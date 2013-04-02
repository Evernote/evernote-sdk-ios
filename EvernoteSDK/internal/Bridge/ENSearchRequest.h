//
//  ENSearchRequest.h
//  EvernoteClipper
//
//  Created by Evernote Corporation on 5/27/09.
//  Copyright 2009 Evernote Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENApplicationRequest.h"

@interface ENSearchRequest : NSObject<ENApplicationRequest> {
	NSString *mQueryString;
}

@property (strong, nonatomic) NSString *queryString;

+ (ENSearchRequest *) searchRequestWithQueryString:(NSString *)queryString;
+ (ENSearchRequest *) searchRequestForSourceApplication:(NSString *)sourceApplication;

@end
