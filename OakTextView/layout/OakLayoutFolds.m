//
//  OakLayoutFolds.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakLayoutFolds.h"

#import <OakFoundation/OakFoundation.h>

@implementation OakLayoutFolds

- (id)initWithContent: (NSString *)str
{
    
}

- (void)dealloc
{
    
    [super dealloc];
}

- (BOOL)hasFoldedLine: (NSUInteger)line
{
    NSUInteger bol = [_buffer locationOfLineStart: line];
    NSUInteger eol = [_buffer locationOfLineEnd: line];
    
    for (NSValue *iLooper in _folded)
    {
        NSRange range = [iLooper rangeValue];
        
        if((range.location <= bol && bol <= range.length)
           || (range.location <= eol && eol <= range.length))
        {
            return YES;
        }        
    }
    
    return NO;
}

- (BOOL)hasStartMarkerForLine: (NSUInteger)line
{
    OakLayoutFoldsLineType type = [self infoForLine: line].type;

    return type == kLineTypeStartMarker || type == kLineTypeIndentStartMarker;
}

- (BOOL)hasStopMarkerForLine: (NSUInteger)line
{
    return [self infoForLine: line].type == kLineTypeStopMarker;
}

- (NSDictionary *)folded
{
    return _legacy;
}

- (void)foldFrom: (NSUInteger)from
              to: (NSUInteger)to
{
    NSMutableArray *newFoldings = [NSMutableArray arrayWithArray: _folded];

    [newFoldings addObject: [NSValue valueWithRange: NSMakeRange(from, to)]];

    [self setFolded: newFoldings];

}

- (NSArray *)removeEnclosingFrom: (NSUInteger)from
                              to: (NSUInteger)to
{
    NSMutableArray *newFoldings = [NSMutableArray array];
    NSMutableArray *res = [NSMutableArray array];
    
    for(NSValue *pair in _folded)
    {
        NSRange range = [pair rangeValue];
        
        if((range.location <= from && from < range.length)
           || (range.location < to && to <= range.length))
        {
            [res addObject: pair];
        }else
        {
            [newFoldings addObject: pair];
        }
    }
    
    [self setFolded: newFoldings];

    return res;
}

- (NSRange)toggleAtLine: (NSUInteger)n
              recursive: (BOOL)recursive
{
    NSRange res = NSMakeRange(0, 0);
    
    if([self hasFoldedLine: n])
    {
        NSUInteger bol = [_buffer locationOfLineStart: n];
        NSUInteger eol = [_buffer locationOfLineEnd: n];
        
        NSMutableArray *newFoldings = [NSMutableArray  array];
        
        for(NSValue *pair in _folded)
        {
            NSRange range = [pair rangeValue];
            
            if(OakCap(range.location, bol, range.length) == bol
               || OakCap(range.location, eol, range.length) == eol)
            {
                if(res.location == res.location)
                {
                    res = range;
                }
                
            }else if(!recursive || !(res.location <= range.location
                                     && range.length <= res.length))
            {
                [newFoldings addObject: pair];
            }
        }
        
        [self setFolded: newFoldings];

    }else
    {
        res = [self foldableRangeAtLine: n];

        if(res.location < res.length)
        {
            if(recursive)
            {
                for(NSValue *pair in [self foldableRanges])
                {
                    NSRange range = [pair rangeValue];
                    
                    if(res.location <= range.location && range.length <= res.length)
                    {
                        [self foldFrom: range.location
                                    to: range.length];
                    }
                }
                
            }else
            {
                [self foldFrom: res.location
                            to: res.length];
            }
        }
    }
    
    return res;

}

- (NSArray *)toggleAllAtLevel: (NSUInteger)level
{
    NSMutableArray * folded = [NSMutableArray arrayWithArray: _folded];
    
    NSMutableArray * unfolded = [NSMutableArray array];

    NSMutableArray * nestingStack = [NSMutableArray array];
    
    for(NSValue *pair in [self foldableRanges])
    {
        while([nestingStack count] > 0
              && [[nestingStack lastObject] rangeValue].length <= [pair rangeValue].location)
        {
            [nestingStack removeLastObject];
        }
        
        [nestingStack addObject: pair];
        
        if(level == 0 || level == [nestingStack count])
        {
            [unfolded addObject: pair];
        }
    }
    
    NSArray *canFoldAtLevel = [unfolded differenceArrayWithArray: folded];
    NSArray *foldedAtLevel = [unfolded intersectArrayWithArray: folded];
    
    if([canFoldAtLevel count] >= [foldedAtLevel count])
    {
        for(NSValue *pair in canFoldAtLevel)
        {
            NSRange range = [pair rangeValue];
            
            [self foldFrom: range.location
                        to: range.length];

        }
        
        return canFoldAtLevel;
    }
    
    NSArray *newFoldings = [folded differenceArrayWithArray: foldedAtLevel];

    [self setFolded: newFoldings];

    return foldedAtLevel;
}

- (void)willReplaceFrom: (NSUInteger)from
                     to: (NSUInteger)to
             withString: (NSString *)str
{
    NSMutableArray *newFoldings = [NSMutableArray array];
    NSUInteger delta = [str length] - (to - from);
    
    for(NSValue *pair in _folded)
    {
        NSRange range = [pair rangeValue];
        
        NSInteger foldFrom = range.location;
        NSInteger foldTo = range.length;
        
        if(to <= foldFrom)
        {
            [newFoldings addObject: [NSValue valueWithRange: NSMakeRange(foldFrom + delta, foldTo + delta)]];
            
        }else if(foldFrom <= from && to <= foldTo && delta != foldFrom - foldTo)
        {
            [newFoldings addObject: [NSValue valueWithRange: NSMakeRange(foldFrom, foldTo + delta)]];
            
        }else if(foldTo <= from)
        {
            [newFoldings addObject: [NSValue valueWithRange: NSMakeRange(foldFrom, foldTo)]];
        }
    }
    
    [self setFolded: newFoldings];
    
    NSUInteger bol = [_buffer locationOfLineStart:  _buffer.convert(from).line];
    
    NSUInteger end = [_buffer locationOfLineStart: _buffer.convert(to).line];
    
    auto first = _levels.lower_bound(bol, &key_comp);
    auto last  = _levels.upper_bound(end, &key_comp);
    if(last != _levels.end())
    {
        ssize_t eraseFrom = first->offset;
        ssize_t eraseTo   = last->offset;
        ssize_t diff = (eraseTo - eraseFrom) + str.size() - (to - from);
        last->key += diff;
        _levels.update_key(last);
    }
    
    _levels.erase(first, last);
}

- (void)didParseFrom: (NSUInteger)from
                  to: (NSUInteger)to
{
    NSUInteger bol = _buffer.begin(_buffer.convert(from).line);
    NSUInteger end = _buffer.begin(_buffer.convert(to).line);
    auto first = _levels.lower_bound(bol, &key_comp);
    auto last  = _levels.upper_bound(end, &key_comp);
    if(last != _levels.end())
    {
        last->key += last->offset - first->offset;
        _levels.update_key(last);
    }
    _levels.erase(first, last);

}

- (BOOL)integrity
{
    iterate(info, _levels)
    {
        NSUInteger pos = info->offset + info->key;
        if(_buffer.size() < pos || _buffer.convert(pos).column != 0)
        {
            NSUInteger n = _buffer.convert(pos).line;
            fprintf(stderr, "%zu) pos: %zu, line %zu-%zu\n", n+1, pos, _buffer.begin(n), _buffer.eol(n));
            return false;
        }
    }
    return true;
}
//    struct value_t
//    {
//        int indent;
//        line_type_t type;
//    };

static int key_comp (NSUInteger key, NSUInteger offset, NSUInteger node)
{
    return key < offset + node ? -1 : (key == offset + node ? 0 : +1);
}

- (void)setFolded: (NSArray *)newFoldings
{
    if(_folded != newFoldings)
    {
        [_folded setArray: newFoldings];
        
        NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
        
        for(NSValue *value in _folded)
        {
            //++tmp[pair->first];
            //--tmp[pair->second];
        }
    
    [_legacy removeAllObjects];
        
    NSInteger level = 0;
    iterate(pair, tmp)
    {
        if(pair->second == 0)
            continue;
        
        if(level == 0 && pair->second > 0)
            _legacy.set(pair->first, true);
        level += pair->second;
        if(level == 0)
            _legacy.set(pair->first, false);
    }
    }
}

- (NSArray *)foldableRanges
{
    NSMutableArray *res = [NSMutableArray array];
    
    NSMutableArray *regularStack = [NSMutableArray array];
    NSMutableArray *indentStack = [NSMutableArray array];
    
    for(NSUInteger n = 0; n < [_buffer numberOfLines]; ++n)
    {
        OakFoldInfo info = [self infoForLine: n];
        
        while([indentStack count] > 0
              && info.type != kLineTypeEmpty
              && info.type != kLineTypeIgnoreLine
              && info.indent <= [[indentStack lastObject] rangeValue].length)
        {
            NSValue *last = [indentStack lastObject];
            
            if([last rangeValue].location < [_buffer locationOfLineEnd: n - 1])
            {
                [res addObject: [NSValue valueWithRange: NSMakeRange([last rangeValue].location, [_buffer locationOfLineEnd: n - 1])]];
            }
            
            [indentStack removeLastObject];
        }
        
        switch(info.type)
        {
            case kLineTypeStartMarker:
            {
                [regularStack addObject: [NSValue valueWithRange: NSMakeRange([_buffer locationOfLineEnd: n], info.indent)]];
                
                break;
            }
                
            case kLineTypeIndentStartMarker:
            {
                [indentStack addObject: [NSValue valueWithRange: NSMakeRange([_buffer locationOfLineEnd: n], info.indent)]];
                break;
            }
                
            case kLineTypeStopMarker:
            {
                for(NSUInteger i = [regularStack count]; i > 0; --i)
                {
                    NSValue *iLooper = [regularStack objectAtIndex: i - 1];
                    
                    if([iLooper rangeValue].length == info.indent)
                    {
                        NSUInteger last = [_buffer locationOfLineStart: n];
                        
                        while(last < [_buffer length]
                              && ([_buffer charAtIndex: last] == '\t'
                                  || [_buffer charAtIndex: last] == ' '))
                        {
                            ++last;
                        }
                        
                        NSValue *value = [regularStack objectAtIndex: i - 1];
                        [res addObject: [NSValu valueWithRange: NSMakeRange([value rangeValue].location, last)]];
                        
                        [regularStack resizeToCount: i - 1];
                        
                        break;
                    }
                }
            }
				break;
        }
    }
    
    for(NSUInteger i = [indentStack count]; i > 0; --i)
    {
        NSRange range = [[indentStack objectAtIndex: i - 1] rangeValue];
        
        [res addObject: [NSValue valueWithRange: NSMakeRange(range.location, [_buffer length])]];
    }
    
    
//    std::sort(res.begin(), res.end());
    
    NSMutableArray *nestingStack = [NSMutableArray  array];
    NSMutableArray *unique = [NSMutableArray array];
    
    for(NSValue *pair in res)
    {
        while([nestingStack count] > 0
              && [[nestingStack lastObject] rangeValue].length <= [pair rangeValue].location)
        {
            [nestingStack removeLastObject];
        }
        
        if([nestingStack count] > 0
           && [[nestingStack lastObject] rangeValue].length < [pair rangeValue].length)
        {
            continue;
        }
        
        [nestingStack addObject: pair];
        
        [unique addObject: pair];
    }
    
    return unique;
}

- (NSRange)foldableRangeAtLine: (NSUInteger)line
{
    NSRange res = NSMakeRange(0, 0);
    
    NSUInteger bol = [_buffer locationOfLineStart: n],
    NSUInteger eol = [_buffer locationOfLineEnd: n];
    
    for(NSValue *pair in [self foldableRanges])
    {
        NSRange range = [pair rangeValue];
        
        if(OakCap(range.location, bol, range.length) == bol
           || OakCap(range.location, eol, range.length) == eol)
        {
            res = range;
        }
    }
    
    return res;
}

- (OakFoldInfo)infoForLine: (NSUInteger)line
{
    NSUInteger bol = [_buffer locationOfLineStart: n];
    
    auto it = _levels.lower_bound(bol, &key_comp);
    
    if(it == _levels.end() || it->offset + it->key != bol)
    {
        if(it != _levels.end())
        {
            bol -= it->offset;
            it->key -= bol;
            _levels.update_key(it);
        }
        else if(it != _levels.begin())
        {
            auto tmp = it;
            --tmp;
            bol -= tmp->offset + tmp->key;
        }
        
        regexp::pattern_t startPattern, stopPattern, indentPattern, ignorePattern;
        setup_patterns(_buffer, n, startPattern, stopPattern, indentPattern, ignorePattern);
        
        NSString * line = _buffer.substr(_buffer.begin(n), _buffer.eol(n));
        NSUInteger res = text::is_blank(line.data(), line.data() + line.size())          ?  1 : 0;
        res += regexp::search(startPattern,  line.data(), line.data() + line.size()) ?  2 : 0;
        res += regexp::search(stopPattern,   line.data(), line.data() + line.size()) ?  4 : 0;
        res += regexp::search(indentPattern, line.data(), line.data() + line.size()) ?  8 : 0;
        res += regexp::search(ignorePattern, line.data(), line.data() + line.size()) ? 16 : 0;
        
        if(res & 6) // if start/stop marker we ignore indent patterns
            res &= ~24;
        
        auto type  = (res & 1) ? kLineTypeEmpty : kLineTypeRegular;
        switch(res)
        {
            case  2: type = kLineTypeStartMarker;       break;
            case  4: type = kLineTypeStopMarker;        break;
            case  8: type = kLineTypeIndentStartMarker; break;
            case 16: type = kLineTypeIgnoreLine;        break;
        }
        
        int indent = indent::leading_whitespace(line.data(), line.data() + line.size(), _buffer.indent().tab_size());
        it = _levels.insert(it, bol, value_t(indent, type));
    }
    return it->value;
}

- (NSString *)foldedAsString
{
    NSMutableArray *v = [NSMutableArray arrayWithCapacity: [_folded count]];
    
    for(NSValue *iLooper in _folded)
    {
        NSRange range = [iLooper rangeValue];
        [v addObject: NSStringFromRange(range)];
    }
    
    return [NSString stringWithFormat: @"(%@)", [v componentsJoinedByString: @","]];
}

- (void)setFoldedAsString: (NSString *)foldedAsString
{
    foldedAsString = [foldedAsString substringWithRange: NSMakeRange(1, [foldedAsString length] - 2)];
    NSArray *rangeStrings = [foldedAsString componentsSeparatedByString: @","];
    
    if ([rangeStrings count] > 0)
    {
        NSMutableArray * newFoldings = [NSMutableArray arrayWithCapacity: [rangeStrings count]];
        for(NSString *iLooper in rangeStrings)
        {
            NSRange range = NSRangeFromString(iLooper);
            
            [newFoldings addObject: [NSValue valueWithRange: range]];
        }
        
        [self setFolded: newFoldings];
    }
}



static void setup_patterns (NSString *  buffer,
                            NSUInteger line,
                            NSRegularExpression * startPattern,
                            NSRegularExpression * stopPattern,
                            NSRegularExpression * indentPattern,
                            NSRegularExpression * ignorePattern)
{
    id ptrn;
    
    OakBundleItem * didFindPatterns;
    OakScopeContext * scope(buffer.scope(buffer.begin(line), false).right, buffer.scope(buffer.end(line), false).left);
    ptrn = bundles::value_for_setting("foldingStartMarker", scope, &didFindPatterns);
    if(NSString * str = boost::get<NSString *>(&ptrn))
        startPattern = *str;
    
    ptrn = bundles::value_for_setting("foldingStopMarker", scope);
    if(NSString * str = boost::get<NSString *>(&ptrn))
        stopPattern = *str;
    
    ptrn = bundles::value_for_setting("foldingIndentedBlockStart", scope);
    if(NSString * str = boost::get<NSString *>(&ptrn))
        indentPattern = *str;
    
    ptrn = bundles::value_for_setting("foldingIndentedBlockIgnore", scope);
    if(NSString * str = boost::get<NSString *>(&ptrn))
        ignorePattern = *str;
    
    if(!didFindPatterns) // legacy — this has bad performance
    {
        citerate(item, bundles::query(bundles::kFieldGrammarScope, to_s(buffer.scope(0, false).left), scope::wildcard, bundles::kItemTypeGrammar))
        {
            foldingStopMarker = NULL_STR;
            NSString * foldingStartMarker = [[item plist] objectForKeyPath: @"foldingStartMarker"];
            
            plist::get_key_path((*item)->plist(), "foldingStopMarker", foldingStopMarker);
            startPattern = foldingStartMarker;
            stopPattern  = foldingStopMarker;
        }
    }
}

@end
