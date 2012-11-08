#ifndef GRAMMAR_TYPES_H_4M8CRK03
#define GRAMMAR_TYPES_H_4M8CRK03





namespace parse
{
	struct stack_t;
	typedef std::shared_ptr<stack_t> stack_ptr;

	extern stack_ptr parse (char const* first, char const* last, stack_ptr stack, std::map<NSUInteger, scope::scope_t>& scopes, BOOL firstLine, NSUInteger i = 0);
	extern BOOL equal (stack_ptr lhs, stack_ptr rhs);

} /* parse */ 

#endif /* end of include guard: GRAMMAR_TYPES_H_4M8CRK03 */
