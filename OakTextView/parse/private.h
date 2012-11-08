#ifndef PARSE_PRIVATE_H_XR3VJA2H
#define PARSE_PRIVATE_H_XR3VJA2H

#include "parse.h"



namespace parse
{
	struct rule_t;

	typedef std::shared_ptr<rule_t> rule_ptr;
	typedef std::weak_ptr<rule_t> rule_weak_ptr;
	typedef std::map<NSString *, rule_ptr> repository_t;
	typedef std::shared_ptr<repository_t> repository_ptr;

	struct rule_t
	{
		WATCH_LEAKS(rule_t);

		static NSUInteger rule_id_counter;

		rule_t () : rule_id(++rule_id_counter), include_string(NULL_STR), scope_string(NULL_STR), content_scope_string(NULL_STR), match_string(NULL_STR), while_string(NULL_STR), end_string(NULL_STR), apply_end_last(NULL_STR) { }

		NSUInteger rule_id;

		bool operator== (rule_t  rhs) const { return rule_id == rhs.rule_id; }
		bool operator!= (rule_t  rhs) const { return rule_id != rhs.rule_id; }
		
		NSString * include_string;

		NSString * scope_string;
		NSString * content_scope_string;

		NSString * match_string;
		NSString * while_string;
		NSString * end_string;
		
		NSString * apply_end_last;

		std::vector<rule_ptr> children;
		repository_ptr captures;
		repository_ptr begin_captures;
		repository_ptr while_captures;
		repository_ptr end_captures;
		repository_ptr repository;
		repository_ptr injections;

		// =======================
		// = Pre-parsed versions =
		// =======================

		rule_weak_ptr include;

		regexp::pattern_t match_pattern;
		regexp::pattern_t while_pattern;
		regexp::pattern_t end_pattern;
	};

	struct stack_t
	{
		WATCH_LEAKS(stack_t);

		stack_t (rule_ptr  rule, scope::scope_t  scope, stack_ptr  parent = stack_ptr()) : parent(parent), rule(rule), scope(scope), anchor(0) { }

		stack_ptr parent;

		rule_ptr rule;                      // the rule supplying patterns for current context
		scope::scope_t scope;               // the scope of the current context

		regexp::pattern_t while_pattern;    // a while-pattern active in current context
		regexp::pattern_t end_pattern;      // the end-pattern which exits this context
		NSUInteger anchor;
		bool zw_begin_match;
		bool apply_end_last;

		bool operator== (stack_t  rhs) ;
		bool operator!= (stack_t  rhs) ;
	};

	std::vector< std::pair<scope::selector_t, rule_ptr> >& injected_grammars ();

} /* parse */

#endif /* end of include guard: PARSE_PRIVATE_H_XR3VJA2H */
