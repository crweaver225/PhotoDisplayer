//
//  ImageCollectionViewCell.swift
//  PhotoDisplayer
//
//  Created by Christopher Weaver on 10/4/21.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
