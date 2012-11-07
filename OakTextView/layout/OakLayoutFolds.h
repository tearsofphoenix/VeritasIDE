//
//  OakLayoutFolds.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    kLineTypeRegular,
    kLineTypeEmpty,
    kLineTypeIgnoreLine,
    kLineTypeStartMarker,
    kLineTypeStopMarker,
    kLineTypeIndentStartMarker
};

typedef NSUInteger OakLayoutFoldsLineType;

struct _OakFoldInfo
{
    NSInteger indent;
    OakLayoutFoldsLineType type;
};

typedef struct _OakFoldInfo OakFoldInfo;

@interface OakLayoutFolds : NSObject
{
    
    NSString *_buffer;
    
    NSMutableDictionary *_levels;
    NSMutableArray *_folded;
    NSMutableDictionary *_legacy;
}

@property (nonatomic, retain) NSString *foldedAsString;

- (id)initWithContent: (NSString *)str;

- (BOOL)hasFolded;

- (BOOL)hasStartMarker: (NSUInteger)n;

- (BOOL)hasStopMarker: (NSUInteger)n;

- (NSDictionary *)folded;

- (void)foldFrom: (NSUInteger)from
              to: (NSUInteger)to;

- (NSArray *)removeEnclosingFrom: (NSUInteger)from
                              to: (NSUInteger)to;

- (NSRange)toggleAtLine: (NSUInteger)n
              recursive: (BOOL)recursive;

- (NSArray *)toggleAllAtLevel: (NSUInteger)level;

- (void)willReplaceFrom: (NSUInteger)from
                     to: (NSUInteger)to
             withString: (NSString *)str;

- (void)didParseFrom: (NSUInteger)from
                  to: (NSUInteger)to;

- (BOOL)integrity;

- (void)setFolded: (NSArray *)newFoldings;

- (NSArray *)foldableRanges;

- (NSRange)foldableRangeAtLine: (NSUInteger)line;

- (OakFoldInfo)infoForLine: (NSUInteger)line;

@end
