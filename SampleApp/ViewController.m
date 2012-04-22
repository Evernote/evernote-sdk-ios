//
//  ViewController.m
//  OAuthTest
//
//  Created by Matthew McGlincy on 3/17/12.
//

#import "EvernoteAsyncNoteStore.h"
#import "EvernoteNoteStore.h"
#import "EvernoteSession.h"
#import "EvernoteUserStore.h"
#import "GCOAuth.h"
#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

@synthesize userLabel;
@synthesize listNotebooksButton;
@synthesize authenticateButton;
@synthesize logoutButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self updateButtonsForAuthentication];
}

- (void)viewDidUnload
{
    [self setListNotebooksButton:nil];
    [self setUserLabel:nil];
    [self setAuthenticateButton:nil];
    [self setLogoutButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)authenticate:(id)sender 
{
    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithCompletionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" 
                                                             message:@"Could not authenticate" 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK" 
                                                   otherButtonTitles:nil] autorelease];
            [alert show];
        } else {
            [self updateButtonsForAuthentication];
        } 
    }];
}

- (void)showUserInfo
{
    EvernoteSession *session = [EvernoteSession sharedSession];
    // Use a try/catch block around any Evernote/Thrift operations,
    // which might throw a TException, EDAMUserException, or EDAMSystemException.
    @try {
        EDAMUser *user = [session.userStore getUser:session.authenticationToken];
        self.userLabel.text = user.username;
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
    }
}

- (IBAction)listNotes:(id)sender {
    /* 
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    NSArray *notebooks = [noteStore listNotebooks];
    if (noteStore.error) {
        NSLog(@"error %@", noteStore.error);        
    } else {
        NSLog(@"notebooks: %@", notebooks);
    }
     */
    
    /*
    EvernoteUserStore *userStore = [EvernoteUserStore userStore];
    EDAMUser *user = [userStore getUser];
    if (userStore.error) {
        NSLog(@"error %@", userStore.error);        
    } else {
        NSLog(@"user: %@", user);
    }
     */
    EvernoteAsyncNoteStore *noteStore = [EvernoteAsyncNoteStore noteStore];
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
        NSLog(@"notebooks: %@", notebooks);
    }
                                failure:^(NSError *error) {
                                    NSLog(@"error %@", noteStore.error);                                            
                                }];
}

- (void)updateButtonsForAuthentication 
{    
    EvernoteSession *session = [EvernoteSession sharedSession];

    if (session.isAuthenticated) {
        self.authenticateButton.enabled = NO;
        self.authenticateButton.alpha = 0.5;
        self.listNotebooksButton.enabled = YES;
        self.listNotebooksButton.alpha = 1.0;
        self.logoutButton.enabled = YES;
        self.logoutButton.alpha = 1.0; 
        [self showUserInfo];
    } else {
        self.authenticateButton.enabled = YES;
        self.authenticateButton.alpha = 1.0;
        self.listNotebooksButton.enabled = NO;
        self.listNotebooksButton.alpha = 0.5;
        self.logoutButton.enabled = NO;
        self.logoutButton.alpha = 0.5;
        self.userLabel.text = @"(not authenticated)";
    }
}

- (IBAction)logout:(id)sender {
    [[EvernoteSession sharedSession] logout];
    [self updateButtonsForAuthentication];
}

- (void)dealloc {
    [listNotebooksButton release];
    [userLabel release];
    [authenticateButton release];
    [logoutButton release];
    [super dealloc];
}
@end
