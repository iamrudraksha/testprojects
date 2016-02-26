//
//  HomeViewController.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 22.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/// key for the flag that is used to define either to show overlay or not
let kHomeOverlayShown = "kHomeOverlayShown"

/**
* Home Screen
*
* @author Alexander Volkov
* @version 1.0
*/
class HomeViewController: UIViewController {

    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var newideasLabel: UILabel!
    
    // Middle
    @IBOutlet weak var middleTopLine1Height: NSLayoutConstraint!
    @IBOutlet weak var middleTopLine2Height: NSLayoutConstraint!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var leftCounterLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var rightCounterLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var browseButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    /// flag: true - overlay was already shown, false - overlay is not yet shown
    var overlayShown = false
    
    var notificationsWidget: NotificationsWidget!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fixUI()
        initNavigation()
        newideasLabel.text = "0"
        leftCounterLabel.text = "0"
        rightCounterLabel.text = "0"
    }
    
    /**
    Show overlay if needed
    
    :param: animated the animation flag
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initNavigation()
        loadData()
        if isFirstTime(kHomeOverlayShown) { // Check if Home Screen is first time opened
            self.showOverlay()
        }
    }
    
    /**
    Initialize navigation bar
    */
    func initNavigation() {
        initNavigationBarTitle("DASHBOARD".localized().uppercaseString)
        
        /// Bell icon
        let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        button.frame = CGRectMake(0, 0, 30, 30)
        button.setImage(UIImage(named: "iconBell"), forState: UIControlState.Normal)
        button.addTarget(self, action: "openNewIdeasAction:", forControlEvents: .TouchUpInside)
        let view = UIView(frame: button.frame)
        view.addSubview(button)
        
        // Add widget
        var widget = NotificationsWidget()
        widget.number = 0
        widget.backgroundColor = UIColor.clearColor()
        let size = CGSize(width: 20, height: 20)
        widget.frame = CGRect(origin: CGPoint(x: 11, y: 0), size: size)
        view.addSubview(widget)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: view)]
        self.notificationsWidget = widget
        
        initBackButtonFromParent()
    }
    
    
    /**
    Fixes UI constraints, image modes
    */
    func fixUI() {
        if isIPhone5() {
            mainImage.contentMode = UIViewContentMode.ScaleAspectFit
        }
        // Float values for heights of the lines
        middleTopLine1Height.constant = 0.5
        middleTopLine2Height.constant = 1.5
        fixConstraints(browseButton)
        fixConstraints(submitButton)
        fixConstraints(settingsButton)
    }
    
    /**
    Changes not zero constrains to have 0.5 value (this is not possible in Interface Builder)
    
    :param: button the button
    */
    private func fixConstraints(button: UIButton) {
        for constraint in button.superview!.constraints() {
            if let c = constraint as? NSLayoutConstraint {
                if c.firstItem as? UIButton == button ?? false
                    || c.secondItem as? UIButton == button ?? false {
                    if c.constant > 0 {
                        c.constant = 0.5
                    }
                }
            }
        }
        button.layoutIfNeeded()
    }
    
    /**
    Shows overlay screen
    */
    func showOverlay() {
        overlayShown = true
        
        let navigationBarHeight: CGFloat = 64
        let rect1 = leftButton.convertRectCorrectly(leftButton.frame, toView: self.view)
        let rect2 = rightButton.convertRectCorrectly(rightButton.frame, toView: self.view)
        let rect3 = submitButton.convertRectCorrectly(submitButton.frame, toView: self.view)
        let coord1 = CGPointMake(CGRectGetMidX(rect1), CGRectGetMidY(rect1) - navigationBarHeight)
        let coord2 = CGPointMake(CGRectGetMidX(rect2), CGRectGetMidY(rect2) - navigationBarHeight)
        let coord3 = CGPointMake(CGRectGetMidX(rect3), CGRectGetMidY(rect3) - navigationBarHeight)

        let string1 = getAttributedString("OVERLAY1")
        let string2 = getAttributedString("OVERLAY2")
        let paragrahStyle = NSMutableParagraphStyle()
        paragrahStyle.alignment = NSTextAlignment.Right
        string2.addAttribute(NSParagraphStyleAttributeName, value: paragrahStyle,
            range: NSMakeRange(0, string2.length))
        
        if let vc = create(OverlayViewController.self) {
            self.view.layoutIfNeeded()
            let referenceImage = navigationController!.createSnapshort()
            
            let data1 = HomeOverlay(text: nil,
                attributedString: string1,
                icon: nil,
                coordirantes: coord1
            )
            let data2 = HomeOverlay(text: nil,
                attributedString: string2,
                icon: nil,
                coordirantes: coord2
            )
            let data3 = HomeOverlay(text: "What's your ideas? Share & discuss with others",
                attributedString: nil,
                icon: UIImage(named: "iconOverlaySubmit"),
                coordirantes: coord3
            )
            vc.homeOverlayData = [data1, data2, data3]
            let view = vc.view
            vc.hideViews()
            RootViewControllerSingleton?.loadViewController(vc, RootViewControllerSingleton!.view)
            vc.fadeIn()
        }
    }
    
    /**
    Get attributed string for overlay screen text
    
    :param: localizedPrefix the prefix for localized string key
    
    :returns: NSMutableAttributedString
    */
    func getAttributedString(localizedPrefix: String) -> NSMutableAttributedString {
        let str1 = "\(localizedPrefix)_TEXT1".localized()
        let str2 = "\(localizedPrefix)_TEXT2".localized()
        let str3 = "\(localizedPrefix)_TEXT3".localized()
        
        let range1 = NSMakeRange(0,count(str1))
        let range2 = NSMakeRange(count(str1), count(str2))
        let range3 = NSMakeRange(count(str1 + str2), count(str3))
        
        var fontSize: CGFloat = 19.7
        if isIPhone5() {
            fontSize = 15
        }
        let font1 = UIFont(name: Fonts.regular, size: fontSize)!
        let font2 = UIFont(name: Fonts.bold, size: fontSize)!
        
        let string = NSMutableAttributedString(string: str1 + str2 + str3, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        string.addAttributes([NSFontAttributeName: font1], range: range1)
        string.addAttributes([NSFontAttributeName: font2, NSForegroundColorAttributeName:Colors.red], range: range2)
        string.addAttributes([NSFontAttributeName: font1], range: range3)
        return string
    }
    
    /**
    Load ideas and update UI
    */
    func loadData() {
        IdeasDataSource.sharedInstance.getIdeas(callback: { (list: [Idea]) -> () in
            
            // My ideas
            self.leftCounterLabel.text = Idea.filterMyIdeas(list).count.description
            
            // All ideas
            self.rightCounterLabel.text = list.count.description
            
            // New ideas
            let n = Idea.filterNewIdeas(list).count
            self.newideasLabel.text = n.description
            self.notificationsWidget.number = n

        }) { (error: RestError, res: RestResponse?) -> () in
            error.showError()
        }
    }
    
    /**
    Open new ideas list
    
    :param: sender the button
    */
    @IBAction func openNewIdeasAction(sender: AnyObject) {
        showIdeas(IdeasListType.New)
    }

    /**
    "My Ideas" button action handler
    
    :param: sender the button
    */
    @IBAction func myIdeasAction(sender: AnyObject) {
        showIdeas(IdeasListType.My)
    }

    /**
    "All Ideas" button action handler
    
    :param: sender the button
    */
    @IBAction func allIdeasAction(sender: AnyObject) {
        showIdeas(IdeasListType.All)
    }
    
    /**
    "Browse" button action handler
    
    :param: sender the button
    */
    @IBAction func browseButtonAction(sender: AnyObject) {
        showIdeas(IdeasListType.Random)
    }
    
    /**
    "Submit Ideas" button action handler
    
    :param: sender the button
    */
    @IBAction func submitButtonAction(sender: AnyObject) {
        openSubmitIdeaScreen()
    }
    
    /**
    "Settings" button action handler
    
    :param: sender the button
    */
    @IBAction func settingsButtonAction(sender: AnyObject) {
        if let vc = create(SettingsViewController.self) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    internal func showIdeas(type: IdeasListType) {
        if let vc = create(IdeasListViewController.self) {
            vc.listType = type
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class MainNavigationViewController: UINavigationController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

/**
* Shortcut method related to application screen transition logic
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIViewController {
    
    /**
    Opens Submit Idea screen
    */
    func openSubmitIdeaScreen() {
        if let vc = create(SubmitIdeaViewController.self) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}