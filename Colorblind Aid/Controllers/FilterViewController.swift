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
    private var currentState: edittingState = .normal
    private var filterViews: [FilterRectView] = [] // Completed rects
    private var currentRect: FilterRectView!
    private var filterType: Constants.ColorblindType = .normal
    
    // MARK: Enumerations
    fileprivate enum edittingState {
        case normal, drawing, moving
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style
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
    
    @IBAction func handleEditLongPress(_ sender: UILongPressGestureRecognizer) {
        // Show the table smoothly
        self.containerTableView.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.containerTableView.alpha = 1.0
        }, completion: nil)
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
            guard let image = self.imageView.image, let ciImage = CIImage(image: image) else {
                return
            }
            let filterValues = ColorblindFilter().data[self.filterType]!
            
            guard let newImage = self.createFilter(ciImage: ciImage, filterValues: filterValues, rect: currentFilterView.frame) else {
                return
            }

            // Update the filter view
            currentFilterView.image = newImage
            currentFilterView.layer.borderWidth = 2.0
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
            
            // Reapply filter (is applicable)
            if currentRect.isFiltered {
                // Apply the filter
                guard let image = self.imageView.image, let ciImage = CIImage(image: image) else {
                    return
                }
                let filterValues = ColorblindFilter().data[currentRect.filterType]!
                
                guard let newImage = self.createFilter(ciImage: ciImage, filterValues: filterValues, rect: currentRect.frame) else {
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
                
                self.view.insertSubview(currentRect, belowSubview: containerTableView)
            
            case .changed:
                currentRect.frame = sender.rect!
                if !imageView.frame.contains(sender.location(in: view)) {
                    sender.state = .ended
                }
            
            case .ended:
                let completedView = FilterRectView(frame: currentRect.frame)
                completedView.editGesture.addTarget(self, action: #selector(handleEditGesture(_:)))
                completedView.editGesture.delegate = self
                
                self.view.insertSubview(currentRect, belowSubview: containerTableView)
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
    
    fileprivate func createFilter(ciImage: CIImage, filterValues: ColorblindFilter.colorblindTransform, rect: CGRect) -> UIImage? {
        // create CIFilter
        let filter = CIFilter(name: "CIColorMatrix")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(filterValues.red, forKey: "inputRVector")
        filter.setValue(filterValues.green, forKey: "inputGVector")
        filter.setValue(filterValues.blue, forKey: "inputBVector")
        filter.setValue(filterValues.alpha, forKey: "inputAVector")
        filter.setValue(filterValues.bias, forKey: "inputBiasVector")
    
        guard let outputImage = filter.outputImage else {
            return nil
        }
    
        // Convert filter view rect to image view scale
        var extentRect = rect
        extentRect.origin.y -= self.imageView.frame.origin.y
        extentRect.origin.x -= self.imageView.frame.origin.x
        extentRect.scale(from: self.imageView.bounds, to: outputImage.extent)
    
        // Crop to region size
        let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent)!
        return UIImage(cgImage: cgImage.cropping(to: extentRect)!)
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
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}

