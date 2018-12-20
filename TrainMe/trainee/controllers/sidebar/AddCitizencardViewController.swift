//
//  AddCitizencardViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 16/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth

class AddCitizencardViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var citizencardImg: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nextBtn.layer.cornerRadius = 17
        
        print("---\(String(describing: Auth.auth().currentUser?.displayName))---\(String(describing: Auth.auth().currentUser?.email))---\(String(describing: Auth.auth().currentUser?.uid))")
        
        citizencardImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectCitizenImg)))
        self.HideKeyboard()
    }

    @objc func handleSelectCitizenImg() {
        
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print(info["UIImagePickerControllerOriginalImage"])
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            citizencardImg.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        print("cancel")
        dismiss(animated: true, completion: nil)
    }

    @IBAction func nextBtnAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "AddCitizencardToAddCertificate", sender: self)
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
