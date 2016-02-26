//
//  SettingsViewController.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 25.06.15.
//  Modified by Volkov Alexander on 16.07.15.
//  Modified by Volkov Alexander on 22.09.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Settings screen
*
* @author Alexander Volkov
* @version 1.1
* changes:
* 1.1:
* - alternative screen closure implemented
* 1.2:
* - keyboard issue fix
*/
class SettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var showWelcomScreen: UISwitch!
    
    /*
    Optional callback that will be used to remove the screen.
    If not specified, then the view controller will be popped from the navigation view controller
    */
    var closeCallbackAfterSave: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.delegate = self
        initNavigation()
        
        showWelcomScreen.setOn(isAlwaysShowWelcomeScreen(), animated: false)
    }
    
    @IBAction func showWelcomeScreenAction(sender: AnyObject) {
        setAlwaysShowWelcomeScreen(showWelcomScreen.on)
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
        if closeCallbackAfterSave == nil {
            initBackButtonFromChild()
        }
    }
    
    /**
    Dismiss the keyboard
    
    - parameter textField: the textField
    
    - returns: true
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        return true
    }
    
    /**
    Validate and save email
    
    - parameter sender: the button
    */
    func saveEmail(sender: AnyObject) {
        let email = emailField.text!
        if email.trim() == "" {
            showAlert("EMAIL_REQUIRED".localized(), message: "EMAIL_EMPTY".localized())
            return
        }
        if !ValidationUtils.validateEmail(email, { (error: RestError, res: RestResponse?) -> () in
            error.showError()
        }) {
            return
        }
        NSUserDefaults.standardUserDefaults().setObject(email, forKey: kUserEmail)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Save email
        if LastUserInfo == nil {
            LastUserInfo = UserInfo(userName: email)
        }
        LastUserInfo?.email = email
        LastUserInfo?.userName = email // TODO Remove. This is just for demonstration.
        
        IdeasListViewControllerNeedToReload = true
        if let callback = closeCallbackAfterSave {
            callback()
        }
        else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    /**
    Validate and save email
    
    - parameter sender: dismiss keyboard event
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true)
    }
    
}
