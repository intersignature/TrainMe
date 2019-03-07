//
//  SettingViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 4/3/2562 BE.
//  Copyright © 2562 Sirichai Binchai. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var currentLang: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 && indexPath.section == 0 {
            print(Locale.preferredLanguages[0])
        }
    }
    
    func checkCurrentLang() {
        
        if Locale.preferredLanguages[0].components(separatedBy: "-").first == "en" {
            self.currentLang.text = "EN"
        } else if Locale.preferredLanguages[0].components(separatedBy: "-").first == "th" {
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
