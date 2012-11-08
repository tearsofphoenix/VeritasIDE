
static inline uint32_t OakUTF8StringToChar (NSString * str)
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

static inline NSString * OakUTF8CharToString(uint32_t ch)
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
//
//namespace diacritics
//{
//	template <typename _Iter>
//	struct iterator_t : public std::iterator<std::bidirectional_iterator_tag, uint32_t>
//	{
//		typedef iterator_t self;
//        
//		iterator_t (utf8::iterator_t<_Iter>  first, utf8::iterator_t<_Iter>  last) : current(first), stop(last) { }
//        
//		self& operator++ ()											{ fetch(); current = next; return *this; }
//        
//		self& operator-- ()
//		{
//			next = current;
//			while(true)
//			{
//				uint32_t ch = *--current;
//				if(ch < 0x100 || !CFCharacterSetIsLongCharacterMember(CFCharacterSetGetPredefined(kCFCharacterSetNonBase), ch))
//					break;
//			}
//			return *this;
//		}
//        
//		self operator+ (ssize_t dist) const
//		{
//			self res(*this);
//			for(; dist > 0; --dist)
//				++res;
//			for(; dist < 0; ++dist)
//				--res;
//			return res;
//		}
//        
//		self operator- (ssize_t dist) const
//		{
//			return *this + -dist;
//		}
//        
//		ssize_t operator- (self  rhs) const
//		{
//			ssize_t res = 0;
//			for(self tmp(rhs); tmp != *this; ++tmp)
//				++res;
//			return res;
//		}
//        
//		BOOL operator== (self  rhs) const				{ return current == rhs.current; }
//		BOOL operator!= (self  rhs) const				{ return current != rhs.current; }
//        
//		uint32_t& operator* ()                     { assert(current != stop); return *current; }
//		uint32_t  operator* () const         { assert(current != stop); return *current; }
//        
//		_Iter operator& () const									{ return &current; }
//		ssize_t length () const										{ fetch(); return &next - &current; }
//        
//	private:
//		utf8::iterator_t<_Iter> current, stop;
//		mutable utf8::iterator_t<_Iter> next;
//        
//		void fetch () const
//		{
//			assert(current != stop);
//			for(next = current; ++next != stop; )
//			{
//				uint32_t ch = *next;
//				if(ch < 0x100 || !CFCharacterSetIsLongCharacterMember(CFCharacterSetGetPredefined(kCFCharacterSetNonBase), ch))
//					break;
//			}
//		}
//	};
//    
//	template <typename _BaseIter> iterator_t<_BaseIter> begin_of (_BaseIter  first, _BaseIter  last)	{ return iterator_t<_BaseIter>(utf8::iterator_t<_BaseIter>(first), utf8::iterator_t<_BaseIter>(last)); }
//	template <typename _BaseIter> iterator_t<_BaseIter> end_of (_BaseIter  first, _BaseIter  last)		{ return iterator_t<_BaseIter>(utf8::iterator_t<_BaseIter>(last), utf8::iterator_t<_BaseIter>(last)); }
//    
//	template <typename _BaseIter>
//	struct range_t
//	{
//		typedef iterator_t<_BaseIter> const_iterator;
//        
//		range_t (iterator_t<_BaseIter>  first, iterator_t<_BaseIter>  last) : first(first), last(last) { }
//		iterator_t<_BaseIter> begin () const	{ return first; }
//		iterator_t<_BaseIter> end () const		{ return last; }
//        
//		std::reverse_iterator< iterator_t<_BaseIter> > rbegin ()			{ return std::reverse_iterator< iterator_t<_BaseIter> >(last); }
//		std::reverse_iterator< iterator_t<_BaseIter> > rend ()					{ return std::reverse_iterator< iterator_t<_BaseIter> >(first); }
//        
//	private:
//		iterator_t<_BaseIter> first, last;
//	};
//    
//	template <typename _BaseIter>
//	range_t<_BaseIter> make_range (_BaseIter  first, _BaseIter  last)
//	{
//		return range_t<_BaseIter>(iterator_t<_BaseIter>(utf8::iterator_t<_BaseIter>(first), utf8::iterator_t<_BaseIter>(last)), iterator_t<_BaseIter>(utf8::iterator_t<_BaseIter>(last), utf8::iterator_t<_BaseIter>(last)));
//	}
//}
