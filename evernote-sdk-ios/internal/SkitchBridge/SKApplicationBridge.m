/*
 * SKApplicationBridge.m
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

#import "SKApplicationBridge.h"

NSString * const SKApplicationBridgeErrorDomain = @"SKApplicationBridgeErrorDomain";
NSString * const SKApplicationBridgeScheme = @"skitch";

NSString * const SKApplicationBridgePayloadIdentifier = @"$$SkitchBridgePayload$$";
NSString * const SKApplicationBridgePayloadVersion = @"$$SkitchBridgeVersion$$";
NSString * const SKApplicationBridgePayloadData = @"$$SkitchBridgeData$$";

NSString * const SKApplicationBridgePasteboardPath = @"/pasteboardName:";
NSString * const SKApplicationBridgeReceiptParameter = @"pasteboardName";

enum {
  SKApplicationBridgeVersion1 = 0x00010000,
  SKApplicationBridgeCurrentVersion = SKApplicationBridgeVersion1,
};


@implementation SKApplicationBridge

+ (SKApplicationBridge *) sharedSkitchBridge {
  static dispatch_once_t pred;
  static SKApplicationBridge *sharedBridge = nil;
  
  dispatch_once(&pred, ^{ sharedBridge = [[self alloc] init]; });
  return sharedBridge;
}

- (BOOL) isSkitchInstalled {
  NSURL *skitchBridgeURL = [[NSURL alloc] initWithScheme:SKApplicationBridgeScheme
                                                    host:@""
                                                    path:@"/"];
  return [[UIApplication sharedApplication] canOpenURL:skitchBridgeURL];
}

- (NSURL *) skitchDownloadURL {
  return [NSURL URLWithString:@"https://itunes.apple.com/us/app/skitch/id490505997?mt=8"];
}

#pragma mark -
#pragma mark
- (NSString *) encodeObjectOntoPasteboard:(id<NSCoding>)object {
	NSData *requestData = [NSKeyedArchiver archivedDataWithRootObject:object];
  if (requestData == nil) {
    return nil;
  }

  NSDictionary *appBridgeData = @{SKApplicationBridgePayloadVersion: @(SKApplicationBridgeCurrentVersion), SKApplicationBridgePayloadData: requestData};

	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithUniqueName];
  pasteboard.persistent = YES;
	[pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:appBridgeData]
    forPasteboardType:SKApplicationBridgePayloadIdentifier];
	
  return [pasteboard name];
}

- (id) decodeObjectFromPasteboardNamed:(NSString *)pasteboardName {
  UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:NO];
  if (pasteboard == nil) {
    NSLog(@"Unable to find pasteboard with name:%@", pasteboardName);
    return nil;
  }
  
  NSData *payloadData = [pasteboard valueForPasteboardType:SKApplicationBridgePayloadIdentifier];
  if (payloadData == nil) {
    NSLog(@"Unable to find pasteboard type:%@ in pasteboard named:%@", SKApplicationBridgePayloadIdentifier, pasteboardName);
    return nil;
  }
  
  [UIPasteboard removePasteboardWithName:pasteboardName];
  
  NSDictionary *payload = [NSKeyedUnarchiver unarchiveObjectWithData:payloadData];
  if (payload == nil || [payload isKindOfClass:[NSDictionary class]] == NO) {
    NSLog(@"Invalid payload in pasteboard: %@", payload);
    return nil;
  }
  
  uint32_t payloadVersion = [[payload objectForKey:SKApplicationBridgePayloadVersion] unsignedIntValue];
  if (payloadVersion > SKApplicationBridgeCurrentVersion) {
    NSLog(@"Unsupported payload version 0x%08x (we support maximum 0x%08x)", payloadVersion, SKApplicationBridgeCurrentVersion);
    return nil;
  }
  
  NSData *requestData = [payload objectForKey:SKApplicationBridgePayloadData];
  if (requestData == nil || [requestData isKindOfClass:[NSData class]] == NO) {
    NSLog(@"Invalid request data:%@", requestData);
    NSLog(@"Payload: %@", payload);
    return nil;
  }
  
  id object = [NSKeyedUnarchiver unarchiveObjectWithData:requestData];
  return object;
}

#pragma mark -
#pragma mark Request helpers
- (BOOL) performRequest:(SKBridgeRequest *)request
                  error:(NSError *__autoreleasing *)error
{
	if ([request isKindOfClass: [SKBridgeRequest class]] == NO || [request requestIdentifier] == nil) {
    if (error != nil) {
      *error = [NSError errorWithDomain:SKApplicationBridgeErrorDomain
                                   code:SKApplicationBridgeErrorBadRequest
                               userInfo:nil];
    }
    return NO;
	}
  
  if ([self isSkitchInstalled] == NO) {
    if (error != nil) {
      *error = [NSError errorWithDomain:SKApplicationBridgeErrorDomain
                                   code:SKApplicationBridgeErrorNotInstalled
                               userInfo:nil];
    }
    return NO;
  }
 
  NSString *pasteboardName = [self encodeObjectOntoPasteboard:request];
  if (pasteboardName == nil) {
    if (error != nil) {
      *error = [NSError errorWithDomain:SKApplicationBridgeErrorDomain
                                   code:SKApplicationBridgeErrorUnknown
                               userInfo:nil];
    }
    return NO;
  }
  
  NSURL *skitchURL = [[NSURL alloc] initWithScheme:SKApplicationBridgeScheme
                                              host:@""
                                              path:[NSString stringWithFormat:@"%@%@", SKApplicationBridgePasteboardPath, pasteboardName]];

	[[UIApplication sharedApplication] openURL:skitchURL];
  return YES;
}

- (SKBridgeRequest *) bridgeRequestFromURL:(NSURL *)url {
  NSString *scheme = [url scheme];
  if ([scheme isEqualToString:SKApplicationBridgeScheme] == NO) {
    NSLog(@"Invalid scheme in URL:%@ (expected:%@)", url, SKApplicationBridgeScheme);
    return nil;
  }
  
  NSString *path = [url path];
  if ([path hasPrefix:SKApplicationBridgePasteboardPath] == NO) {
    NSLog(@"Invalid path in URL:%@ (expected prefix:%@)", path, SKApplicationBridgePasteboardPath);
    return nil;
  }
  
  NSString *pasteboardName = [path substringFromIndex:[SKApplicationBridgePasteboardPath length]];
  if (pasteboardName == nil) {
    NSLog(@"Missing pasteboard name in URL:%@", url);
    return nil;
  }
  
  SKBridgeRequest *request = [self decodeObjectFromPasteboardNamed:pasteboardName];
    if (request == nil || [request isKindOfClass: [SKBridgeRequest class]] == NO) {
    NSLog(@"Invalid pasteboard data");
    return nil;
  }
  
  return request;
}

#pragma mark -
#pragma mark Receipt helpers
- (BOOL) sendReceipt:(SKBridgeReceipt *)receipt
               error:(NSError *__autoreleasing *)error
{
  if ([receipt isKindOfClass:[SKBridgeReceipt class]] == NO) {
    if (error != nil) {
      *error = [NSError errorWithDomain:SKApplicationBridgeErrorDomain
                                   code:SKApplicationBridgeErrorInvalidReceipt
                               userInfo:nil];
    }
    return NO;
	}

  NSURL *callbackURL = receipt.callbackURL;
  if (callbackURL == nil || [[UIApplication sharedApplication] canOpenURL:callbackURL] == NO) {
    if (error != nil) {
      *error = [NSError errorWithDomain:SKApplicationBridgeErrorDomain
                                   code:SKApplicationBridgeErrorInvalidReceipt
                               userInfo:nil];
    }
    return NO;
  }
  
  
  NSString *pasteboardName = [self encodeObjectOntoPasteboard:receipt];
  if (pasteboardName == nil) {
    if (error != nil) {
      *error = [NSError errorWithDomain:SKApplicationBridgeErrorDomain
                                   code:SKApplicationBridgeErrorUnknown
                               userInfo:nil];
    }
    return NO;
  }

  NSString *finalURL = [[callbackURL absoluteString] stringByAppendingFormat:@"%@%@=%@", ([callbackURL query] == nil ? @"?" : @"&"), SKApplicationBridgeReceiptParameter, pasteboardName];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:finalURL]];
  return YES;
}

- (SKBridgeReceipt *) bridgeReceiptFromURL:(NSURL *)url {
  NSString *query = [url query];
  if (query == nil) {
    NSLog(@"Missing query in URL:%@", url);
    return nil;
  }
  
  NSArray *parameters = [query componentsSeparatedByString:@"&"]; // somewhat error prone...
  NSString *pasteboardName = nil;
  for (NSString *aParameter in parameters) {
    NSArray *keyValuePair = [aParameter componentsSeparatedByString:@"="];
    if ([keyValuePair count] == 2 && [[keyValuePair objectAtIndex:0] isEqualToString:SKApplicationBridgeReceiptParameter]) {
      pasteboardName = [keyValuePair lastObject];
      break;
    }
  }
  
  if (pasteboardName == nil) {
    NSLog(@"Missing pasteboard parameter (%@) in URL:%@", SKApplicationBridgeReceiptParameter, url);
    return nil;
  }
  
  id payload = [self decodeObjectFromPasteboardNamed:pasteboardName];
  if (payload == nil || [payload isKindOfClass:[SKBridgeReceipt class]] == NO) {
    NSLog(@"Invalid pasteboard data");
    return nil;
  }
  
  return payload;
}

@end
