//
//  ENNoteImportRequest.m
//  Evernote
//
//  Created by Steve White on 7/20/12.
//  Copyright (c) 2012 Evernote Corporation. All rights reserved.
//

#import "ENNoteImportRequest.h"

@implementation ENNoteImportRequest

@synthesize file = _file;
@synthesize createNotebook = _createNotebook;

+ (ENNoteImportRequest *) importRequestForFile:(NSString *)file {
  ENNoteImportRequest *request = [[ENNoteImportRequest alloc] init];
  request.file = file;
  return request;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self != nil) {
    self.file = [aDecoder decodeObjectForKey:@"file"];
    self.createNotebook = [aDecoder decodeBoolForKey:@"createNotebook"];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.file forKey:@"file"];
  [aCoder encodeBool:self.createNotebook forKey:@"createNotebook"];
}

- (NSString *) requestIdentifier {
	return NSStringFromClass([self class]);
}

@end
