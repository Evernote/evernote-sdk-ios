// Created by khammond on Mon Oct 29 2001.
// Formatted by Timothy Hatcher on Sun Jul 4 2004.
// Copyright (c) 2001 Kyle Hammond. All rights reserved.
// Original development by Dave Winer.

@interface NSData (NSDataBase64Additions)
+ (NSData *) endataWithBase64EncodedString:(NSString *) string;
- (id) initWithBase64EncodedString:(NSString *) string;

- (NSString *) enbase64Encoding;
- (NSString *) enbase64EncodingWithLineLength:(unsigned int) lineLength;
@end
