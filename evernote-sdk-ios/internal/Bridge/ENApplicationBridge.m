//
//  ENApplicationBridge.m
//  EvernoteClipper
//
//  Created by Steve White on 5/27/09.
//  Copyright 2009 Evernote Corporation. All rights reserved.
//

#import "ENApplicationBridge.h"
#import "ENApplicationBridge_Private.h"

NSString * const kEN_ApplicationBridge_EvernoteNotInstalled = @"EN_ApplicationBridge_EvernoteNotInstalled";
NSString * const kEN_ApplicationBridge_InvalidRequestType = @"EN_ApplicationBridge_InvalidRequestType";

const uint32_t kEN_ApplicationBridge_DataVersion = 0x00010000;

NSString * const kEN_ApplicationBridge_DataVersionKey = @"$dataVersion$";
NSString * const kEN_ApplicationBridge_CallBackURLKey = @"$callbackURL$";
NSString * const kEN_ApplicationBridge_RequestIdentifierKey = @"$requestIdentifier$";
NSString * const kEN_ApplicationBridge_RequestDataKey = @"$requestData$";
NSString * const kEN_ApplicationBridge_CallerAppNameKey = @"$callerAppName$";
NSString * const kEN_ApplicationBridge_CallerAppIdentifierKey = @"$callerAppIdentifier$";
NSString * const kEN_ApplicationBridge_ConsumerKey = @"$consumerKey$";

@implementation ENApplicationBridge

+ (ENApplicationBridge *) newApplicationBridge {
	ENApplicationBridge *result = [[ENApplicationBridge alloc] init];
	return result;
}

#pragma mark -
#pragma mark 
- (NSURL *) _iphoneBaseURL {
	return [NSURL URLWithString:@"evernote://applicationBridge"];
}

#pragma mark -
#pragma mark 
- (BOOL) isEvernoteInstalled {
#if TARGET_OS_IPHONE
	return [[UIApplication sharedApplication] canOpenURL:[self _iphoneBaseURL]];
#else
	NSString *path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.evernote.Evernote"];
	return path != nil;
#endif
}

- (NSURL *) evernoteDownloadURL {
#if TARGET_OS_IPHONE
	return [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=281796108&mt=8"];
#else
	return [NSURL URLWithString:@"http://www.evernote.com/download/#a-macwin"];
#endif
}

#if TARGET_OS_IPHONE
- (void) _performIphoneRequest:(id<ENApplicationRequest>)request withCallbackURL:(NSURL *)callbackURL {
	NSMutableDictionary *appBridgeData = [NSMutableDictionary dictionary];

	[appBridgeData setObject:[NSNumber numberWithUnsignedInt:kEN_ApplicationBridge_DataVersion] forKey:kEN_ApplicationBridge_DataVersionKey];
	[appBridgeData setObject:[request requestIdentifier] forKey:kEN_ApplicationBridge_RequestIdentifierKey];
	
	NSData *requestData = [NSKeyedArchiver archivedDataWithRootObject:request];
	[appBridgeData setObject:requestData forKey:kEN_ApplicationBridge_RequestDataKey];
	
	if (callbackURL != nil) {
		[appBridgeData setObject:callbackURL forKey:kEN_ApplicationBridge_CallBackURLKey];
	}
	
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	if (infoDictionary != nil) {
		NSString *appIdentifier = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
		if (appIdentifier != nil) {
			[appBridgeData setObject:appIdentifier forKey:kEN_ApplicationBridge_CallerAppIdentifierKey];
		}
		NSString *appName = [infoDictionary objectForKey:(NSString *)kCFBundleNameKey];
		if (appName != nil) {
			[appBridgeData setObject:appName forKey:kEN_ApplicationBridge_CallerAppNameKey];
		}
	}
	
	// XXX: I cannot get a custom pasteboard to be persistent... so for the
	// time being, we'll have to shove this onto the general pasteboard.
	//	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithUniqueName];
	//	[pasteboard setPersistent:YES];
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	[pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:appBridgeData] forPasteboardType:@"$EvernoteApplicationBridgeData$"];
	
	NSString *baseURL = [[self _iphoneBaseURL] absoluteString];
	NSString *pasteboardURI = [NSString stringWithFormat:@"/pasteboardName:%@", [pasteboard name]];
	NSString *finalURL = [baseURL stringByAppendingString:pasteboardURI];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:finalURL]];
}
#else
- (void) _performDesktopRequest:(id<ENApplicationRequest>)request withCallbackURL:(NSURL *)callbackURL {
	// XXX: Implement me!
}
#endif

- (void) performRequest:(id<ENApplicationRequest>)request withCallbackURL:(NSURL *)callbackURL {
	if ([request conformsToProtocol:@protocol(ENApplicationRequest)] == NO || [request requestIdentifier] == nil) {
		NSException *e = [NSException exceptionWithName:kEN_ApplicationBridge_InvalidRequestType
																						 reason:nil
																					 userInfo:nil];
		@throw e;
	}
	if ([self isEvernoteInstalled] == NO) {
		NSException *e = [NSException exceptionWithName:kEN_ApplicationBridge_EvernoteNotInstalled
																						 reason:nil
																					 userInfo:nil];
		@throw e;
	}

#if TARGET_OS_IPHONE
	[self _performIphoneRequest:request withCallbackURL:callbackURL];
#else
	[self _performDesktopRequest:request withCallbackURL:callbackURL];
#endif
}

- (void) performRequest:(id<ENApplicationRequest>)request {
	[self performRequest:request withCallbackURL:nil];
}
@end
