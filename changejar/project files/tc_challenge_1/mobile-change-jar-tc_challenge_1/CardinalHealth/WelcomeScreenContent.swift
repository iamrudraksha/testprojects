//
//  WelcomeScreenContent.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 22.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Model for a content in Welcome Screen
*
* @author Alexander Volkov
* @version 1.0
*/
class WelcomeScreenContent: NSObject {

    var contentImage: UIImage?
    var title: String?
    var contentText: String?
    var boldText: String?
    
    /**
    Parses given JSON into WelcomeScreenContent
    
    :param: data JSON data
    
    :returns: WelcomeScreenContent instance
    */
    init(data: JSON) {
        super.init()
        
        title = data["title"].string
        contentText = data["contentText"].string
        boldText = data["boldText"].string
        
        if let imageString: String = data["bgImage"].string {
            if let image = UIImage(named: imageString) {
                contentImage = image
            }
        }
    }
    
    /**
    Get data for all welcome screens
    
    :returns: the list
    */
    class func getPredefinedData() -> [WelcomeScreenContent] {
        var predefinedData = [WelcomeScreenContent]()
        
        let path = NSBundle.mainBundle().pathForResource("WelcomScreenData", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!, options: .DataReadingMappedIfSafe, error: nil)
        let json = JSON(data: jsonData!)

        for (key: String, screenJSON: JSON) in json {
            predefinedData.append(WelcomeScreenContent(data: screenJSON))
        }
        
        return predefinedData
    }
}