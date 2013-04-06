/*
 * ENMLUtility.h
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
#import "KSHTMLWriter.h"

/** Utility methods to work with ENML.
 */
@interface ENMLUtility : NSObject <NSXMLParserDelegate>

/** Utility function to create an enml media tag.
 
 @param  dataHash The md5 hash of the data
 @param  mime The mime type of the data
 */
+ (NSString*) mediaTagWithDataHash:(NSData *)dataHash
                              mime:(NSString *)mime;


/** Utility function to convert ENML to HTML.
 
 @param  enmlContent The enml content of the note
 @param  block The completion block that will be called on completion
 */
- (void) convertENMLToHTML:(NSString*)enmlContent completionBlock:(void(^)(NSString* html, NSError *error))block;


/** Utility function to convert ENML to HTML.
 
 @param  enmlContent The enml content of the note
 @param  resources The resources array
 @param  block The completion block that will be called on completion
 */
- (void) convertENMLToHTML:(NSString*)enmlContent withResources:(NSArray*)resources completionBlock:(void(^)(NSString* html, NSError *error))block;

@end
