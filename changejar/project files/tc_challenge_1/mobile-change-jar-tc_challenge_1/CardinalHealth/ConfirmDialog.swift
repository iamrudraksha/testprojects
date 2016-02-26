//
//  ConfirmDialog.swift
//  CardinalHealth
//
//  Created by Alexander Volkov on 12.12.14.
//  Copyright (c) 2014 Appirio, Inc. All rights reserved.
//

import UIKit

/**
* Provides easy API for Confirmation Dialog.
*
* @author Alexander Volkov
* @version 1.0
*/
class ConfirmDialog: NSObject, UIAlertViewDelegate {
    
    /// the action to be processed after confirmation
    let action: ()->()
    
    /// optional block to invoke when user cancels the confirmation
    var cancelled: (()->())?
    
    /// dialog reference
    let refreshAlert: UIAlertView
    
    /**
    Open Confirmation dialog with given title, text and action.
    
    :param: title         the dialog title
    :param: text          the message to show
    :param: action        action block
    :param: okButtonTitle optional "OK" button title
    
    :returns: ConfirmDialog instance that must be saved in a variable
    */
    init(title: String, text:  String, action: ()->(), _ okButtonTitle: String = "OK".localized()) {
        self.action = action
        self.refreshAlert = UIAlertView()
        super.init()
        
        refreshAlert.title = title
        refreshAlert.message = text
        refreshAlert.addButtonWithTitle("Cancel".localized())
        refreshAlert.delegate = self
        refreshAlert.addButtonWithTitle(okButtonTitle)
        dispatch_async(dispatch_get_main_queue(), {
            self.refreshAlert.show()
        });
    }
    
    /**
    Save as previous init method, but this takes cancel callback block
    
    :param: title  the dialog title
    :param: text   the message to show
    :param: cancelled cancel callback block
    :param: action action block
    
    :returns: ConfirmDialog instance that must be saved in a variable
    */
    convenience init(title: String, text:  String, cancelled: ()->(), action: ()->()) {
        self.init(title:title, text:text, action:action)
        self.cancelled = cancelled
    }
    
    /**
    UIAlertViewDelegate implementation
    
    :param: alertView   the view
    :param: buttonIndex tapped button index
    */
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            action()
        }
        else {
            cancelled?()
        }
    }
}