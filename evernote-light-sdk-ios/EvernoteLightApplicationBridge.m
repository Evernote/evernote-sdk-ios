//
//  EvernoteLightApplicationBridge.m
//  evernote-sdk-ios
//
//  Created by Martin Hering on 06.04.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "ENNewNoteRequest.h"
#import "EvernoteLightApplicationBridge.h"

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

@implementation ENNote 

@end

@implementation EvernoteLightApplicationBridge

+ (BOOL) isEvernoteInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"en://"]];
}

- (BOOL) saveNewNoteToEvernoteApp:(ENNote*)note
{
    if([EvernoteLightApplicationBridge isEvernoteInstalled])
    {
        NSMutableDictionary* appBridgeData = [NSMutableDictionary dictionary];
        ENNewNoteRequest* request = [[ENNewNoteRequest alloc] init];
        //NSMutableArray *enResources = [NSMutableArray array];
        [request setTitle:note.title];
        [request setContent:note.content];
        [request setContentMimeType:note.contentMimeType];
        /*
        [request setTagNames:note.tagNames];
        [request setLatitude:[note.attributes latitude]];
        [request setLongitude:[note.attributes longitude]];
        [request setAltitude:[note.attributes altitude]];
        if(note.resources.count > 0) {
            for (EDAMResource *edamResource in note.resources) {
                ENResourceAttachment *enRes = [[ENResourceAttachment alloc] init];
                [enRes setMimeType:edamResource.mime];
                [enRes setFilename:edamResource.attributes.fileName];
                [enRes setResourceData:edamResource.data.body];
                [enResources addObject:enRes];
            }
            [request setResourceAttachments:[NSArray arrayWithArray:enResources]];
        }
        */
        [request setSourceApplication:self.applicationName];
        [request setSourceURL:note.sourceURL];
        [request setConsumerKey:self.consumerKey];
        [appBridgeData setObject:[NSNumber numberWithUnsignedInt:kEN_ApplicationBridge_DataVersion] forKey:kEN_ApplicationBridge_DataVersionKey];
        [appBridgeData setObject:[request requestIdentifier] forKey:kEN_ApplicationBridge_RequestIdentifierKey];
        [appBridgeData setObject:self.consumerKey forKey:kEN_ApplicationBridge_ConsumerKey];
        
        
        NSData *requestData = [NSKeyedArchiver archivedDataWithRootObject:request];
        [appBridgeData setObject:requestData forKey:kEN_ApplicationBridge_RequestDataKey];
        
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
        NSString* pasteboardName = [NSString stringWithFormat:@"com.evernote.bridge.%@", self.consumerKey];
        UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
        [pasteboard setPersistent:YES];
        [pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:appBridgeData] forPasteboardType:@"$EvernoteApplicationBridgeData$"];
        NSString* openURL = [NSString stringWithFormat:@"en://app-bridge/consumerKey/%@/pasteBoardName/%@",self.consumerKey,pasteboardName];
        BOOL success = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openURL]];

        return success;
    }

return NO;
}


@end
