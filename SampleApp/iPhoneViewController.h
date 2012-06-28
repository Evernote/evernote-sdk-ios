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
- (IBAction)logout:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *userLabel;
@property (retain, nonatomic) IBOutlet UIButton *listNotebooksButton;
@property (retain, nonatomic) IBOutlet UIButton *authenticateButton;
@property (retain, nonatomic) IBOutlet UIButton *logoutButton;

@end
