#ifndef OAK_ALGORITHM_H_E3HYH9S3
#define OAK_ALGORITHM_H_E3HYH9S3

#include <algorithm>
#include <math.h>

namespace oak
{
	template <typename _InputIter, typename _ValueT>
	bool contains (_InputIter  first, _InputIter  last, _ValueT  value)
	{
		return std::find(first, last, value) != last;
	}

	template <typename _ValueT>
	_ValueT cap (_ValueT min, _ValueT cur, _ValueT max)
	{
		return MAX(min, MIN(cur, max));
	}

	template <typename _InputIter1, typename _InputIter2>
	bool has_prefix (_InputIter1 srcFirst, _InputIter1  srcLast, _InputIter2 prefixFirst, _InputIter2  prefixLast)
	{
		while(srcFirst != srcLast && prefixFirst != prefixLast)
		{
			if(*srcFirst != *prefixFirst)
				return false;
			++srcFirst, ++prefixFirst;
		}
		return prefixFirst == prefixLast;
	}

	template <typename _InputIter1, typename _InputIter2, typename _InputIter3, typename _OutputIter>
	_OutputIter replace_copy (_InputIter1 it, _InputIter1  srcLast, _InputIter2  findFirst, _InputIter2  findLast, _InputIter3  replaceFirst, _InputIter3  replaceLast, _OutputIter out)
	{
		while(it != srcLast)
		{
			_InputIter1  next = search(it, srcLast, findFirst, findLast);
			out = std::copy(it, next, out);
			if((it = next) != srcLast)
			{
				out = std::copy(replaceFirst, replaceLast, out);
				std::advance(it, std::distance(findFirst, findLast));
			}
		}
		return out;
	}

	template <typename _BidirectionalIterator>
	std::reverse_iterator<_BidirectionalIterator> rev_iter (_BidirectionalIterator it)
	{
		return std::reverse_iterator<_BidirectionalIterator>(it);
	}

};

#endif /* end of include guard: OAK_ALGORITHM_H_E3HYH9S3 */
