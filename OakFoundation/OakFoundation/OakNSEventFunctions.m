#import "OakNSEventFunctions.h"
#import "OakFileEncodingType.h"

static NSString * glyph_named (NSString * name)
{
	static struct
    {
        NSString * name;
        NSString * glyph;
        
    } const KeyGlyphs[] =
	{
		{ @"pb_enter",     @"⌤" },
        
		{ @"left",         @"←" },
		{ @"up",           @"↑" },
		{ @"right",        @"→" },
		{ @"down",         @"↓" },
        
		{ @"ib_left",      @"⇠" },
		{ @"ib_up",        @"⇡" },
		{ @"ib_right",     @"⇢" },
		{ @"ib_down",      @"⇣" },
        
		{ @"home",         @"↖" },
		{ @"end",          @"↘" },
		{ @"return",       @"↩" },
		{ @"pageup",       @"⇞" },
		{ @"pagedown",     @"⇟" },
		{ @"tab",          @"⇥" },
		{ @"backtab",      @"⇤" },
		{ @"shift",        @"⇧" },
		{ @"control",      @"⌃" },
		{ @"enter",        @"⌅" },
		{ @"command",      @"⌘" },
		{ @"modifier",     @"⌥" },
		{ @"backspace",    @"⌫" },
		{ @"delete",       @"⌦" },
		{ @"escape",       @"⎋" },
		{ @"numlock",      @"⌧" },
		{ @"help",         @"?⃝" },
        
		{ @"space",        @"␣" }
	};
    
	for(NSUInteger i = 0; i != sizeof(KeyGlyphs) / sizeof(KeyGlyphs[0]); ++i)
	{
		if(name == KeyGlyphs[i].name)
			return KeyGlyphs[i].glyph;
	}
    
	return @"�";
}

static NSString * glyphs_for_key (NSString * key, BOOL numpad)
{
	static struct
    {
        unsigned short code;
        NSString * name;
    } const Keys[] =
	{
		{ NSUpArrowFunctionKey,          @"up"        },
		{ NSDownArrowFunctionKey,        @"down"      },
		{ NSLeftArrowFunctionKey,        @"left"      },
		{ NSRightArrowFunctionKey,       @"right"     },
		{ NSDeleteFunctionKey,           @"delete"    },
		{ NSHomeFunctionKey,             @"home"      },
		{ NSEndFunctionKey,              @"end"       },
		{ NSPageUpFunctionKey,           @"pageup"    },
		{ NSPageDownFunctionKey,         @"pagedown"  },
		{ NSClearLineFunctionKey,        @"numlock",  },
		{ NSHelpFunctionKey,             @"help",     },
		{ NSTabCharacter,                @"tab"       },
		{ NSCarriageReturnCharacter,     @"return"    },
		{ NSEnterCharacter,              @"enter"     },
		{ NSBackTabCharacter,            @"backtab"   },
		{ '\033',                        @"escape"    },
		{ NSDeleteCharacter,             @"backspace" },
		{ ' ',                           @"space"     },
	};
    
	NSString * res = key;
    
	BOOL didMatch = false;
	uint32_t code = OakUTF8StringToChar(key);
	for(NSUInteger i = 0; i < sizeof(Keys) / sizeof(Keys[0]) && !didMatch; ++i)
	{
		if((didMatch = (code == Keys[i].code)))
        {
			res = glyph_named(Keys[i].name);
        }
	}
    
	if(code == 0xA0)
    {
		res = @"nbsp";
    }
	else if(NSF1FunctionKey <= code && code <= NSF35FunctionKey)
    {
		res = [NSString stringWithFormat: @"F%d", code - NSF1FunctionKey + 1];
    }
    
	if(numpad)
    {
		res = [res stringByAppendingString: @"\u20E3"]; // COMBINING ENCLOSING KEYCAP
    }
    
	return res;
}

static NSString * s_OakStringForKeyMask (NSEventMask flags)
{
	static struct EventFlag_t
    {
        NSUInteger flag;
        NSString * symbol;
    } const EventFlags[] =
	{
		{ NSNumericPadKeyMask, @"#" },
		{ NSControlKeyMask,    @"^" },
		{ NSAlternateKeyMask,  @"~" },
		{ NSShiftKeyMask,      @"$" },
		{ NSCommandKeyMask,    @"@" },
	};
    
	NSMutableString * res = [NSMutableString string];
	for(NSUInteger i = 0; i < sizeof(EventFlags) / sizeof(EventFlags[0]); ++i)
    {
		[res appendString: (flags & EventFlags[i].flag) ? EventFlags[i].symbol : @""];
    }
    
	return res;
}

static NSUInteger s_OakEventFlagFromChar (char ch)
{
	switch(ch)
	{
		case '$': return NSShiftKeyMask;
		case '^': return NSControlKeyMask;
		case '~': return NSAlternateKeyMask;
		case '@': return NSCommandKeyMask;
		case '#': return NSNumericPadKeyMask;
	}
	return 0;
}

static NSString * parse_event_string (NSString * eventString, NSUInteger * flags, BOOL legacy)
{
	*flags = 0;
    
    NSMutableString *key = [NSMutableString string];
    
	if(legacy)
	{
		BOOL scanningFlags = YES;
        BOOL real = YES;
        
		for(NSUInteger iLooper = 0; iLooper < [eventString length]; ++iLooper)
		{
            const unichar ch = [eventString characterAtIndex: iLooper];
            

			if((scanningFlags = scanningFlags && s_OakEventFlagFromChar(ch) != 0))
            {
				*flags |= s_OakEventFlagFromChar(ch);
                
			}else if((real = (!real || ch != '\\')))
            {
				[key appendString: [NSString stringWithCharacters: &ch
                                                           length: 1]];
            }
		}
	}
	else
	{
		NSUInteger i = [eventString rangeOfString: @("[^$\\^~@#]")
                                          options: NSRegularExpressionSearch].location;
		if(i == NSNotFound)
        {
			i = [eventString length] == 0 ? 0 : [eventString length] - 1;
        }
        
        const char* cString = [eventString UTF8String];
		for(const char* charLooper = cString; *charLooper; ++charLooper)
        {
            *flags |= s_OakEventFlagFromChar(*charLooper);
        }
        
		[key setString: [eventString substringFromIndex: i]];
	}
                 
                 return key;
}

NSString * OakCreateEventString (NSString* key, NSUInteger flags)
{
    return [s_OakStringForKeyMask(flags) stringByAppendingString: key];
}

NSString * OakNormalizeEventString (NSString * eventString, NSUInteger* startOfKey)
{
    NSUInteger flags;
    NSString * key = parse_event_string(eventString, &flags, true);
    
    NSString * modifierString = ([key length] == 0) ? @"" : s_OakStringForKeyMask(flags);
    
    if(startOfKey)
    {
        *startOfKey = [modifierString length];
    }
    return [modifierString stringByAppendingString: key];
}

NSString * OakGlyphsForFlags (NSUInteger flags)
{
    NSMutableString * res = [NSMutableString string];
    
    if(flags & NSControlKeyMask)
    {
        [res appendString: glyph_named(@"control")];
    }
    if(flags & NSAlternateKeyMask)
    {
        [res  appendString: glyph_named(@"modifier")];
    }
    
    if(flags & NSShiftKeyMask)
    {
        [res  appendString: glyph_named(@"shift")];
    }
    
    if(flags & NSCommandKeyMask)
    {
        [res  appendString: glyph_named(@"command")];
    }
    
    return res;
}

NSString * OakGlyphsForEventString (NSString * eventString, NSUInteger* startOfKey)
{
    NSUInteger flags;
    NSString * key = parse_event_string(eventString, &flags, NO);
    
    if((flags & NSShiftKeyMask) == 0)
    {
        NSString * upCased = [key uppercaseString];
        
        if(![key isEqualToString: [key lowercaseString]])
        {
            flags |= NSShiftKeyMask;
            
        }else if(![key isEqualToString: upCased])
        {
            key = upCased;
        }
    }
    
    NSString * modifierString = OakGlyphsForFlags(flags);
    if(startOfKey)
    {
        *startOfKey = [modifierString length];
    }
    
    return [modifierString stringByAppendingString: glyphs_for_key(key, flags & NSNumericPadKeyMask)];
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

//static NSString * string_forWithEventFlag (CGKeyCode key, CGEventFlags flags)
//{
//	CGEventRef event = CGEventCreateKeyboardEvent(NULL, key, true);
//	CGEventSetFlags(event, flags);
//	NSString * tmp = to_s([[NSEvent eventWithCGEvent:event] characters]);
//    
//	NSString * res = tmp;
//	citerate(str, diacritics::make_range(tmp.data(), tmp.data() + tmp.size()))
//    {
//		res = NSString *(&str, &str + str.length());
//    }
//    
//	CFRelease(event);
//    
//	return res;
//}
//
//
//NSString * to_s (NSEvent* anEvent, BOOL preserveNumPadFlag)
//{
//	CGEventRef cgEvent = [anEvent CGEvent];
//	CGKeyCode key      = (CGKeyCode)[anEvent keyCode];
//	CGEventFlags flags = CGEventGetFlags(cgEvent);
//	flags &= kCGEventFlagMaskCommand | kCGEventFlagMaskShift | kCGEventFlagMaskAlternate | kCGEventFlagMaskControl | kCGEventFlagMaskNumericPad;
//    
//	NSString * keyString              = nil;
//	NSString * keyStringNoFlags = string_for(key, 0);
//	CGEventFlags newFlags              = flags & (kCGEventFlagMaskControl|kCGEventFlagMaskCommand);
//	flags &= ~kCGEventFlagMaskControl;
//    
//	if(flags & kCGEventFlagMaskNumericPad)
//	{
//		NSString * numPadKeys = @"0123456789=/*-+.,";
//		if(preserveNumPadFlag && [numPadKeys rangeOfCharacterFromSet: [NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound)
//        {
//			newFlags |= kCGEventFlagMaskNumericPad;
//        }
//        
//		flags &= ~kCGEventFlagMaskControl;
//	}
//    
//	NSString * keyStringCommand = string_for(key, kCGEventFlagMaskCommand);
//	if((flags & kCGEventFlagMaskCommand) && keyStringNoFlags != keyStringCommand)
//	{
//		D(DBF_NSEvent, bug("command (⌘) changes key\n"););
//        
//		newFlags |= flags & kCGEventFlagMaskAlternate;
//		flags    &= ~kCGEventFlagMaskAlternate;
//        
//		if(flags & kCGEventFlagMaskShift)
//		{
//			if(keyStringCommand.size() == 1 && isalpha(keyStringCommand[0]))
//			{
//				D(DBF_NSEvent, bug("manually upcase key\n"););
//				keyString = NSString *(1, toupper(keyStringCommand[0]));
//			}
//			else
//			{
//				D(DBF_NSEvent, bug("shift (⇧) is literal\n"););
//				newFlags |= kCGEventFlagMaskShift;
//			}
//		}
//	}
//	else
//	{
//		if(flags & kCGEventFlagMaskAlternate)
//		{
//			NSString * keyStringAlternate = string_for(key, flags & (kCGEventFlagMaskAlternate
//                                                                     | kCGEventFlagMaskShift));
//			if(!is_ascii(keyStringAlternate) || keyStringNoFlags == keyStringAlternate)
//			{
//				NSLog(@"option (⌥) is literal\n");
//                
//				newFlags |= kCGEventFlagMaskAlternate;
//				flags    &= ~kCGEventFlagMaskAlternate;
//			}
//		}
//        
//		if(flags & kCGEventFlagMaskShift)
//		{
//			NSString * keyStringShift = string_for(key, flags & (kCGEventFlagMaskAlternate|kCGEventFlagMaskShift));
//			if(!is_ascii(keyStringShift) || keyStringNoFlags == keyStringShift)
//			{
//				NSLog(@"shift (⇧) is literal\n");
//				newFlags |= kCGEventFlagMaskShift;
//				flags    &= ~kCGEventFlagMaskShift;
//			}
//			else
//			{
//				D(DBF_NSEvent, bug("use NSEvent’s uppercased version\n"););
//				keyString = keyStringShift;
//			}
//		}
//	}
//    
//	return string_for(newFlags) + (keyString == NULL_STR ? string_for(key, flags) : keyString);
//}
//
//
//static NSString * string_for (CGEventFlags flags)
//{
//	static struct EventFlag_t { CGEventFlags flag; NSString * symbol; } const EventFlags[] =
//	{
//		{ kCGEventFlagMaskNumericPad, @"#" },
//		{ kCGEventFlagMaskControl,    @"^" },
//		{ kCGEventFlagMaskAlternate,  @"~" },
//		{ kCGEventFlagMaskShift,      @"$" },
//		{ kCGEventFlagMaskCommand,    @"@" }
//	};
//    
//	NSMutableString * res = [NSMutableString string];
//	for(NSUInteger i = 0; i < sizeof(EventFlags) / sizeof(EventFlags[0]); ++i)
//    {
//		[res appendString: (flags & EventFlags[i].flag) ? EventFlags[i].symbol : @""];
//    }
//    
//	return res;
//}
//
//static BOOL is_ascii (NSString * str)
//{
//	char ch = [str length] == 1 ? [str UTF8String][0] : 0;
//	return 0x20 < ch && ch < 0x7F;
//}

