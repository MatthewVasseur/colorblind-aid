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
    
    
    var screenCentre: CGPoint!
    var pixelInfo: Int!
    var pixel: Pixel!
    
    var latestPrediction: String = "…" // a variable containing the latest CoreML prediction
    
    private var latestColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.52)
    private var data: UnsafePointer<UInt8>!
    
    //var uiImage: UIImage!
    
    // Serial dispatch queue
    let dispatchQueue = DispatchQueue(label: "com.queues.dispatchqueue")
    
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
        
        // Set screen center point and pixel index
        screenCentre = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
        // Get the center pixel
        
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Begin Loop to Update Color labeler
        loopColorLabelUpdate()
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
        
        let arHitTestResults = sceneView.hitTest(screenCentre, types: [.featurePoint, .existingPlaneUsingExtent])
        // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
        
        // Find closest hit
        if let closestResult = arHitTestResults.first {
            
            // Get Coordinates of HitTest
            let transform = closestResult.worldTransform
            let worldCoord = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            // get RGB values
//            let r = Int(data[pixelInfo])
//            let g = Int(data[pixelInfo+1])
//            let b = Int(data[pixelInfo+2])
//            let a = Int(data[pixelInfo+3]) / CGFloat(255.0)
            pixelInfo = Int((sceneView.frame.width * screenCentre.y) + screenCentre.x) * 4
            let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
            let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
            let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
            
            //pixel = Pixel.init(data: data, pixelInfo: 0)
//            self.latestColor = pixel.toUIColor()
//            let colorText = pixel.toRGBString()
            
            // Store the latest prediction
            //            self.latestPrediction = colorText
            
            //print(pixel.toXYZ())
//            print(colorText)
            
            // Display Debug Text on screen
//            self.debugTextView.text = colorText
            
            debugTextView.backgroundColor = latestColor
            //imageView.image = uiImage
            
            // Create 3D Text
            let node = createNewBubbleParentNode("colorText")
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
    
    // MARK: - Color labeling handling
    func loopColorLabelUpdate() {
        // Continuously run the photo getter (Preventing 'hiccups' in Frame Rate)
        
        dispatchQueue.async {
            // 1. Run Update
            self.updateColorLabel()
            
            // 2. Loop this function
            self.loopColorLabelUpdate()
        }
    }
    
    func updateColorLabel() {
        // Get Camera Image as pixel data
        guard let pixbuff = (sceneView.session.currentFrame?.capturedImage) else {
            return
        }
        
        // Create cgImage
        let ciImage = CIImage(cvPixelBuffer: pixbuff)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        //uiImage = UIImage(cgImage: cgImage!, scale: 1.0, orientation: .right)
        
        // Extract pixel data and create new pixel
        data = CFDataGetBytePtr(cgImage?.dataProvider?.data)
    }
}



