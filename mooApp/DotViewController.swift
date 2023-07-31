//
//  DotViewController.swift
//  mooApp
//
//  Created by tuan on 5/4/17.
//  Copyright © 2017 tuan. All rights reserved.
//

import UIKit

class DotViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var btnSignup: UIButton!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var btnPrivacy: UIButton!
    @IBOutlet var btnTerm: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sliderPageViewController = segue.destination as? SliderPageViewController {
            sliderPageViewController.sliderDelegate = self
        }
        
        //set text
        btnSignup.setTitle(NSLocalizedString("landing_sign_up",comment:"landing_sign_up"), for: UIControlState())
        btnLogin.setTitle(NSLocalizedString("landing_login",comment:"landing_login"), for: UIControlState())
        btnPrivacy.setTitle(NSLocalizedString("landing_privacy",comment:"landing_privacy"), for: UIControlState())
        btnTerm.setTitle(NSLocalizedString("landing_term_of_service",comment:"landing_term_of_service"), for: UIControlState())
    }

    //Mark: Actions
    //@IBAction func onTouchLoginButton(_ sender: AnyObject) {
        //go to page
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "login")
        self.present(vc, animated: true, completion: nil)*/
        //self.performSegue(withIdentifier: "sequeShowLogin", sender: self)
    //}
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
}

extension DotViewController: SliderPageViewControllerDelegate {
    
    @objc(sliderPageViewControllerWithSliderPageViewController:idUpdatePageCount:) func sliderPageViewController(sliderPageViewController tutorialPageViewController: SliderPageViewController, idUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    @objc(sliderPageViewControllerWithSliderPageViewController:didUpdatePageIndex:) func sliderPageViewController(sliderPageViewController tutorialPageViewController: SliderPageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}
