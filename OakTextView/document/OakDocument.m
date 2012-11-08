//
//  OakDocument.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakDocument.h"
#import "OakFileReader.h"
#import "OakFileEncodingType.h"
#import <OakFoundation/OakFoundation.h>

@protocol OakDocumentReader<NSObject>

- (NSData *)next;

@end

@interface OakDocumentMark : NSObject

@property (nonatomic, retain) NSString * type;

@property (nonatomic, retain) NSString * info;

@end


@implementation OakDocumentMark

- (id)init
{
    if ((self = [super init]))
    {
        [self setType: @"bookmark"];
        [self setInfo: @""];
    }
    
    return self;
}

- (void)dealloc
{
    [_type release];
    [_info release];
    
    [super dealloc];
}

- (BOOL)isEqual: (id)object
{
    if ([object isKindOfClass: [self class]])
    {
        return [_type isEqualToString: [(OakDocumentMark *)object type]] && [_info isEqualToString: [object info]];
    }
    
    return NO;
}

@end


struct open_callback_wrapper_t : OakF
{
    open_callback_wrapper_t (document::OakDocument * doc, document::open_callback_ptr callback) : _document(doc), _callbacks(1, callback) { }
    
    void select_charset (NSString * path, NSData * content, file::open_context_ptr context)    { _callbacks[0]->select_charset(path, content, context); }
    void select_line_feeds (NSString * path, NSData * content, file::open_context_ptr context) { _callbacks[0]->select_line_feeds(path, content, context); }
    void select_file_type (NSString * path, NSData * content, file::open_context_ptr context)  { if(_document->file_type() == NULL_STR) _callbacks[0]->select_file_type(path, content, context); else context->set_file_type(_document->file_type()); }
    void add_callback (document::open_callback_ptr callback)                                                { _callbacks.push_back(callback); }
    
    void show_content (NSString * path, NSData * content, std::map<NSString *, NSString *>  attributes, NSString * fileType, NSString * pathAttributes, OakFileEncodingType * encoding, std::vector<NSUUID *>  binaryImportFilters, std::vector<NSUUID *>  textImportFilters)
    {
        // we are deleted in post_load() so make a copy of relevant data
        std::vector<document::open_callback_ptr> callbacks(_callbacks);
        document::OakDocument * doc = _document;
        
        _document->post_load(path, content, attributes, fileType, pathAttributes, encoding);
        iterate(cb, callbacks)
        (*cb)->show_document(path, doc);
    }
    
    void show_error (NSString * path, NSString * message, NSUUID * filter)
    {
        // we are deleted in post_load() so make a copy of relevant data
        std::vector<document::open_callback_ptr> callbacks(_callbacks);
        document::OakDocument * doc = _document;
        
        _document->post_load(path, NSData *(), std::map<NSString *, NSString *>(), NULL_STR, NULL_STR, encoding::type());
        iterate(cb, callbacks)
        (*cb)->show_error(path, doc, message, filter);
    }
    
private:
    document::OakDocument * _document;
    std::vector<document::open_callback_ptr> _callbacks;
};


@interface OakDocument()
{
    BOOL _did_load_marks;
    NSString *_selection;
    NSString *_folded;
    NSString *_visible_rect;
    BOOL _disable_callbacks;
    NSInteger _revision;
    NSInteger _disk_revision;
    BOOL _modified;
    NSInteger _open_count;
    BOOL _has_lru;
    BOOL _is_on_disk;
    NSInteger _backup_revision;
        
    NSInteger _untitled_count;
    id _grammar_callback;
    NSString *_path_attributes;
        
    NSString *_identifier;
    NSMutableDictionary *_marks;
    
    
    NSString * _selection;
    NSString * _folded;
    NSString * _visible_rect;
    NSData * _content;
    
    NSMutableArray *_callbacks;
    
    open_callback_wrapper_ptr _open_callback;

}
@end

@implementation OakDocument

- (id)init
{
    if((self = [super init]))
    {
        _did_load_marks = NO;
        _selection = nil;
        _folded = nil;
        _visible_rect = nil;
        _disable_callbacks = NO;
        _revision = 0;
        _disk_revision = 0;
        _modified = NO;
        _path = nil;
        _open_count = 0;
        _has_lru = NO;
        _is_on_disk = NO;
        _recent_tracking = YES;
        _backup_path = nil;
        _backup_revision = 0;
        _virtual_path = nil;
        _custom_name = nil;
        _untitled_count = 0;
        
        ///TODO
        //
        //_grammar_callback
        _file_type = nil;
        _path_attributes = nil;
        _disk_encoding = nil;
        _disk_newlines = nil;
        _disk_bom = NO;
    }
    
    return self;
}

- (id<OakDocumentReader>)create_reader;

// ======================================================
// = Performing replacements (from outside a text view) =
// ======================================================

- (void)replaceContentWith: (NSDictionary *)replacements;

- (void)addMark: (OakDocumentMark *)mark
        atRange: (OakTextRange *)range;

- (void)removeAllMarksWithTypeToClear: (NSString *)typeToClear;

- (NSDictionary *)allMarks;

- (void)_loadMarksFromString: (NSString *) src;

- (void)_setupMarksFromString: (NSString *) src
                       stream: (NSInputStream *)stream;

- (NSString *)marks_as_string;

- (NSDictionary *)symbols;

- (void)addCallback: (OakDocumentCallback)callback
{
    callback = Block_copy(callback);
    
    [_callbacks addObject: callback];
    
    Block_release(callback);
    
}

- (void)removeCallback: (OakDocumentCallback)callback
{
    [_callbacks removeObject: callback];
}

- (void)check_modified: (ssize_t) diskRev
              received: (ssize_t)rev
{
    
}

- (void)broadcastEvent: (OakDocumentEventType)event
               cascade: (BOOL)cascade
{
    if(!_disable_callbacks)
    {
        _disable_callbacks = !cascade;
        
        for (OakDocumentCallback callback in _callbacks)
        {
            callback(self, event);
        }

        _disable_callbacks = false;
    }
}

// ===================
// = For OakTextView =
// ===================

- (void)post_loadForPath: (NSString * path)
                 content: (NSData *) content
              attributes: (NSDictionary *)attributes
                fileType: (NSString *)fileType
          pathAttributes: (NSString *) pathAttributes
                encoding: (OakFileEncodingType * )encoding;

- (void)post_saveToPath: (NSString *) path
                content: (NSData *)content,
        pathAttributes: (NSString *) pathAttributes
    encoding: (OakFileEncodingType *) encoding
    succes: (BOOL) succes;


- (BOOL)try_openWithCallback: (OakDocumentCallback)callback;

- (void)open;

- (void)close;

- (void)show;

- (void)hide;

- (NSDate *)lru

- (void) try_saveWithCallback: (OakDocumentCallback)callback;

- (BOOL)save;

- (BOOL)backup;

NSString *& buffer ()               { assert(_buffer); return *_buffer; }
NSString *  buffer () const   { assert(_buffer); return *_buffer; }

ng::undo_manager_t& undo_manager ()               { assert(_undo_manager); return *_undo_manager; }
ng::undo_manager_t  undo_manager () const   { assert(_undo_manager); return *_undo_manager; }

// =============
// = Accessors =
// =============

NSUUID * identifier () const       { return _identifier; }
ssize_t revision () const             { return _revision; }
void set_revision (ssize_t rev)       { check_modified(_disk_revision, rev); }
bool is_open () const                 { return _open_count != 0 && !_open_callback; }

NSString * file_type () ;
settings_t const settings () const    { return settings_for_path(virtual_path(), scope(), path::parent(_path), variables(std::map<NSString *, NSString *>(), false)); }

std::map<NSString *, NSString *> variables (std::map<NSString *, NSString *> map, bool sourceFileSystem = true) ;

bool is_modified () ;
bool is_on_disk () const                            { return is_open() ? _is_on_disk : path::exists(path());                }
void set_disk_revision (ssize_t rev)                { check_modified(rev, _revision);                                       }
NSString * selection () const               { return _selection;                                                    }
NSString * folded () const                  { return _folded;                                                       }
NSString * visible_rect () const                   { return _visible_rect;                                                 }

void set_selection (NSString * sel)         { _selection = sel; _visible_rect = NULL_STR;                           }
void set_folded (NSString * folded)         { _folded = folded;                                                     }
void set_visible_rect (NSString * rect)     { _visible_rect = rect;                                                 }

void set_authorization (OakAuthorization *  auth) { _authorization = auth; }

private:
scope::scope_t scope () const { return file_type() + " " + _path_attributes; }

void setup_buffer ();
void grammar_did_change ();

void set_content (NSData *  bytes);
NSString * content
{
    assert(_buffer); return _buffer->substr(0, _buffer->size());
}

void set_modified (bool flag);

// ==============
// = Properties =
// ==============

friend OakDocument * create (NSString * path);
friend OakDocument * from_content (NSString * content, NSString * fileType);
friend OakDocument * find (NSUUID * uuid, bool searchBackups);

NSUUID * _identifier;              // to identify this document when there is no path
path::identifier_t _key;
ssize_t _revision;
ssize_t _disk_revision;
bool _modified;

NSString * _path;                    // does not imply there actually is a file
NSUInteger _open_count;                   // document open in some window/tab
mutable NSDate * _lru;             // last time document was shown
mutable bool _has_lru;
bool _is_on_disk;
bool _recent_tracking;

mutable NSString * _backup_path;     // if there is a backup, this is set — we can have a backup even when there is no path
mutable ssize_t _backup_revision;

NSString * _virtual_path;
NSString * _custom_name;
mutable NSUInteger _untitled_count;       // this is ≠ 0 if the document is untitled

struct grammar_callback_t : parse::grammar_t::callback_t
{
    grammar_callback_t (document_t& doc) : _document(doc) { }
    void grammar_did_change ()                            { _document.grammar_did_change(); }
private:
    document_t& _document;
};

parse::grammar_ptr _grammar;
grammar_callback_t _grammar_callback;

mutable NSString * _file_type;       // this may also be in the settings
mutable NSString * _path_attributes;
// NSUUID * _grammar_uuid;

std::shared_ptr<NSString *> _buffer;
NSString * _pristine_buffer = NULL_STR;
std::shared_ptr<ng::undo_manager_t> _undo_manager;
void mark_pristine ();

// NSString * _folder;                   // when there is no path, this value is where the document will likely end up, i.e, used for retrieving settings and default save location
OakAuthorization * _authorization;   // when opened via sudo

friend struct document_tracker_t;
NSUInteger untitled_count () const        { return _untitled_count; }

NSString * _disk_encoding;
NSString * _disk_newlines;
bool _disk_bom;

protected: // so that we can trigger the callback in unit tests
OakDocumentWatch *_file_watcher;
friend struct watch_t;
void watch_callback (int flags, NSString * newPath, bool async = true);
};

extern OakDocument * create (NSString * path = NULL_STR);
extern OakDocument * find (NSUUID * uuid, bool searchBackups = true);
extern OakDocument * from_content (NSString * content, NSString * fileType = NULL_STR);

// ====================
// = Document scanner =
// ====================

struct extern scanner_t
{
    WATCH_LEAKS(scanner_t);
    
    scanner_t (NSString * path, path::glob_list_t  glob, bool follow_links = false, bool depth_first = false);
    ~scanner_t ();
    
    bool is_running () const { return is_running_flag; }
    void stop ()             { should_stop_flag = true; }
    void wait () const       { pthread_join(thread, NULL); }
    
    static std::vector<OakDocument *> open_documents ();
    
    std::vector<OakDocument *> accept_documents ();
    NSString * get_current_path () ;
    
private:
    NSString * path;
    path::glob_list_t glob;
    bool follow_links, depth_first;
    
    pthread_t thread;
    mutable pthread_mutex_t mutex;
    volatile bool is_running_flag, should_stop_flag;
    
    void thread_main ();
    void scan_dir (NSString * dir);
    
    NSString * current_path;
    std::vector<OakDocument *> documents;
    std::set< std::pair<dev_t, ino_t> > seen_paths;
};


@end
