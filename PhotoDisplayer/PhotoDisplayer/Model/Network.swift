//
//  Network.swift
//  PhotoDisplayer
//
//  Created by Christopher Weaver on 10/4/21.
//


import Foundation
import UIKit

class Network {
    
    /**
     Takes in a string and attempts to generate a url object if valid
        - Returns: an Optional URL object
     */
    func returnValidURL(urlString: String?) -> URL? {
        guard let urlString = urlString else { return nil }
        if let validURL = URL(string: urlString) {
            return validURL
        }
        return nil
    }
    
    /**
     Asychrounously takes in a url object and makes an api GET call.
        - Returns: An optional error string and an optional dictionary with return results.
     */
    func makeWebserviceCall(url: URL?, completionHandler: @escaping (_ error: String?, _ response: [String:Any]?) -> Void) {
        
        if Reachability.isConnectedToNetwork() {
            
            guard let url = url else {
                completionHandler("Invalid URL", nil)
                return
            }
            
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                guard (error == nil) else {
                    completionHandler(response.debugDescription,nil)
                    return
                }
                
                guard let data = data else {
                    completionHandler("Unexpected data returned",nil)
                    return
                }
                
                if let jsonReturnData = self.parseAsJSON(data: data) {
                    completionHandler(nil, jsonReturnData)
                } else {
                    completionHandler("Unexpected data returned", nil)
                }
            })
            task.resume()
            
        } else {
            completionHandler("No Internet Connection", nil)
        }
    }
    
    /**
     Asychrounously takes in a url object and makes an api GET call for the retrieval of an image.
        - Returns: An optional error string and an optional UIImage.
     */
    func makeWebserviceCallForImage(url: URL?, completionHandler: @escaping ( _ error: String?, _ image: UIImage?) -> Void) {
        
        if Reachability.isConnectedToNetwork() {
            
            guard let url = url else {
                completionHandler("Invalid URL", nil)
                return
            }
            
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                guard (error == nil) else {
                    completionHandler(response.debugDescription,nil)
                    return
                }
                
                guard let data = data else {
                    completionHandler("Unexpected data returned",nil)
                    return
                }
                
                if let returnImage = UIImage(data: data)  {
                    completionHandler(nil, returnImage)
                } else {
                    completionHandler("Unexpected data returned",nil)
                }
            })
            
            task.resume()
            
        } else {
            completionHandler("No Internet Connection", nil)
        }
    }
    
    /**
     Takes data returend from any api endpoint and attempts serialize into a JSON dictionary
        - Returns: An optional dictionary object
     */
    private func parseAsJSON(data: Data) -> [String:Any]? {
        
        var serializedData: AnyObject!
        
        do {

            serializedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject?
            
            if let returnJSON = serializedData as? [String:Any]  {
                return returnJSON
            } else {
                return nil
            }
            
        } catch {
            print("failed to parse JSON. Error: \(error)")
            return nil
        }
    }
}

