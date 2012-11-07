#ifndef INTERMEDIATE_H_LWU9YRUW
#define INTERMEDIATE_H_LWU9YRUW

#include <oak/misc.h>

namespace path
{
	struct extern intermediate_t
	{
		intermediate_t (NSString * dest);
		bool commit () const;

		operator NSString * () const { return _intermediate; }
		operator char const* () const        { return _intermediate.c_str(); }

	private:
		NSString * _resolved;
		NSString * _intermediate;
	};
	
} /* path */

#endif /* end of include guard: INTERMEDIATE_H_LWU9YRUW */
