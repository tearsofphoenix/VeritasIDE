#include "editor.h"

#include <text/classification.h>
#include <text/utf8.h>
#include <text/OakTextCtype.h>

namespace ng
{
	// ====================
	// = Visual Distances =
	// ====================

	NSUInteger editor_t::visual_distance (NSString *  buffer, index_t first, index_t last, bool eastAsianWidth)
	{
		ASSERT_LE(first.index, last.index);
		ASSERT_EQ(buffer.convert(first.index).line, buffer.convert(last.index).line);
		NSUInteger len = 0, tabSize = buffer.indent().tab_size();
		NSString * str = buffer.substr(first.index, last.index);
		citerate(ch, diacritics::make_range(str.data(), str.data() + str.size()))
			len += *ch == '\t' ? tabSize - (len % tabSize) : (eastAsianWidth && text::OakTextIsEastAsianWidth(*ch) ? 2 : 1);
		return len + (first.index == last.index ? last.carry - first.carry : last.carry);
	}

	index_t editor_t::visual_advance (NSString *  buffer, index_t caret, NSUInteger distance, bool eastAsianWidth)
	{
		NSUInteger len = 0, tabSize = buffer.indent().tab_size();
		NSString * str = buffer.substr(caret.index, buffer.eol(buffer.convert(caret.index).line));
		citerate(ch, diacritics::make_range(str.data(), str.data() + str.size()))
		{
			if(len == distance)
				return index_t(caret.index + (&ch - str.data()));

			NSUInteger chWidth = *ch == '\t' ? tabSize - (len % tabSize) : (eastAsianWidth && text::OakTextIsEastAsianWidth(*ch) ? 2 : 1);
			if(len + chWidth > distance || *ch == '\n')
				return index_t(caret.index + (&ch - str.data()), distance - len);

			len += chWidth;
		}
		return index_t(caret.index + str.size(), distance - len);
	}

} /* ng */