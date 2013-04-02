//
//  ENLinkNotebookRequest.h
//  Evernote
//
//  Created by Steve White on 9/14/11.
//  Copyright 2011 Evernote Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENApplicationRequest.h"

@interface ENLinkNotebookRequest : NSObject<ENApplicationRequest> {
  NSString *_shareKey;
  NSString *_shardID;
  NSString *_name;
  NSString *_ownerName;
}

@property (strong, nonatomic) NSString *shareKey;
@property (strong, nonatomic) NSString *shardID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *ownerName;

+ (ENLinkNotebookRequest *) linkNotebookRequestWithName:(NSString *)name
                                              ownerName:(NSString *)ownerName
                                               shareKey:(NSString *)shareKey
                                                shardID:(NSString *)shardID;


@end
