//
//  RegisterViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 21/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var fullnameView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullnameView.layer.cornerRadius = 17
        nextBtn.layer.cornerRadius = 17
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let register2Vc = segue.destination as? Register2ViewController {
            register2Vc.str = "dfgDFGDFG"
        }
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
        nextTransition(segueId: "RegisterToRegister2")
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
