//
//  ENOAuthProtocol.h
//  EvernoteSDK
//
//  Created by Dirk Holtwick on 02.04.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

@protocol ENOAuthDelegate <NSObject>
- (void)oauthViewControllerDidCancel:(id)sender;
- (void)oauthViewControllerDidSwitchProfile:(id)sender;
- (void)oauthViewController:(id)sender didFailWithError:(NSError *)error;
- (void)oauthViewController:(id)sender receivedOAuthCallbackURL:(NSURL *)url;
@end
