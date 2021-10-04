//
//  DetailImageViewController.swift
//  PhotoDisplayer
//
//  Created by Christopher Weaver on 10/4/21.
//

import UIKit

class DetailImageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.snapToNearestCell(scrollView: scrollView)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.snapToNearestCell(scrollView: scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.snapToNearestCell(scrollView: scrollView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userPhotosManager?.returnUserPhotoCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        /// Set up collectionview cell
        var cell: ImageCollectionViewCell?
        if cell == nil {
            self.collectionView?.register(UINib(nibName:"ImageCollectionViewCell",bundle: nil), forCellWithReuseIdentifier: "imageCell")
            cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionViewCell
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.shareImage))
            cell?.imageView.addGestureRecognizer(longPressRecognizer)
        }
        cell?.imageView.image = nil
        cell?.indexPath = indexPath
        
        let userPhoto: UserPhoto?
        /// This method will check to see if the user has set a specific photo to display from the MainPageViewController. Otherwise load based on the collectionview row.
        if let userPhotoValue = self.userPhotosManager?.returnCurrentPhoto() {
            userPhoto = userPhotoValue
            cell?.indexPath?.row = userPhoto?.id ?? indexPath.row
        } else {
            userPhoto = self.userPhotosManager?.returnUserPhoto(id: indexPath.row)
        }
        /// If the user long holds, the view controller will grab the UserPhoto at this location to share
        self.currentIndex = indexPath
        /// Asychronously load the UserPhoto image either from memory or via api
        userPhoto?.loadImage(completionHandler: { (image) in
            /// Check to make sure the cell was not reused by another object since call was made
            if cell?.indexPath?.row == userPhoto?.id {
                DispatchQueue.main.async {
                    cell?.imageView.image = image
                }
            }
        })
        
        return cell!
    }
    
    /**
        This method will move the view controller to center one of the images on the page when the user stops scrolling
     */
    private func snapToNearestCell(scrollView: UIScrollView) {
         let middlePoint = Int(scrollView.contentOffset.x + UIScreen.main.bounds.width / 2)
         if let indexPath = self.collectionView.indexPathForItem(at: CGPoint(x: middlePoint, y: 0)) {
              self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
         }
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var userPhotosManager: UserPhotoManager?
    var currentIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.collectionViewLayout = flowLayout!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let userPhoto = userPhotosManager?.returnCurrentPhoto() {
            self.collectionView.scrollToItem(at: IndexPath(row: (userPhoto.id), section: 0), at: .centeredHorizontally, animated: false)
            self.userPhotosManager?.removeCurrentPhoto()
        }
    }

    /**
        Will look for the current UserPhoto for the colleciton view and share with the system Activity ViewController
     */
    @objc private func shareImage() {
        guard let id = self.currentIndex?.row else { return }
        if let userPhoto = userPhotosManager?.returnUserPhoto(id: id) {
            userPhoto.loadImage(completionHandler: { (image) in
                let activtyView = UIActivityViewController(activityItems: [image ?? UIImage()], applicationActivities: nil)
                activtyView.popoverPresentationController?.sourceView = self.view
                self.present(activtyView, animated: true, completion: nil)
            })
        }
    }
}
