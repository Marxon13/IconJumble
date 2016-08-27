//
//  IconJumbleConfigurationWindowController.swift
//  IconJumble
//
//  Created by McQuilkin, Brandon (NonEmp) on 8/20/16.
//  Copyright © 2016 Brandon McQuilkin. All rights reserved.
//

import Cocoa

class IconJumbleConfigurationWindowController: NSWindowController {
    
    //----------------------------
    // MARK: Properties
    //----------------------------
    
    /**
     The defaults object instantiated by the nib.
     */
    var defaults: IconJumbleDefaults = IconJumbleDefaults()
    
    @IBOutlet weak var libraryButton: NSPopUpButton?
    @IBOutlet weak var randomCheckbox: NSButton?
    
    @IBOutlet weak var libraryOptionsButton: NSPopUpButton?
    @IBOutlet weak var speedField: NSTextField?
    @IBOutlet weak var angularSpeedField: NSTextField?
    
    override var windowNibName: String {
        return "IconJumbleConfigurationWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        let contents = try! FileManager.default.contentsOfDirectory(atPath: defaults.libraryDirectory)

        // Populate the pop up button.
        for content in contents {
            let dir = defaults.libraryDirectory + "/" + content
            var isDir: ObjCBool = false
            
            FileManager.default.fileExists(atPath: dir, isDirectory: &isDir)
            
            if isDir.boolValue == true {
                libraryButton?.addItem(withTitle: content)
                libraryOptionsButton?.addItem(withTitle: content)
            } else {
                continue
            }
            
            if content == defaults.sourceToDisplay {
                libraryButton?.selectItem(at: libraryButton!.itemArray.count - 1)
                libraryOptionsButton?.selectItem(at: libraryOptionsButton!.itemArray.count - 1)
            }
            
        }
        
        // Populate the checkbox.
        randomCheckbox?.state = defaults.randomFolder ? NSOnState : NSOffState
        if defaults.randomFolder {
            libraryButton?.isEnabled = false
        }
        
        // Populate the text fields.
        speedField?.floatValue = defaults.speed(forSource: defaults.sourceToDisplay)
        angularSpeedField?.floatValue = defaults.angularSpeed(forSource: defaults.sourceToDisplay)
        
    }
    
    //----------------------------
    // MARK: Values
    //----------------------------
    
    @IBAction func libraryChange(sender: NSPopUpButton) {
        if let currentItem = sender.selectedItem?.title {
            defaults.sourceToDisplay = currentItem
        }
    }
    
    @IBAction func libraryOptionChange(sender: NSPopUpButton) {
        // Populate the text fields.
        if let currentItem = sender.selectedItem?.title {
            speedField?.floatValue = defaults.speed(forSource: currentItem)
            angularSpeedField?.floatValue = defaults.angularSpeed(forSource: currentItem)
        }
    }
    
    @IBAction func randomLibraryChanged(sender: NSButton) {
        defaults.randomFolder = sender.state == NSOnState
        
        libraryButton?.isEnabled = !defaults.randomFolder
    }
    
    @IBAction func speedChanged(sender: NSTextField) {
        if let selectedSource = libraryOptionsButton?.selectedItem?.title {
            defaults.setSpeed(speed: sender.floatValue, forSource: selectedSource)
        }
    }
    
    @IBAction func angularSpeedChanged(sender: NSTextField) {
        if let selectedSource = libraryOptionsButton?.selectedItem?.title {
            defaults.setAngularSpeed(speed: sender.floatValue, forSource: selectedSource)
        }
    }
    
    
    //----------------------------
    // MARK: Actions
    //----------------------------
    
    @IBAction func close(_ sender: AnyObject) {
        // Close
        if let window = window {
            window.sheetParent?.endSheet(window, returnCode: NSModalResponseOK)
        }
    }
    
    @IBAction func openLibrary(_ sender: AnyObject) {
        NSWorkspace.shared().openFile(defaults.libraryDirectory)
    }
    
}
