#ifndef INDENT_H_8HVG320W
#define INDENT_H_8HVG320W


#include <scope/scope.h>

namespace indent
{
	struct patterns_t
	{
		typedef regexp::pattern_t const (&array_type)[4];
		operator array_type () const { return array; }
		regexp::pattern_t array[4];
	};

	patterns_t patterns_for_scope (OakScopeContext *  scope);

	template <typename T>
	NSString * line (T  buf, NSUInteger n)
	{
		return buf.substr(buf.begin(n), buf.eol(n));
	}

	template <typename T>
	fsm_t create_fsm (T  buf, regexp::pattern_t const (&patterns)[4], NSUInteger from, NSUInteger indentSize, NSUInteger tabSize)
	{
		fsm_t fsm(patterns, indentSize, tabSize);
		while(from > 0 && !fsm.is_seeded(line(buf, --from)))
			continue;
		return fsm;
	}

} /* indent */

#endif /* end of include guard: INDENT_H_8HVG320W */
