//
//  HelpfulFunctions.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 22.06.15.
//  Modified by Volkov Alexander on 16.07.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
A set of helpful functions and extensions
*/

/**
*  Fonts used in the app
*/
struct Fonts {
    static let regular = "SourceSansPro-Regular"
    static let semibold = "SourceSansPro-Semibold"
    static let bold = "SourceSansPro-Bold"    
    static let italic = "SourceSansPro-It"
    static let lightItalic = "SourceSansPro-LightIt"
    static let light = "SourceSansPro-Light"
}

/**
*  Colors used in the app
*/
struct Colors {
    static let darkGray = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    static let gray = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    static let lightGray = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1)
    static let yellow = UIColor(red: 255/255, green: 161/255, blue: 0/255, alpha: 1)
    static let red = UIColor(red: 228/255, green: 31/255, blue: 53/255, alpha: 1)
}

/**
* Extenstion adds helpful methods to String
*
* @author Alexander Volkov
* @version 1.0
*/
extension String {
    
    /**
    Get string without spaces at the end and at the start.
    
    - returns: trimmed string
    */
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    /** Checks if string contains given substring
    
    - returns: true if the string contains given substring
    */
    func contains(substring: String) -> Bool{
        if let _ = self.rangeOfString(substring){
            return true
        }
        return false
    }
    
    /**
    Shortcut method for stringByReplacingOccurrencesOfString
    
    - parameter target:     the string to replace
    - parameter withString: the string to add instead of target
    
    - returns: a result of the replacement
    */
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString,
            options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    /**
    Checks if the string is number
    
    - returns: true if the string presents number
    */
    func isNumber() -> Bool {
        let formatter = NSNumberFormatter()
        if let _ = formatter.numberFromString(self) {
            return true
        }
        return false
    }
    
    /**
    Checks if the string is positive number
    
    - returns: true if the string presents positive number
    */
    func isPositiveNumber() -> Bool {
        let formatter = NSNumberFormatter()
        if let number = formatter.numberFromString(self) {
            if number.doubleValue > 0 {
                return true
            }
        }
        return false
    }
    
    /**
    Get URL encoded string.
    
    - returns: URL encoded string
    */
    public func urlEncodedString() -> String {
        let set = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet;
        set.removeCharactersInString(":?&=@+/'");
        return self.stringByAddingPercentEncodingWithAllowedCharacters(set as NSCharacterSet)!
    }
    
    /**
    Get a localized string
    
    - returns: the localized string.
    */
    func localized() -> String {
        return NSLocalizedString(self, comment: self)
    }
}

/**
*  Common date parsers
*/
struct FullDateParsers {
    static var dateParser: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // if hours are [0-23]
        f.locale = NSLocale.currentLocale()
        return f
        }()
    static var dateStringLength = 19
}

extension NSDate {
    
    /**
    Returns now many hours, minutes, etc. the date is from now.
    
    - returns: string, e.g. "5 hours ago"
    */
    func timeToNow() -> String {
        let timeInterval = NSDate().timeIntervalSinceDate(self)

        let days = Int(floor(timeInterval / (3600 * 24)))
        let hours = Int(floor((timeInterval % (3600 * 24)) / 3600))
        let minutes = Int(floor((timeInterval % 3600) / 60))
        let seconds = Int(timeInterval % 60)
        
        if days > 0 { return days == 1 ? "\(days) " + "DAY_AGO".localized() : "\(days) " + "DAYS_AGO".localized() }
        if hours > 0 { return hours == 1 ? "\(hours) " + "HOUR_AGO".localized() : "\(hours) " + "HOURS_AGO".localized() }
        if minutes > 0 { return minutes == 1 ? "\(minutes) " + "MIN_AGO".localized() : "\(minutes) " + "MINS_AGO".localized() }
        if seconds > 0 { return seconds == 1 ? "\(seconds) " + "SEC_AGO".localized() : "\(seconds) " + "SECS_AGO".localized() }
        return "JUST_NOW".localized()
    }
    
    /**
    Parse full date string, e.g. 2014-11-17T19:39:12
    
    - parameter string: the date string
    
    - returns: date object or nil
    */
    class func parseFullDate(var string: String) -> NSDate? {
        string = string.substringToIndex(string.startIndex.advancedBy(FullDateParsers.dateStringLength))
        return FullDateParsers.dateParser.dateFromString(string)
    }
}

extension Bool {
    
    /**
    Get random boolean value.
    
    - returns: random value
    */
    static func random() -> Bool {
        return arc4random_uniform(10) > 5
    }
}

/**
Check if iPhone5 like device

- returns: true - if this device has width as on iPhone5, false - else
*/
func isIPhone5() -> Bool {
    return UIScreen.mainScreen().nativeBounds.width == 640
}

/**
Shows an alert with the title and message.

- parameter title:   the title
- parameter message: the message
*/
func showAlert(title: String, message: String) {
    let myAlertView = UIAlertView()
    myAlertView.title = title
    myAlertView.message = message
    myAlertView.addButtonWithTitle("OK".localized())
    myAlertView.show()
}

/**
Delays given callback invokation

- parameter time:     the delay in seconds
- parameter callback: the callback to invoke after 'delay' seconds
*/
func delay(delay: NSTimeInterval, callback: ()->()) {
    let delay = delay * Double(NSEC_PER_SEC)
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay));
    dispatch_after(popTime, dispatch_get_main_queue(), {
        callback()
    })
}

/**
Check if something was activated for the first time

- parameter key:  the key for the event/action

- returns: true - if need to do something extra as this is the first time, false - else
*/
func isFirstTime(key: String) -> Bool {
    if NSUserDefaults.standardUserDefaults().boolForKey(key) {
        return false
    }
    return true
}

/**
Check if always need to show Welcom Screen during the start.
Default - true

- returns: true - if need to show Welcome Screen each time the app is launched, false - else
*/
func isAlwaysShowWelcomeScreen() -> Bool {
    return NSUserDefaults.standardUserDefaults().objectForKey(kAlwaysShowWelcomeScreen) as? Bool ?? true
}

func setAlwaysShowWelcomeScreen(show: Bool) {
    NSUserDefaults.standardUserDefaults().setObject(show, forKey: kAlwaysShowWelcomeScreen)
    NSUserDefaults.standardUserDefaults().synchronize()
}

/**
Updates NSUserDefaults and saves a flag to mark that corresponding event is not first time

- parameter key:  the key for the event/action
*/
func updateNotFirstTime(key: String) {
    NSUserDefaults.standardUserDefaults().setObject(true, forKey: key)
    NSUserDefaults.standardUserDefaults().synchronize()
}
