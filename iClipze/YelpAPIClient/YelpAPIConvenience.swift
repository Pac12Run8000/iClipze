//
//  YelpAPIConvenience.swift
//  iClipze
//
//  Created by Michelle Grover on 3/14/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import Foundation


extension YelpAPIClient {
    
    func getBarbershopData( latitude:Double?, longitude:Double?,completionHandler:@escaping(_ isSuccessful:Bool?, _ error:Error?, _ businessEntity:BusinessEntity?) -> ()) {
        
        YelpAPIClient.sharedInstance().taskForGettingBarbershops(latitude: latitude, longitude: longitude) { (data, isSuccess, error) in
            
            guard data != nil else {
                print("The data does not exist")
                completionHandler(false, nil, nil)
                return
            }
            
           
            self.decodeDataForModel(data: data, completionHandler: { (succeed, err, business) in
                if (succeed) {
                    completionHandler(true, nil, business)
                } else {
                    completionHandler(false, err, nil)
                }
            })
            
        }
        
    }
}



// MARK:- Json encodable and decodeable functionality
extension YelpAPIClient {
    
    
    
    private func decodeDataForModel(data:Data?, completionHandler:@escaping (_ isSucces:Bool, _ error:Error?, _ businessEntity:BusinessEntity?) -> ()) {
        let entity:BusinessEntity?
        
        if (data == nil) {
            print("There is no data")
            completionHandler(false, nil, nil)
        }
        //
        let barbershopDecoder = JSONDecoder()
        
        do {
            entity = try barbershopDecoder.decode(BusinessEntity.self, from: data!)
            completionHandler(true, nil, entity)
        } catch let e as Error {
            print("Error:\(e.localizedDescription)")
            completionHandler(false, e, nil)
        }
        
        

    }
    
}



    
    
    


