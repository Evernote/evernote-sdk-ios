/*
 * ENXMLWriter.h
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

#import <Foundation/Foundation.h>

#import "ENXMLDTD.h"

@protocol ENXMLWriterDelegate;

@interface ENXMLWriter : NSObject

@property (weak, nonatomic) id<ENXMLWriterDelegate> delegate;

@property (strong, nonatomic) ENXMLDTD *dtd;
@property (assign, nonatomic) NSUInteger openElementCount;
@property (strong, readonly, nonatomic) NSString *contents;

- (id) initWithDelegate:(id<ENXMLWriterDelegate>)delegate;

- (void) startDocument;
- (void) endDocument;

// Returns NO if the element is not valid in the
// given DTD.
- (BOOL) startElement:(NSString *)elementName;
- (BOOL) startElement:(NSString*)elementName 
       withAttributes:(NSDictionary*)attrDict;

- (void) endElement;

// Returns NO if the element is not valid in the
// given DTD.
- (BOOL) writeElement:(NSString *)element
       withAttributes:(NSDictionary *)attributes
              content:(NSString *)content;

// Write an attribute.  The assumption here is that the attribute value has 
// *not* been escaped: e.g. foo&bar not foo&amp;bar
// Returns NO if the attribute is not valid for
// the current element in the DTD.
- (BOOL) writeAttributeName:(NSString*)name 
                      value:(NSString*)value;

// Write a raw string.  No escaping is performed.
- (void) writeRawString:(NSString *)rawString;

// Write a string.  Escaping is performed.
- (void) writeString:(NSString *)string;

- (void) startCDATA;
- (void) writeCDATA:(NSString *)string;
- (void) endCDATA;

@end


@protocol ENXMLWriterDelegate <NSObject>
- (void) xmlWriter:(ENXMLWriter *)writer didGenerateData:(NSData*)data;
- (void) xmlWriterDidEndWritingDocument:(ENXMLWriter *)writer;
@end
