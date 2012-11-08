//
//  OakDocumentOpenCallback.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakDocumentOpenCallback.h"
#import "OakAuthorization.h"

enum
{
    kStateIdle,
    kStateStart,
    kStateObtainAuthorization,
    kStateLoadContent,
    kStateExecuteBinaryImportFilter,
    kStateEstimateEncoding,
    kStateSelectEncoding,
    kStateDecodeContent,
    kStateEstimateLineFeeds,
    kStateHarmonizeLineFeeds,
    kStateExecuteTextImportFilter,
    kStateEstimateFileType,
    kStateEstimateTabSettings,
    kStateShowContent,
    kStateDone
};

typedef NSInteger OakFileOpenState;

enum
{
    kEstimateEncodingStateBOM,
    kEstimateEncodingStateExtendedAttribute,
    kEstimateEncodingStateASCII,
    kEstimateEncodingStateUTF8,
    kEstimateEncodingStatePathSettings,
    kEstimateEncodingStateAskUser
};

typedef NSInteger OakFileOpenEstimateEncodingState;

@interface OakFileOpenContext : NSObject<OakFileOpenContext>
{
    OakFileOpenState _state;
    OakFileOpenState _next_state;
    OakFileOpenEstimateEncodingState _estimate_encoding_state;
    
    OakFileOpenCallback *_callback;
    
    NSString *_path;
    NSString *_virtual_path;
    OakAuthorization *_authorization;
    
    NSData *_content;
    NSMutableDictionary *_attributes;
    NSStringEncoding *_encoding;
    NSString *_file_type; // root grammar scope
    NSString * _path_attributes;
    NSString * _error;
    NSUUID *_filter; // this filter failed
    
    NSMutableArray *_binary_import_filters;
    NSMutableArray *_text_import_filters;
}

- (id)initWithPath: (NSString *)path
   existingContent: (NSData *)existingContent
     authorization: (OakAuthorization *)authorization
          callback: (OakFileOpenCallback *)callback
       virtualPath: (NSString *)virtualPath;

@end

@implementation OakFileOpenContext

- (id)initWithPath: (NSString *)path
   existingContent: (NSData *)existingContent
     authorization: (OakAuthorization *)authorization
          callback: (OakFileOpenCallback *)callback
       virtualPath: (NSString *)virtualPath
{
    if((self = [super init]))
    {
        _state = kStateIdle;
        _next_state = kStateStart;
        _estimate_encoding_state = kEstimateEncodingStateBOM;
        _callback = [callback retain];
        _path = [path retain];
        _virtual_path = [virtualPath retain];
        _content = [existingContent retain];
        _file_type = kFileTypePlainText;
        _path_attributes = nil;
        _error = nil;
    }
    
    return self;
}

- (void)dealloc
{
    if(_state != kStateDone)
    {
        [_callback showErrorForPath: _path
                            message: _error
                             filter: _filter];
    }
    
    [_callback release];
    [_path release];
    [_virtual_path release];
    [_content release];
    
    
    [super dealloc];
}

- (void)_proceed
{
    _state = _next_state;

	{
		_next_state = kStateIdle;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
		while(_state != kStateIdle && _state != kStateDone)
		{
			switch(_state)
			{
				case kStateStart:
				{
					_state      = kStateIdle;
					_next_state = kStateObtainAuthorization;
                    
                    NSError *error = nil;
					_path_attributes = [fileManager attributesOfItemAtPath: _path
                                                                     error: &error];
                    if (error)
                    {
                        NSLog(@"in func: %s error: %@", __func__, error);
                    }
                    
					if(_content)
						_next_state = kStateExecuteBinaryImportFilter;
                    
					[self _proceed];
				}
                    break;
                    
				case kStateObtainAuthorization:
				{
					_state      = kStateIdle;
					_next_state = kStateLoadContent;
                    
					if(_path && access([_path UTF8String], R_OK) == -1 && errno == EACCES)
                    {
                        [_callback obtainForPath: _path
                                   authorization: _authorization
                                         context: self];
                    }else
                    {
                        [self _proceed];
                    }
				}
                    break;
                    
				case kStateLoadContent:
				{
					_state      = kStateIdle;
					_next_state = kStateExecuteBinaryImportFilter;
                    
					new file::read_t(_path, _authorization, std::static_pointer_cast<open_file_context_t>(shared_from_this()));
				}
                    break;
                    
				case kStateExecuteBinaryImportFilter:
				{
					_state      = kStateIdle;
					_next_state = kStateEstimateEncoding;
                    
					if(!_content)
						break;
                    
					std::vector<OakBundleItem *> filters;
					citerate(item, filter::find(_path, _content, _path_attributes, filter::kBundleEventBinaryImport))
					{
						if(!oak::contains(_binary_import_filters.begin(), _binary_import_filters.end(), (*item)->uuid()))
						{
							filters.push_back(*item);
							_binary_import_filters.push_back((*item)->uuid());
							break; // FIXME see next FIXME
						}
					}
                    
					if(filters.empty())
					{
						proceed();
					}
					else // FIXME we need to show dialog incase of multiple import hooks
					{
						_next_state = kStateExecuteBinaryImportFilter;
						filter::run(filters.back(), _path, _content, std::static_pointer_cast<open_file_context_t>(shared_from_this()));
					}
				}
                    break;
                    
				case kStateEstimateEncoding:
				{
					_state      = kStateIdle;
					_next_state = kStateDecodeContent;
                    
					char const* first = _content->begin();
					char const* last  = _content->end();
					switch(_estimate_encoding_state++)
					{
						case kEstimateEncodingStateBOM:
						{
							NSString * charset = charset_from_bom(first, last);
							if(charset != kCharsetNoEncoding)
							{
								_encoding.set_charset(charset);
								_encoding.set_byte_order_mark(true);
							}
						}
                            break;
                            
						case kEstimateEncodingStateExtendedAttribute:
						{
							NSString * charset = path::get_attr(_path, "com.apple.TextEncoding");
							_encoding.set_charset(charset != NULL_STR ? charset.substr(0, charset.find(';')) : kCharsetUnknown);
						}
                            break;
                            
						case kEstimateEncodingStateASCII:
							_encoding.set_charset(std::find_if(first, last, &not_ascii) == last ? kCharsetNoEncoding : kCharsetUnknown);
                            break;
                            
						case kEstimateEncodingStateUTF8:
							_encoding.set_charset(utf8::is_valid(first, last) ? kCharsetUTF8 : kCharsetUnknown);
                            break;
                            
						case kEstimateEncodingStatePathSettings:
							_encoding.set_charset(settings_for_path(_path, "attr.file.unknown-encoding " + file::path_attributes(_path)).get(kSettingsEncodingKey, kCharsetUnknown));
                            break;
                            
						case kEstimateEncodingStateAskUser:
							_next_state = kStateSelectEncoding;
							_estimate_encoding_state = kEstimateEncodingStateAskUser;
                            break;
					}
					proceed();
				}
                    break;
                    
				case kStateSelectEncoding:
				{
					_state      = kStateIdle;
					_next_state = kStateDecodeContent;
                    
					_callback->select_charset(_path, _content, shared_from_this());
				}
                    break;
                    
				case kStateDecodeContent:
				{
					_state      = kStateIdle;
					_next_state = kStateEstimateLineFeeds;
                    
					if(NSData * decodedContent = convert(_content, _encoding.charset() == kCharsetNoEncoding ? kCharsetASCII : _encoding.charset(), kCharsetUTF8, _encoding.byte_order_mark()))
                        _content = decodedContent;
					else	_next_state = kStateEstimateEncoding;
                    
					proceed();
				}
                    break;
                    
				case kStateEstimateLineFeeds:
				{
					_state      = kStateIdle;
					_next_state = kStateHarmonizeLineFeeds;
                    
					_encoding.set_newlines(find_line_endings(_content->begin(), _content->end()));
					if(_encoding.newlines() != kMIX)
                        proceed();
					else	_callback->select_line_feeds(_path, _content, shared_from_this());
				}
                    break;
                    
				case kStateHarmonizeLineFeeds:
				{
					if(_encoding.newlines() != kLF)
					{
						char* newEnd = harmonize_line_endings(_content->begin(), _content->end(), _encoding.newlines());
						_content->resize(newEnd - _content->begin());
					}
					_state = kStateExecuteTextImportFilter;
				}
                    break;
                    
				case kStateExecuteTextImportFilter:
				{
					_state      = kStateIdle;
					_next_state = kStateEstimateFileType;
                    
					std::vector<OakBundleItem *> filters;
					citerate(item, filter::find(_path, _content, _path_attributes, filter::kBundleEventTextImport))
					{
						if(!oak::contains(_text_import_filters.begin(), _text_import_filters.end(), (*item)->uuid()))
						{
							filters.push_back(*item);
							_text_import_filters.push_back((*item)->uuid());
							break; // FIXME see next FIXME
						}
					}
                    
					if(filters.empty())
					{
						proceed();
					}
					else // FIXME we need to show dialog incase of multiple import hooks
					{
						_next_state = kStateExecuteTextImportFilter;
						filter::run(filters.back(), _path, _content, std::static_pointer_cast<open_file_context_t>(shared_from_this()));
					}
				}
                    break;
                    
				case kStateEstimateFileType:
				{
					_state      = kStateIdle;
					_next_state = kStateEstimateTabSettings;
                    
					_file_type = OakGetFileType(_path, _content, _virtual_path);
					if(_file_type != NULL_STR)
                        proceed();
					else	_callback->select_file_type(_virtual_path != NULL_STR ? _virtual_path : _path, _content, shared_from_this());
				}
                    break;
                    
				case kStateEstimateTabSettings:
				{
					_state = kStateShowContent;
					// TODO run some heuristic
				}
                    break;
                    
				case kStateShowContent:
				{
					_state = kStateDone;
					_callback->show_content(_path, _content, _attributes, _file_type, _path_attributes, _encoding, _binary_import_filters, _text_import_filters);
				}
                    break;
			}
		}
	}
}

- (void)setAuthorization: (OakAuthorization *)authorization
{
    if (_authorization != authorization)
    {
        [_authorization release];
        _authorization = [authorization retain];
        
        [self _proceed];
    }
}

- (void)setContent: (NSData *)content
{
    if(_content != content)
    {
        [_content release];
        _content = [content retain];
        
        [self _proceed];
    }
}

- (void)setContent: (NSData *)content
        attributes: (NSDictionary *)attr
{
    if (_attributes != attr)
    {
        [_attributes release];
        _attributes = [attr retain];
    }
    
    [self setContent: _content];
}

- (void)setCharsetName: (NSString *)charsetName
{
    //_encoding.set_charset(charset);
    [self _proceed];
}

- (void)setLineFeeds: (NSString *)lineFeeds
{
    //_encoding.set_newlines(newlines);
    [self _proceed];
}

- (void)setFileType: (NSString *)fileType
{
    if (_file_type != fileType)
    {
        [_file_type release];
        _file_type = [fileType retain];
        
        [self _proceed];
    }
}

- (void)filterErrorForCommand: (OakBundleCommand *)command
                           rc: (int)rc
                       output: (NSString *)outPut
                        error: (NSString *)error
{
    [_error release];
    _error = [[NSString stringWithFormat: @"Command returned status code %d. error: %@, %@", rc, error, outPut] retain];
    _filter = [command uuid];
}

@end


@implementation OakDocumentOpenCallback


- (void)showContentForPath:(NSString *)path
                      data:(NSData *)content
                attributes:(NSDictionary *)attr
                  fileType:(NSString *)fileType
            pathAttributes:(NSString *)pathAttributes
                  encoding:(NSStringEncoding)encoding
       binaryImportFilters:(NSArray *)filters
         textImportFilters:(NSArray *)textFilters
{
    
}

@end


namespace
{
	struct open_file_context_t : file::open_context_t
	{
		open_file_context_t (NSString * path, NSData * existingContent, OakAuthorization * auth, file::open_callback_ptr callback, NSString * virtualPath) : _state(kStateIdle), _next_state(kStateStart), _estimate_encoding_state(kEstimateEncodingStateBOM), _callback(callback), _path(path), _virtual_path(virtualPath), _authorization(auth), _content(existingContent), _file_type(kFileTypePlainText), _path_attributes(NULL_STR), _error(NULL_STR)
		{
		}
        
		~open_file_context_t ()
		{
			if(_state != kStateDone)
				_callback->show_error(_path, _error, _filter);
		}
        
		void set_authorization (OakAuthorization * auth)                                       { _authorization = auth;                  proceed(); }
		void set_content (NSData * content)                                                 { _content = content;                     proceed(); }
		void set_content (NSData * content, std::map<NSString *, NSString *>  attr) { _attributes = attr; _content = content; proceed(); }
		void set_charset (NSString * charset)                                            { _encoding.set_charset(charset);         proceed(); }
		void set_line_feeds (NSString * newlines)                                        { _encoding.set_newlines(newlines);       proceed(); }
		void set_file_type (NSString * fileType)                                         { _file_type  = fileType;                 proceed(); }
        
		void filter_error (bundle_command_t  command, int rc, NSString * out, NSString * err)
		{
			_error = [NSString stringWithFormat: @"Command returned status code %d.%@%@", rc, err, out];
			_filter = command.uuid;
		}
        
		void proceed ()
		{
			_state = _next_state;
			event_loop();
		}
        
	private:
		void event_loop ();
        
		enum state_t {
			kStateIdle,
			kStateStart,
			kStateObtainAuthorization,
			kStateLoadContent,
			kStateExecuteBinaryImportFilter,
			kStateEstimateEncoding,
			kStateSelectEncoding,
			kStateDecodeContent,
			kStateEstimateLineFeeds,
			kStateHarmonizeLineFeeds,
			kStateExecuteTextImportFilter,
			kStateEstimateFileType,
			kStateEstimateTabSettings,
			kStateShowContent,
			kStateDone
		};
        
		enum estimate_encoding_state_t {
			kEstimateEncodingStateBOM,
			kEstimateEncodingStateExtendedAttribute,
			kEstimateEncodingStateASCII,
			kEstimateEncodingStateUTF8,
			kEstimateEncodingStatePathSettings,
			kEstimateEncodingStateAskUser
		};
        
		state_t _state;
		state_t _next_state;
		int _estimate_encoding_state;
        
		file::open_callback_ptr _callback;
        
		NSString * _path;
		NSString * _virtual_path;
		OakAuthorization * _authorization;
        
		NSData * _content;
		std::map<NSString *, NSString *> _attributes;
		encoding::type _encoding;
		NSString * _file_type; // root grammar scope
		NSString * _path_attributes;
		NSString * _error;
		NSUUID * _filter; // this filter failed
        
		std::vector<NSUUID *> _binary_import_filters;
		std::vector<NSUUID *> _text_import_filters;
	};
    
	typedef std::shared_ptr<open_file_context_t> file_context_ptr;
}

// =================
// = Threaded Read =
// =================

namespace file
{
	struct read_t
	{
		struct request_t { NSString * path; OakAuthorization * authorization; };
		struct result_t  { NSData * bytes; std::map<NSString *, NSString *> attributes; int error_code; };
        
		WATCH_LEAKS(read_t);
        
		read_t (NSString * path, OakAuthorization * auth, file_context_ptr context);
		 ~read_t ();
        
		static read_t::result_t handle_request (read_t::request_t  request);
		void handle_reply (read_t::result_t  result);
        
	private:
		NSUInteger _client_key;
		file_context_ptr _context;
	};
    
	static oak::server_t<read_t>& read_server ()
	{
		static oak::server_t<read_t> server;
		return server;
	}
    
	read_t::read_t (NSString * path, OakAuthorization * auth, file_context_ptr context) : _context(context)
	{
		_client_key = read_server().register_client(this);
		read_server().send_request(_client_key, (request_t){ path, auth });
	}
    
	read_t::~read_t ()
	{
		read_server().unregister_client(_client_key);
	}
    
	read_t::result_t read_t::handle_request (read_t::request_t  request)
	{
		result_t result;
		result.error_code = 0;
        
		int fd = ::open(request.path.c_str(), O_RDONLY);
		if(fd != -1)
		{
			struct stat sbuf;
			if(fstat(fd, &sbuf) != -1)
			{
				fcntl(fd, F_NOCACHE, 1);
				result.bytes.reset(new io::bytes_t(sbuf.st_size));
				if(read(fd, result.bytes->get(), result.bytes->size()) != sbuf.st_size)
					result.bytes.reset();
			}
			else
			{
				result.error_code = errno;
			}
			close(fd);
            
			result.attributes = path::attributes(request.path);
		}
		else if(errno == EACCES)
		{
			///TODO:remote
            //
		}
		else
		{
			result.error_code = errno;
		}
		return result;
	}
    
	void read_t::handle_reply (read_t::result_t  result)
	{
		if(!result.bytes && result.error_code == ENOENT)
            _context->set_content(NSData *(new io::bytes_t("")), result.attributes);
		else	_context->set_content(result.bytes, result.attributes);
		delete this;
	}
    
} /* file */

// ====================
// = Encoding Support =
// ====================

template <typename _InputIter>
NSString * charset_from_bom (_InputIter  first, _InputIter  last)
{
	static struct UTFBOMTests { NSString * bom; NSString * encoding; } const BOMTests[] =
	{
		{ NSString *("\x00\x00\xFE\xFF", 4), kCharsetUTF32BE },
		{ NSString *("\xFE\xFF",         2), kCharsetUTF16BE },
		{ NSString *("\xFF\xFE\x00\x00", 4), kCharsetUTF32LE },
		{ NSString *("\xFF\xFE",         2), kCharsetUTF16LE },
		{ NSString *("\uFEFF",           3), kCharsetUTF8    }
	};
    
	for(NSUInteger i = 0; i < sizeofA(BOMTests); ++i)
	{
		if(oak::has_prefix(first, last, BOMTests[i].bom.begin(), BOMTests[i].bom.end()))
			return BOMTests[i].encoding;
	}
	return kCharsetNoEncoding;
}

static BOOL not_ascii (char ch)
{
	return !((0x20 <= ch && ch < 0x80) || (ch && strchr("\t\n\f\r\e", ch)));
}

static NSData * remove_bom (NSData * content)
{
	if(content)
	{
		ASSERT_GE(content->size(), 3); ASSERT_EQ(NSString *(content->get(), content->get() + 3), "\uFEFF");
		memmove(content->get(), content->get()+3, content->size()-3);
		content->resize(content->size()-3);
	}
	return content;
}

static NSData * convert (NSData * content, NSString * from, NSString * to, BOOL bom = false)
{
	if(from == kCharsetUnknown)
		return NSData *();
    
	content = encoding::convert(content, from, to);
	return bom ? remove_bom(content) : content;
}

// =====================
// = Line Feed Support =
// =====================

template <typename _InputIter>
NSString * find_line_endings (_InputIter  first, _InputIter  last)
{
	NSUInteger cr_count = std::count(first, last, '\r');
	NSUInteger lf_count = std::count(first, last, '\n');
    
	if(cr_count == 0)
		return kLF;
	else if(lf_count == 0)
		return kCR;
	else if(lf_count == cr_count)
		return kCRLF;
	else
		return kLF;
}

template <typename _InputIter>
_InputIter harmonize_line_endings (_InputIter first, _InputIter last, NSString * lineFeeds)
{
	_InputIter out = first;
	while(first != last)
	{
		BOOL isCR = *first == '\r';
		if(out != first || isCR)
			*out = isCR ? '\n' : *first;
		if(++first != last && isCR && *first == '\n')
			++first;
		++out;
	}
	return out;
}

// ===================================
// = Default Callback Implementation =
// ===================================

namespace file
{
	void open_callback_t::obtain_authorization (NSString * path, OakAuthorization * auth, open_context_ptr context)
	{
		if(auth.obtain_right(kAuthRightName))
			context->set_authorization(auth);
	}
    
	void open_callback_t::select_charset (NSString * path, NSData * content, open_context_ptr context)
	{
	}
    
	void open_callback_t::select_line_feeds (NSString * path, NSData * content, open_context_ptr context)
	{
		context->set_line_feeds(kLF);
	}
    
	void open_callback_t::select_file_type (NSString * path, NSData * content, open_context_ptr context)
	{
		context->set_file_type(kFileTypePlainText);
	}
    
} /* file */


// ====================

namespace file
{
	void open (NSString * path, OakAuthorization * auth, open_callback_ptr cb, NSData * existingContent, NSString * virtualPath)
	{
		open_context_ptr context(new open_file_context_t(path, existingContent, auth, cb, virtualPath));
		std::static_pointer_cast<open_file_context_t>(context)->proceed();
	}
    
}
