//
//  AppDelegate.m
//  OAuthTest
//
//  Created by Matthew McGlincy on 3/17/12.
//
//  A simple sample application that demonstrates authenticating to Evernote
//  via OAuth and using the resulting authentication token to make a simple
//  Evernote API call.
//
//  To get started, fill in your consumer key and secret below.
//

#import "AppDelegate.h"
#import "EvernoteSDK.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // Initial development is done on the sandbox service
    // Change this to BootstrapServerBaseURLStringUS to use the production Evernote service
    // Change this to BootstrapServerBaseURLStringCN to use the Yinxiang Biji production service
    // BootstrapServerBaseURLStringSandbox does not support the  Yinxiang Biji service
    NSString *EVERNOTE_HOST = BootstrapServerBaseURLStringSandbox;

#warning Add Consumer Key and Consumer Secret, but also modify Info.plist according to documentation!
#warning Remove these warnings once done with it.

    // Fill in the consumer key and secret with the values that you received from Evernote
    // To get an API key, visit http://dev.evernote.com/documentation/cloud/
    NSString *CONSUMER_KEY = @"your key";
    NSString *CONSUMER_SECRET = @"your secret";
    
    // set up Evernote session singleton
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST 
                              consumerKey:CONSUMER_KEY 
                           consumerSecret:CONSUMER_SECRET];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[EvernoteSession sharedSession] handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL canHandle = NO;
    if ([[NSString stringWithFormat:@"en-%@", [[EvernoteSession sharedSession] consumerKey]] isEqualToString:[url scheme]] == YES) {
        canHandle = [[EvernoteSession sharedSession] canHandleOpenURL:url];
    }
    return canHandle;
}

- (BOOL) canHandleSwitchProfileURL:(NSURL *)url {
    NSString *requestURL = [url path];
    NSArray *components = [requestURL componentsSeparatedByString:@"/"];
    if ([components count] < 2) {
        NSLog(@"URL:%@ has invalid component count: %i", url, [components count]);
        return NO;
    }
    [[EvernoteSession sharedSession] updateCurrentBootstrapProfileWithName:components[1]];
    return YES;
}

@end
