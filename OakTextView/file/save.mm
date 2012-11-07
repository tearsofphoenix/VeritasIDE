#include "save.h"
#import "OakAuthorization.h"
#import "OakFileEncodingType.h"

enum
{
    kStateIdle,
    kStateStart,
    kStateSelectPath,
    kStateMakeWritable,
    kStateObtainAuthorization,
    kStateExecuteTextExportFilter,
    kStateConvertLineFeeds,
    kStateSelectEncoding,
    kStateEncodeContent,
    kStateExecuteBinaryExportFilter,
    kStateSaveContent,
    kStateNotifyCallback,
    kStateDone
};

typedef NSInteger OakFileSaveState;

@interface OakFileSaveContext : NSObject<OakFileSaveContext>
{
    OakFileSaveState                     _state;
    OakFileSaveState                     _next_state;
    BOOL                                 _make_writable;
    BOOL                                 _saved;
    
    id              _callback;
    
    
    NSString *                         _file_type;
    NSString *                          _path_attributes;
    OakFileEncodingType                  *_encoding;
    
    NSString *                          _error;
    NSUUID *                          _filter; // this filter failed
    
    NSMutableArray*             _binary_import_filters;
    NSMutableArray*             _text_import_filters;
    
    NSMutableArray*             _binary_export_filters;
    NSMutableArray*             _text_export_filters;
}

@property (nonatomic, retain) id content;

@end

@implementation OakFileSaveContext

@synthesize path = _path;
@synthesize writable = _writable;
@synthesize authorization = _authorization;
@synthesize content = _content;
@synthesize charset = _charset;

- (void)dealloc
{
    
    if(_state != kStateDone)
    {
        assert(!_saved);
        //_callback didSave(_path, _content, _path_attributes, _encoding, _saved, _error, _filter);
    }
    
    [super dealloc];
}

- (void)_proceed
{
    _state = _next_state;
    
    [self _proceed];
}

- (void)setPath: (NSString *)path
{
    if (_path != path)
    {
        [_path release];
        _path = [path retain];
        
        [self _proceed];
    }
}

- (void)setWritable: (BOOL)writable
{
    if (_writable != writable)
    {
        _writable = writable;
        
        [self _proceed];
    }
}

- (void)setAuthorization: (OakAuthorization *)authorization
{
    if(_authorization != authorization)
    {
        [_authorization release];
        _authorization = [authorization retain];
        
        [self _proceed];
    }
}

- (void)setContent: (NSData *) content
{
    if (_content != content)
    {
        [_content release];
        _content = [content retain];
        
        [self _proceed];
    }
}

- (void)setCharset: (NSString *)charset
{
    [_encoding setCharsetName: charset];
    
    [self _proceed];
}

- (void)setSaved: (BOOL)flag
           error: (NSString *)error
{
    _saved = flag;
    [_error release];
    _error = [error retain];
    
    [self _proceed];
}

- (void)filterCommand: (OakBundleCommand *)command
           returnCode: (int)rc
                ouput: (NSString *)outPut
                error: (NSString *)err
{
    _error = [NSString stringWithFormat: @"Command returned status code %d.%@%@", rc, err, outPut];
    _filter = [command uuid];
}

@end

// ==================
// = Threaded Write =
// ==================

NSString * const OakSaveNotificationPathKey = @"path";
NSString * const OakSaveNotificationDataKey = @"data";
NSString * const OakSaveNotificationAttributesKey = @"attributes";
NSString * const OakSaveNotificationAuthorizationKey = @"authorization";

@interface OakFileSaveWriter : NSObject
{
    NSUInteger _client_key;
    OakFileSaveContext *_callback;
}

- (void)handleReply: (NSString *)error;

@end

@implementation OakFileSaveWriter

static NSNotificationCenter * s_OakFileSaveNotificationCenter = nil;

static NSNotificationCenter *OakFileSaveNotificationCenter(void)
{
    if (!s_OakFileSaveNotificationCenter)
    {
        s_OakFileSaveNotificationCenter = [[NSNotificationCenter alloc] init];
    }
    
    return s_OakFileSaveNotificationCenter;
}

- (id)init
{
    if ((self = [super init]))
    {
        //            _client_key = write_server().register_client(this);
        //            write_server().send_request(_client_key, (request_t){ path, bytes, attributes, authorization });
    }
    
    return self;
}

- (void)dealloc
{
    [OakFileSaveNotificationCenter() removeObserver: self];
    
    [super dealloc];
}

- (NSString *)handleRequest: (NSDictionary *)request
{
    NSString *error = @"";
//    file_status_t status = file::status(request.path);
//    
//    if(status == kFileTestWritable
//       || status == kFileTestNotWritableButOwner)
//    {
//        if(status == kFileTestNotWritableButOwner)
//        {
//            struct stat sbuf;
//            if(stat(request.path.c_str(), &sbuf) == 0)
//                chmod(request.path.c_str(), sbuf.st_mode | S_IWUSR);
//        }
//        
//        path::intermediate_t dest(request.path);
//        
//        int fd = open(dest, O_CREAT|O_TRUNC|O_WRONLY, S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH);
//        if(fd == -1)
//            error = text::format("open(\"%s\"): %s", (char const*)dest, strerror(errno));
//        else if(write(fd, request.bytes->get(), request.bytes->size()) != request.bytes->size())
//        {
//            close(fd);
//            error = text::format("write(): %s", strerror(errno));
//        }
//        else if(close(fd) != 0)
//            error = text::format("close(): %s", strerror(errno));
//        else if(!dest.commit())
//            error = text::format("Atomic save: %s", strerror(errno));
//        else if(!path::set_attributes(request.path, request.attributes))
//            error = text::format("Setting extended attributes: %s", strerror(errno));
//    }
//    else if(status == kFileTestWritableByRoot || status == kFileTestNotWritable)
//    {
//        ///TODO:remote
//        //
//        
//    }
    return error;
}

- (void)handleReply: (NSString *)error
{
    [_callback  setSaved: (!error)
                   error: error];
}


// ====================
// = Context Datatype =
// ====================

- (void)event_loop
{
    _next_state = kStateIdle;
    while(_state != kStateIdle && _state != kStateDone)
    {
        switch(_state)
        {
            case kStateStart:
            {
                _state      = kStateIdle;
                _next_state = kStateSelectPath;
                
                if(_path == NULL_STR)
                    _callback->select_path(_path, _content, shared_from_this());
                else	proceed();
            }
                break;
                
            case kStateSelectPath:
            {
                _state      = kStateIdle;
                _next_state = kStateMakeWritable;
                
                if(_path != NULL_STR)
                {
                    _path_attributes = file::path_attributes(_path);
                    proceed();
                }
            }
                break;
                
            case kStateMakeWritable:
            {
                _state      = kStateIdle;
                _next_state = kStateObtainAuthorization;
                
                switch(file::status(_path))
                {
                    case kFileTestNotWritable:
                    case kFileTestNotWritableButOwner:
                        _callback->select_make_writable(_path, _content, shared_from_this());
                        break;
                        
                    case kFileTestWritable:
                    case kFileTestWritableByRoot:
                        proceed();
                        break;
                        
                    case kFileTestNoParent:
                    case kFileTestReadOnly:
                        // TODO show error
                        break;
                }
            }
                break;
                
            case kStateObtainAuthorization:
            {
                _state      = kStateIdle;
                _next_state = kStateExecuteTextExportFilter;
                
                file_status_t status = file::status(_path);
                if(status == kFileTestWritable || (status == kFileTestNotWritableButOwner && _make_writable))
                    proceed();
                else if(status == kFileTestWritableByRoot || (status == kFileTestNotWritable && _make_writable))
                    _callback->obtain_authorization(_path, _content, _authorization, shared_from_this());
            }
                break;
                
            case kStateExecuteTextExportFilter:
            {
                _state      = kStateIdle;
                _next_state = kStateConvertLineFeeds;
                
                std::vector<OakBundleItem *> filters;
                citerate(item, filter::find(_path, _content, _path_attributes, filter::kBundleEventTextExport))
                {
                    if(!oak::contains(_text_export_filters.begin(), _text_export_filters.end(), (*item)->uuid()))
                    {
                        filters.push_back(*item);
                        _text_export_filters.push_back((*item)->uuid());
                        break; // FIXME see next FIXME
                    }
                }
                
                if(filters.empty())
                {
                    proceed();
                }
                else // FIXME we need to show dialog incase of multiple import hooks
                {
                    _next_state = kStateExecuteTextExportFilter;
                    filter::run(filters.back(), _path, _content, std::static_pointer_cast<file_context_t>(shared_from_this()));
                }
            }
                break;
                
            case kStateConvertLineFeeds:
            {
                _state      = kStateIdle;
                _next_state = kStateEncodeContent;
                
                if(_encoding.newlines() != kLF)
                {
                    NSString * tmp;
                    oak::replace_copy(_content->begin(), _content->end(), kLF.begin(), kLF.end(), _encoding.newlines().begin(), _encoding.newlines().end(), back_inserter(tmp));
                    _content->set_string(tmp);
                }
                
                proceed();
            }
                break;
                
            case kStateSelectEncoding:
            {
                _state      = kStateIdle;
                _next_state = kStateEncodeContent;
                
                _callback->select_charset(_path, _content, _encoding.charset(), shared_from_this());
            }
                break;
                
            case kStateEncodeContent:
            {
                _state      = kStateIdle;
                _next_state = kStateExecuteBinaryExportFilter;
                
                if(_encoding.charset() == kCharsetNoEncoding)
                {
                    _next_state = kStateSelectEncoding;
                }
                else
                {
                    NSData * encodedContent = _content;
                    
                    if(_encoding.byte_order_mark())
                    {
                        NSString * tmp("\uFEFF");
                        tmp.insert(tmp.end(), encodedContent->begin(), encodedContent->end());
                        encodedContent->set_string(tmp);
                    }
                    
                    if(encodedContent = encoding::convert(_content, kCharsetUTF8, _encoding.charset()))
                        _content = encodedContent;
                    else	_next_state = kStateSelectEncoding;
                }
                
                proceed();
            }
                break;
                
            case kStateExecuteBinaryExportFilter:
            {
                _state      = kStateIdle;
                _next_state = kStateSaveContent;
                
                std::vector<OakBundleItem *> filters;
                citerate(item, filter::find(_path, _content, _path_attributes, filter::kBundleEventBinaryExport))
                {
                    if(!oak::contains(_binary_export_filters.begin(), _binary_export_filters.end(), (*item)->uuid()))
                    {
                        filters.push_back(*item);
                        _binary_export_filters.push_back((*item)->uuid());
                        break; // FIXME see next FIXME
                    }
                }
                
                if(filters.empty())
                {
                    proceed();
                }
                else // FIXME we need to show dialog incase of multiple import hooks
                {
                    _next_state = kStateExecuteBinaryExportFilter;
                    filter::run(filters.back(), _path, _content, std::static_pointer_cast<file_context_t>(shared_from_this()));
                }
            }
                break;
                
            case kStateSaveContent:
            {
                _state      = kStateIdle;
                _next_state = kStateNotifyCallback;
                
                new file::write_t(_path, _content, _attributes, _authorization, std::static_pointer_cast<file_context_t>(shared_from_this()));
            }
                break;
                
            case kStateNotifyCallback:
            {
                _state      = kStateIdle;
                _next_state = kStateDone;
                
                _callback->did_save(_path, _content, file::path_attributes(_path), _encoding, _saved, _error, _filter);
                proceed();
            }
                break;
        }
    }
}

@end

namespace file
{
	// =================
	// = Save Callback =
	// =================
    
	void save_callback_t::select_path (NSString * path, NSData * content, save_context_ptr context)
	{
		context->set_path(NULL_STR);
	}
    
	void save_callback_t::select_make_writable (NSString * path, NSData * content, save_context_ptr context)
	{
		context->set_make_writable(false);
	}
    
	void save_callback_t::obtain_authorization (NSString * path, NSData * content, OakAuthorization * auth, save_context_ptr context)
	{
		if(auth.obtain_right(kAuthRightName))
			context->set_authorization(auth);
	}
    
	void save_callback_t::select_charset (NSString * path, NSData * content, NSString * charset, save_context_ptr context)
	{
		context->set_charset(kCharsetUTF8);
	}
    
	// ==============
	// = Public API =
	// ==============
    
	// bool hasEncoding   = path::get_attr(path, "com.apple.TextEncoding") != NULL_STR;
	// bool storeEncoding = dstSettings.get(kSettingsStoreEncodingPerFileKey, hasEncoding);
	// if(storeEncoding || hasEncoding)
	// 	path::set_attr(path, "com.apple.TextEncoding", storeEncoding ? encoding : NULL_STR);
    
	void save (NSString * path, save_callback_ptr cb, OakAuthorization * auth, NSData * content, std::map<NSString *, NSString *>  attributes, NSString * fileType, OakFileEncodingType * encoding, std::vector<NSUUID *>  binaryImportFilters, std::vector<NSUUID *>  textImportFilters)
	{
		save_context_ptr context(new file_context_t(cb, path, auth, content, attributes, fileType, encoding, binaryImportFilters, textImportFilters));
		std::static_pointer_cast<file_context_t>(context)->proceed();
	}
    
} /* file */
