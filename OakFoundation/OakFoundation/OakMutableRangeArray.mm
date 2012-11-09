//
//  OakMutableRangeArray.m
//  OakFoundation
//
//  Created by LeixSnake on 11/9/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import "OakMutableRangeArray.h"
#import "OakRangeArray.h"
#import "_OakMutableStructArray.hpp"
#import <objc/runtime.h>

typedef NSComparisonResult (^ NSRangeCompare)(const NSRange &, const NSRange &);

@interface OakMutableRangeArray()
{
    _OakMutableStructArray<NSRange, NSRangeCompare> *_priv;
}
@end

@implementation OakMutableRangeArray

static Class s_OakRangeArrayStringClass = nil;
static Class s_OakRangeArrayValueClass = nil;
static NSRange s_OakRangeArrayInvalidRange;
static NSRangeCompare s_OakRangeCompare = nil;

typedef BOOL(* OakIsKindOfClassIMP)(id obj, SEL sel, Class theClass);
static OakIsKindOfClassIMP imp_isKindOfClass = NULL;

static NSRange f_OakRangeFromObject(id obj)
{
    if (imp_isKindOfClass(obj, @selector(isKindOfClass:), s_OakRangeArrayValueClass))
    {
        return [obj rangeValue];
        
    }else if (imp_isKindOfClass(obj, @selector(isKindOfClass:), s_OakRangeArrayStringClass))
    {
        return NSRangeFromString(obj);
    }
    
    return s_OakRangeArrayInvalidRange;
}

+ (void)initialize
{
    imp_isKindOfClass = (OakIsKindOfClassIMP)class_getMethodImplementation([NSObject class], @selector(isKindOfClass:));
    
    s_OakRangeCompare = (^(const NSRange& r1, const NSRange & r2)
                         {
                             if (r1.location < r2.location)
                             {
                                 return (NSComparisonResult)NSOrderedAscending;
                                 
                             }else if(r1.location == r2.location)
                             {
                                 if (r1.length < r2.length)
                                 {
                                     return (NSComparisonResult)NSOrderedAscending;
                                     
                                 }else if(r1.length == r2.length)
                                 {
                                     return (NSComparisonResult)NSOrderedSame;
                                     
                                 }else
                                 {
                                     return (NSComparisonResult)NSOrderedDescending;
                                 }
                             }else
                             {
                                 return (NSComparisonResult)NSOrderedDescending;
                             }
                         });
    
    s_OakRangeCompare = Block_copy(s_OakRangeCompare);
    
    s_OakRangeArrayStringClass = [NSString class];
    s_OakRangeArrayValueClass = [NSValue class];
    s_OakRangeArrayInvalidRange = NSMakeRange(NSNotFound, NSNotFound);
}

- (void)normalize
{
    
}

- (void)removeAllRanges
{
    _priv->removeAllValues();
}

- (void)removeRangesAtIndexes: (NSIndexSet *)indexes
{
    [indexes enumerateIndexesUsingBlock: (^(NSUInteger idx, BOOL *stop)
                                          {
                                              _priv->removeValueAtIndex(idx);
                                          })];
}

- (void)removeRangeAtIndex: (NSUInteger)arg1
{
    _priv->removeValueAtIndex(arg1);
}

- (void)insertRange: (NSRange)arg1
            atIndex: (NSUInteger)arg2
{
    _priv->insertValueAtIndex(arg1, arg2);
}

- (void)addRange:(NSRange)arg1
{
    _priv->addValue(arg1);
}

- (void)setRange: (NSRange)value
         atIndex: (NSUInteger)idx
{
    _priv->replaceValueAtIndexWithValue(idx, value);
}

#define M_OakRangeArray(op)    {    for (NSUInteger iLooper = 0; iLooper < _priv->count(); ++iLooper)\
                                    {\
                                        NSRange rangeLooper = _priv->valueAtIndex(iLooper);\
                                        if (rangeLooper.location + rangeLooper.length op arg1)\
                                        {\
                                            return iLooper;\
                                        }\
                                    }\
                                    return NSNotFound;\
                                }

- (NSUInteger)indexOfRangeContainingOrFollowing:(NSUInteger)arg1
{
    M_OakRangeArray(>=);
}

- (NSUInteger)indexOfRangeContainingOrPreceding:(NSUInteger)arg1
{
    M_OakRangeArray(<=);
}

- (NSUInteger)indexOfRangeFollowing:(NSUInteger)arg1
{
    M_OakRangeArray(>);
}

- (NSUInteger)indexOfRangePreceding:(NSUInteger)arg1
{
    M_OakRangeArray(<);
}

- (NSRange)lastRange
{
    if (_priv->count() > 0)
    {
        return _priv->lastValue();
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: @"Index: 0 out of range: [0...0]"
                                     userInfo: nil];
    }
}

- (NSRange)firstRange
{
    if (_priv->count() > 0)
    {
        return _priv->firstValue();
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: @"Index: 0 out of range: [0...0]"
                                     userInfo: nil];
    }
}

- (NSUInteger)indexOfRange:(NSRange)arg1
{
    return _priv->indexOfValue(arg1);
}

- (NSRange)rangeAtIndex: (NSUInteger)idx
{
    if (idx < _priv->count())
    {
        return _priv->valueAtIndex(idx);
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat: @"Index: %ld out of range: [0...%ld]", idx, _priv->count()]
                                     userInfo: nil];
    }
}

- (void)replaceObjectAtIndex: (NSUInteger)idx
                  withObject: (id)obj
{
    if (idx < _priv->count())
    {
        _priv->replaceValueAtIndexWithValue(idx, f_OakRangeFromObject(obj));
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat: @"Index: %ld out of range: [0...%ld]", idx, _priv->count()]
                                     userInfo: nil];
    }
}

- (void)removeObjectAtIndex: (NSUInteger)idx
{
    if (idx < _priv->count())
    {
        _priv->removeValueAtIndex(idx);
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat: @"Index: %ld out of range: [0...%ld]", idx, _priv->count()]
                                     userInfo: nil];

    }
}

- (void)removeLastObject
{
    if (_priv->count() > 0)
    {
        _priv->removeLastValue();
    }
}

- (void)insertObject: (id)obj
             atIndex: (NSUInteger)idx
{
    if (idx < _priv->count())
    {
        _priv->insertValueAtIndex(f_OakRangeFromObject(obj), idx);
        
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat: @"Index: %ld out of range: [0...%ld]", idx, _priv->count()]
                                     userInfo: nil];
    }
}

- (void)addObject: (id)obj
{
    _priv->addValue(f_OakRangeFromObject(obj));
}

- (id)objectAtIndex: (NSUInteger)idx
{
    if (idx < _priv->count())
    {
        return [NSValue valueWithRange: _priv->valueAtIndex(idx)];
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat: @"Index: %ld out of range: [0...%ld]", idx, _priv->count()]
                                     userInfo: nil];
    }
}

- (NSUInteger)count
{
    return _priv->count();
}

- (id)descriptionWithLocale: (id)locale
{
    NSMutableString *des = [NSMutableString stringWithString: @"("];
    
    for (NSUInteger iLooper = 0; iLooper < _priv->count(); ++iLooper)
    {
        [des appendFormat: @"\n%@,", NSStringFromRange(_priv->valueAtIndex(iLooper))];
    }
    
    [des appendString: @"\n)"];
    
    return des;
}

- (id)mutableCopyWithZone: (NSZone *)zone
{
    OakMutableRangeArray *mutableCopy = [[[self class] allocWithZone: zone] init];
    mutableCopy->_priv->setArray(*_priv);
    
    return mutableCopy;
}

- (id)copyWithZone: (NSZone *)zone
{
    const NSRange *data = _priv->data();
    OakRangeArray *copy = [[OakRangeArray allocWithZone: zone] initWithRanges: data
                                                                        count: _priv->count()];
    
    free((void *)data);
    
    return copy;
}

- (BOOL)isEqualToArray:(id)arg1
{
    if (arg1)
    {
        if([arg1 isKindOfClass: [self class]])
        {
            OakMutableRangeArray *value = arg1;
            return _priv->operator==(*(value->_priv));
            
        }else if([arg1 isKindOfClass: [OakRangeArray class]])
        {
            const void *data = _priv->data();
            BOOL result = memcmp(data, [(OakRangeArray *)arg1 rangeData], sizeof(NSRange) * _priv->count()) == 0;
            free((void *)data);
            
            return result;            
        }

        return NO;
    }
    
    return NO;
}

- (NSUInteger)hash
{
    return _priv->count();
}

- (void)dealloc
{
    if (_priv)
    {
        delete _priv;
    }
    
    [super dealloc];
}

- (id)init
{
    return [self initWithRanges: NULL
                          count: 0];
}

- (id)initWithRanges: (const NSRange *)arg1
               count: (NSUInteger)arg2
{
    if ((self = [super init]))
    {
        _priv = new _OakMutableStructArray<NSRange, NSRangeCompare>(arg1, arg2, s_OakRangeCompare);
    }
    
    return self;
}

- (id)initWithObjects: (id *)arg1
                count: (NSUInteger)arg2
{
    if ((self = [super init]))
    {
        _priv = new _OakMutableStructArray<NSRange, NSRangeCompare>(arg2, s_OakRangeCompare);
        
        for (NSUInteger iLooper = 0; iLooper < arg2; ++iLooper)
        {
            _priv->addValue(f_OakRangeFromObject( arg1[iLooper] ));
        }
    }
    
    return self;
    
}

- (id)initWithCapacity:(NSUInteger)arg1
{
    if ((self = [super init]))
    {
        _priv = new _OakMutableStructArray<NSRange, NSRangeCompare>(arg1, s_OakRangeCompare);
    }
    
    return self;
}

- (const NSRange *)rangeData
{
    return _priv->data();
}

@end
