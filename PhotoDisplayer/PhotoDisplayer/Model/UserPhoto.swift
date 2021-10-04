//
//  UserPhoto.swift
//  PhotoDisplayer
//
//  Created by Christopher Weaver on 10/4/21.
//


import Foundation
import UIKit

class UserPhoto {
    
    static var imageCache = NSCache<AnyObject, UIImage>()
    
    private var userImage: UIImage?
    var id: Int

    init(id: Int) {
        self.id = id
    }
    
    /**
     Asychrounously loads images.
        - Returns: an Optional UIImage
     */
    func loadImage(completionHandler: @escaping( _ image: UIImage?) -> Void) {
        
        guard (self.userImage == nil) else {
            completionHandler(userImage)
            return
        }

        let cachedImage = UserPhoto.imageCache.object(forKey: self.id as AnyObject)
        guard (cachedImage == nil) else {
            completionHandler(cachedImage)
            return
        }
        
        let network = Network()
        
        if let url = network.returnValidURL(urlString: "https://jsonplaceholder.typicode.com/photos/\(self.id + 1)") {
            
            network.makeWebserviceCall(url: url, completionHandler: { [weak self] (error, returnJSON) in

                if let imageURL = network.returnValidURL(urlString: returnJSON?["url"] as? String) {
                            
                    network.makeWebserviceCallForImage(url: imageURL, completionHandler: { [ weak self] (error, image) in
                                
                        if let image = image {
                                    
                            self?.userImage = image
                                    
                            UserPhoto.imageCache.setObject(image, forKey: self?.id as AnyObject)
                                    
                            completionHandler(image)
                            
                        } else {
                            completionHandler(nil)
                        }
                    })
                } else {
                    completionHandler(nil)
                }
            })
        } else {
            completionHandler(nil)
        }
    }
}

