* Add more testing for correct developer setup
* Cleanup the repository
* License clarifications

= 1.1.1 / 2013-03-26

* Adding ability to monitor download/upload progress
* Handle invalid tokens
* Bug fixes

= 1.1.0 / 2013-03-01

* ENML to HTML converter
* Save a new note using Evernote for iOS app
* View a note using Evernote for iOS app
* Utility function to check if a business notebook is writable
* Demonstrate how to fetch large number of notes
* Sample code for all of the above 

= 1.0.1 / 2013-01-10

* Switch to the Evernote app only if the right URL schemes are setup

= 1.0.0 / 2013-01-07

* Supports bootstrapping by default, make sure you activate your consumer key for the China service
* ARC
* Authentication improvements, including the ability to login using the Evernote iOS app (this will be enabled automatically once the next update for the iOS app comes out)
* Apple style documentation
* Deployment target has been changed to 5.0. There are ways to compile for 4.0. If needed, please open an issue in GitHub

= 0.2.3 / 2012-12-07

* Added support for Evernote Business
	* Added [UserStore.authenticateToBusiness](http://dev.evernote.com/documentation/reference/UserStore.html#Fn_UserStore_authenticateToBusiness)
	* Added BusinessNotebook and contact to [Notebook](http://dev.evernote.com/documentation/reference/Types.html#Struct_Notebook)
	* Added businessId, businessName and businessRole to [User.accounting](http://dev.evernote.com/documentation/reference/Types.html#Struct_Accounting)
* Added NoteFilter to [RelatedQuery](http://dev.evernote.com/documentation/reference/NoteStore.html#Struct_RelatedQuery) to allow relatedness searches to be filtered
* Changed the way that sharing permissions are represented on a [SharedNotebook](http://dev.evernote.com/documentation/reference/Types.html#Struct_SharedNotebook)
	* Deprecated notebookModifiable and requireLogin
	* Added privilege and allowPreview
* Added NotebookRestrictions to [Notebook](http://dev.evernote.com/documentation/reference/Types.html#Struct_Notebook) to allow clients to more easily determined the operations that they can perform in a given shared notebook.
* Moved [PremiumInfo](http://dev.evernote.com/documentation/reference/Types.html#Struct_PremiumInfo) and [SponsoredGroupRole](http://dev.evernote.com/documentation/reference/Types.html#Enum_SponsoredGroupRole) from the userstore package to the types package.
* Removed all advertising functions and structures
* Removed the previously deprecated NoteStore.getAccountSize function
* Added extra utility functions to make it easier to use Business api's and access shared notes.
* Added utility functions and sample code to create a photo note.
* Updated sample app for Business and shared notes.

= 0.2.2 / 2012-11-20

* Added bootstrapping to the SDK. The SDK now supports the Yinxiang Biji service.
* Added activity indicator when the web view is loading.

= 0.2.1 / 2012-09-05

* Remove authentication cookies from the embedded UIWebView prior to authenticating
  to allow users to log in as a different user after declining to authorize access.

= 0.2 / 2012-08-24

* Update to Evernote API version 1.22, which adds NoteStore.findRelated()

= 0.1.6 / 2012-07-30

* Drop XCode project deployment target to iOS 4.0

= 0.1.5 / 2012-07-16

* Remove unused server-side Thrift code.

= 0.1.4 / 2012-07-11

* Remove unused Thrift transport files that caused compilation warnings.

= 0.1.3 / 2012-07-07

* Delete cookies from the Evernote service host when logging out.
* Set webView.delegate to nil upon dealloc.
* Make unit tests pass.
* Fix 2 leaks: autorelease UIBarButtonItem and UIWebView.

= 0.1.2 / 2012-06-13

* Update EvernoteSession to use an embedded UIViewController and UIWebView for OAuth authorization.


= 0.1.1 / 2012-05-03

* Improve NSURLConnection handling and error detection to EvernoteSession. 
Includes trapping non-200 HTTP response codes, as might be returned by a failed initial OAuth temp token request.

* Add UnitTests target, EvernoteSessionTests, and OCMock.

* Fix mem leak in ENCredentials.


= 0.1.0 / 2012-04-25

* Initial release.
