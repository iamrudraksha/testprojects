//
//  LoggerListener.swift
//  CardinalHealth
//
//  Created by Alexander Volkov on 07.04.15.
//  Copyright (c) 2015 TopCoder. All rights reserved.
//

import Foundation


// notification types
enum LoggerNotifications: String {
    case Request = "LoggerNotifications.Request"
    case Error = "LoggerNotifications.Error"
    case Response = "LoggerNotifications.Response"
}

/// the queue used to print log messages
private let logQueue : dispatch_queue_t = dispatch_queue_create("Logger", DISPATCH_QUEUE_SERIAL)

/**
* Observer notifications for Logger
*
* @author Alexander Volkov
* @version 1.0
*/
class LoggerListener: NSObject {
    
    // flag - the state of the listening notifications
    var isListening: Bool = false
    
    class var sharedInstance: LoggerListener {
        struct Static {
            static let instance : LoggerListener = LoggerListener()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        isListening = true
        addObservers()
    }
    
    /**
    start listenning the log
    */
    func start() {
        isListening = true;
    }
    
    /**
    stop listenning the log
    */
    func stop() {
        isListening = false
    }
    
    func receivedInfoLogNotication(notification: NSNotification) {
        if self.isListening {
            if let object: AnyObject = notification.object {
                Logger.infoLog(object.description)
            }
            else {
                Logger.infoLog("<empty info notification>")
            }
        }
    }
    
    func receivedErrorLogNotification(notification: NSNotification) {
        if self.isListening {
            if let object: AnyObject = notification.object {
                if let error = object as? RestError {
                    // Log parts of RestError with different loger levels
                    if let code = error.responseStatusCode {
                        Logger.errorLog("RestError[errorObject=\(error.errorObject), responseStatusCode=\(code)" +
                            ", <see DEBUG level for errorMsg field>]")
                        Logger.logDebug("RestError[...,errorMsg=\(error.errorMsg)]")
                        return
                    }
                }
                Logger.errorLog(object.description)
            }
            else {
                Logger.errorLog("<empty error notification>")
            }
        }
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInfoLogNotication:",
            name: LoggerNotifications.Request.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedErrorLogNotification:",
            name: LoggerNotifications.Error.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInfoLogNotication:",
            name: LoggerNotifications.Response.rawValue, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


/**
* Class for writting log to the standard output.
* To start print logs into a console: LoggerListener.sharedInstance.start()
*
* @author Alexander Volkov
* @version 1.0
*/
class Logger: NSObject {
    
    /// possible logger levels
    enum LogLevel : NSInteger {
        case DEBUG = 0, INFO, WARN, ERROR, FATAL, OFF
    }
    
    /// current logger lovel. Initially obtained from the configuration.
    class var logLevel : NSInteger {
        return Configuration.sharedConfig.loggingLevel
    }
    
    /**
    Log message with DEBUG level
    
    :param: log the log message
    */
    class func logDebug(log : NSString) {
        if Logger.logLevel <= LogLevel.DEBUG.rawValue {
            __LINE__
            var logMsg = "[\(__FILE__)][\(__LINE__)][Debug] : \(log)"
            Logger.log(logMsg)
        }
    }
    
    /**
    Log message with INFO level
    
    :param: log the log message
    */
    class func infoLog(log: String) {
        if Logger.logLevel <= LogLevel.INFO.rawValue {
            var logMsg = "[Info] : \(log)"
            Logger.log(logMsg)
        }
    }
    
    /**
    Log message with WARN level
    
    :param: log the log message
    */
    class func warnLog(log: String) {
        if Logger.logLevel <= LogLevel.WARN.rawValue {
            var logMsg = "[Warning] : \(log)"
            Logger.log(logMsg)
        }
    }
    
    /**
    Log message with ERROR level
    
    :param: log the log message
    */
    class func errorLog(log: String) {
        if Logger.logLevel <= LogLevel.ERROR.rawValue {
            var logMsg = "[ERROR] : \(log)"
            Logger.log(logMsg)
        }
    }
    
    /**
    Log message with FATAL level
    
    :param: log the log message
    */
    class func fatalLog(log: String) {
        if Logger.logLevel <= LogLevel.FATAL.rawValue {
            var logMsg = "[FATAL] : \(log)"
            Logger.log(logMsg)
        }
    }
    
    /**
    Print given log message into the console in a separate queue
    
    :param: log the log message
    */
    internal class func log (log : String) {
        dispatch_async(logQueue, { () -> Void in
            println(log)
        });
    }
}