#ifndef DOCUMENT_COLLECTION_LNUANNO
#define DOCUMENT_COLLECTION_LNUANNO

#include "document.h"
#include <oak/misc.h>
#import <OakFoundation/OakFoundation.h>

	extern NSUUID * kCollectionNew;
	extern NSUUID * kCollectionCurrent;

	extern void show (OakDocument * document, NSUUID * collection, OakTextRange * selection, bool bringToFront);
    
	extern void show (NSArray *documents);

	extern void show_browser (NSString * path);

	extern NSDictionary *variables (OakDocument * document, NSUUID * collection, NSMutableDictionary *env);

#endif /* end of include guard: DOCUMENT_COLLECTION_LNUANNO */
