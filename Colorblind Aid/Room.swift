//
//  Room.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/29/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import Foundation
import SceneKit
import os.log

class Room: NSObject, NSCoding {
    // MARK: - Properties
    var name: String
    var nodes: [Node]
    var image: UIImage
    
    // MARK: - Types
    struct PropertyKey {
        static let name = "name"
        static let nodes = "nodes"
        static let image = "image"
    }
    
    //MARK: - Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("rooms")

    
    // MARK: - Initializers
    init(name: String, nodes: [Node], image: UIImage) {
        self.name = name
        self.nodes = nodes
        self.image = image
    }
    
    // MARK: - NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(nodes, forKey: PropertyKey.nodes)
        aCoder.encode(image, forKey: PropertyKey.image)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Room object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // The nodes are required
        guard let nodes = aDecoder.decodeObject(forKey: PropertyKey.nodes) as? [Node] else {
            os_log("Unable to decode the nodes for a Room object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // The image is required
        guard let image = aDecoder.decodeObject(forKey: PropertyKey.image) as? UIImage else {
            os_log("Unable to decode the image for a Room object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(name: name, nodes: nodes, image: image)
    }
    
    /// Save the rooms
    static func saveRooms() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(AppState.sharedInstance.rooms, toFile: Room.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Rooms successfully saved.", log: .default, type: .debug)
        } else {
            os_log("Failed to save rooms...", log: .default, type: .error)
        }
    }
    
    // Load the rooms
    static func loadRooms() -> [Room]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Room.ArchiveURL.path) as? [Room]
    }
    
    // MARK: - Node Structure
    struct Node {
        var title: String
        // Coord
        var x: Float
        var y: Float
        var z: Float
        
        init(title: String, vector: SCNVector3) {
            self.title = title
            self.x = vector.x
            self.y = vector.y
            self.z = vector.z
        }
    }
}
