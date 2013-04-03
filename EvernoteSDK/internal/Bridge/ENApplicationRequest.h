//
//  ENApplicationRequest.h
//  EvernoteClipper
//
//  Created by Evernote Corporation on 5/27/09.
//  Copyright 2009 Evernote Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ENApplicationRequest<NSObject,NSCoding>
@required
- (NSString *) requestIdentifier;

@end
