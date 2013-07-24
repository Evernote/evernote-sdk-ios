/*
 * NSRegularExpression+ENAGRegex.m
 * evernote-sdk-ios
 *
 * Copyright 2012 Evernote Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSRegularExpression+ENAGRegex.h"

@implementation NSRegularExpression (ENAGRegex)
+ (NSRegularExpression *) enRegexWithPattern:(NSString *)pattern {
    NSError *regexError = nil;
    NSRegularExpression *result = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                            options:0
                                                                              error:&regexError];
    if (result == nil) {
        NSLog(@"regularExpressionWithPattern:%@ returned error:%@", pattern, regexError);
    }
    return result;
}

- (BOOL) enFindInString:(NSString *)string {
    NSTextCheckingResult *result = [self firstMatchInString:string
                                                    options:0
                                                      range:NSMakeRange(0, [string length])];
    return (result != nil);
}

- (BOOL) enMatchesString:(NSString *)string {
    NSRange stringRange = NSMakeRange(0, [string length]);
    NSTextCheckingResult *result = [self firstMatchInString:string
                                                    options:0
                                                      range:stringRange];
    
    if (result == nil) {
        return NO;
    }
    return NSEqualRanges([result range], stringRange);
}

- (NSArray *) enCapturedSubstringsOfString:(NSString *)string {
    __block NSMutableArray *retVal = [NSMutableArray array];
    [self enumerateMatchesInString:string
                           options:0
                             range:NSMakeRange(0, [string length])
                        usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                            for (NSUInteger i=0; i<[result numberOfRanges]; i++) {
                                NSRange range = [result rangeAtIndex:i];
                                if (range.location == NSNotFound) {
                                    [retVal addObject:[NSString string]];
                                }
                                else {
                                    NSString *matchedString=[string substringWithRange:range];
                                    [retVal addObject:matchedString];
                                }
                            }
                        }];
    return retVal;
    
}

- (NSString *)enReplaceWithString:(NSString *)rep inString:(NSString *)str {
    return [self stringByReplacingMatchesInString:str
                                          options:0
                                            range:NSMakeRange(0, [str length])
                                     withTemplate:rep];
}

@end
