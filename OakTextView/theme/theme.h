
enum
{
    bool_true,
    bool_false,
    bool_unset
};

typedef NSInteger bool_t;

@class OakScopeSelector;
@class OakScopeContext;
@class OakBundleItem;

@interface OakThemeStyle : NSObject

@property (nonatomic, retain) NSColor *foregroundColor;
@property (nonatomic, retain) NSColor *backgroundColor;
@property (nonatomic, retain) NSColor *caretColor;
@property (nonatomic, retain) NSColor *selectionColor;

@property (nonatomic, retain) NSFont *font;
@property (nonatomic) BOOL underlined;
@property (nonatomic) BOOL misspelled;


@end


@interface OakThemeGutterStyle : NSObject

@property (nonatomic, retain) NSColor * divider;
@property (nonatomic, retain) NSColor * selectionBorder;

@property (nonatomic, retain) NSColor * foreground;
@property (nonatomic, retain) NSColor * background;
@property (nonatomic, retain) NSColor * icons;
@property (nonatomic, retain) NSColor * iconsHover;
@property (nonatomic, retain) NSColor * iconsPressed;

@property (nonatomic, retain) NSColor * selectionForeground;
@property (nonatomic, retain) NSColor * selectionBackground;
@property (nonatomic, retain) NSColor * selectionIcons;
@property (nonatomic, retain) NSColor * selectionIconsHover;
@property (nonatomic, retain) NSColor * selectionIconsPressed;

@end



@interface OakDecoposedStyle : NSObject

//    decomposed_style_t (scope::selector_t  scopeSelector = scope::selector_t(),
//                        NSString * fontName = NULL_STR,
//                        CGFloat fontSize = -1) : scope_selector(scopeSelector), font_name(fontName), font_size(fontSize), bold(bool_unset), italic(bool_unset), underlined(bool_unset), misspelled(bool_unset) { }

@property (nonatomic, retain) OakScopeSelector * scopeSelector;

@property (nonatomic, retain) NSString * fontName;
@property (nonatomic, retain) NSColor * foregroundColor;
@property (nonatomic, retain) NSColor * backgroundColor;
@property (nonatomic, retain) NSColor * caretColor;
@property (nonatomic, retain) NSColor * selectionColor;
@property (nonatomic, retain) NSColor * invisiblesColor;

@property (nonatomic)     CGFloat fontSize;

@property (nonatomic)     bool_t bold;
@property (nonatomic)     bool_t italic;
@property (nonatomic)     bool_t underlined;
@property (nonatomic)     bool_t misspelled;

+ (id)styleWithDictionary: (NSDictionary *)dict;

@end


@interface OakTheme : NSObject
{
    
    OakBundleItem * _item;
    
    NSMutableArray *_decomposedStyles;
    OakThemeGutterStyle *_gutter_styles;
    NSColor * _foregroundColor;
    NSColor * _backgroundColor;
    BOOL _isDark;
    BOOL _isTransparent;
    
    NSMutableDictionary *_cache;
    
}

- (id)initWithBundleItem: (OakBundleItem *)themeItem;

- (NSUUID *)uuid;

- (NSColor *)foregroundColor;

- (NSColor *)backgroundColorForFileType: (NSString *) fileType;

- (BOOL)isDark;

- (BOOL)isTransparent;

- (OakThemeGutterStyle *)gutterStyles;

- (OakThemeStyle *)stylesForScope: (OakScopeContext *)scope
                         fontName: (NSString *) fontName
                         fontSize: (CGFloat)fontSize;

- (void)setupStyles;

@end

extern NSArray * OakGlobalDecomposedStyles(OakScopeContext * scope);
