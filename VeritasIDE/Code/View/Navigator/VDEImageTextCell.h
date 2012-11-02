/*
     File: VDEImageTextCell.h 
 Abstract: Subclass of NSTextFieldCell which can display text and an image simultaneously.
 
 */

#import <Cocoa/Cocoa.h>

@interface VDEImageTextCell : NSTextFieldCell

@property (nonatomic, strong) NSImage *image;

@end
