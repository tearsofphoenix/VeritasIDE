//
//  VDEPushButton.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-1.
//
//

#import "VDEPushButton.h"

@interface VDEPushButton()
{
@private
    id _originTarget;
    SEL _actionSEL;
    BOOL _isSelected;
}

@end

@implementation VDEPushButton

@synthesize selectedImage = _selectedImage;

- (void)setTarget: (id)anObject
{
    _originTarget = anObject;
    
    [super setTarget: self];
}

- (void)setAction: (SEL)aSelector
{
    _actionSEL = aSelector;
    
    [super setAction: @selector(_handleButtonPressedEvent:)];
}

- (void)_handleButtonPressedEvent: (id)sender
{
    _isSelected = !_isSelected;
    if (_isSelected)
    {
        [self setImage: _selectedImage];
        
    }else
    {
        [self setImage: [self alternateImage]];
    }
    
    [_originTarget performSelector: _actionSEL
                        withObject: self];
}

- (BOOL)isSelected
{
    return _isSelected;
}

@end
