/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import <XcodeEdit/XCTextAnnotation.h>

@class PBXDebugInstructionPointer;

@interface XCInstructionPointerTextAnnotation : XCTextAnnotation
{
    PBXDebugInstructionPointer *_instrPointer;
}

+ (id)annotationWithInstructionPointer:(id)arg1;
+ (NSUInteger)_defaultHighlightsByMask;
+ (id)_defaultAnnotationTheme;
+ (NSUInteger)_defaultSidebarMarkerAlignment;
+ (id)instructionPointerSidebarIcon;
@property(readonly, nonatomic) PBXDebugInstructionPointer *instructionPointer; // @synthesize instructionPointer=_instrPointer;
- (BOOL)isInstructionPointer;
- (void)drawInParagraphRect:(CGRect)arg1 sidebarRect:(CGRect)arg2 withArrowPoint:(CGPoint)arg3 inTextView:(id)arg4;
- (NSInteger)precedence;
- (BOOL)wantsOmittedLineNumber;
- (id)sidebarMarkerIconImage;
- (void)dealloc;
- (id)initWithInstructionPointer:(id)arg1;

@end

