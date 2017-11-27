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
    
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    
    var snapContainer: SnapContainerViewController!
    
    /// Can the filter views be editted?
    private var canEditFilters: Bool = false {
        /// Update edit button & touches upon set
        didSet {
            if canEditFilters {
                editButton.setTitle("Done", for: .normal)
                imageView.isUserInteractionEnabled = true
            } else {
                editButton.setTitle("Edit", for: .normal)
                imageView.isUserInteractionEnabled = false
            }
        }
    }
    private var currentState: edittingState = .normal
    private var filterViews: [FilterRectView] = [] // Completed rects
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
    }
    
    @objc func handleEditGesture(_ sender: UITapGestureRecognizer) {
        // Ensure there is an image on which to draw and we should be editting
        if imageView.image == nil || !canEditFilters {
            return
        }
        
        guard let currentFilterView = sender.view as? FilterRectView else {
            return
        }
        
        // Use an alert controller to how to edit the view
        let editMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        editMenu.popoverPresentationController?.sourceView = self.view
        
        // Create move, filter, delete, and cancel actions
        let move = UIAlertAction(title: "Move", style: .default) {
            (alert: UIAlertAction) in
            
            self.currentState = .moving
            self.currentRect = currentFilterView
            
            return
        }
        
        let filter = UIAlertAction(title: "Filter", style: .default) {
            (alert: UIAlertAction) in
            
            // apply a prop filter
            guard let image = self.imageView.image, let ciImage = CIImage(image: image) else {
                return
            }
            
            let filterValues = ColorblindFilter().data[.protanopia]!
            
            let filter = CIFilter(name: "CIColorMatrix")!
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(filterValues.red, forKey: "inputRVector")
            filter.setValue(filterValues.green, forKey: "inputGVector")
            filter.setValue(filterValues.blue, forKey: "inputBVector")
            filter.setValue(filterValues.alpha, forKey: "inputAVector")
            filter.setValue(filterValues.bias, forKey: "inputBiasVector")
            
            guard let outputImage = filter.outputImage else {
                return
            }
            
//            let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent)!
            // Convert filter view rect to image view scale
            var extentRect = currentFilterView.frame
            
            extentRect.origin.y -= self.imageView.frame.origin.y
            extentRect.scale(from: self.imageView.bounds, to: outputImage.extent)
            let cgImage = CIContext().createCGImage(outputImage, from: extentRect)!
            let newImage =  UIImage(cgImage: cgImage)
            
//            UIGraphicsBeginImageContext(self.imageView.frame.size)
//            newImage.draw(in: self.imageView.frame)
//            image.draw(in: self.imageView.frame, blendMode: CGBlendMode.normal, alpha: 0.8)
            
//            self.imageView.image = newImage
            currentFilterView.image = newImage
            
            // TODO: MAKE THIS RIGHT
//            currentFilterView.i += 1
//            currentFilterView.backgroundColor = currentFilterView.colors[currentFilterView.i % 7]
            
            return
        }
        
        let delete = UIAlertAction(title: "Delete", style: .destructive) {
            (alert: UIAlertAction) in
            
            // remove from superview and filterviews array
            for (index, filterView) in self.filterViews.enumerated() {
                if filterView === currentFilterView {
                    self.filterViews.remove(at: index)
                    break
                }
            }
            currentFilterView.removeFromSuperview()
            
            return
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) {
            (alert: UIAlertAction) in
            
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
        
        if currentState == .moving {
            // Change the view's position (use the touch as center of rect)
            currentRect.frame.origin = CGPoint(x: sender.origin!.x - (currentRect.frame.width / 2.0),
                                               y: sender.origin!.y - (currentRect.frame.height / 2.0))
            currentRect = FilterRectView()
            
            // Cancel the gesture
            sender.state = .cancelled
        }
        
        switch sender.state {
            case .began:
                currentRect.frame = sender.rect!
                currentRect.isHidden = false
                
                currentState = .drawing
                
                self.view.addSubview(currentRect)
            
            case .changed:
                currentRect.frame = sender.rect!
            
            case .ended:
                let completedView = FilterRectView(frame: currentRect.frame)
                completedView.editGesture.addTarget(self, action: #selector(handleEditGesture(_:)))
                completedView.editGesture.delegate = self
                
                self.view.addSubview(completedView)
                filterViews.append(completedView)
                
                currentRect.frame = CGRect.zero
                currentRect.isHidden = true
            
                currentState = .normal
            
            case .cancelled, .failed, .possible:
                currentRect.frame = CGRect.zero
                currentRect.isHidden = true
            
                currentState = .normal
        }
    }
    
    // MARK: - Status Bar: Hide
    override var prefersStatusBarHidden : Bool {
        return true
    }
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
        for filterView in filterViews {
            filterView.removeFromSuperview()
        }
        filterViews.removeAll()
        canEditFilters = false
        
        // Set photoImageView to display the selected image.
        imageView.image = selectedImage
        
        let imageRatio = selectedImage.size.ratio()
        let viewRatio = view.frame.size.ratio()
        
        // Assume viewRatio < 1
        if (imageRatio > viewRatio) {
            // width constrains
            imageViewWidth.constant = view.frame.size.width
            imageViewHeight.constant = imageViewWidth.constant / imageRatio
        } else {
            // height constrains
            imageViewHeight.constant = view.frame.size.height
            imageViewWidth.constant = imageViewHeight.constant * imageRatio
        }
        imageView.layoutIfNeeded()
        
        //imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: selectedImage.size.width / selectedImage.size.height).isActive = true
//
//        // Resize image view (aspect fill)
//        let ratio = selectedImage.size.width / selectedImage.size.height
//        if view.frame.width < view.frame.height {
//            let newHeight = view.frame.width / ratio
//            imageView.frame.size = CGSize(width: view.frame.width, height: newHeight)
//        } else {
//            let newWidth = view.frame.height * ratio
//            imageView.frame.size = CGSize(width: newWidth, height: view.frame.height)
//        }

        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}

