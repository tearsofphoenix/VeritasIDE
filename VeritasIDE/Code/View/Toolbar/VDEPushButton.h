//
//  VDEPushButton.h
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-1.
//
//

#import <Cocoa/Cocoa.h>

@interface VDEPushButton : NSButton

@property (retain) NSImage *selectedImage;

- (BOOL)isSelected;

@end
