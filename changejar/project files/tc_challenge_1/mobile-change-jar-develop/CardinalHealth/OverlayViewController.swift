//
//  OverlayViewController.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 23.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
*  Data for displaying overlay
*/
struct HomeOverlay {
    
    /// the text
    let text: String?
    let attributedString: NSAttributedString?
    
    /// the icon to show (defines which overlay variant to use)
    let icon: UIImage?
    
    /// coordinates of the highlighted area
    let coordirantes: CGPoint
}
    
/**
* Overlay for Home and Idea Details screens
*
* @author Alexander Volkov
* @version 1.0
*/
class OverlayViewController: UIViewController {

    @IBOutlet weak var bgImage: UIImageView!
    
    // Top
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    // Home Screen overlay
    @IBOutlet weak var homeOverlay: UIView!
    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var holeView: UIView!
    @IBOutlet weak var holeHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var holeVerticalConstraint: NSLayoutConstraint!
    
    // Variant 1
    @IBOutlet weak var infoWithIcon: UIView!
    @IBOutlet weak var infoIcon: UIImageView!
    @IBOutlet weak var textAfterIcon: UILabel!
    
    // Variant 2
    @IBOutlet weak var infoText: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    
    // Idea Details overlay
    @IBOutlet weak var detailsOverlay: UIView!
    @IBOutlet weak var details1View: UIView!
    @IBOutlet weak var details2View: UIImageView!
    @IBOutlet var details2lines: [NSLayoutConstraint]!
    
    /// data for Home Screen overlay
    var homeOverlayData: [HomeOverlay]?
    var detailsOverlayData: [Int]?
    
    /// current overlay content index
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        homeOverlay.hidden = true
        detailsOverlay.hidden = true
        for line in details2lines {
            line.constant = 0.5
        }
        
        if let data = homeOverlayData {
            if data.count > 0 {
                updateWithHomeData(data[0])
            }
        }
        else {
            detailsOverlayData = [1,2] // screen indexes
            updateWithDetailsData(detailsOverlayData![0])
        }
        self.bgImage.alpha = 0
    }
    
    /**
    Hide views
    */
    func hideViews() {
        self.homeOverlay.alpha = 0
        self.detailsOverlay.alpha = 0
        self.topView.alpha = 0
    }
    
    /**
    Fade in the views
    */
    func fadeIn() {
        hideViews()
        self.bgImage.alpha = 1
        delay(0.2, callback: { () -> () in
            StatusBarStyle = UIStatusBarStyle.Default
            self.parentViewController?.setNeedsStatusBarAppearanceUpdate()
        })
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.homeOverlay.alpha = 1
            self.detailsOverlay.alpha = 1
            self.topView.alpha = 1
        })
    }
    
    /**
    Update UI with Home Screen overlay data
    
    - parameter data: the data
    */
    func updateWithHomeData(data: HomeOverlay) {
        homeOverlay.hidden = false
        
        if let icon = data.icon {
            infoWithIcon.hidden = false
            infoText.hidden = true
            
            infoIcon.image = icon
            textAfterIcon.text  = data.text
        }
        else {
            infoWithIcon.hidden = true
            infoText.hidden = false
            if let attrStr = data.attributedString {
                infoLabel.attributedText = attrStr
            }
            else {
                infoLabel.text = data.text
            }
        }
        holeHorizontalConstraint.constant = data.coordirantes.x
        holeVerticalConstraint.constant = data.coordirantes.y
    }
    
    /**
    Update UI with Idea Details Screen overlay data
    
    - parameter data: the data
    */
    func updateWithDetailsData(data: Int) {
        detailsOverlay.hidden = false
        details1View.hidden = true
        details2View.hidden = true
        
        switch data {
        case 1:
            details1View.hidden = false
        case 2:
            details2View.hidden = false
        default: break
        }
    }

    /**
    "Ok" button action handler
    
    - parameter sender: the button
    */
    @IBAction func okButtonAction(sender: AnyObject) {
        delay(0.2, callback: { () -> () in
            StatusBarStyle = UIStatusBarStyle.LightContent
            self.parentViewController?.setNeedsStatusBarAppearanceUpdate()
        })
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.hideViews()
        }) { (fin: Bool) -> Void in
            self.removeFromParent()
        }
    }

    /**
    "Next"/"Done" buttons action handler
    
    - parameter sender: the button
    */
    @IBAction func nextButtonAction(sender: AnyObject) {
        var isLastScreen = false
        if let data = homeOverlayData {
            // Next tapped
            if currentIndex < data.count - 1 {
                currentIndex++
                self.updateWithHomeData(data[self.currentIndex])
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    
                }, completion: nil)
                
                // If last overlay
                isLastScreen = currentIndex == data.count - 1
            }
            // Done tapped
            else {
                okButtonAction(sender)
            }
        }
        else if let data = detailsOverlayData {
            // Next tapped
            if currentIndex < data.count - 1 {
                currentIndex++
                self.updateWithDetailsData(data[self.currentIndex])
                isLastScreen = currentIndex == data.count - 1
            }
            // Done tapped
            else {
                okButtonAction(sender)
            }
        }
        if isLastScreen {
            self.nextButton.setTitle("DONE".localized(), forState: .Normal)
        }
    }
}
