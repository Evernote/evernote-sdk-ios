//
//  ENOAuthViewController.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 5/26/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "ENOAuthViewController.h"
#import "ENConstants.h"

@interface ENOAuthViewController() <UIWebViewDelegate>

@property (nonatomic, retain) NSURL *authorizationURL;
@property (nonatomic, retain) NSString *oauthCallbackPrefix;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, copy) NSString* currentProfileName;
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, assign) BOOL isSwitchingAllowed;

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
    [_currentProfileName release];
    [_activityIndicator release];
    [super dealloc];
}

- (id)initWithAuthorizationURL:(NSURL *)authorizationURL 
           oauthCallbackPrefix:(NSString *)oauthCallbackPrefix
                   profileName:(NSString *)currentProfileName
                allowSwitching:(BOOL)isSwitchingAllowed
                      delegate:(id<ENOAuthViewControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.authorizationURL = authorizationURL;
        self.oauthCallbackPrefix = oauthCallbackPrefix;
        self.currentProfileName = currentProfileName;
        self.delegate = delegate;
        self.isSwitchingAllowed = isSwitchingAllowed;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)] autorelease];
    
    self.navigationItem.rightBarButtonItem = cancelItem;
    
    // adding an activity indicator
    self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    [self.activityIndicator setHidesWhenStopped:YES];
    
    self.webView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    self.activityIndicator.frame = CGRectMake((self.navigationController.view.frame.size.width - (self.activityIndicator.frame.size.width/2))/2,
                                              (self.navigationController.view.frame.size.height - (self.activityIndicator.frame.size.height/2) - 44)/2,
                                              self.activityIndicator.frame.size.width,
                                              self.activityIndicator.frame.size.height);
    [self.webView addSubview:self.activityIndicator];
    [self updateUIForNewProfile:self.currentProfileName
           withAuthorizationURL:self.authorizationURL];
}

- (void)cancel:(id)sender
{
    [self.webView stopLoading];
    if (self.delegate) {
        [self.delegate oauthViewControllerDidCancel:self];
    }
    self.delegate = nil;
}

- (void)switchProfile:(id)sender
{
    [self.webView stopLoading];
    // start a page flip animation 
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                           forView:[[self navigationController] view]
                             cache:YES];
    [self.webView setDelegate:nil];
    // Blank out the web view
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
    self.navigationItem.leftBarButtonItem = nil;
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [self.activityIndicator startAnimating];
    [self.delegate oauthViewControllerDidSwitchProfile:self];
}

- (void)updateUIForNewProfile:(NSString*)newProfile withAuthorizationURL:(NSURL*)authURL{
    self.authorizationURL = authURL;
    self.currentProfileName = newProfile;
    if(self.isSwitchingAllowed) {
        NSString *leftButtonTitle = nil;
        if([self.currentProfileName isEqualToString:ENBootstrapProfileNameChina]) {
            leftButtonTitle = NSLocalizedString(@"Evernote-International", @"Evernote-International");
        }
        else {
            leftButtonTitle = NSLocalizedString(@"Evernote-China", @"Evernote-China");
        }
        UIBarButtonItem* switchProfileButton = [[[UIBarButtonItem alloc] initWithTitle:leftButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(switchProfile:)] autorelease];
        self.navigationItem.leftBarButtonItem = switchProfileButton;
    }
    [self loadWebView];
}

- (void)loadWebView {
    [self.activityIndicator startAnimating];
    [self.webView setDelegate:self];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.authorizationURL]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

# pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
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

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}

@end
