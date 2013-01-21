/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import "NSLayoutManager.h"

@interface XCLayoutManager : NSLayoutManager
{
}

+ (void)initialize;
- (void)drawUnderlineForGlyphRange:(NSRange)arg1 underlineType:(NSInteger)arg2 baselineOffset:(CGFloat)arg3 lineFragmentRect:(CGRect)arg4 lineFragmentGlyphRange:(NSRange)arg5 containerOrigin:(CGPoint)arg6;
- (void)drawBackgroundForGlyphRange:(NSRange)arg1 atPoint:(CGPoint)arg2;
- (NSUInteger)layoutOptions;
- (void)addTemporaryAttribute:(id)arg1 value:(id)arg2 forCharacterRange:(NSRange)arg3;
- (void)removeTemporaryAttribute:(id)arg1 forCharacterRange:(NSRange)arg2;
- (void)addTemporaryAttributes:(id)arg1 forCharacterRange:(NSRange)arg2;
- (void)setTemporaryAttributes:(id)arg1 forCharacterRange:(NSRange)arg2;
- (void)textContainerChangedGeometry:(id)arg1;
- (NSRange)_characterRangeCurrentlyInAndAfterContainer:(id)arg1;
- (void)_fillLayoutHoleAtIndex:(NSUInteger)arg1 desiredNumberOfLines:(NSUInteger)arg2;
- (id)init;

@end
