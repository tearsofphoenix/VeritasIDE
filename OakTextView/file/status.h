#ifndef FILE_STATUS_H_CIXQCEQO
#define FILE_STATUS_H_CIXQCEQO

#include <oak/misc.h>

enum file_status_t
{
	kFileTestWritable,
	kFileTestWritableByRoot,
	kFileTestNotWritable,
	kFileTestNotWritableButOwner,
	kFileTestNoParent,
	kFileTestReadOnly,
	kFileTestUnhandled,
};

namespace file
{
	extern file_status_t status (NSString * path);

} /* file */

#endif /* end of include guard: FILE_STATUS_H_CIXQCEQO */
