//
//  ENApplicationBridge_Private.h
//  Evernote
//
//  Created by Steve White on 5/7/10.
//  Copyright 2010 Evernote Corporation. All rights reserved.
//

#import "ENNewNoteRequest.h"
#import "ENResourceAttachment.h"

extern const uint32_t kEN_ApplicationBridge_DataVersion;

extern NSString * const kEN_ApplicationBridge_DataVersionKey;
extern NSString * const kEN_ApplicationBridge_CallBackURLKey;
extern NSString * const kEN_ApplicationBridge_RequestIdentifierKey;
extern NSString * const kEN_ApplicationBridge_RequestDataKey;
extern NSString * const kEN_ApplicationBridge_CallerAppNameKey;
extern NSString * const kEN_ApplicationBridge_CallerAppIdentifierKey;
extern NSString * const kEN_ApplicationBridge_ConsumerKey;

@interface ENResourceAttachment ()
@property (strong, nonatomic) NSString *filepath;
@end

@interface ENNewNoteRequest ()
- (uint32_t) totalRequestSize;
@end
