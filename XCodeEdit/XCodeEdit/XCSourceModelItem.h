/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

@interface XCSourceModelItem : NSObject
{
    NSRange _relativeLocation;
    unsigned int _colorId:15;
    unsigned int _isOpaque:1;
    unsigned int _dirty:1;
    unsigned int _isBlock:1;
    unsigned int _ignoreToken:1;
    unsigned int _inheritsColor:1;
    unsigned int _isIdentifier:1;
    unsigned int _isSimpleToken:1;
    unsigned int _isVolatile:1;
    unsigned int _needToDirtyRightEdges:1;
    NSInteger _langId;
    NSInteger _token;

    NSMutableArray *_children;
}

+ (id)sourceModelItemWithRange:(NSRange)arg1
                      language:(NSInteger)arg2
                         token:(NSInteger)arg3
                         color:(short)arg4;

- (void)clearIndexedColors;
- (NSInteger)compare:(id)arg1;
- (id)followingItem;
- (id)precedingItem;
- (id)_lastLeafItem;
- (id)_firstLeafItem;
- (id)nextItem;
- (id)previousItem;
- (BOOL)isAncestorOf:(id)arg1;
- (id)childAdjoiningLocation:(NSUInteger)arg1;
- (id)childEnclosingLocation:(NSUInteger)arg1;
- (id)_childEnclosingLocation:(NSUInteger)arg1;

- (NSUInteger)indexOfChildAtLocation:(NSUInteger)arg1;
- (NSUInteger)indexOfChildAfterLocation:(NSUInteger)arg1;
- (NSUInteger)indexOfChildBeforeLocation:(NSUInteger)arg1;

- (NSArray *)children;
- (NSUInteger)numberOfChildren;

- (void)addChildren: (NSArray *)arg1;
- (void)addChild: (id)arg1;
- (void)assignParents: (NSArray *)arg1;

@property (nonatomic, assign) XCSourceModelItem *parent;

- (BOOL)isVolatile;
- (void)setVolatile:(BOOL)arg1;
- (BOOL)needToDirtyRightEdges;
- (void)setNeedToDirtyRightEdges:(BOOL)arg1;
- (BOOL)isSimpleToken;
- (void)setIsSimpleToken:(BOOL)arg1;
- (BOOL)inheritsColor;
- (void)setInheritsColor:(BOOL)arg1;
- (BOOL)ignoreToken;
- (void)setIgnoreToken:(BOOL)arg1;
- (BOOL)dirty;
- (void)setDirty:(BOOL)arg1;
- (NSInteger)token;
- (void)setToken:(NSInteger)arg1;
- (NSInteger)langId;
- (BOOL)isIdentifier;
- (short)rawColorId;
- (BOOL)isOpaque;
- (void)setIsOpaque:(BOOL)arg1;
- (short)colorId;
- (void)setColorId:(short)arg1;
- (NSRange)innerRange;
- (void)offsetBy:(NSInteger)arg1;
- (void)setRange:(NSRange)arg1;
- (NSRange)range;
- (id)enclosingBlock;
- (NSInteger)blockDepth;
- (void)setIsBlock:(BOOL)arg1;
- (BOOL)isBlock;
- (void)dirtyRange:(NSRange)arg1 changeInLength:(NSInteger)arg2;
- (void)dirtyRelativeRange:(NSRange)arg1 changeInLength:(NSInteger)arg2;
- (void)validate;
- (id)dumpContext;
- (id)contextArray;
- (id)simpleDescription;
- (id)diffableDescription;
- (id)description;
- (id)innerDescription:(id)arg1 showSelf:(BOOL)arg2;
- (void)dealloc;
- (id)initWithRange:(NSRange)arg1 language:(NSInteger)arg2 token:(NSInteger)arg3 color:(short)arg4;

@end

