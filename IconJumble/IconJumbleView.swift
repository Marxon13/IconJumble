//
//  IconJumbleView.swift
//  IconJumble
//
//  Created by McQuilkin, Brandon (NonEmp) on 8/20/16.
//  Copyright © 2016 Brandon McQuilkin. All rights reserved.
//

import Cocoa
import ScreenSaver
import SpriteKit

class IconJumbleView: ScreenSaverView {
    
    //----------------------------
    // MARK: Properties
    //----------------------------
    
    /**
     The sprite view that will render SpriteKit scenes.
     */
    lazy var sceneView: SKView = SKView()
    
    //----------------------------
    // MARK: Initalization
    //----------------------------
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        sharedSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }
    
    func sharedSetup() {
        // Set up animation duration
        animationTimeInterval = 1.0 / 60.0
        
        // Setup the sprite kit view
        sceneView.wantsLayer = true // This is very very important!!!!!!
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sceneView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: ["view": sceneView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["view": sceneView]))
    }
    
    //----------------------------
    // MARK: Screen Saver
    //----------------------------
    
    override func startAnimation() {
        super.startAnimation()
        sceneView.presentScene(IconJumbleScene(size: sceneView.bounds.size), transition: SKTransition())
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    override func hasConfigureSheet() -> Bool {
        return true
    }
    
    override func configureSheet() -> NSWindow? {
        struct Holder {
            static var controller: IconJumbleConfigurationWindowController = IconJumbleConfigurationWindowController()
        }
        
        Holder.controller.loadWindow()
        Holder.controller.windowDidLoad()
        return Holder.controller.window
    }
    
    //----------------------------
    // MARK: Layout
    //----------------------------
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        sceneView.frame = NSRect(origin: CGPoint.zero, size: frame.size)
    }
    
    //--------------------------------
    // MARK: Drawing
    //--------------------------------
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
    }

    
}
