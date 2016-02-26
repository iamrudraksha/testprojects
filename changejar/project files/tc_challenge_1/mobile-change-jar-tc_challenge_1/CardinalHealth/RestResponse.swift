//
//  RestResponse.swift
//  CardinalHealth
//
//  Created by Alexander Volkov on 07.04.15.
//  Copyright (c) 2015 TopCoder. All rights reserved.
//

import Foundation

/**
* Object representation of a HTTP Response.
*
* @author Alexander Volkov
* @version 1.0
*/
class RestResponse {
    
    // HTTP headers
    var headers: Dictionary<String,String>?
    
    // Parsed response body
    var responseObject: AnyObject?
    
    // an occurred error during the HTTP request
    var error: NSError?
    
    // the HTTP result code
    var statusCode: Int?
    
    // the Mime type of the received content
    var mimeType: String?
    
    // the requested URL
    var URL: NSURL?
    
    init(responseObject : AnyObject?) {
        self.responseObject = responseObject;
    }
    
}