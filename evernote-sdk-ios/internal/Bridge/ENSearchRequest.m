//
//  ENSearchRequest.m
//  EvernoteClipper
//
//  Created by Steve White on 5/27/09.
//  Copyright 2009 Evernote Corporation. All rights reserved.
//

#import "ENSearchRequest.h"

static int kEN_SearchRequest_Version = 0x00010000;
static NSString *kEN_SearchRequest_VersionKey = @"!version!";
static NSString *kEN_SearchRequest_QueryString = @"mQueryString";

@implementation ENSearchRequest

@synthesize queryString = mQueryString;

+ (ENSearchRequest *) searchRequestWithQueryString:(NSString *)queryString {
	ENSearchRequest *result = [[ENSearchRequest alloc] init];
	result.queryString = queryString;
	return result;
}

+ (ENSearchRequest *) searchRequestForSourceApplication:(NSString *)sourceApplication {
	NSString *queryString = [NSString stringWithFormat:@"sourceApplication:\"%@\"", sourceApplication];
	return [self searchRequestWithQueryString:queryString];
}


- (id) initWithCoder:(NSCoder *)coder {
  self = [super init];
  if (self != nil) {
		int encodedVersion = [coder decodeIntForKey:kEN_SearchRequest_VersionKey];
		if (encodedVersion != kEN_SearchRequest_Version) {
			return nil;
		}
		self.queryString = [coder decodeObjectForKey:kEN_SearchRequest_QueryString];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:kEN_SearchRequest_Version forKey:kEN_SearchRequest_VersionKey];
	[coder encodeObject:self.queryString forKey:kEN_SearchRequest_QueryString];
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
	
  [ms appendString: @"queryString:"];
  [ms appendFormat: @"\"%@\"", self.queryString];
	
  [ms appendString: @")"];	
	
	return [NSString stringWithString:ms];
}


@end
