#include "document.h"
#include "merge.h"
#include "collection.h"


#include <file/type.h>
#include <file/path_info.h>

#include <selection/selection.h>

#include <text/utf8.h>
#include <text/OakTextCtype.h>

#import <OakSCM/OakSCM.h>

#include <settings/volume.h>
#include <queue>
#include <sys/stat.h>

static NSString * session_dir ()
{
    return @"/tmp";
}

// ==========
// = Backup =
// ==========

static NSString * backup_path (NSString * displayName)
{
    NSString *rp = [displayName stringByReplacingOccurrencesOfString: @"/"
                                                          withString: @":"];

	return [session_dir() stringByAppendingPathComponent: rp];
}

@interface OakDocumentBackupRecord : NSObject

@property (nonatomic, assign)     NSTimer *timer;

@property (nonatomic) CFAbsoluteTime backup_at;

@property (nonatomic) CFAbsoluteTime upper_limit;

@end

@implementation OakDocumentBackupRecord

- (id)init
{
    if((self = [super init]))
    {
        _backup_at = DBL_MAX;
        _upper_limit = CFAbsoluteTimeGetCurrent() + 10;
    }
    return self;
}

@end

static NSMutableDictionary *records;

static void cancel_backup (NSUUID * docId)
{
	[records removeObjectForKey: docId];
}

static void perform_backup (NSUUID * docId)
{
	if(OakDocument * document = document::find(docId, false))
    {
		[document backup];
    }
    
	[records removeObjectForKey: docId];
}

static void schedule_backup (NSUUID * docId)
{
	OakDocumentBackupRecord *record = records[docId];
	CFAbsoluteTime backupAt = MIN(CFAbsoluteTimeGetCurrent() + 2, [record upper_limit]);
	if(![record timer] || [record backup_at] < backupAt)
	{
		record.timer =  cf::setup_timer(backupAt - CFAbsoluteTimeGetCurrent(), std::bind(&perform_backup, docId));
		record.backup_at = backupAt;
	}
}

// ==========

static std::multimap<OakTextRange *, document::document_t::mark_t> parse_marks (NSString * str)
{
	std::multimap<OakTextRange *, document::document_t::mark_t> marks;
	if(str != NULL_STR)
	{
		id plist = plist::parse(str);
		if(plist::array_t const* array = boost::get<plist::array_t>(&plist))
		{
			iterate(bm, *array)
			{
				if(NSString * str = boost::get<NSString *>(&*bm))
					marks.insert(std::make_pair(*str, "bookmark"));
			}
		}
	}
	return marks;
}

namespace document
{
	// ================
	// = File Watcher =
	// ================

	struct watch_t : watch_base_t
	{
		WATCH_LEAKS(document::watch_t);

		watch_t (NSString * path, document_weak_ptr document) : watch_base_t(path), document(document) { }

		void callback (int flags, NSString * newPath)
		{
			if(OakDocument * doc = document.lock())
				doc->watch_callback(flags, newPath);
		}

	private:
		document_weak_ptr document;
	};

	// ====================
	// = Document Tracker =
	// ====================

	static OSSpinLock spinlock = 0;
	static pthread_t MainThread = pthread_self();

	static struct document_tracker_t
	{
		ssize_t lock_count;
		document_tracker_t () : lock_count(0) { }

		struct lock_t
		{
			lock_t (document_tracker_t* tracker) : tracker(tracker), locked(false) { retain(); }
			~lock_t ()                                                             { release(); }

			void retain ()  { OSSpinLockLock(&spinlock); DB(++tracker->lock_count); locked = true; };
			void release () { if(!locked) return; DB(--tracker->lock_count); OSSpinLockUnlock(&spinlock); locked = false; }

		private:
			document_tracker_t* tracker;
			bool locked;
		};

		OakDocument * create (NSString * path, path::identifier_t  key)
		{
			lock_t lock(this);
			D(DBF_Document_Tracker, bug("%s\n", path.c_str()););

			std::map<path::identifier_t, document_weak_ptr>::const_iterator it = documents_by_path.find(key);
			if(it != documents_by_path.end())
			{
				if(OakDocument * res = it->second.lock())
				{
					D(DBF_Document_Tracker, bug("re-use instance (%s)\n", res->path().c_str()););
					lock.release();
					if(pthread_self() == MainThread)
						res->set_path(path);
					return res;
				}
				else
				{
					D(DBF_Document_Tracker, bug("*** old instance gone\n"););
				}
			}

			OakDocument * res = OakDocument *(new document_t);
			res->_identifier.generate();
			res->_path = path;
			res->_key  = key;

			add(res);
			return res;
		}

		OakDocument * find (NSUUID * uuid, bool searchBackups)
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

		void remove (NSUUID * uuid, path::identifier_t  key)
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

		path::identifier_t  update_path (OakDocument * doc, path::identifier_t  oldKey, path::identifier_t  newKey)
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

		NSUInteger untitled_counter ()
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

	private:
		void add (OakDocument * doc)
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

	} documents;

	OakDocument * create (NSString * rawPath)                             { NSString * path = path::resolve(rawPath); return path::is_text_clipping(path) ? from_content(path::resource(path, typeUTF8Text, 256)) : documents.create(path, path::identifier_t(path)); }
	OakDocument * create (NSString * path, path::identifier_t  key) { return documents.create(path, key); }
	OakDocument * find (NSUUID * uuid, bool searchBackups)              { return documents.find(uuid, searchBackups); }

	OakDocument * from_content (NSString * content, NSString * fileType)
	{
		D(DBF_Document, bug("%s\n", fileType.c_str()););
		OakDocument * doc = create();
		if(fileType != NULL_STR)
			doc->set_file_type(fileType);
		doc->set_content(NSData *(new io::bytes_t(content)));
		return doc;
	}

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
		mutable bool did_load;

	} lru;

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

	// ==============
	// = document_t =
	// ==============

	document_t::~document_t ()
	{
		D(DBF_Document, bug("%s\n", display_name().c_str()););
		if(_grammar)
			_grammar->remove_callback(&_grammar_callback);
		if(_path != NULL_STR && _buffer)
			document::marks.set(_path, marks());
		documents.remove(_identifier, _key);
	}

	NSString * document_t::display_name () const
	{
		if(_custom_name != NULL_STR)
			return _custom_name;
		if(_path != NULL_STR)
			return path::display_name(_path);

		if(!_untitled_count)
			_untitled_count = documents.untitled_counter();

		return _untitled_count == 1 ? "untitled" : text::format("untitled %zu", _untitled_count);
	}

	NSString * document_t::backup_path () const
	{
		if(_backup_path == NULL_STR)
			_backup_path = ::backup_path(display_name());
		return _backup_path;
	}

	NSString * document_t::file_type () const
	{
		D(DBF_Document, bug("%s, %s\n", display_name().c_str(), _file_type.c_str()););
		return _file_type;
	}

	std::map<NSString *, NSString *> document_t::variables (std::map<NSString *, NSString *> map, bool sourceFileSystem) const
	{
		map["TM_DISPLAYNAME"]   = display_name();
		map["TM_DOCUMENT_UUID"] = to_s(identifier());

		if(path() != NULL_STR)
		{
			map["TM_FILEPATH"]  = path();
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

	void document_t::setup_buffer ()
	{
		D(DBF_Document, bug("%s, %s\n", display_name().c_str(), _file_type.c_str()););
		if(_file_type != NULL_STR)
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

		const_cast<document_t*>(this)->broadcast(callback_t::did_change_indent_settings);

		D(DBF_Document, bug("done\n"););
	}

	void document_t::grammar_did_change ()
	{
		_buffer->set_grammar(bundles::lookup(_grammar->uuid())); // Preferably we’d pass _grammar to the buffer but then the buffer couldn’t get at the root scope and folding markers. Perhaps this should be exposed by grammar_t, but ideally the buffer itself would setup a callback to be notified about grammar changes. We only moved it to document_t because with a callback, buffer_t can’t get copy constructors for free.
	}

	void document_t::mark_pristine ()
	{
		assert(_buffer);
		_pristine_buffer = _buffer->substr(0, _buffer->size()); // TODO We should use a cheap ng::detail::storage_t copy
	}

	void document_t::post_load (NSString * path, NSData * content, std::map<NSString *, NSString *>  attributes, NSString * fileType, NSString * pathAttributes, OakFileEncodingType * encoding)
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

	void document_t::post_save (NSString * path, NSData * content, NSString * pathAttributes, OakFileEncodingType * encoding, bool success)
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

	encoding::type document_t::encoding_for_save_as_path (NSString * path)
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

	void document_t::try_save (document::save_callback_ptr callback)
	{
		struct save_callback_wrapper_t : file::save_callback_t
		{
			save_callback_wrapper_t (document::OakDocument * doc, document::save_callback_ptr callback, bool close) : _document(doc), _callback(callback), _close(close) { }

			void select_path (NSString * path, NSData * content, file::save_context_ptr context)                                     { _callback->select_path(path, content, context); }
			void select_make_writable (NSString * path, NSData * content, file::save_context_ptr context)                            { _callback->select_make_writable(path, content, context); }
			void obtain_authorization (NSString * path, NSData * content, OakAuthorization * auth, file::save_context_ptr context) { _callback->obtain_authorization(path, content, auth, context); }
			void select_charset (NSString * path, NSData * content, NSString * charset, file::save_context_ptr context)      { _callback->select_charset(path, content, charset, context); }

			void did_save (NSString * path, NSData * content, NSString * pathAttributes, OakFileEncodingType * encoding, bool success, NSString * message, NSUUID * filter)
			{
				_document->post_save(path, content, pathAttributes, encoding, success);
				_callback->did_save_document(_document, path, success, message, filter);
				if(_close)
					_document->close();
			}

		private:
			document::OakDocument * _document;
			document::save_callback_ptr _callback;
			bool _close;
		};

		D(DBF_Document, bug("save ‘%s’\n", _path.c_str()););

		bool closeAfterSave = false;
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

	bool document_t::save ()
	{
        try_save(callback);

		return res;
	}

	bool document_t::backup ()
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

	bool document_t::is_modified () const
	{
		return _modified;
	}

	void document_t::set_modified (bool flag)
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

	bool document_t::try_open (document::open_callback_ptr callback)
	{
		if(++_open_count == 1)
		{
			if(_backup_path != NULL_STR)
			{
				bool modified = _modified;
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

	void document_t::watch_callback (int flags, NSString * newPath, bool async)
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
				open_callback_t (document::OakDocument * doc, bool async) : _document(doc), _wait(!async) { }

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
						bool conflict = false;
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
				bool _wait;
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

	static ng::index_t cap (NSString *  buf, text::pos_t  pos)
	{
		NSUInteger line = OakCap<NSUInteger>(0, pos.line,   buf.lines()-1);
		NSUInteger col  = OakCap<NSUInteger>(0, pos.column, buf.eol(line) - buf.begin(line));
		ng::index_t res = buf.sanitize_index(buf.convert(text::pos_t(line, col)));
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

	scanner_t::scanner_t (NSString * path, path::glob_list_t  glob, bool follow_links, bool depth_first) : path(path), glob(glob), follow_links(follow_links), depth_first(depth_first), is_running_flag(true), should_stop_flag(false)
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
	
} /* document */
