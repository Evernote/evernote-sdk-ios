Evernote SDK for iOS version 1.1.1
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
- Build the evernote-sdk-ios as a static library and include the .h's and .a. (Make sure to add the `-ObjC` flag to your "Other Linker flags" if you choose this option). 
More info [here](http://developer.apple.com/library/ios/#technotes/iOSStaticLibraries/Articles/configuration.html#/apple_ref/doc/uid/TP40012554-CH3-SW2). 
- Use [cocoapods](http://cocoapods.org), a nice Objective-C dependency manager. Our pod name is "Evernote-SDK-iOS".

### Link with frameworks

evernote-sdk-ios depends on some frameworks, so you'll need to add them to any target's "Link Binary With Libraries" Build Phase.
Add the following frameworks in the "Link Binary With Libraries" phase

- Security.framework
- StoreKit.framework

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

The SDK now supports the Yinxiang Biji service by default. 

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
                                    if([EvernoteSession isTokenExpiredWithError:error]) {
                                        // trigger auth again
                                        // auth code is shown in the Authenticate section
                                    }
                                    NSLog(@"error %@", error);                                            
                                }];
                                
Full information on the Evernote NoteStore and UserStore API is available on the [Evernote Developers portal page](http://dev.evernote.com/documentation/cloud/).

### Prompting the user to install the Evernote for iOS app

If you need to check if the Evernote for iOS app is installed, you can use the following :

    [[EvernoteSession sharedSession] isEvernoteInstalled]

If you need to prompt the user to install the Evernote for iOS app, you can use the following :

    [[EvernoteSession sharedSession] installEvernoteAppUsingViewController:self]

The preferred way for using any of the Evernote for iOS related functions is :

    if([[EvernoteSession sharedSession] isEvernoteInstalled]) {
    // Invoke Evernote for iOS related function
    }
    else {
    // Prompt user to install the app
    [[EvernoteSession sharedSession] installEvernoteAppUsingViewController:self];
    }


### Use the Evernote for iOS App to create/view Notes

For this to work, the latest Evernote for iOS app needs to be installed. You can send text/html or text/plain types of content. You can also send attachments.

To make a new note:

    EDAMNote *note = <create a new note here>
    [[EvernoteSession sharedSession] setDelegate:self];
    [[EvernoteNoteStore noteStore] saveNewNoteToEvernoteApp:note withType:@"text/html"];

To view a note:

    EDAMNote *noteToBeViewed : <Get the note that you want to view>
    [[EvernoteNoteStore noteStore] viewNoteInEvernote:noteToBeViewed];

You can also see sample for this in the sample app.


### Viewing notes

You can use this to view notes within your app. You will need to include `ENMLUtitlity.h`

Here is an example. The example requires you to setup a web view or any other html renderer. 

    [[EvernoteNoteStore noteStore] getNoteWithGuid:<guid of note to be displayed> withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
                ENMLUtility *utltility = [[ENMLUtility alloc] init];
                [utltility convertENMLToHTML:note.content withResources:note.resources completionBlock:^(NSString *html, NSError *error) {
                    if(error == nil) {
                        [self.webView loadHTMLString:html baseURL:nil];
                    }
                }];
            } failure:^(NSError *error) {
                NSLog(@"Failed to get note : %@",error);
            }];
Check the Note browser in the sample app for some sample code.

### Handling expired Authentication tokens

You should check for expired auth tokens and trigger authentication again if the authentication token is expired or revoked by the user.

You can check for expired using `if(EvernoteSession isTokenExpiredWithError:error])` in the error block. 

FAQ
---

### Does the Evernote SDK support ARC?

Yes. To use the SDK in a non-ARC project, please use the -fobjc-arc compiler flag on all the files in the Evernote SDK.

### What if I want to do my own Evernote Thrift coding?

`EvernoteNoteStore` and `EvernoteUserStore` are an abstraction layer on top of Thrift, and try to keep some of that nastiness out of your hair.
You can still get access to the underlying Thrift client objects, though: check out EvernoteSession's userStore and noteStore properties.

## License

The Evernote SDK is licensed under a BSD style license:

    Copyright (c) 2007-2012 by Evernote Corporation, All rights reserved.
 
    Use of the source code and binary libraries included in this package
    is permitted under the following terms:
 
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
 
    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
 
    THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
    IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
    IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
    NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
    THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Other included softwares are licensed under their respective licenses.
