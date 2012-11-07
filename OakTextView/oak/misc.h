#ifndef OAK_MISC_H_35H67VAO
#define OAK_MISC_H_35H67VAO

#ifndef sizeofA
#define sizeofA(a) (sizeof(a)/sizeof(a[0]))
#endif

#ifndef SQ
#define SQ(x) ((x)*(x))
#endif

#ifndef STRINGIFY
#define xSTRINGIFY(number) #number
#define STRINGIFY(number)  xSTRINGIFY(number)
#endif

#define  NULL_STR  ""
#include <map>
#include <vector>
#include <set>
#include <string>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <sys/xattr.h>

#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>

#endif /* end of include guard: OAK_MISC_H_35H67VAO */
