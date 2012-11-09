//
//  OakMutableRectArray.m
//  OakFoundation
//
//  Created by LeixSnake on 11/9/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import "OakMutableRectArray.h"
#import "OakRectArray.h"
#import "_OakMutableStructArray.hpp"

#define M_OakRectFromObject(obj) ([obj isKindOfClass: [NSString class]] ? NSRectFromString(obj) : ([obj isKindOfClass: [NSValue class]] ? [obj rectValue] : NSZeroRect))

typedef BOOL (* OakRectCompare)(const NSRect& rect1, const NSRect& rect2);

@interface OakMutableRectArray ()
{
@private
    _OakMutableStructArray<NSRect, OakRectCompare> *_priv;
}
@end

@implementation OakMutableRectArray

- (void)removeAllRects
{
    _priv->removeAllValues();
}

- (void)removeRectsAtIndexes: (NSIndexSet *)indexes
{
    [indexes enumerateIndexesUsingBlock: (^(NSUInteger idx, BOOL *stop)
                                          {
                                              _priv->removeValueAtIndex(idx);
                                          })];
}

- (void)removeRectAtIndex:(NSUInteger)idx
{
    if(idx < _priv->count())
    {
        _priv->removeValueAtIndex(idx);
        
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat: @"Index: %ld out of range: [0...%ld]", idx, _priv->count()]
                                     userInfo: nil];
    }
        
}

- (void)insertRect: (NSRect)rect
           atIndex: (NSUInteger)idx
{
    if (idx < _priv->count())
    {
        _priv->insertValueAtIndex(rect, idx);
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat: @"Index: %ld out of range: [0...%ld]", idx, _priv->count()]
                                     userInfo: nil];
    }
}

- (void)addRect:(NSRect)rect
{
    _priv->addValue(rect);
}

- (void)setRect: (NSRect)rect
        atIndex: (NSUInteger)idx
{
    _priv->replaceValueAtIndexWithValue(idx, rect);
}

- (NSRect)lastRect
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

- (NSRect)firstRect
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

- (NSUInteger)indexOfRect:(NSRect)rect
{
    return _priv->indexOfValue(rect);
}

- (NSRect)rectAtIndex: (NSUInteger)idx
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
        _priv->replaceValueAtIndexWithValue(idx, M_OakRectFromObject(obj));
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
        _priv->insertValueAtIndex(M_OakRectFromObject(obj), idx);
        
    }else
    {
        @throw [NSException exceptionWithName: NSRangeException
                                       reason: [NSString stringWithFormat: @"Index: %ld out of range: [0...%ld]", idx, _priv->count()]
                                     userInfo: nil];
    }
}

- (void)addObject: (id)obj
{
    _priv->addValue(M_OakRectFromObject(obj));
}

- (id)objectAtIndex: (NSUInteger)idx
{
    if (idx < _priv->count())
    {
        return [NSValue valueWithRect: _priv->valueAtIndex(idx)];
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
        [des appendFormat: @"\n%@,", NSStringFromRect(_priv->valueAtIndex(iLooper))];
    }
    
    [des appendString: @"\n)"];
    
    return des;
}

- (id)mutableCopyWithZone: (NSZone *)zone
{
    OakMutableRectArray *mutableCopy = [[[self class] allocWithZone: zone] init];
    mutableCopy->_priv->setArray(*_priv);
    
    return mutableCopy;
}

- (id)copyWithZone: (NSZone *)zone
{
    const NSRect *data = _priv->data();
    OakRectArray *copy = [[OakRectArray allocWithZone: zone] initWithRects: data
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
            OakMutableRectArray *value = arg1;
            return _priv->operator==(*(value->_priv));
            
        }else if ([arg1 isKindOfClass: [OakRectArray class]])
        {
            const NSRect *data = _priv->data();

            BOOL result = memcmp(data, [arg1 rectData], sizeof(NSRect) * _priv->count()) == 0;

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


- (id)initWithRects:(const NSRect *)rects
              count:(NSUInteger)count
{
    if ((self = [super init]))
    {
        if (rects)
        {
            _priv = new _OakMutableStructArray<NSRect, OakRectCompare>(rects, count, (OakRectCompare)NSEqualRects);
            
        }else
        {
            _priv = NULL;
        }
    }
    
    return self;
}

- (id)initWithObjects: (id *)objects
                count: (NSUInteger)count
{
    if ((self = [super init]))
    {
        if (objects)
        {
            _priv = new _OakMutableStructArray<NSRect, OakRectCompare>(count, (OakRectCompare)NSEqualRects);
            for (NSUInteger iLooper = 0; iLooper < count; ++iLooper)
            {
                id obj = objects[iLooper];
                _priv->addValue([obj isKindOfClass: [NSString class]]
                                 ? NSRectFromString(obj)
                                 : ([obj isKindOfClass: [NSValue class]]
                                    ? [obj rectValue]
                                    : NSZeroRect)
                                );
            }
            
        }else
        {
            _priv = NULL;
        }
    }
    
    return self;
}

- (id)initWithCapacity: (NSUInteger)cap
{
    if ((self = [super init]))
    {
        _priv = new _OakMutableStructArray<NSRect, OakRectCompare>(cap, (OakRectCompare)NSEqualRects);
    }
    
    return self;
}

- (const void *)rectData
{
    return _priv->data();
}

@end
