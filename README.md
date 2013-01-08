Evernote SDK for iOS version 1.0.0
=========================================

What this is
------------
A pleasant iOS-wrapper around the Evernote Cloud API (v1.22), using OAuth for authentication. 

Required reading
----------------
Please check out the [Evernote Developers portal page](http://dev.evernote.com/documentation/cloud/).
Apple style docs are [here](http://dev.evernote.com/documentation/reference/ios/).

Installing 
----------

### Register for an Evernote API key (and secret)

You can do this on the [Evernote Developers portal page](http://dev.evernote.com/documentation/cloud/).

### Include the code

You have a few options:

- Copy the evernote-sdk-ios source code into your Xcode project.
- Add the evernote-sdk-ios xcodeproj to your project/workspace.
- Build the evernote-sdk-ios as a static library and include the .h's and .a.
- Use [cocoapods](http://cocoapods.org), a nice Objective-C dependency manager. Our pod name is "Evernote-SDK-iOS".

### Link with frameworks

evernote-sdk-ios depends on Security.framework, so you'll need to add that to any target's "Link Binary With Libraries" Build Phase.

### Modify your application's main plist file

Create an array key called URL types with a single array sub-item called URL Schemes. Give this a single item with your consumer key prefixed with 'en-'

	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string></string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>en-<consumer key></string>
			</array>
		</dict>
	</array>

### Modify your AppDelegate

First you set up the shared EvernoteSession, configuring it with your consumer key and secret. 

The SDK now supports the Yinxiang Biji service. 

- To support both services, set the service to EVERNOTE_SERVICE_BOTH.
- To support Yinxiang Biji only, change 'service' to EVERNOTE_SERVICE_YINXIANG and 'EVERNOTE_HOST' to 'app.yinxiang.com'.
- To support international only, change 'service' to EVERNOTE_SERVICE_INTERNATIONAL and 'EVERNOTE_HOST' to 'www.evernote.com'.

Do something like this in your AppDelegate's `application:didFinishLaunchingWithOptions:` method.

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
		// Initial development is done on the sandbox service
		// Change this to BootstrapServerBaseURLStringUS to use the production Evernote service
		// Change this to BootstrapServerBaseURLStringCN to use the Yinxiang Biji production service
		// BootstrapServerBaseURLStringSandbox does not support the  Yinxiang Biji service
		NSString *EVERNOTE_HOST = BootstrapServerBaseURLStringSandbox;
    
		// Fill in the consumer key and secret with the values that you received from Evernote
		// To get an API key, visit http://dev.evernote.com/documentation/cloud/
		NSString *CONSUMER_KEY = @"your key";
		NSString *CONSUMER_SECRET = @"your secret";
    
		// set up Evernote session singleton
		[EvernoteSession setSharedSessionHost:EVERNOTE_HOST
					  consumerKey:CONSUMER_KEY  
				       consumerSecret:CONSUMER_SECRET];
	}

Do something like this in your AppDelegate's `application:openURL:sourceApplication:annotation:` method

	- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
		BOOL canHandle = NO;
		if ([[NSString stringWithFormat:@"en-%@", [[EvernoteSession sharedSession] consumerKey]] isEqualToString:[url scheme]] == YES) {
		canHandle = [[EvernoteSession sharedSession] canHandleOpenURL:url];
		}
		return canHandle;
	}

Do something like this in your AppDelegate's `applicationDidBecomeActive:` method
	
	- (void)applicationDidBecomeActive:(UIApplication *)application
	{
    		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    		[[EvernoteSession sharedSession] handleDidBecomeActive];
	}

Now you're good to go.

Using the Evernote SDK from your code
-------------------------------------

### Authenticate

Somewhere in your code, you'll need to authenticate the `EvernoteSession`, passing in your view controller.

A normal place to do this would be a "link to Evernote" button action.

    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            // authentication failed :(
            // show an alert, etc
            // ...
        } else {
            // authentication succeeded :)
            // do something now that we're authenticated
            // ... 
        } 
    }];

Calling authenticateWithViewController:completionHandler: will start the OAuth process. EvernoteSession will open a new modal view controller, to display Evernote's OAuth web page and handle all the back-and-forth OAuth handshaking. When the user finishes this process, Evernote's modal view controller will be dismissed.

### Use EvernoteNoteStore and EvernoteUserStore for asynchronous calls to the Evernote API

Both `EvernoteNoteStore` and `EvernoteUserStore` have a convenience constructor that uses the shared `EvernoteSession`.  
All API calls are asynchronous, occurring on a background GCD queue. You provide the success and failure callback blocks.
E.g.,

    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
                                    // success... so do something with the returned objects
                                    NSLog(@"notebooks: %@", notebooks);
                                }
                                failure:^(NSError *error) {
                                    // failure... show error notification, etc
                                    NSLog(@"error %@", error);                                            
                                }];
                                
Full information on the Evernote NoteStore and UserStore API is available on the [Evernote Developers portal page](http://dev.evernote.com/documentation/cloud/).

FAQ
---

### Does the Evernote SDK support ARC?

Yes. To use the SDK in a non-ARC project, please use the -fobjc-arc compiler flag on all the files in the Evernote SDK.

### What if I want to do my own Evernote Thrift coding?

`EvernoteNoteStore` and `EvernoteUserStore` are an abstraction layer on top of Thrift, and try to keep some of that nastiness out of your hair.
You can still get access to the underlying Thrift client objects, though: check out EvernoteSession's userStore and noteStore properties.


