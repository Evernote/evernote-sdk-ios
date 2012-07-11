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