/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import "NSObject.h"

@class NSMutableData;

@interface PBXRecordVector : NSObject
{
    struct {
        unsigned int _field1;
        unsigned int _field2;
        unsigned int _field3;
        unsigned int _field4;
    } *_header;
    NSMutableData *_store;
    NSUInteger _cursor;
    void *_records;
    NSUInteger _tag;
    dispatch_queue_t _vectorAccessQueue;
}

- (void)replaceRecordsAtRow:(NSUInteger)arg1 withVector:(id)arg2;
- (void)appendVector:(id)arg1;
- (void)setCursor:(NSUInteger)arg1;
- (NSUInteger)cursor;
- (NSUInteger)insertRecords:(const void *)arg1 count:(NSUInteger)arg2 atRow:(NSUInteger)arg3;
- (NSUInteger)appendRecords:(const void *)arg1 count:(NSUInteger)arg2;
- (NSUInteger)appendRecord:(const void *)arg1;
- (BOOL)setCurrentRecord:(const void *)arg1;
- (BOOL)getCurrentRecord:(void *)arg1;
- (BOOL)getPreviousRecord:(void *)arg1;
- (BOOL)getNextRecord:(void *)arg1;
- (void)setTag:(NSUInteger)arg1;
- (NSUInteger)getTag;
- (BOOL)writeDataToFile:(id)arg1 queue:(dispatch_queue_t )arg2;
- (NSUInteger)count;
- (void *)records;
- (BOOL)setRecord:(const void *)arg1 atRow:(NSUInteger)arg2;
- (BOOL)getRecord:(void *)arg1 atRow:(NSUInteger)arg2;
- (void *)currentRecord;
- (void *)lastRecord;
- (void *)firstRecord;
- (NSUInteger)rowForRecord:(void *)arg1;
- (void *)recordAtRow:(NSUInteger)arg1;
- (void)dealloc;
- (id)initWithContentsOfFile:(id)arg1 accessQueue:(dispatch_queue_t )arg2;
- (id)initRecordSize:(NSUInteger)arg1 capacity:(NSUInteger)arg2 accessQueue:(dispatch_queue_t )arg3;
- (BOOL)getTopRecord:(void *)arg1;
- (BOOL)popRecord:(void *)arg1;
- (NSUInteger)pushRecord:(const void *)arg1;

@end
