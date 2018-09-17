//
//  AddCertificateViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 18/9/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit

class AddCertificateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var certificateImg: UIImageView!
    @IBOutlet weak var certificateDetailTv: UITextView!
    @IBOutlet weak var cerificateTableView: UITableView!
    @IBOutlet weak var addCertBtn: UIButton!
    var countAddedCertificate = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cerificateTableView.delegate = self
        self.cerificateTableView.dataSource = self
        
        self.certificateImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectCitizenImg)))
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
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.countAddedCertificate
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "certificateCell") as! CertificateTableViewCell
        cell.setDataToCell(certificateImg: #imageLiteral(resourceName: "leftArrow"), certificateDetail: "fdsfsdf")
        
        return cell
    }

    @IBAction func addCertBtnAction(_ sender: UIButton) {
        self.countAddedCertificate += 1
        self.cerificateTableView.reloadData()
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
}
