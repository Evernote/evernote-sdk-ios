/*
 * SKApplicationBridge.h
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
#if TARGET_OS_IPHONE
# import <UIKit/UIKit.h>
#else
# import <Cocoa/Cocoa.h>
#endif
#import "SKBridgeRequest.h"
#import "SKBridgeReceipt.h"

extern NSString * const SKApplicationBridgeErrorDomain;

enum {
  SKApplicationBridgeErrorBadRequest = -1000,
  SKApplicationBridgeErrorNotInstalled = -2000,
  
  SKApplicationBridgeErrorInvalidReceipt = -4000,
  SKApplicationBridgeErrorUnknown = -9999,
};

@interface SKApplicationBridge : NSObject

+ (SKApplicationBridge *) sharedSkitchBridge;
- (BOOL) isSkitchInstalled;
- (NSURL *) skitchDownloadURL;

- (BOOL) performRequest:(SKBridgeRequest *)request
                  error:(NSError *__autoreleasing *)error;
- (BOOL) sendReceipt:(SKBridgeReceipt *)receipt
               error:(NSError *__autoreleasing *)error;

// For Skitch to decode incoming requests
- (SKBridgeRequest *) bridgeRequestFromURL:(NSURL *)url;

// For external apps to decode receipts sent back from Skitch
- (SKBridgeReceipt *) bridgeReceiptFromURL:(NSURL *)url;

@end
