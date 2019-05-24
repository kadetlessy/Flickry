//
//  NetworkService.swift
//  Flickry
//
//  Created by Olesia on 24/05/2019.
//  Copyright © 2019 Olesia Inc. All rights reserved.
//

import Foundation

class FlickrService {
    
    private let apiKey = "3e7cc266ae2b0e0d78e279ce8e361736"
    
    func searchFlickr(for searchTerm: String, page: Int?, completion: @escaping (SearchResult?) -> ()) {
        guard let searchURL = flickrSearchURL(for: searchTerm, pageNumber: page) else {
            completion(nil)
            return
        }
        
        let searchRequest = URLRequest(url: searchURL)
        
        URLSession.shared.dataTask(with: searchRequest) { (data, response, error) in
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let flickr = try JSONDecoder().decode(Flickr.self, from: data)
                completion(flickr.photos)
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    private func flickrSearchURL(for searchTerm: String, pageNumber: Int?) -> URL? {
        guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        var URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&format=json&nojsoncallback=1&safe_search=1&text=\(escapedTerm)"
        
        if let pageNumber = pageNumber {
            URLString += "&page=\(pageNumber)"
        }
        
        return URL(string:URLString)
    }
}
