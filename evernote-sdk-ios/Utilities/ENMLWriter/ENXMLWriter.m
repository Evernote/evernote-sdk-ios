/*
 * ENXMLWriter.m
 * evernote-sdk-ios
 *
 * Copyright 2012 Evernote Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ENXMLWriter.h"
#import "ENXMLUtils.h"
#import <libxml/xmlwriter.h>

static void CheckXMLResult(int result, NSString *blah) {
  if (result < 0) {
    NSString *errorMessage = nil;
    xmlErrorPtr lastXMLError = xmlGetLastError();
    if (lastXMLError) {
      errorMessage = [[NSString alloc] initWithCString:lastXMLError->message 
                                              encoding:NSUTF8StringEncoding];
      xmlResetLastError();
    }
    
    [NSException raise:@"ENXMLWriterLibXMLError"
                format:@"%@ returned result=%i, error=%@", blah, result, errorMessage];
  }
}

@interface ENXMLWriter()
@property ( strong, nonatomic) NSString *currentElementName;
@end

@implementation ENXMLWriter {
  id<ENXMLWriterDelegate> __weak _delegate;
  NSMutableString *_contents;
  
  xmlTextWriterPtr _xmlWriter;
  xmlOutputBufferPtr _xmlOutputBuffer;
  
  ENXMLDTD * _dtd;
  NSString * _currentElementName;
  NSUInteger _openElementCount;
}

@synthesize currentElementName = _currentElementName;

#pragma mark -
#pragma mark Stream Writer Callbacks
static int ENXMLWriter_delegateWriteCallback(void * context,  const char * buffer, int len) {
  ENXMLWriter *self = (__bridge ENXMLWriter *)context;
  NSData *data = [[NSData alloc] initWithBytes:buffer 
                                        length:len];
  [self->_delegate xmlWriter:self 
             didGenerateData:data];
  return len;
}

static int ENXMLWriter_contentsWriteCallback(void * context,  const char * buffer, int len) {
  NSMutableString *contents = (__bridge NSMutableString *)context;
  [contents appendString:[NSString stringWithUTF8String:buffer]];
  return len;
}

static int ENXMLWriter_delegateCloseCallback(void * context) {
  ENXMLWriter *self = (__bridge ENXMLWriter *)context;
  [self->_delegate xmlWriterDidEndWritingDocument:self];
  return 0;
}

#pragma mark -
#pragma mark Properties

@synthesize delegate = _delegate;
@synthesize contents = _contents;
@synthesize dtd = _dtd;
@synthesize openElementCount = _openElementCount;

#pragma mark -
#pragma mark NSObject Methods
- (id) initWithDelegate:(id)delegate {
  self = [self init];
  if (self != nil) {
    self.delegate = delegate;
  }
  return self;
}

- (void) dealloc {
  if (_xmlWriter) {
    xmlFreeTextWriter(_xmlWriter);
    _xmlWriter = nil;
  }
}

#pragma mark -
#pragma mark XML Writting
- (void) startDocument {
  if (_delegate != nil) {
    _xmlOutputBuffer = xmlOutputBufferCreateIO(ENXMLWriter_delegateWriteCallback,
                                               ENXMLWriter_delegateCloseCallback, 
                                               (__bridge void *)(self), 
                                               NULL);
  }
  else {
    _contents = [[NSMutableString alloc] init];
    _xmlOutputBuffer = xmlOutputBufferCreateIO(ENXMLWriter_contentsWriteCallback,
                                               NULL,
                                               (__bridge void *)_contents, 
                                               NULL);
  }
  CheckXMLResult(_xmlOutputBuffer == nil ? -1 : 0, @"xmlOutputBufferCreateIO");

  _xmlWriter = xmlNewTextWriter(_xmlOutputBuffer);
  CheckXMLResult(_xmlWriter == nil ? -1 : 0, @"xmlNewTextWriter");
  

  int result = xmlTextWriterSetIndent(_xmlWriter, 0);
  CheckXMLResult(result, @"xmlTextWriterSetIndent");
  
  if (_dtd != nil && _dtd.docTypeDeclaration != nil) {
    //This call will insert the xml declaration into the document
    result = xmlTextWriterStartDocument(_xmlWriter, NULL, xmlGetCharEncodingName(XML_CHAR_ENCODING_UTF8), "no");
    CheckXMLResult(result, @"xmlTextWriterStartDocument");

    result = xmlTextWriterWriteRaw(_xmlWriter,
                                   xmlCharFromNSString(_dtd.docTypeDeclaration));
    CheckXMLResult(result, @"xmlTextWriterWriteRaw");
  }
  
  //Put a newline after the doc type to make things more readable
  result = xmlTextWriterWriteRaw(_xmlWriter, (const xmlChar *) "\n");
  CheckXMLResult(result, @"xmlTextWriterWriteRaw");
}

- (void) endDocument {
  int result = xmlTextWriterEndDocument(_xmlWriter);
  CheckXMLResult(result, @"xmlTextWriterEndDocument");
  
  xmlFreeTextWriter(_xmlWriter);
  _xmlWriter = nil;
}

- (BOOL) startElement:(NSString *)elementName {
  if (_dtd != nil && [_dtd isElementLegal:elementName] == NO) {
    return NO;
  }

  int result = xmlTextWriterStartElement(_xmlWriter,
                                         xmlCharFromNSString(elementName));
  CheckXMLResult(result, @"xmlTextWriterStartElement");
  _openElementCount++;
  self.currentElementName = elementName;
  return YES;
}

- (BOOL) startElement:(NSString*)elementName 
       withAttributes:(NSDictionary*)attrDict 
{
  BOOL success = [self startElement:elementName];
  if (success == NO) return NO;
  
  for (NSString *key in [attrDict allKeys]) {
    [self writeAttributeName:key 
                       value:[attrDict objectForKey:key]];
  }
  
  return YES;
}

- (void) endElement {
  int result = xmlTextWriterEndElement(_xmlWriter);
  CheckXMLResult(result, @"xmlTextWriterEndElement");
  self.currentElementName = nil;
  _openElementCount--;
}

- (BOOL) writeElement:(NSString *)element
       withAttributes:(NSDictionary *)attributes
              content:(NSString *)content
{
  BOOL success = [self startElement:element
                     withAttributes:attributes];
  if (success == NO) return NO;
  
  [self writeString:content];
  [self endElement];

  return YES;
}

// Write an attribute.  The assumption here is that the attribute value has 
// *not* been escaped: e.g. foo&bar not foo&amp;bar
- (BOOL) writeAttributeName:(NSString*)name 
                      value:(NSString*)value
{
#if INTERNAL_BUILD
  NSAssert(value != nil, @"Attempted to write attribute with nil value! name=%@", name);
#else
  if (value == nil) {
    value = @"";
  }
#endif
  if (_dtd != nil && [_dtd isAttributeLegal:name inElement:_currentElementName] == NO) {
    return NO;
  }
  
  //Convert @"&#38;" to &
  NSMutableString * fixedValue = [[NSMutableString alloc] initWithString:value];
  [fixedValue replaceOccurrencesOfString:@"&#38;"
                              withString:@"&"
                                 options:0
                                   range:NSMakeRange(0, [fixedValue length])];

  
  int result = xmlTextWriterWriteAttribute(_xmlWriter, 
                                           xmlCharFromNSString(name),
                                           xmlCharFromNSString(fixedValue));

  CheckXMLResult(result, @"xmlTextWriterWriteAttribute");
  return YES;
}

- (void) writeString:(NSString *)string raw:(BOOL)raw {
  if (string == nil) {
    return;
  }
  
  int result;
  if (raw == YES) {
    result = xmlTextWriterWriteRaw(_xmlWriter, xmlCharFromNSString(string));
    CheckXMLResult(result, @"xmlTextWriterWriteRaw");
  }
  else {
    result = xmlTextWriterWriteString(_xmlWriter, xmlCharFromNSString(string));
    CheckXMLResult(result, @"xmlTextWriterWriteString");
  }
}

// Write a raw string.  No escaping is performed.
- (void) writeRawString:(NSString *)rawString {
  [self writeString:rawString raw:YES];
}


// Write a string.  Escaping is performed.
- (void) writeString:(NSString *)string {
  [self writeString:string raw:NO];
}

- (void) startCDATA {
  int result = xmlTextWriterStartCDATA(_xmlWriter);
  CheckXMLResult(result, @"xmlTextWriterStartCDATA");
}

- (void) writeCDATA:(NSString *)string {
  int result = xmlTextWriterWriteCDATA(_xmlWriter, xmlCharFromNSString(string));
  CheckXMLResult(result, @"xmlTextWriterWriteCDATA");
}

- (void) endCDATA {
  int result = xmlTextWriterEndCDATA(_xmlWriter);
  CheckXMLResult(result, @"xmlTextWriterEndCDATA");
}

@end
