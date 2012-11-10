//
//  VDERulerMarker.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-10.
//
//

#import "VDERulerMarker.h"

@implementation VDERulerMarker


- (NSInteger)supportedTypes
{
    
}
- (NSUInteger)supportedModifiers
{
    
}

- (BOOL)trackMouse: (NSEvent *)mouseDownEvent
            adding: (BOOL)isAdding
{
    
}

- (id)delegate
{
    
}

- (void)drawRect: (CGRect)arg1
{
    
}

- (void)didDoubleClickWithModifierFlags: (NSUInteger)arg1
{
    
}
- (void)didSingleClickWithModifierFlags: (NSUInteger)arg1
{
    
}

- (void)didMove
{
    
}

- (BOOL)isValid
{
    return _isValid;
}

- (void)setIsValid: (BOOL)flag
{
    if (_isValid != flag)
    {
        _isValid = flag;
    }
}

- (id)initWithRulerView: (NSRulerView *)rulerView
         markerLocation: (CGFloat)location
                  image: (NSImage *)image
            imageOrigin: (CGPoint)pos
{
    if ((self = [super initWithRulerView: rulerView
                          markerLocation: location
                                   image: image
                             imageOrigin: pos]))
    {
        
    }
    
    return self;
}

- (id)initWithRulerView: (NSRulerView *)rulerView
               location: (CGFloat)location
      representedObject: (id)arg3
{
    if ((self = [super initWithRulerView: rulerView
                          markerLocation: location
                                   image: nil
                             imageOrigin: NSZeroPoint]))
    {
        [self setRepresentedObject: arg3];
    }
    
    return self;
}

@end
