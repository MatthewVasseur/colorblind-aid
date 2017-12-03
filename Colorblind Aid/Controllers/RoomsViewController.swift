//
//  RoomsViewController.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/1/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit

class RoomsViewController: UIViewController, SnapContainerViewElement {

    // MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var snapContainer: SnapContainerViewController!
    
    fileprivate let reuseIdentifier = "RoomCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    fileprivate let itemsPerRow: CGFloat = 2
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions
    @IBAction func handleARButton(_ sender: Any) {
        snapContainer.move(to: "middle")
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension RoomsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppState.sharedInstance.rooms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? RoomCell else {
            fatalError("Wrong type of cell.")
        }
        let room = AppState.sharedInstance.rooms[indexPath.row]

        // Set fields and autolayout
        cell.imageView.image = room.image
        cell.label.text = room.name
        cell.label.layoutIfNeeded()
        cell.imageView.layoutIfNeeded()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow - 1)
        let availableWidth = collectionView.frame.width - (sectionInsets.left + sectionInsets.right + paddingSpace)
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem * 1.10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}
