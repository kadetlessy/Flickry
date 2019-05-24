//
//  FlickrImageCell.swift
//  Flickry
//
//  Created by Olesia on 24/05/2019.
//  Copyright © 2019 Olesia Inc. All rights reserved.
//

import UIKit

class FlickrPhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}
