![BMLTiOSLib Icon](https://bmlt.app/wp-content/uploads/2017/01/BMLTLogo.png)

*[This document, as a GitHub Pages Site](https://bmlt-enabled.github.io/BMLTiOSLib/)*

# BMLTiOSLib

**NOTE:** A detailed, example-rich technical discussion of this library [is available on this Web site](https://bmlt.app/specific-topics/bmltioslib/).

The BMLTiOSLib fits between [the BMLT Root Server's Semantic Interface](https://bmlt.app/semantic/) and your iOS app:

![Chart, Showing Where the BMLTiOSLib Fits](https://bmlt.app/wp-content/uploads/2017/01/BMLTiOSLibSetup.png)

This project is an [iOS Shared Framework](https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPFrameworks/Tasks/CreatingFrameworks.html), designed to ease integration of a BMLT Root Server into an iOS client (it may also work for MacOS, but we're not there yet). The BMLTiOSLib is a Swift-only framework. It won't support Objective-C. The [BMLTiOSLib/Framework](https://github.com/bmlt-enabled/BMLTiOSLib/tree/master/BMLTiOSLib/Framework%20Project) directory has the relevant exported classes. The [BMLTiOSLib/Test Harness Project](https://github.com/bmlt-enabled/BMLTiOSLib/tree/master/BMLTiOSLib/Test%20Harness%20Project) directory implements a fairly complex program that we've written to exercise the library. Because [Apple now requires that iOS apps only interact with SSL servers](https://techcrunch.com/2016/06/14/apple-will-require-https-connections-for-ios-apps-by-the-end-of-2016/), it's a bit complex to test. We don't want to compromise security by allowing connections to self-signed certs, so we can't test with localhost.

**PROTIP:** We use [Charles Proxy](https://www.charlesproxy.com) to examine the interaction between the simulator and the server. [It is possible to set up Charles as a "man in the middle" to decrypt SSL interactions.](https://www.charlesproxy.com/documentation/proxying/ssl-proxying/)

For easy testing, you can connect to [the BMLT Test Server](https://latest.aws.bmlt.app/main_server/), which uses SSL. This database may change a lot, as it is our main test bed, but it will always have the ability to be accessed via SSL. [The BMLTiOSLib Tester app](https://github.com/bmlt-enabled/BMLTiOSLib/tree/master/BMLTiOSLib/Test%20Harness%20Project) is not pretty. It's not meant to be. It's a space shuttle cockpit program that's designed to let us press all the various buttons. It also has a couple of issues with operation that, quite frankly, aren't a priority to fix, as [we now have several "real world" implementations](https://bmlt.app/satellites/bmlt-ios-apps/) that stress the BMLTiOSLib a great deal more than this ugly little duckling. [This is the documentation page for the BMLTiOSLib.](https://bmlt.app/bmltioslib/)

## INSTALLATION

### As A [CocoaPod](https://cocoapods.org):

To use this as a [CocoaPod](https://cocoapods.org), simply add the following to your [podfile](https://guides.cocoapods.org/using/the-podfile.html):

    pod 'BMLTiOSLib'

You then `cd` to the project directory, and execute `pod install` or `pod update` on the command line.

### Using [Carthage](https://github.com/Carthage/Carthage):

To use this from [Carthage](https://github.com/Carthage/Carthage), simply add the following to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

    github "bmlt-enabled/BMLTiOSLib"

You then `cd` to the project directory, and execute `carthage update` on the command line.

### Directly:

You can also directly access this project from its [location as a GitHub repo](https://github.com/bmlt-enabled/BMLTiOSLib), and include it into your project.

## UNDER THE HOOD

The BMLTiOSLib communicates with the Root Server using [the BMLT JSON Semantic Interface](http://bmlt.magshare.net/semantic/how-to-use-the-semantic-interface/). Administration is done using [the BMLT Administrative Semantic Interface](http://bmlt.magshare.net/semantic/semantic-administration/) (Also JSON). The whole idea is to completely abstract the communication layer from the app development process. BMLTiOSLib provides a simple, error-checked functional interface to the BMLT. Interaction with the BMLTiOSLib is done via Apple's [Delegation Pattern](https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/Delegation.html). When you instantiate an instance of BMLTiOSLib, you register your app as a [BMLTiOSLibDelegate](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html) delegate instance, and it will receive events as they come in. You then use the functional interface to operate the connection.

## BASIC USAGE:

The [BMLTiOSLib](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html) class represents the public interface to the BMLTiOSLib framework. This class needs to be instantiated with a URI to a valid [Root Server](http://bmlt.magshare.net/installing-a-new-root-server/) (the same URI used to log in), and a BMLTiOSLibDelegate delegate instance. Instantiation immediately starts a communication process, and the result will be reflected in the delegate's [bmltLibInstance(_ inLibInstance: BMLTiOSLib, serverIsValid: Bool)](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html#/c:@M@BMLTiOSLib@objc\(pl\)BMLTiOSLibDelegate\(im\)bmltLibInstance:serverIsValid:) callback. If this instance fails to connect to a valid Root Server, it should be deleted, and reinstantiated for a new connection. Once a connection is established, the HTTP session is maintained until the instance is deinstantiated. The session is required to be maintained for Semantic Administration. You cannot share a session across instances of [BMLTiOSLib](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html).

### BASIC SERVER INFORMATION:
 
Once you have successfully connected (established a session) to the Root Server, this instance will have some fundamental information available about that server. Your delegate's [bmltLibInstance(_ inLibInstance: BMLTiOSLib, serverIsValid: Bool)](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html#/c:@M@BMLTiOSLib@objc\(pl\)BMLTiOSLibDelegate\(im\)bmltLibInstance:serverIsValid:) method is called when the connection is successful (`serverIsValid` is true). This information can be accessed by calling the following [BMLTiOSLib](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html) instance properties:

- [distanceUnits](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC13distanceUnitsAA0ab8DistanceD0Ov) and [distanceUnitsString](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC19distanceUnitsStringSSv) (This is the distance unit used for the server -Km or Mi).

- [availableMeetingValueKeys](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC25availableMeetingValueKeysSaySSGv) (This contains the Dictionary key strings that can access various meeting properties).

- [emailMeetingContactsEnabled](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC27emailMeetingContactsEnabledSbv) (True, if the Server is set to allow emails to be sent to meeting contacts).

- [emailServiceBodyAdminsEnabled](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC29emailServiceBodyAdminsEnabledSbv) (True, if these emails will CC the Service Body Admin for that Service body, as well as the meeting contact -They may be the same email address).

- [changeDepth](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC11changeDepthSiv) (The number of changes saved per meeting).

- [googleAPIKey](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC12googleAPIKeySSv) ([The Google Maps API key](https://developers.google.com/maps/documentation/javascript/get-api-key) for the Root Server -May not be useful for most other Servers).

- [delegate](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC8delegateSQyAA0aB8Delegate_pGv) (That will be the object -implementing the [BMLTiOSLibDelegate](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html) protocol that was passed in as delegate [when the instance was created](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAACABSS15inRootServerURI_AA0aB8Delegate_p0cG0tcfc)).

- [versionAsString](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC15versionAsStringSSv) and [versionAsInt](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC12versionAsIntSiv) (The server version)

- [isAdminAvailable](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC16isAdminAvailableSbv) (True, if [Semantic Administration](https://bmlt.app/semantic/semantic-administration/) is available).

- [defaultLocation](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC15defaultLocationSC22CLLocationCoordinate2DVv) (The Root Server's default central location).

- [serviceBodies](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC13serviceBodiesSayAA0aB27HierarchicalServiceBodyNodeCGv) (This is a "flat" Array of the Service bodies, with no hierarchy).

- [hierarchicalServiceBodies](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC25hierarchicalServiceBodiesAA0ab12HierarchicalD8BodyNodeCv) (This maps out the Service bodies in the hierarchy they occupy on the Root Server, and this is just one node with children only -no parents or Service body).

- [allPossibleFormats](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC18allPossibleFormatsSayAA0aB10FormatNodeCGv) (an Array of format objects available -May not all be used by the meetings).

- [availableServerLanguages](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC24availableServerLanguagesSayAA0abD4LangCGv) (an Array of language objects).

You determine if the connection was successful by examining the value of the `serverIsValid` parameter in the required [bmltLibInstance(_ inLibInstance: BMLTiOSLib, serverIsValid: Bool)](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html#/c:@M@BMLTiOSLib@objc\(pl\)BMLTiOSLibDelegate\(im\)bmltLibInstance:serverIsValid:) call:


```

    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, serverIsValid: Bool) {
        if serverIsValid {
                                •
                                •
                                •
                                •
        }
    }

```

If any errors occurred, the required [bmltLibInstance(_ : BMLTiOSLib, errorOccurred: Error)](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html#/c:@M@BMLTiOSLib@objc\(pl\)BMLTiOSLibDelegate\(im\)bmltLibInstance:errorOccurred:) call is made:


```

    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, errorOccurred: Error) {
                                •
                                •
                                •
                                •
    }


```

Here's a brief image, showing how the BMLTiOSLib acts when setting up the connection:


![Interaction Diagram](https://bmlt.app/wp-content/uploads/2017/01/InitialConnection.png)


### MEETING SEARCHES:
 
The way that you do a meeting search with this class, is to acquire the instance's searchCriteria object, and use its various properties to set up your desired search. Once that is done, you call this class instance's [performMeetingSearch(_:BMLTiOSLibSearchCriteria.SearchCriteriaExtent)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibSearchCriteria.html#/s:10BMLTiOSLib0aB14SearchCriteriaC014performMeetingC0yAC0cD6ExtentOF) method, indicating whether you want just meetings, just the formats used by the meetings in the search results, or both. Once the search is complete, this class will call your delegate routines:

- [bmltLibInstance(_:BMLTiOSLib,meetingSearchResults:[BMLTiOSLibMeetingNode])](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html#/c:@M@BMLTiOSLib@objc\(pl\)BMLTiOSLibDelegate\(im\)bmltLibInstance:meetingSearchResults:) is called with the results of the meeting search.

- [bmltLibInstance(_:BMLTiOSLib,formatSearchResults:[BMLTiOSLibFormatNode],isAllUsedFormats:Bool)](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html#/c:@M@BMLTiOSLib@objc\(pl\)BMLTiOSLibDelegate\(im\)bmltLibInstance:formatSearchResults:isAllUsedFormats:) is called with the results of the format search.

Either or both may be called, depending on what you requested when you called [performMeetingSearch(_:BMLTiOSLibSearchCriteria.SearchCriteriaExtent)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibSearchCriteria.html#/s:10BMLTiOSLib0aB14SearchCriteriaC014performMeetingC0yAC0cD6ExtentOF). If there are no results, they will be called with empty Arrays. You can get meeting search results, the formats used for the given meeting search, or both. These results are returned in these two [BMLTiOSLibDelegate](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html) calls:
 
 
```

    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, meetingSearchResults: [BMLTiOSLibMeetingNode]) {
                                •
                                •
                                •
                                •
    }

    public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, formatSearchResults: [BMLTiOSLibFormatNode], isAllUsedFormats: Bool) {
                                •
                                •
                                •
                                •
    }


```

If [isAllUsedFormats](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html#/c:@M@BMLTiOSLib@objc\(pl\)BMLTiOSLibDelegate\(im\)bmltLibInstance:formatSearchResults:isAllUsedFormats:) is false, then the formats returned are **ONLY** those used in the set of meetings specified in the search. If `isAllUsedFormats` is true, then the format set is every available format on the server; regardless of whether ot not it is used by any of the meetings (basically the same as the contents of the [allPossibleFormats](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC18allPossibleFormatsSayAA0aB10FormatNodeCGv) instance property).
 

### MEETING CHANGES:
 
You can query for meeting changes, including deleted meetings [(and you can restore deleted meetings if you are an authorized administrator)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC21restoreDeletedMeetingSbSiF). You do this by calling one of these methods:
 
- [getAllMeetingChanges(meetingID:Int?)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC20getAllMeetingChangesySi9meetingID_tF)

- [getAllMeetingChanges(serviceBodyID:Int?)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC24getDeletedMeetingChangesySiSg13serviceBodyID_tF)

- [getAllMeetingChanges(meeting:BMLTiOSLibMeetingNode?)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC20getAllMeetingChangesyAA0abE4NodeCSg7meeting_tF)

- [getAllMeetingChanges(fromDate:Date?,toDate:Date?)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC20getAllMeetingChangesy10Foundation4DateVSg04fromH0_AG02toH0SiSg9meetingIDtF)

- [getAllMeetingChanges(fromDate:Date?,toDate:Date?,meetingID:Int?)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC20getAllMeetingChangesy10Foundation4DateVSg04fromH0_AG02toH0SiSg9meetingIDtF)

- [getAllMeetingChanges(fromDate:Date?,toDate:Date?,serviceBodyID:Int?)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC20getAllMeetingChangesy10Foundation4DateVSg04fromH0_AG02toH0SiSg13serviceBodyIDtF)

- [getAllMeetingChanges(fromDate:Date?,toDate:Date?,serviceBodyID:Int?,meetingID:Int?)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC20getAllMeetingChangesy10Foundation4DateVSg04fromH0_AG02toH0SiSg13serviceBodyIDAJ07meetingM0tF)

- [getAllMeetingChanges(fromDate:Date?,toDate:Date?,serviceBodyID:Int?,meetingID:Int?,userID:Int?)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC20getAllMeetingChangesy10Foundation4DateVSg04fromH0_AG02toH0SiSg13serviceBodyIDAJ07meetingM0AJ04userM0tF)

- [getDeletedMeetingChanges()](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC24getDeletedMeetingChangesyyF)

- [getDeletedMeetingChanges(serviceBodyID:Int?)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC24getDeletedMeetingChangesySiSg13serviceBodyID_tF)

- [getDeletedMeetingChanges(serviceBodyIDs:[Int]?)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC24getDeletedMeetingChangesySaySiGSg14serviceBodyIDs_tF)

- [getDeletedMeetingChanges(fromDate:Date?,toDate:Date?,serviceBodyID:Int?)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC24getDeletedMeetingChangesy10Foundation4DateVSg04fromH0_AG02toH0SiSg13serviceBodyIDtF)

- [getDeletedMeetingChanges(fromDate:Date?,toDate:Date?,serviceBodyIDs:[Int]?)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC24getDeletedMeetingChangesy10Foundation4DateVSg04fromH0_AG02toH0SaySiGSg14serviceBodyIDstF)

After calling one of the above methods, your delegate is called back with the [bmltLibInstance(_:BMLTiOSLib,changeListResults:[BMLTiOSLibChangeNode])](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html#/c:@M@BMLTiOSLib@objc\(pl\)BMLTiOSLibDelegate\(im\)bmltLibInstance:changeListResults:) method; which will have an Array of the requested change objects. You can then use these objects to revert meetings, or restore deleted meetings:

```
 
     public func bmltLibInstance(_ inLibInstance: BMLTiOSLib, changeListResults: [BMLTiOSLibChangeNode]) {
                                •
                                •
                                •
                                •
    }
 
```

### SENDING MESSAGES TO MEETING CONTACTS:

In some Root Servers, the administrator can choose to enable the ability for users of the site to send messages to designated contacts for meetings (or the Service Body Administrator responsible for the meeting). In these cases, the message is received as an email, but the sender does not send an email. Instead, they use a method of the [BMLTiOSLibMeetingNode](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibMeetingNode.html) class, called [sendMessageToMeetingContact(fromAddress:String,messageBody:String)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibMeetingNode.html#/s:10BMLTiOSLib0aB11MeetingNodeC013sendMessageToC7ContactySS11fromAddress_SS11messageBodytF). The message is sent in the background. When the message has been sent, your delegate is called with the [bmltLibInstance(_:BMLTiOSLib,sendMessageSuccessful:Bool)](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html#/c:@M@BMLTiOSLib@objc\(pl\)BMLTiOSLibDelegate\(im\)bmltLibInstance:sendMessageSuccessful:) method.


## ADMINISTRATION:

In order to perform administration on the Root Server, you need to log in with the [adminLogin(loginID:String,password:String)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC10adminLoginSbSS7loginID_SS8passwordtF) method. The login will remain valid for the lifetime of this object (and its connection session), or until the [adminLogout()](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLib.html#/s:10BMLTiOSLibAAC11adminLogoutSbyF) method is called. Results of meeting searches may return the meeting objects as instances of [BMLTiOSLibEditableMeetingNode](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html) instead of [BMLTiOSLibMeetingNode](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibMeetingNode.html) (as long as you are logged in as an administrator, and have sufficient rights to edit the meeting). It will depend on the edit rights that the login has for the given meeting. If you cannot edit the meeting, then the instance will be of [BMLTiOSLibMeetingNode](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibMeetingNode.html), instead of [BMLTiOSLibEditableMeetingNode](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html). If the instance is [BMLTiOSLibEditableMeetingNode](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html), the [isEditable](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibMeetingNode.html#/s:10BMLTiOSLib0aB11MeetingNodeC10isEditableSbv) property will return true. If the instance is of the [BMLTiOSLibEditableMeetingNode](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html) class, you can cast it to that class, and manipulate the public properties. Once the properties have been set, you can then call the [saveChanges()](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html#/s:10BMLTiOSLib0aB19EditableMeetingNodeC11saveChangesyyF) method for that instance, and the meeting will be saved. Until the [saveChanges()](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html#/s:10BMLTiOSLib0aB19EditableMeetingNodeC11saveChangesyyF) method is called, the meeting changes are not sent to the server. Once the meeting has been saved, your delegate will receive a call to its [bmltLibInstance(_:BMLTiOSLib,adminMeetingChangeComplete:BMLTiOSLibChangedMeeting!)](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html#/c:@M@BMLTiOSLib@objc\(pl\)BMLTiOSLibDelegate\(im\)bmltLibInstance:adminMeetingChangeComplete:) method with an object that will contain whatever fields of the meeting changed, with the "before" and "after" values (always Strings). You can also delete a meeting, by calling the [delete()](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html#/s:10BMLTiOSLib0aB19EditableMeetingNodeC6deleteyyF) method (The deletion happens immediately). If you delete the meeting, your delegate is called with the [bmltLibInstance(_:BMLTiOSLib,deleteMeetingSuccessful:Bool)](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html#/c:@M@BMLTiOSLib@objc\(pl\)BMLTiOSLibDelegate\(im\)bmltLibInstance:deleteMeetingSuccessful:) method. If you call the [restoreToOriginal()](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html#/s:10BMLTiOSLib0aB19EditableMeetingNodeC17restoreToOriginalyyF) method, any changes that you made to the meeting object will be reverted to the state of the meeting on the server. Nothing will be sent to the server. You can also revert a meeting to the state it was in before a given change record for that meeting, using the [revertMeetingToBeforeThisChange(_:BMLTiOSLibChangeNode)](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibChangeNode.html#/s:10BMLTiOSLib0aB10ChangeNodeC025revertMeetingToBeforeThisC0SbyF) method. Nothing will be sent to the server. If the change was inappropriate for the meeting, the call will return false. If it was successful, the meeting's state will be reverted to that in the change record, but will not yet be sent to the server. You still need to call [saveChanges()](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html#/s:10BMLTiOSLib0aB19EditableMeetingNodeC11saveChangesyyF).


### ROLLING BACK AND UNDELETING MEETINGS:

Selecting the [saveMeetingToBeforeThisChange()](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibChangeNode.html#/s:10BMLTiOSLib0aB10ChangeNodeC023saveMeetingToBeforeThisC0SbyF) of a change [or editable meeting object](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html#/s:10BMLTiOSLib0aB19EditableMeetingNodeC04saveD18ToBeforeThisChangeSbAA0abjE0CF) will use the restore deleted or rollback function of the Semantic Admin interface (as long as you are logged in as an administrator, and have sufficient rights to edit the meeting). We do allow you to take the "before" record of the meeting (found in the `json_data` JSON response, or the [beforeObject](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibChangeNode.html#/s:10BMLTiOSLib0aB10ChangeNodeC12beforeObjectSQyAA0ab7MeetingD0CGv) property of the change record object), and save that. This allows you to add new changes (as opposed to simply accepting the whole change in a rollback, you can choose to only take certain changes). It also gives a better change record in the meeting history. Instead of a curt "Meeting was rolled back to a previous version.", you now have a list of the exact fields that were changed. Remember that the [beforeObject](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibChangeNode.html#/s:10BMLTiOSLib0aB10ChangeNodeC12beforeObjectSQyAA0ab7MeetingD0CGv) and [afterObject](/Classes/BMLTiOSLibChangeNode.html#/s:10BMLTiOSLib0aB10ChangeNodeC11afterObjectSQyAA0ab7MeetingD0CGv) properties are fully-qualified meeting objects, and, if editable, can be saved, which overwrites whatever is currently in the database (It's exactly like saving a changed meeting record). You revert a meeting by calling the [revertMeetingToBeforeThisChange()](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibChangeNode.html#/s:10BMLTiOSLib0aB10ChangeNodeC025revertMeetingToBeforeThisC0SbyF) method of the change record object concerned. It's quite simple.

### NEW MEETINGS:

Creating new meetings is easy (as long as you are logged in as an administrator, and have sufficient rights to create a meeting). You create an instance of [BMLTiOSLibEditableMeetingNode](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html) with an ID of 0 (the default). Then, when you call [saveChanges()](https://bmlt-enabled.github.io/BMLTiOSLib/Classes/BMLTiOSLibEditableMeetingNode.html#/s:10BMLTiOSLib0aB19EditableMeetingNodeC11saveChangesyyF), it will create a new meeting. When you create a new meeting, or restore a deleted meeting, your delegate is called with the [bmltLibInstance(_:BMLTiOSLib,newMeetingAdded:BMLTiOSLibEditableMeetingNode)](https://bmlt-enabled.github.io/BMLTiOSLib/Protocols/BMLTiOSLibDelegate.html#/c:@M@BMLTiOSLib@objc\(pl\)BMLTiOSLibDelegate\(im\)bmltLibInstance:newMeetingAdded:) method. The `newMeetingAdded` parameter will contain an object that models the newly-created meeting (including the new ID, if it was a brand-new meeting).

## As of December, 2017:

### TO DO

- Make tasks interruptable without terminating the session. Currently, the way to terminate a task is to terminate the session. This works great for search apps, but not so good for admin apps, as the session carries the login. If you terminate the session, you force the user to log back in.

- Make the library multi-tasking. Currently, the library works in a single-threaded manner. It should be able to handle multiple simultaneous tasks.

### NICE TO HAVE

- Test against a simple TVOS Swift app

- Test against a simple MacOS Swift app
