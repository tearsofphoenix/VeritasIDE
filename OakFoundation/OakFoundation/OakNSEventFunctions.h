
extern NSString * OakNormalizeEventString (NSString * eventString, NSUInteger* startOfKey);
extern NSString * OakGlyphsForEventString (NSString * eventString, NSUInteger* startOfKey);
extern NSString * OakGlyphsForFlags (NSUInteger flags);


extern NSString * OakStringFromEventAndFlag(NSEvent* anEvent, BOOL preserveNumPadFlag);

extern NSString * OakCreateEventString (NSString* key, NSUInteger flags);
