//
//  Register2ViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 22/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class Register2ViewController: UIViewController {

    @IBOutlet weak var text: UILabel!
    var str = String()
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var verifyPasswordView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        text.text = str
        
        emailView.layer.cornerRadius = 17
        passwordView.layer.cornerRadius = 17
        verifyPasswordView.layer.cornerRadius = 17
        nextBtn.layer.cornerRadius = 17
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let register3Vc = segue.destination as? Register3ViewController {
            
        }
    }
    
    func backTrainsition(segueId: String) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }
    
    func nextTransition(segueId: String) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        view.window!.layer.add(transition, forKey: kCATransition)
        performSegue(withIdentifier: segueId, sender: self)
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        backTrainsition(segueId: "Register2ToRegister")
    }
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
        nextTransition(segueId: "Register2ToRegister3")
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
