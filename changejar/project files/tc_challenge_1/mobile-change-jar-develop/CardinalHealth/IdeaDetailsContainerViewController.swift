//
//  IdeaDetailsContainerViewController.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 25.06.15.
//  Modified by Volkov Alexander on 16.07.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Protocol to obtain next and previous ideas to the current one
*
* @author Alexander Volkov
* @version 1.0
*/
protocol IdeaDetailsContainerViewControllerDelegate {
    
    /**
    Get next idea from given
    
    - parameter referenceIdea: the reference idea
    
    - returns: the next idea
    */
    func getNextIdea(referenceIdea: Idea) -> Idea?
    
    /**
    Get previous idea from given
    
    - parameter referenceIdea: the reference idea
    
    - returns: the previous idea
    */
    func getPreviousIdea(referenceIdea: Idea) -> Idea?
    
    /**
    Shows search field
    */
    func showSearch()
}

/// key for the flag that is used to define either to show Overlay or not
let kIdeaDetailsScreenShown = "kIdeaDetailsScreenShown"

/**
* Main view controller for Idea Details screen.
* Loads summary and full details of an idea and helps to swipe between ideas.
*
* @author Alexander Volkov
* @version 1.1
* changes:
* 1.1:
* - updated isFirstTime() method support
*/
class IdeaDetailsContainerViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    /// the idea to show
    var idea: Idea! {
        didSet {
            // Mark idea as not new because we going to show it
            IdeasDataSource.sharedInstance.markIdeasAsNotNew([idea])
        }
    }
    
    /// reference to delegate
    var delegate: IdeaDetailsContainerViewControllerDelegate?
    
    /// reference to last opened view controller
    var lastViewController: IdeaDetailsSummaryViewController?
    
    /// flag: true - overlay was already shown, false - overlay is not yet shown
    var overlayShown = false
    
    /**
    Initialize UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        initBackButtonFromChild()
        initNavigation()
        updateUI()
    }

    /**
    Fix navigation bar and try show overlay
    
    - parameter animated: the animation flag
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initNavigation()
        if isFirstTime(kIdeaDetailsScreenShown) {
            updateNotFirstTime(kIdeaDetailsScreenShown)
            showOverlay()
        }
    }
    
    /**
    Initialize navigation bar
    */
    func initNavigation() {
        initNavigationBarTitle("IDEAS".localized().uppercaseString)
        initRightButtons([("iconPlus", "submitIdeaAction:"), ("iconSearch", "searchAction:")])
    }
    
    /**
    Update UI using idea data
    */
    func updateUI() {
        if let vc = create(IdeaDetailsSummaryViewController.self) {
            vc.idea = idea
            loadViewController(vc, containerView)
            lastViewController = vc
        }
    }
    
    /**
    Shows overlay screen
    */
    func showOverlay() {
        overlayShown = true
        if let vc = create(OverlayViewController.self) {
            self.view.layoutIfNeeded()
            let referenceImage = navigationController!.createSnapshort()
            _ = vc.view
            vc.hideViews()
            RootViewControllerSingleton?.loadViewController(vc, RootViewControllerSingleton!.view)
            vc.bgImage.image = referenceImage
            vc.fadeIn()
        }
    }

    // MARK: Button actions
    
    /**
    "Search" button action handler
    
    - parameter sender: the button
    */
    func searchAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        delegate?.showSearch()
    }

    /**
    "Plus" button action handler
    
    - parameter sender: the button
    */
    func submitIdeaAction(sender: AnyObject) {
        openSubmitIdeaScreen()
    }
    
    /**
    Swipe left action. Show next idea.
    
    - parameter sender: the swipe gesture recognizer
    */
    @IBAction func leftSwipeAction(sender: AnyObject) {
        // Disable idea swipe if full details are shown
        if lastViewController!.fullDetailsViewController != nil {
            return
        }
        if let idea = delegate?.getNextIdea(idea) {
            if let vc = create(IdeaDetailsSummaryViewController.self) {
                vc.idea = idea
                if let last = lastViewController {
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        last.gradientView?.alpha = 0
                    })
                    dismissViewControllerToSide(last, side: .LEFT, nil)
                }
                
                // Show next idea
                self.idea = idea
                loadViewController(vc, self.containerView)
                self.containerView.sendSubviewToBack(vc.view)
                lastViewController = vc
            }
        }
        else {
            // Shake to indicate the end of the sequence of ideas
            self.containerView.shakeView()
        }
    }
    
    /**
    Swipe right action. Show previous idea.
    
    - parameter sender: the swipe gesture recognizer
    */
    @IBAction func rightSwipeAction(sender: AnyObject) {
        // Disable idea swipe if full details are shown
        if lastViewController!.fullDetailsViewController != nil {
            return
        }
        if let idea = delegate?.getPreviousIdea(idea) {
            if let vc = create(IdeaDetailsSummaryViewController.self) {
                vc.idea = idea
                let lastVC = lastViewController
                
                // Show previous idea
                self.idea = idea
                _ = vc.view
                vc.gradientView?.alpha = 0
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    vc.gradientView?.alpha = 1
                })
                showViewControllerFromSide(vc, inContainer: self.containerView,
                    bounds: self.containerView.bounds, side: .LEFT, { () -> () in
                        lastVC?.removeFromParent()
                })
                lastViewController = vc
            }
        }
        else {
            // Shake to indicate the end of the sequence of ideas
            self.containerView.shakeView()
        }
    }
}
