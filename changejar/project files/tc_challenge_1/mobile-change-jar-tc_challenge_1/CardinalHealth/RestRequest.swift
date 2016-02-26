//
//  RestRequest.swift
//  CardinalHealth
//
//  Created by Alexander Volkov on 07.04.15.
//  Copyright (c) 2015 TopCoder. All rights reserved.
//

import Foundation

/**
* HTTP methods for requests
*/
enum RestMethod: String {
    case OPTIONS = "OPTIONS"
    case GET = "GET"
    case HEAD = "HEAD"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    case TRACE = "TRACE"
    case CONNECT = "CONNECT"
}

/**
Content types that the server supports
*/
enum ContentType: String {
    case JSON = "application/json"
    case OTHER = ""
}

/**
* Class stores data for HTTP request
*
* @author Alexander Volkov
* @version 1.0
*/
class RestRequest {
    
    /// specific Base URL to use. If empty, then default Base URL is used (from configuration)
    var baseUrl = ""
    
    /// specific accessToken. If empty, then default accessToken is used (from RestApi)
    var accessToken: String?
    /*
    By default all services should return JSON formatted response.
    If another format is needed, it can be added to ContentType enum.
    */
    var responseType = ContentType.JSON
    
    /// the endpoint to request
    var endpoint = ""
    
    /// HTTP method
    var method: RestMethod!
    
    /// HTTP parameters to use
    var parameters: [String : AnyObject]?
    
    /// Additional HTTP headers
    var headers: [String : String]?
    
    /**
    flag: true - need to log request body when send, false - do not log the request body
    (used when body is large or contains binary data
    */
    var needToLogBody = true
    
    init(){}
    
    /**
    Create new instance of RestRequest.
    
    :param: method   HTTP method to use in HTTP request.
    :param: endpoint the endpoint - suffix for the URL that is constructed from "BaseURL",
    content type and token parameter and the endpoint
    
    :returns: RestRequest
    */
    init(_ method: RestMethod, _ endpoint: String) {
        self.method = method
        self.endpoint = endpoint
    }
    
    /**
    Build the URL to request from pieces: Base URL, endpoint.
    
    :param: defaultBaseUrl the default Base URL used in the app. If the request is not equipped with baseUrl,
        then this default Base URL will be used.
    
    :returns: the URL for HTTP request
    */
    func buildFullUrl(defaultBaseUrl: String) -> String {
        var base = defaultBaseUrl
        if baseUrl != "" {
            base = baseUrl
        }
        return base + endpoint
    }
}