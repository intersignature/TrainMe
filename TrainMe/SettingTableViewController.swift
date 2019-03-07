//
//  SettingViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 4/3/2562 BE.
//  Copyright © 2562 Sirichai Binchai. All rights reserved.
//

import UIKit
import Localize_Swift

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var currentLang: UILabel!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("current-lang, \(defaults.string(forKey: "Current-Language"))")
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 && indexPath.section == 0 {
            
            let alert = UIAlertController(title: "Would you like to change language?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "English (EN)", style: .default, handler: { (enAction) in
                self.changeLang(langCode: "en")
            }))
            alert.addAction(UIAlertAction(title: "Thai (TH)", style: .default, handler: { (thAction) in
                self.changeLang(langCode: "th")
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func changeLang(langCode: String) {
        
        self.defaults.set(langCode, forKey: "Current-Language")
        Localize.setCurrentLanguage(langCode)
        
        var alert = UIAlertController()
        
        if langCode == "en" {
            alert = UIAlertController(title: "Change application language to English successful!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (okAction) in
                self.currentLang.text = "EN"
            }))
        } else if langCode == "th" {
            alert = UIAlertController(title: "เปลี่ยนภาษาของแอปพลิเคชันเป็นภาษาไทยเรียบร้อยแล้ว", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (okAction) in
                self.currentLang.text = "TH"
            }))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkCurrentLang() {
        
        if defaults.string(forKey: "Current-Language") == "en" {
            self.currentLang.text = "EN"
        } else if defaults.string(forKey: "Current-Language") == "th" {
            self.currentLang.text = "TH"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.tableFooterView = UIView()
        tableView.backgroundView = UIImageView(image: UIImage(named: "BG_HOME"))
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        self.checkCurrentLang()
    }
}
