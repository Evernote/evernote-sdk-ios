/*
 * SKNewSkitchRequest.m
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

#import "SKNewSkitchRequest.h"
#import <MobileCoreServices/MobileCoreServices.h>

enum {
  SKNewSkitchRequestVersion1 = 0x00010000,
  SKNewSkitchRequestCurrentVersion = SKNewSkitchRequestVersion1,
};

static NSString *SKNewSkitchRequestVersionKey = @"__version__";
static NSString *SKNewSkitchRequestMimeKey = @"_mime";
static NSString *SKNewSkitchRequestDataKey = @"_data";
static NSString *SKNewSkitchRequestDataURLKey = @"_dataURL";
static NSString *SKNewSkitchRequestResourceGUIDKey = @"_resourceGUID";
static NSString *SKNewSkitchRequestUserInfoKey = @"_userInfo";
static NSString *SKNewSkitchRequestReceiptKey = @"_receipt";

@implementation SKNewSkitchRequest

@synthesize mime = _mime;
@synthesize data = _data;
@synthesize dataURL = _dataURL;
@synthesize resourceGUID = _resourceGUID;
@synthesize receipt = _receipt;

- (id) initWithContentsOfFile:(NSString *)file {
  self = [self init];
  if (self != nil) {
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] == NO) {
      return nil;
    }
    
    _data = [NSData dataWithContentsOfFile:file];
    if (_data == nil) {
      return nil;
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
    _mime = mimeType;
  }
  return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self != nil) {
    uint32_t encodedVersion = [aDecoder decodeInt32ForKey:SKNewSkitchRequestVersionKey];
    if (encodedVersion != SKNewSkitchRequestCurrentVersion) {
      return nil;
    }
    
    _mime = [aDecoder decodeObjectForKey:SKNewSkitchRequestMimeKey];
    _data = [aDecoder decodeObjectForKey:SKNewSkitchRequestDataKey];
    NSString *dataURLString = [aDecoder decodeObjectForKey:SKNewSkitchRequestDataURLKey];
    if (dataURLString != nil) {
      _dataURL = [NSURL URLWithString:dataURLString];
    }
    self.userInfo = [aDecoder decodeObjectForKey:SKNewSkitchRequestUserInfoKey];
    _resourceGUID = [aDecoder decodeObjectForKey:SKNewSkitchRequestResourceGUIDKey];
    _receipt = [aDecoder decodeObjectForKey:SKNewSkitchRequestReceiptKey];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeInt32:SKNewSkitchRequestCurrentVersion forKey:SKNewSkitchRequestVersionKey];

  [aCoder encodeObject:_mime forKey:SKNewSkitchRequestMimeKey];
  [aCoder encodeObject:_data forKey:SKNewSkitchRequestDataKey];
  [aCoder encodeObject:[_dataURL absoluteString] forKey:SKNewSkitchRequestDataURLKey];
  [aCoder encodeObject:_resourceGUID forKey:SKNewSkitchRequestResourceGUIDKey];
  [aCoder encodeObject:self.userInfo forKey:SKNewSkitchRequestUserInfoKey];
  [aCoder encodeObject:_receipt forKey:SKNewSkitchRequestReceiptKey];
}

- (NSString *) requestIdentifier {
  return NSStringFromClass([self class]);
}

- (uint32_t) version {
  return SKNewSkitchRequestCurrentVersion;
}

@end
