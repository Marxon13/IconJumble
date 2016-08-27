//
//  IconJumbleScene.swift
//  IconJumble
//
//  Created by McQuilkin, Brandon (NonEmp) on 8/20/16.
//  Copyright © 2016 Brandon McQuilkin. All rights reserved.
//

import Cocoa
import SpriteKit

private let spriteCategory: UInt32 = 0x1 << 1
private let wallCategory: UInt32 = 0x1 << 2

class IconJumbleScene: SKScene, SKPhysicsContactDelegate, IconJumbleDefaultsDelegate {
    
    //--------------------------------
    // MARK: Properties
    //--------------------------------
    
    /// The maximum limit of sprites to load.
    internal var spriteCountLimit: Int =  Int.max
    /// The maximum velocity of the sprites.
    internal var maximumInitialImpulse: CGFloat = 100.0
    /// The maximum angular velocity of the sprites.
    internal var maximumInitialAngularImpulse: CGFloat = 0.5
    /// The distance the bounding box is beyond the screen.
    internal var sceneBorderExtension: CGFloat = 250.0
    
    internal var topZPosition: UInt = 0
    
    /**
     The defaults controller.
     */
    fileprivate let defaults: IconJumbleDefaults = IconJumbleDefaults()
    
    //--------------------------------
    // MARK: Initalization
    //--------------------------------
    
    override init() {
        super.init()
        sharedSetup()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        sharedSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedSetup()
    }
    
    fileprivate func sharedSetup() {
        // Set the scene's resize mode.
        scaleMode = SKSceneScaleMode.resizeFill
        
        // Set other properties
        backgroundColor = NSColor.white
        name = "IconJumbleScene"
        
        // Set the defaults delegate
        defaults.delegate = self
        defaults.setupLibraryIfNecessary()
        
        // Update the physics
        updatePhysics()
        
        // Load the sprites
        reloadSprites()
    }
    
    fileprivate func updatePhysics() {
        // Set an edge loop with the current bounds
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: -sceneBorderExtension, y: -sceneBorderExtension, width: frame.size.width + (2 * sceneBorderExtension), height: frame.size.height + (2 * sceneBorderExtension)))
        physicsBody?.friction = 0.0
        physicsBody?.collisionBitMask = 0x1 << 1
        physicsBody?.categoryBitMask = wallCategory
        physicsBody?.contactTestBitMask = spriteCategory
        physicsBody?.friction = 0.0
        physicsBody?.linearDamping = 0.0
        physicsBody?.angularDamping = 0.0
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
    }
    
    //----------------------------
    // MARK: Configuration
    //----------------------------
    
    func iconJumbleDefaultsConfigurationDidChange() {
        reloadSprites()
    }
    
    //--------------------------------
    // MARK: Layout
    //--------------------------------
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        // Update the physics body for the new bounds
        updatePhysics()
    }
    
    //--------------------------------
    // MARK: Node Loading
    //--------------------------------
    
    fileprivate func reloadSprites() {
        // Clear all the children from the scene
        removeAllChildren()
        
        // Load new sprites if any were specified
        
        let directoryPath = defaults.folderToLoad
        let sourceName = defaults.sourceToDisplay
        
        // Retreive all the pngs in the folder.
        if let enumerator: FileManager.DirectoryEnumerator = FileManager.default.enumerator(atPath: directoryPath) {
            while let path: String = enumerator.nextObject() as? String {
                // Skip any non-png images
                if !path.hasSuffix("png") {
                    continue
                }
                
                // Create a node
                let spritePath: String = directoryPath + ("/" + path)
                if let spriteImage: NSImage = NSImage(contentsOfFile: spritePath) {
                    
                    // Resize the image if necessary
                    let sprite: SKSpriteNode = SKSpriteNode(texture: SKTexture(image: spriteImage))
                    // Set a random location of the sprite.
                    sprite.position = CGPoint(x: CGFloat.random(min: -sceneBorderExtension, max: frame.size.width + sceneBorderExtension), y: CGFloat.random(min: -sceneBorderExtension, max: frame.size.height + sceneBorderExtension))
                    
                    // Set other properties
                    sprite.physicsBody = SKPhysicsBody(circleOfRadius: (sprite.size.width + sprite.size.height) / 4.0)
                    sprite.physicsBody?.friction = 0.0
                    sprite.physicsBody?.restitution = 1
                    sprite.physicsBody?.linearDamping = 0.0
                    sprite.physicsBody?.angularDamping = 0.0
                    sprite.physicsBody?.mass = 1.0
                    sprite.physicsBody?.collisionBitMask = wallCategory
                    sprite.physicsBody?.categoryBitMask = spriteCategory
                    sprite.physicsBody?.contactTestBitMask = wallCategory
                    sprite.physicsBody?.affectedByGravity = false
                    
                    // Add the node to the scene.
                    addChild(sprite)
                    let speed = defaults.speed(forSource: sourceName)
                    let angularSpeed = defaults.angularSpeed(forSource: sourceName)
                    let dx = CGFloat.random(min: -CGFloat(speed), max: CGFloat(speed))
                    let dy = CGFloat.random(min: -CGFloat(speed), max: CGFloat(speed))
                    sprite.physicsBody!.applyImpulse(CGVector(dx: dx, dy: dy))
                    let da = CGFloat.random(min: -CGFloat(angularSpeed), max: CGFloat(angularSpeed))
                    sprite.physicsBody!.applyAngularImpulse(da)
                    
                    // Debug
                    if children.count > spriteCountLimit {
                        break
                    }
                }
            }
        }
    }
    
    //--------------------------------
    // MARK: Physics Delegate
    //--------------------------------
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Get the physics body of the sprite node
        let nodeBody: SKPhysicsBody = contact.bodyA != scene?.physicsBody ? contact.bodyA : contact.bodyB
        if let spriteNode: SKSpriteNode = nodeBody.node as? SKSpriteNode {
            // Move the sprite to the top after it hits the edge. That way the order of sprites changes and all will be visible at some point.
            spriteNode.zPosition = CGFloat(topZPosition)
            topZPosition = topZPosition &+ 1
        }
    }
}

public extension CGFloat {
    
    public static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
}
