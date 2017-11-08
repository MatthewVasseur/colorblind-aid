//
//  FilterViewController.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/1/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, SnapContainerViewElement {
    
    // MARK: - Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    private var isCreatingFilter: Bool=false
    private var rects: [UIView] = [] // Completed rects
    private var currentRect: UIView!
    
    var snapContainer: SnapContainerViewController!
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the current rect
        currentRect = UIView()
        currentRect.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        currentRect.layer.borderColor = UIColor.black.cgColor
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
        isCreatingFilter = !isCreatingFilter
        if isCreatingFilter {
            editButton.setTitle("Done", for: .normal)
        } else {
            editButton.setTitle("Edit", for: .normal)
        }
    }
    
    @IBAction func handleDrawGesture(_ sender: DrawGestureRecognizer) {
        // Ensure there is an image on which to draw and we should be drawing
        if (imageView.image == nil) || !isCreatingFilter {
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
            let completedView = UIView(from: currentRect)
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
    
    // MARK: - Methods
    func draw(rect: CGRect) {
    
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
        
        // Set photoImageView to display the selected image.
        imageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}

