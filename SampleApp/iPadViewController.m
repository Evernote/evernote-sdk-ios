//
//  iPadViewController.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 6/12/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "EvernoteSDK.h"
#import "iPadViewController.h"
#import "ENMLUtility.h"
#import "NSData+EvernoteSDK.h"

@interface iPadViewController ()

@property (nonatomic, strong) NSArray *notebooks;

@end

@implementation iPadViewController

@synthesize authenticateButton = _authenticateButton;
@synthesize listNotebooksButton = _listNotebooksButton;
@synthesize tableView = _tableView;
@synthesize logoutButton = _logoutButton;
@synthesize notebooks = _notebooks;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self updateButtonsForAuthentication];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setAuthenticateButton:nil];
    [self setListNotebooksButton:nil];
    [self setLogoutButton:nil];
    [self setListBusinessButton:nil];
    [self setPhotoNoteButton:nil];
    [self setSharedNotesButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)authenticate:(id)sender 
{
    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                             message:@"Could not authenticate" 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK" 
                                                   otherButtonTitles:nil];
            [alert show];
        } else {
            NSLog(@"authenticated! noteStoreUrl:%@ webApiUrlPrefix:%@", session.noteStoreUrl, session.webApiUrlPrefix);
            [self updateButtonsForAuthentication];
        } 
    }];
}

- (IBAction)listNotebooks:(id)sender {
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
        self.notebooks = notebooks;
        [self.tableView reloadData];
    }
                                failure:^(NSError *error) {
                                    NSLog(@"error %@", error);                                            
                                }];
}

- (IBAction)listSharedNotes:(id)sender {
    // Get the users note store
    EvernoteNoteStore *defaultNoteStore = [EvernoteNoteStore noteStore];
    [defaultNoteStore listLinkedNotebooksWithSuccess:^(NSArray *linkedNotebooks) {
        if(linkedNotebooks.count >0) {
            EDAMNoteFilter* noteFilter = [[EDAMNoteFilter alloc] initWithOrder:0
                                                                      ascending:NO
                                                                          words:nil
                                                                   notebookGuid:nil
                                                                       tagGuids:nil
                                                                       timeZone:nil
                                                                       inactive:NO
                                                                     emphasized:nil];
            [defaultNoteStore listNotesForLinkedNotebook:linkedNotebooks[0]  withFilter:noteFilter success:^(EDAMNoteList *list) {
                NSLog(@"Shared notes : %@",list);
            } failure:^(NSError *error) {
                NSLog(@"Error : %@",error);
            }];
        }
        else {
            NSLog(@"No linked notebooks.");
        }
        
    } failure:^(NSError *error) {
        NSLog(@"Error listing linked notes: %@",error);
    }];
}

- (IBAction)listBusinessNotebooks:(id)sender {
    EvernoteNoteStore *noteStore = [EvernoteNoteStore businessNoteStore];
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
        self.notebooks = notebooks;
        [self.tableView reloadData];
    }
                                failure:^(NSError *error) {
                                    NSLog(@"error %@", error);
                                }];
}

- (IBAction)createPhotoNote:(id)sender {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"evernote_logo_4c-sm" ofType:@"png"];
    NSData *myFileData = [NSData dataWithContentsOfFile:filePath];
    NSData *dataHash = [myFileData enmd5];
    EDAMData *edamData = [[EDAMData alloc] initWithBodyHash:dataHash size:myFileData.length body:myFileData];
    EDAMResource* resource = [[EDAMResource alloc] initWithGuid:nil noteGuid:nil data:edamData mime:@"image/png" width:0 height:0 duration:0 active:0 recognition:0 attributes:nil updateSequenceNum:0 alternateData:nil];
    NSString *noteContent = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                             "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
                             "<en-note>"
                             "<span style=\"font-weight:bold;\">Hello photo note.</span>"
                             "<br />"
                             "<span>Evernote logo :</span>"
                             "<br />"
                             "%@"
                             "</en-note>",[ENMLUtility mediaTagWithDataHash:dataHash mime:@"image/png"]];
    NSMutableArray* resources = [NSMutableArray arrayWithArray:@[resource]];
    EDAMNote *newNote = [[EDAMNote alloc] initWithGuid:nil title:@"Test photo note" content:noteContent contentHash:nil contentLength:noteContent.length created:0 updated:0 deleted:0 active:YES updateSequenceNum:0 notebookGuid:nil tagGuids:nil resources:resources attributes:nil tagNames:nil];
    [[EvernoteNoteStore noteStore] setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Total bytes written : %lld , Total bytes expected to be written : %lld",totalBytesWritten,totalBytesExpectedToWrite);
    }];
    [[EvernoteNoteStore noteStore] createNote:newNote success:^(EDAMNote *note) {
        NSLog(@"Note created successfully.");
    } failure:^(NSError *error) {
        NSLog(@"Error creating note : %@",error);
    }];
}

- (IBAction)logout:(id)sender {
    [[EvernoteSession sharedSession] logout];
    [self updateButtonsForAuthentication];
    self.notebooks = nil;
    [self.tableView reloadData];
}

- (void)updateButtonsForAuthentication 
{    
    EvernoteSession *session = [EvernoteSession sharedSession];
    
    if (session.isAuthenticated) {
        self.authenticateButton.enabled = NO;
        self.authenticateButton.alpha = 0.5;
        self.listNotebooksButton.enabled = YES;
        self.listNotebooksButton.alpha = 1.0;
        self.listBusinessButton.enabled = YES;
        self.listBusinessButton.alpha = 1.0;
        self.photoNoteButton.enabled = YES;
        self.photoNoteButton.alpha = 1.0;
        self.sharedNotesButton.enabled = YES;
        self.sharedNotesButton.alpha = 1.0;
        self.logoutButton.enabled = YES;
        self.logoutButton.alpha = 1.0; 
    } else {
        self.authenticateButton.enabled = YES;
        self.authenticateButton.alpha = 1.0;
        self.listNotebooksButton.enabled = NO;
        self.listNotebooksButton.alpha = 0.5;
        self.photoNoteButton.enabled = NO;
        self.photoNoteButton.alpha = 0.5;
        self.sharedNotesButton.enabled = NO;
        self.sharedNotesButton.alpha = 0.5;
        self.listBusinessButton.enabled = NO;
        self.listBusinessButton.alpha = 0.5;
        self.logoutButton.enabled = NO;
        self.logoutButton.alpha = 0.5;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notebooks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EDAMNotebook *notebook = [self.notebooks objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotebookTableCell"];
    cell.textLabel.text = notebook.name;
    cell.detailTextLabel.text = @"";
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
