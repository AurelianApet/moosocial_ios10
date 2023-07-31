//
//  BlueViewController.swift
//  mooApp
//
//  Created by tuan on 5/4/17.
//  Copyright © 2017 tuan. All rights reserved.
//

import UIKit

class SliderThreeViewController: UIViewController {

    @IBOutlet var sliderIcon: UIImageView!
    @IBOutlet var sliderDes: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set background
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "slider.bg3")
        self.view.insertSubview(backgroundImage, at: 0)
        
        //set icon
        sliderIcon.backgroundColor = UIColor(patternImage: UIImage(named: "slider.icon3")!)
        
        //set text
        sliderDes.text = NSLocalizedString("landing_slider_description_three",comment:"landing_slider_description_three")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
