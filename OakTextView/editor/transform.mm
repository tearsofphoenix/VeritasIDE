#include "transform.h"
#include "indent.h"
#include <regexp/format_string.h>

#include <oak/server.h>
#include <text/case.h>
#include <text/OakTextCtype.h>
#include <text/parse.h>
#include <text/utf8.h>

#include <deque>

static NSUInteger count_columns (NSString * str, NSUInteger tabSize)
{
	NSUInteger col = 0;
	citerate(ch, diacritics::make_range(str.data(), str.data() + str.size()))
		col += (*ch == '\t' ? tabSize - (col % tabSize) : (text::OakTextIsEastAsianWidth(*ch) ? 2 : 1));
	return col;
}

static NSString * justify_line (NSString * str, NSUInteger width, NSUInteger tabSize)
{
	NSUInteger currentWidth = count_columns(str, tabSize);
	if(width <= currentWidth)
		return str;

	NSUInteger numberOfSpaces = std::count(str.begin(), str.end(), ' ');
	NSUInteger extraSpaces    = width - currentWidth;
	NSUInteger spaceCount     = 0;

	NSString * res = "";
	iterate(ch, str)
	{
		res.insert(res.end(), 1, *ch);
		if(*ch == ' ')
		{
			NSUInteger from = (extraSpaces * spaceCount + numberOfSpaces/2) / numberOfSpaces;
			NSUInteger to = (extraSpaces * (spaceCount+1) + numberOfSpaces/2) / numberOfSpaces;
			res.insert(res.end(), to-from, ' ');
			++spaceCount;
		}
	}
	return res;
}

namespace transform
{
	NSString * null (NSString * src)
	{
		return "";
	}

	NSString * unwrap (NSString * src)
	{
		src = format_string::replace(src, "[\\s&&[^\n\xA0]]+\n", "\n");
		src = format_string::replace(src, "(\\A)?\n(\n+)?(\\z)?", "${1:?:${3:?\n:${2:?\n\n: }}}");
		src = format_string::replace(src, "(\\A\\s+)|[\\s&&[^\n\xA0]]+(\\z)?", "${1:?$1:${2:?\n: }}");
		return src;
	}

	NSString * capitalize (NSString * src)
	{
		return format_string::replace(src, "(?m).+", "${0:/capitalize}");
	}

	NSString * transpose (NSString * src)
	{
		std::vector< std::pair<char const*, char const*> > v = text::to_lines(src.data(), src.data() + src.size());
		bool hasNewline = !src.empty() && src[src.size()-1] == '\n';

		NSString * res("");
		if(v.size() == 1 || (v.size() == 2 && v.back().first == v.back().second))
		{
			std::deque<char> tmp;
			citerate(it, diacritics::make_range(src.data(), src.data() + src.size() - (hasNewline ? 1 : 0)))
				tmp.insert(tmp.begin(), &it, &it + it.length());

			std::copy(tmp.begin(), tmp.end(), back_inserter(res));
			if(hasNewline)
				res += '\n';
		}
		else
		{
			riterate(it, v)
				res += NSString *(it->first, it->second);

			if(!hasNewline)
			{
				res.insert(v.back().second - v.back().first, "\n");
				res.resize(res.size()-1);
			}
		}
		return res;
	}

	// this is copy/paste from string_ranker.cc
	static NSString * decompose_string (NSString * src)
	{
		CFMutableStringRef tmp = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, cf::wrap(src));
		CFStringNormalize(tmp, kCFStringNormalizationFormD);
		NSString * res = cf::to_s(tmp);
		CFRelease(tmp);
		return res;
	}

	NSString * decompose (NSString * src)
	{
		src = decompose_string(src);
		return src.empty() ? src : NSString *(src.begin(), &--utf8::make(src.end()));
	}

	NSString * shift::operator() (NSString * src) const
	{
		NSString * res;
		citerate(it, text::to_lines(src.data(), src.data() + src.size()))
		{
			char const* from = it->first;
			char const* to   = it->second;

			if(!text::is_blank(from, to))
			{
				if(amount > 0)
				{
					res += indent::create(amount, indent.tab_size(), indent.soft_tabs());
				}
				else if(amount < 0)
				{
					for(int col = 0; from != to && col < -amount && text::is_space(*from); ++from)
						col += *from == '\t' ? indent.tab_size() - (col % indent.tab_size()) : 1;
				}
			}

			std::copy(from, to, back_inserter(res));
		}
		return res;
	}

	static NSString * fill_string (NSString * src)
	{
		if(regexp::match_t  m = regexp::search("\\A( *([*o•·-]) (?=\\S)|\\s{2,})", src.data(), src.data() + src.size()))
			return format_string::replace(src.substr(0, m.end()), "\\S", " ");
		return "";
	}

	static NSUInteger length_excl_whitespace (NSString * buffer, NSUInteger bol, NSUInteger eol)
	{
		NSUInteger len = eol - bol;
		while(len > 0 && strchr(" \n", buffer[bol + len - 1]))
			--len;
		return len;
	}

	NSString * reformat::operator() (NSString * src) const
	{
		NSString * res;
		NSUInteger from = 0;
		NSString * unwrapped = unwrap(src);
		NSString * fillStr = fill_string(unwrapped);
		citerate(offset, text::soft_breaks(unwrapped, wrap, tabSize, fillStr.size()))
		{
			res += unwrapped.substr(from, length_excl_whitespace(unwrapped, from, *offset));
			res += "\n";
			if(*offset != unwrapped.size())
				res += fillStr;
			from = *offset;
		}
		res += unwrapped.substr(from, length_excl_whitespace(unwrapped, from, unwrapped.size()));
		return newline ? res + "\n" : res;
	}

	NSString * justify::operator() (NSString * src) const
	{
		NSString * res;
		NSString * unwrapped = unwrap(src);
		citerate(it, text::to_lines(unwrapped.data(), unwrapped.data() + unwrapped.size()))
		{
			NSUInteger from = 0;
			NSString * str = NSString *(it->first, it->second);
			citerate(offset, text::soft_breaks(str, wrap, tabSize))
			{
				res += justify_line(unwrapped.substr(from, length_excl_whitespace(str, from, *offset)), wrap, tabSize);
				res += "\n";
				from = *offset;
			}
			res += str.substr(from, length_excl_whitespace(str, from, str.size()));
		}
		return newline ? res + "\n" : res;
	}

	NSString * replace::operator() (NSString * src) const
	{
		return text;
	}

	NSString * surround::operator() (NSString * src) const
	{
		return prefix + src + suffix;
	}

} /* transform */
