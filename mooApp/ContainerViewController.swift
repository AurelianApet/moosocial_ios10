//
//  ContainerViewController.swift
//  mooApp
//
//  Copyright (c) SocialLOFT LLC
//  mooSocial - The Web 2.0 Social Network Software
//  @website: http://www.moosocial.com
//  @author: mooSocial
//  @license: https://moosocial.com/license/
//

import UIKit
import QuartzCore

enum SlideOutState {
    case bothCollapsed
    case leftPanelExpanded
    case rightPanelExpanded
}

class ContainerViewController: UIViewController,HomeTabBarViewControllerDelegate {
    
    var centerNavigationController: UINavigationController!
    var centerViewController: HomeTabBarViewController!
    var centerViewAction = AppConstants.ACTION_DEFAULT_ON_HOME_TAB_BAR_CONTROLLER
    
    var currentState: SlideOutState = .bothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .bothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    var leftViewController: SidePanelViewController?
    var rightViewController: SidePanelViewController?
    
    let centerPanelExpandedOffset: CGFloat = 60
    var panGestureRecognizer:UIPanGestureRecognizer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if centerViewController == nil{
          
        }
        centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "fix_homeTabBar") as? HomeTabBarViewController
        
        centerViewController.action = centerViewAction
        centerViewController.delegateExt = self
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMove(toParentViewController: self)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ContainerViewController.handlePanGesture(_:)))
     
        //centerNavigationController.view.addGestureRecognizer(panGestureRecognizer!)
        
        //centerNavigationController.hidesBarsOnSwipe = true
        
    }
    
    // Hacking for homtabar tintColor
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // Mark : CenterViewController delegate
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func toggleRightPanel() {
        let notAlreadyExpanded = (currentState != .rightPanelExpanded)
        
        if notAlreadyExpanded {
            addRightPanelViewController()
        }
        
        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func collapseSidePanels() {
        switch (currentState) {
        case .rightPanelExpanded:
            toggleRightPanel()
        case .leftPanelExpanded:
            //toggleLeftPanel()
            break
        default:
            break
        }
    }
    func addGestureRecognizer(){
        
        if centerNavigationController.view.gestureRecognizers?.contains(panGestureRecognizer!) == false{
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer!)
        }
        
    }
    func removeGestureRecognizer(){
        if centerNavigationController.view.gestureRecognizers != nil {
            for gesture in centerNavigationController.view.gestureRecognizers! {
               
                if gesture == panGestureRecognizer{
                   
                centerNavigationController.view.removeGestureRecognizer(gesture)
                }
                
                    
                   
                
            }
        }
    }
    func addLeftPanelViewController() {
        /*
        if (leftViewController == nil) {
            leftViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LeftViewController") as? SidePanelViewController
//            leftViewController!.animals = Animal.allCats()
            
            addChildSidePanelController(leftViewController!)
        }
        */
    }
    
    func addChildSidePanelController(_ sidePanelController: SidePanelViewController) {
        sidePanelController.delegateEx = centerViewController
        
        view.insertSubview(sidePanelController.view, at: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMove(toParentViewController: self)
    }
    
    func addRightPanelViewController() {
        if (rightViewController == nil) {
            rightViewController = self.storyboard!.instantiateViewController(withIdentifier: "RightViewController") as? SidePanelViewController
            
            addChildSidePanelController(rightViewController!)
        }
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .leftPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .bothCollapsed
                
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil;
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateRightPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .rightPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: -centerNavigationController.view.frame.width + centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { _ in
                self.currentState = .bothCollapsed
                
                self.rightViewController!.view.removeFromSuperview()
                self.rightViewController = nil;
            }
        }
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    // Fixing bug Warning: Attempt to present UIIMagePickerController on mooApp whose view is not in the window hierrarchy!
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        if (self.presentedViewController != nil) {
            super.dismiss(animated: flag, completion: completion)
        }
    }
}


extension ContainerViewController: UIGestureRecognizerDelegate {
    // MARK: Gesture recognizer
    
    func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
        
        if centerViewController.selectedIndex != centerViewController.NOTIFICATION_TAB && centerViewController.selectedIndex != centerViewController.MESSAGE_TAB {
            switch(recognizer.state) {
            case .began:
                
                if (currentState == .bothCollapsed) {
                    if (gestureIsDraggingFromLeftToRight) {
                        addLeftPanelViewController()
                    } else {
                        addRightPanelViewController()
                    }
                    
                    showShadowForCenterViewController(true)
                }
                
                
                break
            case .changed:
                let velocity : CGPoint = recognizer.velocity(in: view)
                if (currentState == .bothCollapsed && velocity.x < 0) ||  currentState == .rightPanelExpanded {
                    recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translation(in: view).x
                    recognizer.setTranslation(CGPoint.zero, in: view)
                }
            case .ended:
                
                if (leftViewController != nil) {
                    // animate the side panel open or closed based on whether the view has moved more or less than halfway
                    let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                    animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
                } else if (rightViewController != nil) {
                    let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
                    animateRightPanel(shouldExpand: hasMovedGreaterThanHalfway)
                }
                
                break
            default:
                break
            }
        }
        
    }
}
