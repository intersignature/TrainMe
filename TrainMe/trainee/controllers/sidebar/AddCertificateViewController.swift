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
        
        let addCert = Certificate(certImg: selectCertImg, certDetail: self.certificateDetailTv.text)
        self.selectedCerts.append(addCert)
        self.cerificateTableView.reloadData()
        self.selectedCerts.forEach { print($0.getData()) }
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

        self.view.showBlurLoader()
        self.uploadFileToStorage()
        self.uploadDataToDatabase()
        performSegue(withIdentifier: "AddCertificateToMain", sender: nil)
    }
    
    func uploadFileToStorage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if let uploadImg = UIImagePNGRepresentation(self.citizenImg) {
            self.storeRef.child("BecomeToATrainer").child(uid).child("citizen.png").putData(uploadImg, metadata: nil) { (metadata, err) in
                if let err = err {
                    self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                    print(err.localizedDescription)
                    return
                }
                print(metadata)
            }
        }
        
        var countCertFilename = 1
        let strRef = self.storeRef.child("BecomeToATrainer").child(uid).child("certificate")
        self.selectedCerts.forEach { (cert) in
            if let uploadCert = UIImagePNGRepresentation(cert.certImg) {
                strRef.child("cert_\(countCertFilename).png").putData(uploadCert, metadata: nil, completion: { (metadata, err) in
                    if let err = err {
                        self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                        print(err)
                        return
                    }
                    print("\(metadata)\n--------------------------------------")
                })
            }
            countCertFilename += 1
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
        
        self.dbRef.child("become_to_a_trainer").child(uid).updateChildValues(certDic) { (err, ref) in
            if let err = err {
                self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
                print(err.localizedDescription)
                return
            }
            print("successfully add BecomeToATrainer to database")
        }
        
        certDic.forEach { (key, value) in
            print("\(key)------------\(value)")
        }
    }
    
    func showLoader() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
}
