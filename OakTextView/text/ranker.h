#ifndef RANKER_KFO7JS5A
#define RANKER_KFO7JS5A



namespace oak
{
	extern NSString * normalize_filter (NSString * filter);
	extern double rank (NSString * filter, NSString * candidate, std::vector< std::pair<NSUInteger, NSUInteger> >* out = NULL);
}

#endif /* end of include guard: RANKER_KFO7JS5A */
