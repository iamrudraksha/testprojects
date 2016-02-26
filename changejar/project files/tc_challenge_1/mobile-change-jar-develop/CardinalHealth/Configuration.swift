//
//  Configuration.swift
//  CardinalHealth
//
//  Created by Alexander Volkov on 19.04.15.
//  Modified by Volkov Alexander on 16.07.15.
//  Copyright (c) 2015 Appirio. All rights reserved.
//

import Foundation

/**
* Configuration reads config from configuration.plist in the app bundle
*
* @author Alexander Volkov
* @version 1.1
* changes:
* 1.1:
* - new parameters: servicePassword, serviceId
*/
class Configuration: NSObject {
    
    /// Base URL for API. Has default value.
    var apiBaseUrl = "http://localhost:8888/"
    
    /// the service passwords (used in HTTPS header)
    var servicePassword = "password"
    
    /// the service ID (used in HTTPS header)
    var serviceId = "id"
    
    /// the log level of the Logger. Default value 1 (INFO)
    var loggingLevel: NSInteger = 1
    
    /// shared instance of Configuration (singleton)
    class var sharedConfig: Configuration {
        struct Static {
            static let instance : Configuration = Configuration()
        }
        return Static.instance
    }
    
    /**
    Reads configuration file
    */
    override init() {
        super.init()
        self.readConfigs()
    }
    
    // MARK: private methods
    
    /**
    * read configs from plist
    */
    func readConfigs() {
        if let path = getConfigurationResourcePath() {
            let configDicts = NSDictionary(contentsOfFile: path)
            
            if let url = configDicts?["apiBaseUrl"] as? String {
                var clearUrl = url.trim()
                if !clearUrl.isEmpty {
                    if clearUrl.hasPrefix("http") {
                        // Fix "/" at the end if needed
                        if !clearUrl.hasSuffix("/") {
                            clearUrl += "/"
                        }
                        self.apiBaseUrl = clearUrl
                    }
                }
            }
            if let servicePassword = configDicts?["servicePassword"] as? String {
                self.servicePassword = servicePassword
            }
            if let serviceId = configDicts?["serviceId"] as? String {
                self.serviceId = serviceId
            }
            if let level = configDicts?["loggingLevel"] as? NSNumber {
                self.loggingLevel = level.integerValue
            }
        }
        else {
            assert(false, "configuration is not found")
        }
    }
    
    /**
    Get the path to the configuration.plist.
    
    - returns: the path to configuration.plist
    */
    func getConfigurationResourcePath() -> String? {
        return NSBundle(forClass: Configuration.classForCoder()).pathForResource("configuration", ofType: "plist")
    }
}