/*
 * SKBRidgeReceipt.m
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

#import "SKBridgeReceipt.h"
#import <MobileCoreServices/MobileCoreServices.h>

static NSString *SKBridgeReceiptCallbackURLKey = @"_callbackURL";
static NSString *SKBridgeReceiptApplicationNameKey = @"_applicationName";
static NSString *SKBridgeReceiptApplicationIDKey = @"_applicationID";
static NSString *SKBridgeReceiptResultMimeKey = @"_resultMime";
static NSString *SKBridgeReceiptResultDataKey = @"_resultData";
static NSString *SKBridgeReceiptMetadataKey = @"_metadata";

@implementation SKBridgeReceipt

@synthesize callbackURL = _callbackURL;
@synthesize applicationName = _applicationName;
@synthesize applicationID = _applicationID;
@synthesize resultMime = _resultMime;
@synthesize resultData = _resultData;
@synthesize metadata = _metadata;

- (id) init {
  self = [super init];
  if (self != nil) {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    if (infoDictionary != nil) {
      self.applicationID = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
      self.applicationName = [infoDictionary objectForKey:(NSString *)kCFBundleNameKey];
    }
  }
  return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self != nil) {
    NSString *callbackURLString = [aDecoder decodeObjectForKey:SKBridgeReceiptCallbackURLKey];
    if (callbackURLString != nil) {
      _callbackURL = [NSURL URLWithString:callbackURLString];
    }
    _applicationName = [aDecoder decodeObjectForKey:SKBridgeReceiptApplicationNameKey];
    _applicationID = [aDecoder decodeObjectForKey:SKBridgeReceiptApplicationIDKey];
    _resultMime = [aDecoder decodeObjectForKey:SKBridgeReceiptResultMimeKey];
    _resultData = [aDecoder decodeObjectForKey:SKBridgeReceiptResultDataKey];
    _metadata = [aDecoder decodeObjectForKey:SKBridgeReceiptMetadataKey];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:[_callbackURL absoluteString] forKey:SKBridgeReceiptCallbackURLKey];
  [aCoder encodeObject:_applicationName forKey:SKBridgeReceiptApplicationNameKey];
  [aCoder encodeObject:_applicationID forKey:SKBridgeReceiptApplicationIDKey];
  [aCoder encodeObject:_resultMime forKey:SKBridgeReceiptResultMimeKey];
  [aCoder encodeObject:_resultData forKey:SKBridgeReceiptResultDataKey];
  [aCoder encodeObject:_metadata forKey:SKBridgeReceiptMetadataKey];
}

- (BOOL) populateResultsWithContentsOfFile:(NSString *)file {
  if ([[NSFileManager defaultManager] fileExistsAtPath:file] == NO) {
    return NO;
  }
  
  _resultData = [NSData dataWithContentsOfFile:file];
  if (_resultData == nil) {
    return NO;
  }
  
  NSString *mimeType = nil;
  NSString *extension = [file pathExtension];
  CFStringRef myUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)extension,
                                                            NULL);
  if (myUTI != NULL) {
    CFStringRef utiMimeType = UTTypeCopyPreferredTagWithClass(myUTI, kUTTagClassMIMEType);
    if (utiMimeType != NULL) {
      if (CFStringGetLength(utiMimeType) > 0) {
        mimeType = (__bridge_transfer id)utiMimeType;
      }
      else {
        CFRelease(utiMimeType);
      }
    }
    CFRelease(myUTI);
  }
  if (mimeType == nil) {
    mimeType = @"application/octet-stream";
  }
  _resultMime = mimeType;
  return YES;
}

@end
