#include "document.h"
#include "merge.h"

#import <OakSCM/OakSCM.h>

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

