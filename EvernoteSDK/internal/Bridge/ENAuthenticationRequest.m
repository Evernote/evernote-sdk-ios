//
//  ENAuthenticationRequest.m
//  Evernote
//
//  Created by Mustafa Furniturewala on 12/27/12.
//  Copyright (c) 2012 Evernote Corporation. All rights reserved.
//

#import "ENAuthenticationRequest.h"

static NSString *ENAuthenticationRequestConsumerKeyKey = @"_consumerKey";
static NSString *ENAuthenticationRequestOauthUserAuthorizationKey = @"_oauthUserAuthorization";
static NSString *ENAuthenticationRequestProfileName = @"_profileName";

@implementation ENAuthenticationRequest


- (id) init {
    self = [super init];
    if (self != nil) {
        
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)coder {
    self = [self init];
    if (self != nil) {
        self.consumerKey = [coder decodeObjectForKey:ENAuthenticationRequestConsumerKeyKey];
        self.oauthUserAuthorization = [coder decodeObjectForKey:ENAuthenticationRequestOauthUserAuthorizationKey];
        self.profileName = [coder decodeObjectForKey:ENAuthenticationRequestProfileName];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_consumerKey forKey:ENAuthenticationRequestConsumerKeyKey];
    [coder encodeObject:_oauthUserAuthorization forKey:ENAuthenticationRequestOauthUserAuthorizationKey];
    [coder encodeObject:_profileName forKey:ENAuthenticationRequestProfileName];
}

- (NSString *) requestIdentifier {
	return NSStringFromClass([self class]);
}

@end
