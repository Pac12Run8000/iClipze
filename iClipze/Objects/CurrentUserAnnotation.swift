//
//  CurrentUserAnnotation.swift
//  iClipze
//
//  Created by Michelle Grover on 3/13/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit

class CurrentUserAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title:String?
    var subtitle: String?
    
    var region: MKCoordinateRegion {
        let span = MKCoordinateSpan(latitudeDelta: 0.50, longitudeDelta: 0.50)
        return MKCoordinateRegion(center: coordinate, span: span)
    }
    
    init(coordinate:CLLocationCoordinate2D, title:String?, subtitle:String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
}

class BarberShopAnnotation:CurrentUserAnnotation {
    override init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        super.init(coordinate: coordinate, title: title, subtitle: subtitle)
    }

}

