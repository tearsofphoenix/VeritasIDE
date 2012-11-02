//
//  VDEProjectFileParser.m
//  VeritasIDE
//
//  Created by LeixSnake on 10/25/12.
//
//

#import "VDEProjectFileParser.h"
#import "VDEProjectConfiguration.h"




/**
 * The number of (unicode) characters to fetch from the source at once.
 */
#define BUFFER_SIZE 64

/**
 * Structure for storing the internal state of the parser.  An instance of this
 * is allocated on the stack, and a copy of it passed down to each parse
 * function.
 */
typedef struct ParserStateStruct
{
    /**
     * The data source.  This is either an NSString or an NSStream, depending on
     * the source.
     */
    id source;
    /**
     * The length of the byte order mark in the source.  0 if there is no BOM.
     */
    int BOMLength;
    /**
     * The string encoding used in the source.
     */
    NSStringEncoding enc;
    /**
     * Function used to pull the next BUFFER_SIZE characters from the string.
     */
    void (*updateBuffer)(struct ParserStateStruct*);
    /**
     * Buffer used to store the next data from the input stream.
     */
    unichar buffer[BUFFER_SIZE];
    /**
     * The index of the parser within the buffer.
     */
    NSUInteger bufferIndex;
    /**
     * The number of bytes stored within the buffer.
     */
    NSUInteger bufferLength;
    /**
     * The index of the parser within the source.
     */
    NSInteger sourceIndex;
    /**
     * Should the parser construct mutable string objects?
     */
    BOOL mutableStrings;
    /**
     * Should the parser construct mutable containers?
     */
    BOOL mutableContainers;
    /**
     * Error value, if this parser is currently in an error state, nil otherwise.
     */
    NSError *error;
} ParserState;

/**
 * Pulls the next group of characters from a string source.
 */
static inline void
updateStringBuffer(ParserState* state)
{
    NSRange r = {state->sourceIndex, BUFFER_SIZE};
    NSUInteger end = [state->source length];
    
    if (end - state->sourceIndex < BUFFER_SIZE)
    {
        r.length = end - state->sourceIndex;
    }
    [state->source getCharacters: state->buffer range: r];
    state->sourceIndex = r.location;
    state->bufferIndex = 0;
    state->bufferLength = r.length;
    if (r.length == 0)
    {
        state->buffer[0] = 0;
    }
}

static inline void
updateStreamBuffer(ParserState* state)
{
    NSInputStream *stream = state->source;
    uint8_t *buffer;
    NSUInteger length;
    NSString *str;
    
    // Discard anything that we've already consumed
    while (state->sourceIndex > 0)
    {
        uint8_t discard[128];
        NSUInteger toRead = 128;
        NSInteger amountRead;
        
        if (state->sourceIndex < 128)
        {
            toRead = state->sourceIndex;
        }
        amountRead = [stream read: discard maxLength: toRead];
        /* If something goes wrong with the stream, return the stream
         * error as our error.
         */
        if (amountRead == 0)
        {
            state->error = [stream streamError];
            state->bufferIndex = 0;
            state->bufferLength = 0;
            state->buffer[0] = 0;
        }
        state->sourceIndex -= amountRead;
    }
    
    /* Get the temporary buffer.  We need to read from here so that we can read
     * characters from the stream without advancing the stream position.
     * If the stream doesn't do buffering, then we need to get data one character
     * at a time.
     */
    if (![stream getBuffer: &buffer length: &length])
    {
        uint8_t bytes[7] = { 0 };
        
        switch (state->enc)
        {
            case NSUTF8StringEncoding:
            {
                int i = -1;
                
                // Read one UTF8 character from the stream
                do
                {
                    [stream read: &bytes[++i] maxLength: 1];
                }
                while (bytes[i] & 0xf);
                if (0 == i)
                {
                    state->buffer[0] = bytes[0];
                }
                else
                {
                    str = [[NSString alloc] initWithUTF8String: (char*)bytes];
                    [str getCharacters: state->buffer range: NSMakeRange(0,1)];
                    [str release];
                }
                break;
            }
            case NSUTF32LittleEndianStringEncoding:
            {
                [stream read: bytes maxLength: 4];
                state->buffer[0] = (unichar)NSSwapLittleIntToHost
                (*(unsigned int*)(void*)bytes);
                break;
            }
            case NSUTF32BigEndianStringEncoding:
            {
                [stream read: bytes maxLength: 4];
                state->buffer[0] = (unichar)NSSwapBigIntToHost
                (*(unsigned int*)(void*)bytes);
                break;
            }
            case NSUTF16LittleEndianStringEncoding:
            {
                [stream read: bytes maxLength: 2];
                state->buffer[0] = (unichar)NSSwapLittleShortToHost
                (*(unichar*)(void*)bytes);
                break;
            }
            case NSUTF16BigEndianStringEncoding:
            {
                [stream read: bytes maxLength: 4];
                state->buffer[0] = (unichar)NSSwapBigShortToHost
                (*(unichar*)(void*)bytes);
                break;
            }
            default:
            {
                break;
            }
        }
        // Set the source index to -1 so it will be 0 when we've finished with it
        state->sourceIndex = -1;
        state->bufferIndex = 0;
        state->bufferLength = 1;
    }
    // Use an NSString to do the character set conversion.  We could do this more
    // efficiently.  We could also reuse the string.
    str = [[NSString alloc] initWithBytesNoCopy: buffer
                                         length: length
                                       encoding: state->enc
                                   freeWhenDone: NO];
    // Just use the string buffer fetch function to actually get the data
    state->source = str;
    updateStringBuffer(state);
    state->source = stream;
}

/**
 * Returns the current character.
 */
static inline unichar
currentChar(ParserState *state)
{
    if (state->bufferIndex >= state->bufferLength)
    {
        state->updateBuffer(state);
    }
    return state->buffer[state->bufferIndex];
}

/**
 * Consumes a character.
 */
static inline unichar consumeChar(ParserState *state)
{
    state->sourceIndex++;
    state->bufferIndex++;
    
    if (state->bufferIndex >= BUFFER_SIZE)
    {
        state->updateBuffer(state);
    }
    
    return currentChar(state);
}

/**
 * Consumes all whitespace characters and returns the first non-space
 * character.  Returns 0 if we're past the end of the input.
 */
static inline unichar consumeSpace(ParserState *state)
{
    while (isspace(currentChar(state)))
    {
        consumeChar(state);
    }
    
    return currentChar(state);
}

/**
 * Sets an error state.
 */
static void
parseError(ParserState *state)
{
    /* TODO: Work out what stuff should go in this and probably add them to
     * parameters for this function.
     */
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"JSON Parse error", NSLocalizedDescriptionKey,
                              [NSString stringWithFormat: @"Unexpected character %c at index %ld",
                               (char)currentChar(state), state->sourceIndex],
                              NSLocalizedFailureReasonErrorKey,
                              nil];
    state->error = [NSError errorWithDomain: NSCocoaErrorDomain
                                       code: 0
                                   userInfo: userInfo];
    [userInfo release];
}


static id parseValue(ParserState *state);

/**
 * Parse a string, as defined by RFC4627, section 2.5
 */
static NSString*
parseString(ParserState *state)
{
    unichar buffer[BUFFER_SIZE];
    int bufferIndex = 0;
    unichar next;
    
    if (state->error)
    {
        return nil;
    }
    
    if (currentChar(state) != '"')
    {
        parseError(state);
        return nil;
    }
    
    NSMutableString *val = [NSMutableString string];
    
    next = consumeChar(state);
    while ((next != 0) && (next != '"'))
    {
        // Unexpected end of stream
        if (next == '\\')
        {
            next = consumeChar(state);
            switch (next)
            {
                    // Simple escapes, just ignore the leading '
                case '"':
                case '\\':
                case '/':
                    break;
                    // Map to the unicode values specified in RFC4627
                case 'b': next = 0x0008; break;
                case 'f': next = 0x000c; break;
                case 'n': next = 0x000a; break;
                case 'r': next = 0x000d; break;
                case 't': next = 0x0009; break;
                    // decode a unicode value from 4 hex digits
                case 'u':
                {
                    char hex[5] = {0};
                    unsigned i;
                    for (i = 0 ; i < 4 ; i++)
                    {
                        next = consumeChar(state);
                        if (!isxdigit(next))
                        {
                            parseError(state);
                            return nil;
                        }
                        hex[i] = next;
                    }
                    // Parse 4 hex digits and a NULL terminator into a 16-bit
                    // unicode character ID.
                    next = (unichar)strtol(hex, 0, 16);
                }
            }
        }
        buffer[bufferIndex++] = next;
        if (bufferIndex >= BUFFER_SIZE)
        {
            NSMutableString *str = [[NSMutableString alloc] initWithCharacters: buffer
                                                                        length: bufferIndex];
            bufferIndex = 0;
            
            [val appendString: str];
            [str release];
        }
        next = consumeChar(state);
    }
    
    if (bufferIndex > 0)
    {
        NSMutableString *str = [[NSMutableString alloc] initWithCharacters: buffer
                                                                    length: bufferIndex];
        
        [val appendString: str];
        [str release];
    }
    
    NSString *ret = nil;
    if (!state->mutableStrings)
    {
        ret = [NSString stringWithString: val];
    }else
    {
        ret = val;
    }
    // Consume the trailing "
    consumeChar(state);
    return ret;
}

/**
 * Parses a number, as defined by section 2.4 of the JSON specification.
 */
static NSNumber*
parseNumber(ParserState *state)
{
    unichar c = currentChar(state);
    char numberBuffer[128];
    char *number = numberBuffer;
    int bufferSize = 128;
    int parsedSize = 0;
    double num;
    
    // Define a macro to add a character to the buffer, because we'll need to do
    // it a lot.  This resizes the buffer if required.
#define BUFFER(x) do {\
                        if (parsedSize == bufferSize)\
                        {\
                            bufferSize *= 2;\
                            if (number == numberBuffer)\
                                number = malloc(bufferSize);\
                            else\
                                number = realloc(number, bufferSize);\
                        }\
                        number[parsedSize++] = (char)x;\
                    } while (0)
    
    // JSON numbers must start with a - or a digit
    if (!(c == '-' || isdigit(c)))
    {
        parseError(state);
        return nil;
    }
    // digit or -
    BUFFER(c);
    // Read as many digits as we see
    while (isdigit(c = consumeChar(state)))
    {
        BUFFER(c);
    }
    // Parse the fractional component, if there is one
    if ('.' == c)
    {
        BUFFER(c);
        while (isdigit(c = consumeChar(state)))
        {
            BUFFER(c);
        }
    }
    // parse the exponent if there is one
    if ('e' == tolower(c))
    {
        BUFFER(c);
        c = consumeChar(state);
        // The exponent must be a valid number
        if (!(c == '-' || c == '+' || isdigit(c)))
        {
            if (number != numberBuffer)
            {
                free(number);
            }
        }
        BUFFER(c);
        while (isdigit(c = consumeChar(state)))
        {
            BUFFER(c);
        }
    }
    // Add a null terminator on the buffer.
    BUFFER(0);
    num = strtod(number, 0);
    if (number != numberBuffer)
    {
        free(number);
    }
    return [[[NSNumber alloc] initWithDouble: num] autorelease];
#undef BUFFER
}
/**
 * Parse an array, as described by section 2.3 of RFC 4627.
 */
static NSArray*
parseArray(ParserState *state)
{
    unichar c = consumeSpace(state);
    
    if (c != '[')
    {
        parseError(state);
        return nil;
    }
    // Eat the [
    consumeChar(state);
    NSMutableArray *array = [NSMutableArray array];
    c = consumeSpace(state);
    while (c != ']')
    {
        // If this fails, it will already set the error, so we don't have to.
        id obj = parseValue(state);
        if (!obj)
        {
            return nil;
        }
        [array addObject: obj];
        
        c = consumeSpace(state);
        if (c == ',')
        {
            consumeChar(state);
            c = consumeSpace(state);
        }
    }
    // Eat the trailing ]
    consumeChar(state);
    NSArray *ret = nil;
    if (!state->mutableContainers)
    {
        ret = [NSArray arrayWithArray: array];
    }else
    {
        ret = array;
    }
    return ret;
}

static NSDictionary * parseObject(ParserState *state)
{
    unichar c = consumeSpace(state);
    
    if (c != '{')
    {
        parseError(state);
        return nil;
    }
    
    // Eat the {
    consumeChar(state);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    c = consumeSpace(state);
    
    while (c != '}')
    {
        id key = parseString(state);
        
        if (!key)
        {
            return nil;
        }
        c = consumeSpace(state);
        if (':' != c)
        {
            parseError(state);
            return nil;
        }
        // Eat the :
        consumeChar(state);
        id obj = parseValue(state);
        if (!obj)
        {
            return nil;
        }
        [dict setObject: obj
                 forKey: key];
        
        c = consumeSpace(state);
        if (c == ',')
        {
            consumeChar(state);
        }
        c = consumeSpace(state);
    }
    // Eat the trailing }
    consumeChar(state);
    NSDictionary *ret = nil;
    if (!state->mutableContainers)
    {
        ret = [NSDictionary dictionaryWithDictionary: dict];
    }else
    {
        ret = dict;
    }
    return ret;
    
}

/**
 * Parses a JSON value, as defined by RFC4627, section 2.1.
 */
static id parseValue(ParserState *state)
{
    unichar c;
    
    if (state->error)
    {
        return nil;
    };
    
    //jumpover spaces
    //
    c = consumeSpace(state);
    
    //   2.1: A JSON value MUST be an object, array, number, or string, or one of the
    //   following three literal names:
    //            false null true
    switch (c)
    {
        case 'A' ... 'Z':
        case 'a' ... 'z':
            return parseString(state);
        case (unichar)'[':
        {
            return parseArray(state);
        }
        case (unichar)'{':
        {
            return parseObject(state);
        }
        case (unichar)'-':
        case (unichar)'0' ... (unichar)'9':
            return parseNumber(state);
    }
    
    parseError(state);
    
    return nil;
}

/**
 * We have to autodetect the string encoding.  We know that it is some
 * unicode encoding, which may or may not contain a BOM.  If it contains a
 * BOM, then we need to skip that.  If it doesn't, then we need to work out
 * the encoding from the position of the NULLs.  The first two characters are
 * guaranteed to be ASCII in a JSON stream, so we can work out the encoding
 * from the pattern of NULLs.
 */

static void getEncoding(const uint8_t BOM[4], ParserState *state)
{
    NSStringEncoding enc = NSUTF8StringEncoding;
    int BOMLength = 0;
    
    if ((BOM[0] == 0xEF) && (BOM[1] == 0xBB) && (BOM[2] == 0xBF))
    {
        BOMLength = 3;
    }
    else if ((BOM[0] == 0xFE) && (BOM[1] == 0xFF))
    {
        BOMLength = 2;
        enc = NSUTF16BigEndianStringEncoding;
    }
    else if ((BOM[0] == 0xFF) && (BOM[1] == 0xFE))
    {
        if ((BOM[2] == 0) && (BOM[3] == 0))
        {
            BOMLength = 4;
            enc = NSUTF32LittleEndianStringEncoding;
        }
        else
        {
            BOMLength = 2;
            enc = NSUTF16LittleEndianStringEncoding;
        }
    }
    else if ((BOM[0] == 0)
             && (BOM[1] == 0)
             && (BOM[2] == 0xFE)
             && (BOM[3] == 0xFF))
    {
        BOMLength = 4;
        enc = NSUTF32BigEndianStringEncoding;
    }
    else if (BOM[0] == 0)
    {
        // TODO: Throw an error if this doesn't match one of the patterns
        // described in section 3 of RFC4627
        if (BOM[1] == 0)
        {
            enc = NSUTF32BigEndianStringEncoding;
        }
        else
        {
            enc = NSUTF16BigEndianStringEncoding;
        }
    }
    else if (BOM[1] == 0)
    {
        if (BOM[2] == 0)
        {
            enc = NSUTF32LittleEndianStringEncoding;
        }
        else
        {
            enc = NSUTF16LittleEndianStringEncoding;
        }
    }
    state->enc = enc;
    state->BOMLength = BOMLength;
}

/**
 * Classes that are permitted to be written.
 */
static Class NSNullClass, NSArrayClass, NSStringClass, NSDictionaryClass,
NSNumberClass;

static inline void
writeTabs(NSMutableString *output, NSInteger tabs)
{
    NSInteger i;
    
    for (i = 0 ; i < tabs ; i++)
    {
        [output appendString: @"\t"];
    }
}

static inline void
writeNewline(NSMutableString *output, NSInteger tabs)
{
    if (tabs >= 0)
    {
        [output appendString: @"\n"];
    }
}


@implementation VDEProjectFileParser


+ (void) initialize
{
    NSNullClass = [NSNull class];
    NSArrayClass = [NSArray class];
    NSStringClass = [NSString class];
    NSDictionaryClass = [NSDictionary class];
    NSNumberClass = [NSNumber class];
}

+ (id) JSONObjectWithData: (NSData *)data
                  options: (NSJSONReadingOptions)opt
                    error: (NSError **)error
{
    uint8_t BOM[4];
    ParserState p;
    
    [data getBytes: BOM
            length: 4];
    
    getEncoding(BOM, &p);
    
    p.source = [[NSString alloc] initWithData: data
                                     encoding: p.enc];
    
    p.updateBuffer = updateStringBuffer;
    p.mutableContainers
    = (opt & NSJSONReadingMutableContainers) == NSJSONReadingMutableContainers;
    p.mutableStrings
    = (opt & NSJSONReadingMutableLeaves) == NSJSONReadingMutableLeaves;
    
    id obj = parseValue(&p);
    
    [p.source release];
    
    if (NULL != error)
    {
        *error = p.error;
    }
    
    return obj;
}

+ (id)parseFileContent: (NSString *)fileContent
{
    //try to find the `!$*UTF8*$!' encoding tag
    VDEProjectConfiguration *projectConfiguration = [[VDEProjectConfiguration alloc] init];
    
    NSRange encodingTagRange = [fileContent rangeOfString: @"^\\s*//\\s*\\!\\$\\*[A-Za-z0-9]+\\*\\$\\!"
                                                  options: NSRegularExpressionSearch];
    if (encodingTagRange.location != NSNotFound)
    {
        //get the name of encoding
        //
        NSString *encodingTag = [fileContent substringWithRange: encodingTagRange];
        encodingTagRange = [encodingTag rangeOfString: @"[A-Za-z0-9]+"
                                              options: NSRegularExpressionSearch];
        encodingTag = [encodingTag substringWithRange: encodingTagRange];
        
        NSLog(@"encoding: %@", encodingTag);
        
        [projectConfiguration setProjectFileEncodingName: encodingTag];
        
        //start to parse configuration
        
    }
    
    return [projectConfiguration autorelease];
}

@end
