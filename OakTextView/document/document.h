#ifndef DOCUMENT_H_MIJOONQT
#define DOCUMENT_H_MIJOONQT

#include <file/save.h>

@class OakDocumentWatch;
@class OakDocument;
@class OakFileOpenCallback;

@interface OakDocumentSaveCallback : OakFileSaveCallback

- (void)didSaveDocument: (OakDocument *) document
                 toPath: (NSString *) path
                success: (BOOL)success
                message: (NSString *) message
                 filter: (NSUUID *)filter;

- (void)didSaveToPath: (NSString *)path
              content: (NSData *)content
       pathAttributes: (NSString *)pathAttributes
             encoding: (OakFileEncodingType *)encoding
              success: (BOOL)success
              message: (NSString *)message
               filter: (NSUUID *)filter;

@end

#endif /* end of include guard: DOCUMENT_H_MIJOONQT */
