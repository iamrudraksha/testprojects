//
//  ValidationUtils.swift
//  CardinalHealth
//
//  Created by Alexander Volkov on 07.04.15.
//  Modified by Volkov Alexander on 16.07.15.
//  Copyright (c) 2015 TopCoder. All rights reserved.
//

import Foundation

/**
* Validation utilities. Helps to check parameters in service methods before sending HTTP request.
*
* @author Alexander Volkov
* @version 1.1
* changes:
* 1.1:
* - email validation message fix
*/
class ValidationUtils {
    
    /**
    Check URL for correctness and callback failure if it's not.
    
    - parameter url:     the URL to check
    - parameter failure: the closure to invoke if validation fails
    
    - returns: true if URL is correct
    */
    class func validateUrl(url: String?, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        if url == nil || url == "" {
            failure?(RestError.errorWithMessage("Empty URL"), nil)
            return false
        }
        if !url!.hasPrefix("http") {
            failure?(RestError.errorWithMessage("URL should start with \"http\""), nil)
            return false
        }
        return true
    }
    
    /**
    Check 'string' if it's correct ID.
    Delegates validation to two other methods.
    
    - parameter id:      the id string to check
    - parameter failure: the closure to invoke if validation fails
    
    - returns: true if string is not empty
    */
    class func validateId(id: String, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        if !ValidationUtils.validateStringNotEmpty(id, failure) { return false }
        if id.isNumber() && !ValidationUtils.validatePositiveNumber(id, failure) { return false }
        return true
    }
    
    /**
    Check 'string' if it's empty and callback failure if it is.
    
    - parameter string:  the string to check
    - parameter failure: the closure to invoke if validation fails
    
    - returns: true if string is not empty
    */
    class func validateStringNotEmpty(string: String, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        if string.isEmpty {
            failure?(RestError.errorWithMessage("Empty string"), nil)
            return false
        }
        return true
    }
    
    /**
    Check if the string is positive number and if not, then callback failure and return false.
    
    - parameter numberString: the string to check
    - parameter failure:      the closure to invoke if validation fails
    
    - returns: true if given string is positive number
    */
    class func validatePositiveNumber(numberString: String, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        if !numberString.isPositiveNumber() {
            failure?(RestError.errorWithMessage("Incorrect number: \(numberString)"), nil)
            return false
        }
        return true
    }
    
    /**
    Check if the string represents email
    
    - parameter email:   the text to validate
    - parameter failure: the closure to invoke if validation fails

    - returns: true if the given string is a valid email
    */
    class func validateEmail(email: String, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        let emailPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        if email.trim() ≈ emailPattern {
            return true
        }
        var message = "EMAIL_FORMAT".localized().replace("%email%", withString: email)
        if email.trim() == "" {
            message = message.replace(":", withString: "")
        }
        failure?(RestError.errorWithMessage(message), nil)
        return false
    }
}

/**
*  Helper class for regular expressions
*
* @author Alexander Volkov
* @version 1.0
*/
class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        self.internalExpression = try! NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: [],
            range:NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}

// Define operator for simplisity of Regex class
infix operator ≈ { associativity left precedence 140 }
func ≈(input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}