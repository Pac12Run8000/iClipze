//
//  ViewController.swift
//  iClipze
//
//  Created by Michelle Grover on 3/12/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var addressTextFieldOutlet: UITextField!
    @IBOutlet weak var currentLocationButtonOutlet: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelOutlet: UILabel!
    @IBOutlet weak var listButtonOutlet: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    var geoCoder = CLGeocoder()
    var businesses = [Buisinesses]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setTextFieldDelegate()
        addressTextFieldOutlet.becomeFirstResponder()
        setupCurrentLocationButtion()
        setupAddddressTextField()
        setupLabelOutlet()
        
        listButtonOutlet.isEnabled = false
       
        navigationController?.navigationBar.tintColor = UIColor.pink
        
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    

    @IBAction func currentLocationButtonAction(_ sender: Any) {
        addressTextFieldOutlet.resignFirstResponder()
        self.listButtonOutlet.isEnabled = false
        self.activityIndicatorView.startAnimating()
        requestLocationCoordinate()
        
    }
    
    deinit {
         unsubscribeToKeyboardNotifications()
    }
    
}

// MARK:- Setup UIElements
extension LocationViewController {
    
    private func setupAddddressTextField() {
        addressTextFieldOutlet.layer.borderWidth = 2
        addressTextFieldOutlet.layer.cornerRadius = 10
        addressTextFieldOutlet.layer.masksToBounds = true
        addressTextFieldOutlet.layer.borderColor = UIColor.myblue.cgColor
        addressTextFieldOutlet.tintColor = UIColor.pink
        addressTextFieldOutlet.textColor = UIColor.pink
    }
    
    
    private func setupCurrentLocationButtion() {
        currentLocationButtonOutlet.layer.cornerRadius = 10
        currentLocationButtonOutlet.layer.borderWidth = 2
        currentLocationButtonOutlet.layer.masksToBounds = true
        currentLocationButtonOutlet.layer.borderColor = UIColor.myblue.cgColor
        currentLocationButtonOutlet.tintColor = UIColor.pink

    }
}


// MARK:- TextFieldDelegates and FirstResponders - Custom Location
extension LocationViewController: UITextFieldDelegate {
    
    
    private func setTextFieldDelegate() {
        addressTextFieldOutlet.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        addressTextFieldOutlet.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if ((textField.text?.isEmpty)! || textField.text == "") {
            return false
        }
        
        if let addressString = textField.text {
            
            listButtonOutlet.isEnabled = false
            self.activityIndicatorView.startAnimating()
            
            getCoordinateFromAddressString(address: addressString) { (isSuccess, coord, error) in
                if (isSuccess!) {
                    
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    
                    let myCoord = CLLocationCoordinate2D(latitude: (coord?.latitude)!, longitude: (coord?.longitude)!)
                    self.addCurrentUserLocationToMap(location: myCoord, title:"You 👍🏾", subtitle: "Available for haircut.")

                    
                    // MARK:- API call for the business located near custom latitude and longitude
                    YelpAPIClient.sharedInstance().getBarbershopData(latitude: coord!.latitude, longitude: coord!.longitude) { (success, error, businessEntity) in
                        
                        if (success!) {
                            
                            self.businesses = (businessEntity?.businesses)!
                            
                            for item in self.businesses {
//                                print("business:\(item)\n")

                                if let myCoord = CLLocationCoordinate2D(latitude: (item.coordinates?.latitude)!, longitude: (item.coordinates?.longitude)!) as? CLLocationCoordinate2D, let name = item.name, let display_phone = item.display_phone {
                                    
                                    
                                    
                                    DispatchQueue.main.async {
                                        self.animateDisplayLabelForBarbershops(label: self.labelOutlet, count: self.businesses.count)
                                        self.addBarberShopAnnotationToMap(location: myCoord, title: name, subtitle: display_phone)
                                        self.listButtonOutlet.isEnabled = true
                                        self.activityIndicatorView.stopAnimating()
                                    }
                                    
                                }
                                
                            }
                           
                        }
                        
                    }
                    
                }
            }
            
        }
        addressTextFieldOutlet.resignFirstResponder()
        return true
        
    }
    
}

// MARK: Show and Hide keyboard - Notifications and Observers
extension LocationViewController {

    
    @objc private func keyboardWillShow(_ notification:Notification) {
        if (addressTextFieldOutlet.isEditing) {
            view.frame.origin.y = 0 - getkeyboardHeight(notification)
            
        }
    }
    
    @objc private func keyboardWillHide(_ notification:Notification) {
        if (addressTextFieldOutlet.isEditing) {
            view.frame.origin.y = 0
        }
    }
    
    private func getkeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    

    
    private func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    private func unsubscribeToKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
}

// MARK:- CLLocationManager Delegate functionality and associated methods - Current Location
extension LocationViewController: CLLocationManagerDelegate {
    
    private func requestLocationCoordinate() {
        locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else {
            print("There was an error getting the location.")
            return
        }
        
        guard let myLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) as? CLLocationCoordinate2D else {
            print("There is an error getting CLLocationCoordinate2D")
            return
        }
        
        mapView.removeAnnotations(mapView.annotations)

        
        let myCoord = CLLocationCoordinate2D(latitude: myLocation.latitude, longitude: myLocation.longitude)
        
        self.addCurrentUserLocationToMap(location: myCoord, title:"Norbert Grover", subtitle: "Available for haircut.")
        
        
        
        YelpAPIClient.sharedInstance().getBarbershopData(latitude: myLocation.latitude, longitude: myLocation.longitude) { (success, error, businessEntity) in
            
            if (success!) {
                
                self.businesses = (businessEntity?.businesses)!
                
                for item in self.businesses {
//                    print("business:\(item)\n")
                    
                    if let myCoord = CLLocationCoordinate2D(latitude: (item.coordinates?.latitude)!, longitude: (item.coordinates?.longitude)!) as? CLLocationCoordinate2D, let name = item.name, let display_phone = item.display_phone {
                        DispatchQueue.main.async {
                            self.animateDisplayLabelForBarbershops(label: self.labelOutlet, count: self.businesses.count)
                            self.addBarberShopAnnotationToMap(location: myCoord, title: name, subtitle: display_phone)
                            self.listButtonOutlet.isEnabled = true
                            self.activityIndicatorView.stopAnimating()
                        }
                        
                    }
                }
            }
            
            
        }
        
        

        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        guard let clerror = error as? CLError else {
            print("error:\(error.localizedDescription)")
            return
        }
        
        switch clerror {
        case CLError.locationUnknown:
            print("location unknown")
            showFailedLocationRequestErrorAlert(message: "Cannot find this location at the moment.")
            activityIndicatorView.stopAnimating()
            break
        case CLError.denied:
            // another test
            print("denied")
            showAuthorizationDisabledAlert()
            break
        default:
            print("other error")
            break
        }
        

        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied) {
            showAuthorizationDisabledAlert()
        }
    }
}

// MARK: Error alert
extension LocationViewController {
    
    private func showFailedLocationRequestErrorAlert(message:String) {
        let alertController = UIAlertController(title: "error message", message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
}

// MARK:- Location Authorization alertController
extension LocationViewController {
    
    private func showAuthorizationDisabledAlert() {
        
        let alertController = UIAlertController(title: "Location access disabled", message: "cannot find clients or barbers with location access disabled.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: "Open settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        alertController.addAction(openAction)
        present(alertController, animated: true, completion: nil)
    }
    
}


// MARK:- Geocode for Custom Address functionality
extension LocationViewController {
    
    private func getCoordinateFromAddressString(address:String, completion handler:@escaping(_ success:Bool?,_ coord:CLLocationCoordinate2D?,_ error:Error?) ->()) {
        
        var coordinate:CLLocationCoordinate2D?
        
        guard let address = address as? String else {
            handler(false, nil, nil)
            return
        }
        
        geoCoder.geocodeAddressString(address) { (placemarks, err) in
            
            guard err == nil else {
                handler(false, nil, err)
                return
            }
            
            var location:CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                coordinate = location.coordinate
                handler(true, coordinate, nil)
            }
            
        }
        
    
    }
    

    
    
}

// MARK:- MKMapViewDelegate functionality
extension LocationViewController: MKMapViewDelegate {
    
    private func addCurrentUserLocationToMap(location:CLLocationCoordinate2D, title:String, subtitle:String) {

        let userAnnotation = CurrentUserAnnotation(coordinate: location, title: title, subtitle: subtitle)
        mapView.setRegion(userAnnotation.region, animated: true)
        mapView.addAnnotation(userAnnotation)
    }
    
    private func addBarberShopAnnotationToMap(location:CLLocationCoordinate2D, title:String, subtitle:String) {

        let barberShopAnnotation = BarberShopAnnotation(coordinate: location, title: title, subtitle: subtitle)
        self.mapView.addAnnotation(barberShopAnnotation)
    }

}

// MARK:- Animate Label and show Label
extension LocationViewController {
    
    private func setupLabelOutlet() {
        labelOutlet.text = "\(businesses.count) barbershop(s) were\nlocated in your search."
        labelOutlet.layer.masksToBounds = true
        labelOutlet.layer.cornerRadius = 8
        labelOutlet.backgroundColor = UIColor.myWhite
        labelOutlet.textColor = UIColor.pink
        labelOutlet.layer.borderColor = UIColor.myblue.cgColor
        labelOutlet.layer.borderWidth = 2
        labelOutlet.alpha = 0.0
        
    }
    
    private func animateDisplayLabelForBarbershops(label:UILabel, count:Int) {
        DispatchQueue.main.async {
            label.text = "\(count) barbershop(s) were\nlocated in your search."
        }
        fadeInFadeOut(label: label)
    }
    private func fadeInFadeOut(label:UILabel) {
        DispatchQueue.main.async {
            if (label.alpha == 0.0) {
                UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseOut, animations: {
                    label.alpha = 1.0
                }, completion: { (success) in
                    if (success) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseOut, animations: {
                                label.alpha = 0.0
                            }, completion: nil)
                        })
                    }
                })

            }
        }
    }
    
    
    
}




// MARK:- Prepare For Segues functionality
extension LocationViewController {
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "barberList" {
            let controller = segue.destination as! BarberListViewController
            controller.businesses = businesses.sorted(by: { (business:Buisinesses, business1:Buisinesses) -> Bool in
                guard let _ = business.distance, let _ = business1.distance else {
                    return true
                }
                return business.distance! < business1.distance!
            })
            
        }
    }
    
}



