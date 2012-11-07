#ifndef TEXT_UTF8_H_8I8S2ODM
#define TEXT_UTF8_H_8I8S2ODM

namespace utf8
{
	inline uint32_t to_ch (NSString * str)
	{

		uint32_t value = [str UTF8String][0];
		NSUInteger mb_length = 1;

		if((value & 0xC0) == 0xC0) // multi-byte
		{
			assert((value & 0xFE) != 0xFE);
			while(value & (1 << (7-mb_length)))
				++mb_length;
			assert([str length] >= mb_length);

			value = value & ((1 << (7-mb_length))-1);
			for(ssize_t i = 1; i < mb_length; ++i)
			{
				value = (value << 6) | ([str UTF8String][i] & 0x3F);
				assert(([str UTF8String][i] & 0xC0) == 0x80);
			}
		}
		return value;
	}

	inline NSString * to_s (uint32_t ch)
	{
		char res[6];
		NSUInteger bitsLeft = 0, strLen = 1;
		if(ch <= 0x7F) // 0xxxxxxx
			res[0] = ((ch >> (bitsLeft =  0)) & 0x7F) | 0x00;
		else if(ch <= 0x7FF) // 110xxxxx 10xxxxxx
			res[0] = ((ch >> (bitsLeft =  6)) & 0x1F) | 0xC0;
		else if(ch <= 0xFFFF) // 1110xxxx 10xxxxxx 10xxxxxx
			res[0] = ((ch >> (bitsLeft = 12)) & 0x0F) | 0xE0;
		else if(ch <= 0x1FFFFF) // 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
			res[0] = ((ch >> (bitsLeft = 18)) & 0x07) | 0xF0;
		else if(ch <= 0x3FFFFFF) // 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
			res[0] = ((ch >> (bitsLeft = 24)) & 0x03) | 0xF8;
		else // if(ch <= 0x7FFFFFFF) // 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
			res[0] = ((ch >> (bitsLeft = 30)) & 0x01) | 0xFC;

		while(bitsLeft >= 6)
		{
			bitsLeft -= 6;
			res[strLen++] = ((ch >> bitsLeft) & 0x3F) | 0x80;
		}

		return [[[NSString alloc] initWithBytes: res
                                         length: strLen
                                       encoding: NSUTF8StringEncoding] autorelease];
	}

	template <typename _Iter>
	struct iterator_t : public std::iterator<std::bidirectional_iterator_tag, uint32_t>
	{
		typedef iterator_t self;

		iterator_t (_Iter  base_iterator) : base_iterator(base_iterator) { }
		iterator_t () { }

		self& operator++ ()								{ fetch(); std::advance(base_iterator, mb_length); return *this; }
		self& operator-- ()								{ do { --base_iterator; } while((*base_iterator & 0xC0) == 0x80); return *this; }

		bool operator== (self  rhs) const	{ return base_iterator == rhs.base_iterator; }
		bool operator!= (self  rhs) const	{ return base_iterator != rhs.base_iterator; }

		uint32_t& operator* ()                  { fetch(); return value; }
		uint32_t  operator* () const      { fetch(); return value; }

		_Iter operator& () const						{ return base_iterator; }
		ssize_t length () const							{ fetch(); return mb_length; }

	private:
		void fetch () const
		{
			_Iter it = base_iterator;
			value = *it;
			mb_length = 1;

			if((value & 0xC0) == 0xC0) // multi-byte
			{
				assert((value & 0xFE) != 0xFE);
				while(value & (1 << (7-mb_length)))
					++mb_length;

				value = value & ((1 << (7-mb_length))-1);
				for(ssize_t i = 1; i < mb_length; ++i)
				{
					value = (value << 6) | (*++it & 0x3F);
					assert((*it & 0xC0) == 0x80);
				}
			}
		}

		_Iter base_iterator;
		mutable uint32_t value;
		mutable ssize_t mb_length;
	};

	template <typename _BaseIter> iterator_t<_BaseIter> make (_BaseIter  base)	{ return iterator_t<_BaseIter>(base); }

	struct validate_t
	{
		validate_t () : len(0), seen(0), success(true) { }
		bool is_valid () const { return success && len == 0; }

		template <typename _Iter>
		bool scan (_Iter  first, _Iter  last)
		{
			for(_Iter it = first; it != last && success; ++it)
			{
				typename std::iterator_traits<_Iter>::value_type ch = *it;
				if(len) // we are in a multi-byte sequence
				{
					if((ch & 0xC0) == 0x80)
					{
						if(++seen == len)
							len = seen = 0;
					}
					else
					{
						success = false;
					}
				}
				else if((ch & 0xC0) == 0x80)
				{
					success = false;
				}
				else if((ch & 0x80) == 0x80)
				{
					NSUInteger numBytes = 1;
					while(ch & (1 << (7-numBytes)))
						++numBytes;

					if(numBytes > 6)
						success = false;

					len = numBytes;
					seen = 1;
				}

// #ifndef NDEBUG
// 				if(!success)
// 				{
// 					fprintf(stderr, "%zu / %zu\n", seen, len);
// 					std::vector<char> v;
// 					text::hex_dump(first, it + 1, back_inserter(v));
// 					fprintf(stderr, "%.*s", (int)v.size(), &v[0]);
// 				}
// #endif
			}
			return success;
		}

	private:
		NSUInteger len, seen;
		bool success;
	};

	template <typename _Iter>
	bool is_valid (_Iter  first, _Iter  last)
	{
		validate_t validate;
		return validate.scan(first, last) && validate.is_valid();
	}

	template <typename T>
	struct multibyte
	{
		static bool partial (T ch)       { return ch & 0x80; }
		static bool is_start (T ch)      { return (ch & 0xC0) == 0xC0; }
		static NSUInteger length (T ch)      {
			assert(is_start(ch)); assert((ch & 0xF8) != 0xF8);
			NSUInteger numBytes = 1;
			while((ch & (1 << (7-numBytes))) && numBytes < 6)
				++numBytes;
			return numBytes;
		}
	};

	template <typename _Iter>
	_Iter find_safe_end (_Iter  first, _Iter  last)
	{
		typedef typename std::iterator_traits<_Iter>::value_type T;

		if(first == last || !multibyte<T>::partial(last[-1]))
			return last;

		_Iter it = last;
		while(!multibyte<T>::is_start(*--it) && it != first)
			;

		return (it + multibyte<T>::length(*it) > last) ? it : last;
	}

} /* utf8 */

namespace diacritics
{
	template <typename _Iter>
	struct iterator_t : public std::iterator<std::bidirectional_iterator_tag, uint32_t>
	{
		typedef iterator_t self;

		iterator_t (utf8::iterator_t<_Iter>  first, utf8::iterator_t<_Iter>  last) : current(first), stop(last) { }

		self& operator++ ()											{ fetch(); current = next; return *this; }

		self& operator-- ()
		{
			next = current;
			while(true)
			{
				uint32_t ch = *--current;
				if(ch < 0x100 || !CFCharacterSetIsLongCharacterMember(CFCharacterSetGetPredefined(kCFCharacterSetNonBase), ch))
					break;
			}
			return *this;
		}

		self operator+ (ssize_t dist) const
		{
			self res(*this);
			for(; dist > 0; --dist)
				++res;
			for(; dist < 0; ++dist)
				--res;
			return res;
		}

		self operator- (ssize_t dist) const
		{
			return *this + -dist;
		}

		ssize_t operator- (self  rhs) const
		{
			ssize_t res = 0;
			for(self tmp(rhs); tmp != *this; ++tmp)
				++res;
			return res;
		}

		bool operator== (self  rhs) const				{ return current == rhs.current; }
		bool operator!= (self  rhs) const				{ return current != rhs.current; }

		uint32_t& operator* ()                     { assert(current != stop); return *current; }
		uint32_t  operator* () const         { assert(current != stop); return *current; }

		_Iter operator& () const									{ return &current; }
		ssize_t length () const										{ fetch(); return &next - &current; }

	private:
		utf8::iterator_t<_Iter> current, stop;
		mutable utf8::iterator_t<_Iter> next;

		void fetch () const
		{
			assert(current != stop);
			for(next = current; ++next != stop; )
			{
				uint32_t ch = *next;
				if(ch < 0x100 || !CFCharacterSetIsLongCharacterMember(CFCharacterSetGetPredefined(kCFCharacterSetNonBase), ch))
					break;
			}
		}
	};

	template <typename _BaseIter> iterator_t<_BaseIter> begin_of (_BaseIter  first, _BaseIter  last)	{ return iterator_t<_BaseIter>(utf8::iterator_t<_BaseIter>(first), utf8::iterator_t<_BaseIter>(last)); }
	template <typename _BaseIter> iterator_t<_BaseIter> end_of (_BaseIter  first, _BaseIter  last)		{ return iterator_t<_BaseIter>(utf8::iterator_t<_BaseIter>(last), utf8::iterator_t<_BaseIter>(last)); }

	template <typename _BaseIter>
	struct range_t
	{
		typedef iterator_t<_BaseIter> const_iterator;

		range_t (iterator_t<_BaseIter>  first, iterator_t<_BaseIter>  last) : first(first), last(last) { }
		iterator_t<_BaseIter> begin () const	{ return first; }
		iterator_t<_BaseIter> end () const		{ return last; }

		std::reverse_iterator< iterator_t<_BaseIter> > rbegin ()			{ return std::reverse_iterator< iterator_t<_BaseIter> >(last); }
		std::reverse_iterator< iterator_t<_BaseIter> > rend ()					{ return std::reverse_iterator< iterator_t<_BaseIter> >(first); }

	private:
		iterator_t<_BaseIter> first, last;
	};

	template <typename _BaseIter>
	range_t<_BaseIter> make_range (_BaseIter  first, _BaseIter  last)
	{
		return range_t<_BaseIter>(iterator_t<_BaseIter>(utf8::iterator_t<_BaseIter>(first), utf8::iterator_t<_BaseIter>(last)), iterator_t<_BaseIter>(utf8::iterator_t<_BaseIter>(last), utf8::iterator_t<_BaseIter>(last)));
	}
	
} /* diacritics */

#endif /* end of include guard: TEXT_UTF8_H_8I8S2ODM */
