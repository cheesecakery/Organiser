//
//  IconsViewController.swift
//  ProdApp
//
//  Created by Permindar LvL on 28/10/2021.
//

import UIKit

private let reuseIdentifier = "cell"

class IconsViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var callbackClosure: (() -> Void)?
    
    var selectedDay: Day?
    var activity: Activity!
    
    var filteredIcons = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        definesPresentationContext = true
        
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        view.isOpaque = false
        
        filteredIcons = icons
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        //Casting is required because UICollectionViewLayout doesn't offer header pin. It is a feature of UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
 
    @IBAction func dismissPopUp(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//Standard collection view implementation
extension IconsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredIcons.count
    }
    
    //TODO: Is not displaying the icon & don't know why
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! iconCell
        cell.icon.image = UIImage(named: filteredIcons[indexPath.row])

        return cell
    }
    
    //TODO: Make search bar -- Create correct title
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            guard let header = headerView as? SupView else { return headerView }
            return header
        default:
            assert(false, "Invalid element type")
        }
    }
}

extension IconsViewController: UICollectionViewDelegate {
    //Save icon when user has selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        activity.icon = filteredIcons[indexPath.row]
        callbackClosure?()
            
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - SEARCH
extension IconsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        self.filteredIcons.removeAll()
             
        for item in icons {
            if (item.lowercased().contains(searchBar.text!.lowercased())) {
                self.filteredIcons.append(item)
            }
        }
             
        if (searchBar.text!.isEmpty) {
            filteredIcons = icons
        }
        collectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty) {
            filteredIcons = icons
            //reload your data source if necessary
            collectionView.reloadData()
        }
    }
}
