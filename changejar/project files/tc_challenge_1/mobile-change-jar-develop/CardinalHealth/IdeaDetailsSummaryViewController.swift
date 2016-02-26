//
//  IdeaDetailsSummaryViewController.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 25.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

struct IdeaDetailsMargins {
    
    static let NAME_HAS_ICON: CGFloat = 46
    static let NAME_NO_ICON: CGFloat = 0
    
    static let AUTHOR_ANONYMOUS: CGFloat = 28
    static let AUTHOR_KNOWN: CGFloat = 49
    
    static let TIME_OY_AUTHOR_ANONYMOUS: CGFloat = 1
    static let TIME_OY_AUTHOR_KNOWN: CGFloat = 4
    static let TIME_OY_AUTHOR_NO_TITLE: CGFloat = 9
}

/**
* Idea Details Summary screen
*
* @author Alexander Volkov
* @version 1.0
*/
class IdeaDetailsSummaryViewController: UIViewController, DetailsNavigationBarViewControllerDelegate {
    
    /// outlets
    @IBOutlet weak var allContentView: UIView!
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorViewHeight: NSLayoutConstraint!
  
    @IBOutlet weak var authorAnonymousView: UIView!
    @IBOutlet weak var authorDetailsView: UIView!
    @IBOutlet weak var authorAnonymousLabel: UILabel!
    @IBOutlet weak var authorIcon: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var authorTitleLabel: UILabel!
    @IBOutlet weak var authorNameLeftMargin: NSLayoutConstraint!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLabelVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var gradientView: UIImageView?
    
    /// the idea to show
    var idea: Idea!
    
    /// reference to full details view controller
    var fullDetailsViewController: UIViewController?
    
    /// reference to navigation bar in full details screen
    var lastDetailsNavigationBarViewController: DetailsNavigationBarViewController?
    
    /**
    Initialize UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }

    /**
    Update UI using idea data
    */
    func updateUI() {
        titleLabel.text = idea.title
        
        // Author
        authorAnonymousView.hidden = !idea.isAnonymous
        authorDetailsView.hidden = idea.isAnonymous
        authorViewHeight.constant = idea.isAnonymous ? IdeaDetailsMargins.AUTHOR_ANONYMOUS : IdeaDetailsMargins.AUTHOR_KNOWN
        timeLabelVerticalConstraint.constant = idea.isAnonymous ? IdeaDetailsMargins.TIME_OY_AUTHOR_ANONYMOUS : IdeaDetailsMargins.TIME_OY_AUTHOR_KNOWN

        if !idea.isAnonymous {
            authorIcon.image = nil
            authorIcon.layer.cornerRadius = self.authorIcon.bounds.width/2
            authorIcon.layer.masksToBounds = true
            authorNameLeftMargin.constant = IdeaDetailsMargins.NAME_NO_ICON
            
            // callback to show profile icon
            let callback = { (image: UIImage) -> () in
                self.authorIcon.image = image
                self.authorNameLeftMargin.constant = IdeaDetailsMargins.NAME_HAS_ICON
            }
            if idea.isMyIdea() {
                LastUserInfo?.getProfileImage(callback)
            }
            else {
                UIImage.loadAsync(idea.submitterIconUrl, callback: callback)
            }
            authorNameLabel.text = idea.submitter
            authorTitleLabel.text = idea.submitterTitle
            if (authorTitleLabel.text?.trim() ?? "").isEmpty {
                authorViewHeight.constant = IdeaDetailsMargins.AUTHOR_ANONYMOUS
                timeLabelVerticalConstraint.constant = IdeaDetailsMargins.TIME_OY_AUTHOR_ANONYMOUS
            }
        }
        else {
            // "by Anonymous" string
            let str1 = "BY_ANONYMOUS_1".localized()
            let str2 = "BY_ANONYMOUS_2".localized()
            
            let range1 = NSMakeRange(0,str1.characters.count)
            let range2 = NSMakeRange(str1.characters.count,str2.characters.count)
            
            let font1 = UIFont(name: Fonts.regular, size: 13)!
            let font2 = UIFont(name: Fonts.semibold, size: 15)!
            
            let string = NSMutableAttributedString(string: str1 + str2, attributes: [NSForegroundColorAttributeName: Colors.darkGray])
            string.addAttributes([NSFontAttributeName:font1], range: range1)
            string.addAttributes([NSFontAttributeName:font2], range: range2)
            authorAnonymousLabel.attributedText = string
        }
        
        timeLabel.text = idea.getDateString()
        textLabel.text = idea.text
    }
    
    /**
    Swipe up action. Show full details.
    
    - parameter sender: the swipe gesture recognizer
    */
    @IBAction func swipeUpAction(sender: AnyObject) {
        showFullDetails()
    }

    /**
    Show full details
    */
    func showFullDetails() {
        if fullDetailsViewController == nil {
            if let vc = create(IdeaFullDetailsViewController.self) {
                vc.idea = idea
                vc.parent = self
                fullDetailsViewController = vc
                let bounds = self.view.bounds
                showViewControllerFromSide(vc, inContainer: self.view, bounds: bounds, side: .BOTTOM, { () -> () in
                    
                })
                topMarginConstraint.constant = -self.allContentView.frame.height
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
                        self.view.layoutIfNeeded()
                    }, completion: nil)
            }
            if let vc = create(DetailsNavigationBarViewController.self) {
                vc.delegate = self
                lastDetailsNavigationBarViewController = vc
                var bounds = self.view.bounds
                bounds.size.height = 64
                vc.view.alpha = 0
                RootViewControllerSingleton?.loadViewController(vc, RootViewControllerSingleton!.view, withBounds: bounds)
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    vc.view.alpha = 1
                })
            }
        }
    }
    
    /**
    Swipe down action. Defined in subclass.
    
    - parameter sender: the swipe gesture recognizer
    */
    @IBAction func swipeDownAction(sender: AnyObject) {
        hideFullDetails()
    }
    
    /**
    Hide full details
    */
    func hideFullDetails() {
        updateUI()
        if let vc = fullDetailsViewController {
            topMarginConstraint.constant = 0
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1.0,
                initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
                    self.view.layoutIfNeeded()
                }, completion: nil)
            dismissViewControllerToSide(vc, side: .BOTTOM, { () -> () in
                self.fullDetailsViewController = nil
            })
        }
        if let vc = lastDetailsNavigationBarViewController {
            lastDetailsNavigationBarViewController = nil
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                vc.view.alpha = 0
            }, completion: { (fin: Bool) -> Void in
                vc.removeFromParent()
            })
        }
    }
    
    // MARK: DetailsNavigationBarViewControllerDelegate
    
    /**
    "Arrow down" button action handler
    
    - parameter viewController: the view controller
    */
    func arrowDownTapped(viewController: DetailsNavigationBarViewController) {
        hideFullDetails()
    }
}
