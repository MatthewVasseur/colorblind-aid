//
//  ARViewController.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 10/25/17.
//  Copyright © 2017 Matthew Vasseur. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

import UIImageColors

class ARViewController: UIViewController, ARSCNViewDelegate, SnapContainerViewElement {
    
    // Mark: - Properties
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var targetButton: UIButton!
    
    var snapContainer: SnapContainerViewController!
    
    private var targetCenter: CGPoint!
    
    private var nodes: [Node] = []
    private var lastUIImage: UIImage!
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the scene and scene view
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Enable Default Lighting - makes the 3D text a bit poppier
        sceneView.autoenablesDefaultLighting = true
        // Enable debug options
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set screen center point and pixel index
        targetCenter = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
        
        // Set the view's delegate
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration and enable plane detection
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("hi")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("uh oh")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - Actions
    
    @IBAction func handleTap(_ gestureRecognize: UITapGestureRecognizer) {
        // Get nearest object to center screen to color lable
        //        let touchLocation = sender.location(in: self.sceneView)
        
        let arHitTestResults = sceneView.hitTest(targetCenter, types: [.featurePoint, .existingPlaneUsingExtent])
        // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
        
        // Find closest hit
        if let closestResult = arHitTestResults.first {
            
            // Get Coordinates of HitTest
            let transform = closestResult.worldTransform
            let worldCoord = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            // Get Camera Image as pixel data and create ciImage
            guard let pixbuff = (sceneView.session.currentFrame?.capturedImage) else {
                return
            }
            let ciImage = CIImage(cvPixelBuffer: pixbuff)
            let context = CIContext()
            
            // Created cropped image into square around center (using magic number 20)
            let imageCenter = CGPoint(x: ciImage.extent.width / 2.0, y: ciImage.extent.height / 2.0)
            let croppedSize = CGSize(forSquare: ciImage.extent.width / 20.0)
            let croppedRect = CGRect(center: imageCenter, size: croppedSize)
            let croppedCIImage = ciImage.cropped(to: croppedRect)
            guard let cgImage = context.createCGImage(croppedCIImage, from: croppedCIImage.extent) else {
                return
            }
            let uiImage = UIImage(cgImage: cgImage)//, scale: 1.0, orientation: .right)
            
            // Get image color and hue name
            let colors = uiImage.getColors()
            let colorText = colors.background.toHueName()
            
            // Create node
            drawNode(title: colorText, position: worldCoord)
        }
    }
    
    @IBAction func handleSaveButton(_ sender: UIButton) {
        // Ensure we have values
        if (nodes.isEmpty || lastUIImage == nil) {
            return
        }
        
        // Use prompt for saving the room
        let savePrompt = UIAlertController(title: "Save Room", message: "Save the labels in this room?", preferredStyle: .alert)
        savePrompt.popoverPresentationController?.sourceView = self.view
        
        let save = UIAlertAction(title: "Save", style: .default) { _ in
            // Get title and create
            guard let title = savePrompt.textFields?.first?.text, !title.isEmpty else {
                return
            }
            let room = Room(name: title, nodes: self.nodes, image: self.lastUIImage)
            
            // Save the room
            AppState.sharedInstance.rooms.append(room)
            Room.saveRooms()
            
            // Reload saved rooms
            guard let roomsCollection = (self.snapContainer.leftVC as? RoomsViewController)?.collectionView else {
                fatalError("Big error in left VC!")
            }
            roomsCollection.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        savePrompt.addTextField { (textField) in
            textField.placeholder = "Name of Room"
        }
        savePrompt.addAction(save)
        savePrompt.addAction(cancel)
        
        self.present(savePrompt, animated: true, completion: nil)
    }
    
    @IBAction func handleRemoveButton(_ sender: UIButton) {
        // Remove all nodes
        for node in sceneView.scene.rootNode.childNodes {
            node.removeFromParentNode()
        }
        nodes.removeAll()
    }
    
    @IBAction func handleCaptureButton(_ sender: UIButton) {
        // Get camera image
        let uiImage = sceneView.snapshot()
        
        guard let filterVC = snapContainer.rightVC as? FilterViewController else {
            fatalError("Wrong VC type.")
        }
        
        filterVC.setImage(uiImage)
        snapContainer.move(to: "right")
    }
    
    @IBAction func showFilter(_ sender: Any) {
        snapContainer.move(to: "right")
    }
    @IBAction func showSettings(_ sender: Any) {
        snapContainer.move(to: "left")
    }
    
    // MARK: - Helper Methods
    func setNodes(_ newNodes: [Node]) {
        // Remove all existing nodes
        for node in sceneView.scene.rootNode.childNodes {
            node.removeFromParentNode()
        }
        self.nodes.removeAll()
        
        // Draw new nodes
        for node in newNodes {
            let position = SCNVector3(node.x, node.y, node.z)
            drawNode(title: node.title, position: position)
        }
    }
    
    func drawNode(title: String, position: SCNVector3) {
        // Create and draw 3D bubble node
        let node = createNewBubbleParentNode(title)
        sceneView.scene.rootNode.addChildNode(node)
        node.position = position
        
        // Add to nodes and save image
        lastUIImage = sceneView.snapshot()
        nodes.append(Node(title: title, vector: position))
        //            nodes.append(Node(title: colorText, x: Double(worldCoord.x), y: Double(worldCoord.y), z: Double(worldCoord.z)))
    }
    
    fileprivate func createNewBubbleParentNode(_ text: String) -> SCNNode {
        // Warning: Creating 3D Text is susceptible to crashing. To reduce chances of crashing; reduce number of polygons, letters, smoothness, etc.
        
        let bubbleDepth: Float = 0.01 // the 'depth' of 3D text
        
        // Text billboard constraint
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // Create the bubble text
        let bubble = SCNText(string: text, extrusionDepth: CGFloat(bubbleDepth))
        bubble.font = UIFont(name: "Futura", size: 0.075)?.withTraits(traits: .traitBold)
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
}
