
@interface NSImage (ImageFromBundle)

+ (NSImage*)imageNamed: (NSString*)aName
   inSameBundleAsClass: (Class)anObject;

- (void)drawAdjustedAtPoint: (NSPoint)aPoint
                   fromRect: (NSRect)srcRect
                  operation: (NSCompositingOperation)op
                   fraction: (CGFloat)delta;

- (void)drawAdjustedInRect: (NSRect)dstRect
                  fromRect: (NSRect)srcRect
                 operation: (NSCompositingOperation)op
                  fraction: (CGFloat)delta;
@end
