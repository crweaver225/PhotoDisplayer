//
//  UserPhotoManager.swift
//  PhotoDisplayer
//
//  Created by Christopher Weaver on 10/4/21.
//

import Foundation
import UIKit

class UserPhotoManager {
    
    private var userPhotos: [UserPhoto] = []
    private var currentPhoto: Int?
    
    /**
     Set the photo the end user selected for the detail page. ID will match the collectionview indexPath row
     */
    func setCurrentPhoto(id: Int) {
        if id < self.userPhotos.count {
            self.currentPhoto = id
        }
    }
    
    /**
     Removes the current user selected photo once the user has scrolled from it or dismissed the detail viewcontroller.
     */
    func removeCurrentPhoto() {
        self.currentPhoto = nil
    }
    
    /**
        - Returns: an optional UserPhoto object from if the user had selected a specific photo for the DetailImageViewController
     */
    func returnCurrentPhoto() -> UserPhoto? {
        if let currentPhoto = currentPhoto {
            return userPhotos[currentPhoto]
        }
        return nil
    }
    
    /**
            - Returns: an integer for the number of user photos the app can load. This number will never be zero and will increment indefinitely right now.
     */
    func returnUserPhotoCount() -> Int {
        return userPhotos.count + 100
    }
    
    /**
    Provides the UserPhoto object tied to a specific id. Since this id is related to a collectionview row, a collectionview delegate can call this method and pass in the IndexPath row to get the next
    UserPhoto to display.
            - Returns: a UserPhoto.
     */
    func returnUserPhoto(id: Int) -> UserPhoto {
        if id < self.userPhotos.count {
            return userPhotos[id]
        } else {
            let userPhoto = UserPhoto(id: id)
            userPhotos.append(userPhoto)
            return userPhoto
        }
    }
}

