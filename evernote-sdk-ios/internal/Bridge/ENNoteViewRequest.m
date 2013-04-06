//
//  ENNoteViewRequest.m
//  EvernoteClipper
//
//  Created by Steve White on 5/27/09.
//  Copyright 2009 Evernote Corporation. All rights reserved.
//

#import "ENNoteViewRequest.h"

enum {
  ENNoteViewRequestVersion1 = 0x00010000,
  ENNoteViewRequestVersion2 = 0x00020000,
  ENNoteViewRequestVersion3 = 0x00030000,
  ENNoteViewRequestCurrentVersion = ENNoteViewRequestVersion3,
};

static NSString *kEN_NoteViewRequest_VersionKey = @"!version!";

static NSString *kEN_NoteViewRequest_NoteID = @"mNoteID";
static NSString *kEN_NoteViewRequest_UserID = @"mUserID";
static NSString *kEN_NoteViewRequest_ShardID = @"mShardID";
static NSString *kEN_NoteViewRequest_SearchTerms = @"mSearchTerms";
static NSString *kEN_NoteViewRequest_LinkedNotebookID = @"linkedNotebookID";

NSString * const ENNoteViewRequestErrorDomain = @"ENNoteViewRequestErrorDomain";

@implementation ENNoteViewRequest

@synthesize userID = _userID;
@synthesize shardID = _shardID;
@synthesize noteID = _noteID;
@synthesize linkedNotebookID = _linkedNotebookID;
@synthesize searchTerms = _searchTerms;

+ (ENNoteViewRequest *) noteViewRequestWithNoteID:(NSString *)noteID {
	ENNoteViewRequest *result = [[ENNoteViewRequest alloc] init];
	result.noteID = noteID;
	return result;
}

+ (ENNoteViewRequest *) noteViewRequestWithNoteID:(NSString *)noteID searchTerms:(NSString *)searchTerms {
	ENNoteViewRequest *result = [[ENNoteViewRequest alloc] init];
	result.noteID = noteID;
  result.searchTerms = searchTerms;
	return result;
}

+ (ENNoteViewRequest *) noteViewRequestWithURL:(NSURL *)url 
                                         error:(NSError **)outError
{
  // Note Link specifications: https://docs.google.com/a/evernote.com/document/d/1TmG-_dgM-rJKckedAubrg9RpS4lNTFr_IhlATSPDKRc/edit?hl=en
  // URL example: evernote:///view/user_id/s1/b87917eb-ee0e-464f-9ec8-fb29fb0f93da/x-coredata%3A%2F%2FAABB6B76-F1F2-4645-83F6-79C643C61D50%2FENNote%2Fp68/
  
  //NSString *requestPath = [url path];   // this returns unescaped string with stringByReplacingPercentEscapesUsingEncoding: then mess up clientSpecificId!
  NSString *requestURL = [url absoluteString];
  
  NSArray *components = [requestURL componentsSeparatedByString:@"/"];
  NSString *command = @"";
  if (components.count > 3) {
    command = [components objectAtIndex:3];
  }
  
  if ([@"view" isEqualToString:command] == NO) {
    if (outError != nil) {
      *outError = [NSError errorWithDomain:ENNoteViewRequestErrorDomain 
                                      code:ENNoteViewRequestUnsupportedCommand 
                                  userInfo:nil];
    }
    return nil;
  }
  
  if (components.count != 9) {
    if (outError != nil) {
      NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"Error", @"Error"), NSLocalizedFailureReasonErrorKey,
                                NSLocalizedString(@"NoteLinkIsNotValidFormat", @"NoteLinkIsNotValidFormat"), NSLocalizedDescriptionKey, 
                                nil];
      *outError = [NSError errorWithDomain:ENNoteViewRequestErrorDomain 
                                      code:ENNoteViewRequestInvalidFormat 
                                  userInfo:userInfo];
      
    }
    return nil;
  }
  
  // Parse the parameters
  NSString *noteGuid = [components objectAtIndex:6];
#if 0
  NSString *clientSpecificId = [components objectAtIndex:7];
  if (clientSpecificId != nil && clientSpecificId.length > 0) {
    clientSpecificId = [clientSpecificId stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  }
  if (clientSpecificId == nil || [clientSpecificId isEqualToString:noteGuid] == YES) {
    clientSpecificId = noteGuid;
  }
#endif
  NSString *linkedNotebookGuid = [components objectAtIndex:8];
  
  ENNoteViewRequest *noteViewRequest = [[ENNoteViewRequest alloc] init];
  noteViewRequest.noteID = noteGuid;
  noteViewRequest.shardID = [components objectAtIndex:5];
  noteViewRequest.userID = [[components objectAtIndex:4] intValue];
  if (linkedNotebookGuid != nil && [linkedNotebookGuid length] > 0) {
    noteViewRequest.linkedNotebookID = linkedNotebookGuid;
  }
  return noteViewRequest;
}

- (id) initWithCoder:(NSCoder *)coder {
  self = [super init];
  if (self != nil) {
		int encodedVersion = [coder decodeIntForKey:kEN_NoteViewRequest_VersionKey];
    if (encodedVersion != ENNoteViewRequestVersion1 && encodedVersion != ENNoteViewRequestVersion2 && encodedVersion != ENNoteViewRequestVersion3) {
      NSLog(@"%s unknown version: %i !", __PRETTY_FUNCTION__, encodedVersion);
      return nil;
    }
    
    self.noteID = [coder decodeObjectForKey:kEN_NoteViewRequest_NoteID];
    if (encodedVersion >= ENNoteViewRequestVersion2) {
      self.searchTerms = [coder decodeObjectForKey:kEN_NoteViewRequest_SearchTerms];
    }
    if (encodedVersion >= ENNoteViewRequestVersion3) {
      self.linkedNotebookID = [coder decodeObjectForKey:kEN_NoteViewRequest_LinkedNotebookID];
    }
  }
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:ENNoteViewRequestCurrentVersion forKey:kEN_NoteViewRequest_VersionKey];
  
	[coder encodeObject:_noteID forKey:kEN_NoteViewRequest_NoteID];
  [coder encodeObject:_searchTerms forKey:kEN_NoteViewRequest_SearchTerms];
  [coder encodeObject:_linkedNotebookID forKey:kEN_NoteViewRequest_LinkedNotebookID];
  [coder encodeObject:_shardID forKey:kEN_NoteViewRequest_ShardID];
  [coder encodeInt:_userID forKey:kEN_NoteViewRequest_UserID];
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
	
  [ms appendString: @"noteID:"];
  [ms appendFormat: @"\"%@\",", self.noteID];
  [ms appendString: @"linkedNotebookID:"];
  [ms appendFormat: @"\"%@\",", self.linkedNotebookID];
  [ms appendString: @"shardID:"];
  [ms appendFormat: @"\"%@\",", self.shardID];
  [ms appendString: @"userID:"];
  [ms appendFormat: @"%i,", self.userID];
  [ms appendString: @"searchTerms:"];
  [ms appendFormat: @"\"%@\"", self.searchTerms];
	
  [ms appendString: @")"];	
	
	return [NSString stringWithString:ms];
}

@end
