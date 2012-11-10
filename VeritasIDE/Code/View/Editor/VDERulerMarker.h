//
//  VDERulerMarker.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-10.
//
//

#import <Cocoa/Cocoa.h>

@interface VDERulerMarker : NSRulerMarker
{
    CGFloat _imageOffset;
    BOOL _isValid;
}

- (NSInteger)supportedTypes;
- (NSUInteger)supportedModifiers;

- (BOOL)trackMouse: (NSEvent *)mouseDownEvent
            adding: (BOOL)isAdding;

- (id)delegate;

- (void)drawRect: (CGRect)arg1;

- (void)didDoubleClickWithModifierFlags: (NSUInteger)arg1;
- (void)didSingleClickWithModifierFlags: (NSUInteger)arg1;

- (void)didMove;
- (BOOL)isValid;
- (void)setIsValid: (BOOL)flag;

- (id)initWithRulerView: (NSRulerView *)rulerView
         markerLocation: (CGFloat)location
                  image: (NSImage *)image
            imageOrigin: (CGPoint)pos;
- (id)initWithRulerView: (id)arg1
               location: (CGFloat)arg2
      representedObject: (id)arg3;

@end
