//
//  _OakMutableStructArray.h
//  OakFoundation
//
//  Created by LeixSnake on 11/9/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#ifndef __OakFoundation___OakMutableStructArray__
#define __OakFoundation___OakMutableStructArray__

#include <iostream>
#include <vector>
#include <Foundation/Foundation.h>

template <typename StructType, typename StructCompare>
class _OakMutableStructArray
{
    typedef StructType value_type;
    typedef StructType * value_ptr;
    
private:
    std::vector<StructType> *_values;
    StructCompare _compare;
    
public:
    
    ~_OakMutableStructArray(void)
    {
        delete _values;
    }
    
    _OakMutableStructArray(void)
    {
        _values = new std::vector<value_type>;
    }
    
    _OakMutableStructArray(const value_type *values, size_t count, StructCompare compare)
    {
        _values = new std::vector<value_type>(values, values + count);
        _compare = compare;
    }
    
    _OakMutableStructArray(size_t capacity, StructCompare compare)
    {
        _values = new std::vector<value_type>;
        _values->reserve(capacity);
        _compare = compare;
    }
    
    void normalize(void);
    
    void removeAllValues(void)
    {
        _values->clear();
    }
    
    void removeValueAtIndex(size_t idx)
    {
        _values->erase(_values->begin() + idx);
    }
    
    void insertValueAtIndex(const value_type& value, size_t idx)
    {
        _values->insert(_values->begin() + idx, value);
    }
    
    void addValue(const value_type& value)
    {
        _values->push_back(value);
    }
    
    value_type lastValue(void)
    {
        return _values->back();
    }
    
    value_type firstValue(void)
    {
        return _values->front();
    }
    
    size_t indexOfValue(const value_type& value)
    {
        size_t count = _values->size();
        for (size_t iLooper = 0; iLooper < count; ++iLooper)
        {
            if (_compare((*_values)[iLooper], value) == NSOrderedSame)
            {
                return iLooper;
            }
        }
        
        return NSNotFound;
    }
    
    const value_type& valueAtIndex(size_t idx)
    {
        
        return (*_values)[idx];
    }
    
    void replaceValueAtIndexWithValue(size_t idx, const value_type& value)
    {
        (*_values)[idx] = value;
    }
        
    void removeLastValue(void)
    {
        _values->pop_back();
    }
    
    size_t count(void) const
    {
        return _values->size();
    }
    
    void setArray(const _OakMutableStructArray & otherArray)
    {
        auto otherValues = otherArray._values;
        _values->assign(otherValues->begin(), otherValues->end());
    }
    
    bool operator== (const _OakMutableStructArray & otherArray) const
    {
        auto otherValues = otherArray._values;
        size_t count = _values->size();
        if(otherValues->size() == count)
        {
            for(size_t iLooper = 0; iLooper < count; ++iLooper)
            {
                if(_compare((*_values)[iLooper], (*otherValues)[iLooper]) != NSOrderedSame)
                {
                    return false;
                }
            }
            
            return true;
        }
        
        return false;
    }
    
    const value_ptr data(size_t outCount = NULL)
    {
        size_t count = _values->size();

        if (count > 0)
        {
            value_ptr returnValue = (value_ptr)malloc(sizeof(value_type) * count);

            for (size_t iLooper = 0; iLooper < count; ++iLooper)
            {
                returnValue[iLooper] = (*_values)[iLooper];
            }
            
            return returnValue;
        }
        
        return NULL;
    }
};


#endif /* defined(__OakFoundation___OakMutableStructArray__) */
