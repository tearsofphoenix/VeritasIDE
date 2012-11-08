//
//  OakEditor.h
//  OakAppKit
//
//  Created by LeixSnake on 11/8/12.
//  Copyright (c) 2012 tearsofphoenix. All rights reserved.
//

#import <Foundation/Foundation.h>

enum 
{
    kMoveBackward,
    kMoveBackwardAndModifySelection,
    kMoveDown,
    kMoveDownAndModifySelection,
    kMoveForward,
    kMoveForwardAndModifySelection,
    kMoveParagraphBackwardAndModifySelection,
    kMoveParagraphForwardAndModifySelection,
    kMoveSubWordLeft,
    kMoveSubWordLeftAndModifySelection,
    kMoveSubWordRight,
    kMoveSubWordRightAndModifySelection,
    kMoveToBeginningOfColumn,
    kMoveToBeginningOfColumnAndModifySelection,
    kMoveToBeginningOfDocument,
    kMoveToBeginningOfDocumentAndModifySelection,
    kMoveToBeginningOfIndentedLine,
    kMoveToBeginningOfIndentedLineAndModifySelection,
    kMoveToBeginningOfLine,
    kMoveToBeginningOfLineAndModifySelection,
    kMoveToBeginningOfParagraph,
    kMoveToBeginningOfParagraphAndModifySelection,
    kMoveToBeginningOfBlock,
    kMoveToBeginningOfBlockAndModifySelection,
    kMoveToEndOfColumn,
    kMoveToEndOfColumnAndModifySelection,
    kMoveToEndOfDocument,
    kMoveToEndOfDocumentAndModifySelection,
    kMoveToEndOfIndentedLine,
    kMoveToEndOfIndentedLineAndModifySelection,
    kMoveToEndOfLine,
    kMoveToEndOfLineAndModifySelection,
    kMoveToEndOfParagraph,
    kMoveToEndOfParagraphAndModifySelection,
    kMoveToEndOfBlock,
    kMoveToEndOfBlockAndModifySelection,
    kMoveUp,
    kMoveUpAndModifySelection,
    kMoveWordBackward,
    kMoveWordBackwardAndModifySelection,
    kMoveWordForward,
    kMoveWordForwardAndModifySelection,
    
    kPageDown,
    kPageDownAndModifySelection,
    kPageUp,
    kPageUpAndModifySelection,
    
    kSelectAll,
    kSelectCurrentScope,
    kSelectBlock,
    kSelectHardLine,
    kSelectLine,
    kSelectParagraph,
    kSelectWord,
    kToggleColumnSelection,
    
    kFindNext,
    kFindPrevious,
    kFindNextAndModifySelection,
    kFindPreviousAndModifySelection,
    kFindAll,
    kFindAllInSelection,
    
    kReplace,
    kReplaceAll,
    kReplaceAllInSelection,
    
    kReplaceAndFind,
    
    kDeleteBackward,
    kDeleteForward,
    kDeleteSubWordLeft,
    kDeleteSubWordRight,
    kDeleteToBeginningOfIndentedLine,
    kDeleteToBeginningOfLine,
    kDeleteToBeginningOfParagraph,
    kDeleteToEndOfIndentedLine,
    kDeleteToEndOfLine,
    kDeleteToEndOfParagraph,
    kDeleteWordBackward,
    kDeleteWordForward,
    kDeleteBackwardByDecomposingPreviousCharacter,
    kDeleteSelection,
    
    kCut,
    kCopy,
    kCopySelectionToFindPboard,
    kCopySelectionToReplacePboard,
    kCopySelectionToYankPboard,
    kAppendSelectionToYankPboard,
    kPrependSelectionToYankPboard,
    kPaste,
    kPastePrevious,
    kPasteNext,
    kPasteWithoutReindent,
    kYank,
    
    kCapitalizeWord,
    kChangeCaseOfLetter,
    kChangeCaseOfWord,
    kLowercaseWord,
    kReformatText,
    kReformatTextAndJustify,
    kShiftLeft,
    kShiftRight,
    kTranspose,
    kTransposeWords,
    kUnwrapText,
    kUppercaseWord,
    
    kSetMark,
    kDeleteToMark,
    kSelectToMark,
    kSwapWithMark,
    
    kComplete,
    kNextCompletion,
    kPreviousCompletion,
    
    kInsertBacktab,
    kInsertTab,
    kInsertTabIgnoringFieldEditor,
    kInsertNewline,
    kInsertNewlineIgnoringFieldEditor,
    
    kIndent,
    
    kMoveSelectionUp,
    kMoveSelectionDown,
    kMoveSelectionLeft,
    kMoveSelectionRight,
    
    kNop
};

typedef NSInteger action_t;

extern action_t to_action (NSString * sel);

@interface OakEditor : NSObject

@end
