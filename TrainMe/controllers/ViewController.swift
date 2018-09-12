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
import SwiftyJSON
import FirebaseStorage
import FirebaseDatabase

class ViewController: UIViewController {
    
    var name: String?
    var email: String?
    var gender: String?
    var dateOfBirth: String?
    var profilePicture: UIImage?
    
    @IBOutlet weak var alreadyUser: UILabel!
    
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var facebookSignupBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signupBtn.layer.cornerRadius = 17
        facebookSignupBtn.layer.cornerRadius = 17
        loginBtn.layer.cornerRadius = 17
        
        setLocalizeText()
        
        facebookSignupBtn.addTarget(self, action: #selector(handleSignInWithFacebook), for: .touchUpInside)
    }
    
    func setLocalizeText() {
        
        signupBtn.setTitle(NSLocalizedString("signup_email", comment: ""), for: .normal)
        facebookSignupBtn.setTitle(NSLocalizedString("signup_facebook", comment: ""), for: .normal)
        loginBtn.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
        alreadyUser.text = NSLocalizedString("already_user", comment: "")
    }

    @objc func handleSignInWithFacebook() {
        
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email, .userBirthday, .userGender], viewController: self) { (result) in
            switch result {
                case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                    print("Success login with facebook")
                    print()
                    self.view.showBlurLoader()
                    self.signIntoFirebase()
//                    self.performSegue(withIdentifier: "WelcomeToMain", sender: nil)
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
//            if !self.checkProfileInfo() {
//                self.fetchFacebookUser()
//            }
            self.checkProfileInfo()
    
//            print(Auth.auth().currentUser?.email)
//            print(Auth.auth().currentUser?.displayName) //-> fullname
//            print(Auth.auth().currentUser?.photoURL)
//            print(Auth.auth().currentUser?.description) //-> role
        }
    }
    
    func checkProfileInfo() {
        
        let userID = Auth.auth().currentUser?.uid
        Database.database().reference().child("user").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.childrenCount == 0 {
                self.fetchFacebookUser()
            } else {
//                self.dismiss(animated: false, completion: nil)
                self.view.removeBluerLoader()
                self.performSegue(withIdentifier: "WelcomeToMain", sender: nil)
            }
//            self.fetchFacebookUser()
        }
    }
    
    fileprivate func fetchFacebookUser() {
        
        let graphRequestConnection = GraphRequestConnection()
        let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, picture.type(large),gender,birthday"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: .defaultVersion)
        graphRequestConnection.add(graphRequest) { (httpResponse, result) in
            switch result {
            case .success(let response):
                guard let responseDictionary = response.dictionaryValue else {return}
                
                let json = JSON(responseDictionary)
                self.name = json["name"].string
                self.email = json["email"].string
                self.gender = json["gender"].string
                self.dateOfBirth = json["birthday"].string
                guard let profilePictureUrl = json["picture"]["data"]["url"].string else {return}
                print(json["picture"].string)
                guard let url = URL(string: profilePictureUrl) else {return}
                
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    guard let data = data else {return}
                    self.profilePicture = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.saveUserIntoFirebase()
                    }
                    
                }).resume()
                break
            case .failed(let err):
                print(err)
                break
            }
        }
        graphRequestConnection.start()
    }
    
    fileprivate func saveUserIntoFirebase() {
        
        guard let profilePicture = self.profilePicture else {return}
        guard let uploadData = UIImageJPEGRepresentation(profilePicture, 0.7) else {return}
        
        Storage.storage().reference().child("profile").child((Auth.auth().currentUser?.uid)!).child("imageProfile"+".jpg").putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                print(err)
                return
            }
            
            print("Successfully saved profile image into firebase storage!")
            
            let profileImageUrlRef = Storage.storage().reference().child("profile").child((Auth.auth().currentUser?.uid)!).child("imageProfile"+".jpg")
            profileImageUrlRef.downloadURL(completion: { (url, err) in
                if let err = err {
                    print(err)
                    return
                }
                
                guard let uid = Auth.auth().currentUser?.uid else {return}
                let dictionaryValues = ["role": "trainer",
                                        "name": self.name,
                                        "email": self.email,
                                        "dateOfBirth": self.dateOfBirth,
                                        "weight": "-1",
                                        "height": "-1",
                                        "gender": self.gender,
                                        "profileImageUrl": url?.absoluteString]
                let values = [uid: dictionaryValues]
                
                let profileChangeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                profileChangeRequest?.photoURL = url
                profileChangeRequest?.commitChanges(completion: { (err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    print("displaynameaa: \(Auth.auth().currentUser?.displayName)")
                    print("displaynameaa: \(Auth.auth().currentUser?.photoURL?.absoluteString)")
                })
                
                Database.database().reference().child("user").updateChildValues(values, withCompletionBlock: { (err, reference) in
                    if let err = err {
                        print(err)
                        return
                    }
                    print("Successfully saved user info into firebase database!")
                    self.view.removeBluerLoader()
//                    self.dismiss(animated: false, completion: nil)
                    self.performSegue(withIdentifier: "WelcomeToMain", sender: nil)
                })
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
