//
//  HelpTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 30/12/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HelpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var helpTableView: UITableView!
    
    var ref: DatabaseReference!
    var currentUser: User!
    var userRole: String!
    var helpArr: [Help] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.helpTableView.delegate = self
        self.helpTableView.dataSource = self
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        
        self.getRole()
    }
    
    func setupHelpData() {
        
        if userRole == "trainer" {
            let help1 = Help(topic: "ข้อตกลงในการใช้ซอฟต์แวร์", desc: "ซอฟต์แวร์นี้เป็นผลงานที่พัฒนาขึ้นโดย นาย ศิริชัย บินชัย จาก สถาบันเทคโนโลยีพระจอมเกล้าเจ้าคุณทหารลาดกระบัง และ นาย ธนยศ สุจิภิญโญ จาก สถาบันเทคโนโลยีพระจอมเกล้าเจ้าคุณทหารลาดกระบัง ภายใต้การดูแลของ ดร.อนันตพัฒน์ อนันตชัย ภายใต้โครงการ ระบบค้นหาผู้ฝึกสอนออกกําลังกายส่วนบุคคลบริเวณใกล้เคียงด้วยแอพพลิเคชั่นมือถือ ซึ่งสนับสนุนโดย ศูนย์เทคโนโลยีอิเล็กทรอนิกส์และคอมพิวเตอร์แห่งชาติ โดยมีวัตถุประสงค์เพื่อส่งเสริมให้นักเรียนและนักศึกษาได้เรียนรู้และฝึกฝนในการพัฒนาซอฟต์แวร์ ลิขสิทธิ์ของซอฟต์แวร์นี้จึงเป็นของผู้พัฒนา ซึ่งผู้พพัฒนาได้อนุญาตให้ศูนย์เทคโนโลยีอิเล็กทรอนิกส์และคอมพิวเตอร์แห่งชาติ เผยแพร่ซอฟต์แวร์นี้ตาม \"ต้นฉบับ\" โดยไม่มีการแก้ไขดัดแปลงใด ๆ ทั้งสิ้น ให้แก่บุคคลทั่วไปได้ใช้เพื่อประโยชน์ส่วนบุคคลหรือประโยชน์ทางการศึกษาที่ไม่มีวัตถุประสงค์ในเชิงพาณิชย์ โดยไม่คิดค่าตอบแทนการใช้ซอฟต์แวร์ ดังนั้น ศูนย์เทคโนโลยีอิเล็กทรอนิกส์และคอมพิวเตอร์แห่งชาติ จึงไม่มีหน้าที่ในการดูแล บำรุงรักษา จัดการอบรมการใช้งาน หรือพัฒนาประสิทธิภาพซอฟต์แวร์ รวมทั้งไม่รับรองความถูกต้องหรือประสิทธิภาพการทำงานของซอฟต์แวร์ ตลอดจนไม่รับประกันความเสียหายต่าง ๆ อันเกิดจากการใช้ซอฟต์แวร์นี้ทั้งสิ้น", imageSource: nil)
            let help2 = Help(topic: "b", desc: "sa", imageSource: nil)
            self.helpArr.append(help1)
            self.helpArr.append(help2)
        } else if userRole == "trainee" {
            let help1 = Help(topic: "ข้อตกลงในการใช้ซอฟต์แวร์", desc: "ซอฟต์แวร์นี้เป็นผลงานที่พัฒนาขึ้นโดย นาย ศิริชัย บินชัย จาก สถาบันเทคโนโลยีพระจอมเกล้าเจ้าคุณทหารลาดกระบัง และ นาย ธนยศ สุจิภิญโญ จาก สถาบันเทคโนโลยีพระจอมเกล้าเจ้าคุณทหารลาดกระบัง ภายใต้การดูแลของ ดร.อนันตพัฒน์ อนันตชัย ภายใต้โครงการ ระบบค้นหาผู้ฝึกสอนออกกําลังกายส่วนบุคคลบริเวณใกล้เคียงด้วยแอพพลิเคชั่นมือถือ ซึ่งสนับสนุนโดย ศูนย์เทคโนโลยีอิเล็กทรอนิกส์และคอมพิวเตอร์แห่งชาติ โดยมีวัตถุประสงค์เพื่อส่งเสริมให้นักเรียนและนักศึกษาได้เรียนรู้และฝึกฝนในการพัฒนาซอฟต์แวร์ ลิขสิทธิ์ของซอฟต์แวร์นี้จึงเป็นของผู้พัฒนา ซึ่งผู้พพัฒนาได้อนุญาตให้ศูนย์เทคโนโลยีอิเล็กทรอนิกส์และคอมพิวเตอร์แห่งชาติ เผยแพร่ซอฟต์แวร์นี้ตาม \"ต้นฉบับ\" โดยไม่มีการแก้ไขดัดแปลงใด ๆ ทั้งสิ้น ให้แก่บุคคลทั่วไปได้ใช้เพื่อประโยชน์ส่วนบุคคลหรือประโยชน์ทางการศึกษาที่ไม่มีวัตถุประสงค์ในเชิงพาณิชย์ โดยไม่คิดค่าตอบแทนการใช้ซอฟต์แวร์ ดังนั้น ศูนย์เทคโนโลยีอิเล็กทรอนิกส์และคอมพิวเตอร์แห่งชาติ จึงไม่มีหน้าที่ในการดูแล บำรุงรักษา จัดการอบรมการใช้งาน หรือพัฒนาประสิทธิภาพซอฟต์แวร์ รวมทั้งไม่รับรองความถูกต้องหรือประสิทธิภาพการทำงานของซอฟต์แวร์ ตลอดจนไม่รับประกันความเสียหายต่าง ๆ อันเกิดจากการใช้ซอฟต์แวร์นี้ทั้งสิ้น", imageSource: nil)
            let help2 = Help(topic: "d", desc: "ASD", imageSource: nil)
            self.helpArr.append(help1)
            self.helpArr.append(help2)
            self.helpArr.append(help2)
            self.helpArr.append(help2)
        }
        self.helpTableView.reloadData()
    }
    
    func getRole() {
        
        self.ref.child("user").child(self.currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let values = snapshot.value as? NSDictionary
            self.userRole = values!["role"] as? String
            print(self.userRole)
            self.setupHelpData()
        }) { (err) in
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            print(err.localizedDescription)
            return
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.helpArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpTableViewCell") as! HelpTableViewCell
        cell.topicHelp.text = self.helpArr[indexPath.row].topic
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(helpArr[indexPath.row].getData())
        
        performSegue(withIdentifier: "HelpToViewHelp", sender: self.helpArr[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "HelpToViewHelp") {
            
            guard let selectedHelp = sender as? Help else { return }
            let vc = segue.destination as! UINavigationController
            let containVc = vc.topViewController as! ViewHelpViewController
            containVc.selectedHelp = selectedHelp
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.setupNavigationStyle()

        self.title = "help".localized()
        
        self.helpTableView.tableFooterView = UIView()

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
