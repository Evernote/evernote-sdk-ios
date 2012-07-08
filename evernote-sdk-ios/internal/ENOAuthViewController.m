//
//  ENOAuthViewController.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 5/26/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "ENOAuthViewController.h"

@interface ENOAuthViewController() <UIWebViewDelegate>

@property (nonatomic, retain) NSURL *authorizationURL;
@property (nonatomic, retain) NSString *oauthCallbackPrefix;
@property (nonatomic, retain) UIWebView *webView;

@end

@implementation ENOAuthViewController

@synthesize delegate = _delegate;
@synthesize authorizationURL = _authorizationURL;
@synthesize oauthCallbackPrefix = _oauthCallbackPrefix;
@synthesize webView = _webView;

- (void)dealloc
{
    self.delegate = nil;
    self.webView.delegate = nil;
    [self.webView stopLoading];
    [_webView release];
    [_authorizationURL release];
    [_oauthCallbackPrefix release];
    [super dealloc];
}

- (id)initWithAuthorizationURL:(NSURL *)authorizationURL 
           oauthCallbackPrefix:(NSString *)oauthCallbackPrefix
                      delegate:(id<ENOAuthViewControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.authorizationURL = authorizationURL;
        self.oauthCallbackPrefix = oauthCallbackPrefix;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem = cancelItem;
    
    // TODO: Using self.view.frame leaves a 20px black space above the webview... from status bar spacing?
    //self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.authorizationURL]];
}

- (void)cancel:(id)sender
{
    [self.webView stopLoading];
    if (self.delegate) {
        [self.delegate oauthViewControllerDidCancel:self];
    }
    self.delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

# pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102) {
        // ignore "Frame load interrupted" errors, which we get as part of the final oauth callback :P
        return;
    }
    
    if (error.code == NSURLErrorCancelled) {
        // ignore rapid repeated clicking (error code -999)
        return;
    }
    
    [self.webView stopLoading];

    if (self.delegate) {
        [self.delegate oauthViewController:self didFailWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[request.URL absoluteString] hasPrefix:self.oauthCallbackPrefix]) {
        // this is our OAuth callback prefix, so let the delegate handle it
        if (self.delegate) {
            [self.delegate oauthViewController:self receivedOAuthCallbackURL:request.URL];
        }
        return NO;
    }
    return YES;
}

@end
