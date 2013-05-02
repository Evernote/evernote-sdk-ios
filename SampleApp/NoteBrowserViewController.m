//
//  NoteBrowserViewController.m
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 2/6/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "NoteBrowserViewController.h"
#import "EvernoteSDK.h"
#import "ENMLUtility.h"

@interface NoteBrowserViewController ()

@property (nonatomic,assign) NSInteger currentNote;
@property (nonatomic,strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic,strong) NSArray* noteList;

@end

@implementation NoteBrowserViewController

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
    [self.btnPrev setEnabled:NO];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect viewRect = self.webView.frame;
    [self.activityIndicator setFrame:CGRectMake(viewRect.size.width/2, viewRect.size.height/2, 20, 20)];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.webView addSubview:self.activityIndicator];
    [self loadMoreNotes];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setBtnPrev:nil];
    [super viewDidUnload];
}

- (IBAction)nextNote:(id)sender {
    if(self.currentNote%10==0) {
        self.currentNote++;
        [self loadMoreNotes];
    }
    else {
        self.currentNote++;
        [self loadCurrentNote];
    }
    if(self.currentNote > 0) {
        [self.btnPrev setEnabled:YES];
    }
}

- (IBAction)previousNote:(id)sender {
    self.currentNote--;
    [self loadCurrentNote];
    if(self.currentNote==0) {
        [self.btnPrev setEnabled:NO];
    }
}

- (void)loadMoreNotes {
    [[self activityIndicator] startAnimating];
    EDAMNoteFilter* filter = [[EDAMNoteFilter alloc] initWithOrder:0 ascending:NO words:nil notebookGuid:nil tagGuids:nil timeZone:nil inactive:NO emphasized:nil];
    EDAMNotesMetadataResultSpec *resultSpec = [[EDAMNotesMetadataResultSpec alloc] initWithIncludeTitle:NO includeContentLength:NO includeCreated:NO includeUpdated:NO includeDeleted:NO includeUpdateSequenceNum:NO includeNotebookGuid:NO includeTagGuids:NO includeAttributes:NO includeLargestResourceMime:NO includeLargestResourceSize:NO];
    [[EvernoteNoteStore noteStore] findNotesMetadataWithFilter:filter offset:self.currentNote maxNotes:10 resultSpec:resultSpec success:^(EDAMNotesMetadataList *metadata) {
        if(metadata.notes.count > 0) {
            self.noteList = metadata.notes;
            [self loadCurrentNote];
        }
        else {
            [self.webView loadHTMLString:@"No note found" baseURL:nil];
            [[self activityIndicator] stopAnimating];
        }
    } failure:^(NSError *error) {
        NSLog(@"Failed to find notes : %@",error);
        [[self activityIndicator] stopAnimating];
    }];
}

- (void) loadCurrentNote {
    [[self activityIndicator] startAnimating];
    if([self.noteList count] > self.currentNote%10) {
        EDAMNoteMetadata* foundNote = self.noteList[self.currentNote%10];
        [[EvernoteNoteStore noteStore] getNoteWithGuid:foundNote.guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
            ENMLUtility *utltility = [[ENMLUtility alloc] init];
            [utltility convertENMLToHTML:note.content withResources:note.resources completionBlock:^(NSString *html, NSError *error) {
                if(error == nil) {
                    [self.webView loadHTMLString:html baseURL:nil];
                    [[self activityIndicator] stopAnimating];
                }
            }];
        } failure:^(NSError *error) {
            NSLog(@"Failed to get note : %@",error);
            [[self activityIndicator] stopAnimating];
        }];
    }
}
@end
