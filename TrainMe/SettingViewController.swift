//
//  SettingViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 4/3/2562 BE.
//  Copyright © 2562 Sirichai Binchai. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var langSw: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelBtnAction(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func langSwOb(_ sender: UISwitch) {
        print(sender.isOn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
}
