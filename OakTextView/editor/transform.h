
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
		NSString * operator() (NSString * src) const;
	private:
		ssize_t amount;
		text::indent_t indent;
	};

	struct reformat
	{
		reformat (NSUInteger wrap, NSUInteger tabSize, bool newlineTerminate = true) : wrap(wrap), tabSize(tabSize), newline(newlineTerminate) { }
		NSString * operator() (NSString * src) const;
	private:
		NSUInteger wrap, tabSize;
		bool newline;
	};

	struct justify
	{
		justify (NSUInteger wrap, NSUInteger tabSize, bool newlineTerminate = true) : wrap(wrap), tabSize(tabSize), newline(newlineTerminate) { }
		NSString * operator() (NSString * src) const;
	private:
		NSUInteger wrap, tabSize;
		bool newline;
	};

	struct replace
	{
		replace (NSString * text) : text(text) { }
		NSString * operator() (NSString * src) const;
	private:
		NSString * text;
	};
	
	struct surround
	{
		surround (NSString * prefix, NSString * suffix) : prefix(prefix), suffix(suffix) { }
		NSString * operator() (NSString * src) const;
	private:
		NSString * prefix, suffix;
	};
	
} /* transform */ 
