//
//  SnapContainerViewController.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/1/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit

// MARK: - Class
class SnapContainerViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    var topVC: UIViewController?
    var leftVC: UIViewController!
    var middleVC: UIViewController!
    var rightVC: UIViewController!
    var bottomVC: UIViewController?
    
    var directionLockDisabled: Bool!
    
    var initialContentOffset = CGPoint() // scrollView initial offset
    //var middleVertScrollVc: VerticalScrollViewController!
    
    var scrollView: UIScrollView!
    var delegate: SnapContainerViewDelegate?
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupVerticalScrollView()
        setupHorizontalScrollView()
    }
    
    // MARK: - SnapViewController
    
    /// Create a SnapContainerViewController given the string identifiers for the 4 view controllers
    class func containerViewWith(left: String, middle: String, right: String, top: String?=nil, bottom: String?=nil, directionLockDisabled: Bool=false) -> SnapContainerViewController? {
        
        let storyboard = UIStoryboard(name: Constants.mainStoryboard, bundle: nil)
        
        guard var leftVC = storyboard.instantiateViewController(withIdentifier: left) as? (UIViewController & SnapContainerViewElement) else {
            return nil
        }
        guard var middleVC = storyboard.instantiateViewController(withIdentifier: middle) as? (UIViewController & SnapContainerViewElement) else {
            return nil
        }
        guard var rightVC = storyboard.instantiateViewController(withIdentifier: right) as? (UIViewController & SnapContainerViewElement) else {
            return nil
        }
        let topVC = top != nil ? storyboard.instantiateViewController(withIdentifier: top!) : nil
        let bottomVC = bottom != nil ? storyboard.instantiateViewController(withIdentifier: bottom!) : nil
        
        let snapContainer = SnapContainerViewController()
        
        snapContainer.directionLockDisabled = directionLockDisabled
        
        snapContainer.topVC = topVC
        snapContainer.leftVC = leftVC
        snapContainer.middleVC = middleVC
        snapContainer.rightVC = rightVC
        snapContainer.bottomVC = bottomVC
        
        middleVC.snapContainer = snapContainer
        rightVC.snapContainer = snapContainer
        leftVC.snapContainer = snapContainer
        
        return snapContainer
    }
    
    class func containerViewWith(leftVC: (UIViewController & SnapContainerViewElement), middleVC: (UIViewController & SnapContainerViewElement), rightVC: (UIViewController & SnapContainerViewElement), topVC: UIViewController?=nil,
                                 bottomVC: UIViewController?=nil, directionLockDisabled: Bool?=false) -> SnapContainerViewController {
        let snapContainer = SnapContainerViewController()
        
        snapContainer.directionLockDisabled = directionLockDisabled
        
        snapContainer.topVC = topVC
        snapContainer.leftVC = leftVC
        snapContainer.middleVC = middleVC
        snapContainer.rightVC = rightVC
        snapContainer.bottomVC = bottomVC
        
        return snapContainer
    }
    
    /// Initialize the vertical scroll view
    func setupVerticalScrollView() {
        //middleVertScrollVc = VerticalScrollViewController.verticalScrollVcWith(middleVc: middleVC, topVc: topVC, bottomVc: bottomVC)
        //delegate = middleVertScrollVc
    }
    
    /// Initialize the horizontal scroll view
    func setupHorizontalScrollView() {
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        
        let view = (x: self.view.bounds.origin.x, y: self.view.bounds.origin.y,
                    width: self.view.bounds.width, height: self.view.bounds.height)
        
        scrollView.frame = self.view.frame
        self.view.addSubview(scrollView)
        
        scrollView.contentSize = CGSize(width: 3 * view.width, height: view.height)
        
        leftVC.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        middleVC.view.frame = CGRect(x: view.width, y: 0, width: view.width, height: view.height)
        rightVC.view.frame = CGRect(x: 2 * view.width, y: 0, width: view.width, height: view.height)
        
        addChildViewController(leftVC)
        addChildViewController(middleVC)
        addChildViewController(rightVC)
        
        scrollView.addSubview(leftVC.view)
        scrollView.addSubview(middleVC.view)
        scrollView.addSubview(rightVC.view)
        
        leftVC.didMove(toParentViewController: self)
        middleVC.didMove(toParentViewController: self)
        rightVC.didMove(toParentViewController: self)
        
        scrollView.contentOffset.x = middleVC.view.frame.origin.x
        scrollView.delegate = self
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.initialContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if delegate != nil && !delegate!.outerScrollViewShouldScroll() && !directionLockDisabled {
            let newOffset = CGPoint(x: self.initialContentOffset.x, y: self.initialContentOffset.y)
            
            // Setting the new offset to the scrollView makes it behave like a proper
            // directional lock, that allows you to scroll in only one direction at any given time
            self.scrollView!.setContentOffset(newOffset, animated:  false)
        }
    }
    
    
    func move(to: String) {
        switch to {
        case "right":
            scrollView.setContentOffset(rightVC.view.frame.origin, animated: true)
            break
            
        case "middle":
            scrollView.setContentOffset(middleVC.view.frame.origin, animated: true)
            break
            
        case "left":
            scrollView.setContentOffset(leftVC.view.frame.origin, animated: true)
            break
            
        default:
            fatalError("Not a valid position")
        }
    
    }
    
    // MARK: - Status Bar: Hide
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}

// MARK: - Protocol
protocol SnapContainerViewDelegate {
    func outerScrollViewShouldScroll() -> Bool
}

protocol SnapContainerViewElement {
    var snapContainer: SnapContainerViewController! {get set}
}
