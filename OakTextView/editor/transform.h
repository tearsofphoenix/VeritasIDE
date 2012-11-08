
namespace transform
{
	NSString * null (NSString * src);
	NSString * unwrap (NSString * src);
	NSString * capitalize (NSString * src);
	NSString * transpose (NSString * src);
	NSString * decompose (NSString * src);

	struct shift
	{
		shift (ssize_t amount, text::indent_t  indent) : amount(amount), indent(indent) { }
		NSString * operator() (NSString * src) ;
	private:
		ssize_t amount;
		text::indent_t indent;
	};

	struct reformat
	{
		reformat (NSUInteger wrap, NSUInteger tabSize, BOOL newlineTerminate = true) : wrap(wrap), tabSize(tabSize), newline(newlineTerminate) { }
		NSString * operator() (NSString * src) ;
	private:
		NSUInteger wrap, tabSize;
		BOOL newline;
	};

	struct justify
	{
		justify (NSUInteger wrap, NSUInteger tabSize, BOOL newlineTerminate = true) : wrap(wrap), tabSize(tabSize), newline(newlineTerminate) { }
		NSString * operator() (NSString * src) ;
	private:
		NSUInteger wrap, tabSize;
		BOOL newline;
	};

	struct replace
	{
		replace (NSString * text) : text(text) { }
		NSString * operator() (NSString * src) ;
	private:
		NSString * text;
	};
	
	struct surround
	{
		surround (NSString * prefix, NSString * suffix) : prefix(prefix), suffix(suffix) { }
		NSString * operator() (NSString * src) ;
	private:
		NSString * prefix, suffix;
	};
	
} /* transform */ 
