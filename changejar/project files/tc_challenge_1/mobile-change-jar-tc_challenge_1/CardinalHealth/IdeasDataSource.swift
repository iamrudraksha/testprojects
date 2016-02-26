//
//  IdeasDataSource.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 23.06.15.
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
* @version 1.0
*/
class IdeasDataSource {
    
    /// instance of raw RestAPI service
    internal let api: RestAPI
    
    /// cached ideas to use in getIdeasCached()
    var cachedIdeas: [Idea]?
    
    /// singleton shared instance
    class var sharedInstance: IdeasDataSource {
        struct Singleton { static let instance = IdeasDataSource() }
        return Singleton.instance
    }
    
    /**
    Instantiates IdeasDataSource without access token
    
    :returns: new instance of the endpoint group wrapper
    */
    internal init() {
        self.api = RestAPI(baseUrl: Configuration.sharedConfig.apiBaseUrl, accessToken: "")
    }
    
    /**
    Get ideas
    
    :param: email         optional email parameter
    :param: forseReload   optional flag: true - need to reload data from server, false - use cached
    :param: callback      callback block used to indicate a success and return ideas
    :param: errorCallback callback block used to notify about an error occurred while processing the request
    */
    func getIdeas(email: String? = nil, forseReload: Bool = true, callback: ([Idea])->(), errorCallback: (RestError, RestResponse?)->()) {
        
        if !forseReload {
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
            AppDelegate.sharedInstance.saveContext()
            callback(list)
            
        }, errorCallback: errorCallback)
    }
    
    /**
    Mark given ideas as not new
    
    :param: ideas the list of ideas
    */
    func markIdeasAsNotNew(ideas: [Idea]) {
        for idea in ideas {
            idea.isNew = false
        }
        AppDelegate.sharedInstance.saveContext()
    }
    
    /**
    Add new idea
    
    :param: ideaData          the new idea
    :param: callback      callback block used to indicate a success and return the idea with changed id
    :param: errorCallback callback block used to notify about an error occurred while processing the request
    */
    func addIdea(ideaData: IdeaData, callback: (Idea)->(), errorCallback: (RestError, RestResponse?)->()) {
        // Validate parameters
        if !ValidationUtils.validateStringNotEmpty(ideaData.title, errorCallback) { return }
        if !ValidationUtils.validateStringNotEmpty(ideaData.text, errorCallback) { return }
        if let name = ideaData.submitter {
            if !ValidationUtils.validateStringNotEmpty(name, errorCallback) { return }
            if !ValidationUtils.validateEmail(ideaData.submitterEmail, errorCallback) { return }
        }
        
        let request = createRequest(.PUT, "ideas/")
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
            
            self.cachedIdeas?.append(newIdea)
            
            callback(newIdea)
            
        }, errorCallback: errorCallback)

    }
    
    /**
    Create request with common headers
    
    :param: method   the HTTP method
    :param: endpoint the endpoint to use
    
    :returns: new request instance
    */
    internal func createRequest(method: RestMethod, _ endpoint: String) -> RestRequest {
        let request = RestRequest(method, endpoint)
        request.headers = ["Email": LastUserInfo?.email ?? ""]
        return request
    }
}