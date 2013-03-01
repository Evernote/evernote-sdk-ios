//
//  KSXMLWriter.m
//
//  Copyright (c) 2010, Mike Abdullah and Karelia Software
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import "KSXMLWriter.h"
#import "NSString+XMLAdditions.h"


@interface KSXMLElementContentsProxy : NSProxy
{
@private
  id          _target;        // weak ref
  KSXMLWriter *_XMLWriter;    // weak ref
  NSUInteger  _elementsCount;
}
- (void)ks_prepareWithTarget:(id)target XMLWriter:(KSXMLWriter *)writer;
@end


#pragma mark -


@interface KSXMLWriter ()

- (void)writeStringByEscapingXMLEntities:(NSString *)string escapeQuot:(BOOL)escapeQuotes;

#pragma mark Element Primitives

//   attribute="value"
- (void)writeAttribute:(NSString *)attribute
                 value:(id)value;

//  Starts tracking -writeString: calls to see if element is empty
- (void)didStartElement;

//  >
//  Then increases indentation level
- (void)closeStartTag;

//   />
- (void)closeEmptyElementTag;             

- (void)writeEndTag:(NSString *)tagName;    // primitive version that ignores open elements stack

- (BOOL)elementCanBeEmpty:(NSString *)tagName;  // YES for everything in pure XML

@property(nonatomic, readwrite) NSStringEncoding encoding;   // default is UTF-8

@end


@interface KSXMLAttributes (KSXMLWriter)
- (void)writeAttributes:(KSXMLWriter *)writer;
@end


#pragma mark -


@implementation KSXMLWriter

#pragma mark Init & Dealloc

- (id)initWithOutputWriter:(id <KSWriter>)output; // designated initializer
{
  self = [super initWithOutputWriter:output];
  if (self != nil) {
    _attributes = [[KSXMLAttributes alloc] init];
    _openElements = [[NSMutableArray alloc] init];
    
    // Inherit encoding where possible
    _encoding = ([output respondsToSelector:@selector(encoding)] ?
                 [(KSXMLWriter *)output encoding] :
                 NSUTF8StringEncoding);
    
    _contentsProxy = [KSXMLElementContentsProxy alloc]; // it's a proxy without an -init method
  }
  return self;
}

- (id)initWithOutputWriter:(id <KSWriter>)output encoding:(NSStringEncoding)encoding;
{
  if (self = [self initWithOutputWriter:output])
  {
    [self setEncoding:encoding];
  }
  
  return self;
}


#pragma mark Writer Status

- (void)close;
{
  [self flush];
  [super close];
}

- (void)flush; { }

#pragma mark Document

- (void)startDocumentWithDocType:(NSString *)docType encoding:(NSStringEncoding)encoding;
{
  [self writeString:@"<!DOCTYPE "];
  [self writeString:docType];
  [self writeString:@">"];
  [self startNewline];
  
  [self setEncoding:encoding];
}

#pragma mark Characters

- (void)writeCharacters:(NSString *)string;
{
  // Quotes are acceptable characters outside of attribute values
  [self writeStringByEscapingXMLEntities:string escapeQuot:NO];
}

+ (NSString *)stringFromCharacters:(NSString *)string;
{
	NSMutableString *result = [NSMutableString string];
  
  KSXMLWriter *writer = [[self alloc] initWithOutputWriter:result];
  [writer writeCharacters:string];
  
  return result;
}

#pragma mark Elements

- (id)writeElement:(NSString *)elementName contentsInvocationTarget:(id)target;
{
  [self startElement:elementName];
  
  [_contentsProxy ks_prepareWithTarget:target XMLWriter:self];
  return _contentsProxy;
}

- (void)writeElement:(NSString *)elementName text:(NSString *)text;
{
  [self startElement:elementName attributes:nil];
  [self writeCharacters:text];
  [self endElement];
}

- (void)startElement:(NSString *)elementName;
{
  [self startElement:elementName writeInline:[self canWriteElementInline:elementName]];
}

- (void)startElement:(NSString *)elementName writeInline:(BOOL)writeInline;
{
  // Can only write suitable tags inline if containing element also allows it
  if (!writeInline)
  {
    [self startNewline];
    [self stopWritingInline];
  }
  
  // Warn of impending start
  [self willStartElement:elementName];
  
  [self writeString:@"<"];
  [self writeString:elementName];
  
  // Must do this AFTER writing the string so subclasses can take early action in a -writeString: override
  [self pushElement:elementName];
  [self startWritingInline];
  
  
  // Write attributes
  [_attributes writeAttributes:self];
  [_attributes close];
  
  
  [self didStartElement];
  [self increaseIndentationLevel];
}

- (void)startElement:(NSString *)elementName attributes:(NSDictionary *)attributes;
{
  for (NSString *aName in attributes)
  {
    NSString *aValue = [attributes objectForKey:aName];
    [self pushAttribute:aName value:aValue];
  }
  
  [self startElement:elementName];
}

- (void)willStartElement:(NSString *)element; { /* for subclassers */ }

- (void)endElement;
{
  // Handle whitespace
	[self decreaseIndentationLevel];
  if (![self isWritingInline]) [self startNewline];   // was this element written entirely inline?
  
  
  // Write the tag itself.
  if (_elementIsEmpty)
  {
    [self popElement];  // turn off _elementIsEmpty first or regular start tag will be written!
    [self closeEmptyElementTag];
  }
  else
  {
    [self writeEndTag:[self topElement]];
    [self popElement];
  }
}

- (void)pushElement:(NSString *)element;
{
  // Private method so that Sandvox can work for now
  [_openElements addObject:element];
}

- (void)popElement;
{
  _elementIsEmpty = NO;
  
  [_openElements removeLastObject];
  
  // Time to cancel inline writing?
  if (![self isWritingInline]) [self stopWritingInline];
}

#pragma mark Current Element

- (void)pushAttribute:(NSString *)attribute value:(id)value; // call before -startElement:
{
  [_attributes addAttribute:attribute value:value];
}

- (KSXMLAttributes *)currentAttributes;
{
  KSXMLAttributes *result = [_attributes copy];
  return result;
}

- (BOOL)hasCurrentAttributes;
{
  return [_attributes hasAttributes];
}

#pragma mark Attributes

- (void)writeAttributeValue:(NSString *)value;
{
  // Make sure that we're not double-escaping XML entities
  NSString *unescapedString = [value stringByUnescapingCrititcalXMLEntities];
  [self writeStringByEscapingXMLEntities:unescapedString escapeQuot:YES];	// make sure to escape the quote mark
}

+ (NSString *)stringFromAttributeValue:(NSString *)value;
{
  NSMutableString *result = [NSMutableString string];
  
  KSXMLWriter *writer = [[self alloc] initWithOutputWriter:result];
  [writer writeAttributeValue:value];
  
  return result;
}

- (void)writeAttribute:(NSString *)attribute
                 value:(id)value;
{
	NSString *valueString = [value description];
	
  [self writeString:@" "];
  [self writeString:attribute];
  if (value != [NSNull null]) {
    [self writeString:@"=\""];
    [self writeAttributeValue:valueString];
    [self writeString:@"\""];
  }
}

#pragma mark Whitespace

- (void)startNewline;   // writes a newline character and the tabs to match -indentationLevel
{
  [self writeString:@"\n"];
  
  for (int i = 0; i < [self indentationLevel]; i++)
  {
    [self writeString:@"\t"];
  }
}

#pragma mark Comments

- (void)writeComment:(NSString *)comment;   // escapes the string, and wraps in a comment tag
{
  [self openComment];
  [self writeStringByEscapingXMLEntities:comment escapeQuot:YES];
  [self closeComment];
}

- (void)openComment;
{
  [self writeString:@"<!--"];
}

- (void)closeComment;
{
  [self writeString:@"-->"];
}

#pragma mark CDATA

- (void)startCDATA;
{
  [self writeString:@"<![CDATA["];
}

- (void)endCDATA;
{
  [self writeString:@"]]>"];
}

#pragma mark Indentation

@synthesize indentationLevel = _indentation;

- (void)increaseIndentationLevel;
{
  [self setIndentationLevel:[self indentationLevel] + 1];
}

- (void)decreaseIndentationLevel;
{
  [self setIndentationLevel:[self indentationLevel] - 1];
}

#pragma mark Validation

- (BOOL)validateElement:(NSString *)element;
{
  NSParameterAssert(element);
  return YES;
}

- (NSString *)validateAttribute:(NSString *)name value:(NSString *)value ofElement:(NSString *)element;
{
  NSParameterAssert(name);
  NSParameterAssert(element);
  return value;
}

#pragma mark Elements Stack

- (BOOL)canWriteElementInline:(NSString *)tagName;
{
  // In standard XML, no elements can be inline, unless it's the start of the doc
  return (_inlineWritingLevel == 0);
}

- (NSArray *)openElements; { return [_openElements copy]; }

- (NSUInteger)openElementsCount;
{
  return [_openElements count];
}

- (BOOL)hasOpenElement:(NSString *)tagName;
{
  // Seek an open element, matching case insensitively
  for (NSString *anElement in _openElements)
  {
    if ([anElement isEqualToString:tagName])
    {
      return YES;
    }
  }
  
  return NO;
}

- (NSString *)topElement;
{
  return [_openElements lastObject];
}

#pragma mark Element Primitives

- (void)didStartElement;
{
  // For elements which can't be empty, might as well go ahead and close the start tag now
  _elementIsEmpty = [self elementCanBeEmpty:[self topElement]];
  if (!_elementIsEmpty) [self closeStartTag];
}

- (void)closeStartTag;
{
  [self writeString:@">"];
}

- (void)closeEmptyElementTag; { [self writeString:@" />"]; }

- (void)writeEndTag:(NSString *)tagName;    // primitive version that ignores open elements stack
{
  [self writeString:@"</"];
  [self writeString:tagName];
  [self writeString:@">"];
}

- (BOOL)elementCanBeEmpty:(NSString *)tagName; { return YES; }

#pragma mark Inline Writing

/*! How it works:
 *
 *  _inlineWritingLevel records the number of objects in the Elements Stack at the point inline writing began (-startWritingInline).
 *  A value of NSNotFound indicates that we are not writing inline (-stopWritingInline). This MUST be done whenever about to write non-inline content (-openTag: does so automatically).
 *  Finally, if _inlineWritingLevel is 0, this is a special value to indicate we're at the start of the document/section, so the next element to be written is inline, but then normal service shall resume.
 */

- (BOOL)isWritingInline;
{
  return ([self openElementsCount] >= _inlineWritingLevel);
}

- (void)startWritingInline;
{
  // Is it time to switch over to inline writing? (we may already be writing inline, so can ignore request)
  if (_inlineWritingLevel >= NSNotFound || _inlineWritingLevel == 0)
  {
    _inlineWritingLevel = [self openElementsCount];
  }
}

- (void)stopWritingInline; { _inlineWritingLevel = NSNotFound; }

static NSCharacterSet *sCharactersToEntityEscapeWithQuot;
static NSCharacterSet *sCharactersToEntityEscapeWithoutQuot;

+ (void)initialize
{
  // Cache the characters to be escaped. Doing it in +initialize should be threadsafe
	if (!sCharactersToEntityEscapeWithQuot)
  {
    // Don't want to escape apostrophes for HTML, but do for Javascript
    sCharactersToEntityEscapeWithQuot = [NSCharacterSet characterSetWithCharactersInString:@"&<>\""];
  }
  if (!sCharactersToEntityEscapeWithoutQuot)
  {
    sCharactersToEntityEscapeWithoutQuot = [NSCharacterSet characterSetWithCharactersInString:@"&<>"];
  }
}

/*!	Escape & < > " ... does NOT escape anything else.  Need to deal with character set in subsequent pass.
 Escaping " so that strings work within HTML tags
 */

// Explicitly escape, or don't escape, double-quots as &quot;
// Within a tag like <foo attribute="%@"> then we have to escape it.
// In just about all other contexts it's OK to NOT escape it, but many contexts we don't know if it's OK or not.
// So I think we want to gradually shift over to being explicit when we know when it's OK or not.
- (void)writeStringByEscapingXMLEntities:(NSString *)string escapeQuot:(BOOL)escapeQuotes;
{
  NSCharacterSet *charactersToEntityEscape = (escapeQuotes ?
                                              sCharactersToEntityEscapeWithQuot :
                                              sCharactersToEntityEscapeWithoutQuot);
  
  // Look for characters to escape. If there are none can bail out quick without having had to allocate anything. #78710
  NSRange searchRange = NSMakeRange(0, [string length]);
  NSRange range = [string rangeOfCharacterFromSet:charactersToEntityEscape options:0 range:searchRange];
  if (range.location == NSNotFound) return [self writeString:string];
  
  
  while (searchRange.length)
	{
    // Write characters not needing to be escaped. Don't bother if there aren't any
		NSRange unescapedRange = searchRange;
    if (range.location != NSNotFound)
    {
      unescapedRange.length = range.location - searchRange.location;
    }
    if (unescapedRange.length)
    {
      [self writeString:[string substringWithRange:unescapedRange]];
    }
    
    
		// Process characters that need escaping
		if (range.location != NSNotFound)
    {            
      NSAssert(range.length == 1, @"trying to escaping non-single character string");    // that's all we should deal with for HTML escaping
			
      unichar ch = [string characterAtIndex:range.location];
      switch (ch)
      {
        case '&':	[self writeString:@"&amp;"];    break;
        case '<':	[self writeString:@"&lt;"];     break;
        case '>':	[self writeString:@"&gt;"];     break;
        case '"':	[self writeString:@"&quot;"];   break;
        default:    [self writeString:[NSString stringWithFormat:@"&#%d;",ch]];
      }
		}
    else
    {
      break;  // no escapable characters were found so we must be done
    }
    
    
    // Continue the search
    searchRange.location = range.location + range.length;
    searchRange.length = [string length] - searchRange.location;
    range = [string rangeOfCharacterFromSet:charactersToEntityEscape options:0 range:searchRange];
	}	
}

#pragma mark String Encoding

@synthesize encoding = _encoding;
- (void)setEncoding:(NSStringEncoding)encoding;
{
  if ( ! (	encoding == NSASCIIStringEncoding
          ||	encoding == NSUTF8StringEncoding
          ||	encoding == NSISOLatin1StringEncoding
          ||	encoding == NSUnicodeStringEncoding ) )
  {
    CFStringRef encodingName = CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding(encoding));
    
    [NSException raise:NSInvalidArgumentException
                format:@"Unsupported character encoding %@ (%u)", encodingName, (unsigned)encoding];
  }
	
  
	_encoding = encoding;
}

- (void)writeString:(NSString *)string;
{
	NSParameterAssert(nil != string); 
  // Is this string some element content? If so, the element is no longer empty so must close the tag and mark as such
  if (_elementIsEmpty && [string length])
  {
    _elementIsEmpty = NO;   // comes first to avoid infinte recursion
    [self closeStartTag];
  }
  
  
  CFRange range = CFRangeMake(0, CFStringGetLength((__bridge CFStringRef)string));
  
  while (range.length)
  {
    CFIndex written = CFStringGetBytes((__bridge CFStringRef)string,
                                       range,
                                       CFStringConvertNSStringEncodingToEncoding([self encoding]),
                                       0,                   // don't convert invalid characters
                                       NO,
                                       NULL,                // not interested in actually getting the bytes
                                       0,
                                       NULL);
    
    if (written < range.length) // there was an invalid character
    {
      // Write what is valid
      if (written)
      {
        NSRange validRange = NSMakeRange(range.location, written);
        [super writeString:[string substringWithRange:validRange]];
      }
      
      // Convert the invalid char
      unichar ch = [string characterAtIndex:(range.location + written)];
      switch (ch)
      {
          // If we encounter a special character with a symbolic entity, use that
        case 160:	[super writeString:@"&nbsp;"];      break;
        case 169:	[super writeString:@"&copy;"];      break;
        case 174:	[super writeString:@"&reg;"];       break;
        case 8211:	[super writeString:@"&ndash;"];     break;
        case 8212:	[super writeString:@"&mdash;"];     break;
        case 8364:	[super writeString:@"&euro;"];      break;
          
          // Otherwise, use the decimal unicode value.
        default:	[super writeString:[NSString stringWithFormat:@"&#%d;",ch]];   break;
      }
      
      // Convert the rest
      NSUInteger increment = written + 1;
      range.location += increment; range.length -= increment;
    }
    else if (range.location == 0)
    {
      // Efficient route for if entire string can be written
      [super writeString:string];
      break;
    }
    else
    {
      // Use CFStringCreateWithSubstring() rather than -substringWithRange: since:
      // A) Can dispose of it straight away rather than filling autorelease pool
      // B) range doesn't need casting
      CFStringRef substring = CFStringCreateWithSubstring(NULL, (__bridge CFStringRef)string, range);
      [super writeString:(__bridge NSString *)substring];
      CFRelease(substring);
      
      break;
    }
  }
}

@end


#pragma mark -


@implementation KSXMLAttributes (KSXMLWriter)

- (void)writeAttributes:(KSXMLWriter *)writer;
{
  for (NSUInteger i = 0; i < [_attributes count]; i+=2)
  {
    NSString *attribute = [_attributes objectAtIndex:i];
    NSString *value = [_attributes objectAtIndex:i+1];
    [writer writeAttribute:attribute value:value];
  }
}

@end



#pragma mark -


@implementation KSXMLElementContentsProxy

- (void)ks_prepareWithTarget:(id)target XMLWriter:(KSXMLWriter *)writer;
{
  NSParameterAssert(writer);
  
  _target = target;
  _XMLWriter = writer;
  _elementsCount = [writer openElementsCount];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
  return [_target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation;
{
  KSXMLWriter *writer = _XMLWriter;           // copy to local vars since invocation may fire off another
  NSUInteger elementsCount = _elementsCount;  // invocation internally, resetting these ivars. #103849
  
  // Forward on
  [invocation invokeWithTarget:_target];
  _target = nil;
  
  // End element
  NSAssert([writer openElementsCount] == elementsCount, @"Writing element contents did not end the same number of sub-elements as it started");(void)elementsCount;
  [writer endElement];
  _XMLWriter = nil;
}

@end

