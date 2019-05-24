//
//  Flickr.swift
//  Flickry
//
//  Created by Olesia on 24/05/2019.
//  Copyright © 2019 Olesia Inc. All rights reserved.
//

import Foundation

struct Flickr: Codable {
    let photos: SearchResult
    let stat: String
}

struct SearchResult: Codable {
    let page: Int
    let pages: Int
    let photo: [Photo]
}

struct Photo: Codable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
    
    enum CodingKeys: String, CodingKey {
        case id, secret, server, farm
    }
}
