//
//  DateTimeViewController.swift
//  iClipze
//
//  Created by Michelle Grover on 3/20/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit


//protocol locationEditViewControllerDelegate:class {
//    func locationEditViewControllerCancel(_ controller:LocationEditViewController)
//    func locationEditViewControllerCoordinate(_ controller:LocationEditViewController, didGetCoordinate location:(CLLocationCoordinate2D,String))
//}

protocol CalendarScheduleDelegate:class {
    func scheduleCancel(controller: DateTimeViewController)
    func scheduleAdd(controller: DateTimeViewController, business:Buisinesses, datePickerDate:UIDatePicker)
}

class DateTimeViewController: UIViewController {
    
//    weak var locationDelegate:locationEditViewControllerDelegate?
    weak var scheduleDelegate:CalendarScheduleDelegate?
    
    var business:Buisinesses!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateDialogView: UIView!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setdatePickerAttributes()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        print("Business:" + business.name!, business.location, business.display_phone)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        scheduleDelegate?.scheduleCancel(controller: self)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
//       saveDate()
        scheduleDelegate?.scheduleAdd(controller: self, business: business, datePickerDate: datePicker)
    }
    
    

}
// MARK:- DatePicker Functionality
extension DateTimeViewController {
    
    
//    private func saveDate() {
//        let date = datePicker.date
//        print("Date:\(date)")
//
//        dismiss(animated: true, completion: nil)
//    }
    
    private func setdatePickerAttributes() {
        
        saveButtonOutlet.layer.borderWidth = 3
        saveButtonOutlet.layer.borderColor = UIColor.pink.cgColor
        saveButtonOutlet.backgroundColor = UIColor.myWhite
        saveButtonOutlet.layer.masksToBounds = true
        saveButtonOutlet.layer.cornerRadius = 15
        saveButtonOutlet.setTitle("save", for: .normal)
        
        
        cancelButtonOutlet.layer.borderWidth = 3
        cancelButtonOutlet.layer.borderColor = UIColor.pink.cgColor
        cancelButtonOutlet.backgroundColor = UIColor.myWhite
        cancelButtonOutlet.layer.masksToBounds = true
        cancelButtonOutlet.layer.cornerRadius = 15
        cancelButtonOutlet.setTitle("cancel", for: .normal)
        
        
        dateDialogView.backgroundColor = UIColor.myblue
        
        self.datePicker.layer.borderColor = UIColor.myblue.cgColor
        self.datePicker.layer.borderWidth = 3
        self.datePicker.layer.cornerRadius = 15
        self.datePicker.layer.masksToBounds = true
        
        
        datePicker.setValue(UIColor.myWhite, forKey: "backgroundColor")
        datePicker.setValue(UIColor.pink, forKeyPath: "textColor")
    }

    
    
    
}


