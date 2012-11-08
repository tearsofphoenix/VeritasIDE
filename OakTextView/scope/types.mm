#include "OakScopeTypes.h"



namespace scope
{
	namespace types
	{
		atom_t const atom_any = "*";

		NSString * to_s (atom_t  v);

		template <typename T>
		NSString * join (T  container, NSString * sep)
		{
			NSString * res = "";
			iterate(it, container)
				res += (res.empty() ? "" : sep) + to_s(*it);
			return res;
		}

		NSString * to_s (any_ptr  v)         { return v ? v->to_s() : "(null)"; }

		NSString * to_s (atom_t  v)          { return v.empty() ? "(empty)" : text::format("%s", v.c_str()); }
		NSString * to_s (scope_t  v)         { return (v.anchor_to_previous ? "> " : "") + join(v.atoms, "."); }

		NSString * to_s (path_t  v)          { return (v.anchor_to_bol ? "^ " : "") + join(v.scopes, " ") + (v.anchor_to_eol ? " $" : ""); }

		NSString * to_s (group_t  v)         { return "(" + to_s(v.selector) + ")"; }
		NSString * to_s (filter_t  v)        { return text::format("%c:", v.filter) + to_s(v.selector); }

		NSString * to_s (expression_t  v)    { return NSString *(v.op != expression_t::op_none ? text::format("%c ", v.op) : "") + (v.negate ? "-" : "") + to_s(v.selector); }
		NSString * to_s (composite_t  v)     { return join(v.expressions, " "); }

		NSString * to_s (selector_t  v)      { return join(v.composites, ", "); }

		NSString * path_t::to_s () const           { return scope::types::to_s(*this); }
		NSString * group_t::to_s () const          { return scope::types::to_s(*this); }
		NSString * filter_t::to_s () const         { return scope::types::to_s(*this); }

	} /* types */ 

} /* scope */ 
