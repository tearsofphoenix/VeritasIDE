
@class OakSelectionIndex;
@class OakSelectionRange;
@class OakSelectionRangeArray;

@class OakScopeSelector;
@class OakTextSelection;
@class OakScopeContext;

enum 
{
    kSelectionMoveLeft,
    kSelectionMoveRight,
    kSelectionMoveFreehandedLeft,
    kSelectionMoveFreehandedRight,
    kSelectionMoveUp,
    kSelectionMoveDown,
    kSelectionMoveToBeginOfSelection,
    kSelectionMoveToEndOfSelection,
    kSelectionMoveToBeginOfSubWord,
    kSelectionMoveToEndOfSubWord,
    kSelectionMoveToBeginOfWord,
    kSelectionMoveToEndOfWord,
    kSelectionMoveToBeginOfSoftLine,
    kSelectionMoveToEndOfSoftLine,
    kSelectionMoveToBeginOfIndentedLine,
    kSelectionMoveToEndOfIndentedLine,
    kSelectionMoveToBeginOfLine,
    kSelectionMoveToEndOfLine,
    kSelectionMoveToBeginOfParagraph,
    kSelectionMoveToEndOfParagraph,
    kSelectionMoveToBeginOfHardParagraph,
    kSelectionMoveToEndOfHardParagraph,
    kSelectionMoveToBeginOfTypingPair,
    kSelectionMoveToEndOfTypingPair,
    kSelectionMoveToBeginOfColumn,
    kSelectionMoveToEndOfColumn,
    kSelectionMovePageUp,
    kSelectionMovePageDown,
    kSelectionMoveToBeginOfDocument,
    kSelectionMoveToEndOfDocument,
    kSelectionMoveNowhere
};

typedef NSInteger move_unit_type;

enum 
{
    kSelectionExtendLeft,
    kSelectionExtendRight,
    kSelectionExtendFreehandedLeft,
    kSelectionExtendFreehandedRight,
    kSelectionExtendUp,
    kSelectionExtendDown,
    kSelectionExtendToBeginOfSubWord,
    kSelectionExtendToEndOfSubWord,
    kSelectionExtendToBeginOfWord,
    kSelectionExtendToEndOfWord,
    kSelectionExtendToBeginOfSoftLine,
    kSelectionExtendToEndOfSoftLine,
    kSelectionExtendToBeginOfIndentedLine,
    kSelectionExtendToEndOfIndentedLine,
    kSelectionExtendToBeginOfLine,
    kSelectionExtendToEndOfLine,
    kSelectionExtendToBeginOfParagraph,
    kSelectionExtendToEndOfParagraph,
    kSelectionExtendToBeginOfTypingPair,
    kSelectionExtendToEndOfTypingPair,
    kSelectionExtendToBeginOfColumn,
    kSelectionExtendToEndOfColumn,
    kSelectionExtendPageUp,
    kSelectionExtendPageDown,
    kSelectionExtendToBeginOfDocument,
    kSelectionExtendToEndOfDocument,
    kSelectionExtendToWord,
    kSelectionExtendToScope,
    kSelectionExtendToSoftLine,
    kSelectionExtendToLineExclLF,
    kSelectionExtendToLine,
    kSelectionExtendToParagraph,
    kSelectionExtendToTypingPair,
    kSelectionExtendToAll
};

typedef NSInteger select_unit_type;


@protocol OakLayoutMovement <NSObject>

- (OakSelectionIndex *)leftIndexOfIndex: (OakSelectionIndex *)index;

- (OakSelectionIndex *)rightIndexOfIndex: (OakSelectionIndex *)index;

- (OakSelectionIndex *)aboveIndexOfIndex: (OakSelectionIndex *)index;

- (OakSelectionIndex *)belowIndexOfIndex: (OakSelectionIndex *)index;

- (OakSelectionIndex *)indexAtBOLOfIndex: (OakSelectionIndex *)index;

- (OakSelectionIndex *)indexAtEOLOfIndex: (OakSelectionIndex *)index;

- (OakSelectionIndex *)pageUpIndexForIndex: (OakSelectionIndex *)index;

- (OakSelectionIndex *)pageDownIndexForIndex: (OakSelectionIndex *)index;

@end

	extern OakSelectionRange * convert (NSString * buffer, OakTextSelection *selection);
	extern BOOL not_empty (NSString * buffer,
                           OakSelectionRange *  selection);
	extern BOOL multiline (NSString * buffer,
                           OakSelectionRange *  selection);
	extern OakSelectionRange * move (NSString * buffer,
                                     OakSelectionRange *  selection,
                                     move_unit_type const unit,
                                     id<OakLayoutMovement> layout);
	extern OakSelectionRange * extend (NSString * buffer,
                                       OakSelectionRange *  selection,
                                       select_unit_type const unit,
                                       id<OakLayoutMovement> const* layout);

	extern OakSelectionRange * extend_if_empty (NSString * buffer,
                                                OakSelectionRange *  selection,
                                                select_unit_type  unit,
                                                id<OakLayoutMovement> * layout);
	extern OakSelectionRange * select_scope (NSString * buffer,
                                             OakSelectionRange *  selection,
                                             OakScopeSelector * scopeSelector);

	extern OakSelectionRange * toggle_columnar (OakSelectionRange *  selection);

	extern OakScopeContext * scope (NSString * buffer,
                                    OakSelectionRange *  selection,
                                    NSString * extraAttributes);

	extern OakSelectionRange * highlight_ranges_for_movement (NSString * buffer,
                                                              OakSelectionRange *  oldSelection,
                                                              OakSelectionRange *  newSelection);
	extern NSDictionary *find (NSString * buffer,
                              OakSelectionRange *  selection,
                              NSString * searchFor,
                              NSStringCompareOptions options,
                              OakSelectionRange *  searchRanges);

	extern NSDictionary *find_all (NSString * buffer,
                                   NSString * searchFor,
                                   NSStringCompareOptions options,
                                   OakSelectionRange *  searchRanges);

	extern OakSelectionRange * all_words (NSString * buffer);

	extern OakSelectionRange * dissect_columnar (NSString * buffer, OakSelectionRange *  selection);

	extern NSString * kCharacterClassWord;
	extern NSString * kCharacterClassSpace;
	extern NSString * kCharacterClassOther;
	extern NSString * kCharacterClassUnknown;

	extern NSString * character_class (NSString * buffer, NSUInteger index);

	extern OakSelectionRange * from_string (NSString * buffer, NSString * str);
	extern NSString * to_s (NSString * buffer, OakSelectionRange *  ranges);
