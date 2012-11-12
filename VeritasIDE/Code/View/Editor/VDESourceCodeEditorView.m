//
//  VDESourceCodeEditorView.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-25.
//
//

#import "VDESourceCodeEditorView.h"
#import "VDESourceCodeEditorViewPrivateHandler.h"
#import <OakFoundation/OakFoundation.h>

@interface VDESourceCodeEditorView ()<NSTextStorageDelegate>
{
@private
    VDESourceCodeEditorViewPrivateHandler *_handler;
    NSTextStorage *_textStorage;
    BOOL _autoSyntaxColoring;
    BOOL syntaxColoringBusy;
}
@end

@implementation VDESourceCodeEditorView

- (id)initWithFrame: (NSRect)frameRect
      textContainer: (NSTextContainer *)container
{
    if((self = [super initWithFrame: frameRect
                      textContainer: container]))
    {
        _textStorage = [self textStorage];
        [_textStorage setDelegate: self];
    }
    
    return self;
}

- (void)textStorageDidProcessEditing: (NSNotification *)notification
{
    NSTextStorage	*textStorage = [notification object];
	NSRange			range = [textStorage editedRange];
	int				changeInLen = [textStorage changeInLength];
	BOOL			wasInUndoRedo = [[self undoManager] isUndoing] || [[self undoManager] isRedoing];
	BOOL			textLengthMayHaveChanged = NO;
	
	// Was delete op or undo that could have changed text length?
	if( wasInUndoRedo )
	{
		textLengthMayHaveChanged = YES;
		range = [self selectedRange];
	}
	if( changeInLen <= 0 )
		textLengthMayHaveChanged = YES;
	
	//	Try to get chars around this to recolor any identifier we're in:
	if( textLengthMayHaveChanged )
	{
		if( range.location > 0 )
			range.location--;
		if( (range.location +range.length +2) < [textStorage length] )
			range.length += 2;
		else if( (range.location +range.length +1) < [textStorage length] )
			range.length += 1;
	}
	
	NSRange						currRange = range;
    
	// Perform the syntax coloring:
	if( _autoSyntaxColoring && range.length > 0 )
	{
		NSRange			effectiveRange;
		NSString*		rangeMode;
		
		
		rangeMode = [textStorage attribute: @"UKTextDocumentSyntaxColoringMode"
                                   atIndex: currRange.location
                            effectiveRange: &effectiveRange];
		
		unsigned int		x = range.location;
		
		/* TODO: If we're in a multi-line comment and we're typing a comment-end
         character, or we're in a string and we're typing a quote character,
         this should include the rest of the text up to the next comment/string
         end character in the recalc. */
		
		// Scan up to prev line break:
		while( x > 0 )
		{
			unichar theCh = [[textStorage string] characterAtIndex: x];
			if( theCh == '\n' || theCh == '\r' )
				break;
			--x;
		}
		
		currRange.location = x;
		
		// Scan up to next line break:
		x = range.location +range.length;
		
		while( x < [textStorage length] )
		{
			unichar theCh = [[textStorage string] characterAtIndex: x];
			if( theCh == '\n' || theCh == '\r' )
				break;
			++x;
		}
		
		currRange.length = x -currRange.location;
		
		// Open identifier, comment etc.? Make sure we include the whole range.
		if( rangeMode != nil )
			currRange = NSUnionRange( currRange, effectiveRange );
		
		// Actually recolor the changed part:
		[self recolorRange: currRange];
	}
}

-(NSDictionary*)	defaultTextAttributes
{
	return (@{
            NSFontAttributeName : [NSFont userFixedPitchFontOfSize: 10.0]
            });
}

-(void)		recolorRange: (NSRange)range
{
	if( syntaxColoringBusy )	// Prevent endless loop when recoloring's replacement of text causes processEditing to fire again.
		return;
	
	if( range.length == 0 )	// Don't like doing useless stuff.
		return;
	
	@try
	{
		syntaxColoringBusy = YES;
        
		
		// Kludge fix for case where we sometimes exceed text length:ra
		int diff = [[self textStorage] length] -(range.location +range.length);
		if( diff < 0 )
			range.length += diff;
        
		// Get the text we'll be working with:
		NSDictionary*				vStyles = [self defaultTextAttributes];
		NSMutableAttributedString*	vString = [[NSMutableAttributedString alloc] initWithString: [[[self textStorage] string] substringWithRange: range] attributes: vStyles];
		[vString autorelease];
        
		// Load colors and fonts to use from preferences:
		// Load our dictionary which contains info on coloring this language:
		NSDictionary*				vSyntaxDefinition = [self syntaxDefinitionDictionary];
		NSEnumerator*				vComponentsEnny = [[vSyntaxDefinition objectForKey: @"Components"] objectEnumerator];
		
		if( vComponentsEnny == nil )	// No list of components to colorize?
		{
			// @finally takes care of cleaning up syntaxColoringBusy etc. here.
			return;
		}
		
		// Loop over all available components:
		NSDictionary*				vCurrComponent = nil;
		NSUserDefaults*				vPrefs = [NSUserDefaults standardUserDefaults];
        
		while( (vCurrComponent = [vComponentsEnny nextObject]) )
		{
			NSString*   vComponentType = [vCurrComponent objectForKey: @"Type"];
			NSString*   vComponentName = [vCurrComponent objectForKey: @"Name"];
			NSString*   vColorKeyName = [@"SyntaxColoring:Color:" stringByAppendingString: vComponentName];
			NSColor*	vColor = [[vPrefs arrayForKey: vColorKeyName] colorValue];
			
			if( !vColor )
				vColor = [[vCurrComponent objectForKey: @"Color"] colorValue];
			
			if( [vComponentType isEqualToString: @"BlockComment"] )
			{
				[self colorCommentsFrom: [vCurrComponent objectForKey: @"Start"]
                                     to: [vCurrComponent objectForKey: @"End"] inString: vString
                              withColor: vColor andMode: vComponentName];
			}
			else if( [vComponentType isEqualToString: @"OneLineComment"] )
			{
				[self colorOneLineComment: [vCurrComponent objectForKey: @"Start"]
                                 inString: vString withColor: vColor andMode: vComponentName];
			}
			else if( [vComponentType isEqualToString: @"String"] )
			{
				[self colorStringsFrom: [vCurrComponent objectForKey: @"Start"]
                                    to: [vCurrComponent objectForKey: @"End"]
                              inString: vString withColor: vColor andMode: vComponentName
                         andEscapeChar: [vCurrComponent objectForKey: @"EscapeChar"]];
			}
			else if( [vComponentType isEqualToString: @"Tag"] )
			{
				[self colorTagFrom: [vCurrComponent objectForKey: @"Start"]
                                to: [vCurrComponent objectForKey: @"End"] inString: vString
                         withColor: vColor andMode: vComponentName
                      exceptIfMode: [vCurrComponent objectForKey: @"IgnoredComponent"]];
			}
			else if( [vComponentType isEqualToString: @"Keywords"] )
			{
				NSArray* vIdents = [vCurrComponent objectForKey: @"Keywords"];
				if( !vIdents && [delegate respondsToSelector: @selector(userIdentifiersForKeywordModeName)] )
					vIdents = [delegate userIdentifiersForKeywordComponentName: vComponentName];
				if( !vIdents )
					vIdents = [[NSUserDefaults standardUserDefaults] objectForKey: [@"SyntaxColoring:Keywords:" stringByAppendingString: vComponentName]];
				if( !vIdents && [vComponentName isEqualToString: @"UserIdentifiers"] )
					vIdents = [[NSUserDefaults standardUserDefaults] objectForKey: TD_USER_DEFINED_IDENTIFIERS];
				if( vIdents )
				{
					NSCharacterSet*		vIdentCharset = nil;
					NSString*			vCurrIdent = nil;
					NSString*			vCsStr = [vCurrComponent objectForKey: @"Charset"];
					if( vCsStr )
						vIdentCharset = [NSCharacterSet characterSetWithCharactersInString: vCsStr];
					
					NSEnumerator*	vItty = [vIdents objectEnumerator];
					while( vCurrIdent = [vItty nextObject] )
                    {
						[self colorIdentifier: vCurrIdent
                                     inString: vString
                                    withColor: vColor
                                      andMode: vComponentName
                                      charset: vIdentCharset];
                    }
				}
			}
		}
		
		// Replace the range with our recolored part:
		[[self textStorage] replaceCharactersInRange: range withAttributedString: vString];
		[[self textStorage] fixFontAttributeInRange: range];	// Make sure Japanese etc. fallback fonts get applied.
	}
	@finally
	{
		syntaxColoringBusy = NO;

		[self textView: self willChangeSelectionFromCharacterRange: [self selectedRange]
      toCharacterRange: [self selectedRange]];
	}
}


-(void)	colorStringsFrom: (NSString*) startCh
                      to: (NSString*) endCh
                inString: (NSMutableAttributedString*) s
               withColor: (NSColor*) col
                 andMode: (NSString*)attr
           andEscapeChar: (NSString*)vStringEscapeCharacter
{
	@try
    {
        NSScanner*			vScanner = [NSScanner scannerWithString: [s string]];
        NSDictionary*		vStyles = [self textAttributesForComponentName: attr
                                                                color: col];
        BOOL				vIsEndChar = NO;
        unichar				vEscChar = '\\';
        BOOL				vDelegateHandlesProgress = NO;
        //[delegate respondsToSelector: @selector(textViewControllerProgressedWhileSyntaxRecoloring:)];
        
        if( vStringEscapeCharacter )
        {
            if( [vStringEscapeCharacter length] != 0 )
                vEscChar = [vStringEscapeCharacter characterAtIndex: 0];
        }
        
        while( ![vScanner isAtEnd] )
        {
            int		vStartOffs,
            vEndOffs;
            vIsEndChar = NO;
            
            if( vDelegateHandlesProgress )
            {
                //[delegate textViewControllerProgressedWhileSyntaxRecoloring: self];
            }
            
            // Look for start of string:
            [vScanner scanUpToString: startCh intoString: nil];
            vStartOffs = [vScanner scanLocation];
            if( ![vScanner scanString:startCh intoString:nil] )
                NS_VOIDRETURN;
            
            while( !vIsEndChar && ![vScanner isAtEnd] )	// Loop until we find end-of-string marker or our text to color is finished:
            {
                [vScanner scanUpToString: endCh intoString: nil];
                
                if( ([vStringEscapeCharacter length] == 0)
                   || [[s string] characterAtIndex: ([vScanner scanLocation] -1)] != vEscChar )	// Backslash before the end marker? That means ignore the end marker.
                    vIsEndChar = YES;	// A real one! Terminate loop.
                if( ![vScanner scanString:endCh intoString:nil] )	// But skip this char before that.
                    return;
                
                if( vDelegateHandlesProgress )
                {
                    //[delegate textViewControllerProgressedWhileSyntaxRecoloring: self];
                }
            }
            
            vEndOffs = [vScanner scanLocation];
            
            // Now mess with the string's styles:
            [s setAttributes: vStyles
                       range: NSMakeRange( vStartOffs, vEndOffs - vStartOffs )];
        }
	}@catch (...)
    {
        
    }
}


@end
