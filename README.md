BMLTiOSLib
==========

**NOTE:** A technical discussion of this library [is available on this Web site](https://bmlt.magshare.net/specific-topics/bmltioslib/).

This project is an [iOS Shared Framework](https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPFrameworks/Tasks/CreatingFrameworks.html), designed to ease integration of a BMLT Root Server into an iOS client (it may also work for MacOS, but we're not there yet).

The BMLTiOSLib is a Swift-only framework. It won't support Objective-C.

The [BMLTiOSLib](https://bitbucket.org/bmlt/bmltioslib/src/master/BMLTiOSLib) directory has the relevant exported classes. The [BMLTiOSLib Tester](https://bitbucket.org/bmlt/bmltioslib/src/master/BMLTiOSLib%20Tester) directory implements a fairly complex program that we've written to exercise the library.

Because [Apple now requires that iOS apps only interact with SSL servers](https://techcrunch.com/2016/06/14/apple-will-require-https-connections-for-ios-apps-by-the-end-of-2016/), it's a bit complex to test. We don't want to compromise security by allowing connections to self-signed certs, so we can't test with localhost.

**PROTIP:** We use [Charles Proxy](https://www.charlesproxy.com) to examine the interaction between the simulator and the server. [It is possible to set up Charles as a "man in the middle" to decrypt SSL interactions.](https://www.charlesproxy.com/documentation/proxying/ssl-proxying/)

For easy testing, you can connect to [the BMLT Test Server](https://tkddevel.com/bmltwork/bmlt/main_server/), which uses SSL. This database may change a lot, as it is our main test bed, but it will always have the ability to be accessed via SSL.

[The BMLTiOSLib Tester app](https://bitbucket.org/bmlt/bmltioslib/src/master/BMLTiOSLib%20Tester) is not pretty. It's not meant to be. It's a space shuttle cockpit program that's designed to let us press all the various buttons. It also has a couple of issues with operation that, quite frankly, aren't a priority to fix, as [we now have several "real world" implementations](https://bmlt.magshare.net/satellites/bmlt-ios-apps/) that stress the BMLTiOSLib a great deal more than this ugly little duckling.

[This is the documentation page for the BMLTiOSLib.](https://bmlt.magshare.net/bmltioslib/)

UNDER THE HOOD
--------------

The BMLTiOSLib communicates with the Root Server using [the BMLT JSON Semantic Interface](http://bmlt.magshare.net/semantic/how-to-use-the-semantic-interface/).

Administration is done using [the BMLT Administrative Semantic Interface](http://bmlt.magshare.net/semantic/semantic-administration/) (Also JSON).

The whole idea is to completely abstract the communication layer from the app development process. BMLTiOSLib provides a simple, error-checked functional interface to the BMLT.

Interaction with the BMLTiOSLib is done via Apple's [Delegation Pattern](https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/Delegation.html).

When you instantiate an instance of BMLTiOSLib, you register your app as a [```BMLTiOSLibDelegate```](https://bmlt.magshare.net/bmlt-doc/07-BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html) delegate instance, and it will receive events as they come in.

You then use the functional interface to operate the connection.

USAGE (Taken from the actual file documentation):
-------------------------------------------------

 The BMLTiOSLib class represents the public interface to the BMLTiOSLib framework.
 
 This class needs to be instantiated with a URI to a valid [Root Server](http://bmlt.magshare.net/installing-a-new-root-server/) (the same URI used to log in), and a BMLTiOSLibDelegate delegate instance.
 
 Instantiation immediately starts a communication process, and the result will be reflected in the delegate's ```bmltLibInstance(_:BMLTiOSLib,serverIsValid:Bool)``` callback.
 
 If this instance fails to connect to a valid Root Server, it should be deleted, and reinstantiated for a new connection.
 
 Once a connection is established, the HTTP session is maintained until the instance is deinstantiated.
 
 The session is required to be maintained for Semantic Administration. You cannot share a session across instances of BMLTiOSLib.
 
 **BASIC SERVER INFORMATION:**
 
 Once you have successfully connected (established a session) to the Root Server, this instance will have some fundamental information available about that server.
 
 Your delegate's ```bmltLibInstance(_:BMLTiOSLib,serverIsValid:Bool)``` method is called when the connection is successful (serverIsValid is true).
 
 This information can be accessed by calling the following instance properties:

- ```distanceUnits``` and ```distanceUnitsString``` (This is the distance unit used for the server -Km or Mi).

- ```availableMeetingValueKeys``` (This contains the Dictionary key strings that can access various meeting properties).

- ```emailMeetingContactsEnabled``` (True, if the Server is set to allow emails to be sent to meeting contacts).

- ```emailServiceBodyAdminsEnabled``` (True, if these emails will CC the Service Body Admin for that Service body, as well as the meeting contact -They may be the same email address).

- ```changeDepth``` (The number of changes saved per meeting).

- ```googleAPIKey``` (The API key for the Root Server -May not be useful for most other Servers).

- ```delegate``` (That will be the object that was passed in as delegate when the instance was created).

- ```versionAsString``` and ```versionAsInt``` (The server version)

- ```isAdminAvailable``` (True, if Semantic Administration is available).

- ```defaultLocation``` (The Root Server's default central location).

- ```serviceBodies``` (This is a "flat" Array of the Service bodies, with no hierarchy).

- ```hierarchicalServiceBodies``` (This maps out the Service bodies in the hierarchy they occupy on the Root Server, and this is just one node with children only -no parents or Service body).

- ```allPossibleFormats``` (an Array of format objects available -May not all be used by the meetings).

- ```availableServerLanguages``` (an Array of language objects).

 **MEETING SEARCHES:**
 
 The way that you do a meeting search with this class, is to acquire the instance's searchCriteria object, and use its various properties to set up your desired search.
 
 Once that is done, you call this class instance's performMeetingSearch(_:BMLTiOSLibSearchCriteria.SearchCriteriaExtent) method, indicating whether you want just meetings, just the formats used by the meetings in the search results, or both.
 
 Once the search is complete, this class will call your delegate routines:
 
- ```bmltLibInstance(_:BMLTiOSLib,meetingSearchResults:[BMLTiOSLibMeetingNode])``` is called with the results of the meeting search.

- ```bmltLibInstance(_:BMLTiOSLib,formatSearchResults:[BMLTiOSLibFormatNode],isAllUsedFormats:Bool)``` is called with the results of the format search.
 
 Either or both may be called, depending on what you requested when you called performMeetingSearch(_:BMLTiOSLibSearchCriteria.SearchCriteriaExtent).
 
 If there are no results, they will be called with empty Arrays.
 
 **MEETING CHANGES:**
 
 You can query for meeting changes, including deleted meetings (and you can restore deleted meetings if you are an authorized administrator).
 
 You do this by calling one of these methods:
 
- getAllMeetingChanges(meetingID:Int?)

- getAllMeetingChanges(serviceBodyID:Int?)

- getAllMeetingChanges(meeting:BMLTiOSLibMeetingNode?)

- getAllMeetingChanges(fromDate:Date?,toDate:Date?)

- getAllMeetingChanges(fromDate:Date?,toDate:Date?,meetingID:Int?)

- getAllMeetingChanges(fromDate:Date?,toDate:Date?,serviceBodyID:Int?)

- getAllMeetingChanges(fromDate:Date?,toDate:Date?,serviceBodyID:Int?,meetingID:Int?)

- getAllMeetingChanges(fromDate:Date?,toDate:Date?,serviceBodyID:Int?,meetingID:Int?,userID:Int?)

- getDeletedMeetingChanges()

- getDeletedMeetingChanges(serviceBodyID:Int?)

- getDeletedMeetingChanges(fromDate:Date?,toDate:Date?,serviceBodyID:Int?)

 After calling one of the above methods, your delegate is called back with the ```bmltLibInstance(_:BMLTiOSLib,changeListResults:[BMLTiOSLibChangeNode])``` method; which will have an Array of the requested change objects. You can then use these objects to revert meetings, or restore deleted meetings.

 **ROLLING BACK AND UNDELETING MEETINGS:**

 Selecting the ```saveMeetingToBeforeThisChange()``` of a change or editable meeting object will use the restore deleted or rollback function of the Semantic Admin interface (as long as you are logged in as an administrator, and have sufficient rights to edit the meeting).
 We do allow you to take the "before" record of the meeting (found in the ```json_data``` JSON response, or the ```beforeObject``` property of the change record object), and save that.
 This allows you to add new changes (as opposed to simply accepting the whole change in a rollback, you can choose to only take certain changes).
 It also gives a better change record in the meeting history. Instead of a curt "Meeting was rolled back to a previous version.", you now have a list of the exact fields that were changed.
 Remember that the "beforeObject" and "afterObject" properties are fully-qualified meeting objects, and, if editable, can be saved, which overwrites whatever is currently in the database (It's exactly like saving a changed meeting record).
 You revert a meeting by calling the ```revertMeetingToBeforeThisChange()``` method of the change record object concerned. It's quite simple.

 **NEW MEETINGS:**
 
 Creating new meetings is easy (as long as you are logged in as an administrator, and have sufficient rights to create a meeting).
 
 You create an instance of [```BMLTiOSLibEditableMeetingNode```](https://bmlt.magshare.net/bmlt-doc/07-BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html) with an ID of 0 (the default). Then, when you call saveChanges(), it will create a new meeting.
 
 When you create a new meeting, or restore a deleted meeting, your delegate is called with the ```bmltLibInstance(_:BMLTiOSLib,newMeetingAdded:BMLTiOSLibEditableMeetingNode)``` method.
 
 The newMeetingAdded parameter will contain an object that models the newly-created meeting (including the new ID, if it was a brand-new meeting).
 
 **SENDING MESSAGES TO MEETING CONTACTS:**
 
 In some Root Servers, the administrator can choose to enable the ability for users of the site to send messages to designated contacts for meetings (or the Service Body Administrator responsible for the meeting).
 
 In these cases, the message is received as an email, but the sender does not send an email. Instead, they use a method of the ```BMLTiOSLibMeetingNode``` class, called ```sendMessageToMeetingContact(fromAddress:String,messageBody:String)```. The message is sent in the background.
 
 When the message has been sent, your delegate is called with the ```bmltLibInstance(_:BMLTiOSLib,sendMessageSuccessful:Bool)``` method.
 
 **ADMINISTRATION:**
 
 In order to perform administration on the Root Server, you need to log in with the ```adminLogin(loginID:String,password:String)``` method. The login will remain valid for the lifetime of this object (and its connection session), or until the adminLogout() method is called.
 
 Results of meeting searches may return the meeting objects as instances of [```BMLTiOSLibEditableMeetingNode```](https://bmlt.magshare.net/bmlt-doc/07-BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html) instead of [BMLTiOSLibMeetingNode](https://bmlt.magshare.net/bmlt-doc/07-BMLTiOSLib/Classes/BMLTiOSLibMeetingNode.html) (as long as you are logged in as an administrator, and have sufficient rights to edit the meeting). is will depend on the edit rights that the login has for the given meeting. If you cannot edit the meeting, then the instance will be of BMLTiOSLibMeetingNode, instead of BMLTiOSLibEditableMeetingNode.
 
 If the instance is ```BMLTiOSLibEditableMeetingNode```, the instance's isEditable property will return true.
 
 If the instance is of the ```BMLTiOSLibEditableMeetingNode``` class, you can cast it to that class, and manipulate the public properties. Once the properties have been set, you can then call the ```saveChanges()``` method for that instance, and the meeting will be saved.
 
 Until the ```saveChanges()``` method is called, the meeting changes are not sent to the server.
 
 Once the meeting has been saved, your delegate will receive a call to its ```bmltLibInstance(_:BMLTiOSLib,adminMeetingChangeComplete:BMLTiOSLibChangedMeeting!)``` method with an object that will contain whatever fields of the meeting changed, with the "before" and "after" values (always Strings).
 
 You can also delete a meeting, by calling the ```delete()``` method (The deletion happens immediately).
 
 If you delete the meeting, your delegate is called with the ```bmltLibInstance(_:BMLTiOSLib,deleteMeetingSuccessful:Bool)``` method.

 If you call the ```restoreToOriginal()``` method, any changes that you made to the meeting object will be reverted to the state of the meeting on the server. Nothing will be sent to the server.
 
 You can also revert a meeting to the state it was in before a given change record for that meeting, using the ```revertMeetingToBeforeThisChange(_:BMLTiOSLibChangeNode)``` method. Nothing will be sent to the server.
 
 If the change was inappropriate for the meeting, the call will return false. If it was successful, the meeting's state will be reverted to that in the change record, but will not yet be sent to the server. You still need to call ```saveChanges()```.


**As of December, 2017:**

TO DO
-----

- Make tasks interruptable without terminating the session. Currently, the way to terminate a task is to terminate the session. This works great for search apps, but not so good for admin apps, as the session carries the login. If you terminate the session, you force the user to log back in.
- Make the library multi-tasking. Currently, the library works in a single-threaded manner. It should be able to handle multiple simultaneous tasks.

NICE TO HAVE
------------

- Test against a simple TVOS Swift app

- Test against a simple MacOS Swift app

CHANGELIST
----------
***Version 1.2.1* ** *- December 12, 2017*

- This implements a bunch of internal structural changes to satisfy [SwiftLint[(https://github.com/realm/SwiftLint), a utility for improving code quality. There should be absolutely no visible external changes, but it's a big change, internally.
- Removed the "auto [Jazzy](https://github.com/realm/jazzy)" documentation generator, as it slows down the build, and we can easily do it manually.

***Version 1.1.2* ** *- December 5, 2017*

- Updated to latest Xcode version.

***Version 1.1.1.3001* ** *- November 29, 2017*

- Spruced up this README, and tweaked some settings in the project.

***Version 1.1.1.3000* ** *- November 23, 2017*

- There was a possibility of a crash if the session was terminated without a connection.

***Version 1.1.0* ** *- November 14, 2017*

- Some basic refactoring to make the library more "Swift-studly."
- Made some references weak/unowned that should have been declared as such. Even though it has not (yet) resulted in a leak, it could.
- Updating basic project format to Xcode 8-compatible.
- Major restrutcture and history reset for CocoaPods.
- The Git repo has been reset. I'll also keep only a master branch, with release tags.
- Moving repo to GitHub, as GitHub and CocoaPods play better together.
- Fixed an issue with the search tab sometimes crashing when selected (test app).

***Version 1.0.1.3000* ** *- August 27, 2017*

- Fixed a possible crash that could be triggered by bad data in the weekday_index.
- Fixed a bug in the integer day and time (used for sorting).
- Added a check for a valid weekday index to the deleted meeting changelist response.
- Fixed a crash in the handler if an empty changelist was returned.
- Fixed an issue where older datasets caused parse problems.
- Slight update for the latest Xcode.
- Fixed an issue where Service bodies with no type would pooch the app.

***Version 1.0.0.3000* ** *- January 25, 2017*

- The BMLTiOSLibDelegate protocol now has almost all its functions optional.
- Switched the project to the MIT License. That's better for a project that is destined to be included in other projects, some of which may be commercial.
- This will be a Swift-only library. I have given up on supporting Objective-C. Not that big a loss.

***Version 1.0.0.2001* ** *- January 14, 2017*

- Added the silly CYA plist thing that says I'm not consorting with turrists using encryption.

***Version 1.0.0.2000* ** *- January 14, 2017*

- First Beta Release of the BMLTiOSLib Project.
- This will include simple demo apps that use the framework.
- Added a "performMeetingSearch()" method to the search criteria object, to make it convenient for apps to use just that object as their interaction.

***Version 1.0.0.1000* ** *- January 9, 2017*

- First Alpha Release of the BMLTiOSLib Project.


