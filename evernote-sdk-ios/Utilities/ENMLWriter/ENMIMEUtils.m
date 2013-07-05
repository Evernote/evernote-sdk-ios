/*
 * ENMIMEUtils.m
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


#import "ENMIMEUtils.h"

#import "EvernoteSDK.h"

#if TARGET_OS_IPHONE
# import <MobileCoreServices/MobileCoreServices.h>
#else
# import <CoreServices/CoreServices.h>
#endif


@implementation ENMIMEUtils

+ (NSString *) fileExtensionForMIMEType: (NSString *) mime {
  if ([mime isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_INK]] == YES) {
    return @"png";
  }

  NSString *extension = nil;
  CFStringRef myUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, 
                                                            (__bridge CFStringRef)mime, 
                                                            NULL);
  if (myUTI != NULL) {
    CFStringRef utiExtension = UTTypeCopyPreferredTagWithClass(myUTI, kUTTagClassFilenameExtension);
    if (utiExtension != NULL) {
      if (CFStringGetLength(utiExtension) > 0) {
        extension = (__bridge_transfer NSString *)utiExtension;
      }
      else {
        CFRelease(utiExtension);
      }
    }
    CFRelease(myUTI);
  }

  if ([mime isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_GIF]] == YES && [extension isEqualToString:@"gif"] == NO) {
    extension = @"gif";
  }
  else if ([mime isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_JPEG]] == YES && [extension isEqualToString:@"jpg"] == NO) {
    extension = @"jpg";
  }
  else if (([mime isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_PNG]] == YES || [mime isEqualToString:@"image/x-png"]) && [extension isEqualToString:@"png"] == NO) {
    extension = @"png";
  }
  else if ([mime isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_WAV]] == YES && [extension isEqualToString:@"wav"] == NO) {
    extension = @"wav";
  }
  else if ([mime isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_MP3]] == YES && [extension isEqualToString:@"mp3"] == NO) {
    extension = @"mp3";
  }
  else if ([mime isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_AMR]] == YES && [extension isEqualToString:@"amr"] == NO) {
    extension = @"amr";
  }
  else if ([mime isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_MP4_VIDEO]] == YES && [extension isEqualToString:@"mp4"] == NO) {
    extension = @"mp4";
  }
  else if ([mime isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_INK]] == YES && [extension isEqualToString:@"png"] == NO) {
    extension = @"png";
  }
  else if ([mime isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_PDF]] == YES && [extension isEqualToString:@"pdf"] == NO) {
    extension = @"pdf";
  }
  
  return extension;
}

+ (NSString *) determineMIMETypeForFile: (NSString *) filename {
  NSString *mimeType = nil;
  NSString *extension = [filename pathExtension];
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

  if ([mimeType isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_GIF]] == NO && [extension isEqualToString:@"gif"] == YES) {
    mimeType = [EDAMLimitsConstants EDAM_MIME_TYPE_GIF];
  }
  else if ([mimeType isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_JPEG]] == NO && [extension isEqualToString:@"jpg"] == YES) {
    mimeType = [EDAMLimitsConstants EDAM_MIME_TYPE_JPEG];
  }
  else if ([mimeType isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_PNG]] == NO && [extension isEqualToString:@"png"] == YES) {
    mimeType = [EDAMLimitsConstants EDAM_MIME_TYPE_PNG];
  }
  else if ([mimeType isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_WAV]] == NO && [extension isEqualToString:@"wav"] == YES) {
    mimeType = [EDAMLimitsConstants EDAM_MIME_TYPE_WAV];
  }
  else if ([mimeType isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_MP3]] == NO && [extension isEqualToString:@"mp3"] == YES) {
    mimeType = [EDAMLimitsConstants EDAM_MIME_TYPE_MP3];
  }
  else if ([mimeType isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_AMR]] == NO && [extension isEqualToString:@"amr"] == YES) {
    mimeType = [EDAMLimitsConstants EDAM_MIME_TYPE_AMR];
  }
  else if ([mimeType isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_MP4_VIDEO]] == NO && [extension isEqualToString:@"mp4"] == YES) {
    mimeType = [EDAMLimitsConstants EDAM_MIME_TYPE_MP4_VIDEO];
  }
  else if ([mimeType isEqualToString:[EDAMLimitsConstants EDAM_MIME_TYPE_PDF]] == NO && [extension isEqualToString:@"pdf"] == YES) {
    mimeType = [EDAMLimitsConstants EDAM_MIME_TYPE_PDF];
  }

  return mimeType;
}

+ (NSString *) mimeTypeForUTI:(NSString *)uti {
  NSString *mimeType = nil;
  
  CFStringRef utiMimeType = UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)uti, kUTTagClassMIMEType);
  if (utiMimeType != NULL) {
    if (CFStringGetLength(utiMimeType) > 0) {
      mimeType = (__bridge_transfer NSString *)utiMimeType;
    }
    else {
      CFRelease(utiMimeType);
    }
  }
  if (mimeType == nil) {
    if ([uti isEqualToString:@"public.jpeg"]) {
      mimeType = @"image/jpeg";
    }
    else if ([uti isEqualToString:@"public.png"]) {
      mimeType = @"image/png";
    }
  }
  return mimeType;
}

@end
