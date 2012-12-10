//
//  iPhoneViewController.h
//  OAuthTest
//
//  Created by Matthew McGlincy on 3/17/12.
//

#import <UIKit/UIKit.h>

@interface iPhoneViewController : UIViewController
- (IBAction)authenticate:(id)sender;
- (IBAction)listNotes:(id)sender;
- (IBAction)listBusinessNotebooks:(id)sender;
- (IBAction)createBusinessNotebook:(id)sender;
- (IBAction)listSharedNotes:(id)sender;
- (IBAction)createPhotoNote:(id)sender;
- (IBAction)logout:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *userLabel;
@property (retain, nonatomic) IBOutlet UILabel *businessLabel;
@property (retain, nonatomic) IBOutlet UIButton *listNotebooksButton;
@property (retain, nonatomic) IBOutlet UIButton *createBusinessNotebookButton;
@property (retain, nonatomic) IBOutlet UIButton *listBusinessButton;
@property (retain, nonatomic) IBOutlet UIButton *authenticateButton;
@property (retain, nonatomic) IBOutlet UIButton *createPhotoButton;
@property (retain, nonatomic) IBOutlet UIButton *sharedNotesButton;
@property (retain, nonatomic) IBOutlet UIButton *logoutButton;

@end
