//
//  ENLinkNotebookRequest.m
//  Evernote
//
//  Created by Steve White on 9/14/11.
//  Copyright 2011 Evernote Corporation. All rights reserved.
//

#import "ENLinkNotebookRequest.h"

static int ENLinkNotebookRequestVersion = 0x00010000;
static NSString *ENLinkNotebookRequestVersionKey = @"!version!";
static NSString *ENLinkNotebookRequestOwnerName = @"_ownerName";
static NSString *ENLinkNotebookRequestShareKey = @"_shareKey";
static NSString *ENLinkNotebookRequestShardID = @"_shardID";
static NSString *ENLinkNotebookRequestName = @"_name";

@implementation ENLinkNotebookRequest

@synthesize ownerName = _ownerName;
@synthesize shareKey = _shareKey;
@synthesize shardID = _shardID;
@synthesize name = _name;

+ (ENLinkNotebookRequest *) linkNotebookRequestWithName:(NSString *)name
                                              ownerName:(NSString *)ownerName
                                               shareKey:(NSString *)shareKey 
                                                shardID:(NSString *)shardID
{
  ENLinkNotebookRequest *request = [[ENLinkNotebookRequest alloc] init];
  request.shareKey = shareKey;
  request.ownerName = ownerName;
  request.name = name;
  request.shardID = shardID;
  return request;
}

- (id) initWithCoder:(NSCoder *)coder {
  self = [super init];
  if (self != nil) {
		int encodedVersion = [coder decodeIntForKey:ENLinkNotebookRequestVersionKey];
		if (encodedVersion != ENLinkNotebookRequestVersion) {
			return nil;
		}
    self.ownerName = [coder decodeObjectForKey:ENLinkNotebookRequestOwnerName];
    self.shareKey = [coder decodeObjectForKey:ENLinkNotebookRequestShareKey];
    self.name = [coder decodeObjectForKey:ENLinkNotebookRequestName];
    self.shardID = [coder decodeObjectForKey:ENLinkNotebookRequestShardID];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:ENLinkNotebookRequestVersion forKey:ENLinkNotebookRequestVersionKey];
  [coder encodeObject:_ownerName forKey:ENLinkNotebookRequestOwnerName];
	[coder encodeObject:_shareKey forKey:ENLinkNotebookRequestShareKey];
  [coder encodeObject:_name forKey:ENLinkNotebookRequestName];
  [coder encodeObject:_shardID forKey:ENLinkNotebookRequestShardID];
}


- (NSString *) requestIdentifier {
	return NSStringFromClass([self class]);
}

#pragma mark -
#pragma mark 
- (NSString *) description {
	NSMutableString *ms = [NSMutableString string];
	
	[ms appendString:NSStringFromClass([self class])];
  [ms appendString:@"("];
	
  [ms appendString: @"name:"];
  [ms appendFormat: @"\"%@\"", _name];
  [ms appendString: @",ownerName:"];
  [ms appendFormat: @"\"%@\"", _ownerName];
  [ms appendString: @",shareKey:"];
  [ms appendFormat: @"\"%@\"", _shareKey];
  [ms appendString: @",shardID:"];
  [ms appendFormat: @"\"%@\"", _shardID];
	
  [ms appendString: @")"];	
	
	return [NSString stringWithString:ms];
}

@end
