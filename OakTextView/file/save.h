@class OakBundleCommand;
@class OakAuthorization;
@class OakFileEncodingType;

@protocol OakFileSaveContext<NSObject>

@property (nonatomic, retain) NSString *path;

@property (nonatomic, getter=isWritable) BOOL writable;

@property (nonatomic, retain) OakAuthorization *authorization;

@property (nonatomic, retain) NSString *charset;

- (void)filterCommand: (OakBundleCommand *)command
           returnCode: (int)rc
                ouput: (NSString *)outPut
                error: (NSString *)err;
@end

@interface OakFileSaveCallback : NSObject


- (void)selectPath: (NSString *)path
           content: (NSData *)content
           context: (id<OakFileSaveContext>)context;

- (void)selectMakeWritableForPath: (NSString *)path
                          content: (NSData *)content
                          context: (id<OakFileSaveContext>)context;

- (void)obtainAuthorizationForPath: (NSString *)path
                           content: (NSData *)content
                     authorization: (OakAuthorization *)authorization
                           context: (id<OakFileSaveContext>)context;
- (void)selectCharsetForPath: (NSString *)path
                     content: (NSData *)content
                     charset: (NSString *)charset
                     context: (id<OakFileSaveContext>)context;

- (void)didSaveToPath: (NSString *)path
              content: (NSData *)content
       pathAttributes: (NSString *)pathAttributes
             encoding: (OakFileEncodingType *)encoding
              success: (BOOL)success
              message: (NSString *)message
               filter: (NSUUID *)filter;

@end

extern void OakFileSave(NSString *path,
                        OakFileSaveCallback *cb,
                        OakAuthorization *auth,
                        NSData * content,
                        NSDictionary * attributes,
                        NSString * fileType,
                        OakFileEncodingType * encoding,
                        NSArray * binaryImportFilters,
                        NSArray *textImportFilters);

