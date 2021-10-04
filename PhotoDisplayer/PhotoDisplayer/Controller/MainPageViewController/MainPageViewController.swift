//
//  MainPageViewController.swift
//  PhotoDisplayer
//
//  Created by Christopher Weaver on 10/4/21.
//

import UIKit

class MainPageViewController:  UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3, height: collectionView.frame.size.width / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userPhotosManager.returnUserPhotoCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /// Setup the collectionview cell
        var cell: ImageCollectionViewCell?
        if cell == nil {
            self.collectionView?.register(UINib(nibName:"ImageCollectionViewCell",bundle: nil), forCellWithReuseIdentifier: "imageCell")
            cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionViewCell
            cell?.contentView.layer.borderWidth = 5
            cell?.contentView.layer.borderColor = UIColor.white.cgColor
        }
        cell?.imageView.image = nil
        cell?.indexPath = indexPath
        
        /// Load the UserPhoto object from the data source
        let userPhoto = self.userPhotosManager.returnUserPhoto(id: indexPath.row)
        
        /// Asychronously load the UserPhoto image either from memory or via api
        userPhoto.loadImage(completionHandler: { (image) in
            /// Check to make sure the cell was not reused by another object since call was made
            if cell?.indexPath?.row == userPhoto.id {
                DispatchQueue.main.async {
                    cell?.imageView.image = image
                }
            }
        })
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /// Set the current photo so that the DetailImageViewController knows which UserPhoto to access
        self.userPhotosManager.setCurrentPhoto(id: indexPath.row)
        
        let detailImageVC = DetailImageViewController()
        detailImageVC.userPhotosManager = self.userPhotosManager
        
        self.present(detailImageVC, animated: true, completion: nil)
    }

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var userPhotosManager: UserPhotoManager = UserPhotoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.collectionViewLayout = flowLayout!
    }

}
