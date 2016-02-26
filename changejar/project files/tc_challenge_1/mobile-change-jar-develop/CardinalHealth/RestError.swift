//
//  RestError.swift
//  CardinalHealth
//
//  Created by Alexander Volkov on 07.04.15.
//  Copyright (c) 2015 TopCoder. All rights reserved.
//

import Foundation

/**
Possible error codes

- UnknownError:   any error type that is not covered by other RestErrorCode cases
- NetworkError:   an error from raw network/REST services
- RequestError:   an error related to REST request
- ParameterError: an error related to wrong method usage, e.g. a wrong parameter was specified
- CommonError:    an error that  is created from a string or NSError and which has any kind of
human-readable information
*/
enum RestErrorCode: Int {
    case UnknownError = 1000
    case NetworkError
    case RequestError
    case ParameterError
    case CommonError
}


/// Common error message for the cases when the response was unexpected format
let ERROR_UNKNOWN_RESPONSE_FORMAT = "Unknown response format"

/**
* Object representation of an error
*
* @author Alexander Volkov
* @version 1.0
*/
class RestError {
    
    /// error code type
    var errorCode: RestErrorCode?
    
    /// human-readable message
    var errorMsg: String?
    
    /// related object
    var errorObject: AnyObject?
    
    /// HTTP response body in JSON format (if the error returned from the server)
    var jsonResponse: JSON?
    
    /// response HTTP code
    var responseStatusCode: Int?
    
    /// helper variable to get full info about the error
    var description: String {
        get {
            return self.toString()
        }
    }
    /**
    Create RestError instance that represents an error related to wrong parameter provided to a method.
    
    - parameter paramName: the name of the parameter
    
    - returns: RestError instance
    */
    class func parameterError(paramName: String) -> RestError {
        return RestError.parameterError(paramName, errorMessage: nil)
    }
    
    /**
    Create RestError instance that represents an error related to wrong parameter provided to a method.
    
    - parameter paramName:    the name of the parameter
    - parameter errorMessage: optional additional error message
    
    - returns: RestError instance
    */
    class func parameterError(paramName: String, errorMessage:String?) -> RestError {
        let error = RestError()
        error.errorCode = .ParameterError
        error.errorMsg = "Parameter error: \(paramName)" + (errorMessage != nil ? ". \(errorMessage)" : "")
        return error
    }
    
    /**
    Converts NSError to RestError instance.
    
    - parameter nsError: NSError obtained from lower levels of the framework
    
    - returns: RestError instance
    */
    class func errorFromNSError(nsError: NSError) -> RestError {
        let error = RestError()
        error.errorCode = .CommonError
        error.errorMsg = nsError.localizedDescription
        return error
    }
    
    /**
    Create RestError instance that represents "unknown response" error
    
    - returns: RestError instance
    */
    class func errorUnknownResponseFormat() -> RestError {
        let error = RestError()
        error.errorCode = .CommonError
        error.errorMsg = ERROR_UNKNOWN_RESPONSE_FORMAT
        return error
    }
    
    /**
    Create and post error notification with given errorMessage
    
    - parameter errorMessage: error message
    
    - returns: the error
    */
    class func errorWithMessage(errorMessage: String) -> RestError {
        let error = RestError()
        error.errorCode = .CommonError
        error.errorMsg = errorMessage
        NSNotificationCenter.defaultCenter().postNotificationName(LoggerNotifications.Error.rawValue,
            object: error.errorMsg)
        return error
    }
    
    /**
    setup an error from the http response
    
    - parameter responseData:
    - parameter statusCode:
    
    - returns: the error
    */
    class func errorFromResponse(responseData: NSData?, statusCode: Int) -> RestError {
        let error = RestError()
        if responseData != nil {
            
            var jsonParseError: NSError?
            let json = JSON(data: responseData!, options: NSJSONReadingOptions.MutableContainers,
                error: &jsonParseError)
            
            
            if jsonParseError == nil {
                error.errorObject = try? NSJSONSerialization.JSONObjectWithData(responseData!,
                    options: NSJSONReadingOptions.MutableContainers)
                if let errorMsg = json["error"].string {
                    error.errorMsg = errorMsg;
                }
                
                if let errorMsg = json["description"].string {
                    error.errorMsg = errorMsg
                }
                
                if let errorMsg = json["error"].string {
                    error.errorMsg = errorMsg
                }
                
                if error.errorMsg == nil {
                    error.errorMsg = "nil"
                }
                NSNotificationCenter.defaultCenter().postNotificationName(LoggerNotifications.Error.rawValue,
                    object: error.errorMsg)
            }
            
            /**
            * if the response is not a json object or can not find description of the error
            * take the plainText as the error description
            */
            if error.errorMsg == nil {
                if let responseText = NSString(data: responseData!, encoding: NSUTF8StringEncoding) {
                    error.errorMsg = responseText as String
                }
            }
        } else {
            error.errorCode = .UnknownError
            error.errorMsg = "response is empty"
        }
        
        error.errorCode = .RequestError
        error.responseStatusCode = statusCode
        
        return error
    }
    
    /**
    Method that creates a string with all inner object variables listed
    
    - returns: a string
    */
    func toString() -> String {
        return "RestError[errorCode=\(errorCode), errorMsg=\(errorMsg), errorObject=\(errorObject)," +
        " responseStatusCode=\(responseStatusCode)]"
    }
    
    /**
    Get human readable message
    
    - returns: the error message
    */
    func getMessage() -> String {
        if let errorMessage = self.errorMsg {
            return errorMessage
        }
        else {
            return toString()
        }
    }
}

/**
* Shortcut methods for common tasks
*/
extension RestError {
    
    /**
    Show alert with localized error message
    */
    func showError() {
        showAlert("Error".localized(), message: self.getMessage())
    }
}