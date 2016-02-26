//
//  DetailsNavigationBarViewController.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 25.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Protocol for delegating Idea Full Details dismiss action
*
* @author Alexander Volkov
* @version 1.0
*/
protocol DetailsNavigationBarViewControllerDelegate {
    
    /**
    Notify that "arrow down" button tapped
    
    :param: viewController the related view controller
    */
    func arrowDownTapped(viewController: DetailsNavigationBarViewController)
}

/**
* View controller for navigation bar on Idea Full Details screen
*
* @author Alexander Volkov
* @version 1.0
*/
class DetailsNavigationBarViewController: UIViewController {

    /// reference to delegate
    var delegate: DetailsNavigationBarViewControllerDelegate!
    
    /**
    "Arrow down" button and swipe down action handler
    
    :param: sender the button or swipe gesture recognizer
    */
    @IBAction func arrowDownAction(sender: AnyObject) {
        delegate?.arrowDownTapped(self)
    }
}
