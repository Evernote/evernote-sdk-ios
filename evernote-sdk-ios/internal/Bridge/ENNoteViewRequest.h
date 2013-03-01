//
//  ENNoteViewRequest.h
//  EvernoteClipper
//
//  Created by Evernote Corporation on 5/27/09.
//  Copyright 2009 Evernote Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENApplicationRequest.h"

extern NSString * const ENNoteViewRequestErrorDomain;

enum {
  ENNoteViewRequestUnsupportedCommand = -4000,
  ENNoteViewRequestInvalidFormat = -4001,
};


@interface ENNoteViewRequest : NSObject<ENApplicationRequest> {
	NSString *_noteID;
	NSString *_shardID;
  NSUInteger _userID;
  NSString *_linkedNotebookID;
  NSString *_searchTerms;
}

@property (assign, nonatomic) NSUInteger userID;
@property (strong, nonatomic) NSString *noteID;
@property (strong, nonatomic) NSString *shardID;
@property (strong, nonatomic) NSString *linkedNotebookID;
@property (strong, nonatomic) NSString *searchTerms;
@property (nonatomic,copy) NSString* consumerKey;

+ (ENNoteViewRequest *) noteViewRequestWithNoteID:(NSString *)noteID;
+ (ENNoteViewRequest *) noteViewRequestWithNoteID:(NSString *)noteID searchTerms:(NSString *)searchTerms;
+ (ENNoteViewRequest *) noteViewRequestWithURL:(NSURL *)url 
                                         error:(NSError **)outError;

@end
