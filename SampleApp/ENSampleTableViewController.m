//
//  ENSampleTableViewController.m
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 5/15/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "ENSampleTableViewController.h"
#import "ENMLUtility.h"
#import "NSData+EvernoteSDK.h"
#import "ConsoleViewController.h"
#import "NoteBrowserViewController.h"
#import "NotebookTableViewController.h"
#import "NSDate+EDAMAdditions.h"

@interface ENSampleTableViewController ()

@property(nonatomic,copy) NSString* consoleText;
@property(nonatomic,copy) NSString* selectedNotebookGUID;
@property(nonatomic,strong) UIActivityIndicatorView* activityIndicatorView;
@property(nonatomic,strong) NSArray* notebooks;

@end

@implementation ENSampleTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicatorView setHidesWhenStopped:YES];
    [self.activityIndicatorView setCenter:CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height - 20)/2)];
    [[self tableView] addSubview:self.activityIndicatorView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return ENLastRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SampleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    switch (indexPath.row) {
        case ENSDKListNotebooks:
            [[cell textLabel] setText:@"List Notebooks"];
            break;
        case ENListSharedNotes :
            [[cell textLabel] setText:@"List Shared notes"];
            break;
        case ENCreatePhotoNote:
            [[cell textLabel] setText:@"Create photo note"];
            break;
        case ENCreateReminderNote:
            [[cell textLabel] setText:@"Create a note with a reminder"];
            break;
        case ENShowBusinessAPI:
            [[cell textLabel] setText:@"Business API's"];
            if(self.isBusiness == NO) {
                cell.userInteractionEnabled = NO;
                cell.textLabel.enabled = NO;
                cell.detailTextLabel.enabled = NO;
            }
            break;
        case ENSaveNewNoteToEvernote:
            [[cell textLabel] setText:@"Reminder note using Evernote"];
            break;
        case ENInstallEvernoteForiOS:
            [[cell textLabel] setText:@"Install Evernote for iOS"];
            break;
        case ENViewNoteInEvernote:
            [[cell textLabel] setText:@"View note in Evernote"];
            break;
        case ENNoteBrowser:
            [[cell textLabel] setText:@"Note browser"];
            break;
        case ENNotebookChooser:
            [[cell textLabel] setText:@"Notebook chooser"];
            break;
        default:
            break;
    }
    [[cell textLabel] setNumberOfLines:0];
    [[cell textLabel] sizeToFit];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case ENSDKListNotebooks:
            [self listNotes];
            break;
        case ENListSharedNotes :
            [self listSharedNotes];
            break;
        case ENCreatePhotoNote:
            [self createPhotoNote];
            break;
        case ENCreateReminderNote:
            [self createReminderNote];
            break;
        case ENShowBusinessAPI:
            [self performSegueWithIdentifier:@"ShowBusinessAPI" sender:self];
            break;
        case ENSaveNewNoteToEvernote:
            [self saveNewNote];
            break;
        case ENInstallEvernoteForiOS:
            [self installEvernote];
            break;
        case ENViewNoteInEvernote:
            [self viewNote];
            break;
        case ENNoteBrowser:
            [self performSegueWithIdentifier:@"showNoteBrowser" sender:self];
            break;
        case ENNotebookChooser:
            [self invlokeNotebookChooser];
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Sample app functions

- (IBAction)listNotes {
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [self.activityIndicatorView startAnimating];
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
        self.consoleText = [NSString stringWithFormat:@"notebooks: %@", notebooks];
        [self.activityIndicatorView stopAnimating];
        self.notebooks = notebooks;
        [self performSegueWithIdentifier:@"ShowNotebookTableView" sender:nil];
    } failure:^(NSError *error) {
        NSLog(@"error %@", error);
    }];
}

- (IBAction)listSharedNotes {
    // Get the users note store
    EvernoteNoteStore *defaultNoteStore = [EvernoteNoteStore noteStore];
    [self.activityIndicatorView startAnimating];
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
                self.consoleText = [NSString stringWithFormat:@"Shared notes : %@",list];
                [self.activityIndicatorView stopAnimating];
                [self logToConsole];
            } failure:^(NSError *error) {
                NSLog(@"Error : %@",error);
                [self.activityIndicatorView stopAnimating];
            }];
        }
        else {
            NSLog(@"No linked notebooks.");
            [self.activityIndicatorView stopAnimating];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"Error listing linked notes: %@",error);
        [self.activityIndicatorView stopAnimating];
    }];
}

- (IBAction)createPhotoNote {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"evernote_logo_4c-sm" ofType:@"png"];
    NSData *myFileData = [NSData dataWithContentsOfFile:filePath];
    NSData *dataHash = [myFileData enmd5];
    EDAMData *edamData = [[EDAMData alloc] initWithBodyHash:dataHash size:myFileData.length body:myFileData];
    EDAMResource* resource = [[EDAMResource alloc] initWithGuid:nil noteGuid:nil data:edamData mime:@"image/png" width:0 height:0 duration:0 active:0 recognition:0 attributes:nil updateSequenceNum:0 alternateData:nil];
    ENMLWriter* myWriter = [[ENMLWriter alloc] init];
    [myWriter startDocument];
    [myWriter startElement:@"span"];
    [myWriter startElement:@"br"];
    [myWriter endElement];
    [myWriter writeResource:resource];
    [myWriter endElement];
    [myWriter endDocument];
    NSString *noteContent = myWriter.contents;
    NSMutableArray* resources = [NSMutableArray arrayWithArray:@[resource]];
    EDAMNote *newNote = [[EDAMNote alloc] init];
    [newNote setTitle:@"Test Evernote SDK"];
    [newNote setContent:noteContent];
    [newNote setContentLength:noteContent.length];
    [newNote setResources:resources];
    [[EvernoteNoteStore noteStore] setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Total bytes written : %lld , Total bytes expected to be written : %lld",totalBytesWritten,totalBytesExpectedToWrite);
    }];
    NSLog(@"Contents : %@",myWriter.contents);
    [self.activityIndicatorView startAnimating];
    [[EvernoteNoteStore noteStore] createNote:newNote success:^(EDAMNote *note) {
        [self.activityIndicatorView stopAnimating];
        NSLog(@"Note created successfully.");
    } failure:^(NSError *error) {
        NSLog(@"Error creating note : %@",error);
        [self.activityIndicatorView stopAnimating];
    }];
}

- (IBAction)createReminderNote {
    ENMLWriter* myWriter = [[ENMLWriter alloc] init];
    [myWriter startDocument];
    [myWriter writeRawString:@"Evernote remind me in a minute"];
    [myWriter endDocument];
    NSString *noteContent = myWriter.contents;
    // Include NSDate+EDAMAdditions.h
    NSDate* now = [NSDate date];
    // After a minute
    NSDate* then = [now dateByAddingTimeInterval:3600];
    
    // Set the reminder
    EDAMNoteAttributes* noteAttributes = [[EDAMNoteAttributes alloc] initWithSubjectDate:0 latitude:0 longitude:0 altitude:0 author:nil source:nil sourceURL:nil sourceApplication:nil shareDate:0 reminderOrder:[now enedamTimestamp] reminderDoneTime:0 reminderTime:[then enedamTimestamp] placeName:nil contentClass:nil applicationData:nil lastEditedBy:nil classifications:nil creatorId:0 lastEditorId:0];
    
    // Create note object
    EDAMNote *ourNote = [[EDAMNote alloc] initWithGuid:nil title:@"Testing Reminders" content:noteContent contentHash:nil contentLength:noteContent.length created:0 updated:0 deleted:0 active:YES updateSequenceNum:0 notebookGuid:nil tagGuids:nil resources:nil attributes:noteAttributes tagNames:nil];
    
    // Attempt to create note in Evernote account with Reminder
    [[EvernoteNoteStore noteStore] createNote:ourNote success:^(EDAMNote *note) {
        // Log the created note object
        NSLog(@"Note created : %@",note);
    } failure:^(NSError *error) {
        // Something was wrong with the note data
        // See EDAMErrorCode enumeration for error code explanation
        // http://dev.evernote.com/documentation/reference/Errors.html#Enum_EDAMErrorCode
        NSLog(@"Error : %@",error);
    }];
}

- (IBAction)saveNewNote {
    if([[EvernoteSession sharedSession] isEvernoteInstalled]) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"evernote_logo_4c-sm" ofType:@"png"];
        NSData *myFileData = [NSData dataWithContentsOfFile:filePath];
        NSData *dataHash = [myFileData enmd5];
        EDAMData *edamData = [[EDAMData alloc] initWithBodyHash:dataHash size:myFileData.length body:myFileData];
        EDAMResource* resource = [[EDAMResource alloc] initWithGuid:nil noteGuid:nil data:edamData mime:@"image/png" width:0 height:0 duration:0 active:0 recognition:0 attributes:nil updateSequenceNum:0 alternateData:nil];
        NSMutableArray *resources = [NSMutableArray arrayWithObjects:resource,resource, nil];
        NSMutableArray *tagNames = [NSMutableArray arrayWithObjects:@"evernote",@"sdk", nil];
        // Include NSDate+EDAMAdditions.h
        NSDate* now = [NSDate date];
        // After 60 minutes
        NSDate* then = [now dateByAddingTimeInterval:3600];
        
        // Set the reminder
        EDAMNoteAttributes* noteAttributes = [[EDAMNoteAttributes alloc] initWithSubjectDate:0 latitude:0 longitude:0 altitude:0 author:nil source:nil sourceURL:nil sourceApplication:nil shareDate:0 reminderOrder:[now enedamTimestamp] reminderDoneTime:0 reminderTime:[then enedamTimestamp] placeName:nil contentClass:nil applicationData:nil lastEditedBy:nil classifications:nil creatorId:0 lastEditorId:0];
        EDAMNote* note = [[EDAMNote alloc] initWithGuid:nil title:@"Test TODO note" content:@"<strong>Here is my new HTML note</strong>" contentHash:nil contentLength:0 created:0 updated:0 deleted:0 active:YES updateSequenceNum:0 notebookGuid:nil tagGuids:nil resources:resources attributes:noteAttributes tagNames:tagNames];
        [[EvernoteSession sharedSession] setDelegate:self];
        [[EvernoteNoteStore noteStore] saveNewNoteToEvernoteApp:note withType:@"text/html"];
    }
    else {
        [self installEvernote];
    }
    
}

- (IBAction)viewNote {
    if([[EvernoteSession sharedSession] isEvernoteInstalled]) {
        NSLog(@"Viewing note..");
        EDAMNoteFilter* filter = [[EDAMNoteFilter alloc] initWithOrder:0 ascending:NO words:nil notebookGuid:nil tagGuids:nil timeZone:nil inactive:NO emphasized:nil];
        [[EvernoteNoteStore noteStore] findNotesWithFilter:filter offset:0 maxNotes:100 success:^(EDAMNoteList *list) {
            NSLog(@"Notes : %d",list.notes.count);
            [[EvernoteNoteStore noteStore] viewNoteInEvernote:list.notes[0]];
        } failure:^(NSError *error) {
            NSLog(@"Error : %@",error);
        }];
    }
    else {
        [self installEvernote];
    }
}

- (IBAction)installEvernote {
    [[EvernoteSession sharedSession] installEvernoteAppUsingViewController:self];
}

- (IBAction)invlokeNotebookChooser {
    NotebookChooserViewController *nbc = [[NotebookChooserViewController alloc] init];
    [nbc setDelegate:self];
    [nbc setSelectedNotebookWithGUID:self.selectedNotebookGUID];
    UINavigationController* notbookChooserNav = [[UINavigationController alloc] initWithRootViewController:nbc];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nbc.modalPresentationStyle = UIModalPresentationFormSheet;
        notbookChooserNav.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [[self navigationController] presentViewController:notbookChooserNav animated:YES completion:^{
        [nbc.navigationItem setTitle:@"Select a notebook"];
    }];
}

- (void)logToConsole {
    NSLog(@"%@",self.consoleText);
    [self performSegueWithIdentifier:@"ShowConsole" sender:self];
}

#pragma mark -
#pragma Delegates

- (void)noteSavedWithNoteGuid:(NSString *)noteGuid {
    NSLog(@"Note saved successfully : %@",noteGuid);
}

- (void)evernoteAppNotInstalled {
    NSLog(@"app not installed");
}

-(void) evernoteAppInstalled {
    NSLog(@"App was installed");
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark -
#pragma Notebook chooser delegate

- (void)notebookChooserController:(NotebookChooserViewController *)controller didSelectNotebook:(EDAMNotebook *)notebook {
    self.selectedNotebookGUID = notebook.guid;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notebook chosen" message:notebook.name delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ShowConsole"]) {
        ConsoleViewController *consoleVC = segue.destinationViewController;
        consoleVC.consoleText = self.consoleText;
    }
    else if([segue.identifier isEqualToString:@"ShowNotebookTableView"]) {
        NotebookTableViewController* notebookTableView = segue.destinationViewController;
        [notebookTableView setNotebooks:self.notebooks];
        self.notebooks = nil;
    }
}

@end
