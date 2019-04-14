//
//  BMLTCommunicator.swift
//  BMLTiOSLib
//
//  Created by MAGSHARE
//
//  https://bmlt.magshare.net/bmltioslib/
//
//  This software is licensed under the MIT License.
//  Copyright (c) 2017 MAGSHARE
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

/* ###################################################################################################################################### */
// MARK: - Class Extensions -
/* ###################################################################################################################################### */
/**
 This adds various functionality to the String class.
 */
extension String {
    /* ################################################################## */
    /**
     This tests a string to see if a given substring is present at the start.
     
     - parameter inSubstring: The substring to test.
     
     - returns: true, if the string begins with the given substring.
     */
    func beginsWith (_ inSubstring: String) -> Bool {
        var ret: Bool = false
        if let range = self.range(of: inSubstring) {
            ret = (range.lowerBound == self.startIndex)
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     The following function comes from this: http: //stackoverflow.com/a/27736118/879365
     
     This extension function cleans up a URI string.
     
     - returns: a string, cleaned for URI.
     */
    func URLEncodedString() -> String? {
        let customAllowedSet =  CharacterSet.urlQueryAllowed
        if let ret = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet) {
            return ret
        } else {
            return ""
        }
    }
    
    /* ################################################################## */
    /**
     The following function comes from this: http: //stackoverflow.com/a/27736118/879365
     
     This extension function creates a URI query string from given parameters.
     
     - parameter parameters: a dictionary containing query parameters and their values.
     
     - returns: a String, with the parameter list.
     */
    static func queryStringFromParameters(_ parameters: [String: String]) -> String? {
        if parameters.isEmpty {
            return nil
        }
        var queryString: String?
        for (key, value) in parameters {
            if let encodedKey = key.URLEncodedString() {
                if let encodedValue = value.URLEncodedString() {
                    if queryString == nil {
                        queryString = "?"
                    } else {
                        queryString! += "&"
                    }
                    queryString! += encodedKey + "=" + encodedValue
                }
            }
        }
        return queryString
    }
    
    /* ################################################################## */
    /**
     "Cleans" a URI
     
     - returns: an implicitly unwrapped optional String. This is the given URI, "cleaned up."
     "http[s]: //" may be prefixed.
     */
    func cleanURI() -> String! {
        return self.cleanURI(sslRequired: false)
    }
    
    /* ################################################################## */
    /**
     "Cleans" a URI, allowing SSL requirement to be specified.
     
     - parameter sslRequired: If true, then we insist on SSL.
     
     - returns: an implicitly unwrapped optional String. This is the given URI, "cleaned up."
     "http[s]: //" may be prefixed.
     */
    func cleanURI(sslRequired: Bool) -> String! {
        var ret: String! = self.URLEncodedString()
        
        // Very kludgy way of checking for an HTTPS URI.
        let wasHTTP: Bool = ret.lowercased().beginsWith("http://")
        let wasHTTPS: Bool = ret.lowercased().beginsWith("https://")
        
        // Yeah, this is pathetic, but it's quick, simple, and works a charm.
        ret = ret.replacingOccurrences(of: "^http[s]{0,1}://", with: "", options: NSString.CompareOptions.regularExpression)
        
        if wasHTTPS || (sslRequired && !wasHTTP && !wasHTTPS) {
            ret = "https://" + ret
        } else {
            ret = "http://" + ret
        }
        
        return ret
    }
}

/* ###################################################################################################################################### */
/**
 This is used to get the app name from the bundle.
 */
extension Bundle {
    /* ################################################################## */
    /**
     - returns: the bundle app name.
     */
    var appName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}

// MARK: - Protocols -
/* ###################################################################################################################################### */
/**
    This is a protocol for a data source that defines a "send and call back" structure.
*/
protocol BMLTCommunicatorDataSourceProtocol: class {
    /** If this is set to true, then errors are ignored. */
    var suppressErrors: Bool { get set }
    
    /* ################################################################## */
    /**
        Calls a URL
        
        - parameter inCommunicator: The communicator instance calling this.
        - parameter inURIAsAString: This contains a string, with the URI.
        - parameter inCompletionBlock: This is the completion block supplied by the caller. It is to be called upon receipt of data.
        - parameter inIsTest: If true, then we don't report task errors (the call is expected to fail).
    
        - returns: a Bool. True, if the call was successfully initiated.
    */
    func callURI(_ inCommunicator: BMLTCommunicator, inURIAsAString: String!, inCompletionBlock: BMLTCommunicator.RequestCompletionBlock!) -> Bool
}

/* ###################################################################################################################################### */
/**
    This defines a protocol for a communicator delegate, which receives the responses.
*/
protocol BMLTCommunicatorDataSinkProtocol: class {
    /* ################################################################## */
    /**
        The response callback.
    
        - parameter inHandler: The handler for this call.
        - parameter inResponseData: The data from the URL request. If nil, the call failed to produce. Check the handler's error data member.
        - parameter inError: Any errors that occurred
        - parameter inRefCon: The data/object passed in via the 'refCon' parameter in the initializer.
    */
    func responseData(_ inHandler: BMLTCommunicator?, inResponseData: Any, inError: Error?, inRefCon: AnyObject?)
}

// MARK: - Classes -
/* ###################################################################################################################################### */
/**
 This manages an interactive session connection with the server.
 
 For whatever reason, Cocoa/Swift won't let me derive from NSURLSession, so this class aggregates it, as opposed to extends it
 (not a big deal, probably better design in the long run anyway).
 
 The semantic administration requires a constant session. Authentication is done once during the session, then the
 server maintains the authentication for the duration of the session. For this reason, we need to maintain a consistent session
 throughout our administration duties. This class is instantiated once by the App Delegate, and holds the session open.
 
 This class maintains a dictionary of completion blocks that it uses to forward server responses to the users of this class.
 User instances need to define a completion block/callback, in the RequestCompletionBlock format. When they call a URL with
 this class, they provide this completion block. When the class instance gets the response, it forwards the data as an NSData
 instance to the completion block.
 */
class BMLTSession: NSObject, URLSessionDataDelegate, BMLTCommunicatorDataSourceProtocol {
    
    /* ################################################################## */
    // MARK: - Nested Classes -
    /* ################################################################## */
    /**
     This class allows us to "tag" tasks with a completion block, allowing better autonomy.
     */
    class BMLTSessionTaskData {
        /** This is the callback for this task. */
        var block: BMLTCommunicator.RequestCompletionBlock! = nil
        /** This is a data property that we build up as we get new data in. */
        var data: Data
        
        /* ################################################################## */
        /**
         Initialize our class. The Data object is always started off empty.
         
         - parameter block: This is the completion block.
         */
        init(block: BMLTCommunicator.RequestCompletionBlock!) {
            self.block = block
            self.data = Data()
        }
    }
    
    /* ################################################################## */
    // MARK: - Computed properties -
    /* ################################################################## */
    
   /** This is our session. */
    var mySession: Foundation.URLSession!   = nil
    
    /* ################################################################## */
    // MARK: - Instance Properties -
    /* ################################################################## */
    
    /** This will be set to true if the URL call is expected to fail (suppresses error report). */
    var suppressErrors: Bool        = false
    /** This is true if this is an SSL session */
    var isSSL: Bool = false
    /** We are strictly linear. No concurrent I/O. We have just one job, and we do it through completion. */
    var myCurrentTask: BMLTSessionTaskData! = nil
    
    /* ################################################################## */
    // MARK: - Instance Methods -
    /* ################################################################## */
    /**
     Make sure we clean up after ourselves.
     */
    deinit {
        self.disconnectSession()
    }
    
    /* ################################################################## */
    /**
     Pretty much exactly what it says on the tin.
     */
    func disconnectSession() {
        self.myCurrentTask = nil
        if self.isSessionConnected() {
            self.isSSL = false
            self.mySession.reset(completionHandler: {})
        }
    }

    /* ################################################################## */
    /**
     Declares the connection status.
     
     - returns: a Bool, true if the session is currently connected.
     */
    func isSessionConnected() -> Bool {
        return nil != self.mySession
    }
    
    /* ################################################################## */
    // MARK: - NSURLSessionDataDelegate Methods -
    /* ################################################################## */
    /**
     Called when a session throws a nutty.
     
     - parameter inSession: The NSURLSession that controls this task.
     - parameter error: The error returned.
     */
    func urlSession(_ inSession: URLSession, didBecomeInvalidWithError inError: Error?) {
        if inSession == self.mySession {  // Make sure this is us.
            if (nil != inError) && !self.suppressErrors {   // We don't display the error if we have been asked not to.
                if nil != self.myCurrentTask {
                    if let callback: BMLTCommunicator.RequestCompletionBlock = self.myCurrentTask!.block {
                        self.myCurrentTask = nil
                        callback(nil, inError)
                    } else {
                        self.myCurrentTask = nil
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called as the task receives data.
     
     - parameter inSession: The NSURLSession that controls this task.
     - parameter dataTask: The task that triggered this callback.
     - parameter didReceive: the received data piece.
     */
    func urlSession(_ inSession: URLSession, dataTask: URLSessionDataTask, didReceive: Data) {
        if (inSession == self.mySession) && (nil != self.myCurrentTask) {  // Make sure this is us.
            // This weird dance is because there's funky stuff going on under the hood, and this
            // will ensure that we have a separate, new copy of the data.
            var dRec: Data = didReceive
            dRec.withUnsafeMutableBytes { bytes in
                if let baseAddr = bytes.baseAddress {
                    let myDataObject = Data(bytes: baseAddr, count: didReceive.underestimatedCount)
                    self.myCurrentTask.data.append(myDataObject)
                }
            }
        }
    }

    /* ################################################################## */
    /**
     Called when a task has completed.
     We use this call to extract a JSON object from the response, then pass that object to the next handler.
     
     - parameter inSession: The NSURLSession that controls this task.
     - parameter task: The task that triggered this callback.
     - parameter error: Any error that occurred.
     */
    func urlSession(_ inSession: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if (inSession == self.mySession) && (nil != self.myCurrentTask) {  // Make sure this is us.
            if (nil != error) && !self.suppressErrors {   // We don't display the error if we have been asked not to.
                if let callback: BMLTCommunicator.RequestCompletionBlock = self.myCurrentTask!.block {
                    self.myCurrentTask = nil
                    callback(nil, error)
                }
            } else {
                if nil != self.myCurrentTask {
                    if let callback: BMLTCommunicator.RequestCompletionBlock = self.myCurrentTask?.block {
                        if let data = self.myCurrentTask?.data {
                            self.myCurrentTask = nil
                            do {    // Extract a usable object tree from the given JSON data.
                                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                                callback(jsonObject, nil)
                            } catch {   // We end up here in the few places where the response is not a proper JSON object.
                                callback(data, nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    // MARK: - BMLTCommunicatorDataSourceProtocol Methods -
    /* ################################################################## */
    /**
     Calls a URL
     
     - parameter inCommunicator: The communicator instance calling this.
     - parameter inURIAsAString: This contains a string, with the URI.
     - parameter inCompletionBlock: This is the completion block supplied by the caller. It is to be called upon receipt of data.
     - parameter inIsTest: If true, then we don't report task errors (the call is expected to fail).
     
     - returns: a Bool. True, if the call was successfully initiated.
     */
    func callURI(_ inCommunicator: BMLTCommunicator, inURIAsAString: String!, inCompletionBlock: BMLTCommunicator.RequestCompletionBlock!) -> Bool {
        // If we did not already have a session established, we set one up.
        if nil == self.mySession {
            self.isSSL = false
            self.mySession = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        }
        
        // This is a bit kludgy, but it's a way to let the server know we're coming from an iOS app.
        var appDisplayName: String = "callingApp=BMLTiOSLib"
        
        if let appName = Bundle.main.appName?.URLEncodedString() {
            appDisplayName += ("+" + appName)
        }
        
        let suffix = inURIAsAString.suffix(4).lowercased()
        
        if ".php" == suffix {
            appDisplayName = "?" + appDisplayName
        } else {
            appDisplayName = "&" + appDisplayName
        }
        var ret: Bool = false
        
        // This is because it is possible to crash the app by inserting a less-than character into a URI.
        let uriString = inURIAsAString.replacingOccurrences(of: "<", with: "%3C") + appDisplayName

        if let url = URL(string: uriString) {
            // Assuming we have a completion block and a URI, we will actually try to get a version from the server (determine its validity).
            if (nil == self.myCurrentTask) && (nil != inCompletionBlock) && (nil != inURIAsAString) && self.isSessionConnected() {
                let dataTask: URLSessionTask = self.mySession.dataTask(with: url)
                self.myCurrentTask = BMLTSessionTaskData(block: inCompletionBlock)
                ret = true
                dataTask.resume()   // Throw the switch, Igor!
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    // MARK: - URLSessionDelegate Methods -
    /* ################################################################## */
    /**
     This is a call that is made to validate an SSL security challenge (session variant).
     
     - parameter session: The session thatt's running the connection being challenged.
     - parameter challenge: The challenge type
     - parameter completionHandler: The handler we need to call with our response.
     */
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let protectionSpace = challenge.protectionSpace
        
        if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            self.isSSL = true
            completionHandler(.useCredential, URLCredential(trust: protectionSpace.serverTrust!))
        } else if protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            if challenge.previousFailureCount > 0 {
                completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            } else {
                let credential = URLCredential(user: "username", password: "password", persistence: .forSession)
                completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, credential)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is a call that is made to validate an SSL security challenge (task variant).
     
     - parameter session: The session thatt's running the connection being challenged.
     - parameter task: The actual URL task that resulted in this challenge.
     - parameter challenge: The challenge type
     - parameter completionHandler: The handler we need to call with our response.
     */
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.previousFailureCount > 0 {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        } else {
            let credential = URLCredential(user: "username", password: "password", persistence: .forSession)
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, credential)
        }
    }
}

/* ###################################################################################################################################### */
/**
    The main reason for the existence of this class is to make the communications testable. Its structure allows the tester to inject
    data sources and sinks.
    
    Data sources and sinks are adornments. This allows us to substitute mocks when testing.

    This is a lightweight, short-lifetime class. It is meant to be instantiated and destroyed on an "as needed" basis.
*/
class BMLTCommunicator {
    /* ################################################################## */
    // MARK: - Type Definitions -
    /* ################################################################## */
    /**
        This is the definition for the testRootServerURI completion block.

        The routine is called upon completion of a URL connection. When the
        connection ends (either successfully or not), this routine is called.
        If it is successful, then the inData parameter will be non-nil.
        If it failed, then the parameter will be nil, and the inError
        parameter may have a value.

        - parameter inData:  The Data returned.
        - parameter inError: Any error that ocurred. Nil, if no error.
    */
    typealias RequestCompletionBlock = (_ inData: Any?, _ inError: Error?) -> Void
    
    /* ################################################################## */
    // MARK: - Fixed Data Members -
    /* ################################################################## */
    /** This is the data source for the call. */
    let dataSource: BMLTCommunicatorDataSourceProtocol!
    /** This is the completion handler to be called when the URL is called. */
    weak var delegate: BMLTCommunicatorDataSinkProtocol!
    /** This is the completion handler to be called when the URL is called. */
    let uriAsAString: String!
    /** This is any extra data the caller may want passed to the callback. */
    let refCon: AnyObject?
    
    // MARK: - Dynamic Data Members -
    /** This contains any error from the call. */
    var error: Error!
    /** This contains the data response (if any). */
    var data: Data!
    
    /* ################################################################## */
    // MARK: - Instance Methods -
    /* ################################################################## */
    /**
        This is the designated initializer for this class. You have to give
        a URL, as well as a delegate (sink) and data source.
        This class executes the connection upon initialization.
    
        - parameter inURI: The URL to be called, as a string.
        - parameter dataSource: The data source.
        - parameter delegate: The delegate object (the sink) to be notified when new data arrives.
        - parameter refCon: This is any object or data that you want to send to the delegate receive method. Default is nil.
        - parameter executeImmediately: If true (the default), the instance executes immediately.
                The reason for this flag, as opposed to simply overriding the "execute()" method,
                is so we have a bit more flexibility. We don't need to rewrite that method if we
                don't want to. Since the parameter has a default, it's not an issue to ignore it.
    */
    init(_ inURI: String, dataSource inDataSource: BMLTCommunicatorDataSourceProtocol, delegate inDelegate: BMLTCommunicatorDataSinkProtocol!, refCon inRefCon: AnyObject? = nil, executeImmediately inExecute: Bool = true) {
        self.uriAsAString = inURI
        self.dataSource = inDataSource
        self.delegate = inDelegate
        self.refCon = inRefCon
        self.data = nil
        self.error = nil
        
        if inExecute {
            self.execute()
        }
    }
    
    /* ################################################################## */
    /**
        This actually executes the connection.
    */
    func execute() {
        _ = self.dataSource.callURI(self, inURIAsAString: self.uriAsAString, inCompletionBlock: self.handleResponseFromHandler)
    }
    
    /* ################################################################## */
    /**
        This is the callback for the URL request.
    
        - parameter inData: the data from the URL request.
        - parameter inError: Any error that ocurred. Nil, if no error.
    */
    func handleResponseFromHandler(_ inData: Any, inError: Error?) {
        self.error = inError
        if nil != self.delegate {
            self.delegate.responseData(self, inResponseData: inData, inError: self.error, inRefCon: self.refCon)
        }
    }
}
