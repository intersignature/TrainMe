//
//  ProgressTabTrainerViewController.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 26/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import UIKit
import SWRevealViewController
import FirebaseAuth
import FirebaseDatabase
import GooglePlaces

struct ExpandableData {
    
    var isExpanded: Bool
    var date: String
    var pendingDetail: [PendingBookPlaceDetail]
}

class ProgressTabTrainerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var progressTableView: UITableView!

    var pendingDetailsCount: Int = 0
    
    var pendingDataListsMatch: [ExpandableData] = []
    var pendingDetails: [PendingBookPlaceDetail] = []
    
    var ref: DatabaseReference!
    var currentUser: User!
    var placesClient: GMSPlacesClient!
    var timeList: [String] = []
    var timeListSorted: [Date] = []
    
    
    var traineeObj: [String: UserProfile] = [:]
    var traineeIds: [String] = []
    
    var placeName: [String: String] = [:]
    var placeIds: [String] = []
    
    var courseName: [String: String] = [:]
    var courseIds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSideMenu()
        self.title = NSLocalizedString("progress", comment: "")
        
        self.ref = Database.database().reference()
        self.currentUser = Auth.auth().currentUser
        self.placesClient = GMSPlacesClient.shared()
        
        self.progressTableView.delegate = self
        self.progressTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.traineeIds.removeAll()
        self.traineeObj.removeAll()
        self.pendingDataListsMatch.removeAll()
        self.pendingDetails.removeAll()
        
        self.getPendingDataList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationStyle()
    }
    
    func getPendingDataList() {
        
        var tempPendingData: [PendingBookPlaceDetail] = []
        print("sadasd:\(self.currentUser.uid)")
        self.ref.child("pending_schedule_detail").child(self.currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for pendingDataObjs in snapshot.children.allObjects as! [DataSnapshot] {
                    print("pendingobjscount: \(pendingDataObjs.childrenCount)")
                    self.pendingDetailsCount += Int(pendingDataObjs.childrenCount)
                    tempPendingData.removeAll()
                    let pendingDataObj = pendingDataObjs.value as! [String: NSDictionary]
                    print("aaa: \(pendingDataObj.values.count)")
                    pendingDataObj.forEach({ (pendingDataObjKey, pendingDataObjVal) in
                        print(pendingDataObjKey)
                        let pendingData = PendingBookPlaceDetail()
                        pendingData.schedule_key = pendingDataObjs.key
                        pendingData.trainee_id = pendingDataObjKey
                        pendingData.course_id = pendingDataObjVal["course_id"] as! String
                        pendingData.place_id = pendingDataObjVal["place_id"] as! String
                        pendingData.start_train_time = pendingDataObjVal["start_train_time"] as! String
                        pendingData.start_train_date = pendingDataObjVal["start_train_date"] as! String
                        tempPendingData.append(pendingData)

                        self.pendingDetails.append(pendingData)
                        
                        if !self.courseIds.contains(pendingData.course_id) {
                            self.courseIds.append(pendingData.course_id)
                            self.getCourseData(courseId: pendingData.course_id)
                        }
                        if !self.placeIds.contains(pendingData.place_id){
                            self.placeIds.append(pendingData.place_id)
                            self.getPlaceData(placeId: pendingData.place_id)
                        }
                        if !self.traineeIds.contains(pendingData.trainee_id) {
                            self.traineeIds.append(pendingData.trainee_id)
                            self.getTraineeData(uid: pendingData.trainee_id)
                        }
                        if !self.timeList.contains("\(pendingData.start_train_date) \(pendingData.start_train_time)") {
                            self.timeList.append("\(pendingData.start_train_date) \(pendingData.start_train_time)")
                        }
                    })
                }
                
            }
//            if self.pendingDetailsCount == self.pendingDetails.count {
//                self.progressTableView.reloadData()
//            }
            
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getTraineeData(uid: String) {
        
        self.ref.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as! NSDictionary
            print(value["name"] as! String)
            let tempUserProfile = UserProfile(fullName: (value["name"] as! String), email: (value["email"] as! String), dateOfBirth: (value["dateOfBirth"] as! String), weight: (value["weight"] as! String), height: (value["height"] as! String), gender: (value["gender"] as! String), role: (value["role"] as! String), profileImageUrl: (value["profileImageUrl"] as! String), uid: uid)
            self.traineeObj[uid] = tempUserProfile
            if self.traineeObj.count == self.traineeIds.count && self.traineeObj.count != 0 &&
                self.courseName.count == self.courseIds.count && self.courseName.count != 0 &&
                self.placeName.count == self.placeIds.count && self.placeName.count != 0 {
                self.sortDate()
            }
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func getPlaceData(placeId: String) {
        
        print(placeId)
        self.placesClient.lookUpPlaceID(placeId) { (place, err) in
            if let err = err {
                print("lookup place id query error: \(err.localizedDescription)")
                return
            }

            guard let place = place else {
                print("No place details for \(placeId)")
                return
            }

            self.placeName[placeId] = place.name
            
            if self.traineeObj.count == self.traineeIds.count && self.traineeObj.count != 0 &&
                self.courseName.count == self.courseIds.count && self.courseName.count != 0 &&
                self.placeName.count == self.placeIds.count && self.placeName.count != 0 {
                self.sortDate()
            }
        }
    }
    
    func getCourseData(courseId: String) {
        
        self.ref.child("courses").child(self.currentUser.uid).child(courseId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as! NSDictionary
            self.courseName[courseId] = (value["course_name"] as! String)
            if self.traineeObj.count == self.traineeIds.count && self.traineeObj.count != 0 &&
                self.courseName.count == self.courseIds.count && self.courseName.count != 0 &&
                self.placeName.count == self.placeIds.count && self.placeName.count != 0 {
                self.sortDate()
            }
        }) { (err) in
            print(err.localizedDescription)
            self.createAlert(alertTitle: err.localizedDescription, alertMessage: "")
            return
        }
    }
    
    func initSideMenu() {
        
        if revealViewController() != nil {
            revealViewController().rearViewRevealWidth = 275
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            menuBtn.target = revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !self.pendingDataListsMatch[section].isExpanded {
            return 0
        }
        
        return pendingDataListsMatch[section].pendingDetail.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return pendingDataListsMatch.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell") as! ProgressTableViewCell

        cell.setDataToCell(traineeImgLink: self.traineeObj[self.pendingDataListsMatch[indexPath.section].pendingDetail[indexPath.row].trainee_id]!.profileImageUrl,
                           traineeName: self.traineeObj[self.pendingDataListsMatch[indexPath.section].pendingDetail[indexPath.row].trainee_id]!.fullName,
                           startDate: self.pendingDataListsMatch[indexPath.section].pendingDetail[indexPath.row].start_train_date,
                           startTime: self.pendingDataListsMatch[indexPath.section].pendingDetail[indexPath.row].start_train_time,
                           position: "\(indexPath.section)-\(indexPath.row)")
        return cell
    }

    func sortDate() {
        
        var convertedArray: [Date] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for dat in self.timeList {
            let date = dateFormatter.date(from: dat)
            if let date = date {
                convertedArray.append(date)
            }
        }
        
        self.timeListSorted = convertedArray.sorted(by: { $0.compare($1) == .orderedAscending })
        self.matchPendingAndDate()
        print(self.timeListSorted)
    }
    
    func matchPendingAndDate() {
        
        var tempPendingDetail: [PendingBookPlaceDetail] = []
        self.timeListSorted.forEach { (date) in
            tempPendingDetail.removeAll()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy HH:mm"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            let result = formatter.string(from: date)
            self.pendingDetails.forEach({ (pendingBookDetail) in
                if result == "\(pendingBookDetail.start_train_date) \(pendingBookDetail.start_train_time)" {
                    tempPendingDetail.append(pendingBookDetail)
                }
            })
            self.pendingDataListsMatch.append(ExpandableData(isExpanded: true, date: "\(result)", pendingDetail: tempPendingDetail))
        }
        self.progressTableView.reloadData()

        
        self.pendingDataListsMatch.forEach { (expandObj) in
            print(expandObj.date)
            expandObj.pendingDetail.forEach({ (pending) in
                print(pending.getData())
            })
            print("hhhhhhhhhhhhhhhhhhhh")
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.placeName[self.pendingDataListsMatch[section].pendingDetail[0].place_id]
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerBtn = UIButton(type: .system)
        headerBtn.setTitle("Close", for: .normal)
        headerBtn.setTitleColor(.black, for: .normal)
        headerBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        headerBtn.addTarget(self, action: #selector(self.handleExpandCollapse(headerBtn:)), for: .touchUpInside)
        headerBtn.tag = section
        headerBtn.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "\(self.pendingDataListsMatch[section].pendingDetail[0].start_train_date) \(self.pendingDataListsMatch[section].pendingDetail[0].start_train_time)"
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false

        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.addSubview(label)
        view.addSubview(headerBtn)

        let views = ["label": label, "button": headerBtn, "view": view]

        let horizontallayoutContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[label(<=250)]-0-[button]-|", options: .alignAllCenterY, metrics: nil, views: views)
        view.addConstraints(horizontallayoutContraints)

        let verticalLayoutContraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalLayoutContraint)

        return view
    }

    @objc func handleExpandCollapse(headerBtn: UIButton) {

        print("handle")
        print(headerBtn.tag)

        let section = headerBtn.tag

        var indexPaths = [IndexPath]()
        for row in self.pendingDataListsMatch[section].pendingDetail.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }

        let isExpanded = self.pendingDataListsMatch[section].isExpanded
        self.pendingDataListsMatch[section].isExpanded = !isExpanded
        
        headerBtn.setTitle(isExpanded ? "Open" : "Close", for: .normal)
        
        if isExpanded {
            self.progressTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            self.progressTableView.insertRows(at: indexPaths, with: .fade)
        }
        
        print("indexPaths: \(indexPaths)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func pendingSegmentedControlAction(_ sender: CustomSegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            // Confirmation
        }
        if sender.selectedSegmentIndex == 1 {
            // Payment
        }
        if sender.selectedSegmentIndex == 2 {
            // Ongoing
        }
        if sender.selectedSegmentIndex == 3 {
            // Successful
        }
    }
}
