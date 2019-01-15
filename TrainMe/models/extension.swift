//
//  extension.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 30/8/2561 BE.
//  Copyright © 2561 Sirichai Binchai. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleMaps
import GooglePlaces

extension UIViewController : GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate{
    
    func clearImageCache() {
        imageCache.removeAllObjects()
    }
    
    func HideKeyboard() {
        
        let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    func createAlert(alertTitle: String, alertMessage: String) {
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    public func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        
        var street_number: String
        var route: String
        var neighborhood: String
        var locality: String
        var administrative_area_level_1: String
        var country: String
        var postal_code: String
        var postal_code_suffix: String
        
        if let addressLines = place.addressComponents {
            for field in addressLines {
                switch field.type {
                case kGMSPlaceTypeStreetNumber:
                    street_number = field.name
                case kGMSPlaceTypeRoute:
                    route = field.name
                case kGMSPlaceTypeNeighborhood:
                    neighborhood = field.name
                case kGMSPlaceTypeLocality:
                    locality = field.name
                case kGMSPlaceTypeAdministrativeAreaLevel1:
                    administrative_area_level_1 = field.name
                case kGMSPlaceTypeCountry:
                    country = field.name
                case kGMSPlaceTypePostalCode:
                    postal_code = field.name
                case kGMSPlaceTypePostalCodeSuffix:
                    postal_code_suffix = field.name
                default:
                    print("Type: \(field.type), Name: \(field.name)")
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    public func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("Error: ", error.localizedDescription)
    }
    
    public func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    public func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    public func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        print ("MarkerTapped Locations: \(marker.position.latitude), \(marker.position.longitude)\nsnippet: \(marker.snippet)")
        return true
    }
    
    func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    
}

extension UIView{
    func showBlurLoader(){
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.startAnimating()
        
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.contentView.center
        
        self.addSubview(blurEffectView)
    }
    
    func removeBluerLoader(){
        
        self.subviews.compactMap { $0 as? UIVisualEffectView }.forEach {$0.removeFromSuperview() }
    }
}

extension String {
    
    func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var containsEmoji: Bool {
        return unicodeScalars.contains { $0.isEmoji }
    }
}

extension UIViewController {
    
    func setupNavigationStyle() {
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 153/255.0, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView {
    
    func downloaded(from url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.contentMode = .scaleAspectFit
                let imageToCache = image
                imageCache.setObject(imageToCache, forKey: url.absoluteString as AnyObject)
                self.image = image
            }
            }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        if link == "" || link == "-1" || link == nil {
            return
        }
        
        if let imageFromCache = imageCache.object(forKey: link as AnyObject) as? UIImage {
            print("Cache result: true")
            self.image = imageFromCache
            self.contentMode = .scaleAspectFit
            return
        } else {
            print("Cache result: false")
            downloaded(from: url, contentMode: mode)
        }
    }
    
    func saveToCache(imageStringUrl: String) {
        
        guard let imageToCache = self.image else { return }
        imageCache.setObject(imageToCache, forKey: imageStringUrl as AnyObject)
    }
    
    func isBlur(_ isBlur: Bool?) {
        
        guard let checkIsBlur = isBlur else { return }
        if checkIsBlur {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(blurEffectView)
        }
    }
}

extension UIImage {
    func saveToCache(imageStringUrl: String) {
        
        imageCache.setObject(self, forKey: imageStringUrl as AnyObject)
    }
}

extension Auth{
    
    func getRole() {
        
        var role: String!
        let uid = self.currentUser?.uid
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("user").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            role = value?["role"]! as! String
            print(role)
        }) { (err) in
            print(err.localizedDescription)
        }
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Date {
    
    func getCurrentTime() -> String {
        
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let date = self
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    func getDiffToCurentTime(from: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "en")
        let fromDate = dateFormatter.date(from: from)
        
        let secondsAgo = Int(self.timeIntervalSince(fromDate!))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute {
            if secondsAgo < 2 {
                return "\(secondsAgo) SECOND AGO"
            }
            return "\(secondsAgo) SECONDS AGO"
        } else if secondsAgo < hour {
            if secondsAgo / minute < 2 {
                return "\(secondsAgo / minute) MINUTE AGO"
            }
            return "\(secondsAgo / minute) MINUTES AGO"
        } else if secondsAgo < day {
            if secondsAgo / hour < 2 {
                return "\(secondsAgo / hour) HOUR AGO"
            }
            return "\(secondsAgo / hour) HOURS AGO"
        } else if secondsAgo < week {
            if secondsAgo / day < 2 {
                return "\(secondsAgo / day) DAY AGO"
            }
            return "\(secondsAgo / day) DAYS AGO"
        }
        if secondsAgo / week < 2 {
            return "\(secondsAgo / week) WEEK AGO"
        }
        return "\(secondsAgo / week) WEEKS AGO"
    }
}

extension UnicodeScalar {
    var isEmoji: Bool {
        switch value {
        case 0x1F600...0x1F64F, // Emoticons
        0x1F300...0x1F5FF, // Misc Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map
        0x1F1E6...0x1F1FF, // Regional country flags
        0x2600...0x26FF, // Misc symbols
        0x2700...0x27BF, // Dingbats
        0xE0020...0xE007F, // Tags
        0xFE00...0xFE0F, // Variation Selectors
        0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
        127000...127600, // Various asian characters
        65024...65039, // Variation selector
        9100...9300, // Misc items
        8400...8447: // Combining Diacritical Marks for Symbols
            return true
            
        default: return false
        }
    }
    
    var isZeroWidthJoiner: Bool {
        return value == 8205
    }
}
