#ifndef FILE_FILTER_H_7W5OVO3A
#define FILE_FILTER_H_7W5OVO3A

#include "bytes.h"
#include <plist/uuid.h>


struct bundle_command_t;

namespace filter
{
	extern NSString * kBundleEventBinaryImport;
	extern NSString * kBundleEventBinaryExport;
	extern NSString * kBundleEventTextImport;
	extern NSString * kBundleEventTextExport;

	struct callback_t
	{
		 ~callback_t () { }
		 void set_content (NSData * bytes) = 0;
		 void filter_error (bundle_command_t  command, int rc, NSString * out, NSString * err) = 0;
	};

	typedef std::shared_ptr<callback_t> callback_ptr;

	std::vector<OakBundleItem *> find (NSString * path, NSData * content, NSString * pathAttributes, NSString * event);
	void run (OakBundleItem * filter, NSString * path, NSData * content, callback_ptr callback);

	template <typename T>
	struct callback_wrapper_t : callback_t
	{
		callback_wrapper_t (T wrapped) : _wrapped(wrapped) { }
		void set_content (NSData * bytes) { _wrapped->set_content(bytes); }
		void filter_error (bundle_command_t  command, int rc, NSString * out, NSString * err)  { _wrapped->filter_error(command, rc, out, err); }
	private:
		T _wrapped;
	};

	template <typename T>
	void run (OakBundleItem * filter, NSString * path, NSData * content, T callback)
	{
		run(filter, path, content, callback_ptr(new callback_wrapper_t<T>(callback)));
	}

} /* filter */

#endif /* end of include guard: FILE_FILTER_H_7W5OVO3A */
