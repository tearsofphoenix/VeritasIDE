//
//  OakAttributedString.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-5.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakAttributedString.h"

@implementation OakAttributedString

- (void)addAttribute: (NSString *)attrName
               value: (id)value
{
    [_attributes addObject: @[ @([_string length]), (attrName ?: [NSNull null]), (value ?: [NSNull null])] ];
}

- (void)appendString: (NSString *)str
{
    [_string appendString: str];
}

- (void)appendBackgroundColor: (NSColor *)backgroundColor
{
    [self addAttribute: NSBackgroundColorAttributeName
                 value: backgroundColor];
}

- (void)appendLineBreakMode: (NSLineBreakMode)mode
{
    // FIXME here we create a new paragraph style, but there may be one already in effect
    // we should instead copy and mutate the current style if there is one
    NSMutableParagraphStyle* paragraph = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [paragraph setLineBreakMode: mode];
    
    [self addAttribute: NSParagraphStyleAttributeName
                 value: paragraph];
}

- (void)appendImage: (NSImage *)image
{
    if(image)
    {
        NSFileWrapper* fileWrapper = [[NSFileWrapper new] autorelease];
        [fileWrapper setIcon: image];
        
        NSTextAttachment* textAttachment = [[[NSTextAttachment alloc] initWithFileWrapper: fileWrapper] autorelease];
        
        [self addAttribute: NSAttachmentAttributeName
                     value: textAttachment];
        
        [self appendString: @"\uFFFC"]; // This is the object replacement character for the text attachment
        
        [self addAttribute: NSAttachmentAttributeName
                     value: NULL];
    }
}

- (void)appendURL: (NSURL *)link
{
    if(link)
    {
        [self addAttribute: NSLinkAttributeName
                     value: [link absoluteString]];
        
        [self addAttribute: NSForegroundColorAttributeName
                     value: [NSColor blueColor]];

        [self addAttribute: nil
                     value: @(OakAttributedStringStyleUnderline)];
    }
}

- (void)appendAttributedString: (OakAttributedString *)str
{
    [self addAttribute: nil
                 value: @(OakAttributedStringStylePush)];
    
    for(NSArray *attrLooper in [str attributes])
    {
        NSUInteger pos = [[attrLooper objectAtIndex: 0] unsignedIntegerValue];
        pos += [_string length];
        [_attributes addObject: @[@(pos), [attrLooper objectAtIndex: 1], [attrLooper objectAtIndex: 2]]];
    }
    
    [self appendString: [str string]];

    [self addAttribute: nil
                 value: @(OakAttributedStringStylePop)];
}

- (NSArray *)attributes
{
    return _attributes;
}

- (NSString *)string
{
    return _string;
}
//inline NSString* attribute_for (NSFont*)                  { return NSFontAttributeName;                    }
//inline NSString* attribute_for (NSColor*)                 { return NSForegroundColorAttributeName;         }
//inline NSString* attribute_for (NSShadow*)                { return NSShadowAttributeName;                  }
//inline NSString* attribute_for (NSParagraphStyle*)        { return NSParagraphStyleAttributeName;          }
//inline NSString* attribute_for (NSMutableParagraphStyle*) { return NSParagraphStyleAttributeName;          }
- (void)appendShadow: (NSShadow *)shadow
{
    [self addAttribute: NSShadowAttributeName
                 value: shadow];
}

- (void)appendFont: (NSFont *)font
{
    [self addAttribute: NSFontAttributeName
                 value: font];
}

- (NSMutableAttributedString *)mutableAttributedString
{
    NSMutableArray *attribute_stack = [NSMutableArray array];
    
    NSMutableDictionary* attributes   = [[NSMutableDictionary new] autorelease];
    NSMutableAttributedString* result = [[NSMutableAttributedString new] autorelease];
    NSUInteger last_pos = 0;
    
    for(NSArray *it in _attributes)
    {
        NSUInteger itrPos = [[it objectAtIndex: 0] unsignedIntegerValue];
        
        
        if(last_pos < itrPos)
        {
            NSAttributedString *strLooper = [[NSAttributedString alloc] initWithString: [_string substringWithRange: NSMakeRange(last_pos, itrPos - last_pos)]
                                                                            attributes: attributes];
            [result appendAttributedString: strLooper];
            
            [strLooper release];
        }
        
        last_pos = itrPos;
        
        NSString *attName = [it objectAtIndex: 1];
        id value = [it objectAtIndex: 2];
        
        if(!attName)
        {
            static struct
            {
                OakAttributedStringStyleType style;
                NSFontTraitMask trait;
                
            } const FontTraits[] =
            {
                { OakAttributedStringStyleBold,     NSBoldFontMask     },
                { OakAttributedStringStyleUnbold,   NSUnboldFontMask   },
                { OakAttributedStringStyleItalic,   NSItalicFontMask   },
                { OakAttributedStringStyleUnitalic, NSUnitalicFontMask },
            };
            
            OakAttributedStringStyleType style     = [value integerValue];
            BOOL did_handle_style = NO;
            
            // Handle font trait styles
            for(int i = 0; i < sizeof(FontTraits); ++i)
            {
                if(style == FontTraits[i].style)
                {
                    attName  = NSFontAttributeName;
                    value    = [[NSFontManager sharedFontManager] convertFont: [attributes objectForKey: NSFontAttributeName]
                                                                  toHaveTrait: FontTraits[i].trait];
                    did_handle_style = NO;
                }
            }
            
            if(!did_handle_style)
            {
                // Handle custom styles
                switch(style)
                {
                    case OakAttributedStringStyleUnderline:
                    {
                        attName  = NSUnderlineStyleAttributeName;
                        value = @(NSUnderlineStyleSingle);
                        break;
                    }
                    case OakAttributedStringStyleNounderline:
                    {
                        attName  = NSUnderlineStyleAttributeName;
                        value = nil;
                        break;
                    }
                    case OakAttributedStringStyleEmboss:
                    {
                        NSShadow* shadow = [[NSShadow new] autorelease];
                        [shadow setShadowColor:[NSColor colorWithCalibratedWhite:1 alpha:0.7]];
                        [shadow setShadowOffset:NSMakeSize(0,-1)];
                        [shadow setShadowBlurRadius:1];
                        attName = NSShadowAttributeName;
                        value = shadow;
                        break;
                    }
                    case OakAttributedStringStyleNoemboss:
                    {
                        attName  = NSShadowAttributeName;
                        value = nil;
                        break;
                    }
                    case OakAttributedStringStylePush:
                    {
                        [attribute_stack addObject: [[attributes copy] autorelease]];
                        [attributes removeAllObjects];
                        value = attName = nil;
                        break;
                    }
                    case OakAttributedStringStylePop:
                    {
                        [attributes setDictionary: [attribute_stack lastObject]];
                        [attribute_stack removeLastObject];
                        value = attName = nil;
                        break;
                    }
                    default:
                    {
                        break;
                    }
                }
            }
        }
        
        if(value)
        {
            [attributes setObject: value
                           forKey: attName];
        }else if(attName)
        {
            [attributes removeObjectForKey: attName];
        }
    }
    
    if(last_pos < [_string length])
    {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString: [_string substringWithRange: NSMakeRange(last_pos, [_string length] - last_pos)]
                                                                  attributes: attributes];
        [result appendAttributedString: str];
        
        [str release];
    }
    
    return result;
}


@end
