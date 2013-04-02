//
//  ENNewNoteRequest.m
//  EvernoteClipper
//
//  Created by Steve White on 5/27/09.
//  Copyright 2009 Evernote Corporation. All rights reserved.
//

#import "ENNewNoteRequest.h"
#import "ENApplicationBridge_Private.h"

static int kEN_NewNoteRequest_Version = 0x00010000;
static NSString *kEN_NewNoteRequest_VersionKey = @"!version!";

static NSString *kEN_NewNoteRequest_Title = @"mTitle";
static NSString *kEN_NewNoteRequest_Content = @"mContent";
static NSString *kEN_NewNoteRequest_ContentMimeType = @"mContentMimeType";
static NSString *kEN_NewNoteRequest_SourceURL = @"mSourceURL";
static NSString *kEN_NewNoteRequest_SourceApplication = @"mSourceApplication";
static NSString *kEN_NewNoteRequest_TagNames = @"mTagNames";
static NSString *kEN_NewNoteRequest_ResourceAttachments = @"mResourceAttachments";

static NSString *kEN_NewNoteRequest_Latitude = @"mLatitude";
static NSString *kEN_NewNoteRequest_Longitude = @"mLongitude";
static NSString *kEN_NewNoteRequest_Altitude = @"mAltitude";


@implementation ENNewNoteRequest

@synthesize title = mTitle;
@synthesize content = mContent;
@synthesize contentMimeType = mContentMimeType;
@synthesize sourceURL = mSourceURL;
@synthesize sourceApplication = mSourceApplication;
@synthesize tagNames = mTagNames;
@synthesize resourceAttachments = mResourceAttachments;

@synthesize latitude = mLatitude;
@synthesize longitude = mLongitude;
@synthesize altitude = mAltitude;

- (id) init {
  self = [super init];
  if (self != nil) {
		self.latitude = NAN;
		self.longitude = NAN;
		self.altitude = NAN;
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)coder {
  self = [self init];
  if (self != nil) {
		int encodedVersion = [coder decodeIntForKey:kEN_NewNoteRequest_VersionKey];
		if (encodedVersion != kEN_NewNoteRequest_Version) {
			return nil;
		}

		self.title = [coder decodeObjectForKey:kEN_NewNoteRequest_Title];
		self.content = [coder decodeObjectForKey:kEN_NewNoteRequest_Content];
		self.contentMimeType = [coder decodeObjectForKey:kEN_NewNoteRequest_ContentMimeType];
		self.sourceURL = [coder decodeObjectForKey:kEN_NewNoteRequest_SourceURL];
		self.sourceApplication = [coder decodeObjectForKey:kEN_NewNoteRequest_SourceApplication];
		self.tagNames = [coder decodeObjectForKey:kEN_NewNoteRequest_TagNames];
		self.resourceAttachments = [coder decodeObjectForKey:kEN_NewNoteRequest_ResourceAttachments];
		
		self.latitude = [coder decodeDoubleForKey:kEN_NewNoteRequest_Latitude];
		self.longitude = [coder decodeDoubleForKey:kEN_NewNoteRequest_Longitude];
		self.altitude = [coder decodeDoubleForKey:kEN_NewNoteRequest_Altitude];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:kEN_NewNoteRequest_Version forKey:kEN_NewNoteRequest_VersionKey];
	[coder encodeObject:self.title forKey:kEN_NewNoteRequest_Title];
	[coder encodeObject:self.content forKey:kEN_NewNoteRequest_Content];
	[coder encodeObject:self.contentMimeType forKey:kEN_NewNoteRequest_ContentMimeType];
	[coder encodeObject:self.sourceURL forKey:kEN_NewNoteRequest_SourceURL];
	[coder encodeObject:self.sourceApplication forKey:kEN_NewNoteRequest_SourceApplication];
	[coder encodeObject:self.tagNames forKey:kEN_NewNoteRequest_TagNames];
	[coder encodeObject:self.resourceAttachments forKey:kEN_NewNoteRequest_ResourceAttachments];
	
	[coder encodeDouble:self.latitude forKey:kEN_NewNoteRequest_Latitude];
	[coder encodeDouble:self.longitude forKey:kEN_NewNoteRequest_Longitude];
	[coder encodeDouble:self.altitude forKey:kEN_NewNoteRequest_Altitude];
}

- (NSString *) requestIdentifier {
	return NSStringFromClass([self class]);
}

#pragma mark -
#pragma mark 
- (void) addResourceAttachment:(ENResourceAttachment *)resourceAttachment {
	NSMutableArray *resourceAttachments = [NSMutableArray arrayWithArray:self.resourceAttachments];
	[resourceAttachments addObject:resourceAttachment];
	self.resourceAttachments = [NSArray arrayWithArray:resourceAttachments];
}

- (void) removeResourceAttachment:(ENResourceAttachment *)resourceAttachment {
	NSMutableArray *resourceAttachments = [NSMutableArray arrayWithArray:self.resourceAttachments];
	[resourceAttachments removeObject:resourceAttachment];
	self.resourceAttachments = [NSArray arrayWithArray:resourceAttachments];
}

- (uint32_t) totalRequestSize {
  uint32_t result = (uint32_t)[[self content] length];
  NSArray *attachments = self.resourceAttachments;
  for (ENResourceAttachment *anAttachment in attachments) {
    NSData *resourceData = [anAttachment resourceData];
    if (resourceData != nil) {
      result += [resourceData length];
    }
    else {
      NSString *filepath = [anAttachment filepath];
      if (filepath != nil) {
        NSError *attrError = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath error:&attrError];
        if (fileAttributes == nil) {
          NSLog(@"%s attributesOfItemAtPath:%@ error:%@", __PRETTY_FUNCTION__, filepath, attrError);
        }
        else {
          result += [fileAttributes fileSize];
        }
      }
    }
  }
  return result;
}

#pragma mark -
#pragma mark 
- (NSString *) description {
	NSMutableString *ms = [NSMutableString string];
	
	[ms appendString:NSStringFromClass([self class])];
  [ms appendString:@"("];
	
  [ms appendString: @"title:"];
  [ms appendFormat: @"\"%@\"", self.title];
  [ms appendString: @",content:"];
  [ms appendFormat: @"\"%@\"", self.content];
  [ms appendString: @",contentMimeType:"];
  [ms appendFormat: @"\"%@\"", self.contentMimeType];
  [ms appendString: @",sourceURL:"];
  [ms appendFormat: @"\"%@\"", self.sourceURL];
  [ms appendString: @",sourceApplication:"];
  [ms appendFormat: @"\"%@\"", self.sourceApplication];
  [ms appendString: @",tagNames:"];
  [ms appendFormat: @"%@", self.tagNames];
  [ms appendString: @",resourceAttachments:"];
  [ms appendFormat: @"%@", self.resourceAttachments];
	
  [ms appendString: @",latitude:"];
  [ms appendFormat: @"%0.8g", self.latitude];
  [ms appendString: @",longitude:"];
  [ms appendFormat: @"%0.8g", self.longitude];
  [ms appendString: @",altitude:"];
  [ms appendFormat: @"%0.8g", self.altitude];
	
  [ms appendString: @")"];	
	
	return [NSString stringWithString:ms];
}
@end
