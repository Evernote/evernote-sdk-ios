//
//  EvernoteLightApplicationBridge.h
//  evernote-sdk-ios
//
//  Created by Martin Hering on 06.04.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENNote : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSURL* sourceURL;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSString* contentMimeType;
@end



@interface EvernoteLightApplicationBridge : NSObject

+ (BOOL) isEvernoteInstalled;

@property (nonatomic, strong) NSString* applicationName;
@property (nonatomic, strong) NSString* consumerKey;


- (BOOL) saveNewNoteToEvernoteApp:(ENNote*)note;
@end
