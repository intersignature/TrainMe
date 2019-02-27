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
import FirebaseAuth
import CropViewController

class EditProfileTraineeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var weightTf: UITextField!
    @IBOutlet weak var heightTf: UITextField!
    @IBOutlet weak var changePasswordBtn: UIButton!
    @IBOutlet weak var changeLb: UILabel!
    @IBOutlet weak var seperateView1: UIView!
    @IBOutlet weak var seperateView2: UIView!
    @IBOutlet weak var seperateView3: UIView!
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var traineeProfile: UserProfile!
    var checkNewImage: Bool = false
    var successTask: [String] = []
    var currentUser: User = Auth.auth().currentUser!
    
    private var croppingStyle = CropViewCroppingStyle.circular
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImg.contentMode = .scaleAspectFit
        self.ref = Database.database().reference()
        self.storageRef = Storage.storage().reference()
        self.changePasswordBtn.layer.cornerRadius = 17
        print("EditProfileTraineeViewController \(self.traineeProfile)")
        
        self.HideKeyboard()
        self.profileImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImg)))
        self.changeLb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImg)))
        self.setProfileImageRound()
        self.setOldProfileToTextfield()
        
        let providerData = self.currentUser.providerData
        print("providerData: \(providerData[0].providerID)")
        if providerData[0].providerID == "facebook.com" {
            self.changePasswordBtn.isHidden = true
        }
    }
    
    @objc func handleSelectProfileImg() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "From camera", style: .default, handler: { (action) in
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .camera
            imgPicker.allowsEditing = false
            self.present(imgPicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "From photo library", style: .default, handler: { (action) in
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .photoLibrary
            imgPicker.allowsEditing = false
            self.present(imgPicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        print(info["UIImagePickerControllerOriginalImage"])
        
//        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            self.profileImg.image = image
//            self.checkNewImage = true
//        }
//        dismiss(animated: true, completion: nil)
        
        guard let image = (info[UIImagePickerControllerOriginalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        cropController.aspectRatioPreset = .presetSquare
        cropController.aspectRatioLockEnabled = true
        cropController.resetAspectRatioEnabled = false
        cropController.aspectRatioPickerButtonHidden = true

//        self.profileImg.image = image
        
        if croppingStyle == .circular {
            if picker.sourceType == .camera {
                picker.dismiss(animated: true, completion: {
                    self.present(cropController, animated: true, completion: nil)
                })
            } else {
                picker.pushViewController(cropController, animated: true)
            }
        }
        else { //otherwise dismiss, and then present from the main controller
            picker.dismiss(animated: true, completion: {
                self.present(cropController, animated: true, completion: nil)
                //self.navigationController!.pushViewController(cropController, animated: true)
            })
        }
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        profileImg.image = image
        self.checkNewImage = true
        layoutImageView()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        if cropViewController.croppingStyle != .circular {
            profileImg.isHidden = true
            
            cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                   toView: profileImg,
                                                   toFrame: CGRect.zero,
                                                   setup: { self.layoutImageView() },
                                                   completion: { self.profileImg.isHidden = false })
        }
        else {
            self.profileImg.isHidden = false 
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    public func layoutImageView() {
        guard profileImg.image != nil else { return }
        
        let padding: CGFloat = 20.0
        
        var viewFrame = self.view.bounds
        viewFrame.size.width -= (padding * 2.0)
        viewFrame.size.height -= ((padding * 2.0))
        
        var imageFrame = CGRect.zero
        imageFrame.size = profileImg.image!.size;
        
        if profileImg.image!.size.width > viewFrame.size.width || profileImg.image!.size.height > viewFrame.size.height {
            let scale = min(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height)
            imageFrame.size.width *= scale
            imageFrame.size.height *= scale
            imageFrame.origin.x = (self.view.bounds.size.width - imageFrame.size.width) * 0.5
            imageFrame.origin.y = (self.view.bounds.size.height - imageFrame.size.height) * 0.5
            profileImg.frame = imageFrame
        }
        else {
            self.profileImg.frame = imageFrame;
            self.profileImg.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        }
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
    
    @IBAction func saveBtnAction(_ sender: UIBarButtonItem) {
        
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
            
            if from == "Image" {
                let changeRequest = self.currentUser.createProfileChangeRequest()
                changeRequest.photoURL = URL(string: url)
                changeRequest.commitChanges(completion: { (err) in
                    if let err = err {
                        self.view.removeBluerLoader()
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                        print(err.localizedDescription)
                        return
                    }
                })
                self.profileImg.saveToCache(imageStringUrl: url)
            } else if from == "Data" {
                let changeRequest = self.currentUser.createProfileChangeRequest()
                changeRequest.displayName = self.nameTf.text!
                changeRequest.commitChanges(completion: { (err) in
                    if let err = err {
                        self.view.removeBluerLoader()
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                        print(err.localizedDescription)
                        return
                    }
                })
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
        
        self.nameTf.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.weightTf.attributedPlaceholder = NSAttributedString(string: "Weight", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.heightTf.attributedPlaceholder = NSAttributedString(string: "Height", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        self.seperateView1.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        self.seperateView2.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        self.seperateView3.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
}
