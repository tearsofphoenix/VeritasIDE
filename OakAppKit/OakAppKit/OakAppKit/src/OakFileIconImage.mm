#import "OakFileIconImage.h"
#import "NSImage+Additions.h"

#import <OakSCM/OakSCM.h>

#include <sys/stat.h>
// ========================
// = Obtain Various Icons =
// ========================

static NSUInteger OakPathRank(NSString * path, NSString * ext)
{
    NSUInteger rank = 0;
    
    NSUInteger pathLength = [path length];
    NSUInteger extLength = [ext length];
    
    if([path rangeOfString: ext
                   options: NSBackwardsSearch].location == pathLength - extLength)
    {
        char ch = [path UTF8String][pathLength - extLength - 1];
        if(ch == '.' || ch == '/' || ch == '_')
            rank = MAX(pathLength - extLength, rank);
    }
    return rank;
}


static NSImage* CustomIconForPath (NSString* path, struct stat  buf)
{
	if(!S_ISREG(buf.st_mode) && !S_ISLNK(buf.st_mode))
		return nil;

	NSMutableDictionary *ordering = [NSMutableDictionary dictionary];
    
	NSDictionary* bindings = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle bundleForClass: [OakFileIconImage class]] pathForResource: @"bindings"
                                                                                                                                       ofType: @"plist"]];
	for(NSString* key in bindings)
	{
		for(NSString* ext in bindings[key])
		{
            NSUInteger rank = OakPathRank(path, ext);
			if(rank)
            {
				[ordering setObject: key
                             forKey: @(rank)];
            }
		}
	}
	return [ordering count] == 0 ? nil : [NSImage imageNamed: [[ordering allValues] objectAtIndex: 0]
                                         inSameBundleAsClass: [OakFileIconImage class]];
}

static NSImage* IconBadgeForPath (NSString* path, struct stat  buf)
{
	IconRef iconRef;
	if(S_ISLNK(buf.st_mode) && GetIconRef(kOnSystemDisk, kSystemIconsCreator, kAliasBadgeIcon, &iconRef) == noErr)
	{
		NSImage* badge = [[[NSImage alloc] initWithIconRef:iconRef] autorelease];
		ReleaseIconRef(iconRef);
		return badge;
	}
	return nil;
}

static NSImage* SystemIconForPath (NSString* path, struct stat  buf)
{
	NSImage* image;
	return [[NSURL fileURLWithPath:path isDirectory:S_ISDIR(buf.st_mode)] getResourceValue:&image forKey:NSURLEffectiveIconKey error:NULL] ? image : [[NSWorkspace sharedWorkspace] iconForFile:path];
}

static NSImage* SystemIconForHFSType (OSType hfsFileTypeCode)
{
	return [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(hfsFileTypeCode)];
}

static NSImage* BadgeForSCMStatus (OakSCMStatus scmStatus)
{
	switch(scmStatus)
	{
		case OakSCMStatusConflicted:   return [NSImage imageNamed:@"Conflicted"  inSameBundleAsClass:[OakFileIconImage class]];
		case OakSCMStatusModified:     return [NSImage imageNamed:@"Modified"    inSameBundleAsClass:[OakFileIconImage class]];
		case OakSCMStatusAdded:        return [NSImage imageNamed:@"Added"       inSameBundleAsClass:[OakFileIconImage class]];
		case OakSCMStatusDeleted:      return [NSImage imageNamed:@"Deleted"     inSameBundleAsClass:[OakFileIconImage class]];
		case OakSCMStatusUnversioned:  return [NSImage imageNamed:@"Unversioned" inSameBundleAsClass:[OakFileIconImage class]];
		case OakSCMStatusMixed:        return [NSImage imageNamed:@"Mixed"       inSameBundleAsClass:[OakFileIconImage class]];
        default: return nil;
	}
	return nil;
}

// =================================
// = Create Image Stack for a Path =
// =================================

static NSArray* ImageStackForPath (NSString* path)
{
	NSMutableArray* res = [NSMutableArray array];
	if(!path)
		return @[ SystemIconForHFSType(kUnknownFSObjectIcon) ];

	struct stat buf;
	if(lstat([path fileSystemRepresentation], &buf) == 0)
	{
		if(NSImage* customImage = CustomIconForPath(path, buf))
		{
			[res addObject:customImage];
			if(NSImage* imageBadge = IconBadgeForPath(path, buf))
				[res addObject:imageBadge];
		}
		else if(NSImage* image = SystemIconForPath(path, buf))
		{
			[res addObject:image];
		}
	}

	if([res count] == 0)
    {
		[res addObject:SystemIconForHFSType(kUnknownFSObjectIcon)];
    }
    ///TODO: SCM status support
    //
//	if(auto scmDriver = scm::info([path stringByDeletingLastPathComponent]))
//	{
//		if(NSImage* scmStatusImage = BadgeForSCMStatus(scmDriver->status([path fileSystemRepresentation])))
//        {
//			[res addObject: scmStatusImage];
//        }
//	}

	return res;
}

// ===============================
// = Custom Image Representation =
// ===============================

@interface OakFileIconImageRep : NSImageRep
{
	NSString* path;
	BOOL isModified;
	NSArray* imageStack;
}

- (id)initWithPath: (NSString*)aPath
        isModified: (BOOL)flag;

@end

@implementation OakFileIconImageRep

- (id)initWithPath:(NSString*)aPath
        isModified: (BOOL)flag
{
	if((self = [super init]))
	{
		path = [aPath retain];
		isModified = flag;
	}
	return self;
}

- (id)copyWithZone:(NSZone*)zone
{
	OakFileIconImageRep* copy = [super copyWithZone:zone];
	copy->path       = [path retain];
	copy->isModified = isModified;
	copy->imageStack = [imageStack retain];
	return copy;
}

- (void)dealloc
{
	[path release];
	[imageStack release];
	[super dealloc];
}

- (BOOL)draw
{
	if(!imageStack)
		imageStack = [ImageStackForPath(path) retain];

	NSImage* buffer = nil;
	if(isModified)
	{
		buffer = [[[NSImage alloc] initWithSize:[self size]] autorelease];
		[buffer lockFocus];
	}

	NSCompositingOperation op = NSCompositeCopy;
	for(NSImage* image in imageStack)
	{
		[image drawInRect:(NSRect){ NSZeroPoint, self.size } fromRect:NSZeroRect operation:op fraction:1];
		op = NSCompositeSourceOver;
	}

	if(isModified)
	{
		[buffer unlockFocus];
		[buffer drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.4];
	}

	return YES;
}
@end

// ====================
// = OakFileIconImage =
// ====================

@implementation OakFileIconImage
- (id)initWithWithPath:(NSString*)aPath isModified:(BOOL)flag size:(NSSize)aSize
{
	if((self = [super initWithSize:aSize]))
	{
		[self addRepresentation:[[[OakFileIconImageRep alloc] initWithPath:aPath isModified:flag] autorelease]];
		[self setSize:aSize];
	}
	return self;
}

+ (id)fileIconImageWithPath:(NSString*)aPath isModified:(BOOL)flag size:(NSSize)aSize { return [[[self alloc] initWithWithPath:aPath isModified:flag size:aSize] autorelease]; }
+ (id)fileIconImageWithPath:(NSString*)aPath isModified:(BOOL)flag                    { return [self fileIconImageWithPath:aPath isModified:flag size:NSMakeSize(16, 16)]; }
+ (id)fileIconImageWithPath:(NSString*)aPath size:(NSSize)aSize                       { return [self fileIconImageWithPath:aPath isModified:NO size:aSize]; }
@end