//
//  FlickrPhotoProvider.swift
//  Flickry
//
//  Created by Olesia on 24/05/2019.
//  Copyright © 2019 Olesia Inc. All rights reserved.
//

import UIKit

class FlickrPhotoProvider {
    
    var photoCache = [String : UIImage]()
    
    func requestImage(for photo: Photo, completion: @escaping (UIImage?) -> Void) {
        let URLString = "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
        if let cachedPhoto = photoCache[URLString] {
            completion(cachedPhoto)
        }
        
        guard let url = URL(string: URLString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
            guard let data = data, let photoImage = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            self?.photoCache[URLString] = photoImage
            completion(photoImage)
        }.resume()
    }
}
