//
//  ENCredentials.h
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/5/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENCredentials : NSObject <NSCoding>

@property (nonatomic, retain) NSString *host;
@property (nonatomic, retain) NSString *edamUserId;
@property (nonatomic, retain) NSString *noteStoreUrl;
@property (nonatomic, retain) NSString *authenticationToken;

- (id)initWithHost:(NSString *)host
        edamUserId:(NSString *)edamUserId
      noteStoreUrl:(NSString *)noteStoreUrl
authenticationToken:(NSString *)authenticationToken;

- (BOOL)saveToKeychain;
- (void)deleteFromKeychain;

@end
