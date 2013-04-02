//
//  ENAuthenticationRequest.h
//  Evernote
//
//  Created by Mustafa Furniturewala on 12/27/12.
//  Copyright (c) 2012 Evernote Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENApplicationRequest.h"

@interface ENAuthenticationRequest : NSObject <ENApplicationRequest>

@property (nonatomic,copy) NSString* consumerKey;
@property (nonatomic,copy) NSString* oauthUserAuthorization;
@property (nonatomic,copy) NSString* profileName;

@end
