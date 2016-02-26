//
//  RootViewController.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 22.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit

/*
The reference to main RootViewController
*/
var RootViewControllerSingleton: RootViewController!

/// key for the flag that is used to define either to show Welcome Screen or not
let kWelcomeScreenShown = "kWelcomeScreenShown"

var StatusBarStyle: UIStatusBarStyle = UIStatusBarStyle.LightContent {
    didSet {
        RootViewControllerSingleton?.setNeedsStatusBarAppearanceUpdate()
    }
}

/**
* Top view controller.
*
* @author Alexander Volkov
* @version 1.0
*/
class RootViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    @IBOutlet weak var pageControl: UIView!
    @IBOutlet weak var welcomeScreenBottomView: UIView!
    
    private var pageViewController: UIPageViewController? {
        didSet {
            pageControl.hidden = pageViewController == nil
            welcomeScreenBottomView.hidden = pageViewController == nil
        }
    }
    
    private var screens = [WelcomeScreenContent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        RootViewControllerSingleton = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if the app is launched for the first time
        if isFirstTime(kWelcomeScreenShown) {
            openWelcomeScreen()
        }
        else {
            openHomeScreen(false)
        }
        updateDots(0)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return pageViewController != nil
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return StatusBarStyle
    }
    
    /**
    Open Welcome Screen
    */
    func openWelcomeScreen() {
        screens = WelcomeScreenContent.getPredefinedData()
        if let pageController = create(WelcomeViewController.self) {
            pageController.dataSource = self
            pageController.delegate = self
            
            if screens.count > 0 {
                let firstController = getItemController(0)!
                let startingViewControllers = [firstController]
                pageController.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
                pageController.view.insertSubview(UIView(), atIndex: 0)
            }
            self.pageViewController = pageController
            var bounds = self.view.bounds
            bounds.size.height = UIScreen.mainScreen().bounds.height - 20
            loadViewController(pageController, self.view, withBounds: bounds)
            pageControl.superview!.bringSubviewToFront(pageControl)
            welcomeScreenBottomView.superview!.bringSubviewToFront(welcomeScreenBottomView)
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    /**
    "Start" button action handler
    
    :param: sender the button
    */
    @IBAction func startButtonAction(sender: AnyObject) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        openHomeScreen(true)
    }
    
    
    func openHomeScreen(animated: Bool) {
        if let vc = create(MainNavigationViewController.self) {
            if let pageVC = self.pageViewController {
                self.pageViewController = nil
                showViewControllerFromSide(vc, inContainer: self.view, bounds: self.view.bounds, side: .BOTTOM, { () -> () in
                    pageVC.removeFromParent()
                })
            }
            else {
                loadViewController(vc, self.view, withBounds: self.view.bounds)
            }
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: Methods needed for WelcomeViewController

    /**
    Creates view controller for given index
    
    :param: itemIndex the index
    
    :returns: a page view controller
    */
    private func getItemController(itemIndex: Int) -> WelcomeScreenContentViewController? {
        if itemIndex < screens.count {
            if let vc = create(WelcomeScreenContentViewController.self) {
                vc.itemIndex = itemIndex
                vc.content = screens[itemIndex]
                let view = vc.view
                let constraintsAndStatusBarHeight: CGFloat = 35 + 225 + 20 // top and bottom constraints, status bar height
                vc.heightConstraint.constant = UIScreen.mainScreen().bounds.height - constraintsAndStatusBarHeight
                view.layoutIfNeeded()
                return vc
            }
        }
        return nil
    }

    /**
    Get previous view controller
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! WelcomeScreenContentViewController

        updateDots(itemController.itemIndex)
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex - 1)
        }
        
        return nil
    }
    
    /**
    Get next view controller
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! WelcomeScreenContentViewController
        
        updateDots(itemController.itemIndex)
        if itemController.itemIndex + 1 < screens.count {
            return getItemController(itemController.itemIndex+1)
        }
        
        return nil
    }
    
    /**
    Update dots indicator
    */
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
        previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
            for vc in pageViewController.viewControllers {
                if let v = vc as? WelcomeScreenContentViewController {
                    updateDots(v.itemIndex)
                }
            }
    }
    
    /**
    Update page indicators (dots)
    
    :param: currentPage current page index
    */
    func updateDots(currentPage: Int) {
        if self.screens.count > 0 {
            for view in pageControl.subviews {
                (view as? UIView)?.removeFromSuperview()
            }
            let dotSize: CGFloat = 10
            let dotSpace: CGFloat = 15
            for i in 0..<self.screens.count {
                let imageView = UIImageView(frame: CGRectMake((dotSize + dotSpace) * CGFloat(i), 0, dotSize, dotSize))
                imageView.image = UIImage(named: "dot" + (i == currentPage ? "Selected" : ""))
                pageControl.addSubview(imageView)
            }
            pageControl.setNeedsDisplay()
        }
    }
}
