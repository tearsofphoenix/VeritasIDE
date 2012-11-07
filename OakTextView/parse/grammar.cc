#include "grammar.h"
#include "private.h"


#include <plist/schema.h>




OAK_DEBUG_VAR(Parser);

namespace parse
{
	static rule_ptr parse_rule (id plist);

	static bool convert_array (plist::array_t  array, std::vector<rule_ptr>& res)
	{
		iterate(it, array)
		{
			if(rule_ptr  child = parse_rule(*it))
				res.push_back(child);
		}
		return true;
	}

	static bool convert_dictionary (NSMutableDictionary *  dict, repository_ptr& res)
	{
		res.reset(new repository_t);
		iterate(it, dict)
		{
			if(rule_ptr  child = parse_rule(it->second))
				res->insert(std::make_pair(it->first, child));
		}
		return true;
	}

	static rule_ptr parse_rule (id any)
	{
		static plist::schema_t<rule_t> schema = plist::schema_t<rule_t>()
			.map("name",                &rule_t::scope_string                             )
			.map("scopeName",           &rule_t::scope_string                             )
			.map("contentName",         &rule_t::content_scope_string                     )
			.map("match",               &rule_t::match_string                             )
			.map("begin",               &rule_t::match_string                             )
			.map("while",               &rule_t::while_string                             )
			.map("end",                 &rule_t::end_string                               )
			.map("applyEndPatternLast", &rule_t::apply_end_last                           )
			.map("include",             &rule_t::include_string                           )
			.map("patterns",            &rule_t::children,             &convert_array     )
			.map("captures",            &rule_t::captures,             &convert_dictionary)
			.map("beginCaptures",       &rule_t::begin_captures,       &convert_dictionary)
			.map("whileCaptures",       &rule_t::while_captures,       &convert_dictionary)
			.map("endCaptures",         &rule_t::end_captures,         &convert_dictionary)
			.map("repository",          &rule_t::repository,           &convert_dictionary)
			.map("injections",          &rule_t::injections,           &convert_dictionary)
		;

		if(NSMutableDictionary * const* plist = boost::get<NSMutableDictionary *>(&any))
		{
			if(!plist->empty() && (plist->find("disabled") == plist->end() || !plist::get<int32_t>(plist->find("disabled")->second)))
			{
				rule_ptr res(new rule_t);
				if(schema.convert(*plist, res.get()))
					return res;
			}
		}
		return rule_ptr();
	}

	static rule_ptr find_repository_item (rule_ptr  rule, NSString * name)
	{
		if(rule->repository)
		{
			repository_t::const_iterator it = rule->repository->find(name);
			if(it != rule->repository->end())
				return it->second;
		}
		return rule_ptr();
	}

	static bool pattern_has_back_references (NSString * ptrn)
	{
		bool escape = false;
		iterate(it, ptrn)
		{
			if(escape && isdigit(*it))
			{
				D(DBF_Parser, bug("%s: %s\n", ptrn.c_str(), "YES"););
				return true;
			}
			escape = !escape && *it == '\\';
		}
		D(DBF_Parser, bug("%s: %s\n", ptrn.c_str(), "NO"););
		return false;
	}

	// =============
	// = grammar_t =
	// =============

	grammar_t::grammar_t (OakBundleItem * grammarItem) : _item(grammarItem), _bundles_callback(*this)
	{
		bundles::add_callback(&_bundles_callback);
		_rule = parse_rule(_item->plist());

		if(!_rule)
		{
			fprintf(stderr, "*** grammar missing for ‘%s’\n", _item->name().c_str());
			_rule.reset(new rule_t);
		}

		_old_plist = _item->plist();
	}

	grammar_t::~grammar_t ()
	{
		bundles::remove_callback(&_bundles_callback);
	}

	NSUUID * grammar_t::uuid () const
	{
		static NSUUID * FallbackGrammarUUID = NSUUID *().generate();
		return _item ? _item->uuid() : FallbackGrammarUUID;
	}

	stack_ptr grammar_t::seed () const
	{
		return stack_ptr(new stack_t(_rule, _rule ? _rule->scope_string : ""));
	}

	void grammar_t::bundles_did_change ()
	{
		OakBundleItem * newItem = bundles::lookup(uuid());
		if(newItem && !plist::equal(_old_plist, newItem->plist())) // FIXME this is a kludge, ideally we should register as callback for the bundle item (when that is supported)
		{
			if(rule_ptr rule = parse_rule(newItem->plist()))
			{
				_item = newItem;
				_rule = rule;
				_old_plist = _item->plist();
				resolve_includes();

				_callbacks(&callback_t::grammar_did_change);
			}
		}
	}

	void grammar_t::resolve_includes ()
	{
		std::vector<rule_ptr> tmp;
		resolve_includes(_rule, tmp);
	}

	void grammar_t::resolve_includes (rule_ptr rule, std::vector<rule_ptr>& stack)
	{
		if(!rule)
			return;

		NSString * inc = rule->include_string;
		if(inc != NULL_STR && inc != "$base")
		{
			D(DBF_Parser, bug("%s\n", inc.c_str()););
			if(inc == "$self")
			{
				rule->include = stack.front();
			}
			else if(inc[0] == '#')
			{
				NSString * name = inc.substr(1);
				riterate(it, stack)
				{
					if(rule_ptr  res = find_repository_item(*it, name))
					{
						rule->include = res;
						D(DBF_Parser, bug("found include: %s\n", res->scope_string.c_str()););
						break;
					}
				}
			}
			else
			{
				NSString *::size_type fragment = inc.find('#');
				citerate(item, bundles::query(bundles::kFieldGrammarScope, fragment == NSString *::npos ? inc : inc.substr(0, fragment), scope::wildcard, bundles::kItemTypeGrammar))
				{
					if(grammar_ptr grammar = parse_grammar(*item))
					{
						rule->include = fragment == NSString *::npos ? grammar->_rule : find_repository_item(grammar->_rule, inc.substr(fragment+1));
						break;
					}
				}
			}

			if(rule->include.expired())
				fprintf(stderr, "*** couldn’t resolve %s\n", inc.c_str());
		}
		else
		{
			if(rule->match_string != NULL_STR)
			{
				rule->match_pattern = regexp::pattern_t(rule->match_string);
				if(!rule->match_pattern)
					fprintf(stderr, "bad begin/match pattern for %s\n", rule->scope_string.c_str());
			}
			if(rule->while_string != NULL_STR && !pattern_has_back_references(rule->while_string))
			{
				rule->while_pattern = regexp::pattern_t(rule->while_string);
				if(!rule->while_pattern)
					fprintf(stderr, "bad while pattern for %s\n", rule->scope_string.c_str());
			}
			if(rule->end_string != NULL_STR && !pattern_has_back_references(rule->end_string))
			{
				rule->end_pattern = regexp::pattern_t(rule->end_string);
				if(!rule->end_pattern)
					fprintf(stderr, "bad end pattern for %s\n", rule->scope_string.c_str());
			}
		}

		stack.push_back(rule);
		iterate(it, rule->children)
			resolve_includes(*it, stack);

		repository_ptr maps[] = { rule->repository, rule->captures, rule->begin_captures, rule->while_captures, rule->end_captures, rule->injections };
		iterate(it, maps)
		{
			if(!*it)
				continue;

			iterate(mapIter, **it)
				resolve_includes(mapIter->second, stack);
		}
		stack.pop_back();
	}

	// ==============
	// = Public API =
	// ==============

	grammar_ptr parse_grammar (OakBundleItem * grammarItem)
	{
		static std::map<NSUUID *, grammar_ptr> Cache;
		injected_grammars(); // ensure these are loaded in the main thread

		NSUUID * uuid = grammarItem->uuid();
		std::map<NSUUID *, grammar_ptr>::iterator grammar = Cache.find(uuid);
		if(grammar == Cache.end())
		{
			grammar = Cache.insert(std::make_pair(uuid, grammar_ptr(new grammar_t(grammarItem)))).first;
			grammar->second->resolve_includes();
		}
		return grammar->second;
	}

} /* parse */ 
