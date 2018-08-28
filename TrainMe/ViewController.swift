//
//  ViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 21/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth


class ViewController: UIViewController {

    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var facebookSignupBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        signupBtn.layer.cornerRadius = 17
        facebookSignupBtn.layer.cornerRadius = 17
        loginBtn.layer.cornerRadius = 17
        
        facebookSignupBtn.addTarget(self, action: #selector(handleSignInWithFacebook), for: .touchUpInside)
        // Do any additional setup after loading the view, typically from a nib.
    
    }

    @objc func handleSignInWithFacebook() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email, .userBirthday, .userGender], viewController: self) { (result) in
            switch result {
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                print("Success login with facebook")
                self.signIntoFirebase()
            case .failed(let err):
                print(err)
            case .cancelled:
                print("Cancel")
            }
        }
    }
    
    fileprivate func signIntoFirebase() {
        guard let authenticationToken = AccessToken.current?.authenticationToken else { return }
        let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (user, err) in
            if let err = err {
                print(err)
                return
            }
//            print(Auth.auth().currentUser?.email)
//            print(Auth.auth().currentUser?.displayName)
//            print(Auth.auth().currentUser?.metadata.description)
//            print(Auth.auth().currentUser?.photoURL)
//            print(Auth.auth().currentUser?.providerData)
//            print(Auth.auth().currentUser?.description)
            
//            Optional("intersignature_facebook@hotmail.com")
//            Optional("Sirichai Drink Binchai")
//            Optional("<FIRUserMetadata: 0x113dee4d0>")
//            Optional(https://graph.facebook.com/667305620307273/picture)
//                Optional([<FIRUserInfoImpl: 0x115e448f0>])
//                Optional("<FIRUser: 0x115d91850>")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

