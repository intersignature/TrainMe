//
//  SidebarViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 27/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class SidebarViewController: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProfileImageRound()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setProfileImageRound() {
        profileImg.layer.borderWidth = 10
        profileImg.layer.masksToBounds = false
        profileImg.layer.borderColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1).cgColor
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        profileImg.clipsToBounds = true
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
