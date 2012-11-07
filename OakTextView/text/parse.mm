#include "parse.h"
#include "OakTextCtype.h"
#include "utf8.h"

NSArray *soft_breaks (NSString * str, NSUInteger width, NSUInteger tabSize, NSUInteger prefixSize)
{
    NSMutableArray *res = [NSMutableArray array];
    
    NSUInteger col = 0, len = 0, spaceCol = 0, spaceLen = 0;
    const char* cString = [str UTF8String];
    
    for(const char* ch = cString; ch; ++ch)
    {
        NSUInteger prevLen = len, prevCol = col;
        len += 1;
        
        col += (*ch == '\t' ? tabSize - (col % tabSize) : (text::OakTextIsEastAsianWidth(*ch) ? 2 : 1));
        
        if(*ch == '\n')
        {
            col = 0;
            
            spaceLen = len;
            spaceCol = col;
        }
        else if(col > width)
        {
            if(spaceCol == 0)
            {
                [res addObject:  @(prevLen)];
                width -= prefixSize;
                prefixSize = 0;
                col = col - prevCol;
            }
            else
            {
                [res addObject: @(spaceLen)];
                width -= prefixSize;
                prefixSize = 0;
                col = col - spaceCol;
                spaceCol = 0;
                
                if(col > width) // Backtrack if text right of the soft break is still too wide: this can only happen for second line of indented soft wrap where the width is decreased after the first break.
                {
                    ch = cString + spaceLen;
                    len = spaceLen + 1;
                    col = (*ch == '\t' ? tabSize : 1);
                }
            }
        }
        else if(*ch == ' ')
        {
            spaceLen = len;
            spaceCol = col;
        }
    }
    return res;
}