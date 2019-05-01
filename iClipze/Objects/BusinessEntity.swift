//
//  BusinessEntity.swift
//  iClipze
//
//  Created by Michelle Grover on 3/17/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import Foundation

struct BusinessEntity: Decodable {
    let businesses:[Buisinesses]?
    let total:Int?
}

struct Buisinesses: Decodable {
    let id:String?
    let name:String?
    let image_url:String?
    let price:String?
    let phone:String?
    let display_phone:String?
    // distance is returned in meters
    let distance:Double?
    let coordinates:Coordinate?
    let location:Address?
}

struct Address: Decodable {
    let display_address:[String]?
}

struct Coordinate: Decodable {
    let latitude:Double?
    let longitude:Double?
}
