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
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UILabel *businessLabel;
@property (strong, nonatomic) IBOutlet UIButton *listNotebooksButton;
@property (strong, nonatomic) IBOutlet UIButton *createBusinessNotebookButton;
@property (strong, nonatomic) IBOutlet UIButton *listBusinessButton;
@property (strong, nonatomic) IBOutlet UIButton *authenticateButton;
@property (strong, nonatomic) IBOutlet UIButton *createPhotoButton;
@property (strong, nonatomic) IBOutlet UIButton *sharedNotesButton;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@end
