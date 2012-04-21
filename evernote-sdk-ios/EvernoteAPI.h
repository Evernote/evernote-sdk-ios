//
//  EvernoteAPI.h
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/20/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvernoteSession.h"

@interface EvernoteAPI : NSObject

+ (EvernoteAPI *)api;
- (id)initWithSession:(EvernoteSession *)session;
- (NSArray *)listNotebooksWithError:(NSError **)error;

@end
