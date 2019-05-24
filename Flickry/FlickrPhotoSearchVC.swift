//
//  ViewController.swift
//  Flickry
//
//  Created by Olesia on 24/05/2019.
//  Copyright © 2019 Olesia Inc. All rights reserved.
//

import UIKit

class FlickrPhotoSearchVC: UIViewController {
    
    private let service = FlickrService()
    private let photoProvider = FlickrPhotoProvider()
    
    private var searchResults: [Photo] = []
    private var currentPage: Int?
    private var numberOfPages: Int?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let cellId = "FlickrCell"
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 30.0, left: 20.0, bottom: 30.0, right: 20.0)
    
    func doSearch() {
        guard let searchString = searchBar.text else {
            return
        }
        
        searchBar.isLoading = true
        
        if let page = currentPage {
            currentPage = page + 1
        }
        
        service.searchFlickr(for: searchString, page: currentPage) { [weak self] (flickrAnswer) in
            guard let result = flickrAnswer, result.photo.count != 0 else {
                DispatchQueue.main.async {
                    self?.searchBar.isLoading = false
                    self?.infoLabel.isHidden = false
                    self?.infoLabel.text = (flickrAnswer == nil) ? "Flickr doesn't answer" : "Nothing found"
                }
                
                return
            }
            
            self?.searchResults.append(contentsOf: result.photo)
            self?.currentPage = result.page
            self?.numberOfPages = result.pages
            DispatchQueue.main.async {
                self?.searchBar.isLoading = false
                self?.collectionView.reloadData()
            }
        }
    }
    
    func resetSearch() {
        currentPage = nil
        numberOfPages = nil
        
        searchResults = []
        collectionView.reloadData()
        
        infoLabel.isHidden = true
    }
    
    func isLoadMoreAvailable() -> Bool {
        if let page = currentPage, let pages = numberOfPages, page < pages {
            return true
        } else {
            return false
        }
    }
}

// MARK: - UISearchBarDelegate
extension FlickrPhotoSearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resetSearch()
        searchBar.resignFirstResponder()
        doSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
           resetSearch()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension FlickrPhotoSearchVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FlickrPhotoCell
        
        let photo = searchResults[indexPath.row]
        photoProvider.requestImage(for: photo, completion: { (image) -> Void in
            DispatchQueue.main.async {
                if collectionView.indexPath(for: cell)?.row == indexPath.row {
                    cell.imageView.image = image ?? UIImage(named: "nothing-found")
                }
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == searchResults.count - 1 && isLoadMoreAvailable() {
            doSearch()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            return
                collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                withReuseIdentifier: "FlickrPhotoFooterView",
                                                                for: indexPath)
        }
        
        fatalError("Collection view: invalid supplementary element kind")
    }
}

// MARK: - Collection View Flow Layout Delegate
extension FlickrPhotoSearchVC : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return isLoadMoreAvailable() ? CGSize(width: collectionView.bounds.width, height: 50.0) : .zero
    }
}
