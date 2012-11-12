//
//  PBXBreakpoint.c
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-10-30.
//
//

#import "PBXBreakpoint.h"
#import "PBXMarkerDelegateProtocol.h"

@interface PBXBreakpoint ()<PBXMarkerDelegateProtocol>

@end

@implementation PBXBreakpoint

+ (id)archivableRelationships
{
    return nil;
}

+ (id)archivableAttributes
{
    return nil;
}

@synthesize originalNumberOfMultipleMatches = _originalNumberOfMultipleMatches;
@synthesize parentBreakpoint = _parentBreakpoint;
@synthesize canContainMultipleMatches = _canContainMultipleMatches;
@synthesize resolveMultipleMatchesInDebugger = _resolveMultipleMatchesInDebugger;

@synthesize breakpointStyle = _breakpointStyle;

@synthesize countType = _countType;

- (void)setLocation:(id)arg1
{
    
}

@synthesize ignoreCount = _ignoreCount;
@synthesize condition = _condition;
@synthesize gdbConditionString = _gdbConditionString;

@synthesize delayBeforeContinue = _delayBeforeContinue;
@synthesize continueAfterActions = _continueAfterActions;

- (NSInteger)nextActionToPerform
{
    return 0;
}

- (BOOL)performWaitingActionsInSession:(id)arg1
{
    return NO;
}

- (void)performActionsInSession:(id)arg1
{
    
}

@synthesize currentMultipleMatches;

- (void)removeMatchedBreakpointsFromProject
{
    
}
- (void)removeMatchedBreakpoint:(id)arg1
{
    
}
- (void)addMatchedBreakpoint:(id)arg1
{
    
}
- (NSArray *)actions
{
    return [NSArray arrayWithArray: _actions];
}

- (void)setActions: (NSArray *)array
{
    [_actions setArray: array];
}

- (void)removeAction:(id)action
{
    [_actions removeObject: action];
}

- (void)addAction: (id)action
{
    [_actions addObject: action];
}
- (void)insertAction: (id)action
             atIndex: (NSUInteger)idx
{
    [_actions insertObject: action
                   atIndex: idx];
}

- (void)markChanged
{
    
}

@synthesize lineNumber = _lineNumber;

- (void)purify
{
    
}

@synthesize hitCount = _hitCount;

@synthesize modificationTime = _modificationTime;

- (void)setComments:(id)arg1
{
    
}

@synthesize alias = _alias;

- (id)locationDisplay
{
    return nil;
}

- (id)location
{
    return nil;
}

- (NSString *)name
{
    return nil;
}

- (NSString *)displayString
{
    return nil;
}

- (NSInteger)compareToBreakpoint:(id)arg1
{
    return 0;
}

- (int)changeMask
{
    return 0;
}

@synthesize textBookmark = _textBookmark;

- (int)displayState
{
    return 0;
}

- (int)_displayState
{
    return 0;
}

- (void)setEnabled: (BOOL)arg1
       userGesture: (BOOL)arg2
{
    
}

@synthesize enabled = _enabled;

@synthesize state = _state;

- (void)setState: (int)arg1
           quiet: (BOOL)arg2
{
    
}

- (void)resetActionState
{
    
}
- (void)resetRuntimeState
{
    
}
- (void)locationChanged
{
    
}
- (void)didChange
{
    
}

- (NSUInteger)changeBit: (NSUInteger)arg1
{
    _changeBits &= arg1;
    return _changeBits;
}

- (void)clearChangeBits
{
    _changeBits &= 0x0;
}

- (void)setChangeBit:(NSUInteger)arg1
{
    _changeBits |= arg1;
}

- (void)dealloc
{
    
    [super dealloc];
}

- (id)bestMatchForFileRef: (id)arg1
             inReferences: (id)arg2
{
    return nil;
}

- (void)fixupFileReferenceWithUnarchiver:(id)arg1
{
    
}
- (void)awakeFromPListUnarchiver:(id)arg1
{
    
}
- (void)setAppleScriptCondition:(id)arg1
{
    
}
- (id)appleScriptCondition
{
    return nil;
}

@synthesize automaticallyContinue = _automaticallyContinue;

- (void)setIsEnabled:(BOOL)arg1
{
    
}

@synthesize project = _project;

- (id)objectSpecifier
{
    return nil;
}


@end
