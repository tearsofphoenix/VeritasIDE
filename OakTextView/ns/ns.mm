#import "ns.h"


#import <text/utf8.h>

static NSString * string_for (CGKeyCode key, CGEventFlags flags)
{
	CGEventRef event = CGEventCreateKeyboardEvent(NULL, key, true);
	CGEventSetFlags(event, flags);
	NSString * tmp = to_s([[NSEvent eventWithCGEvent:event] characters]);

	NSString * res = tmp;
	citerate(str, diacritics::make_range(tmp.data(), tmp.data() + tmp.size()))
    {
		res = NSString *(&str, &str + str.length());
    }
    
	CFRelease(event);
	return res == "" ? NULL_STR : res;
}

static NSString * string_for (CGEventFlags flags)
{
	static struct EventFlag_t { CGEventFlags flag; NSString * symbol; } const EventFlags[] =
	{
		{ kCGEventFlagMaskNumericPad, @"#" },
		{ kCGEventFlagMaskControl,    @"^" },
		{ kCGEventFlagMaskAlternate,  @"~" },
		{ kCGEventFlagMaskShift,      @"$" },
		{ kCGEventFlagMaskCommand,    @"@" }
	};

	NSMutableString * res = [NSMutableString string];
	for(NSUInteger i = 0; i < sizeofA(EventFlags); ++i)
    {
		[res appendString: (flags & EventFlags[i].flag) ? EventFlags[i].symbol : @""];
    }
    
	return res;
}

static bool is_ascii (NSString * str)
{
	char ch = str.size() == 1 ? str[0] : 0;
	return 0x20 < ch && ch < 0x7F;
}

/*
	The “simple” heuristic is the following:

		Always treat ⌃ as literal modifier
		Remove numpad modifier unless key is among what is on standard numpad (incl. comma)
		if ⌘ changes key (Qwerty-Dvorak ⌘ hybrid):
			if ⌥ is down: treat ⌥ as literal
			if ⇧ is down and (changed) key is not a-z: treat ⇧ as literal else if key is a-z: upcase key string
		else
			If ⌥ is down and character (with flags & ⌥⇧) is non-ASCII or if ⌥ doesn’t affect key string: treat ⌥ as literal
			if ⇧ is down and character (with flags & ⌥⇧) is non-ASCII or if ⇧ doesn’t affect key string, treat ⇧ as literal else if key is a-z: upcase key string
		end if
*/

NSString * to_s (NSEvent* anEvent, bool preserveNumPadFlag)
{
	CGEventRef cgEvent = [anEvent CGEvent];
	CGKeyCode key      = (CGKeyCode)[anEvent keyCode];
	CGEventFlags flags = CGEventGetFlags(cgEvent);
	flags &= kCGEventFlagMaskCommand | kCGEventFlagMaskShift | kCGEventFlagMaskAlternate | kCGEventFlagMaskControl | kCGEventFlagMaskNumericPad;

	NSString * keyString              = NULL_STR;
	NSString * keyStringNoFlags = string_for(key, 0);
	CGEventFlags newFlags              = flags & (kCGEventFlagMaskControl|kCGEventFlagMaskCommand);
	flags &= ~kCGEventFlagMaskControl;

	if(flags & kCGEventFlagMaskNumericPad)
	{
		static NSString * numPadKeys = "0123456789=/*-+.,";
		if(preserveNumPadFlag && numPadKeys.find(keyStringNoFlags) != NSString *::npos)
			newFlags |= kCGEventFlagMaskNumericPad;
		flags &= ~kCGEventFlagMaskControl;
	}

	NSString * keyStringCommand = string_for(key, kCGEventFlagMaskCommand);
	if((flags & kCGEventFlagMaskCommand) && keyStringNoFlags != keyStringCommand)
	{
		D(DBF_NSEvent, bug("command (⌘) changes key\n"););

		newFlags |= flags & kCGEventFlagMaskAlternate;
		flags    &= ~kCGEventFlagMaskAlternate;

		if(flags & kCGEventFlagMaskShift)
		{
			if(keyStringCommand.size() == 1 && isalpha(keyStringCommand[0]))
			{
				D(DBF_NSEvent, bug("manually upcase key\n"););
				keyString = NSString *(1, toupper(keyStringCommand[0]));
			}
			else
			{
				D(DBF_NSEvent, bug("shift (⇧) is literal\n"););
				newFlags |= kCGEventFlagMaskShift;
			}
		}
	}
	else
	{
		if(flags & kCGEventFlagMaskAlternate)
		{
			NSString * keyStringAlternate = string_for(key, flags & (kCGEventFlagMaskAlternate|kCGEventFlagMaskShift));
			if(!is_ascii(keyStringAlternate) || keyStringNoFlags == keyStringAlternate)
			{
				D(DBF_NSEvent, bug("option (⌥) is literal\n"););
				newFlags |= kCGEventFlagMaskAlternate;
				flags    &= ~kCGEventFlagMaskAlternate;
			}
		}

		if(flags & kCGEventFlagMaskShift)
		{
			NSString * keyStringShift = string_for(key, flags & (kCGEventFlagMaskAlternate|kCGEventFlagMaskShift));
			if(!is_ascii(keyStringShift) || keyStringNoFlags == keyStringShift)
			{
				D(DBF_NSEvent, bug("shift (⇧) is literal\n"););
				newFlags |= kCGEventFlagMaskShift;
				flags    &= ~kCGEventFlagMaskShift;
			}
			else
			{
				D(DBF_NSEvent, bug("use NSEvent’s uppercased version\n"););
				keyString = keyStringShift;
			}
		}
	}

	return string_for(newFlags) + (keyString == NULL_STR ? string_for(key, flags) : keyString);
}
