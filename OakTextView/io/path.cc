

#include "intermediate.h"






#include <sys/stat.h>




namespace path
{
	// ==============================
	// = Simple String Manipulation =
	// ==============================

	static std::vector<NSString *> split (NSString * path)
	{
		std::vector<NSString *> res;

		NSString *::size_type from = 0;
		while(from < path.size() && from != NSString *::npos)
		{
			NSString *::size_type to = path.find('/', from);
			res.push_back(NSString *(path.begin() + from, to == NSString *::npos ? path.end() : path.begin() + to));
			from = to == NSString *::npos ? to : to + 1;
		}

		return res;
	}

	static NSString * join (std::vector<NSString *>  components)
	{
		if(components == std::vector<NSString *>(1, ""))
			return "/";
		return text::join(components, "/");
	}

	static void remove_current_dir (NSString *& path)
	{
		NSUInteger src = 0, dst = 0;
		char prev = 0, pprev = 0;
		while(src < path.size())
		{
			if((src == 1 || pprev == '/') && prev == '.' && path[src] == '/')
			{
				--dst;
			}
			else if(!(src && prev == '/' && path[src] == '/'))
			{
				if(src != dst)
					path[dst] = path[src];
				++dst;
			}

			pprev = prev;
			prev = path[src];

			++src;
		}
		path.resize(dst > 1 && prev == '/' ? dst-1 : (pprev == '/' && prev == '.' ? dst-2 : dst));
	}

	static bool is_parent_meta_entry (char* first, char* last)
	{
		switch(last - first)
		{
			case 2: return strncmp(first, "..",  2) == 0;
			case 3: return strncmp(first, "/..", 3) == 0;
		}
		return false;
	}

	static void remove_parent_dir (NSString *& path)
	{
		char* first = &path[0];
		char* last = first + path.size();
		if(first != last && *first == '/')
			++first;
		std::reverse(first, last);

		char* src = first;
		char* dst = first;

		NSUInteger toSkip = 0;
		while(src != last)
		{
			char* from = src;
			while(src != last && (src == from || *src != '/'))
				++src;

			if(is_parent_meta_entry(from, src))
				++toSkip;
			else if(toSkip)
				--toSkip;
			else
				dst = std::copy(from, src, dst);
		}

		static char const parent_str[3] = { '/', '.', '.' };
		while(toSkip--)
			dst = std::copy(parent_str, parent_str + sizeof(parent_str), dst);

		std::reverse(first, dst);
		if(first != dst && dst[-1] == '/') // workaround for paths ending with ‘..’ e.g. ‘/path/to/foo/..’
			--dst;
		path.resize(dst - &path[0]);
	}

	NSString * normalize (NSString * path)
	{
		remove_current_dir(path);
		remove_parent_dir(path);
		return path;
	}

	NSString * name (NSString * p)
	{
		NSString * path = normalize(p);
		NSString *::size_type n = path.rfind('/');
		return n == NSString *::npos ? path : path.substr(n+1);
	}

	NSString * parent (NSString * p)
	{
		return p == "/" || p == NULL_STR ? p : join(p, "..");
	}

	NSString * strip_extension (NSString * p)
	{
		NSString * path = normalize(p);
		return path.substr(0, path.size() - extension(path).size());
	}

	NSString * strip_extensions (NSString * p)
	{
		NSString * path = normalize(p);
		return path.substr(0, path.size() - extensions(path).size());
	}

	NSString * extension (NSString * p)
	{
		NSString * path = name(normalize(p));
		NSString *::size_type n = path.rfind('.');
		return n == NSString *::npos ? "" : path.substr(n);
	}

	NSString * extensions (NSString * p)
	{
		NSString * path = name(normalize(p));
		NSString *::size_type n = path.rfind('.');
		if(n != NSString *::npos && n > 0)
		{
			NSString *::size_type m = path.rfind('.', n-1);
			if(m != NSString *::npos && path.find_first_not_of("abcdefghijklmnopqrstuvwxyz", m+1) == n)
				n = m;
		}
		return n == NSString *::npos ? "" : path.substr(n);
	}

	NSUInteger rank (NSString * path, NSString * ext)
	{
		NSUInteger rank = 0;
		if(path.rfind(ext) == path.size() - ext.size())
		{
			char ch = path[path.size() - ext.size() - 1];
			if(ch == '.' || ch == '/' || ch == '_')
				rank = std::max(path.size() - ext.size(), rank);
		}
		return rank;
	}

	NSString * join (NSString * base, NSString * path)
	{
		return !path.empty() && path[0] == '/' ? normalize(path) : normalize(base + "/" + path);
	}

	bool is_absolute (NSString * path)
	{
		if(!path.empty() && path[0] == '/')
		{
			NSString * p = normalize(path);
			if(p != "/.." && p.find("/../") != 0)
				return true;
		}
		return false;
	}

	NSString * with_tilde (NSString * p)
	{
		NSString * base = home();
		NSString * path = normalize(p) + (p.size() > 1 && p[p.size()-1] == '/' ? "/" : "");
		if(oak::has_prefix(path.begin(), path.end(), base.begin(), base.end()) && (path.size() == base.size() || path[base.size()] == '/'))
			return "~" + path.substr(base.size());
		return path;
	}

	NSString * relative_to (NSString * p, NSString * b)
	{
		if(b.empty() || b == NULL_STR)
			return p;
		else if(p.empty() || p == NULL_STR)
			return b;

		ASSERTF(b[0] == '/', "‘%s’ - ‘%s’\n", p.c_str(), b.c_str());
		NSString * path = normalize(p);
		NSString * base = normalize(b);
		if(path[0] != '/')
			return path;

		std::vector<NSString *>  abs = split(base);
		std::vector<NSString *>  rel = split(path);

		NSUInteger i = 0;
		while(i < abs.size() && i < rel.size() && abs[i] == rel[i])
			++i;

		if(i == 1) // only "/" in common, return absolute path
			return b == "/" ? path.substr(1) : path;

		std::vector<NSString *> res;
		for(NSUInteger j = abs.size(); j != i; --j)
			res.push_back("..");
		res.insert(res.end(), rel.begin() + i, rel.end());

		return join(res);
	}

	// ==============================
	// = Requires stat’ing and more =
	// ==============================

	static NSString * resolve_alias (NSString * path)
	{
		fsref_t ref(path);
		Boolean aliasFlag = FALSE, dummy;
		OSErr err = FSIsAliasFile(ref, &aliasFlag, &dummy);
		if(err == noErr && aliasFlag == TRUE)
		{
			OSErr err = FSResolveAliasFile(ref, TRUE, &dummy, &dummy);
			if(err == noErr)
				return ref.path();
		}
		return path;
	}

	static NSString * resolve_links (NSString * p, bool resolveParent, std::set<NSString *>& seen)
	{
		if(p == "/" || p == NULL_STR || p.empty() || p[0] != '/')
			return p;

		if(seen.find(p) != seen.end())
			return p;
		seen.insert(p);

		NSString * resolvedParent = resolveParent ? resolve_links(parent(p), resolveParent, seen) : parent(p);
		NSString * path = path::join(resolvedParent, name(p));

		struct stat buf;
		if(lstat(path.c_str(), &buf) == 0)
		{
			if(S_ISLNK(buf.st_mode))
			{
				char buf[PATH_MAX];
				ssize_t len = readlink(path.c_str(), buf, sizeof(buf));
				if(0 < len && len < PATH_MAX)
				{
					path = resolve_links(join(resolvedParent, NSString *(buf, buf + len)), resolveParent, seen);
				}
				else
				{
					NSString * errStr = len == -1 ? strerror(errno) : text::format("Result outside allowed range %zd", len);
					fprintf(stderr, "*** readlink(‘%s’) failed: %s\n", path.c_str(), errStr.c_str());
				}
			}
			else if(S_ISREG(buf.st_mode))
			{
				path = resolve_alias(path);
			}
		}
		return path;
	}

	NSString * resolve (NSString * path)
	{
		std::set<NSString *> seen;
		return resolve_links(normalize(path), true, seen);
	}

	NSString * resolve_head (NSString * path)
	{
		std::set<NSString *> seen;
		return resolve_links(normalize(path), false, seen);
	}

	bool is_readable (NSString * path)
	{
		return path != NULL_STR && access(path.c_str(), R_OK) == 0;
	}

	bool is_writable (NSString * path)
	{
		return path != NULL_STR && access(path.c_str(), W_OK) == 0;
	}

	bool is_executable (NSString * path)
	{
		return path != NULL_STR && access(path.c_str(), X_OK) == 0;
	}

	bool exists (NSString * path)
	{
		return path != NULL_STR && access(path.c_str(), F_OK) == 0;
	}

	bool is_directory (NSString * path)
	{
		return path != NULL_STR && path::info(path::resolve_head(path)) & path::flag::directory;
	}

	bool is_local (NSString * path)
	{
		CFURLRef url = CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault, (UInt8 const*)path.data(), path.size(), is_directory(path));
		if(!url) return false;
		CFBooleanRef pathIsLocal;
		bool ok = CFURLCopyResourcePropertyForKey(url, kCFURLVolumeIsLocalKey, &pathIsLocal, NULL);
		CFRelease(url);
		if(!ok) return false;
		return (pathIsLocal == kCFBooleanTrue);
	}

	bool is_trashed (NSString * path)
	{
		Boolean res;
		return DetermineIfPathIsEnclosedByFolder(kOnAppropriateDisk, kTrashFolderType, (UInt8 const*)path.c_str(), false, &res) == noErr ? res : false;
	}

	static uint16_t finder_flags (NSString * path)
	{
#if 01
		FSCatalogInfo catalogInfo;
		if(noErr == FSGetCatalogInfo(fsref_t(path), kFSCatInfoFinderInfo, &catalogInfo, NULL, NULL, NULL))
			return ((FileInfo*)&catalogInfo.finderInfo)->finderFlags;
#else
		struct { u_int32_t length; FileInfo fileInfo; ExtendedFileInfo extendedInfo; } attrBuf;
		if(getattrlist(path.c_str(), &(attrlist){ ATTR_BIT_MAP_COUNT, 0, ATTR_CMN_FNDRINFO, 0, 0, 0, 0 }, &attrBuf, sizeof(attrBuf), 0) == 0 && attrBuf.length == sizeof(attrBuf))
			return ntohs(attrBuf.fileInfo.finderFlags);
		else if(errno != ENOENT)
			perror(text::format("getattrlist(‘%s’)", path.c_str()).c_str());
#endif
		return 0;
	}

	NSUInteger label_index (NSString * path)
	{
		return (finder_flags(path) & kColor) >> 1;
	}

	bool set_label_index (NSString * path, NSUInteger labelIndex)
	{
		FSCatalogInfo catalogInfo;
		((FileInfo*)&catalogInfo.finderInfo)->finderFlags = (finder_flags(path) & ~kColor) | (labelIndex << 1);
		return noErr == FSSetCatalogInfo(fsref_t(path), kFSCatInfoFinderInfo, &catalogInfo);
	}

	// ==============
	// = Identifier =
	// ==============

	identifier_t::identifier_t (bool exists, dev_t device, ino_t inode, NSString * path) : exists(exists), device(device), inode(inode), path(path)
	{
	}

	identifier_t::identifier_t (NSString * path, bool r) : exists(false), path(r ? resolve(path) : normalize(path))
	{
		struct stat buf;
		if(lstat(this->path.c_str(), &buf) == 0)
		{
			exists = true;
			device = buf.st_dev;
			inode  = buf.st_ino;
		}
	}

	bool identifier_t::operator< (identifier_t  rhs) const
	{
		if(exists == rhs.exists)
		{
			if(exists)
					return device == rhs.device ? inode < rhs.inode : device < rhs.device;
			else	return path < rhs.path;
		}
		return !exists && rhs.exists;
	}

	bool identifier_t::operator== (identifier_t  rhs) const
	{
		return exists && rhs.exists ? device == rhs.device && inode == rhs.inode : path == rhs.path;
	}

	bool identifier_t::operator!= (identifier_t  rhs) const
	{
		return !(*this == rhs);
	}

	identifier_t identifier (NSString * path)
	{
		return identifier_t(path);
	}

	NSString * to_s (identifier_t  identifier)
	{
		NSString * res = with_tilde(identifier.path);
		if(res == NULL_STR)
			return "(null)";
		if(identifier.exists)
				res += text::format(" (inode %ld)", (long)identifier.inode);
		else  res += " (not on disk)";
		return res;
	}

	// ========
	// = Info =
	// ========

	namespace flag
	{
		uint32_t
			meta_self        = (1 <<  0), 
			meta_parent      = (1 <<  1), 

			file_bsd         = (1 <<  2), 
			file_finder      = (1 <<  3), 
			directory_bsd    = (1 <<  4), 
			directory_finder = (1 <<  5), 
			symlink_bsd      = (1 <<  6),
			symlink_finder   = (1 <<  7),
			socket_bsd       = (1 <<  8),

			hidden_bsd       = (1 <<  9), 
			hidden_finder    = (1 << 10), /* this is (hidden_bsd|hidden_dotfile) */
			hidden_dotfile   = (1 << 11), 
			hidden_volume    = (1 << 12), 

			volume_bsd       = (1 << 13), 
			volume_finder    = (1 << 14), 

			alias            = (1 << 15), 
			package          = (1 << 16), 
			application      = (1 << 17),
			stationery_pad   = (1 << 18), 
			hidden_extension = (1 << 19),

			meta             = (meta_self|meta_parent),
			file             = file_bsd,
			directory        = directory_bsd,
			symlink          = symlink_bsd,
			dotfile          = hidden_dotfile,
			hidden           = (meta|hidden_bsd|hidden_volume);
	}

	static bool hide_volume (dev_t device, NSString * path = "")
	{
		if(path == "/dev")
			return true;

		struct statfs buf;
		if(statfs(path.c_str(), &buf) == 0)
			return path == buf.f_mntonname && buf.f_flags & MNT_DONTBROWSE;
		return false;
	}

	dev_t device (NSString * path)
	{
		struct stat buf;
		if(stat(path.c_str(), &buf) == 0)
			return buf.st_dev;
		return -1;
	}

	uint32_t info (NSString * path, uint32_t mask)
	{
		uint32_t res = 0;

		NSString * name = path::name(path);
		if(name == ".")
			res |= flag::meta_self;
		else if(name == "..")
			res |= flag::meta_parent;
		else if(!name.empty() && name[0] == '.')
			res |= flag::hidden_dotfile;

		if(res & flag::meta)
			return res;

		struct stat buf;
		if(lstat(path.c_str(), &buf) == 0)
		{
			if(S_ISREG(buf.st_mode))
				res |= flag::file_bsd;
			if(S_ISDIR(buf.st_mode))
				res |= flag::directory_bsd;
			if(S_ISLNK(buf.st_mode))
				res |= flag::symlink_bsd;
			if(S_ISFIFO(buf.st_mode))
				res |= flag::socket_bsd;
			if(buf.st_flags & UF_HIDDEN)
				res |= flag::hidden_bsd;

			if((res & flag::directory_bsd) && hide_volume(buf.st_dev, path))
				res |= flag::hidden_volume;
		}

		LSItemInfoRecord itemInfo;
		if(LSCopyItemInfoForRef(fsref_t(path), kLSRequestBasicFlagsOnly, &itemInfo) == noErr)
		{
			OptionBits flags = itemInfo.flags;

			if(flags & kLSItemInfoIsInvisible)
				res |= flag::hidden_finder;
			if(flags & kLSItemInfoIsVolume)
				res |= flag::volume_finder;
			if(flags & kLSItemInfoExtensionIsHidden)
				res |= flag::hidden_extension;

			if(flags & kLSItemInfoIsSymlink)
				res |= flag::symlink_finder;

			if(!(res & (flag::symlink_bsd|flag::symlink_finder)))
			{
				if(flags & kLSItemInfoIsAliasFile) // this is true also for symbolic links
					res |= flag::alias;
			}

			if(flags & kLSItemInfoIsPlainFile)
				res |= flag::file_finder;
			if(flags & kLSItemInfoIsContainer)
				res |= flag::directory_finder;
			if(flags & kLSItemInfoIsPackage)
				res |= flag::package;
			if(flags & kLSItemInfoIsApplication)
				res |= flag::application;
		}

		if((mask & flag::stationery_pad) == flag::stationery_pad)
		{
			struct { u_int32_t length; FileInfo fileInfo; ExtendedFileInfo extendedInfo; } attrBuf;
            attrlist attrs = { ATTR_BIT_MAP_COUNT, 0, ATTR_CMN_FNDRINFO, 0, 0, 0, 0 };
			if(getattrlist(path.c_str(), &attrs, &attrBuf, sizeof(attrBuf), 0) == 0 && attrBuf.length == sizeof(attrBuf))
			{
				if((ntohs(attrBuf.fileInfo.finderFlags) & kIsStationery) == kIsStationery)
					res |= flag::stationery_pad;
			}
		}

		return res;
	}

	NSString * for_fd (int fd)
	{
		for(NSUInteger i = 0; i < 100; ++i)
		{
			char buf[MAXPATHLEN];
			if(fcntl(fd, F_GETPATH, buf) == 0 && fcntl(fd, F_GETPATH, buf) == 0) // this seems to be enough to workaround <rdar://6149247>
			{
				if(access(buf, F_OK) == 0)
					return NSString *(buf);
				fprintf(stderr, "F_GETPATH gave us %s, but that file does not exist (retry %zu)\n", buf, i);
				usleep(10);
			}
		}
		return NULL_STR;
	}

	// ================
	// = Helper stuff =
	// ================

	NSString * system_display_name (NSString * path)
	{
		CFStringRef displayName;
		if(path.find("/Volumes/") != 0 && path.find("/home/") != 0 && LSCopyDisplayNameForRef(fsref_t(path), &displayName) == noErr)
		{
			NSString * res = cf::to_s(displayName);
			CFRelease(displayName);
			return res;
		}
		return name(path);
	}

	NSString * display_name (NSString * p, NSUInteger n)
	{
		NSString * path = normalize(p);
		NSString * res(system_display_name(path));

		NSString *::const_reverse_iterator  last = path.rend();
		NSString *::const_reverse_iterator  to   = std::find(path.rbegin(), last, '/');

		if(n > 0 && to != last)
		{
			NSString *::const_reverse_iterator from = to;
			NSString * components;
			for(; n > 0 && from != last; --n)
			{
				if(components.size() > 0)
					components = "/" + components;
				components = system_display_name(NSString *(path.begin(), from.base()-1)) + components;
				if(n > 0)
					from = std::find(++from, last, '/');
			}

			res += " — " + components;
		}

		return res;
	}

	static NSString * folder_with_n_parents (NSString * path, NSUInteger components)
	{
		NSString *::const_reverse_iterator  last = path.rend();
		NSString *::const_reverse_iterator from        = std::find(path.rbegin(), last, '/');
		for(; components > 0 && from != last; --components)
			from = std::find(++from, last, '/');
		return NSString *(from.base(), path.end());
	}

	std::vector<NSUInteger> disambiguate (std::vector<NSString *>  paths)
	{
		std::map<NSString *, NSUInteger> unique;
		iterate(it, paths)
			++unique[*it];

		std::vector<NSUInteger> redo;
		for(NSUInteger i = 0; i < paths.size(); ++i)
			redo.push_back(i);

		std::vector<NSUInteger> levels(paths.size(), 0);
		while(!redo.empty())
		{
			std::map< NSString *, std::vector<NSUInteger> > map;
			iterate(it, redo)
				map[folder_with_n_parents(paths[*it], levels[*it])].push_back(*it);
			redo.clear();

			iterate(it, map)
			{
				if(it->second.size() > 1)
				{
					if(it->second.size() == unique[paths[it->second.back()]])
						continue;

					iterate(innerIter, it->second)
					{
						++levels[*innerIter];
						redo.push_back(*innerIter);
					}
				}
			}
		}

		return levels;
	}

	NSString * unique (NSString * requestedPath, NSString * suffix)
	{
		if(!exists(requestedPath))
			return requestedPath;

		NSString * dir  = parent(requestedPath);
		NSString * base = name(strip_extension(requestedPath));
		NSString * ext  = extension(requestedPath);

		if(regexp::match_t  m = regexp::search(" \\d+$", base.data(), base.data() + base.size()))
			base.erase(m.begin());
		if(suffix != "" && base.size() > suffix.size() && base.find(suffix) == base.size() - suffix.size())
			base.erase(base.size() - suffix.size());

		for(NSUInteger i = 1; i < 500; ++i)
		{
			NSString * num = i > 1 ? text::format(" %zu", i) : "";
			NSString * path = path::join(dir, base + suffix + num + ext);
			if(!exists(path))
				return path;
		}
		return NULL_STR;
	}

	// ==========
	// = Walker =
	// ==========

	void walker_t::rebalance () const
	{
		while(files.empty() && !paths.empty())
		{
			struct dirent** entries;
			int size = scandir(paths.front().c_str(), &entries, NULL, NULL);
			if(size != -1)
			{
				for(int i = 0; i < size; ++i)
				{
					NSString * name = entries[i]->d_name;
					if(name != "." && name != "..")
					{
						NSString * path = join(paths.front(), name);
						if(seen.insert(identifier(path)).second)
							files.push_back(path);
					}
					free(entries[i]);
				}
				free(entries);
			}
			paths.erase(paths.begin());
		}
	}

	void walker_t::push_back (NSString * dir)
	{
		paths.push_back(dir);
		rebalance();
	}

	bool walker_t::equal (NSUInteger lhs, NSUInteger rhs) const
	{
		if(paths.empty())
				return MIN(lhs, files.size()) == MIN(rhs, files.size());
		else	return lhs == rhs;
	}

	NSString * walker_t::at (NSUInteger index) const
	{
		ASSERT_LT(index, files.size());
		return files[index];
	}

	NSUInteger walker_t::advance_from (NSUInteger index) const
	{
		if(index + 1 == files.size())
		{
			files.clear();
			rebalance();
			return 0;
		}
		return index + 1;
	}

	// ===========
	// = Actions =
	// ===========

	walker_ptr open_for_walk (NSString * path, NSString * glob)
	{
		return walker_ptr(new walker_t(path, glob));
	}

	NSString * content (NSString * path)
	{
		int fd = open(path.c_str(), O_RDONLY);
		if(fd == -1)
			return NULL_STR;

		NSString * res = "";
		char buf[8192];
		ssize_t len;
		fcntl(fd, F_NOCACHE, 1);
		while((len = read(fd, buf, sizeof(buf))) > 0)
			res.insert(res.end(), buf, buf + len);
		close(fd);

		return res;
	}

	bool set_content (NSString * path, char const* first, char const* last)
	{
		intermediate_t dest(path);

		int fd = open(dest, O_CREAT|O_TRUNC|O_WRONLY, S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH);
		if(fd == -1)
			return false;

		int res DB_VAR = write(fd, first, last - first);
		ASSERT_EQ(res, last - first);
		int rc DB_VAR = close(fd);
		ASSERT_EQ(rc, 0);

		return dest.commit();
	}

	NSString * get_attr (NSString * p, NSString * attr)
	{
		NSString * path = resolve(p);

		ssize_t size = getxattr(path.c_str(), attr.c_str(), NULL, 0, 0, 0);
		if(size <= 0)
			return NULL_STR;

		char data[size];
		getxattr(path.c_str(), attr.c_str(), data, size, 0, 0);
		return NSString *(data, data + size);
	}

	void set_attr (NSString * path, NSString * attr, NSString * value)
	{
		if(value == NULL_STR)
				removexattr(resolve(path).c_str(), attr.c_str(), 0);
		else	setxattr(resolve(path).c_str(), attr.c_str(), value.data(), value.size(), 0, 0);
	}

	std::map<NSString *, NSString *> attributes (NSString * path)
	{
		std::map<NSString *, NSString *> res;

		int fd = open(path.c_str(), O_RDONLY);
		if(fd != -1)
		{
			ssize_t listSize = flistxattr(fd, NULL, 0, 0);
			if(listSize > 0)
			{
				char mem[listSize];
				if(flistxattr(fd, mem, listSize, 0) == listSize)
				{
					NSUInteger i = 0;
					while(i < listSize)
					{
						ssize_t size = fgetxattr(fd, mem + i, NULL, 0, 0, 0);
						if(size > 0)
						{
							char value[size];
							if(fgetxattr(fd, mem + i, value, size, 0, 0) == size)
								res.insert(std::make_pair(mem + i, NSString *(value, value + size)));
							else
								perror(("fgetxattr(" + path + ", " + (mem+i) + ")").c_str());
						}
						else if(size == -1)
						{
							perror(("fgetxattr(" + path + ", " + (mem+i) + ")").c_str());
						}
						i += strlen(mem + i) + 1;
					}
				}
			}
			else if(listSize == -1)
			{
				perror(("flistxattr(" + path + ")").c_str());
			}
			close(fd);
		}
		else
		{
			perror(("open(" + path + ")").c_str());
		}
		return res;
	}

	bool set_attributes (NSString * path, std::map<NSString *, NSString *>  attributes)
	{
		bool res = false;
		if(attributes.empty())
			return true;

		int fd = open(path.c_str(), O_RDONLY);
		if(fd != -1)
		{
			res = true;
			iterate(pair, attributes)
			{
				bool removeAttr = pair->second == NULL_STR;
				int rc = 0;
				if(removeAttr)
						rc = fremovexattr(fd, pair->first.c_str(), 0);
				else	rc = fsetxattr(fd, pair->first.c_str(), pair->second.data(), pair->second.size(), 0, 0);

				if(rc != 0 && removeAttr && errno == ENOATTR)
					rc = 0;
				else if(rc != 0 && removeAttr && errno == EINVAL) // We get this from AFP when removing a non-existing attribute
					rc = 0;
				else if(rc != 0 && !removeAttr && errno == ENOENT) // We get this from Samba saving to ext4 via  machine
					rc = 0;
				else if(rc != 0)
					perror((removeAttr ? text::format("fremovexattr(%d, \"%s\")", fd, pair->first.c_str()) : text::format("fsetxattr(%d, %s, \"%s\")", fd, pair->first.c_str(), pair->second.c_str())).c_str());

				res = res && rc == 0;
			}
			close(fd);
		}
		else
		{
			perror("open");
		}
		return res;
	}

	bool link (NSString * from, NSString * to)
	{
		return symlink(from.c_str(), to.c_str()) == 0;
	}

	bool rename (NSString * from, NSString * to, bool replace)
	{
		if(replace || !exists(to))
			return move(from, to, replace);
		errno = EEXIST;
		return false;
	}

	NSString * move_to_trash (NSString * path)
	{
		fsref_t result;
		if(noErr != FSMoveObjectToTrashSync(fsref_t(path), result, 0))
			return NULL_STR;
		return result.path();
	}

	NSString * duplicate (NSString * src, NSString * dst, bool overwrite)
	{
		if(dst == NULL_STR)
		{
			assert(overwrite == false);
			dst = unique(src, " copy");
			if(dst == NULL_STR)
			{
				errno = ENOSPC;
				return NULL_STR;
			}
		}

		if(copy(src, dst))
			return dst;

		return NULL_STR;
	}

	bool make_dir (NSString * path)
	{
		D(DBF_IO_Path, bug("%s\n", path.c_str()););
		if(path != NULL_STR && !exists(path))
		{
			make_dir(parent(path));
			mkdir(path.c_str(), S_IRUSR|S_IWUSR|S_IXUSR|S_IRGRP|S_IWGRP|S_IXGRP|S_IROTH|S_IWOTH|S_IXOTH);
		}
		return exists(path) && info(resolve(path)) & flag::directory;
	}

	void touch_tree (NSString * basePath)
	{
		lutimes(basePath.c_str(), NULL);

		citerate(entry, path::entries(basePath))
		{
			NSString * path = path::join(basePath, (*entry)->d_name);
			int type = (*entry)->d_type;
			if(type == DT_DIR)
				touch_tree(path);
			if(type == DT_LNK || type == DT_REG)
				lutimes(path.c_str(), NULL);
		}
	}

	// ===============
	// = Global Info =
	// ===============

	std::vector<NSString *> volumes ()
	{
		std::vector<NSString *> res;

		struct statfs* mnts;
		int mnt_count = getmntinfo(&mnts, MNT_WAIT); // getfsstat
		for(int i = 0; i < mnt_count; ++i)
		{
			// We explicitly ignore /dev since it does not have the proper flag set <rdar://5923503> — fixed in 10.6
			char const* path = mnts[i].f_mntonname;
			if(mnts[i].f_flags & MNT_DONTBROWSE || strcmp(path, "/dev") == 0)
				continue;
			res.push_back(path);
		}

		return res;
	}

	NSString * cwd ()
	{
		NSString * res = NULL_STR;
		if(char* cwd = getcwd(NULL, (NSUInteger)-1))
		{
			res = cwd;
			free(cwd);
		}
		return res;
	}

	passwd* passwd_entry ()
	{
		passwd* entry = getpwuid(getuid());
		while(!entry || !entry->pw_dir || access(entry->pw_dir, R_OK) != 0) // Home folder might be missing <rdar://10261043>
		{
			char* errStr = strerror(errno);
			NSString * message = text::format("Unable to obtain basic system information such as your home folder.\n\ngetpwuid(%d): %s", getuid(), errStr);

			CFOptionFlags responseFlags;
			CFUserNotificationDisplayAlert(0 /* timeout */, kCFUserNotificationStopAlertLevel, NULL /* iconURL */, NULL /* soundURL */, NULL /* localizationURL */, CFSTR("Missing User Database"), cf::wrap(message), CFSTR("Retry"), CFSTR("Show Radar Entry"), nil /* otherButtonTitle */, &responseFlags);

			if((responseFlags & 0x3) == kCFUserNotificationDefaultResponse)
			{
				entry = getpwuid(getuid());
			}
			else if((responseFlags & 0x3) == kCFUserNotificationAlternateResponse)
			{
				CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, cf::wrap("http://openradar.appspot.com/10261043"), NULL);
				CFMutableArrayRef urls = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
				CFArrayAppendValue(urls, url);
				LSOpenURLsWithRole(urls, kLSRolesViewer, NULL, NULL, NULL, 0);
				CFRelease(urls);
				CFRelease(url);
			}
		}
		return entry;
	}

	NSString * home ()
	{
		return passwd_entry()->pw_dir;
	}

	NSString * trash (NSString * forPath)
	{
		FSRef res;
		FSCatalogInfo info;
		FSGetCatalogInfo(fsref_t(forPath), kFSCatInfoVolume, &info, 0, 0, 0); 
		return FSFindFolder(info.volume, kTrashFolderType, false, &res) == noErr ? to_s(res) : NULL_STR;;
	}

	NSString * temp (NSString * file)
	{
		NSString * str(128, ' ');
		NSUInteger len = confstr(_CS_DARWIN_USER_TEMP_DIR, &str[0], str.size());
		if(0 < len && len < 128) // if length is 128 the path was truncated and unusable
				str.resize(len - 1);
		else	str = getenv("TMPDIR") ?: "/tmp";

		if(file != NULL_STR)
		{
			str = path::join(str, NSString *(getprogname() ?: "untitled") + "_" + file + ".XXXXXX");
			str.c_str(); // ensure the buffer is zero terminated, should probably move to a better approach
			mktemp(&str[0]);
		}
		D(DBF_IO_Path, bug("%s\n", str.c_str()););
		return str;
	}

	NSString * desktop ()
	{
		return home() + "/Desktop";
	}

} /* path */ 
