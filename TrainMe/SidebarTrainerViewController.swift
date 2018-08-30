//
//  SidebarViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 27/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

class SidebarTrainerViewController: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var emailLb: UILabel!
    @IBOutlet weak var userProfileBtn: UIButton!
    @IBOutlet weak var creditcardBtn: UIButton!
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var becomeATrainerBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    
    @IBAction func logoutBtnAction(_ sender: UIButton) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "LogoutSeg", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setProfileImageRound()

        print(Auth.auth().currentUser?.displayName)
        print(Auth.auth().currentUser?.photoURL?.absoluteString)
        
        nameLb.text = Auth.auth().currentUser?.displayName
        emailLb.text = Auth.auth().currentUser?.email
        
        setLocalizeText()
        
        if Auth.auth().currentUser?.photoURL != nil {
            profileImg.downloaded(from: (Auth.auth().currentUser?.photoURL)!)
        } else {
            // profileImg.downloaded(from: (Auth.auth().currentUser?.photoURL)!) -> use default image link
        }
        // Do any additional setup after loading the view.
    }

    func setLocalizeText() {
        userProfileBtn.setTitle(NSLocalizedString("user_profile", comment: ""), for: .normal)
        creditcardBtn.setTitle(NSLocalizedString("credit_card_paypal", comment: ""), for: .normal)
        helpBtn.setTitle(NSLocalizedString("help", comment: ""), for: .normal)
        settingsBtn.setTitle(NSLocalizedString("settings", comment: ""), for: .normal)
        becomeATrainerBtn.setTitle(NSLocalizedString("become_a_trainer", comment: ""), for: .normal)
        logoutBtn.setTitle(NSLocalizedString("logout", comment: ""), for: .normal)
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
