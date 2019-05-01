//
//  BarberListViewController.swift
//  iClipze
//
//  Created by Michelle Grover on 3/18/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit
import EventKit

class BarberListViewController: UIViewController {
    
    var businesses:[Buisinesses] = [Buisinesses]()
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "<-- swipe left on tableview cell"
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString.iClipzeAttributedString(foreground: UIColor.pink, background: UIColor.myWhite)
        
        
        setDelegate()
        
    }
    

    

}


// MARK:- UITableViewDelegate
extension BarberListViewController:UITableViewDelegate, UITableViewDataSource {
    
    private func setDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = businesses.count as? Int {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UITableViewCell, let business = businesses[indexPath.row] as? Buisinesses {
            
//            if let imageViewUrl = business.image_url, let url = URL(string: imageViewUrl) {
//                ImageService.getImage(withUrl: url) { (success, image, err) in
//                    if (success!) {
//                        DispatchQueue.main.async {
//                            cell.imageView?.image = image
//                        }
//                        
//                    }
//                }
//                
//
//                
//            }
//            
//            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
//            cell.imageView?.layer.masksToBounds = true
            
            
            cell.textLabel?.text = business.name
            cell.textLabel?.textColor = UIColor.pink
            cell.detailTextLabel?.textColor = UIColor.purple
            
            
            let mi = business.distance! * 0.00062137
            cell.detailTextLabel?.text = String(format: "Distance in miles: %.2f", mi)
            
            return cell
        }
        return UITableViewCell(style: .default, reuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

// MARK:- MAP, Phone call, Add to calender functionality
extension BarberListViewController {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let map = mapAction(indexPath: indexPath)
        let calender = calenderAction(indexPath: indexPath)
        let phoneCall = phoneCallAction(indexPath: indexPath)
        return UISwipeActionsConfiguration(actions: [map, calender, phoneCall])
    }
    
    private func phoneCallAction(indexPath:IndexPath) -> UIContextualAction {
        let business = businesses[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "call") { (action, view, completion) in
            if let businessPhone = business.phone {
                self.callBarberShop(phoneNumber: businessPhone)
            }
            completion(true)
        }
        action.backgroundColor = UIColor.offOrange
        return action
    }
    
    private func calenderAction(indexPath:IndexPath) -> UIContextualAction {
        let business = businesses[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "schedule") { (action, view, completion) in
//            print("name:\(business.name)", "date:\(Date())")
            self.presentCalendarPopUp(business: business)
            completion(true)
            
        }
        action.backgroundColor = UIColor.myblue
        return action
    }
    
    private func mapAction(indexPath:IndexPath) -> UIContextualAction {
        let business = businesses[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "map") { (action, view, completion) in
//            print("lat:\(business.coordinates?.latitude)", "lon:\(business.coordinates?.longitude)")
            self.locateDestinationInAppleMaps(business: business)
            completion(true)
        }
        action.backgroundColor = UIColor.grossGreen
        return action
    }
    
    
    
    
}
// MARK:- Apple maps - Mapping functionality
extension BarberListViewController {
    
    
    private func locateDestinationInAppleMaps(business:Buisinesses?) {
        
        guard let business = business, let name = business.name, let latitude = business.coordinates?.latitude, let longitude = business.coordinates?.longitude else {
            print("No business object.")
            return
        }
        
        let regionDistance:CLLocationDistance = 1000
        let lat:CLLocationDegrees = latitude
        let long:CLLocationDegrees = longitude
        
        
        let coodinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let regionSpan = MKCoordinateRegion.init(center: coodinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [MKLaunchOptionsMapCenterKey:NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey:NSValue(mkCoordinateSpan: regionSpan.span)]
        
        let placemark = MKPlacemark(coordinate: coodinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)
    }
    
    
}
// MARK:- Calendar functionality
extension BarberListViewController {
    
    private func presentCalendarPopUp(business:Buisinesses) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "dateVC") as! DateTimeViewController
        controller.business = business
        controller.scheduleDelegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    
}


// MARK:- Phone call functionality
extension BarberListViewController {
    
    private func formatPhoneNumberForCall(input:String) -> String {
        var value = input
        if (input.prefix(1) == "+") {
            value.removeFirst()
        }
        value.insert("-", at: input.index(input.startIndex, offsetBy: 4))
        value.insert("-", at: input.index(input.startIndex, offsetBy: 8))
        if (value.prefix(1) == "1") {
            value.removeFirst()
        }
        return value
    }
    
    
    private func callBarberShop(phoneNumber:String)  {
        if let phone = phoneNumber as? String, let formattedPhone = self.formatPhoneNumberForCall(input: phone) as? String, let formattedPhoneString = "tel://\(formattedPhone)" as? String, let formattedPhoneUrl = URL(string: formattedPhoneString) {
            UIApplication.shared.open(formattedPhoneUrl, options: [:], completionHandler: nil)
        }
    }
}

// MARK:- Extension for phone error
extension BarberListViewController {
    
    private func displayError(message:String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
}


// MARK:- CalendarScheduleDelegate functionality
extension BarberListViewController: CalendarScheduleDelegate {
    
    func scheduleCancel(controller: DateTimeViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func scheduleAdd(controller: DateTimeViewController, business: Buisinesses, datePickerDate: UIDatePicker) {
//        print("Business:" + business.name!, business.location!, business.display_phone!, datePickerDate.date)
        addEventToCalendar(business: business, datePickerDate: datePickerDate)
        dismiss(animated: true, completion: nil)
    }
}


// MARK:- Adds an event to the calendar
extension BarberListViewController {
    
    private func addEventToCalendar(business:Buisinesses, datePickerDate:UIDatePicker) {
        
        guard let location = business.location?.display_address?.reduce("", { (result:String, nextItem:String) -> String in
            return result + " " + nextItem
        }) else {
            print("There was an error getting the location.")
            return
        }
        
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (succeed, error) in
            if (succeed && error == nil) {
                let event:EKEvent = EKEvent(eventStore: eventStore)
                if let businessname = business.name {
                    event.title = "Hair cut at: \(String(describing: businessname))"
                }
                DispatchQueue.main.async {
                    event.startDate = datePickerDate.date
                    event.endDate = datePickerDate.date
                }
                event.location = location
                if let phoneNumber = business.display_phone {
                    event.notes = "Reach this barber at: \(String(describing: phoneNumber))"
                }
                
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    print("This event was saved.")
                } catch {
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    
    }
    
    
    
}



