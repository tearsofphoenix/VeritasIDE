#ifndef UTF16_H_VKRVH0HR
#define UTF16_H_VKRVH0HR

#include "utf8.h"


namespace utf16
{
	template <typename _Iter>
	_Iter advance (_Iter  first, NSUInteger distance)
	{
		utf8::iterator_t<char const*> it(first);
		for(; distance; ++it)
			distance -= (*it > 0xFFFF) ? 2 : 1;
		return &it;
	}

	template <typename _Iter>
	_Iter advance (_Iter  first, NSUInteger distance, _Iter  last)
	{
		utf8::iterator_t<char const*> it(first);
		for(; distance && &it != last; ++it)
			distance -= (*it > 0xFFFF) ? 2 : 1;
		return &it;
	}

	template <typename _Iter>
	NSUInteger distance (_Iter  first, _Iter  last)
	{
		NSUInteger res = 0;
		foreach(it, utf8::make(first), utf8::make(last))
			res += (*it > 0xFFFF) ? 2 : 1;
		return res;
	}

} /* utf16 */ 

#endif /* end of include guard: UTF16_H_VKRVH0HR */
