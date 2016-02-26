//
//  UserInfo.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 23.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/// the key for user's email
let kUserEmail = "kUserEmail";

/// Current user data
var LastUserInfo: UserInfo?

/**
* A representation of the user account data.
* Stores email.
*
* @author Alexander Volkov
* @version 1.0
*/
class UserInfo {
 
    /// full name of the user
    var userName: String
    
    /// Email of the user
    var email: String = ""
    
    /// user's title
    var userTitle: String = ""
    
    /// the URL string of the profile icon
    var imageUrl: String?
    
    /// cached image obtained using getProfileImage() method
    var cachedProfileImage: UIImage?
    
    init(userName: String) {
        self.userName = userName
    }
    
    /**
    Get profile image if possible.
    Reuses cached image.
    
    :param: callback the callback block to return the image
    */
    func getProfileImage(callback: (UIImage)->()) {
        if let image = cachedProfileImage {
            callback(image)
        }
        else {
            UIImage.loadAsync(self.imageUrl, callback: { (image: UIImage) -> () in
                self.cachedProfileImage = image
                callback(image)
            })
        }
    }
}