//
//  ARViewController.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 10/25/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

import Vision

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    // Mark: - Properties
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var debugTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    let bubbleDepth: Float = 0.01 // the 'depth' of 3D text
    var latestPrediction: String = "…" // a variable containing the latest CoreML prediction
    var latestColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.52)
    var data: UnsafePointer<UInt8>!
    var uiImage: UIImage!
    
    // COREML
    //var visionRequests = [VNRequest]()
    //let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml") // A Serial Queue
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up the scene and scene view
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // Enable Default Lighting - makes the 3D text a bit poppier.
        sceneView.autoenablesDefaultLighting = true
        // Enable debug options
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //////////////////////////////////////////////////
        
        // Set up Vision Model
        guard let selectedModel = try? VNCoreMLModel(for: Inceptionv3().model) else {
            // (Optional) This can be replaced with other models on https://developer.apple.com/machine-learning/
            fatalError("Could not load model. Ensure model has been drag and dropped (copied) to XCode Project from https://developer.apple.com/machine-learning/ . Also ensure the model is part of a target (see: https://stackoverflow.com/questions/45884085/model-is-not-part-of-any-target-add-the-model-to-a-target-to-enable-generation ")
        }
        
        // Set up Vision-CoreML Request
        let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        // Crop from centre of images and scale to appropriate size.
        visionRequests = [classificationRequest]
        
        // Begin Loop to Update CoreML
        loopCoreMLUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Enable plane detection
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            // Do any desired updates to SceneKit here.
        }
    }
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - Status Bar: Hide
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func handleTap(gestureRecognize: UITapGestureRecognizer) {
        // Get nearest object to center screen to color lable
        //        let touchLocation = sender.location(in: self.sceneView)
        let screenCentre = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
        let arHitTestResults = sceneView.hitTest(screenCentre, types: [.featurePoint, .existingPlaneUsingExtent])
        // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
        
        if let closestResult = arHitTestResults.first {
            
            // Get Coordinates of HitTest
            let transform = closestResult.worldTransform
            let worldCoord = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            //
            let pixelInfo: Int = Int((uiImage.size.width * screenCentre.y) + screenCentre.x) * 4
            
            let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
            let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
            let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
            
            self.latestColor = UIColor(red: r, green: g, blue: b, alpha: a)
            let colorText = String(format: "Red: %3.2f, Green: %3.2f, Blue: %3.2f", r, g, b)
            // Store the latest prediction
            //            self.latestPrediction = colorText
            
            print(colorText)
            
            // Display Debug Text on screen
            self.debugTextView.text = colorText
            
            debugTextView.backgroundColor = latestColor
            imageView.image = uiImage
            
            // Create 3D Text
            let node = createNewBubbleParentNode(colorText)
            sceneView.scene.rootNode.addChildNode(node)
            node.position = worldCoord
        }
    }
    
    // MARK: - Methods
    
    private func createNewBubbleParentNode(_ text: String) -> SCNNode {
        // Warning: Creating 3D Text is susceptible to crashing. To reduce chances of crashing; reduce number of polygons, letters, smoothness, etc.
        
        // Text billboard constraint
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // Create the bubble text
        let bubble = SCNText(string: text, extrusionDepth: CGFloat(bubbleDepth))
        bubble.font = UIFont(name: "Futura", size: 0.10)?.withTraits(traits: .traitBold)
        bubble.alignmentMode = kCAAlignmentCenter
        bubble.firstMaterial?.diffuse.contents = UIColor.orange
        bubble.firstMaterial?.specular.contents = UIColor.white
        bubble.firstMaterial?.isDoubleSided = true
        bubble.chamferRadius = CGFloat(bubbleDepth)
        // bubble.flatness // setting this too low can cause crashes.
        
        // Create the bubble node
        let bubbleNode = SCNNode(geometry: bubble)
        // Centre Node - to Centre-Bottom point
        let (minBound, maxBound) = bubble.boundingBox
        bubbleNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, bubbleDepth/2)
        
        // Reduce default text size
        bubbleNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        
        // Create the sphere node
        let sphere = SCNSphere(radius: 0.005)
        sphere.firstMaterial?.diffuse.contents = UIColor.cyan
        let sphereNode = SCNNode(geometry: sphere)
        
        // Create the parent node
        let parentNode = SCNNode()
        parentNode.addChildNode(bubbleNode)
        parentNode.addChildNode(sphereNode)
        parentNode.constraints = [billboardConstraint]
        
        return parentNode
    }
    
    // MARK: - CoreML Vision Handling
    
    func loopCoreMLUpdate() {
        // Continuously run CoreML whenever it's ready. (Preventing 'hiccups' in Frame Rate)
        
        dispatchQueueML.async {
            // 1. Run Update.
            self.updateCoreML()
            
            // 2. Loop this function.
            self.loopCoreMLUpdate()
        }
        
    }
    
    func classificationCompleteHandler(request: VNRequest, error: Error?) {
        // Catch Errors
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        // Get Classifications
        let classifications = observations[0...1] // top 2 results
            .flatMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        DispatchQueue.main.async {
            // Print Classifications
            //            print(classifications)
            //            print("--")
            
            // Display Debug Text on screen
            //            var debugText:String = ""
            //            debugText += classifications
            //            self.debugTextView.text = debugText
            
            // Store the latest prediction
            //            var objectName:String = "…"
            //            objectName = classifications.components(separatedBy: "-")[0]
            //            objectName = objectName.components(separatedBy: ",")[0]
            //            self.latestPrediction = objectName
        }
    }
    
    func updateCoreML() {
        ///////////////////////////
        // Get Camera Image as RGB
        guard let pixbuff = (sceneView.session.currentFrame?.capturedImage) else {
            return
        }
        let ciImage = CIImage(cvPixelBuffer: pixbuff)
        
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        uiImage = UIImage(cgImage: cgImage!, scale: 1.0, orientation: .right)
        
        data = CFDataGetBytePtr(cgImage?.dataProvider?.data)
        
        //        let screenCentre = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
        //        let pixelInfo: Int = ((Int(uiImage.size.width) * Int(screenCentre.y)) + Int(screenCentre.x)) * 4
        //
        //        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        //        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        //        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        //        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        //print(colorText)
        
        //        DispatchQueue.main.async {
        //            self.latestColor = UIColor(red: r, green: g, blue: b, alpha: a)
        //            let colorText = String(format: "Red: %3.2f, Green: %3.2f, Blue: %3.2f", r, g, b)
        //            // Store the latest prediction
        //            self.latestPrediction = colorText
        //
        //            print(colorText)
        //
        //            // Display Debug Text on screen
        //            var debugText = ""
        //            debugText += colorText
        //            self.debugTextView.text = debugText
        //        }
        
        
        
        // Note: Not entirely sure if the ciImage is being interpreted as RGB, but for now it works with the Inception model.
        // Note2: Also uncertain if the pixelBuffer should be rotated before handing off to Vision (VNImageRequestHandler) - regardless, for now, it still works well with the Inception model.
        
        ///////////////////////////
        // Prepare CoreML/Vision Request
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        // let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage!, orientation: myOrientation, options: [:])
        // Alternatively; we can convert the above to an RGB CGImage and use that. Also UIInterfaceOrientation can inform orientation values.
        
        ///////////////////////////
        // Run Image Request
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
        
    }
}



