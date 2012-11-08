#import "OakSound.h"
#import <AudioToolbox/AudioToolbox.h>

void OakPlayUISound (OakSoundIdentifier aSound)
{
	struct sound_info_t
	{
		OakSoundIdentifier name;
		NSString * path;
		bool initialized;
		SystemSoundID sound;
	};

	static sound_info_t sounds[] =
	{
		{ OakSoundDidTrashItemUISound,         @"dock/drag to trash.aif"   },
		{ OakSoundDidMoveItemUISound,          @"system/Volume Mount.aif"  },
		{ OakSoundDidCompleteSomethingUISound, @"system/burn complete.aif" }
	};

	for(NSUInteger i = 0; i < sizeof(sounds) / sizeof(sounds[0]); ++i)
	{
		if(sounds[i].name == aSound)
		{
			if(!sounds[i].initialized)
			{
				NSString * path_10_6 = [@"/System/Library/Components/CoreAudio.component/Contents/Resources/SystemSounds" stringByAppendingPathComponent: sounds[i].path];
				NSString * path_10_7 = [@"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds" stringByAppendingPathComponent: sounds[i].path];
				NSString * path = ([[NSFileManager defaultManager] fileExistsAtPath: path_10_7]) ? path_10_7 : path_10_6;

				CFURLRef url = CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault, (UInt8 const*)[path UTF8String], [path length], false);
				AudioServicesCreateSystemSoundID(url, &sounds[i].sound);
				CFRelease(url);
				sounds[i].initialized = true;
			}

			if(sounds[i].sound)
            {
				AudioServicesPlaySystemSound(sounds[i].sound);
            }
            
			break;
		}
	}
}
