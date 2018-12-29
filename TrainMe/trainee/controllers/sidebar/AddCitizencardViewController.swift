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

class AddCitizencardViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {

    @IBOutlet weak var citizencardImg: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    
    private var croppingStyle = CropViewCroppingStyle.default
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nextBtn.layer.cornerRadius = 17
        
        print("---\(String(describing: Auth.auth().currentUser?.displayName))---\(String(describing: Auth.auth().currentUser?.email))---\(String(describing: Auth.auth().currentUser?.uid))")
        
        citizencardImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectCitizenImg)))
        self.HideKeyboard()
    }

    @objc func handleSelectCitizenImg() {
        
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

    @IBAction func nextBtnAction(_ sender: UIButton) {
        if self.citizencardImg.image != nil {
            self.performSegue(withIdentifier: "AddCitizencardToAddCertificate", sender: self)
        } else {
            self.createAlert(alertTitle: "Please select citizen image", alertMessage: "")
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "AddCitizencardToAddCertificate") {
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! AddCertificateViewController
            containVc.citizenImg = self.citizencardImg.image
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        citizencardImg.removeGestureRecognizer(UITapGestureRecognizer())
    }
}
