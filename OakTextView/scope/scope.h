#ifndef SCOPE_SELECTOR_H_WZ1A8GIC
#define SCOPE_SELECTOR_H_WZ1A8GIC

#include <oak/misc.h>


namespace scope
{
	namespace types
	{
		struct path_t;
		struct selector_t;
		typedef std::shared_ptr<path_t> path_ptr;
		typedef std::shared_ptr<selector_t> selector_ptr;

	} /* types */

	struct scope_t
	{
		WATCH_LEAKS(scope_t);

		scope_t ();
		scope_t (char const* scope);
		scope_t (NSString * scope);

		bool has_prefix (scope_t  rhs) const;

		scope_t append (NSString * atom) const;
		scope_t parent () const;

		bool operator== (scope_t  rhs) const;
		bool operator!= (scope_t  rhs) const;
		bool operator< (scope_t  rhs) const;

		explicit operator bool () const;

	private:
		void setup (NSString * str);

		friend struct selector_t;
		friend scope::scope_t shared_prefix (scope_t  a, scope_t  b);
		friend NSString * xml_difference (scope_t  from, scope_t  to, NSString * open, NSString * close);
		friend NSString * to_s (scope_t  s);
		types::path_ptr path;
	};

	struct extern context_t
	{
		context_t () { }
		context_t (char const* str) : left(str), right(str) { }
		context_t (NSString * str) : left(str), right(str) { }
		context_t (scope_t  actual) : left(actual), right(actual) { }
		context_t (scope_t  left, scope_t  right) : left(left), right(right) { }

		bool operator== (context_t  rhs) const { return left == rhs.left && right == rhs.right; }
		bool operator!= (context_t  rhs) const { return !(*this == rhs); }
		bool operator< (context_t  rhs) const  { return left < rhs.left || (left == rhs.left && right < rhs.right); }

		scope_t left, right;
	};

	extern scope_t wildcard;

	extern scope_t shared_prefix (scope_t  a, scope_t  b);
	extern NSString * xml_difference (scope_t  from, scope_t  to, NSString * open = @"<", NSString * close = @">");
	extern NSString * to_s (scope_t  s);
	extern NSString * to_s (context_t  s);

	struct extern selector_t
	{
		WATCH_LEAKS(selector_t);

		selector_t ();
		selector_t (char const* str);
		selector_t (NSString * str);

		bool does_match (context_t  scope, double* rank = NULL) const;

	private:
		void setup (NSString * str);

		friend NSString * to_s (selector_t  s);
		types::selector_ptr selector;
	};

	extern NSString * to_s (selector_t  s);

} /* scope */

#endif /* end of include guard: SCOPE_SELECTOR_H_WZ1A8GIC */