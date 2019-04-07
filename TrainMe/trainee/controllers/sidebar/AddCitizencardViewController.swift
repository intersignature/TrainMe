//
//  AddCitizencardViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 16/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import CropViewController
import FirebaseDatabase
import FirebaseStorage

class AddCitizencardViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {

    @IBOutlet weak var citizencardImg: UIImageView!
    @IBOutlet weak var citizenTrueCopyLb: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    
    private var croppingStyle = CropViewCroppingStyle.default
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    var selectedCertificates: [Certificate] = []
    
    var dbRef: DatabaseReference!
    var storeRef: StorageReference!
    var successfulTask: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dbRef = Database.database().reference()
        self.storeRef = Storage.storage().reference()
        
        saveBtn.layer.cornerRadius = 17
        
        print("---\(String(describing: Auth.auth().currentUser?.displayName))---\(String(describing: Auth.auth().currentUser?.email))---\(String(describing: Auth.auth().currentUser?.uid))")
        
        citizencardImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectCitizenImg)))
        self.HideKeyboard()
    }

    @objc func handleSelectCitizenImg() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "from_camera".localized(), style: .default, handler: { (action) in
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .camera
            imgPicker.allowsEditing = false
            self.present(imgPicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "from_photo_library".localized(), style: .default, handler: { (action) in
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .photoLibrary
            imgPicker.allowsEditing = false
            self.present(imgPicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
//        print(info["UIImagePickerControllerOriginalImage"])
//
//        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            citizencardImg.image = image
//        }
//        dismiss(animated: true, completion: nil)
        
        guard let image = (info[UIImagePickerControllerOriginalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        
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
        citizencardImg.image = image
        layoutImageView()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        if cropViewController.croppingStyle != .circular {
            citizencardImg.isHidden = true
            
            cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                   toView: citizencardImg,
                                                   toFrame: CGRect.zero,
                                                   setup: { self.layoutImageView() },
                                                   completion: { self.citizencardImg.isHidden = false })
        }
        else {
            self.citizencardImg.isHidden = false
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    public func layoutImageView() {
        guard citizencardImg.image != nil else { return }
        
        let padding: CGFloat = 20.0
        
        var viewFrame = self.view.bounds
        viewFrame.size.width -= (padding * 2.0)
        viewFrame.size.height -= ((padding * 2.0))
        
        var imageFrame = CGRect.zero
        imageFrame.size = citizencardImg.image!.size;
        
        if citizencardImg.image!.size.width > viewFrame.size.width || citizencardImg.image!.size.height > viewFrame.size.height {
            let scale = min(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height)
            imageFrame.size.width *= scale
            imageFrame.size.height *= scale
            imageFrame.origin.x = (self.view.bounds.size.width - imageFrame.size.width) * 0.5
            imageFrame.origin.y = (self.view.bounds.size.height - imageFrame.size.height) * 0.5
            citizencardImg.frame = imageFrame
        }
        else {
            self.citizencardImg.frame = imageFrame;
            self.citizencardImg.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        print("cancel")
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveBtnAction(_ sender: UIButton) {
        
        if self.citizencardImg.image != nil {
            self.view.showBlurLoader()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.uploadFileToStorage()
        } else {
            self.createAlert(alertTitle: "please_select_citizen_card_image".localized(), alertMessage: "")
        }
    }
    
    func uploadFileToStorage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        if let uploadImg = UIImagePNGRepresentation(self.citizencardImg.image!) {
            let uploadCitizenTask = self.storeRef.child("BecomeToATrainer").child(uid).child("citizen.png").putData(uploadImg, metadata: metadata) { (metadata, err) in
                if let err = err {
                    self.view.removeBluerLoader()
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                    print(err.localizedDescription)
                    return
                }
                print(metadata)
            }
            uploadCitizenTask.observe(.progress) { (snapshot) in
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                    / Double(snapshot.progress!.totalUnitCount)
                print("uploadtask: \(snapshot.reference.name)")
                print("uploadtask: \(percentComplete)")
            }
            uploadCitizenTask.observe(.success) { (snapshot) in
                print("uploadsuccesstask: \(snapshot.reference.name)")
                self.successfulTask.append(snapshot.reference.name)
                print("successfulTask: \(self.successfulTask)")
                self.checkSuccesfulUploadImageFileToStorage()
            }
        }
        
        var countCertFilename = 1
        let strRef = self.storeRef.child("BecomeToATrainer").child(uid).child("certificate")
        self.selectedCertificates.forEach { (cert) in
            if let uploadCert = UIImagePNGRepresentation(cert.certImg) {
                let uploadCertTask = strRef.child("cert_\(countCertFilename).png").putData(uploadCert, metadata: metadata, completion: { (metadata, err) in
                    if let err = err {
                        self.view.removeBluerLoader()
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                        print(err)
                        return
                    }
                })
                uploadCertTask.observe(.progress, handler: { (snapshot) in
                    let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                        / Double(snapshot.progress!.totalUnitCount)
                    print("uploadtask: \(snapshot.reference.name)")
                    print("uploadtask: \(percentComplete)")
                })
                uploadCertTask.observe(.success, handler: { (snapshot) in
                    print("uploadsuccesstask: \(snapshot.reference.name)")
                    self.successfulTask.append(snapshot.reference.name)
                    print("successfulTask: \(self.successfulTask)")
                    self.checkSuccesfulUploadImageFileToStorage()
                })
            }
            countCertFilename += 1
        }
    }
    
    func checkSuccesfulUploadImageFileToStorage() {
        var checkFile = true
        for i in 1...self.selectedCertificates.count {
            if !self.successfulTask.contains("cert_\(i).png") || !self.successfulTask.contains("citizen.png") {
                checkFile = false
                break
            }
        }
        if checkFile {
            self.uploadDataToDatabase()
        }
    }
    
    func uploadDataToDatabase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var countCertDb = 1
        var certDic: [String: String] = [:]
        self.selectedCertificates.forEach { (cert) in
            certDic["cert\(countCertDb)"] = cert.certDetail
            countCertDb += 1
        }
        certDic["status"] = "pending"
        
        self.dbRef.child("become_to_a_trainer").child(uid).updateChildValues(certDic) { (err, ref) in
            if let err = err {
                self.view.removeBluerLoader()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print(err.localizedDescription)
                return
            }
            self.view.removeBluerLoader()
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            let alert = UIAlertController(title: "successful_add_trainer_request".localized(), message: "please_wait_for_admin_approve".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "AddCitizenToMain", sender: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            print("successfully add BecomeToATrainer to database")
        }
        
        certDic.forEach { (key, value) in
            print("\(key)------------\(value)")
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.setupNavigationStyle()
        
        self.title = "add_citizencard".localized()
        self.citizenTrueCopyLb.text = "citizen_card_true_copy_detail".localized()
        self.saveBtn.setTitle("save".localized(), for: .normal)
        
        self.citizencardImg.layer.cornerRadius = 5
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        citizencardImg.removeGestureRecognizer(UITapGestureRecognizer())
    }
}
