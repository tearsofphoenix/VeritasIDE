

enum
{
	OakSoundDidMoveItemUISound,
	OakSoundDidTrashItemUISound,
	OakSoundDidCompleteSomethingUISound
};

typedef NSInteger OakSoundIdentifier;

extern void OakPlayUISound (OakSoundIdentifier aSound);
