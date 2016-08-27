//
//  AppDelegate.swift
//  IconJumbleDemo
//
//  Created by McQuilkin, Brandon (NonEmp) on 8/20/16.
//  Copyright © 2016 Brandon McQuilkin. All rights reserved.
//

import Cocoa
import ScreenSaver

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var saverView: IconJumbleView!
    
    @IBAction func showConfiguration(_ sender: NSObject!) {
        if saverView.hasConfigureSheet() {
            if let window = window {
                window.beginSheet(saverView.configureSheet()!) { (result: NSModalResponse) -> Void in
                    
                }
            }
        }
    }
    
    // MARK: - Private
    
    func endSheet(_ sheet: NSWindow) {
        sheet.close()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        saverView = IconJumbleView(frame: window.contentView!.bounds, isPreview: false)
        saverView.translatesAutoresizingMaskIntoConstraints = false
        saverView.startAnimation()
        
        saverView.sceneView.showsDrawCount = true
        saverView.sceneView.showsNodeCount = true
        saverView.sceneView.showsFPS = true
        
        // Add the view to the window
        window.contentView!.addSubview(saverView)
        
        window.contentView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: ["view": saverView]))
        window.contentView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["view": saverView]))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

