#ifndef NS_H_SEBJ2BBY
#define NS_H_SEBJ2BBY

#include <oak/misc.h>
#include "event.h"

extern NSString * to_s (NSString* aString);
extern NSString * to_s (NSData* aString);
extern NSString * to_s (NSEvent* anEvent, bool preserveNumPadFlag = false);

namespace ns
{
	extern NSString * create_event_string (NSString* key, NSUInteger flags);

} /* ns */

#endif /* end of include guard: NS_H_SEBJ2BBY */
