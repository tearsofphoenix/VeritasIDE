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
#import "OakDocumentWatch.h"
#import "OakDocumentMark.h"

@protocol OakDocumentReader<NSObject>

- (NSData *)next;

@end


@interface OakDocument()
{
    
    OakAuthorization * _authorization;   // when opened via sudo
    
    NSString * _disk_encoding;
    NSString * _disk_newlines;
    BOOL _disk_bom;
    
    OakDocumentWatch *_file_watcher;
    
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
    
    NSData * _content;
    
    NSMutableArray *_callbacks;
    
    id _key;
    
    NSString * _path;                    // does not imply there actually is a file
    NSDate * _lru;             // last time document was shown
    BOOL _recent_tracking;
    
    NSString * _backup_path;     // if there is a backup, this is set — we can have a backup even when there is no path
    
    NSString * _virtual_path;
    NSString * _custom_name;
    
    NSString * _file_type;       // this may also be in the settings
    
    NSString * _buffer;
    NSString * _pristine_buffer;
    NSUndoManager *_undo_manager;
    
    
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

- (id)initWithContent: (NSString *)content
             fileType: (NSString *)fileType
{
    if((self = [super init]))
    {
        if(fileType)
        {
            [self setFileType: fileType];
        }
        
        [self setContent: content];
    }
    
    return self;
}

- (void)dealloc
{
    if(_grammar)
    {
        //_grammar->remove_callback(&_grammar_callback);
    }
    if(_path && _buffer)
    {
        //document::marks.set(_path, marks());
    }
    
    //documents.remove(_identifier, _key);
    
    [super dealloc];
}

- (id<OakDocumentReader>)createReader
{
    
}

// ======================================================
// = Performing replacements (from outside a text view) =
// ======================================================

- (void)replaceContentWith: (NSDictionary *)replacements
{
    
}

- (void)addMark: (OakDocumentMark *)mark
        atRange: (OakTextRange *)range
{
    
}

- (void)removeAllMarksWithTypeToClear: (NSString *)typeToClear
{
    
}

- (NSDictionary *)allMarks
{
    
}

- (void)_loadMarksFromString: (NSString *) src
{
    
}

- (void)_setupMarksFromString: (NSString *) src
                       stream: (NSInputStream *)stream
{
    
}

- (NSString *)marksAsString
{
    
}

- (NSDictionary *)symbols
{
    
}

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

- (void)checkModified: (ssize_t) diskRev
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

- (void)postLoadForPath: (NSString *)path
                content: (NSData *) content
             attributes: (NSDictionary *)attributes
               fileType: (NSString *)fileType
         pathAttributes: (NSString *) pathAttributes
               encoding: (OakFileEncodingType * )encoding
{
    _open_callback.reset();
    if(!content)
    {
        _open_count = 0;
        return;
    }
    
    _path_attributes = pathAttributes;
    
    _disk_encoding = encoding.charset();
    _disk_newlines = encoding.newlines();
    _disk_bom      = encoding.byte_order_mark();
    
    if(_file_type == NULL_STR)
        _file_type = fileType;
    
    if(_selection == NULL_STR)
    {
        std::map<NSString *, NSString *>::const_iterator sel  = attributes.find("com.macromates.selectionRange");
        std::map<NSString *, NSString *>::const_iterator rect = attributes.find("com.macromates.visibleRect");
        _selection    = sel != attributes.end()  ? sel->second  : NULL_STR;
        _visible_rect = rect != attributes.end() ? rect->second : NULL_STR;
    }
    
    _is_on_disk = _path != NULL_STR && access(_path.c_str(), F_OK) == 0;
    if(_is_on_disk)
        _file_watcher.reset(new watch_t(_path, shared_from_this()));
    
    _buffer.reset(new NSString *);
    setup_buffer();
    if(content)
    {
        _buffer->insert(0, NSString *(content->begin(), content->end()));
        setup_marks(path, *_buffer);
        
        std::map<NSString *, NSString *>::const_iterator folded = attributes.find("com.macromates.folded");
        if(folded != attributes.end())
            _folded = folded->second;
    }
    _buffer->bump_revision();
    check_modified(_buffer->revision(), _buffer->revision());
    mark_pristine();
    _undo_manager.reset(new ng::undo_manager_t(buffer()));
    
    broadcast(callback_t::did_change_open_status);
}

- (void)postSaveToPath: (NSString *) path
               content: (NSData *)content
        pathAttributes: (NSString *) pathAttributes
              encoding: (OakFileEncodingType *) encoding
                succes: (BOOL) succes
{
    if(success)
    {
        _key        = documents.update_path(shared_from_this(), _key, path::identifier_t(_path));
        _is_on_disk = true;
        
        _path_attributes = pathAttributes;
        
        _disk_encoding = encoding.charset();
        _disk_bom      = encoding.byte_order_mark();
        _disk_newlines = encoding.newlines();
        
        check_modified(revision(), revision());
        mark_pristine();
        broadcast(callback_t::did_save);
        
        D(DBF_Document, bug("search for ‘did save’ hooks in scope ‘%s’\n", to_s(scope()).c_str()););
        citerate(item, bundles::query(bundles::kFieldSemanticClass, "callback.document.did-save", scope()))
        {
            D(DBF_Document, bug("%s\n", (*item)->name().c_str()););
            document::run(parse_command(*item), buffer(), OakSelectionRanges *(), shared_from_this());
        }
    }
    
    if(_is_on_disk)
        _file_watcher.reset(new watch_t(_path, shared_from_this()));
}


- (BOOL)tryOpenWithCallback: (OakDocumentCallback)callback
{
    
}

- (void)open
{
    
}

- (void)close
{
    
}

- (void)show
{
    
}

- (void)hide
{
    
}

- (NSDate *)lru
{
    
}

- (void)trySaveWithCallback: (OakDocumentCallback)callback
{
    
}

- (BOOL)save
{
    
}

- (BOOL)backup
{
    
}

- (NSString *)buffer
{
    
}

- (NSUndoManager *)undoManager
{
    
}

// =============
// = Accessors =
// =============

- (NSUUID *)identifier
{
    return _identifier;
}

- (NSInteger)revision
{
    return _revision;
}

- (void)setRevision: (NSInteger)rev
{
    [self checkModified: _disk_revision
               received: rev];
}

- (BOOL)isOpen
{
    return _open_count != 0 && !_open_callback;
}

- (NSString *)fileType
{
    
}

- (NSDictionary *)settings
{
    return nil; //settings_for_path(virtual_path(), scope(), path::parent(_path), variables(std::map<NSString *, NSString *>(), false));
}

- (NSDictionary *)variablesWith: (NSDictionary *)map
             isSourceFileSystem: (BOOL)sourceFileSystem
{
    
    map["TM_DISPLAYNAME"]   = display_name();
    map["TM_DOCUMENT_UUID"] = [self identifier];
    
    NSString *path = [self path];
    
    if(path)
    {
        map["TM_FILEPATH"]  = [self path];
        map["TM_FILENAME"]  = path::name(path());
        map["TM_DIRECTORY"] = path::parent(path());
        map["PWD"]          = path::parent(path());
        
        if(scm::info_ptr info = scm::info(path::parent(path())))
        {
            NSString * branch = info->branch();
            if(branch != NULL_STR)
                map["TM_SCM_BRANCH"] = branch;
            
            NSString * name = info->scm_name();
            if(name != NULL_STR)
                map["TM_SCM_NAME"] = name;
        }
    }
    
    return sourceFileSystem ? variables_for_path(path(), scope(), map) : map;
    
}

- (BOOL)isModified
{
    
}

-(BOOL)isOnDisk
{
    return [self isOpen] ? _is_on_disk : [[self path] existsAsPath];
}

- (void)setDiskRevision: (NSInteger)rev
{
    [self checkModified: rev
               received: _revision];
}

- (NSString *)selection
{
    return _selection;
}

- (NSString *)folded
{
    return _folded;
}

- (NSString *)visibleRect
{
    return _visible_rect;
}

- (void)setSelection: (NSString *)sel
{
    if (_selection != sel)
    {
        [_selection release];
        _selection = [sel retain];
        _visible_rect = nil;
    }
}

- (void)setFolded: (NSString *)folded
{
    _folded = folded;
}

- (void)setVisibleRect: (NSString *)rect
{
    _visible_rect = rect;
}

- (void)setAuthorization: (OakAuthorization *)auth
{
    _authorization = auth;
}

- (scope_t)scope
{
    return file_type() + " " + _path_attributes;
}

- (void)_setupBuffer
{

    if(_file_type)
    {
        citerate(item, bundles::query(bundles::kFieldGrammarScope, _file_type, scope::wildcard, bundles::kItemTypeGrammar))
        {
            if(parse::grammar_ptr grammar = parse::parse_grammar(*item))
            {
                if(_grammar)
                    _grammar->remove_callback(&_grammar_callback);
                
                _grammar = grammar;
                _grammar->add_callback(&_grammar_callback);
                
                _buffer->set_grammar(*item);
                
                break;
            }
        }
    }
    
    settings_t  settings = this->settings();
    _buffer->indent() = text::indent_t(settings.get(kSettingsTabSizeKey, 4), SIZE_T_MAX, settings.get(kSettingsSoftTabsKey, false));
    _buffer->set_spelling_language(settings.get(kSettingsSpellingLanguageKey, "en"));
    _buffer->set_live_spelling(settings.get(kSettingsSpellCheckingKey, false));
    
    [self broadcastEvent: OakDocumentEventdid_change_indent_settings
                 cascade: YES];
}

- (void)grammarDidChange
{
    
}

- (void)setContent: (NSData *)bytes
{
    
}

- (NSString *)content
{
    assert(_buffer);
    return _buffer;
}

- (void)setModified: (BOOL)flag
{
    
}

// ==============
// = Properties =
// ==============

+ (OakDocument *)documentWithPath: (NSString *)path
{
    
}

+ (OakDocument *)documentFromContent: (NSString *)content
                            fileType: (NSString *)fileType
{
    
}

+ (OakDocument *)documentWithUUID: (NSUUID *)uuid
                    searchBackups: (BOOL)flag
{
    
}

- (void)_markPristine
{
    
}


- (NSUInteger)untitledCount
{
    return _untitled_count;
}

- (void)watchCallbackWithFlag: (int) flags
                         path: (NSString *)newPath
                        async: (BOOL)async
{
    
}

- (NSString *)displayName
{
    if(_custom_name)
    {
        return _custom_name;
    }
    
    if(_path)
    {
        return path::display_name(_path);
    }
    
    if(!_untitled_count)
    {
        _untitled_count = documents.untitled_counter();
    }
    
    return _untitled_count == 1 ? @"untitled" : [NSString stringWithFormat: @"untitled %zu", _untitled_count];
}

- (NSString *)backupPath
{
    if(_backup_path)
    {
        _backup_path = ::backup_path(display_name());
    }
    
    return _backup_path;
}

- (void)grammarDidChange
{
    _buffer->set_grammar(bundles::lookup(_grammar->uuid())); // Preferably we’d pass _grammar to the buffer but then the buffer couldn’t get at the root scope and folding markers. Perhaps this should be exposed by grammar_t, but ideally the buffer itself would setup a callback to be notified about grammar changes. We only moved it to document_t because with a callback, buffer_t can’t get copy constructors for free.
}

- (void)markPristine
{
    assert(_buffer);
    _pristine_buffer = _buffer->substr(0, _buffer->size()); // TODO We should use a cheap ng::detail::storage_t copy
}

- (OakFileEncodingType *)encodingForSaveAsPath: (NSString *)path
{
    encoding::type res = disk_encoding();
    
    settings_t  settings = settings_for_path(path);
    if(!is_on_disk() || res.charset() == kCharsetNoEncoding)
    {
        res.set_charset(settings.get(kSettingsEncodingKey, kCharsetUTF8));
        res.set_byte_order_mark(settings.get(kSettingsUseBOMKey, res.byte_order_mark()));
    }
    
    if(!is_on_disk() || res.newlines() == NULL_STR)
        res.set_newlines(settings.get(kSettingsLineEndingsKey, "\n"));
    
    return res;
}


@end


void document_t::try_save (document::save_callback_ptr callback)
{
    struct save_callback_wrapper_t : file::save_callback_t
    {
        save_callback_wrapper_t (document::OakDocument * doc, document::save_callback_ptr callback, BOOL close) : _document(doc), _callback(callback), _close(close) { }
        
        void select_path (NSString * path, NSData * content, file::save_context_ptr context)                                     { _callback->select_path(path, content, context); }
        void select_make_writable (NSString * path, NSData * content, file::save_context_ptr context)                            { _callback->select_make_writable(path, content, context); }
        void obtain_authorization (NSString * path, NSData * content, OakAuthorization * auth, file::save_context_ptr context) { _callback->obtain_authorization(path, content, auth, context); }
        void select_charset (NSString * path, NSData * content, NSString * charset, file::save_context_ptr context)      { _callback->select_charset(path, content, charset, context); }
        
        void did_save (NSString * path, NSData * content, NSString * pathAttributes, OakFileEncodingType * encoding, BOOL success, NSString * message, NSUUID * filter)
        {
            _document->post_save(path, content, pathAttributes, encoding, success);
            _callback->did_save_document(_document, path, success, message, filter);
            if(_close)
                _document->close();
        }
        
    private:
        document::OakDocument * _document;
        document::save_callback_ptr _callback;
        BOOL _close;
    };
    
    D(DBF_Document, bug("save ‘%s’\n", _path.c_str()););
    
    BOOL closeAfterSave = false;
    if(!is_open())
    {
        if(!_content && _backup_path == NULL_STR)
            return callback->did_save(_path, NSData *(), _path_attributes, encoding::type(_disk_newlines, _disk_encoding, _disk_bom), false, NULL_STR, NSUUID *());
        open();
        closeAfterSave = true;
    }
    
    _file_watcher.reset();
    
    NSData * bytes(new io::bytes_t(content()));
    
    std::map<NSString *, NSString *> attributes;
    if(volume::settings(_path).extended_attributes())
    {
        attributes["com.macromates.selectionRange"] = _selection;
        attributes["com.macromates.visibleRect"]    = _visible_rect;
        attributes["com.macromates.bookmarks"]      = marks_as_string();
        attributes["com.macromates.folded"]         = _folded;
    }
    
    save_callback_wrapper_t* cb = new save_callback_wrapper_t(shared_from_this(), callback, closeAfterSave);
    save_callback_ptr sharedPtr((save_callback_t*)cb);
    
    encoding::type const encoding = encoding_for_save_as_path(_path);
    file::save(_path, sharedPtr, _authorization, bytes, attributes, _file_type, encoding, std::vector<NSUUID *>() /* binary import filters */, std::vector<NSUUID *>() /* text import filters */);
}

BOOL document_t::save ()
{
    try_save(callback);
    
    return res;
}

BOOL document_t::backup ()
{
    assert(_buffer);
    NSString * dst = backup_path();
    if(path::set_content(dst, content()))
    {
        path::set_attr(dst, "com.macromates.backup.path",           _path);
        path::set_attr(dst, "com.macromates.backup.identifier",     to_s(_identifier));
        path::set_attr(dst, "com.macromates.selectionRange",        _selection);
        path::set_attr(dst, "com.macromates.visibleRect",           _visible_rect);
        path::set_attr(dst, "com.macromates.backup.file-type",      _file_type);
        path::set_attr(dst, "com.macromates.backup.encoding",       _disk_encoding);
        path::set_attr(dst, "com.macromates.backup.bom",            _disk_bom ? "YES" : "NO");
        path::set_attr(dst, "com.macromates.backup.newlines",       _disk_newlines);
        path::set_attr(dst, "com.macromates.backup.untitled-count", text::format("%zu", _untitled_count));
        path::set_attr(dst, "com.macromates.backup.custom-name",    _custom_name);
        path::set_attr(dst, "com.macromates.bookmarks",             marks_as_string());
        path::set_attr(dst, "com.macromates.folded",                NULL_STR);
        if(is_modified())
            path::set_attr(dst, "com.macromates.backup.modified", "YES");
        
        // TODO tab size, spell checking, soft wrap, etc. should go into session!?!
        
        _backup_revision = revision();
        
        return true;
    }
    return false;
}

void document_t::check_modified (ssize_t diskRev, ssize_t rev)
{
    _disk_revision = diskRev;
    _revision = rev;
    
    set_modified(_revision != _disk_revision && (!buffer().empty() || is_on_disk()));
    if(is_modified())
        schedule_backup(identifier());
    else	cancel_backup(identifier());
}

BOOL document_t::is_modified () const
{
    return _modified;
}

void document_t::set_modified (BOOL flag)
{
    if(_modified != flag)
    {
        _modified = flag;
        
        broadcast(callback_t::did_change_modified_status);
        if(!_modified && _backup_path != NULL_STR && access(_backup_path.c_str(), F_OK) == 0)
            unlink(_backup_path.c_str());
    }
}

void document_t::set_path (NSString * newPath)
{
    NSString * normalizedPath = path::resolve(newPath);
    if(_path == normalizedPath)
        return;
    
    _path = normalizedPath;
    _key  = documents.update_path(shared_from_this(), _key, path::identifier_t(normalizedPath));
    if(is_open())
    {
        _is_on_disk = access(_path.c_str(), F_OK) == 0;
        _file_watcher.reset(_is_on_disk ? new watch_t(_path, shared_from_this()) : NULL);
        
        NSString * newFileType = OakGetFileType(_path, NSData *(new io::bytes_t(content())), _virtual_path);
        if(newFileType != NULL_STR)
            set_file_type(newFileType);
    }
    _custom_name = NULL_STR;
    broadcast(callback_t::did_change_path);
}

BOOL document_t::try_open (document::open_callback_ptr callback)
{
    if(++_open_count == 1)
    {
        if(_backup_path != NULL_STR)
        {
            BOOL modified = _modified;
            post_load(_path, NSData *(new io::bytes_t(path::content(_backup_path))), path::attributes(_backup_path), _file_type, file::path_attributes(_path), encoding::type(_disk_newlines, _disk_encoding, _disk_bom));
            if(modified)
                set_revision(buffer().bump_revision());
            return true;
        }
        
        _open_callback.reset(new open_callback_wrapper_t(shared_from_this(), callback));
        file::open(_path, _authorization, _open_callback, _content, _virtual_path);
        _content.reset();
        return false;
    }
    else if(_open_callback)
    {
        _open_callback->add_callback(callback);
        return false;
    }
    else
    {
        assert(_buffer); // load completed
        return true;
    }
}

void document_t::open ()
{
    try_open(callback)
}

void document_t::close ()
{
    if(--_open_count != 0)
        return;
    
    broadcast(callback_t::did_change_open_status);
    _file_watcher.reset();
    
    if(_path != NULL_STR && !is_modified() && volume::settings(_path).extended_attributes())
    {
        D(DBF_Document, bug("save attributes for ‘%s’\n", _path.c_str()););
        path::set_attr(_path, "com.macromates.selectionRange", _selection);
        path::set_attr(_path, "com.macromates.visibleRect",    _visible_rect);
        path::set_attr(_path, "com.macromates.bookmarks",      marks_as_string());
    }
    
    if(_backup_path != NULL_STR && access(_backup_path.c_str(), F_OK) == 0)
        unlink(_backup_path.c_str());
    _backup_path = NULL_STR;
    
    check_modified(-1, -1);
    _undo_manager.reset();
    _buffer.reset();
    _pristine_buffer = NULL_STR;
}

void document_t::show ()
{
    _has_lru = true;
    document::lru.set(_path, _lru = NSDate *::now());
}

void document_t::hide ()
{
    _has_lru = true;
    document::lru.set(_path, _lru = NSDate *::now());
}

NSDate * document_t::lru () const
{
    if(!_has_lru)
    {
        _has_lru = true;
        _lru = document::lru.get(_path);
    }
    return _lru;
}

void document_t::watch_callback (int flags, NSString * newPath, BOOL async)
{
    assert(_file_watcher);
    assert(is_open());
    
    // NOTE_ATTRIB
    if((flags & NOTE_RENAME) == NOTE_RENAME)
    {
        set_path(newPath);
    }
    else if((flags & NOTE_DELETE) == NOTE_DELETE)
    {
        D(DBF_Document_WatchFS, bug("%s deleted\n", _path.c_str()););
        if(_is_on_disk && !(_is_on_disk = access(_path.c_str(), F_OK) == 0))
            broadcast(callback_t::did_change_on_disk_status);
    }
    else if((flags & NOTE_WRITE) == NOTE_WRITE || (flags & NOTE_CREATE) == NOTE_CREATE)
    {
        struct open_callback_t : file::open_callback_t
        {
            open_callback_t (document::OakDocument * doc, BOOL async) : _document(doc), _wait(!async) { }
            
            void select_charset (NSString * path, NSData * content, file::open_context_ptr context)    { context->set_charset(_document->_disk_encoding); }
            void select_line_feeds (NSString * path, NSData * content, file::open_context_ptr context) { context->set_line_feeds(_document->_disk_newlines); }
            void select_file_type (NSString * path, NSData * content, file::open_context_ptr context)  { context->set_file_type(_document->_file_type); }
            void show_error (NSString * path, NSString * message, NSUUID * filter)        { fprintf(stderr, "%s: %s\n", path.c_str(), message.c_str()); }
            
            void show_content (NSString * path, NSData * content, std::map<NSString *, NSString *>  attributes, NSString * fileType, NSString * pathAttributes, OakFileEncodingType * encoding, std::vector<NSUUID *>  binaryImportFilters, std::vector<NSUUID *>  textImportFilters)
            {
                if(!_document->is_open())
                    return;
                
                NSString * yours = NSString *(content->begin(), content->end());
                NSString * mine  = _document->content();
                
                if(yours == mine)
                {
                    D(DBF_Document_WatchFS, bug("yours == mine, marking document as not modified\n"););
                    _document->set_disk_revision(_document->revision());
                    _document->mark_pristine();
                }
                else if(!_document->is_modified())
                {
                    D(DBF_Document_WatchFS, bug("changed on disk and we have no local changes, so reverting to that\n"););
                    _document->undo_manager().begin_undo_group(OakSelectionRanges *(0));
                    _document->_buffer->replace(0, _document->_buffer->size(), yours);
                    _document->_buffer->bump_revision();
                    _document->check_modified(_document->_buffer->revision(), _document->_buffer->revision());
                    _document->mark_pristine();
                    _document->undo_manager().end_undo_group(OakSelectionRanges *(0));
                }
                else
                {
                    BOOL conflict = false;
                    NSString * merged = merge(_document->_pristine_buffer, mine, yours, &conflict);
                    D(DBF_Document_WatchFS, bug("changed on disk and we have local changes, merge conflict %s.\n%s\n", BSTR(conflict), merged.c_str()););
                    _document->undo_manager().begin_undo_group(OakSelectionRanges *(0));
                    _document->_buffer->replace(0, _document->_buffer->size(), merged);
                    _document->set_revision(_document->_buffer->bump_revision());
                    _document->undo_manager().end_undo_group(OakSelectionRanges *(0));
                    // TODO if there was a conflict, we shouldn’t take the merged content (but ask user what to do)
                    // TODO mark_pristine() but using ‘yours’
                }
                
            }
            
        private:
            document::OakDocument * _document;
            BOOL _wait;
        };
        
        if(!_is_on_disk && (_is_on_disk = access(_path.c_str(), F_OK) == 0))
            broadcast(callback_t::did_change_on_disk_status);
        
        open_callback_t* raw = new open_callback_t(shared_from_this(), async);
        file::open_callback_ptr cb((file::open_callback_t*)raw);
        file::open(_path, _authorization, cb);
        raw->wait();
    }
}

void document_t::set_file_type (NSString * newFileType)
{
    D(DBF_Document, bug("%s → %s (%s)\n", _file_type.c_str(), newFileType.c_str(), display_name().c_str()););
    if(_file_type != newFileType)
    {
        _file_type = newFileType;
        if(_buffer)
            setup_buffer();
        broadcast(callback_t::did_change_file_type);
    }
}

void document_t::set_content (NSData *  bytes)
{
    D(DBF_Document, bug("%.*s… (%zu bytes), file type %s\n", MIN<int>(32, bytes->size()), bytes->get(), bytes->size(), _file_type.c_str()););
    assert(!_buffer);
    _content = bytes;
}

namespace
{
    struct file_reader_t : reader::open_t
    {
        WATCH_LEAKS(file_reader_t);
        file_reader_t (document_const_ptr  document) : reader::open_t(document->path()), document(document) { }
    private:
        document_const_ptr document;
    };
    
    struct buffer_reader_t : document::document_t::reader_t
    {
        WATCH_LEAKS(buffer_reader_t);
        buffer_reader_t (NSData *  data) : _data(data) { }
        
        NSData * next ()
        {
            NSData * res = _data;
            _data.reset();
            return res;
        }
        
    private:
        NSData * _data;
    };
}

document_t::reader_ptr document_t::create_reader () const
{
    if(is_open())
        return reader_ptr(new buffer_reader_t(NSData *(new io::bytes_t(content()))));
		return reader_ptr(new file_reader_t(shared_from_this()));
        }

// ===========
// = Replace =
// ===========

void document_t::replace (std::multimap<OakTextRange *, NSString *>  replacements)
{
    assert(!is_open());
    
    if(replacements.empty())
        return;
    
    assert(_path != NULL_STR);
    assert(!_buffer)
    
    NSString * buf;
    buf.insert(0, path::content(_path));
    
    riterate(pair, replacements)
    {
        D(DBF_Document_Replace, bug("replace %s with ‘%s’\n", NSString *(pair->first).c_str(), pair->second.c_str()););
        buf.replace(buf.convert(pair->first.min()), buf.convert(pair->first.max()), pair->second);
    }
    
    _content.reset(new io::bytes_t(buf.substr(0, buf.size())));
}

static OakSelectionIndex * cap (NSString *  buf, text::pos_t  pos)
{
    NSUInteger line = OakCap<NSUInteger>(0, pos.line,   buf.lines()-1);
    NSUInteger col  = OakCap<NSUInteger>(0, pos.column, buf.eol(line) - buf.begin(line));
    OakSelectionIndex * res = buf.sanitize_index(buf.convert(text::pos_t(line, col)));
    if(pos.offset && res.index < buf.size() && buf[res.index] == "\n")
        res.carry = pos.offset;
    return res;
}

// =========
// = Marks =
// =========

void document_t::load_marks (NSString * src) const
{
    if(_did_load_marks)
        return;
    
    if(src != NULL_STR)
    {
        _marks = document::marks.get(src);
        document::marks.set(src, std::multimap<OakTextRange *, document_t::mark_t>());
    }
    
    _did_load_marks = true;
}

static void copy_marks (NSString *& buf, std::multimap<OakTextRange *, document_t::mark_t>  marks)
{
    iterate(pair, marks)
    buf.set_mark(cap(buf, pair->first.from).index, pair->second.type);
}

void document_t::setup_marks (NSString * src, NSString *& buf) const
{
    if(_did_load_marks)
    {
        copy_marks(buf, _marks);
    }
    else if(src != NULL_STR)
    {
        copy_marks(buf, document::marks.get(src));
        document::marks.set(src, std::multimap<OakTextRange *, document_t::mark_t>());
    }
}

std::multimap<OakTextRange *, document_t::mark_t> document_t::marks () const
{
    if(_buffer)
    {
        std::multimap<OakTextRange *, document_t::mark_t> res;
        citerate(pair, _buffer->get_marks(0, _buffer->size()))
        res.insert(std::make_pair(_buffer->convert(pair->first), pair->second));
        return res;
    }
    return document::marks.get(_path);
}

void document_t::add_mark (OakTextRange * range, mark_t  mark)
{
    if(_buffer)
    {
        _buffer->set_mark(_buffer->convert(range.from), mark.type);
    }
    else
    {
        load_marks(_path);
        _marks.insert(std::make_pair(range, mark));
    }
    broadcast(callback_t::did_change_marks);
}

void document_t::remove_all_marks (NSString * typeToClear)
{
    if(_buffer)
    {
        _buffer->remove_all_marks(typeToClear);
    }
    else
    {
        load_marks(_path);
        
        std::multimap<OakTextRange *, mark_t> newMarks;
        if(typeToClear != NULL_STR)
        {
            iterate(it, _marks)
            {
                if(it->second.type != typeToClear)
                    newMarks.insert(*it);
            }
        }
        
        _marks.swap(newMarks);
    }
    broadcast(callback_t::did_change_marks);
}

NSString * document_t::marks_as_string () const
{
    std::vector<NSString *> v;
    if(_buffer)
    {
        citerate(pair, _buffer->get_marks(0, _buffer->size()))
        {
            if(pair->second == "bookmark")
                v.push_back(text::format("'%s'", NSString *(_buffer->convert(pair->first)).c_str()));
        }
    }
    else
    {
        load_marks(_path);
        iterate(mark, _marks)
        {
            if(mark->second.type == "bookmark")
                v.push_back(text::format("'%s'", NSString *(mark->first).c_str()));
        }
    }
    return v.empty() ? NULL_STR : "( " + text::join(v, ", ") + " )";
}

// ===========
// = Symbols =
// ===========

std::map<text::pos_t, NSString *> document_t::symbols ()
{
    if(!_buffer)
        return std::map<text::pos_t, NSString *>();
    
    _buffer->wait_for_repair();
    
    std::map<text::pos_t, NSString *> res;
    citerate(pair, _buffer->symbols())
    res.insert(std::make_pair(_buffer->convert(pair->first), pair->second));
    return res;
}

// ====================
// = Document scanner =
// ====================

std::vector<OakDocument *> scanner_t::open_documents ()
{
    std::vector<OakDocument *> res;
    
    document_tracker_t::lock_t lock(&document::documents);
    iterate(pair, document::documents.documents)
    {
        OakDocument * doc = pair->second.lock();
        if(doc && doc->is_open())
            res.push_back(doc);
    }
    
    return res;
}

scanner_t::scanner_t (NSString * path, path::glob_list_t  glob, BOOL follow_links, BOOL depth_first) : path(path), glob(glob), follow_links(follow_links), depth_first(depth_first), is_running_flag(true), should_stop_flag(false)
{
    D(DBF_Document_Scanner, bug("%s, links %s\n", path.c_str(), BSTR(follow_links)););
    
    document_tracker_t::lock_t lock(&document::documents);
    iterate(pair, document::documents.documents)
    {
        OakDocument * doc = pair->second.lock();
        if(doc && doc->path() == NULL_STR)
            documents.push_back(doc);
    }
    
    struct bootstrap_t { static void* main (void* arg) { ((scanner_t*)arg)->thread_main(); return NULL; } };
    pthread_mutex_init(&mutex, NULL);
    pthread_create(&thread, NULL, &bootstrap_t::main, this);
}

scanner_t::~scanner_t ()
{
    D(DBF_Document_Scanner, bug("\n"););
    stop();
    wait();
    pthread_mutex_destroy(&mutex);
}

std::vector<OakDocument *> scanner_t::accept_documents ()
{
    pthread_mutex_lock(&mutex);
    std::vector<OakDocument *> res;
    res.swap(documents);
    pthread_mutex_unlock(&mutex);
    return res;
}

NSString * scanner_t::get_current_path () const
{
    pthread_mutex_lock(&mutex);
    NSString * res = current_path;
    pthread_mutex_unlock(&mutex);
    return res;
}

void scanner_t::thread_main ()
{
    oak::set_thread_name("document::scanner_t");
    
    scan_dir(path);
    D(DBF_Document_Scanner, bug("running %s → NO\n", BSTR(is_running_flag)););
    is_running_flag = false;
}

void scanner_t::scan_dir (NSString * initialPath)
{
    D(DBF_Document_Scanner, bug("%s, running %s\n", initialPath.c_str(), BSTR(is_running_flag)););
    
    std::deque<NSString *> dirs(1, initialPath);
    std::vector<NSString *> links;
    while(!dirs.empty())
    {
        NSString * dir = dirs.front();
        dirs.pop_front();
        
        struct stat buf;
        if(lstat(initialPath.c_str(), &buf) != 0) // get st_dev so we don’t need to stat each path entry (unless it is a symbolic link)
            continue;
        
        assert(S_ISDIR(buf.st_mode) || S_ISLNK(buf.st_mode));
        
        pthread_mutex_lock(&mutex);
        current_path = dir;
        pthread_mutex_unlock(&mutex);
        
        std::vector<NSString *> newDirs;
        std::multimap<NSString *, path::identifier_t, text::less_t> files;
        citerate(it, path::entries(dir))
        {
            if(should_stop_flag)
                break;
            
            NSString * path = path::join(dir, (*it)->d_name);
            if((*it)->d_type == DT_DIR)
            {
                if(glob.exclude(path, path::kPathItemDirectory))
                    continue;
                
                if(seen_paths.insert(std::make_pair(buf.st_dev, (*it)->d_ino)).second)
                    newDirs.push_back(path);
                else	D(DBF_Document_Scanner, bug("skip known path: ‘%s’\n", path.c_str()););
            }
            else if((*it)->d_type == DT_REG)
            {
                if(glob.exclude(path, path::kPathItemFile))
                    continue;
                
                if(seen_paths.insert(std::make_pair(buf.st_dev, (*it)->d_ino)).second)
                    files.insert(std::make_pair(path, path::identifier_t(true, buf.st_dev, (*it)->d_ino, path)));
                else	D(DBF_Document_Scanner, bug("skip known path: ‘%s’\n", path.c_str()););
            }
            else if((*it)->d_type == DT_LNK)
            {
                links.push_back(path); // handle later since link may point to another device plus if link is “local” and will be seen later, we reported the local path rather than this link
            }
        }
        
        std::sort(newDirs.begin(), newDirs.end(), text::less_t());
        dirs.insert(depth_first ? dirs.begin() : dirs.end(), newDirs.begin(), newDirs.end());
        
        if(dirs.empty())
        {
            iterate(link, links)
            {
                NSString * path = path::resolve(*link);
                if(lstat(path.c_str(), &buf) == 0)
                {
                    if(S_ISDIR(buf.st_mode) && follow_links && seen_paths.insert(std::make_pair(buf.st_dev, buf.st_ino)).second)
                    {
                        if(glob.exclude(path, path::kPathItemDirectory))
                            continue;
                        
                        D(DBF_Document_Scanner, bug("follow link: %s → %s\n", link->c_str(), path.c_str()););
                        dirs.push_back(path);
                    }
                    else if(S_ISREG(buf.st_mode))
                    {
                        if(glob.exclude(path, path::kPathItemFile))
                            continue;
                        
                        if(seen_paths.insert(std::make_pair(buf.st_dev, buf.st_ino)).second)
                            files.insert(std::make_pair(path, path::identifier_t(true, buf.st_dev, buf.st_ino, path)));
                        else	D(DBF_Document_Scanner, bug("skip known path: ‘%s’\n", path.c_str()););
                    }
                }
            }
            links.clear();
        }
        
        pthread_mutex_lock(&mutex);
        iterate(file, files)
        documents.push_back(document::create(file->first, file->second));
        pthread_mutex_unlock(&mutex);
    }
}

