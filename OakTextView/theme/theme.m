#import "theme.h"
#import <OakFoundation/OakFoundation.h>
#import <OakAppKit/NSColor+Additions.h>

static NSColor *soften (NSColor *color, CGFloat factor);
static CGFloat read_font_size (NSString * str_font_size);

//static void get_key_path (NSMutableDictionary *  plist, NSString * setting, NSColor *color)
//{
//	color = read_color([plist objectForKeyPath: setting]);
//}

//static void get_key_path (NSMutableDictionary *  plist, NSString * setting, CGFloat font_size)
//{
//	font_size = read_font_size([plist objectForKeyPath: setting]);
//}

@implementation  OakDecoposedStyle

+ (id)styleWithDictionary: (NSDictionary *)dict
{
    if((self = [super init]))
    {
        
        NSString * scopeSelector = [dict objectForKeyPath: @"scope"];
        [self setScopeSelector: scopeSelector];
        
        [self setFontName: [dict objectForKeyPath: @"settings.fontName"]];
        [self setFontSize: [dict objectForKeyPath: @"settings.fontSize"]];
        
        [self setForegroundColor: [dict objectForKeyPath: @"settings.foreground"]];
        [self setBackgroundColor: [dict objectForKeyPath: @"settings.background"]];
        [self setCaretColor: [dict objectForKeyPath: @"settings.caret"]];
        
        [self setSelectionColor: [dict objectForKeyPath: @"settings.selection"]];
        [self setInvisibles: [dict objectForKeyPath: @"settings.invisibles"]];
        
        id flag = [dict objectForKeyPath: @"settings.misspelled"];
        if (flag)
        {
            [self setMisspell: [flag boolValue]];
        }else
        {
            [self setMisspell: bool_unset];
        }
        
        NSString * fontStyle = [dict objectForKeyPath: @"settings.fontStyle"];
        if(fontStyle)
        {
            if([fontStyle rangeOfString: @"plain"].location != NSNotFound)
            {
                self.bold       = bool_false;
                self.italic     = bool_false;
                self.underlined = bool_false;
            }
            else
            {
                self.bold       = [fontStyle rangeOfString: @"bold"].location      != NSNotFound ? bool_true : bool_unset;
                self.italic     = [fontStyle rangeOfString: @"italic"].location    != NSNotFound ? bool_true : bool_unset;
                self.underlined = [fontStyle rangeOfString: @"underline"].location != NSNotFound ? bool_true : bool_unset;
            }
        }
    }
	return self;
}

@end

NSArray * OakGlobalDecomposedStyles(OakScopeContext *  scope)
{
    //	static struct { NSString * name; theme_t::color_info_t decomposed_style_t::*field; } const colorKeys[] =
    //	{
    //		{ "foreground", &decomposed_style_t::foreground },
    //		{ "background", &decomposed_style_t::background },
    //		{ "caret",      &decomposed_style_t::caret      },
    //		{ "selection",  &decomposed_style_t::selection  },
    //		{ "invisibles", &decomposed_style_t::invisibles },
    //	};
    //
    //	static struct { NSString * name; bool_t decomposed_style_t::*field; } const booleanKeys[] =
    //	{
    //		{ "misspelled", &decomposed_style_t::misspelled },
    //		{ "bold",       &decomposed_style_t::bold       },
    //		{ "italic",     &decomposed_style_t::italic     },
    //		{ "underline",  &decomposed_style_t::underlined },
    //	};
    //
    //	std::vector<decomposed_style_t> res;
    //
    //	for(NSUInteger i = 0; i < sizeofA(colorKeys); ++i)
    //	{
    //		OakBundleItem * item;
    //		id value = bundles::value_for_setting(colorKeys[i].name, scope, &item);
    //		if(item)
    //		{
    //			res.push_back(decomposed_style_t(item->scope_selector()));
    //			res.back().*(colorKeys[i].field) = [NSColor colorWithString: value]);
    //		}
    //	}
    //
    //	for(NSUInteger i = 0; i < sizeofA(booleanKeys); ++i)
    //	{
    //		OakBundleItem * item;
    //		id value = bundles::value_for_setting(booleanKeys[i].name, scope, &item);
    //		if(item)
    //		{
    //			res.push_back(decomposed_style_t(item->scope_selector()));
    //			res.back().*(booleanKeys[i].field) = plist::is_true(value) ? bool_true : bool_false;
    //		}
    //	}
    //
    //	OakBundleItem * fontNameItem;
    //	id fontNameValue = bundles::value_for_setting("fontName", scope, &fontNameItem);
    //	if(fontNameItem)
    //	{
    //		res.push_back(decomposed_style_t(fontNameItem->scope_selector()));
    //		res.back().font_name = plist::get<NSString *>(fontNameValue);
    //	}
    //
    //	OakBundleItem * fontSizeItem;
    //	id fontSizeValue = bundles::value_for_setting("fontSize", scope, &fontSizeItem);
    //	if(fontSizeItem)
    //	{
    //		res.push_back(decomposed_style_t(fontSizeItem->scope_selector()));
    //		res.back().font_size = read_font_size(plist::get<NSString *>(fontSizeValue));
    //	}
    //
    //	return res;
}

// ===========
// = theme_t =
// ===========

@implementation OakTheme

- (id)initWithBundleItem: (OakBundleItem *)themeItem
{
    if ((self = [super init]))
    {
        _item = [themeItem retain];
        
        [self setupStyles];
        
        //setup_styles();
        //bundles::add_callback(&_callback);

    }
    
    return self;
}

- (void)dealloc
{
	//bundles::remove_callback(&_callback);
    
    [super dealloc];
}

static NSColor* soften (NSColor *color, CGFloat factor)
{
	CGFloat r = [color redComponent], g = [color greenComponent], b = [color blueComponent], a = [color alphaComponent];
	
	if([color isDark])
	{
		r = 1 - factor * (1 - r);
		g = 1 - factor * (1 - g);
		b = 1 - factor * (1 - b);
	}
	else
	{
		r *= factor;
		g *= factor;
		b *= factor;
	}
	
    return [NSColor colorWithCalibratedRed: r
                                     green: g
                                      blue: b
                                     alpha: a];
}

- (void)setupStyles
{
	[_decomposedStyles removeAllObjects];;
	[_cache removeAllObjects];
    
	if(_item)
	{
		if(OakBundleItem * newItem = bundles::lookup([_item uuid]))
        {
			_item = newItem;
        }
        
		NSArray *items = [[_item plist] objectForKeyPath: @"settings"];
		if(items)
		{
			for(id it in items)
			{
				if([it isKindOfClass: [NSDictionary class]])
				{
					[_decomposedStyles addObject: [OakDecoposedStyle styleWithDictionary: it]];
                    
					if(! [[[[_decomposedStyles lastObject] back] invisibles] is_blank])
					{
                        OakDecoposedStyle invisbleStyle = [[OakDecoposedStyle alloc] init];
                        
						//decomposed_style_t invisbleStyle("deco.invisible");
                        [invisbleStyle setForeground: [[_decomposedStyles lastObject] invisibles]];

						[_decomposedStyles addObject: invisbleStyle];
					}
				}
			}
		}
	}
    
	// =======================================
	// = Find “global” foreground/background =
	// =======================================
    
	// We assume that the first style is the unscoped root style
    if ([_decomposedStyles count] == 0)
    {
        _foregroundColor = [[NSColor colorWithString: @"#FFFFFF"] retain];
        _backgroundColor = [[NSColor colorWithString: @"#000000"] retain];
    }else
    {
        _foregroundColor = [[[_decomposedStyles objectAtIndex: 0] foreground] retain];
        _backgroundColor = [[[_decomposedStyles objectAtIndex: 0] background] retain];
    }

	_isDark    = [_backgroundColor isDark];
    
	_isTransparent = [_backgroundColor alphaComponent] < 1;
    
	// =========================
	// = Default Gutter Styles =
	// =========================
    
    [_gutter_styles setDivider: soften(_foregroundColor, 0.4)];
    [_gutter_styles setForeground: soften(_foregroundColor, 0.5)];
    [_gutter_styles setBackground: soften(_backgroundColor, 0.87)];
    [_gutter_styles setSelectionForeground: soften(_foregroundColor, 0.95)];
    [_gutter_styles setBackground: soften(_backgroundColor, 0.95)];
    
	NSMutableDictionary * gutterSettings = [[_item plist] objectForKeyPath: @"gutterSettings"];
    
	if(gutterSettings)
	{
//		static struct
//        {
//            NSString * key;
//            cf::color_t gutter_styles_t::*field;
//        } const gutterKeys[] =
//		{
//			{ "divider",               &gutter_styles_t::divider               },
//			{ "selectionBorder",       &gutter_styles_t::selectionBorder       },
//			{ "foreground",            &gutter_styles_t::foreground            },
//			{ "background",            &gutter_styles_t::background            },
//			{ "icons",                 &gutter_styles_t::icons                 },
//			{ "iconsHover",            &gutter_styles_t::iconsHover            },
//			{ "iconsPressed",          &gutter_styles_t::iconsPressed          },
//			{ "selectionForeground",   &gutter_styles_t::selectionForeground   },
//			{ "selectionBackground",   &gutter_styles_t::selectionBackground   },
//			{ "selectionIcons",        &gutter_styles_t::selectionIcons        },
//			{ "selectionIconsHover",   &gutter_styles_t::selectionIconsHover   },
//			{ "selectionIconsPressed", &gutter_styles_t::selectionIconsPressed },
//		};
//        
//		iterate(gutterKey, gutterKeys)
//        get_key_path(gutterSettings, gutterKey->key, _gutter_styles.*(gutterKey->field));
	}
    
	_gutter_styles.selectionBorder       = _gutter_styles.selectionBorder       ? _gutter_styles.selectionBorder       : _gutter_styles.divider;
	_gutter_styles.icons                 = _gutter_styles.icons                 ? _gutter_styles.icons                 : _gutter_styles.foreground;
	_gutter_styles.iconsHover            = _gutter_styles.iconsHover            ? _gutter_styles.iconsHover            : _gutter_styles.icons;
	_gutter_styles.iconsPressed          = _gutter_styles.iconsPressed          ? _gutter_styles.iconsPressed          : _gutter_styles.icons;
	_gutter_styles.selectionIcons        = _gutter_styles.selectionIcons        ? _gutter_styles.selectionIcons        : _gutter_styles.selectionForeground;
	_gutter_styles.selectionIconsHover   = _gutter_styles.selectionIconsHover   ? _gutter_styles.selectionIconsHover   : _gutter_styles.selectionIcons;
	_gutter_styles.selectionIconsPressed = _gutter_styles.selectionIconsPressed ? _gutter_styles.selectionIconsPressed : _gutter_styles.selectionIcons;
}

- (NSUUID *)uuid
{
    if (_item)
    {
        return [_item uuid];
    }else
    {
        return [NSUUID UUID];
    }
}

- (NSColor *)backgroundColorForFileType: (NSString *)fileType
{
	if(fileType)
    {
		return [styles_for_scope(fileType, nil, 0) background];
    }
        return _background;
}

- (OakThemeStyle *)stylesForScope: (OakScopeContext *)scope
                         fontName: (NSString *)fontName
                         fontSize: (CGFloat)fontSize
{
    
	id styles = [_cache objectForKey: @[ scope, fontName, @(fontSize)]];
	if(styles)
	{
		NSMutableDictionary *ordering = [NSMutableDictionary dictionary];
        
		for(id it in global_styles(scope))
		{
			double rank = 0;
			if([[it scopeSelector] doesMatch: scope])
            {
                [ordering setObject: it
                             forKey: @(rank)];
            }
		}
        
		for(id it in _decomposedStyles)
		{
			double rank = 0;

			if([[it scopeSelector] doesMatch: scope])
            {
                [ordering setObject: it
                             forKey: @(rank)];
            }
		}
        
        OakDecoposedStyle base = nil;
		//decomposed_style_t base(scope::selector_t(), fontName, fontSize);
		//iterate(it, ordering)
        //base += it->second;
        
        NSFont *font = [NSFont fontWithName: [base font_name]
                                       size: [base font_size]];

        CTFontSymbolicTraits traits = (([base bold] == bool_true ? kCTFontBoldTrait : 0)
                                       + ([base italic] == bool_true ? kCTFontItalicTrait : 0));
		if(traits)
		{
            CTFontRef newFont = CTFontCreateCopyWithSymbolicTraits([font CTFont], [base font_size]), NULL, traits,
            kCTFontBoldTrait | kCTFontItalicTrait);
			if(newFont)
            {
                font = newFont;
            }
		}
        
		NSColor *foreground = [[base foreground] is_blank]   ? [NSColor colorWithString: @"#000000"]   : base.foreground;
		NSColor *background = [[base background] is_blank]   ? [NSColor colorWithString: @"#FFFFFF"]   : base.background;
		NSColor *caret      = [[base caret] is_blank]        ? [NSColor colorWithString: @"#000000"]   : base.caret;
		NSColor *selection  = [[base selection] is_blank]    ? [NSColor colorWithString: @"#4D97FF54"] : base.selection;
        
		styles_t res(foreground, background, caret, selection, font, base.underlined == bool_true, base.misspelled == bool_true);
		styles = _cache.insert(std::make_pair(key_t(scope, fontName, fontSize), res)).first;
	}
    
	return styles->second;
}

@end

//theme_t::decomposed_style_t& theme_t::decomposed_style_t::operator+= (theme_t::decomposed_style_t  rhs)
//{
//	font_name  = rhs.font_name != NULL_STR    ? rhs.font_name : font_name;
//	font_size  = rhs.font_size > 0            ? rhs.font_size : font_size * fabs(rhs.font_size);
//    
//	foreground = rhs.foreground.is_blank()    ? foreground : rhs.foreground;
//	background = rhs.background.is_blank()    ? background : [background blended, rhs.background);
//	caret      = rhs.caret.is_blank()         ? caret      : rhs.caret;
//	selection  = rhs.selection.is_blank()     ? selection  : rhs.selection;
//	invisibles = rhs.invisibles.is_blank()    ? invisibles : rhs.invisibles;
//    
//	bold       = rhs.bold       == bool_unset ? bold       : rhs.bold;
//	italic     = rhs.italic     == bool_unset ? italic     : rhs.italic;
//	underlined = rhs.underlined == bool_unset ? underlined : rhs.underlined;
//	misspelled = rhs.misspelled == bool_unset ? misspelled : rhs.misspelled;
//    
//	return *this;
//}

// ==============
// = Public API =
// ==============

OakTheme * parse_theme (OakBundleItem * themeItem)
{
	static NSUUID * kEmptyThemeUUID = NSUUID *().generate();
	static std::map<NSUUID *, OakTheme *> Cache;
    
	NSUUID * uuid = themeItem ? themeItem->uuid() : kEmptyThemeUUID;
	std::map<NSUUID *, OakTheme *>::iterator theme = Cache.find(uuid);
	if(theme == Cache.end())
		theme = Cache.insert(std::make_pair(uuid, OakTheme *(new theme_t(themeItem)))).first;
	return theme->second;
}
