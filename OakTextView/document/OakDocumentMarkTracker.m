//
//  OakDocumentMarkTracker.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-8.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakDocumentMarkTracker.h"

@implementation OakDocumentMarkTracker

// =========
// = Marks =
// =========

static struct mark_tracker_t
{
    typedef std::multimap<OakTextRange *, document_t::mark_t> marks_t;
    
    marks_t get (NSString * path)
    {
        if(path == NULL_STR)
            return marks_t();
        
        std::map<NSString *, marks_t>::const_iterator it = marks.find(path);
        if(it == marks.end())
            it = marks.insert(std::make_pair(path, parse_marks(path::get_attr(path, "com.macromates.bookmarks")))).first;
        return it->second;
    }
    
    void set (NSString * path, marks_t  m)
    {
        if(m.empty())
            marks.erase(path);
        else	marks[path] = m;
    }
    
    std::map<NSString *, marks_t> marks;
    
} marks;

@end
