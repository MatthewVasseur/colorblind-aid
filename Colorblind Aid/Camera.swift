//
//  Camera.swift
//  Bookster
//
//  Created by Matthew Vasseur on 3/20/17.
//  Copyright © 2017 Matthew Vasseur. All rights reserved.
//
// http://stackoverflow.com/questions/39812390/how-to-load-image-from-camera-or-photo-library-in-swift

import UIKit
import MobileCoreServices

/// The Camera class boxes the image picker
class Camera {
    
    // MARK: - Properties
    var delegate: (UINavigationControllerDelegate & UIImagePickerControllerDelegate)?
    
    // MARK: - Initializer
    
    // Assign the delegate
    init (delegate: UINavigationControllerDelegate & UIImagePickerControllerDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Presentation Methods
    
    /// Present the photo library for photo selection
    func presentPhotoLibrary(target: UIViewController, canEdit: Bool) {
        
        // Cancel if unable to access photo library/saved photos
        if (!UIImagePickerController.isSourceTypeAvailable(.photoLibrary) && !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)) {
            return
        }
        
        // Initializer image type (Image) and picker
        let imageType = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .overFullScreen
        
        // Determine source type: photo library if available, otherwise saved photo albums
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
            imagePicker.sourceType = .photoLibrary
        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.sourceType = .savedPhotosAlbum
        }
        
        // Determine media types
        if let availableTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType) {
            if (availableTypes as NSArray).contains(imageType) {
                imagePicker.mediaTypes = [imageType]
            }
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.delegate = delegate
        
        // Present image picker
        target.present(imagePicker, animated: true, completion: nil)
    }
    
    /// Present the camera for photo selection
    func presentPhotoCamera(target: UIViewController, canEdit: Bool) {
        
        // Cancel if unable to access camera
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        // Initializer image type (Image) and picker
        let imageType = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .overFullScreen
        
        // Determine source and media types
        if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
            if (availableTypes as NSArray).contains(imageType) {
                imagePicker.mediaTypes = [imageType]
                imagePicker.sourceType = .camera
            }
        }
        
        // Initialize camera device
        if UIImagePickerController.isCameraDeviceAvailable(.front) {
            imagePicker.cameraDevice = .front
        } else if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            imagePicker.cameraDevice = .rear
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        
        // Present image picker
        target.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Static Methods
    
    // Common use case for Camera
    static func displayPhotoPresentation(target: UIViewController, canEdit: Bool=true) {
        // Use Camera object to select a user image
        guard let delegate = target as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate) else {
            fatalError("Invalid target (probably not UIImagePickerControllerDelegate & UINavigationControllerDelegate): \(target)")
        }
        let camera = Camera(delegate: delegate)
        
        // Use an alert controller to determine camera or photo library
        let imagePickerMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imagePickerMenu.popoverPresentationController?.sourceView = target.view
        
        // use camera, photo library, and cancel actions
        let takePhoto = UIAlertAction(title: "Camera", style: .default) {
            (alert : UIAlertAction!) in
            camera.presentPhotoCamera(target: target, canEdit: canEdit)
        }
        let sharePhoto = UIAlertAction(title: "Library", style: .default) {
            (alert : UIAlertAction) in
            camera.presentPhotoLibrary(target: target, canEdit: canEdit)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) {
            (alert : UIAlertAction) in
            return
        }
        
        imagePickerMenu.addAction(takePhoto)
        imagePickerMenu.addAction(sharePhoto)
        imagePickerMenu.addAction(cancel)
        
        target.present(imagePickerMenu, animated: true, completion: nil)
    }
}
