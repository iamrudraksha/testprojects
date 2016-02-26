//
//  IdeasDataSource.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 23.06.15.
//  Modified by Volkov Alexander on 16.07.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation


/*
OPTION: true - will mark new added ideas by current user as not new, false - will do nothing.
*/
var OPTION_MARK_MY_IDEAS_AS_NOT_NEW = false

/**
* Ideas data source
*
* @author Alexander Volkov
* @version 1.1
* changes:
* 1.1:
* - new HTTP headers
* - POST request instead of PUT
*/
class IdeasDataSource {
    
    // HTTP headers used in requests
    let HEADER_AUTH_ID = "Email"                    // used to identify the user on server
    let HEADER_SERVICE_PASSWORD = "servicePassword" // used to secure the connection with the service
    let HEADER_SERVICE_ID = "serviceId"             // used to identify the service
    
    /// instance of raw RestAPI service
    internal let api: RestAPI
    
    /// flag: true - need to use cached ideas, false - use ideas from the server
    var useCache = false
    
    /// singleton shared instance
    class var sharedInstance: IdeasDataSource {
        struct Singleton { static let instance = IdeasDataSource() }
        return Singleton.instance
    }
    
    /**
    Instantiates IdeasDataSource without access token
    
    - returns: new instance of the endpoint group wrapper
    */
    internal init() {
        self.api = RestAPI(baseUrl: Configuration.sharedConfig.apiBaseUrl, accessToken: "")
    }
    
    /**
    Get ideas
    
    - parameter email:         optional email parameter
    - parameter forseReload:   optional flag: true - need to reload data from server, false - use cached
    - parameter callback:      callback block used to indicate a success and return ideas
    - parameter errorCallback: callback block used to notify about an error occurred while processing the request
    */
    func getIdeas(email: String? = nil, forseReload: Bool = false, callback: ([Idea])->(), errorCallback: (RestError, RestResponse?)->()) {
        
        if !forseReload {
            if useCache {
                var ideas = Idea.findAll(AppDelegate.sharedInstance.managedObjectContext!)
                if ideas.count > 0 {
                    
                    // Filter by email
                    if let emailToFilter = email {
                        ideas = ideas.filter({ $0.submitterEmail == emailToFilter })
                    }
                    
                    callback(ideas)
                    return
                }
            }
        }
        
        // Validate parameter
        if email != nil {
            if !ValidationUtils.validateStringNotEmpty(email!, errorCallback) { return }
        }

        var request = createRequest(.GET, "ideas/")
        if email != nil {
            request = createRequest(.GET, "ideas/" + email!.urlEncodedString())
        }
    
        // Send request
        self.api.sendAndHandleCommonErrors(request, withJSONCallback: {
            (json: JSON, response: RestResponse?) -> () in
            
            var list = [Idea]()
            for item in json.arrayValue {
                let idea = Idea.fromJson(item)
                list.append(idea)
                
                // Mark all 'my' ideas as not new (this is required when the app is opened from another device)
                if OPTION_MARK_MY_IDEAS_AS_NOT_NEW {
                    if idea.isMyIdea() {
                        idea.isNew = false
                    }
                }
            }
            self.useCache = true
            AppDelegate.sharedInstance.saveContext()
            callback(list)
            
        }, errorCallback: errorCallback)
    }
    
    /**
    Mark given ideas as not new
    
    - parameter ideas: the list of ideas
    */
    func markIdeasAsNotNew(ideas: [Idea]) {
        for idea in ideas {
            idea.isNew = false
        }
        AppDelegate.sharedInstance.saveContext()
    }
    
    /**
    Add new idea
    
    - parameter ideaData:          the new idea
    - parameter callback:      callback block used to indicate a success and return the idea with changed id
    - parameter errorCallback: callback block used to notify about an error occurred while processing the request
    */
    func addIdea(ideaData: IdeaData, callback: (Idea)->(), errorCallback: (RestError, RestResponse?)->()) {
        // Validate parameters
        if !ValidationUtils.validateStringNotEmpty(ideaData.title, errorCallback) { return }
        if !ValidationUtils.validateStringNotEmpty(ideaData.text, errorCallback) { return }
        if let name = ideaData.submitter {
            if !ValidationUtils.validateStringNotEmpty(name, errorCallback) { return }
            if !ValidationUtils.validateEmail(ideaData.submitterEmail, errorCallback) { return }
        }
        
        let request = createRequest(.POST, "ideas/")
        request.parameters = [
            "anonymous": ideaData.submitter == nil,
            "createdTimestamp": FullDateParsers.dateParser.stringFromDate(ideaData.created),
            "idea": ideaData.text,
            "ideaTitle": ideaData.title,
            "submitter": ideaData.submitter ?? "",
            "submitterTitle": ideaData.submitterTitle,
            "submitterEmail": ideaData.submitterEmail,
            "submitterIdea" : ideaData.submitterIdea ? "yes" : "no"
        ]
        
        // Send request
        self.api.sendAndHandleCommonErrors(request, withJSONCallback: {
            (json: JSON, response: RestResponse?) -> () in
            
            let newIdea = Idea.fromJson(json)
            if OPTION_MARK_MY_IDEAS_AS_NOT_NEW {
                newIdea.isNew = false // mark as not new because we just created it
            }
            AppDelegate.sharedInstance.saveContext()
            
            callback(newIdea)
            
        }, errorCallback: errorCallback)

    }
    
    /**
    Create request with common headers
    
    - parameter method:   the HTTP method
    - parameter endpoint: the endpoint to use
    
    - returns: new request instance
    */
    internal func createRequest(method: RestMethod, _ endpoint: String) -> RestRequest {
        let request = RestRequest(method, endpoint)
        request.headers = [
            HEADER_AUTH_ID: LastUserInfo?.email ?? "",
            HEADER_SERVICE_PASSWORD: Configuration.sharedConfig.servicePassword,
            HEADER_SERVICE_ID: Configuration.sharedConfig.serviceId
        ]
        return request
    }
}