/*
 * ENMLWriter.m
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

#import "ENMLWriter.h"

#import "ENEncryptedContentInfo.h"
#import "ENMIMEUtils.h"
#import "ENConstants.h"
#import "ENMIMEUtils.h"

#import "NSData+EvernoteSDK.h"
#import "NSRegularExpression+ENAGRegex.h"
#import "NSString+EDAMNilAdditions.h"
#import "EvernoteSDK.h"

@implementation ENMLWriter

+ (BOOL) validateURLComponents: (NSURL *) url {
  if (url == nil) {
    return NO;
  }
  
  NSString *scheme = [url scheme];
  if ([scheme rangeOfString: @"script"].location != NSNotFound) {
    // disallow *script* schemes!
    return NO;
  }
  else if ([scheme isEqualToString: @"file"]) {
    return YES;
  }
  else if ([scheme isEqualToString:@"x-apple-data-detectors"]) {
    return NO;
  }
  else if ([scheme isEqualToString:@"tel"]) {
    return YES;
  }
  
  BOOL result = YES;
  
  // compare regex parsed components to what NSURL thinks it has since NSURL is stinky
  // See RFC 3986 Appendix B
  NSRegularExpression * r = [NSRegularExpression enRegexWithPattern: @"^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?"];
  NSArray * components = [r enCapturedSubstringsOfString: [url absoluteString]];
  if (!components || [components count] != 10) {
    return NO;
  }
  
  scheme = [components objectAtIndex: 2];
  if (![scheme enIsEqualToStringWithEmptyEqualToNull: [url scheme]]) {
    NSLog(@"Scheme '%@' does not match scheme '%@'", scheme, [url scheme]);
    result = NO;
  }
  NSString * authority = [components objectAtIndex: 4];
  NSMutableString * hrefAuthority = [NSMutableString string];
  if ([url user] || [url password]) {
    if ([url user]) {
      [hrefAuthority appendString: [url user]];
    }
    if ([url password]) {
      [hrefAuthority appendString: @":"];
      [hrefAuthority appendString: [url password]];
    }
    [hrefAuthority appendString: @"@"];
  }
  if ([url host]) {
    [hrefAuthority appendString: [url host]];
  }
  if ([url port]) {
    [hrefAuthority appendString: @":"];
    [hrefAuthority appendFormat: @"%@", [url port]];
  }
  
  if (![authority enIsEqualToStringWithEmptyEqualToNull: hrefAuthority]) {
    NSLog(@"Authority '%@' does not match authority '%@'", authority, hrefAuthority);
    result = NO;
  }
  NSString * path = [components objectAtIndex: 5];
  path = [path stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
  NSString * urlPath = [url path];
  if (![path enIsEqualToStringWithEmptyEqualToNull: urlPath]) {
    if ([scheme caseInsensitiveCompare: @"mailto"] == 0) {
      if (! [path enIsEqualToStringWithEmptyEqualToNull: [url resourceSpecifier]]) {
        NSLog(@"Path '%@' does not match resource specifier '%@'", path, [url resourceSpecifier]);
        result = NO;
      }
    } else if ([path hasSuffix: @"/"]) {
      path = [path substringToIndex: [path length] - 1];
      if (![path enIsEqualToStringWithEmptyEqualToNull: urlPath]) {
        NSLog(@"Path '%@' does not match path '%@'", path, urlPath);
        result = NO;
      }
    } else {
      NSLog(@"Path '%@' does not match path '%@'", path, urlPath);
      result = NO;
    }
  }
  NSString * query = [components objectAtIndex: 7];
  if (![query enIsEqualToStringWithEmptyEqualToNull: [url query]]) {
    NSLog(@"Query '%@' does not match query '%@'", query, [url query]);
    result = NO;
  }
  NSString * fragment = [components objectAtIndex: 9];
  if (![fragment enIsEqualToStringWithEmptyEqualToNull: [url fragment]]) {
    NSLog(@"Fragment '%@' does not match fragment '%@'", fragment, [url fragment]);
    result = NO;
  }
  
  return result;
}

+ (NSString *) emptyNote {
  ENMLWriter *writer = [[ENMLWriter alloc] init];
  [writer startDocument];
  [writer endDocument];
  return [writer contents];
}

- (id) init {
  self = [super init];
  if (self != nil) {
    self.dtd = [ENXMLDTD enml2dtd];
  }
  return self;
}

- (void) startDocumentWithAttributes:(NSDictionary *)attributes {
  [super startDocument];
  [self startElement:ENMLTagNote 
      withAttributes:attributes];
}

- (void) startDocument {
  [self startDocumentWithAttributes:nil];
}

- (void) endDocument {
  [self endElement]; // ENMLTagNote
  [super endDocument];
}

- (NSDictionary *) validateURLAttribute:(NSString *)attributeKey
                           inAttributes:(NSDictionary *)attributes
{
  NSString *urlString = [attributes objectForKey:attributeKey];
  if (urlString == nil) {
    return attributes;
  }

  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
  if ([ENMLWriter validateURLComponents:url] == YES) {
    [newAttributes setObject:[url absoluteString]
                      forKey:attributeKey];
  }
  else {
    NSLog(@"Unable to validate URL:%@ in attributes:%@", urlString, attributes);
    [newAttributes removeObjectForKey:attributeKey];
  }
  
  return newAttributes;
}

- (BOOL) startElement:(NSString*)elementName 
       withAttributes:(NSDictionary*)attrDict 
{
  if ([elementName isEqualToString:@"a"]) {
    NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:attrDict];
    NSArray *attributeKeys = [attrDict allKeys];
    for (NSString *aKey in attributeKeys) {
      if ([aKey hasPrefix:@"x-apple-"] == YES) {
        [newAttributes removeObjectForKey:aKey];
      }
    }

    attrDict = [self validateURLAttribute:@"href"
                             inAttributes:newAttributes];
  }
  else if ([elementName isEqualToString:@"img"]) {
    attrDict = [self validateURLAttribute:@"src"
                             inAttributes:attrDict];
  }
  return [super startElement:elementName withAttributes:attrDict];
}

#pragma mark -
#pragma mark
- (void) writeResourceWithDataHash:(NSData *)dataHash
                              mime:(NSString *)mime
                        attributes:(NSDictionary *)attributes
{
  NSMutableDictionary *mediaAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
  
  if (mime == nil) {
    mime = ENMIMETypeOctetStream;
  }
  [mediaAttributes setObject:mime forKey:@"type"];
  [mediaAttributes setObject:[dataHash enlowercaseHexDigits] forKey:@"hash"];

  [self writeElement:ENMLTagMedia 
      withAttributes:mediaAttributes 
             content:nil];
}

- (void) writeResource:(EDAMResource *)resource {
  EDAMData* resourceData = resource.data;
  [self writeResourceWithDataHash:resourceData.bodyHash
                             mime:[resource mime]
                       attributes:nil];
}

- (void) writeEncryptedInfo:(ENEncryptedContentInfo *)encryptedInfo {
  NSMutableDictionary *cryptAttributes = [NSMutableDictionary dictionary];
  [cryptAttributes setObject:encryptedInfo.cipher forKey:@"cipher"];
  
  NSString *keyLength = [[NSNumber numberWithInt:encryptedInfo.keyLength] stringValue];
  [cryptAttributes setObject:keyLength forKey:@"length"];

  NSString *hint = encryptedInfo.hint;
  if (hint != nil) {
    [cryptAttributes setObject:hint forKey:@"hint"];
  }
  
  [self writeElement:ENMLTagCrypt
      withAttributes:cryptAttributes 
             content:encryptedInfo.cipherText];
}

- (void) writeTodoWithCheckedState:(BOOL)checkedState {
  NSDictionary *attributes = nil;
  if (checkedState == YES) {
    attributes = [NSDictionary dictionaryWithObject:@"true" forKey:@"checked"];
  }
  
  [self writeElement:ENMLTagTodo
      withAttributes:attributes 
             content:nil];
}


@end
