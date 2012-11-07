#import <oak/misc.h>

enum OakSoundIdentifier
{
	OakSoundDidMoveItemUISound,
	OakSoundDidTrashItemUISound,
	OakSoundDidCompleteSomethingUISound
};

extern void OakPlayUISound (OakSoundIdentifier aSound);
