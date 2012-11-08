//
//  OakDocumentLRUTracker.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-8.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakDocumentLRUTracker.h"

@implementation OakDocumentLRUTracker


// ===============
// = LRU Tracker =
// ===============

static struct lru_tracker_t
{
    lru_tracker_t () : did_load(false) { }
    
    NSDate * get (NSString * path) const
    {
        if(path == NULL_STR)
            return NSDate *();
        
        load();
        std::map<NSString *, NSDate *>::const_iterator it = map.find(path);
        D(DBF_Document_LRU, bug("%s → %s\n", path.c_str(), it != map.end() ? to_s(it->second).c_str() : "not found"););
        return it == map.end() ? NSDate *() : it->second;
    }
    
    void set (NSString * path, NSDate * date)
    {
        if(path == NULL_STR)
            return;
        
        D(DBF_Document_LRU, bug("%s → %s\n", path.c_str(), to_s(date).c_str()););
        load();
        map[path] = date;
        save();
    }
    
private:
    void load () const
    {
        if(did_load)
            return;
        did_load = true;
        
        if(CFPropertyListRef cfPlist = CFPreferencesCopyAppValue(CFSTR("LRUDocumentPaths"), kCFPreferencesCurrentApplication))
        {
            NSMutableDictionary *  plist = plist::convert(cfPlist);
            D(DBF_Document_LRU, bug("%s\n", to_s(plist).c_str()););
            CFRelease(cfPlist);
            
            plist::array_t paths;
            if(plist::get_key_path(plist, "paths", paths))
            {
                NSDate * t = NSDate *::now();
                iterate(path, paths)
                {
                    if(NSString * str = boost::get<NSString *>(&*path))
                        map.insert(std::make_pair(*str, t - (1.0 + map.size())));
                }
            }
        }
    }
    
    void save () const
    {
        std::map<NSDate *, NSString *> sorted;
        iterate(item, map)
        sorted.insert(std::make_pair(item->second, item->first));
        
        std::map< NSString *, std::vector<NSString *> > plist;
        std::vector<NSString *>& paths = plist["paths"];
        riterate(item, sorted)
        {
            paths.push_back(item->second);
            if(paths.size() == 50)
                break;
        }
        
        D(DBF_Document_LRU, bug("%s\n", text::join(paths, ", ").c_str()););
        CFPreferencesSetAppValue(CFSTR("LRUDocumentPaths"), cf::wrap(plist), kCFPreferencesCurrentApplication);
    }
    
    mutable std::map<NSString *, NSDate *> map;
    mutable BOOL did_load;
    
} lru;

@end
