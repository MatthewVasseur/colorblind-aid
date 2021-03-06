//
//  FilterViewController.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/1/17.
//  Copyright © 2017 Matthew Vasseur. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, SnapContainerViewElement, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var boundsView: UIView!
    @IBOutlet weak var containerTableView: UIView!
    
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
    private var shouldDaltonize: Bool = true
    private var currentState: edittingState = .normal
    private var currentRect: FilterRectView!
    private var filterViews: [FilterRectView] = [] // Completed rects
    private var filterType: Constants.ColorblindType = .normal
    
    // MARK: Enumerations
    fileprivate enum edittingState {
        case normal, drawing, moving
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the colorblind filter
        ColorblindFilterVendor.register()
        //view.backgroundColor = UIColor(patternImage: UIImage(named: "subtleDots")!)
        
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
    
    @IBAction func handleFilterButton(_ sender: UIButton) {
        // Show the table smoothly (and make sure it's on top)
        self.containerTableView.isHidden = false
        self.view.bringSubview(toFront: containerTableView)
        UIView.animate(withDuration: 0.5, animations: {
            self.containerTableView.alpha = 1.0
        }, completion: nil)
    }
    
    @IBAction func handleFilterLongPress(_ sender: UILongPressGestureRecognizer) {
        if self.presentedViewController != nil {
            return
        }
        // Prompt to switch from daltonize to simulate
        let prompt = UIAlertController(title: "Daltonize or Simulate?", message: "Would you like to simulate or correct for color blindness?", preferredStyle: .alert)
        prompt.popoverPresentationController?.sourceView = self.view
        
        let dalt = UIAlertAction(title: "Daltonize", style: .default) {_ in
            self.shouldDaltonize = true
        }
        let sim = UIAlertAction(title: "Simulate", style: .default) { _ in
            self.shouldDaltonize = false
        }
        
        prompt.addAction(dalt)
        prompt.addAction(sim)
        
        self.present(prompt, animated: true, completion: nil)
    }
    
    @IBAction func handleSaveButton(_ sender: UIButton) {
        // Confirm save
        let confirmDialogue = self.view.confirmDialogue(title: "Save Photo?", message: "Are you sure you'd like to save the filtered photo to your camera roll?", confirm: {
            self.saveFilteredImage()
        })
        
        self.present(confirmDialogue, animated: true, completion: nil)
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
            
            // Apply the filter
            guard let newImage = self.createFilter(filterValues: ColorblindFilter.data[self.filterType]!, rect: currentFilterView.frame) else {
                return
            }

            // Update the filter view
            currentFilterView.image = newImage
            currentFilterView.layer.borderWidth = 1.0
            currentFilterView.isFiltered = true
            currentFilterView.filterType = self.filterType
            
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
            
            // Resize filter view is necessary (by using intersection)
            currentRect.frame = currentRect.frame.intersection(imageView.frame)
            
            // Reapply filter (is applicable)
            if currentRect.isFiltered {
                // Apply the filter
                guard let newImage = self.createFilter(filterValues: ColorblindFilter.data[currentRect.filterType]!, rect: currentRect.frame) else {
                    return
                }
                
                // Update the filter view
                currentRect.image = newImage
            }
            
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
                // Take rect frame of intersection with image view (as to always be within bounds)
                let completedView = FilterRectView(frame: currentRect.frame.intersection(imageView.frame))
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
    
    // MARK: - Helper Methods
    
    fileprivate func saveFilteredImage() {
        if (imageView.image == nil || filterViews.isEmpty) {
            return
        }
        // Save the image by merging filtered views using a graphics context
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0.0)
        imageView.image?.draw(in: imageView.bounds)
        
        // Merge each filtered view
        for filterView in filterViews {
            if !filterView.isFiltered {
                continue
            }
            let drawRect = filterView.frame.offsetBy(dx: -imageView.frame.origin.x, dy: -imageView.frame.origin.y)
            filterView.image?.draw(in: drawRect)
        }
        
        // Create the new image
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return
        }
        UIGraphicsEndImageContext()
        
        // Clear rectangles
        for filterView in filterViews {
            filterView.removeFromSuperview()
        }
        filterViews.removeAll()
        canEditFilters = false
        
        // Set the image and save to photos
        imageView.image = image
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    fileprivate func createFilter(filterValues: ColorblindFilter.colorblindTransformMatrix, rect: CGRect) -> UIImage? {
        // Get image
        guard let image = imageView.image, let ciImage = CIImage(image: image) else {
            return nil
        }
        
        // create CIFilter
        let filter: CIFilter
        if shouldDaltonize {
            filter = CIFilter(name: "ColorblindFilter")!

            filter.setValue(filterValues.algoName.rawValue, forKey: "inputAlgoName")
        } else {
            filter = CIFilter(name: "CIColorMatrix")!
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(filterValues.red, forKey: "inputRVector")
        filter.setValue(filterValues.green, forKey: "inputGVector")
        filter.setValue(filterValues.blue, forKey: "inputBVector")
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        
        // Convert filter view rect to image view scale
        var extentRect = rect
        extentRect.origin.y -= imageView.frame.origin.y
        extentRect.origin.x -= imageView.frame.origin.x
        extentRect.scale(from: imageView.bounds, to: outputImage.extent)
        
        // Crop to region size
        let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent)!
        return UIImage(cgImage: cgImage.cropping(to: extentRect)!, scale: image.scale, orientation: image.imageOrientation)
    }
    
    /// Set the image and adjust the image view to contain the whole image with proper aspect ratio
    func setImage(_ image: UIImage) {
        // Clear rectangles
        for filterView in filterViews {
            filterView.removeFromSuperview()
        }
        filterViews.removeAll()
        canEditFilters = true
        
        imageView.image = image
        
        // Adjust the image view size to fit perfectly!
        let imageRatio = image.size.ratio()
        let viewRatio = boundsView.frame.size.ratio()
        
        // Determine whether width or height constrains the image size to adjust image view as needed
        if ((viewRatio < 1) && (imageRatio > viewRatio)) || ((viewRatio > 1) && (imageRatio < viewRatio)) {
            // width constrains
            imageViewWidth.constant = boundsView.frame.size.width
            imageViewHeight.constant = imageViewWidth.constant / imageRatio
        } else {
            // height constrains
            imageViewHeight.constant = boundsView.frame.size.height
            imageViewWidth.constant = imageViewHeight.constant * imageRatio
        }
        imageView.layoutIfNeeded()
    }
    
    // MARK: - Navigation Handlers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Initialize table view controller
        if let tableViewController = segue.destination as? UITableViewController {
            tableViewController.tableView.delegate = self
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        // Hide the table smoothly
        UIView.animate(withDuration: 0.5, animations: {
            cell.accessoryType = .checkmark
            self.containerTableView.alpha = 0
        }, completion: { _ in
           self.containerTableView.isHidden = true
        })
        
        // Change filter type to selected
        filterType = convertIndexPathToFilterType(indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        cell.accessoryType = .none
    }
    
    fileprivate func convertIndexPathToFilterType(_ indexPath: IndexPath) -> Constants.ColorblindType {
        switch indexPath.section {
        case 0:
            return .normal
        case 1:
            switch indexPath.row {
            case 0:
                return .deuteranopia
            case 1:
                return .deuteranomaly
            case 2:
                return .protanopia
            case 3:
                return .protanomaly
            default:
                fatalError("Invalid row")
            }
        case 2:
            switch indexPath.row {
            case 0:
                return .tritanopia
            case 1:
                return .tritanomaly
            default:
                fatalError("Invalid row")
            }
        case 3:
            switch indexPath.row {
            case 0:
                return .achromatopsia
            case 1:
                return .achromatomaly
            default:
                fatalError("Invalid row")
            }
        case 4:
            switch indexPath.row {
            case 0:
                return .deuteranopiaLMS
            case 1:
                return .protanopiaLMS
            case 2:
                return .tritanopiaLMS
            default:
                fatalError("Invalid row")
            }
        default:
            fatalError("Invalid section")
        }
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
        
        // Set photoImageView to display the selected image.
        setImage(selectedImage)
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}

