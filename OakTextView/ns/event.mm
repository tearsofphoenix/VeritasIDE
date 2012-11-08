#import "event.h"
#import "ns.h"



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
    
	for(NSUInteger i = 0; i != sizeofA(KeyGlyphs); ++i)
	{
		if(name == KeyGlyphs[i].name)
			return KeyGlyphs[i].glyph;
	}
    
	return @"�";
}

static NSString * glyphs_for_key (NSString * key, bool numpad = false)
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
    
	bool didMatch = false;
	uint32_t code = utf8::to_ch(key);
	for(NSUInteger i = 0; i < sizeofA(Keys) && !didMatch; ++i)
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

static NSString * string_for (NSUInteger flags)
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
	for(NSUInteger i = 0; i < sizeofA(EventFlags); ++i)
    {
		[res appendString: (flags & EventFlags[i].flag) ? EventFlags[i].symbol : @""];
    }
    
	return res;
}

static NSUInteger ns_flag_for_char (uint32_t ch)
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

static void parse_event_string (NSString * eventString, NSString *& key, NSUInteger& flags, bool legacy = false)
{
	flags = 0;
	if(legacy)
	{
		key = "";
		bool scanningFlags = true, real = true;
		foreach(ch, utf8::make(eventString.data()), utf8::make(eventString.data() + eventString.size()))
		{
			if(scanningFlags = scanningFlags && ns_flag_for_char(*ch) != 0)
				flags |= ns_flag_for_char(*ch);
			else if(real = (!real || *ch != '\\'))
				key.append(&ch, ch.length());
		}
	}
	else
	{
		NSUInteger i = eventString.find_first_not_of("$^~@#");
		if(i == NSNotFound)
        {
			i = eventString.empty() ? 0 : eventString.size() - 1;
        }
        
		foreach(ch, eventString.data(), eventString.data() + i)
        flags |= ns_flag_for_char(*ch);
		key = eventString.substr(i);
	}
}

NSString * OakCreateEventString (NSString* key, NSUInteger flags)
{
    return string_for(flags) + to_s(key);
}

NSString * OakNormalizeEventString (NSString * eventString, NSUInteger* startOfKey)
{
    NSString * key; NSUInteger flags;
    parse_event_string(eventString, key, flags, true);
    
    NSString * modifierString = key.empty() ? "" : string_for(flags);
    if(startOfKey)
        *startOfKey = modifierString.size();
    return modifierString + key;
}

NSString * OakGlyphsForFlags (NSUInteger flags)
{
    NSString * res = "";
    if(flags & NSControlKeyMask)
        res += glyph_named("control");
    if(flags & NSAlternateKeyMask)
        res += glyph_named("modifier");
    if(flags & NSShiftKeyMask)
        res += glyph_named("shift");
    if(flags & NSCommandKeyMask)
        res += glyph_named("command");
    return res;
}

NSString * OakGlyphsForEventString (NSString * eventString, NSUInteger* startOfKey)
{
    NSString * key; NSUInteger flags;
    parse_event_string(eventString, key, flags);
    
    if((flags & NSShiftKeyMask) == 0)
    {
        NSString * upCased = text::uppercase(key);
        if(key != text::lowercase(key))
            flags |= NSShiftKeyMask;
        else if(key != upCased)
            key = upCased;
    }
    
    NSString * modifierString = OakGlyphsForFlags(flags);
    if(startOfKey)
        *startOfKey = modifierString.size();
    
    return modifierString + glyphs_for_key(key, flags & NSNumericPadKeyMask);
}
