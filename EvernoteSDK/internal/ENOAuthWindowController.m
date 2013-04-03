//
//  ENOAuthWindowController.m
//  EvernoteSDK
//
//  Created by Dirk Holtwick on 02.04.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "ENOAuthWindowController.h"

@interface ENOAuthWindowController()

@property (nonatomic, strong) NSURL *authorizationURL;
@property (nonatomic, strong) NSString *oauthCallbackPrefix; 
@property (nonatomic, copy) NSString* currentProfileName; 
@property (nonatomic, assign) BOOL isSwitchingAllowed;
@property (nonatomic, strong) NSDate* startDate;

@end


@implementation ENOAuthWindowController

@synthesize delegate = _delegate;
@synthesize authorizationURL = _authorizationURL;
@synthesize oauthCallbackPrefix = _oauthCallbackPrefix;
@synthesize webView = _webView;

- (id)initWithAuthorizationURL:(NSURL *)authorizationURL
           oauthCallbackPrefix:(NSString *)oauthCallbackPrefix
                   profileName:(NSString *)currentProfileName
                allowSwitching:(BOOL)isSwitchingAllowed
                      delegate:(id<ENOAuthDelegate>)delegate
{
    self = [super initWithWindowNibName:NSStringFromClass(self.class)];
    if (self) {
        NSLog(@"URL %@", authorizationURL);
        self.authorizationURL = authorizationURL;
        self.oauthCallbackPrefix = oauthCallbackPrefix;
        self.currentProfileName = currentProfileName;
        self.delegate = delegate;
        self.isSwitchingAllowed = isSwitchingAllowed;
    }
    return self;
}

#pragma mark - Sheet

- (void)presentSheetForWindow:(NSWindow *)window {
    [self.activityIndicator startAnimation:nil];

    // show the sheet
    [NSApp beginSheet:self.window
       modalForWindow:window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:nil];
    
    [self updateUIForNewProfile:self.currentProfileName
           withAuthorizationURL:self.authorizationURL];
}

- (void)dismissSheet {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[NSApplication sharedApplication] endSheet:self.window];
    }];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:nil];
}

#pragma mark - Actions

- (IBAction)doCancel:(id)sender {
    [self dismissSheet];
}

//- (void)dealloc
//{
//    self.delegate = nil;
//    self.webView.delegate = nil;
//    [self.webView stopLoading];
//}
//
//- (void)cancel:(id)sender
//{
//    [self.webView stopLoading];
//    if (self.delegate) {
//        [self.delegate oauthViewControllerDidCancel:self];
//    }
//    self.delegate = nil;
//}
//
//- (void)switchProfile:(id)sender
//{
//    [self.webView stopLoading];
//    // start a page flip animation
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
//    [UIView setAnimationDuration:1.0];
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
//                           forView:[[self navigationController] view]
//                             cache:YES];
//    [self.webView setDelegate:nil];
//    // Blank out the web view
//    [self.webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
//    self.navigationItem.leftBarButtonItem = nil;
//    [UIView commitAnimations];
//}
//
//- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
//    [self.activityIndicator startAnimating];
//    [self.delegate oauthViewControllerDidSwitchProfile:self];
//}

- (void)updateUIForNewProfile:(NSString*)newProfile withAuthorizationURL:(NSURL*)authURL{
    self.authorizationURL = authURL;
    self.currentProfileName = newProfile;
    [self loadWebView];
}

- (void)loadWebView {
    [self.activityIndicator startAnimation:nil];
    self.webView.frameLoadDelegate = self;
    self.webView.policyDelegate = self;
    NSLog(@"Open URL %@", self.authorizationURL);
    [self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:self.authorizationURL]];
}

# pragma mark - WebView Delegate

- (void)webView:(WebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimation:nil];
    if ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102) {
        // ignore "Frame load interrupted" errors, which we get as part of the final oauth callback :P
        return;
    }

    if (error.code == NSURLErrorCancelled) {
        // ignore rapid repeated clicking (error code -999)
        return;
    }

    [self.webView stopLoading:nil];

    if (self.delegate) {
        [self.delegate oauthViewController:self didFailWithError:error];
        [self dismissSheet];
    }
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    [self webView:sender shouldStartLoadWithRequest:frame.dataSource.request];
}

// handles redirects, which is used by OAuth
- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener {
    if ([[request.URL absoluteString] hasPrefix:self.oauthCallbackPrefix]) {
        // this is our OAuth callback prefix, so let the delegate handle it
        if (self.delegate)
        {
            [self.delegate oauthViewController:self receivedOAuthCallbackURL:request.URL];
            [self dismissSheet];
        }
        [listener ignore];
    }
    else
    {
        // perform default action
        [listener use];
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    [self webViewDidFinishLoad:sender];
} 

- (BOOL)webView:(WebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request {
    if ([[request.URL absoluteString] hasPrefix:self.oauthCallbackPrefix]) {
        // this is our OAuth callback prefix, so let the delegate handle it
        if (self.delegate) {
            [self.delegate oauthViewController:self receivedOAuthCallbackURL:request.URL];
            [self dismissSheet];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(WebView *)webView {
    [self.activityIndicator stopAnimation:nil];
}

//# pragma mark - UIWebViewDelegate
//
//- (void)webView:(WebView *)webView didFailLoadWithError:(NSError *)error
//{
//    [self.activityIndicator stopAnimating];
//    if ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102) {
//        // ignore "Frame load interrupted" errors, which we get as part of the final oauth callback :P
//        return;
//    }
//
//    if (error.code == NSURLErrorCancelled) {
//        // ignore rapid repeated clicking (error code -999)
//        return;
//    }
//
//    [self.webView stopLoading];
//
//    if (self.delegate) {
//        [self.delegate oauthViewController:self didFailWithError:error];
//    }
//}
//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    if ([[request.URL absoluteString] hasPrefix:self.oauthCallbackPrefix]) {
//        // this is our OAuth callback prefix, so let the delegate handle it
//        if (self.delegate) {
//            [self.delegate oauthViewController:self receivedOAuthCallbackURL:request.URL];
//        }
//        return NO;
//    }
//    return YES;
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [self.activityIndicator stopAnimating];
//    self.startDate = [NSDate date];
//    NSLog(@"OAuth Step 2 - Time Running is: %f",[self.startDate timeIntervalSinceNow] * -1);
//}

@end
