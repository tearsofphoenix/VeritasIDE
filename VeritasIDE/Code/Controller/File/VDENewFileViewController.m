//
//  VDENewFileViewController.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-1.
//
//

#import "VDENewFileViewController.h"

@interface VDENewFileViewController ()<NSRuleEditorDelegate, NSCollectionViewDelegate>

@end

@implementation VDENewFileViewController

#pragma mark - rule editor delegate

- (NSInteger)     ruleEditor: (NSRuleEditor *)editor
numberOfChildrenForCriterion: (id)criterion
                 withRowType: (NSRuleEditorRowType)rowType
{
    return 1;
}

/* When called, you should return the child of the given item at the given index.  If criterion is nil, return the root criterion for the given row type at the given index. Implementation of this method is required. */
- (id)ruleEditor: (NSRuleEditor *)editor
           child: (NSInteger)index
    forCriterion: (id)criterion
     withRowType: (NSRuleEditorRowType)rowType
{
    return @"Root";
}

/* When called, you should return a value for the given criterion.  The value should be an instance of NSString, NSView, or NSMenuItem.  If the value is an NSView or NSMenuItem, you must ensure it is unique for every invocation of this method; that is, do not return a particular instance of NSView or NSMenuItem more than once.  Implementation of this method is required. */
- (id)        ruleEditor: (NSRuleEditor *)editor
displayValueForCriterion: (id)criterion
                   inRow: (NSInteger)row
{
    return @"OK";
}


@end
