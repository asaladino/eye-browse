//
//  NavigationViewController.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/19/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    enum MSPaneViewControllerType: Int {
        case browser
    }
    
    var paneViewControllerIdentifiers  = [
        MSPaneViewControllerType.browser: "Browser"
    ]
    
    var paneViewControllerType: MSPaneViewControllerType!
    var dynamicsDrawerViewController: MSDynamicsDrawerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func transitionToViewController(_ paneViewControllerType: MSPaneViewControllerType) {
        // Close pane if already displaying the pane view controller
        if self.paneViewControllerType != nil && paneViewControllerType == self.paneViewControllerType {
            self.dynamicsDrawerViewController.setPaneState(MSDynamicsDrawerPaneState.closed, animated: true, allowUserInterruption: true, completion: nil)
            return
        }
        
        let animateTransition = self.dynamicsDrawerViewController.paneViewController != nil
        
        let paneViewController = self.storyboard!.instantiateViewController(
            withIdentifier: self.paneViewControllerIdentifiers[paneViewControllerType]!) as! BaseViewController
        
        paneViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController
            
        self.dynamicsDrawerViewController.setPane(paneViewController, animated:animateTransition, completion:nil)
        self.paneViewControllerType = paneViewControllerType
    }
    
    
}
