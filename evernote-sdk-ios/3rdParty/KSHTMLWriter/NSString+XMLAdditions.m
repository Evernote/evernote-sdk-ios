//
//  NSString+XMLAdditions.m
//  Evernote
//
//  Created by Steve White on 10/5/07.
//  Copyright 2007 Evernote Corporation. All rights reserved.
//

#import "NSString+XMLAdditions.h"

@implementation NSString (XMLAdditions)

// see .h
- (NSString *) stringByEscapingCriticalXMLEntities
{
  NSMutableString * mutable = [NSMutableString stringWithString:self];
  [mutable replaceOccurrencesOfString: @"&"
                           withString: @"&amp;"
                              options: NSLiteralSearch
                                range: NSMakeRange(0, mutable.length)];
  [mutable replaceOccurrencesOfString: @"<"
                           withString: @"&lt;"
                              options: NSLiteralSearch
                                range: NSMakeRange(0, mutable.length)];
  [mutable replaceOccurrencesOfString: @">"
                           withString: @"&gt;"
                              options: NSLiteralSearch
                                range: NSMakeRange(0, mutable.length)];
  [mutable replaceOccurrencesOfString: @"'"
                           withString: @"&#x27;"
                              options: NSLiteralSearch
                                range: NSMakeRange(0, mutable.length)];
  [mutable replaceOccurrencesOfString: @"\""
                           withString: @"&quot;"
                              options: NSLiteralSearch
                                range: NSMakeRange(0, mutable.length)];
  return mutable;
}

- (NSString *) stringByUnescapingCrititcalXMLEntities
{
  NSMutableString *mutable = [NSMutableString stringWithString:self];
  [mutable replaceOccurrencesOfString:@"&amp;"
                           withString:@"&"
                              options:NSLiteralSearch
                                range:NSMakeRange(0, mutable.length)];
  [mutable replaceOccurrencesOfString:@"&lt;"
                           withString:@"<"
                              options:NSLiteralSearch
                                range:NSMakeRange(0, mutable.length)];
  [mutable replaceOccurrencesOfString:@"&gt;"
                           withString:@">"
                              options:NSLiteralSearch
                                range:NSMakeRange(0, mutable.length)];
  [mutable replaceOccurrencesOfString:@"&#x27;"
                           withString:@"'"
                              options:NSLiteralSearch
                                range:NSMakeRange(0, mutable.length)];
  [mutable replaceOccurrencesOfString:@"&quot;"
                           withString:@"\""
                              options:NSLiteralSearch
                                range:NSMakeRange(0, mutable.length)];
  return mutable;
};

@end
