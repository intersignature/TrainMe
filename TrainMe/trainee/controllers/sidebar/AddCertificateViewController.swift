//
//  AddCertificateViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 18/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class AddCertificateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var certificateImg: UIImageView!
    @IBOutlet weak var certificateDetailTv: UITextView!
    @IBOutlet weak var cerificateTableView: UITableView!
    @IBOutlet weak var addCertBtn: UIButton!
    
    var citizenImg: UIImage!
    var selectedCerts: [Certificate] = []
    var selectCertImg = UIImage()
    var dbRef: DatabaseReference!
    var storeRef: StorageReference!
    var successfulTask: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dbRef = Database.database().reference()
        self.storeRef = Storage.storage().reference()
        self.cerificateTableView.delegate = self
        self.cerificateTableView.dataSource = self
        self.certificateDetailTv.delegate = self
        self.HideKeyboard()
        self.certificateImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectCitizenImg)))
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        certificateDetailTv.resignFirstResponder()
        return true
    }
    
    @objc func handleSelectCitizenImg() {
        
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info["UIImagePickerControllerOriginalImage"])
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            certificateImg.image = image
            self.selectCertImg = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedCerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "certificateCell") as! CertificateTableViewCell
        cell.setDataToCell(certificate: selectedCerts[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteBtn = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let chooseAlert = UIAlertController(title: "", message: "Would you like to delete this certificate?", preferredStyle: .actionSheet)
            chooseAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            chooseAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.selectedCerts.remove(at: indexPath.row)
                self.cerificateTableView.beginUpdates()
                self.cerificateTableView.deleteRows(at: [indexPath], with: .automatic)
                self.cerificateTableView.endUpdates()
                self.selectedCerts.forEach { print($0.getData()) }
            }))
            self.present(chooseAlert, animated: true, completion: nil)
        }
        return [deleteBtn]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }

    @IBAction func addCertBtnAction(_ sender: UIButton) {
        
        print("addCertBtnAction \(self.certificateImg.image)")
        if self.certificateImg.image != nil {
            let addCert = Certificate(certImg: selectCertImg, certDetail: self.certificateDetailTv.text)
            self.selectedCerts.append(addCert)
            self.cerificateTableView.reloadData()
            self.certificateImg.image = nil // Clear image
            self.certificateDetailTv.text = "Certificate detail"
            self.selectedCerts.forEach { print($0.getData()) }
        } else {
            self.createAlert(alertTitle: "Please select certificate image", alertMessage: "")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationStyle()
        self.navigationItem.leftBarButtonItem?.title = "Back"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.certificateImg.removeGestureRecognizer(UITapGestureRecognizer())
    }
    
    @IBAction func backBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnAction(_ sender: UIBarButtonItem) {

        if self.selectedCerts.count > 0 {
            self.view.showBlurLoader()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.uploadFileToStorage()
        } else {
            self.createAlert(alertTitle: "Please select certificate image", alertMessage: "")
        }
    }
    
    func uploadFileToStorage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        if let uploadImg = UIImagePNGRepresentation(self.citizenImg) {
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
        self.selectedCerts.forEach { (cert) in
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
        for i in 1...self.selectedCerts.count {
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
        self.selectedCerts.forEach { (cert) in
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
            let alert = UIAlertController(title: "Successful add trainer request", message: "Please wait for admin approve", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "AddCertificateToMain", sender: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            print("successfully add BecomeToATrainer to database")
        }
        
        certDic.forEach { (key, value) in
            print("\(key)------------\(value)")
        }
    }
}
