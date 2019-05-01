//
//  YelpAPIClient.swift
//  iClipze
//
//  Created by Michelle Grover on 3/14/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import Foundation

class YelpAPIClient: NSObject {
    
    var session = URLSession.shared
    
    func taskForGettingBarbershops(latitude:Double?, longitude:Double?, completionHandler:@escaping(_ data:Data?,_ success:Bool?,_ error:Error?) -> ()) {
        
        session = setDefaultTimeoutForConfiguration()
        
        
        guard let latitude = latitude, let longitude = longitude else {
            print("There was an error getting coords for task.")
            return
        }
        
        let barbershopsUrl:String = getbarbershopUrl(latitude: latitude, longitude: longitude)!
        
        var urlRequest = URLRequest(url: URL(string: barbershopsUrl)!)

        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer " + YelpAPIClient.Constants.APIKeyValues.BearerToken, forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "GET"
        
        let task = session.dataTask(with: urlRequest) { (data, response, err) in
            guard err == nil else {
                print("error on request:\(String(describing: err?.localizedDescription))")
                completionHandler(nil, false, err)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("StatusCode is not in acceptable range.")
                completionHandler(nil, false, nil)
                return
            }
            
            completionHandler(data, true, nil)
        }
        task.resume()
    }
    
    
}

// MARK:- Build the url
extension YelpAPIClient {
    
    private func getbarbershopUrl(latitude:Double?, longitude:Double?) -> String? {
        if let latitude = latitude, let longitude = longitude {
             return "https://api.yelp.com/v3/businesses/search?term=barbershop&latitude=\(latitude)&longitude=\(longitude)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
       return nil
    }
    
}
