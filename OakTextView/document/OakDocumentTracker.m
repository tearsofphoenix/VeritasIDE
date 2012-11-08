//
//  OakDocumentTracker.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-8.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakDocumentTracker.h"
#import "OakDocument.h"

@interface OakDocumentTracker ()
{
    NSInteger _lockCount;
    
}

@end

@implementation OakDocumentTracker

static NSMutableDictionary *s_OakPathToDocumentDict = nil;

+ (void)initialize
{
    s_OakPathToDocumentDict = [[NSMutableDictionary alloc] init];
}

- (OakDocument *)initWithPath: (NSString *)path
                   identifier: (id)key
{
    lock_t lock(this);
    
    OakDocument *it = [s_OakPathToDocumentDict objectForKey: key];
    if(it)
    {
        if(OakDocument * res = it->second.lock())
        {
            NSLog(@"re-use instance (%@)\n", [res path]);
            lock.release();
            
            if(pthread_self() == MainThread)
            {
                res->set_path(path);
            }
            
            return res;
            
        }else
        {
            NSLog(@"*** old instance gone\n");
        }
    }
    
    OakDocument * res = OakDocument *(new document_t);
    res->_identifier.generate();
    res->_path = path;
    res->_key  = key;
    
    add(res);
    return res;
}

- (OakDocument *)findDocumentByUUID: (NSUUID *)uuid
                      searchBackups: (BOOL)flag
{
    lock_t lock(this);
    D(DBF_Document_Tracker, bug("%s\n", to_s(uuid).c_str()););
    std::map<NSUUID *, document_weak_ptr>::const_iterator it = documents.find(uuid);
    if(it != documents.end())
    {
        if(OakDocument * res = it->second.lock())
        {
            D(DBF_Document_Tracker, bug("re-use instance\n"););
            return res;
        }
        else
        {
            D(DBF_Document_Tracker, bug("*** old instance gone\n"););
        }
    }
    
    path::walker_ptr walker = path::open_for_walk(session_dir());
    iterate(path, *walker)
    {
        NSString * attr = path::get_attr(*path, "com.macromates.backup.identifier");
        if(attr != NULL_STR && uuid == NSUUID *(attr))
        {
            OakDocument * res = OakDocument *(new document_t);
            
            res->_identifier     = uuid;
            res->_backup_path    = *path;
            
            res->_path           = path::get_attr(*path, "com.macromates.backup.path");
            res->_key            = path::identifier_t(res->_path);
            res->_file_type      = path::get_attr(*path, "com.macromates.backup.file-type");
            res->_disk_encoding  = path::get_attr(*path, "com.macromates.backup.encoding");
            res->_disk_bom       = path::get_attr(*path, "com.macromates.backup.bom") == "YES";
            res->_disk_newlines  = path::get_attr(*path, "com.macromates.backup.newlines");
            res->_untitled_count = atoi(path::get_attr(*path, "com.macromates.backup.untitled-count").c_str());
            res->_custom_name    = path::get_attr(*path, "com.macromates.backup.custom-name");
            res->_modified       = path::get_attr(*path, "com.macromates.backup.modified") == "YES";
            
            add(res);
            return res;
        }
    }
    D(DBF_Document_Tracker, bug("no instance found\n"););
    return OakDocument *();
}

- (void)removeWithUUID: (NSUUID *)uuid
                   key: (id)key
{
    lock_t lock(this);
    D(DBF_Document_Tracker, bug("%s, %s\n", to_s(uuid).c_str(), to_s(key).c_str()););
    if(key)
    {
        std::map<path::identifier_t, document_weak_ptr>::iterator it = documents_by_path.find(key);
        ASSERTF(it != documents_by_path.end(), "%s, %s", to_s(key).c_str(), to_s(uuid).c_str());
        if(!it->second.lock())
        {
            documents_by_path.erase(it);
        }
        else
        {
            D(DBF_Document_Tracker, bug("*** old instance replaced\n"););
        }
    }
    assert(documents.find(uuid) != documents.end());
    documents.erase(uuid);
}

- (id)updatePathWithDocument: (OakDocument *)doc
                      oldKey: (id)oldKey
                      newKey: (id)newKey
{
    lock_t lock(this);
    D(DBF_Document_Tracker, bug("%s → %s\n", to_s(oldKey).c_str(), to_s(newKey).c_str()););
    if(oldKey)
    {
        assert(documents_by_path.find(oldKey) != documents_by_path.end());
        documents_by_path.erase(oldKey);
    }
    
    if(newKey)
    {
        assert(documents_by_path.find(newKey) == documents_by_path.end());
        documents_by_path.insert(std::make_pair(newKey, doc));
    }
    
    return newKey;
}

- (NSUInteger)untitledCounter
{
    lock_t lock(this);
    
    std::set<NSUInteger> reserved;
    iterate(pair, documents)
    {
        if(OakDocument * doc = pair->second.lock())
        {
            if(doc->path() == NULL_STR)
                reserved.insert(doc->untitled_count());
        }
    }
    
    NSUInteger res = 1;
    while(reserved.find(res) != reserved.end())
        ++res;
    return res;
}

std::map<NSUUID *, document_weak_ptr> documents;
std::map<path::identifier_t, document_weak_ptr> documents_by_path;

- (void)_addDocument: (OakDocument *)doc
{
    ASSERT_EQ(lock_count, 1); // we assert that a lock has been obtained by the caller
    documents.insert(std::make_pair(doc->identifier(), doc));
    if(doc->_key)
    {
        D(DBF_Document_Tracker, bug("%s\n", doc->path().c_str()););
        std::map<path::identifier_t, document_weak_ptr>::iterator it = documents_by_path.find(doc->_key);
        ASSERTF(it == documents_by_path.end() || !it->second.lock(), "%s, %s\n", to_s(doc->_key).c_str(), to_s(doc->identifier()).c_str());
        if(it == documents_by_path.end())
            documents_by_path.insert(std::make_pair(doc->_key, doc));
        else  it->second = doc;
    }
}


@end


namespace document
{
	// ================
	// = File Watcher =
	// ================
    
    
	// ====================
	// = Document Tracker =
	// ====================
    
	static OSSpinLock spinlock = 0;
	static pthread_t MainThread = pthread_self();
    
    
	OakDocument * create (NSString * rawPath)
    {
        NSString * path = path::resolve(rawPath);
        return (path::is_text_clipping(path)
                ? from_content(path::resource(path, typeUTF8Text, 256))
                : documents.create(path, path::identifier_t(path)));
    }
    
	OakDocument * create (NSString * path, path::identifier_t  key)
    {
        return documents.create(path, key);
    }
    
	OakDocument * find (NSUUID * uuid, BOOL searchBackups)
    {
        return documents.find(uuid, searchBackups);
    }
