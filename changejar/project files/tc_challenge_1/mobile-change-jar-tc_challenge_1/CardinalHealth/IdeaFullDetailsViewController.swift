//
//  IdeaFullDetailsViewController.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 25.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Idea Details shown after swipe up
*
* @author Alexander Volkov
* @version 1.0
*/
class IdeaFullDetailsViewController: IdeaDetailsSummaryViewController {
    
    @IBOutlet weak var lineHeight: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    /// reference to parent view controller
    var parent: IdeaDetailsSummaryViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fixUI()
    }
    
    override func updateUI() {
        let headerInitialHeight = headerViewHeightConstraint.constant
        let titleInitialHeight: CGFloat = 60
        
        super.updateUI()
        
        self.titleLabel.layoutIfNeeded()
        let rect = self.titleLabel.textRectForBounds(self.titleLabel.bounds, limitedToNumberOfLines: 4)
        let extraHeight = rect.height - titleInitialHeight
        if extraHeight > 0 {
            headerViewHeightConstraint.constant = headerInitialHeight + extraHeight
        }
        self.titleLabel.layoutIfNeeded()
        self.view.layoutIfNeeded()

    }
    
    /**
    Fixes UI constraints
    */
    func fixUI() {
        lineHeight.constant = 0.5
    }
    
    /**
    Swipe down action. Hide full details.
    
    :param: sender the swipe gesture recognizer
    */
    override func swipeUpAction(sender: AnyObject) {
        parent.hideFullDetails()
    }
}
