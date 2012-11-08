//
//  OakDocumentTracker.h
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-8.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OakDocumentTracker : NSObject


- (OakDocument *)initWithPath: (NSString *)path
                   identifier: (id)key;

- (OakDocument *)findDocumentByUUID: (NSUUID *)uuid
                      searchBackups: (BOOL)flag;

- (void)removeWithUUID: (NSUUID *)uuid
                   key: (id)key;

- (id)updatePathWithDocument: (OakDocument *)doc
                      oldKey: (id)oldKey
                      newKey: (id)newKey;


- (NSUInteger)untitledCounter;

@end
