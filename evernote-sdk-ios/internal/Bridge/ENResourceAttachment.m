//
//  ENResourceAttachment.m
//  EvernoteClipper
//
//  Created by Steve White on 5/27/09.
//  Copyright 2009 Evernote Corporation. All rights reserved.
//

#import "ENResourceAttachment.h"
#import "ENApplicationBridge_Private.h"

static int kEN_ResourceAttachment_Version = 0x00010000;
static NSString *kEN_ResourceAttachment_VersionKey = @"!version!";

static NSString *kEN_ResourceAttachment_ResourceData = @"mResourceData";
static NSString *kEN_ResourceAttachment_MimeType = @"mMimeType";
static NSString *kEN_ResourceAttachment_Filename = @"mFilename";


@implementation ENResourceAttachment

@synthesize resourceData = mResourceData;
@synthesize mimeType = mMimeType;
@synthesize filename = mFilename;
@synthesize filepath = mFilepath;

- (id) initWithCoder:(NSCoder *)coder {
  self = [super init];
  if (self != nil) {
		int encodedVersion = [coder decodeIntForKey:kEN_ResourceAttachment_VersionKey];
		if (encodedVersion != kEN_ResourceAttachment_Version) {
			return nil;
		}

		self.resourceData = [coder decodeObjectForKey:kEN_ResourceAttachment_ResourceData];
		self.mimeType = [coder decodeObjectForKey:kEN_ResourceAttachment_MimeType];
		self.filename = [coder decodeObjectForKey:kEN_ResourceAttachment_Filename];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:kEN_ResourceAttachment_Version forKey:kEN_ResourceAttachment_VersionKey];
	[coder encodeObject:self.resourceData forKey:kEN_ResourceAttachment_ResourceData];
	[coder encodeObject:self.mimeType forKey:kEN_ResourceAttachment_MimeType];
	[coder encodeObject:self.filename forKey:kEN_ResourceAttachment_Filename];
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
	
  [ms appendString: @"resourceData:"];
  [ms appendFormat: @"%@", self.resourceData];
  [ms appendString: @",mimeType:"];
  [ms appendFormat: @"\"%@\"", self.mimeType];
  [ms appendString: @",filename:"];
  [ms appendFormat: @"\"%@\"", self.filename];
	
  [ms appendString: @")"];	
	
	return [NSString stringWithString:ms];
}
@end
