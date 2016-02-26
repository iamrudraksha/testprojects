//
//  UIExtensions.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 22.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit
/**
A set of helpful extensions for classes from UIKit
*/

/**
* Shortcut helpful methods for instantiating UIViewController
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIViewController {

    /**
    Instantiate given view controller.
    The method assumes that view controller is identified the same as its class
    and view is defined in the same storyboard.
    
    :param: viewControllerClass the class name
    
    :returns: view controller or nil
    */
    func create<T: UIViewController>(viewControllerClass: T.Type) -> T? {
        let className = NSStringFromClass(viewControllerClass).componentsSeparatedByString(".").last!
        return self.storyboard?.instantiateViewControllerWithIdentifier(className) as? T
    }
}

/**
* Methods for loading and removing view controller and their views
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIViewController {
    
    /**
    Shortcut method for loading view controller, making it full transparent and fading in.
    
    :param: viewController the view controller to show
    :param: callback       callback block to invoke after the view controller is fully visible (alpha=1)
    */
    func fadeInViewController(viewController: UIViewController, _ callback: (()->())?) {
        let viewToShow = viewController.view
        viewToShow.alpha = 0
        loadViewController(viewController, self.view)
        
        // Fade in
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            viewToShow.alpha = 1
            }) { (fin: Bool) -> Void in
                callback?()
        }
    }
    
    /**
    Add the view controller and view into the current view controller
    and given containerView correspondingly.
    Uses autoconstraints.
    
    :param: childVC       view controller to load
    :param: containerView view to load into
    */
    func loadViewController(childVC: UIViewController, _ containerView: UIView) {
        let childView = childVC.view
        childView.translatesAutoresizingMaskIntoConstraints()
        childView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
            | UIViewAutoresizing.FlexibleHeight;
        loadViewController(childVC, containerView, withBounds: containerView.bounds)
    }
    
    /**
    Add the view controller and view into the current view controller
    and given containerView correspondingly.
    Sets fixed bounds for the loaded view in containerView.
    Constraints can be added manually or automatically.
    
    :param: childVC       view controller to load
    :param: containerView view to load into
    :param: bounds        the view bounds
    */
    func loadViewController(childVC: UIViewController, _ containerView: UIView, withBounds bounds: CGRect) {
        let childView = childVC.view
        
        childView.frame = bounds
        
        // Adding new VC and its view to container VC
        self.addChildViewController(childVC)
        containerView.addSubview(childView)
        
        // Finally notify the child view
        childVC.didMoveToParentViewController(self)
    }
    
    /**
    Remove view controller and view from their parents
    */
    func removeFromParent() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
}

/**
* Adds methods for changing navigation bar.
*
* @author Alexander Volkov
* @version 1.0
*/
extension UINavigationController {
    
    /**
    Changes navigation bar title to given title.
    
    :param: title the title
    */
    func setNavigationTitle(title: String) {
        // Title
        let font = UIFont(name: Fonts.semibold, size: 18)!
        var string = NSMutableAttributedString(string: title, attributes: [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.whiteColor()
            ])
        let label = UILabel(frame: CGRectMake(0, 0, 30, 150))
        label.attributedText = string
        self.navigationBar.topItem?.titleView = label
    }
    
    /**
    Change navigation title to textField for searching
    */
    func setNavigationForSearching(title: String, delegate: UITextFieldDelegate?) -> SearchTextField {
        let margin: CGFloat = 65
        let textField = SearchTextField(frame: CGRectMake(0, 0, self.view.frame.width - margin * 2, 30))
        textField.clearButtonMode = UITextFieldViewMode.WhileEditing
        textField.tintColor = UIColor.blackColor()

        // Placeholder
        let font = UIFont(name: Fonts.italic, size: 14)!
        let attributes = [NSFontAttributeName:font,
            NSForegroundColorAttributeName: UIColor(white: 0.45, alpha: 1.0)]
        var string = NSAttributedString(string: title, attributes: attributes)
        textField.attributedPlaceholder = string
        textField.font = font
        textField.textColor = UIColor(white: 0.45, alpha: 1.0)
        textField.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.delegate = delegate
        self.navigationBar.topItem?.titleView = textField
        return textField
    }
}

/**
* Search field
*
* @author Alexander Volkov
* @version 1.0
*/
class SearchTextField: UITextField {
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10.0, 0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return self.textRectForBounds(bounds)
    }
    
}

/**
* Extends UIViewController with shortcut methods
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIViewController {
    
    /**
    Change navigation bar title with given title
    
    :param: title the title
    */
    func initNavigationBarTitle(title: String) {
        self.navigationController?.setNavigationTitle(title)
    }
    
    /**
    Initialize right navigation buttons
    
    :param: buttons the data for the buttons (icon and selector)
    */
    func initRightButtons(buttons: [(String, Selector)]) {
        var list = [UIBarButtonItem]()
        for data in buttons {
            let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            button.frame = CGRectMake(0, 0, 30, 30)
            button.setImage(UIImage(named: data.0), forState: UIControlState.Normal)
            button.addTarget(self, action: data.1, forControlEvents: .TouchUpInside)
            list.append(UIBarButtonItem(customView: button))
        }
        self.navigationItem.rightBarButtonItems = list
    }
    
    /**
    Initialize back button for next view controller that will be pushed
    */
    func initBackButtonFromParent() {
        let backItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }
    
    /**
    Initialize back button for current view controller that will be pushed
    */
    func initBackButtonFromChild() {
        let customBarButtonView = UIView(frame: CGRectMake(0, 0, 60, 40))
        // Button
        let button = UIButton()
        button.addTarget(self, action: "backButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(-24, 0, 60, 40);
        
        // Button title
        button.setTitle("", forState: UIControlState.Normal)
        button.setImage(UIImage(named:"iconBack"), forState: UIControlState.Normal)
        
        // Set custom view for left bar button
        customBarButtonView.addSubview(button)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBarButtonView)
    }
    
    /**
    Creates attributed string from given text.
    
    :param: text the text
    */
    func createAttributedStringForNavigation(text: String) -> NSMutableAttributedString {
        let string = NSMutableAttributedString(string: text, attributes: [
            NSFontAttributeName: UIFont(name: Fonts.regular, size: 12.0)!,
            NSForegroundColorAttributeName: UIColor.blackColor()
            ])
        return string
    }
    
    /**
    "Back" button action handler
    */
    func backButtonAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}


/**
* Extension that replaces standard convertRect
*
* @author TCASSEMBLER
* @version 1.0
*/
extension UIView {
    
    /**
    Same as standard convertRect but fixed to provide correct origin coordinates.
    
    :param: rect the rect to convert
    :param: view the reference view there to convert the coordinates to
    
    :returns: the coordinates of the given rect in the given view
    */
    func convertRectCorrectly(rect: CGRect, toView view: UIView) -> CGRect {
        if UIScreen.mainScreen().scale == 1 {
            return self.convertRect(rect, toView: view)
        }
        else if self == view {
            return rect
        }
        else {
            var rectInParent = self.convertRect(rect, toView: self.superview)
            rectInParent.origin.x /= 2
            rectInParent.origin.y /= 2
            let superViewRect = self.superview!.convertRectCorrectly(self.superview!.frame, toView: view)
            rectInParent.origin.x += superViewRect.origin.x
            rectInParent.origin.y += superViewRect.origin.y
            return rectInParent
        }
    }
}

/**
* Methods for creating snapshots
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIViewController {
    
    /**
    Create snapshort of the current view
    
    :returns: snapshort image
    */
    func createSnapshort() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: false)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

/**
* Shortcut methods for UITableView
*
* @author Alexander Volkov
* @version 1.0
*/
extension UITableView {
    
    /**
    Prepares tableView to have zero margins for separator
    and removes extra separators after all rows
    */
    func separatorInsetAndMarginsToZero() {
        let tableView = self
        if tableView.respondsToSelector("setSeparatorInset:") {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        if tableView.respondsToSelector("setLayoutMargins:") {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
}

/// the target view (textView) which should not dismiss the keyboard
var KeyboardDismissingUIViewTarget: UIView?

/**
* Custom class for top view that dismisses keyboard when tapped outside the given textView or textField
*
* @author Alexander Volkov
* @version 1.0
*/
class KeyboardDismissingUIView: UIView {
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var textFieldOrView: UIView?
        if let textField = KeyboardDismissingUIViewTarget as? UITextField {
            textFieldOrView = textField
        }
        else if let textView = KeyboardDismissingUIViewTarget as? UITextView {
            textFieldOrView = textView
        }
        if let targetView = textFieldOrView {
            // Convert the point to the target view's coordinate system.
            // The target view isn't necessarily the immediate subview
            let pointForTargetView = targetView.convertPoint(point, fromView: self)
            
            if CGRectContainsPoint(targetView.bounds, pointForTargetView) {
                return targetView.hitTest(pointForTargetView, withEvent: event)
            }
            else {
                KeyboardDismissingUIViewTarget = nil
                targetView.resignFirstResponder()
                return nil
            }
        }
        return super.hitTest(point, withEvent: event)
    }
}

/**
* Extends UIImage with a shortcut method.
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIImage {
    
    /**
    Load image asynchronously
    
    :param: url      image URL
    :param: callback the callback to return the image or nil
    */
    class func loadFromURLAsync(url: NSURL, callback: (UIImage?)->()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            let imageData = NSData(contentsOfURL: url)
            dispatch_async(dispatch_get_main_queue(), {
                if let data = imageData {
                    if let image = UIImage(data: data) {
                        // If image is correct, then return it
                        callback(image)
                        return
                    }
                    else {
                        println("ERROR: Error occured while creating image from the data: \(data)")
                    }
                }
                // No image - return nil
                callback(nil)
            })
        })
    }
    
    /**
    Load image asynchronously.
    More simple method than loadFromURLAsync() that helps to cover common fail cases
    and allow to concentrate on success loading.
    
    :param: urlString the url string
    :param: callback  the callback to return the image
    */
    class func loadAsync(urlString: String?, callback: (UIImage)->()) {
        if let urlStr = urlString {
            if urlStr.hasPrefix("http://") {
                if let url = NSURL(string: urlStr) {
                    UIImage.loadFromURLAsync(url, callback: { (image: UIImage?) -> () in
                        if let img = image {
                            callback(img)
                        }
                    })
                }
            }
            else {
                // This case is for demonstration. Local image is used.
                if let image = UIImage(named: urlStr) {
                    callback(image)
                }
            }
        }
    }
}


/**
View transition type (from corresponding side)
*/
enum TRANSITION {
    case RIGHT, LEFT, BOTTOM, NONE
}
/**
* Methods for custom transitions from the sides
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIViewController {
    
    /**
    Show view controller from the side.
    See also dismissViewControllerToSide()
    
    :param: viewController the view controller to show
    :param: side           the side to move the view controller from
    :param: bounds         the bounds of the view controller
    :param: callback       the callback block to invoke after the view controller is shown and stopped
    */
    func showViewControllerFromSide(viewController: UIViewController,
        inContainer containerView: UIView, bounds: CGRect, side: TRANSITION, _ callback:(()->())?) {
            // New view
            let toView = viewController.view;
            
            // Setup bounds for new view controller view
            toView.translatesAutoresizingMaskIntoConstraints()
            toView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
            var frame = bounds
            frame.origin.y = containerView.frame.height - bounds.height
            switch side {
            case .BOTTOM:
                frame.origin.y = containerView.frame.size.height // From bottom
            case .LEFT:
                frame.origin.x = -containerView.frame.size.width // From left
            case .RIGHT:
                frame.origin.x = containerView.frame.size.width // From right
            default:break
            }
            toView.frame = frame
            
            self.addChildViewController(viewController)
            containerView.addSubview(toView)
            
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1.0,
                initialSpringVelocity: 1.0, options: nil, animations: { () -> Void in
                    switch side {
                    case .BOTTOM:
                        frame.origin.y = containerView.frame.height - bounds.height + bounds.origin.y
                    case .LEFT, .RIGHT:
                        frame.origin.x = 0
                    default:break
                    }
                    toView.frame = frame
                }) { (fin: Bool) -> Void in
                    viewController.didMoveToParentViewController(self)
                    callback?()
            }
    }
    
    /**
    Shortcut method for showViewControllerFromSide
    
    :param: viewController the view controller to show from bottom
    */
    func showViewControllerFromBottom(viewController: UIViewController) {
        showViewControllerFromSide(viewController, inContainer: self.view, bounds: self.view.bounds, side: .BOTTOM, nil)
    }
    
    /**
    Dismiss the view controller through moving it back to given side
    See also showViewControllerFromSide()
    
    :param: viewController the view controller to dismiss
    :param: side           the side to move the view controller to
    :param: callback       the callback block to invoke after the view controller is dismissed
    */
    func dismissViewControllerToSide(viewController: UIViewController, side: TRANSITION, _ callback:(()->())?) {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0, options: nil, animations: { () -> Void in
                // Move back to bottom
                switch side {
                case .BOTTOM:
                    viewController.view.frame.origin.y = self.view.frame.height
                case .LEFT:
                    viewController.view.frame.origin.x = -self.view.frame.size.width
                case .RIGHT:
                    viewController.view.frame.origin.x = self.view.frame.size.width
                default:break
                }
                
            }) { (fin: Bool) -> Void in
                viewController.willMoveToParentViewController(nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParentViewController()
                callback?()
        }
    }
    
}

extension UIView {
    
    /**
    Shake the view
    */
    func shakeView() {
        shakeView(4)
    }
    
    /**
    Shake the view
    
    :param: shakes the number of shakes
    */
    private func shakeView(shakes: Int) {
        if shakes == 0 {
            self.transform = CGAffineTransformIdentity
            return
        }
        let shakeDistance: CGFloat = 10
        UIView.animateWithDuration(0.05, animations: { () -> Void in
            self.transform = CGAffineTransformMakeTranslation(shakes % 2 == 0 ? shakeDistance : -shakeDistance, 0)
            }) { (_) -> Void in
                self.shakeView(shakes - 1)
        }
    }
}
