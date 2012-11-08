#include "scope.h"
#include "parse.h"



namespace scope
{
	scope_t wildcard("x-any");

	// =========
	// = Scope =
	// =========

	scope_t::scope_t ()                         { ; }
	scope_t::scope_t (char const* scope)        { setup(scope); }
	scope_t::scope_t (NSString * scope) { setup(scope); }

	void scope_t::setup (NSString * scope)
	{
		path.reset(new scope::types::path_t);
		scope::parse::path(scope.data(), scope.data() + scope.size(), *path);
	}

	BOOL scope_t::has_prefix (scope_t  rhs) const
	{
		std::vector<types::scope_t>  lhsScopes = path     ? path->scopes     : std::vector<types::scope_t>();
		std::vector<types::scope_t>  rhsScopes = rhs.path ? rhs.path->scopes : std::vector<types::scope_t>();

		NSUInteger i = 0;
		for(; i < MIN(lhsScopes.size(), rhsScopes.size()); ++i)
		{
			if(lhsScopes[i] != rhsScopes[i])
				break;
		}

		return i == rhsScopes.size();
	}

	scope_t scope_t::append (NSString * atom) const
	{
		scope_t res;
		res.path.reset(new types::path_t(path ? *path : types::path_t()));
		types::scope_t scope;
		parse::scope(atom.data(), atom.data() + atom.size(), scope);
		res.path->scopes.push_back(scope);
		return res;
	}

	scope_t scope_t::parent () const
	{
		scope_t res;
		if(path && !path->scopes.empty())
		{
			res.path.reset(new types::path_t(*path));
			res.path->scopes.pop_back();
		}
		return res;
	}

	BOOL scope_t::operator== (scope_t  rhs) const   { return (!path && !rhs.path) || (path && rhs.path && *path == *rhs.path); }
	BOOL scope_t::operator!= (scope_t  rhs) const   { return !(*this == rhs); }
	BOOL scope_t::operator< (scope_t  rhs) const    { return (!path && rhs.path) || (path && rhs.path && *path < *rhs.path); }
	scope_t::operator BOOL () const                       { return path ? true : false; }

	scope_t shared_prefix (scope_t  lhs, scope_t  rhs)
	{
		std::vector<types::scope_t>  lhsScopes = lhs.path ? lhs.path->scopes : std::vector<types::scope_t>();
		std::vector<types::scope_t>  rhsScopes = rhs.path ? rhs.path->scopes : std::vector<types::scope_t>();

		NSUInteger i = 0;
		for(; i < MIN(lhsScopes.size(), rhsScopes.size()); ++i)
		{
			if(lhsScopes[i] != rhsScopes[i])
				break;
		}

		scope_t res;
		res.path.reset(new types::path_t);
		res.path->scopes.insert(res.path->scopes.end(), lhsScopes.begin(), lhsScopes.begin() + i);
		return res;
	}

	NSString * xml_difference (scope_t  lhs, scope_t  rhs, NSString * open, NSString * close)
	{
		std::vector<types::scope_t>  lhsScopes = lhs.path ? lhs.path->scopes : std::vector<types::scope_t>();
		std::vector<types::scope_t>  rhsScopes = rhs.path ? rhs.path->scopes : std::vector<types::scope_t>();

		NSUInteger i = 0;
		for(; i < MIN(lhsScopes.size(), rhsScopes.size()); ++i)
		{
			if(lhsScopes[i] != rhsScopes[i])
				break;
		}

		NSString * res = "";
		for(NSUInteger j = lhsScopes.size(); j > i; --j)
			res += open + "/" + to_s(lhsScopes[j-1]) + close;
		for(NSUInteger j = i; j < rhsScopes.size(); ++j)
			res += open + to_s(rhsScopes[j]) + close;
		return res;
	}

	NSString * to_s (scope_t  s)
	{
		return s.path ? to_s(*s.path) : "";
	}

	NSString * to_s (context_t  c)
	{
		return c.left == c.right ? text::format("(l/r ‘%s’)", to_s(c.left).c_str()) : text::format("(left ‘%s’, right ‘%s’)", to_s(c.left).c_str(), to_s(c.right).c_str());
	}

	// ============
	// = Selector =
	// ============

	selector_t::selector_t ()                        { ; }
	selector_t::selector_t (char const* str)         { setup(str); }
	selector_t::selector_t (NSString * str)  { setup(str); }

	void selector_t::setup (NSString * str)
	{
		selector.reset(new scope::types::selector_t);
		scope::parse::selector(str.data(), str.data() + str.size(), *selector);
	}

	NSString * to_s (selector_t  s)
	{
		return s.selector ? to_s(*s.selector) : "";
	}

	// ============
	// = Matching =
	// ============

	BOOL selector_t::does_match (context_t  scope, double* rank) const
	{
		if(!selector)
		{
			if(rank)
				*rank = 0;
			return true;
		}
		if(!scope.left.path || !scope.right.path)
			return false;
		return scope.left == wildcard || scope.right == wildcard || selector->does_match(*scope.left.path, *scope.right.path, rank);
	}
}
