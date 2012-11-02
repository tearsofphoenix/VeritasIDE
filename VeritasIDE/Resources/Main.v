@import "Test.v"

@interface VeritasTest : NSObject

- (id)init
{
    if((self = [super init]))
    {
        print("Hello, in function:", _cmd)
    }
    
    return self
}

- (void)doSomething
{
    local iLoveVeritas = YES
    if(iLoveVeritas)
    {
        local sheLoveMeToo = YES
        if(sheLoveMeToo)
        {
            [self iShouldDoBetterThanNow];
            
        }else
        {
            [self iShouldDoBetterToLetHerLoveMe]
        }
        
    }else
    {
        [self thisIsImpossible]
    }
}

@end

main = function()
    test()
end