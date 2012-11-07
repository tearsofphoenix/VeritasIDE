#ifndef TEXT_CDEF_H_GWU81P7L
#define TEXT_CDEF_H_GWU81P7L

#include <oak/misc.h>
#include <stdint.h>
#include <CoreFoundation/CFCharacterSet.h>
#include <ctype.h>

namespace text
{
	inline bool is_word_char (uint32_t ch)
	{
		return ch < 0x80 ? (isalnum(ch) || ch == '_') : CFCharacterSetIsLongCharacterMember(CFCharacterSetGetPredefined(kCFCharacterSetAlphaNumeric), ch);
	}

	inline bool is_not_word_char (uint32_t ch)
	{
		return !is_word_char(ch);
	}

	inline bool is_space (char ch)
	{
		return ch == '\t' || ch == ' ';
	}

	inline bool is_not_space (char ch)
	{
		return !is_space(ch);
	}

	inline bool is_blank (char const* it, char const* last)
	{
		last = it != last && last[-1] == '\n' ? last-1 : last;
		return std::find_if(it, last, &is_not_space) == last;
	}

	extern bool OakTextIsEastAsianWidth (uint32_t ch);

} /* text */ 

#endif /* end of include guard: TEXT_CDEF_H_GWU81P7L */
