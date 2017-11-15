//
//  FilterViewController.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/1/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, SnapContainerViewElement, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    var snapContainer: SnapContainerViewController!
    
    private var canEditFilters: Bool = false
    private var currentState: edittingState = .normal
    private var rects: [FilterRectView] = [] // Completed rects
    private var currentRect: FilterRectView!
    
    // MARK: Enumerations
    fileprivate enum edittingState {
        case normal, drawing, moving
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the current rect
        currentRect = FilterRectView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Status Bar: Hide
    override var prefersStatusBarHidden : Bool {
        return true
    }

    // MARK: - Actions
    @IBAction func handleCameraButton(_ sender: UIButton) {
        // Use camera to pick photo, etc.
        Camera.displayPhotoPresentation(target: self, canEdit: false)
    }
    
    @IBAction func handleARButton(_ sender: UIButton) {
        // Go back to AR screen
        snapContainer.move(to: "middle")
    }
    
    @IBAction func handleEditButton(_ sender: UIButton) {
        canEditFilters = !canEditFilters
        if canEditFilters {
            editButton.setTitle("Done", for: .normal)
            imageView.isUserInteractionEnabled = true
        } else {
            editButton.setTitle("Edit", for: .normal)
            imageView.isUserInteractionEnabled = false
        }
    }
    
//    @IBAction func handleEditButton(_ sender: UIButton) {
//        if currentState == .drawing {
//            currentState == .normal
//            editButton.setTitle("Done", for: .normal)
//            imageView.isUserInteractionEnabled = true
//        } else {
//            currentState == .drawing
//            editButton.setTitle("Edit", for: .normal)
//            imageView.isUserInteractionEnabled = false
//        }
//    }
    
    // MARK: - Actions
    @objc func handleEditGesture(_ sender: UITapGestureRecognizer) {
        guard let filterView = sender.view as? FilterRectView else {
            return
        }
        
        // TODO: MAKE THIS RIGHT
        
        // Use an alert controller to how to edit the view
        let editMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        editMenu.popoverPresentationController?.sourceView = self.view
        
        // Create move, filter, delete, and cancel actions
        let move = UIAlertAction(title: "Move", style: .default) {
            (alert : UIAlertAction) in
            print("Moving")
            return
        }
        let filter = UIAlertAction(title: "Filter", style: .default) {
            (alert : UIAlertAction) in
            
            filterView.i += 1
            filterView.backgroundColor = filterView.colors[filterView.i % 7]
            return
        }
        let delete = UIAlertAction(title: "Delete", style: .destructive) {
            (alert : UIAlertAction) in
            print("deleting")
            
            filterView.removeFromSuperview()
            return
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) {
            (alert : UIAlertAction) in
            return
        }
        
        editMenu.addAction(move)
        editMenu.addAction(filter)
        editMenu.addAction(delete)
        editMenu.addAction(cancel)
        
        self.present(editMenu, animated: true, completion: nil)
    }
    
    @IBAction func handleDrawGesture(_ sender: DrawGestureRecognizer) {
        // Ensure there is an image on which to draw and we should be editting
        if imageView.image == nil || !canEditFilters {
            return
        }
        
        
        switch sender.state {
        case .began:
            currentRect.frame = sender.rect!
            currentRect.isHidden = false
            self.view.addSubview(currentRect)
            
            print("began")
            
        case .changed:
//            currentRect.isHidden = false
            currentRect.frame = sender.rect!
            
            //print("changed")
            
        case .ended:
            let completedView = FilterRectView(frame: currentRect.frame)
            completedView.editGesture.addTarget(self, action: #selector(handleEditGesture(_:)))
            completedView.editGesture.delegate = self
            
            self.view.addSubview(completedView)
            rects.append(completedView)
            
            currentRect.isHidden = true
            currentRect.frame = CGRect.zero
            
            print("ended")
            
        case .cancelled:
            print("cancelled")
            
        case .failed, .possible:
            print("failed")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UIImagePickerControlerDelegate
extension FilterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Clear rectangles
        for rect in rects {
            rect.removeFromSuperview()
        }
        rects.removeAll()
        
        // Set photoImageView to display the selected image.
        imageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}

