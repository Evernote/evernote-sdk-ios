//
//  MoreViewController.m
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 2/4/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "MoreViewController.h"
#import "NSData+EvernoteSDK.h"


@interface MoreViewController ()

@end

@implementation MoreViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveNewNote:(id)sender {
    if([[EvernoteSession sharedSession] isEvernoteInstalled]) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"evernote_logo_4c-sm" ofType:@"png"];
        NSData *myFileData = [NSData dataWithContentsOfFile:filePath];
        NSData *dataHash = [myFileData md5];
        EDAMData *edamData = [[EDAMData alloc] initWithBodyHash:dataHash size:myFileData.length body:myFileData];
        EDAMResource* resource = [[EDAMResource alloc] initWithGuid:nil noteGuid:nil data:edamData mime:@"image/png" width:0 height:0 duration:0 active:0 recognition:0 attributes:nil updateSequenceNum:0 alternateData:nil];
        NSMutableArray *resources = [NSMutableArray arrayWithObjects:resource,resource, nil];
        NSMutableArray *tagNames = [NSMutableArray arrayWithObjects:@"evernote",@"sdk", nil];
        EDAMNote* note = [[EDAMNote alloc] initWithGuid:nil title:@"Test Note - Evernote SDK" content:@"<strong>Here is my new HTML note</strong>" contentHash:nil contentLength:0 created:0 updated:0 deleted:0 active:YES updateSequenceNum:0 notebookGuid:nil tagGuids:nil resources:resources attributes:nil tagNames:tagNames];
        [[EvernoteSession sharedSession] setDelegate:self];
        [[EvernoteNoteStore noteStore] saveNewNoteToEvernoteApp:note withType:@"text/html"];
    }
    else {
        [self installEvernote:self];
    }

}

- (IBAction)viewNote:(id)sender {
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
        [self installEvernote:self];
    }
}

- (IBAction)installEvernote:(id)sender {
    [[EvernoteSession sharedSession] installEvernoteAppUsingViewController:self];
}

- (void)noteSavedWithNoteGuid:(NSString *)noteGuid {
    NSLog(@"Note saved successfully : %@",noteGuid);
}

- (void)appNotInstalled {
    NSLog(@"app not installed");
}

-(void) appInstalled {
    NSLog(@"App was installed");
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
