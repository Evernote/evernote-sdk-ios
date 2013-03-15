/*
 * ENMLUtility.m
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

#import "ENMLUtility.h"
#import "NSData+EvernoteSDK.h"
#import "EvernoteSDK.h"
#import "KSHTMLWriter.h"
#import "NSDataBase64Additions.h"


typedef void (^ENMLHTMLCompletionBlock)(NSString* html, NSError *error);


@interface ENMLUtility ()

@property (nonatomic,strong) NSMutableString* outputHTML;
@property (nonatomic,strong) KSHTMLWriter* htmlWriter;
@property (nonatomic,strong) NSArray* resources;
@property (nonatomic,copy) ENMLHTMLCompletionBlock completionBlock;
@property (nonatomic,strong) NSXMLParser* xmlParser;
@property (nonatomic,assign) BOOL shouldIgnoreNextEndElement;

@end

@implementation ENMLUtility

+ (NSString*) mediaTagWithDataHash:(NSData *)dataHash
                              mime:(NSString *)mime
{
    if (mime == nil) {
        mime = ENMIMETypeOctetStream;
    }
    NSString* dataHashHex = [dataHash enlowercaseHexDigits];
    NSString* mediaTag = [NSString stringWithFormat:@"<%@ type =\"%@\" hash=\"%@\"/>",
                          ENMLTagMedia,
                          mime,
                          dataHashHex] ;
    return mediaTag;
}

- (void) convertENMLToHTML:(NSString*)enmlContent completionBlock:(void(^)(NSString* html, NSError *error))block {
    [self convertENMLToHTML:enmlContent withResources:nil completionBlock:block];
}


- (void) convertENMLToHTML:(NSString*)enmlContent withResources:(NSArray*)resources completionBlock:(void(^)(NSString* html, NSError *error))block {
    self.xmlParser = [[NSXMLParser alloc] initWithData:[enmlContent dataUsingEncoding:NSUTF8StringEncoding]];
    self.outputHTML = [NSMutableString string];
    self.htmlWriter = [[KSHTMLWriter alloc] initWithOutputWriter:self.outputHTML];
    [self.xmlParser setDelegate:self];
    self.resources = resources;
    self.completionBlock = block;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.xmlParser parse];
    });
}

#pragma mark -
#pragma NSXMLParser delegate functions

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.htmlWriter close];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completionBlock(self.outputHTML,nil);
    });
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completionBlock(nil,parseError);
    });
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if([elementName isEqualToString:ENMLTagNote]) {
        [self.htmlWriter startElement:@"body"];
    }
    else if([elementName isEqualToString:ENMLTagTodo]) {
        self.shouldIgnoreNextEndElement = YES;
        [self writeTodoWithAttributes:attributeDict];
    }
    else if([elementName isEqualToString:ENMLTagMedia] && self.resources) {
        NSString *mediaHash = [attributeDict objectForKey:@"hash"];
        NSData* dataHash =  [NSData endataWithHexDigits:mediaHash];
        EDAMResource *foundResource = nil;
        for (EDAMResource* resource in self.resources) {
            if([[[resource data] bodyHash] isEqualToData:dataHash]) {
                foundResource = resource;
            }
        }
        NSMutableDictionary *scrubbedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
        [scrubbedAttributes removeObjectForKey:@"hash"];
        [scrubbedAttributes removeObjectForKey:@"type"];
        [self setShouldIgnoreNextEndElement:YES];
        [self writeResource:foundResource withAttributes:scrubbedAttributes];
    }
    else {
        [self.htmlWriter startElement:elementName];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if(self.shouldIgnoreNextEndElement == NO) {
        [self.htmlWriter endElement];
    }
    else {
        self.shouldIgnoreNextEndElement = NO;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.htmlWriter writeCharacters:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    [self.htmlWriter startCDATA];
    [self.htmlWriter writeString:[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding]];
    [self.htmlWriter endCDATA];
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
    [self.htmlWriter writeComment:comment];
}

#pragma mark -
#pragma Internal functions

- (void) writeResource:(EDAMResource*)resource
        withAttributes:(NSDictionary *)attributes
{
    if (resource == nil) {
        return;
    }
    NSString *mime = [resource mime];
    
    NSMutableDictionary *scrubbedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    
    if ([mime hasPrefix:@"image/"] == YES) {
        [self writeImageTagForResource:resource
                        withAttributes:scrubbedAttributes];
    }
    else {
        // Ignoring all other resource types
    }
}

- (void) writeImageTagForResource:(EDAMResource *)resource
                   withAttributes:(NSDictionary *)attributes
{
    
    NSMutableDictionary *imageAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    NSString *mime = [resource mime];
    NSString* imgStr = [NSString stringWithFormat:@"data:%@;base64,%@",mime,[[[resource data] body] enbase64Encoding]];

    [imageAttributes setObject:imgStr
                        forKey:@"src"];
    if (mime == nil) {
        mime = ENMIMETypeOctetStream;
    }
    
    [imageAttributes setObject:mime
                        forKey:ENHTMLAttributeMime];
    
    NSNumber *width = [attributes objectForKey:@"width"];
    NSNumber *height = [attributes objectForKey:@"height"];
    if (width == nil || height == nil) {
        width = [NSNumber numberWithInt:[resource width]];
        height = [NSNumber numberWithInt:[resource height]];
    }
    
    [imageAttributes setObject:width
                        forKey:@"width"];
    [imageAttributes setObject:height
                        forKey:@"height"];
    
    [self.htmlWriter startElement:@"img" attributes:imageAttributes];
    [self.htmlWriter endElement];
}

- (void) writeTodoWithAttributes:(NSDictionary *)attributes
{
    NSMutableDictionary *checkboxAttributes = [NSMutableDictionary dictionary];
    [checkboxAttributes setObject:@"checkbox" forKey:@"type"];
    [checkboxAttributes setObject:@"true" forKey:@"disabled"];
    
    if ([[attributes valueForKey:@"checked"] isEqualToString:@"true"] == YES) {
        [checkboxAttributes setObject:[NSNull null] forKey:@"checked"];
    }
    
    [self.htmlWriter startElement:@"input"
            attributes:checkboxAttributes];
    [self.htmlWriter endElement];
}


@end
