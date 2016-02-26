//
//  ThankViewController.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 24.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/// the text for ThankViewController label
var ThankScreenText: NSAttributedString!

/**
* Screen shown after success idea submission
*
* @author Alexander Volkov
* @version 1.0
*/
class ThankViewController: UIViewController, UIActionSheetDelegate {

    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var thanksLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var textHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!

    var parent: SubmitIdeaViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var titleFontSize: CGFloat = 18
        if isIPhone5() {
            titleFontSize = 13
        }
        var titleFont = UIFont(name: Fonts.light, size: titleFontSize)!
        let title = NSMutableAttributedString(string: "THANKS_DETAILS".localized() ?? "", attributes: [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: titleFont
            ])
        messageLabel.attributedText = title
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    /**
    Update UI
    
    :param: animated the animation flag
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textLabel.attributedText = getAttributedString()
        let rect = textLabel.sizeThatFits(textLabel.bounds.size)
        textHeight.constant = rect.height
        textLabel.layoutIfNeeded()
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        self.view.layoutIfNeeded()
    }
    
    /**
    "Close" button action handler
    
    :param: sender the button
    */
    @IBAction func closeButtonAction(sender: AnyObject) {
        let actionSheet = UIActionSheet(title: "WHAT_TO_DO".localized(), delegate: self,
            cancelButtonTitle: nil,
            destructiveButtonTitle: nil, otherButtonTitles: "GO_BACK".localized(), "OPEN_HOME".localized())
        actionSheet.showInView(self.view)
    }
    
    /**
    Action sheet buttons action handler
    
    :param: actionSheet the actionSheet
    :param: buttonIndex the index of the tapped button
    */
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        IdeasListViewControllerNeedToReload = true
        switch buttonIndex {
        case 0:
            self.parent.navigationController?.popViewControllerAnimated(false)
        case 1:
            self.parent.navigationController?.popToRootViewControllerAnimated(true)
        default:
            break
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.parentViewController?.dismissViewControllerToSide(self, side: .BOTTOM, nil)
        })
    }
    
    /**
    Get text data
    
    :returns: the attributed string
    */
    func getAttributedString() -> NSAttributedString {
        if ThankScreenText != nil {
            return ThankScreenText
        }
        let path = NSBundle.mainBundle().pathForResource("ThankScreen", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!, options: .DataReadingMappedIfSafe, error: nil)
        let json = JSON(data: jsonData!)
        
        // "by Anonymous" string
        var paragraphs = [(String, String)]()
        var titleRanges = [NSRange]()
        var textRanges = [NSRange]()
        var lastLen = 0
        var str = ""
        for item in json.arrayValue {
            let title = item["title"].stringValue + "\r"
            let text = item["contentText"].stringValue + "\r\r"
            str += title + text
            titleRanges.append(NSMakeRange(lastLen, count(title)))
            lastLen += count(title)
            textRanges.append(NSMakeRange(lastLen, count(text)))
            lastLen += count(text)
            paragraphs.append((title, text))
        }

        let font1 = UIFont(name: Fonts.semibold, size: 14)!
        let font2 = UIFont(name: Fonts.regular, size: 14)!
        
        let string = NSMutableAttributedString(string: str, attributes: [NSForegroundColorAttributeName: Colors.gray, NSFontAttributeName:font2])
        for range in titleRanges {
            string.addAttributes([NSFontAttributeName:font1], range: range)
        }
        ThankScreenText = string
        return string
    }
}
