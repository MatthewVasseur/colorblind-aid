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
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        // Action menu
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        menu.popoverPresentationController?.sourceView = self.view
        
        let load = UIAlertAction(title: "Load", style: .default, handler: { _ in
            // Get the indexPath
            guard let indexPath = self.collectionView.indexPathForItem(at: sender.location(in: self.collectionView)) else {
                return
            }
            
            // Load the cell
            let room = AppState.sharedInstance.rooms[indexPath.row]
            self.loadRoom(room)
        })
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            if (sender.state != .ended) {
                return
            }
            
            // Get the index path
            guard let indexPath = self.collectionView.indexPathForItem(at: sender.location(in: self.collectionView)) else {
                return
            }
            
            // Delete the cell
            AppState.sharedInstance.rooms.remove(at: indexPath.row)
            self.collectionView.reloadData()
            Room.saveRooms()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        menu.addAction(load)
        menu.addAction(delete)
        menu.addAction(cancel)
        
        self.present(menu, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    func loadRoom(_ room: Room) {
        // Set the nodes
        guard let ARVC = snapContainer.middleVC as? ARViewController else {
            fatalError("Incorrect view controllers")
        }
        ARVC.setNodes(room.nodes)
        
        // Move to the AR
        snapContainer.move(to: "middle")
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout & UICollectionViewDelegate
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Load the nodes
        let room = AppState.sharedInstance.rooms[indexPath.row]
        
        loadRoom(room)
    }
    
}
