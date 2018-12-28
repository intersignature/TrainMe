//
//  EditProfileTraineeViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 28/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import DTTextField
import FirebaseDatabase
import FirebaseStorage

class EditProfileTraineeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameTf: DTTextField!
    @IBOutlet weak var weightTf: DTTextField!
    @IBOutlet weak var heightTf: DTTextField!
    @IBOutlet weak var changePasswordBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var changeLb: UILabel!
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var traineeProfile: UserProfile!
    var checkNewImage: Bool = false
    var successTask: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        self.storageRef = Storage.storage().reference()
        self.changePasswordBtn.layer.cornerRadius = 17
        self.saveBtn.layer.cornerRadius = 17
        print("EditProfileTraineeViewController \(self.traineeProfile)")
        
        self.HideKeyboard()
        self.profileImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImg)))
        self.changeLb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImg)))
        self.setProfileImageRound()
        self.setOldProfileToTextfield()
    }
    
    @objc func handleSelectProfileImg() {
        
        print("handleSelectProfileImg")
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info["UIImagePickerControllerOriginalImage"])
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImg.image = image
            self.checkNewImage = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func setOldProfileToTextfield() {
        
        self.profileImg.downloaded(from: self.traineeProfile.profileImageUrl)
        self.nameTf.text = self.traineeProfile.fullName
        self.weightTf.text = self.traineeProfile.weight
        self.heightTf.text = self.traineeProfile.height
    }
    
    @IBAction func changePasswordBtnAction(_ sender: UIButton) {
    }
    
    @IBAction func saveBtnAction(_ sender: UIButton) {
        
        self.view.showBlurLoader()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if self.checkNewProfileData() {
            self.changeDataToDatabase(from: "Data", url: "")
            if self.checkNewImage {
                self.uploadImageProfileToStorage()
            }
        } else {
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.createAlert(alertTitle: "Please fill in blank", alertMessage: "")
        }
    }
    
    func checkNewProfileData() -> Bool {
        if self.nameTf.text == "" || self.weightTf.text == "" || self.heightTf.text == "" {
            return false
        }
        return true
    }
    
    func changeDataToDatabase(from: String, url: String) {
        
        var changeData: [String: String] = [:]
        
        if from == "Image" {
            changeData = ["profileImageUrl": url]
        } else if from == "Data"{
            changeData = ["name": self.nameTf.text!,
            "weight": self.weightTf.text!,
            "height": self.heightTf.text!]
        }
        
        self.ref.child("user").child(self.traineeProfile.uid).updateChildValues(changeData) { (err, ref) in
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print(err.localizedDescription)
                return
            }
            self.successTask.append(from)
            
            if (self.checkNewImage && self.successTask.contains("Image") && self.successTask.contains("Data")) || (self.checkNewImage == false && self.successTask.contains("Data")) {
                
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                let alert = UIAlertController(title: "Change profile data successfully", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func uploadImageProfileToStorage() {
        
        if let uploadImg = UIImagePNGRepresentation(self.profileImg.image!) {
            let uploadRef = self.storageRef.child("profile").child(self.traineeProfile.uid).child("imageProfile.png")
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            uploadRef.putData(uploadImg, metadata: metadata) { (metadata, err) in
                if let err = err {
                    self.view.removeBluerLoader()
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                    print(err.localizedDescription)
                    return
                }
                uploadRef.downloadURL(completion: { (url, err) in
                    if let err = err {
                        self.view.removeBluerLoader()
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                        print(err.localizedDescription)
                        return
                    }
                    self.changeDataToDatabase(from: "Image", url: (url?.absoluteString)!)
                })
            }
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setProfileImageRound() {
        
        self.profileImg.layer.masksToBounds = false
        self.profileImg.layer.cornerRadius = self.profileImg.frame.height / 2
        self.profileImg.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
}
