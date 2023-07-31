//
//  EmojiViewController.swift
//  mooApp
//
//  Created by tuan on 7/13/17.
//  Copyright © 2017 moosocialloft. All rights reserved.
//

import UIKit

class EmojiViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let customView = Bundle.main.loadNibNamed("Emoji", owner: self, options: nil)?.first as? EmojiView {
            self.view.addSubview(customView)
        }
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
