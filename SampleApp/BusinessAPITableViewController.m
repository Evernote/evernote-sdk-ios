//
//  BusinessAPITableViewController.m
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 5/16/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "BusinessAPITableViewController.h"
#import "EvernoteSDK.h"
#import "NSData+EvernoteSDK.h"
#import "ENMLUtility.h"
#import "ConsoleViewController.h"

@interface BusinessAPITableViewController ()

@property (nonatomic,copy) NSString* consoleText;

@end

@implementation BusinessAPITableViewController

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
    return ENBusinessLastRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SampleBusinessCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    switch (indexPath.row) {
        case ENSDKListBusinessNotebooks:
            [[cell textLabel] setText:@"List Business Notebooks"];
            break;
        case ENCreateBusinessNotebook:
            [[cell textLabel] setText:@"Create Business Notebook"];
            break;
        case ENCreateBusinessNote:
            [[cell textLabel] setText:@"Create business note"];
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
        case ENSDKListBusinessNotebooks:
            [self listBusinessNotebooks];
            break;
        case ENCreateBusinessNotebook:
            [self createBusinessNotebook];
            break;
         case ENCreateBusinessNote:
            [self createBusinessNote];
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Internal functions

- (IBAction)listBusinessNotebooks {
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [noteStore listBusinessNotebooksWithSuccess:^(NSArray *linkedNotebooks) {
        self.consoleText = [NSString stringWithFormat:@"Business notebooks: %@", linkedNotebooks];
        [self logToConsole];
    } failure:^(NSError *error) {
        NSLog(@"Error : %@",error);
    }];
}

- (IBAction)createBusinessNotebook {
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    EDAMNotebook* notebook = [[EDAMNotebook alloc] initWithGuid:nil name:@"test" updateSequenceNum:0 defaultNotebook:NO serviceCreated:0 serviceUpdated:0 publishing:nil published:NO stack:nil sharedNotebookIds:nil sharedNotebooks:nil businessNotebook:nil contact:nil restrictions:nil];
    [noteStore createBusinessNotebook:notebook success:^(EDAMLinkedNotebook *businessNotebook) {
        self.consoleText = [NSString stringWithFormat:@"Created a business notebook : %@",businessNotebook];
        [self logToConsole];
    } failure:^(NSError *error) {
        NSLog(@"Error : %@",error);
    }];
}

- (IBAction)createBusinessNote {
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [noteStore listBusinessNotebooksWithSuccess:^(NSArray *linkedNotebooks) {
        if(linkedNotebooks.count>0) {
            EDAMLinkedNotebook* businessNotebook = linkedNotebooks[0];
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
            [noteStore createNote:newNote inBusinessNotebook:businessNotebook success:^(EDAMNote *createdNote) {
                NSLog(@"Created note : %@",createdNote.title);
            } failure:^(NSError *error) {
                NSLog(@"Failed to created a note : %@",error);
            }];
        }
        else {
            NSLog(@"No business notebooks found");
        }
    } failure:^(NSError *error) {
        ;
    }];
}

- (void)logToConsole {
    NSLog(@"%@",self.consoleText);
    [self performSegueWithIdentifier:@"ShowConsole" sender:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ShowConsole"]) {
        ConsoleViewController *consoleVC = segue.destinationViewController;
        consoleVC.consoleText = self.consoleText;
    }
}

@end
