//
//  SubmitIdeaViewController.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 24.06.15.
//  Modified by Volkov Alexander on 16.07.15.
//  Modified by Volkov Alexander on 22.09.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Submit Idea form
*
* @author Alexander Volkov
* @version 1.1
* changes:
* 1.1:
* - equal font size for all fields
* - unused switcher removed
* - only user's email is shown, but support for profile image is leaved
* 1.2:
* - keyboard issue fix
*/
class SubmitIdeaViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    /// the limit for the idea text
    let CHARACTERS_LIMIT = 160
    
    /// margins for name for different cases (has icon/has no icon)
    let NAME_LEFT_MARGIN_HAS_ICON: CGFloat = 46
    let NAME_LEFT_MARGIN_NO_ICON: CGFloat = 0
    
    let ERROR_EMPTY_STRING = "ERROR_EMPTY_STRING".localized()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var lineHeight: [NSLayoutConstraint]!
    @IBOutlet weak var loadingIndicatorView: UIView!
    
    // Name
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var nameSwitcher: UISwitch!
    
    @IBOutlet weak var userDataView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var charactersLimitLabel: UILabel!
    @IBOutlet weak var ideaTextView: UITextView!
    
    /// last edited text field or view
    var lastTextField: UIView?
    
    /// the text in text view before editing
    var textPlaceholderText: String = ""
    
    /// reference to opened ConfirmDialog
    var confirmDialog: ConfirmDialog?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleField.delegate = self
        ideaTextView.delegate = self
        textPlaceholderText = ideaTextView.text
        
        fixUI()
        initNavigation()
        updateUI()
    }
    
    /**
    Init navigation and focus on idea title automatically
    
    - parameter animated: the animation flag
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initNavigation()
        titleField.becomeFirstResponder()
    }
    
    /**
    Fixes UI constraints
    */
    func fixUI() {
        for c in lineHeight {
            c.constant = 0.5 // create more thin lines
        }
    }
    
    /**
    Initialize navigation bar
    */
    func initNavigation() {
        initNavigationBarTitle("SUBMIT_IDEAS".localized().uppercaseString)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Submit".localized(), style: UIBarButtonItemStyle.Plain, target: self, action: "submitAction:")]
        initBackButtonFromChild()
    }
    
    /**
    Update user info
    */
    func updateUI() {
        if let info = LastUserInfo {
            nameLabel.text = info.userName
            titleLabel.text = info.userTitle
            icon.image = nil
            icon.layer.cornerRadius = icon.bounds.width/2
            icon.layer.masksToBounds = true
            nameLeftMargin.constant = NAME_LEFT_MARGIN_NO_ICON
            info.getProfileImage({ (image: UIImage) -> () in
                self.icon.image = image
                self.nameLeftMargin.constant = self.NAME_LEFT_MARGIN_HAS_ICON
            })
        }
        else {
            print("ERROR: Trying to submit without authentication")
        }
    }
    
    /**
    "Show name" switcher action handler
    
    - parameter sender: the switcher
    */
    @IBAction func showNameSwitcherAction(sender: AnyObject) {
        userDataView.alpha = nameSwitcher.on ? 1 : 0.3
    }
    
    /**
    "Submit" button action handler
    
    - parameter sender: the button
    */
    func submitAction(sender: AnyObject) {
        self.titleField.resignFirstResponder()
        self.ideaTextView.resignFirstResponder()
        
        let ideaTitle = titleField.text!
        var ideaText = ideaTextView.text!
        if ideaText.trim() == textPlaceholderText {
            ideaText = ""
        }
        
        // Validate the fields
        let errorCallback = { (error: RestError, res: RestResponse?) -> () in
            showAlert("Error".localized(), message: self.ERROR_EMPTY_STRING)
        }
        if !ValidationUtils.validateStringNotEmpty(ideaTitle, errorCallback) { return }
        if !ValidationUtils.validateStringNotEmpty(ideaText, errorCallback) { return }
        if ideaText.characters.count > CHARACTERS_LIMIT {
            let errorMessage = "ERROR_CHARACTER_LIMIT".localized().replace("%number%", withString: CHARACTERS_LIMIT.description)
            showAlert("Error".localized(), message: errorMessage)
            return
        }
        
        // Submit
        let idea = IdeaData()
        idea.title = ideaTitle
        idea.text = ideaText
        if nameSwitcher.on {
            idea.submitter = LastUserInfo?.userName ?? ""
            idea.submitterTitle = LastUserInfo?.userTitle ?? ""
        }
        idea.submitterEmail = LastUserInfo?.email ?? ""
        loadingIndicatorView.hidden = false
        IdeasDataSource.sharedInstance.addIdea(idea, callback: { (idea: Idea) -> () in
            
            self.loadingIndicatorView.hidden = true
            // Show Thanks Screen
            if let vc = self.create(ThankViewController.self) {
                vc.parent = self
                RootViewControllerSingleton!.showViewControllerFromBottom(vc)
            }
            
        }) { (error: RestError, res: RestResponse?) -> () in
            self.loadingIndicatorView.hidden = true
            error.showError()
        }
        
    }

    /**
    Check changes and confirm to close
    */
    override func backButtonAction() {
        self.titleField.resignFirstResponder()
        self.ideaTextView.resignFirstResponder()
        noChanges { () -> () in
            super.backButtonAction()
        }
    }
    
    /**
    Check if there are changes in the form and ask user to confirm the closing
    
    - parameter callback: the action to invoke when confirmed by the user
    */
    private func noChanges(callback: ()->()) {
        if hasChanges() {
            self.confirmDialog = ConfirmDialog(title: "ALERT_TITLE_UNSAVED_CHANGES".localized(),
                text: "ALERT_TEXT_UNSAVED_CHANGES".localized(),
                action: callback, "YES".localized())
            return
        }
        callback()
    }
    
    /**
    Check if the form has been changed
    
    - returns: true - has changes, false - else
    */
    func hasChanges() -> Bool {
        return !titleField.text!.trim().isEmpty
        || ideaTextView.text.trim() != textPlaceholderText
        || !nameSwitcher.on
    }
    
    // MARK: UITextFieldDelegate, UITextViewDelegate
    
    /**
    Dismiss the keyboard
    
    - parameter textField: the textField
    
    - returns: true
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
    Change color of the character limit label to red when the limit exceeded.
    
    - parameter textView: the textView
    - parameter range:    the rande of the text to update
    - parameter text:     the text to replace in range
    
    - returns: true
    */
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let text = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        charactersLimitLabel.textColor = text.characters.count > CHARACTERS_LIMIT ? UIColor.redColor() : UIColor.blackColor()
        return true
    }

    /**
    Dismiss keyboard when tapped outside the keyboard or textView
    
    - parameter touches: the touches
    - parameter event:   the related event
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        ideaTextView.resignFirstResponder()
        titleField.resignFirstResponder()
    }
    
    /**
    Save last used textField to determine the need to move the view up to reveal the field after the keyboard appear
    
    - parameter textField: the textField
    */
    func textFieldDidBeginEditing(textField: UITextField) {
        lastTextField = textField
        if textField.frame.maxY > 100 {
            UIView.animateWithDuration(0.3) {
                self.scrollView.contentOffset.y = textField.frame.maxY
            }
        }
    }
    
    /**
    Save last used textView to determine the need to move the view up to reveal the field after the keyboard appear
    
    - parameter textView: the textView
    */
    func textViewDidBeginEditing(textView: UITextView) {
        // Replace placeholder
        if textView.text.trim() == textPlaceholderText {
            let font = UIFont(name: Fonts.regular, size: 16)!
            textView.font = font
            textView.textColor = Colors.gray
            textView.text = ""
        }
        
        lastTextField = textView
        UIView.animateWithDuration(0.3) {
            self.scrollView.contentOffset.y = textView.frame.maxY
        }
    }
    
    /**
    Set back placeholder if needed
    
    - parameter textView: the textView
    */
    func textViewDidEndEditing(textView: UITextView) {
        lastTextField = nil
        if textView.text.trim() == "" {
            textView.text = textPlaceholderText
            let font = UIFont(name: Fonts.italic, size: 15)!
            textView.textColor = Colors.lightGray
            textView.font = font
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        lastTextField = nil
    }
    
    // MARK: Keyboard events
    
    /**
    Override to start listen keyboard events
    
    - parameter animated: flag whether the view is animated when appear
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for keyboard events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Override to stop listen keyboard events
    
    - parameter animated: flag whether the view is animated when disappear
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Keyboard appear event handler
    
    - parameter notification: the notification object that contains keyboard size
    */
    func keyboardWillShow(notification: NSNotification) {
        let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        UIView.animateWithDuration(0.3) {
            self.scrollView.contentInset.bottom = rect.height
        }
    }
    
    /**
    Keyboard disappear event handler. Rollback all changes in the scrollView
    
    - parameter notification: the notification object
    */
    func keyboardWillHide(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.3) {
                self.scrollView.contentInset.bottom = 0
            }
        })
    }
    
}

/**
* Class used for forms
*
* @author Alexander Volkov
* @version 1.0
*/
class FormScrollView: UIScrollView {
    
    /**
    Dismiss keyboard
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.endEditing(true)
    }
}
