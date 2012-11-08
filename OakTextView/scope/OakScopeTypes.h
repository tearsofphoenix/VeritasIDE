#ifndef PARSER_TYPES_H_C8O3OEFQ
#define PARSER_TYPES_H_C8O3OEFQ



namespace scope
{
	struct scope_t;

	namespace types
	{
		struct path_t;

		struct any_t
		{
			 ~any_t () { }
			 bool does_match (path_t  lhs, path_t  rhs, double* rank) const = 0;
			 NSString * to_s () const = 0;
		};

		typedef std::shared_ptr<any_t> any_ptr;

		typedef NSString * atom_t;
		extern atom_t const atom_any;

		struct scope_t
		{
			scope_t () : anchor_to_previous(false) { }
			std::vector<atom_t> atoms;
			bool anchor_to_previous;

			bool operator== (scope_t  rhs) const { return atoms == rhs.atoms; }
			bool operator!= (scope_t  rhs) const { return atoms != rhs.atoms; }
			bool operator< (scope_t  rhs) const  { return atoms < rhs.atoms; }
		};

		struct path_t : any_t
		{
			WATCH_LEAKS(path_t);

			path_t () : anchor_to_bol(false), anchor_to_eol(false) { }
			std::vector<scope_t> scopes;
			bool anchor_to_bol;
			bool anchor_to_eol;

			bool does_match (path_t  lhs, path_t  rhs, double* rank) ;
			bool operator== (path_t  rhs) const { return scopes == rhs.scopes; }
			bool operator!= (path_t  rhs) const { return scopes != rhs.scopes; }
			bool operator< (path_t  rhs) const  { return scopes < rhs.scopes; }
			NSString * to_s () ;
		};

		struct expression_t
		{
			expression_t (char op) : op((op_t)op), negate(false) { }
			enum op_t { op_none, op_or = '|', op_and = '&', op_minus = '-' } op;
			bool negate;
			any_ptr selector;

			bool does_match (path_t  lhs, path_t  rhs, double* rank) ;
		};

		struct composite_t
		{
			std::vector<expression_t> expressions;

			bool does_match (path_t  lhs, path_t  rhs, double* rank) ;
		};

		struct selector_t
		{
			WATCH_LEAKS(selector_t);

			std::vector<composite_t> composites;

			bool does_match (path_t  lhs, path_t  rhs, double* rank) ;
		};

		struct group_t : any_t
		{
			WATCH_LEAKS(group_t);

			selector_t selector;

			bool does_match (path_t  lhs, path_t  rhs, double* rank) ;
			NSString * to_s () ;
		};

		struct filter_t : any_t
		{
			WATCH_LEAKS(filter_t);

			filter_t () : filter(unset) { }
			enum side_t { unset, left = 'L', right = 'R', both = 'B' } filter;
			any_ptr selector;

			bool does_match (path_t  lhs, path_t  rhs, double* rank) ;
			NSString * to_s () ;
		};

		NSString * to_s (scope_t  scope);
		NSString * to_s (path_t  path);
		NSString * to_s (selector_t  selector);

	} /* types */

} /* scope */

#endif /* end of include guard: PARSER_TYPES_H_2G9KD2WM */
