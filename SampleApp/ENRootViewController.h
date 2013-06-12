//
//  ENRootViewController.h
//  OAuthTest
//
//  Created by Mustafa Furniturewala
//

#import <UIKit/UIKit.h>

@interface ENRootViewController : UIViewController

- (IBAction)authenticate:(id)sender;
- (IBAction)evernoteAPI:(id)sender;
- (IBAction)logout:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnEvernoteAPI;
@property (strong, nonatomic) IBOutlet UILabel *businessLabel;
@property (strong, nonatomic) IBOutlet UIButton *authenticateButton;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;

@end
