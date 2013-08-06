/*
 * ENXMLDTD.m
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

#import "ENXMLDTD.h"
#import "ENXMLUtils.h"
#import <libxml/parserInternals.h>
#import <libxml/tree.h>

xmlExternalEntityLoader defaultExternalEntityLoader = NULL;
static xmlParserInputPtr	enxmlExternalEntityLoader	(const char * URL, 
                                             const char * ID, 
                                             xmlParserCtxtPtr context)
{
  xmlParserInputPtr ret = NULL;
  NSString *urlString = [[NSString alloc] initWithCString:URL encoding:NSUTF8StringEncoding];
  NSURL *urlObject = [[NSURL alloc] initWithString:urlString];
  if (urlObject != nil) {
    NSString *path = [urlObject path];
    if (path != nil) {
      NSString *filename = [path lastPathComponent];
      if (filename != nil) {
        // Can't use mainBundle for unit test purposes...
        NSString *bundledFile = [[NSBundle bundleForClass:[ENXMLDTD class]] pathForResource:filename
                                                                                        ofType:nil];
        if (bundledFile != nil) {
          ret = xmlNewInputFromFile(context, [bundledFile fileSystemRepresentation]);
        }
      }
    }
  }
  
  if (ret == NULL){
    if (defaultExternalEntityLoader != NULL) {
      ret = defaultExternalEntityLoader(URL, ID, context);
    }
  }
  
  return ret;
}

@implementation ENXMLDTD {
  xmlDtdPtr _dtd;
  NSString * _docTypeDeclaration;
}

@synthesize docTypeDeclaration = _docTypeDeclaration;

+ (void) initialize {
  if (self == [ENXMLDTD class]) {
    defaultExternalEntityLoader = xmlGetExternalEntityLoader();
    xmlSetExternalEntityLoader(enxmlExternalEntityLoader);
  }
}

+ (ENXMLDTD *) dtdWithBundleResource:(NSString *)resource ofType:(NSString *)type {
  // Can't use mainBundle for unit test purposes...
  NSString *dtdFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:resource ofType:type];
  
  ENXMLDTD *dtd = [[ENXMLDTD alloc] initWithContentsOfFile:dtdFilePath];
  return dtd;
}

+ (ENXMLDTD *) enexDTD {
  static ENXMLDTD *dtd = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dtd = [ENXMLDTD dtdWithBundleResource:@"evernote-export" ofType:@"dtd"];
  });

  return dtd;
}

+ (ENXMLDTD *) enml2dtd {
  static ENXMLDTD *dtd = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dtd = [ENXMLDTD dtdWithBundleResource:@"enml2" ofType:@"dtd"];
    dtd.docTypeDeclaration = @"<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">";
  });

  return dtd;
}

+ (ENXMLDTD *) lat1DTD {
  static ENXMLDTD *dtd = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dtd = [ENXMLDTD dtdWithBundleResource:@"xhtml-lat1" ofType:@"ent"];
  });
  
  return dtd;
}

+ (ENXMLDTD *) symbolDTD {
  static ENXMLDTD *dtd = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dtd = [ENXMLDTD dtdWithBundleResource:@"xhtml-symbol" ofType:@"ent"];
  });
  
  return dtd;
}

+ (ENXMLDTD *) specialDTD {
  static ENXMLDTD *dtd = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dtd = [ENXMLDTD dtdWithBundleResource:@"xhtml-special" ofType:@"ent"];
  });
  
  return dtd;
}

- (id) initWithContentsOfFile:(NSString *)file {
  self = [super init];
  if (self != nil) {
    xmlParserInputBufferPtr inputBuff = xmlParserInputBufferCreateFilename([file fileSystemRepresentation], XML_CHAR_ENCODING_NONE);
    if (inputBuff == NULL) {
      xmlErrorPtr lastErrorPtr = xmlGetLastError();
      NSString *errorMessage = nil;
      if (lastErrorPtr != NULL) {
        errorMessage = [NSString stringWithCString:lastErrorPtr->message encoding:NSUTF8StringEncoding];
      }
      NSLog(@"xmlParserInputBufferCreateFilename(%@) returned error:%@", file, errorMessage);
      xmlResetLastError();
      return nil;
    }
    
    _dtd = xmlIOParseDTD(NULL, inputBuff, XML_CHAR_ENCODING_NONE);
    if (_dtd == NULL) {
      xmlErrorPtr lastErrorPtr = xmlGetLastError();
      NSString *errorMessage = nil;
      if (lastErrorPtr != NULL) {
        errorMessage = [NSString stringWithCString:lastErrorPtr->message encoding:NSUTF8StringEncoding];
      }
      NSLog(@"xmlIOParseDTD() returned error:%@", errorMessage);
      xmlResetLastError();
      return nil;
    }

  }
  return self;
}

- (void) dealloc {
  if (_dtd != NULL) {
    xmlFreeDtd(_dtd);
    _dtd = NULL;
  }
}

- (xmlEntityPtr) xmlEntityNamed:(NSString *)name {
  xmlEntitiesTablePtr table = (xmlEntitiesTablePtr) _dtd->entities;
  if (table == NULL) {
    return NULL;
  }
  return((xmlEntityPtr) xmlHashLookup(table, xmlCharFromNSString(name)));
}

- (xmlElementPtr) xmlElementNamed:(NSString *)name {
  xmlEntitiesTablePtr table = (xmlEntitiesTablePtr)_dtd->elements;
  return((xmlElementPtr) xmlHashLookup(table, xmlCharFromNSString(name)));
}

- (BOOL) isElementLegal:(NSString *)name {
  return ([self xmlElementNamed:name] != NULL);
}

- (NSDictionary*) sanitizedAttributes:(NSDictionary*)attribDict
                           forElement:(NSString *)elementName
{
  xmlElementPtr elementResult = [self xmlElementNamed:elementName];
  if (elementResult == NULL) {
    NSLog(@"Error retrieving element:%@ from dtd:%@", elementName, self);
    return nil;
  }
  
  NSMutableDictionary *cleanedAttribDict = [[NSMutableDictionary alloc] init];
  
  NSArray *attributeKeys = [attribDict allKeys];
  for (NSString* key in attributeKeys) {
    xmlAttributePtr dtdAttributes = elementResult->attributes;
    
    while (dtdAttributes != NULL) {
      NSString *elementAttributeName = NSStringFromXmlChar(dtdAttributes->name);
      if (elementAttributeName && [key caseInsensitiveCompare:elementAttributeName] == NSOrderedSame){
        [cleanedAttribDict setObject:[attribDict objectForKey:key] 
                              forKey:key];
        break;
      }
      
      dtdAttributes = dtdAttributes->nexth;
    }
  }  
  
  return cleanedAttribDict;
}

- (BOOL) isAttributeLegal:(NSString *)attribute 
                inElement:(NSString *)element 
{
  NSDictionary *testDict = [NSDictionary dictionaryWithObject:[NSNull null]
                                                       forKey:attribute];
  
  NSDictionary *result = [self sanitizedAttributes:testDict forElement:element];
  return ([result count] == 1);
}

@end
