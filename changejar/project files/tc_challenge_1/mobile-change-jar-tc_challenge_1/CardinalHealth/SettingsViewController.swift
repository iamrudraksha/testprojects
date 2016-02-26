//
//  SettingsViewController.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 25.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Settings screen
*
* @author Alexander Volkov
* @version 1.0
*/
class SettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.delegate = self
        initNavigation()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initNavigation()
        emailField.becomeFirstResponder()
        emailField.text = LastUserInfo?.email ?? ""
    }
    
    /**
    Initialize navigation bar
    */
    func initNavigation() {
        initNavigationBarTitle("SETTINGS".localized().uppercaseString)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Save".localized(), style: UIBarButtonItemStyle.Plain, target: self, action: "saveEmail:")]
        initBackButtonFromChild()
    }
    
    /**
    Dismiss the keyboard
    
    :param: textField the textField
    
    :returns: true
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        return true
    }
    
    /**
    Validate and save email
    
    :param: sender the button
    */
    func saveEmail(sender: AnyObject) {
        let email = emailField.text
        if !ValidationUtils.validateEmail(email, { (error: RestError, res: RestResponse?) -> () in
            error.showError()
        }) {
            return
        }
        NSUserDefaults.standardUserDefaults().setObject(email, forKey: kUserEmail)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Save email
        LastUserInfo?.email = email
        LastUserInfo?.userName = email // TODO Remove. This is just for demonstration.
        
        IdeasListViewControllerNeedToReload = true
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Keyboard events
    
    /**
    Override to start listen keyboard events
    
    :param: animated flag whether the view is animated when appear
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for keyboard events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Override to stop listen keyboard events
    
    :param: animated flag whether the view is animated when disappear
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Keyboard appear event handler
    
    :param: notification the notification object that contains keyboard size
    */
    func keyboardWillShow(notification: NSNotification) {
        
        if self.emailField?.isFirstResponder() ?? false {
            KeyboardDismissingUIViewTarget = self.emailField
        }
    }
    
    /**
    Keyboard disappear event handler. Rollback all changes in the scrollView
    
    :param: notification the notification object
    */
    func keyboardWillHide(notification: NSNotification) {
        KeyboardDismissingUIViewTarget = nil
    }
}
