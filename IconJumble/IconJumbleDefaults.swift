//
//  IconJumbleDefaults.swift
//  IconJumble
//
//  Created by McQuilkin, Brandon (NonEmp) on 8/20/16.
//  Copyright © 2016 Brandon McQuilkin. All rights reserved.
//

import Cocoa
import ScreenSaver

/**
 The delegate protocol for the defaults.
 */
protocol IconJumbleDefaultsDelegate {
    
    /**
     Notifies the delegate that the configuration did change.
     */
    func iconJumbleDefaultsConfigurationDidChange()
}

fileprivate let IconJumbleConfigurationDidChangeNotificationName = "IconJumbleConfigurationDidChangeNotification"
fileprivate let IconJumbleBundleIdentifier = "com.BrandonMcQuilkin.IconJumble"

fileprivate let IconJumbleSourceToDisplayKey: String = "sourceToDisplay"
fileprivate let IconJumbleRandomFolderKey: String = "randomFolder"
fileprivate let IconJumbleLibraryDefaultsKey: String = "libraryDefaults"

fileprivate let IconJumbleSpeedKey: String = "speed"
fileprivate let IconJumbleAngularSpeedKey: String = "angularSpeed"

class IconJumbleDefaults: NSObject {
    
    //----------------------------
    // MARK: Properties
    //----------------------------
    
    /**
     The defaults used to load and save the values to/from disk.
     */
    fileprivate var screenSaverDefaults: ScreenSaverDefaults?
    
    /**
     The defaults delegate.
     */
    var delegate: IconJumbleDefaultsDelegate?
    
    /**
     Whether or not to save the changes.
     */
    fileprivate var saveChanges: Bool = true
    
    /**
     The defaults for the various icon libraries.
    */
    fileprivate var libraryDefaults: [String: [String: Float]] = [:]
    
    /**
     The name of the folder that all the icons are sourced from.
     */
    var sourceToDisplay: String = "Default Icons" {
        didSet {
            save()
        }
    }
    
    /**
     The speed of the icons for the given source.
    */
    func speed(forSource: String) -> Float {
        if let speed = libraryDefaults[sourceToDisplay]?[IconJumbleSpeedKey] {
            return speed
        }
        return 100.0
    }
    
    /**
     Set the speed of the icons for the given source.
    */
    func setSpeed(speed: Float, forSource: String) {
        if libraryDefaults[forSource] == nil {
            libraryDefaults[forSource] = [:]
        }
        libraryDefaults[forSource]?[IconJumbleSpeedKey] = speed
        save()
    }
    
    /**
     The angular speed of the icons for the given source.
     */
    func angularSpeed(forSource: String) -> Float {
        if let speed = libraryDefaults[sourceToDisplay]?[IconJumbleAngularSpeedKey] {
            return speed
        }
        return 0.25
    }
    
    /**
     Set the angulat speed of the icons for the given source.
     */
    func setAngularSpeed(speed: Float, forSource: String) {
        if libraryDefaults[forSource] == nil {
            libraryDefaults[forSource] = [:]
        }
        libraryDefaults[forSource]?[IconJumbleAngularSpeedKey] = speed
        save()
    }
    
    /**
     Whether or not to pick a random folder to display.
     */
    var randomFolder: Bool = true {
        didSet {
            save()
        }
    }
    
    /**
     The path to the library where the icons are pulled from.
     */
    var libraryDirectory: String {
        // Generate the path to the icon library.
        let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]
        let libraryDirectory = applicationSupportDirectory + "/" + IconJumbleBundleIdentifier
        // Create the folder if necessary.
        if !FileManager.default.fileExists(atPath: libraryDirectory, isDirectory: nil) {
            try! FileManager.default.createDirectory(atPath: libraryDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        return libraryDirectory
    }
    
    /**
     Sets up the library by copying the default icons if they don't exist and there are not other icons in the foulder.
     */
    func setupLibraryIfNecessary() {
        if try! FileManager.default.contentsOfDirectory(atPath: libraryDirectory).count == 0 {
            let defaultDest = libraryDirectory + "/" + "Default Icons"
            let defaultSource = Bundle(for: IconJumbleDefaults.self).path(forResource: "Default Icons", ofType: nil)!
            try! FileManager.default.copyItem(atPath: defaultSource, toPath: defaultDest)
        }
    }
    
    var folderToLoad: String {
        
        // Get the contents of the library.
        let contents = try! FileManager.default.contentsOfDirectory(atPath: libraryDirectory)
        var folders: [String] = []
        
        // Sort out the non-folder contents.
        for content in contents {
            let dir = libraryDirectory + "/" + content
            var isDir: ObjCBool = false
            
            FileManager.default.fileExists(atPath: dir, isDirectory: &isDir)
            
            if isDir.boolValue == true {
                folders.append(dir)
            }
        }
        
        // If we have the source folder, and we are not displaying a random folder.
        if folders.contains(libraryDirectory + "/" + sourceToDisplay) && !randomFolder {
            return libraryDirectory + "/" + sourceToDisplay
        } else {
            return folders[Int.random(folders.count - 1)]
        }
    }
    
    //----------------------------
    // MARK: Initalization
    //----------------------------
    
    override init() {
        super.init()
        screenSaverDefaults = ScreenSaverDefaults(forModuleWithName: IconJumbleBundleIdentifier)
        register()
        revert()
        
        // Register for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(IconJumbleDefaults.configurationDidChange(_:)), name: NSNotification.Name(rawValue: IconJumbleConfigurationDidChangeNotificationName), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: IconJumbleConfigurationDidChangeNotificationName), object: nil)
    }
    
    //----------------------------
    // MARK: Actions
    //----------------------------
    
    internal func configurationDidChange(_ notification: Notification) {
        // Load the values from defaults
        revert()
        // Notify the delegate
        if let delegate = delegate {
            delegate.iconJumbleDefaultsConfigurationDidChange()
        }
    }
    
    /**
     Registers the default values.
     */
    func register() {
        screenSaverDefaults?.register(defaults: [
            IconJumbleSourceToDisplayKey: sourceToDisplay,
            IconJumbleRandomFolderKey: randomFolder,
            IconJumbleLibraryDefaultsKey: libraryDefaults
            ])
    }
    
    /**
     Saves the current values to disk and notifies the observers.
     */
    func save() {
        if saveChanges {
            // Save all parameters to defaults.
            screenSaverDefaults?.set(sourceToDisplay, forKey: IconJumbleSourceToDisplayKey)
            screenSaverDefaults?.set(randomFolder, forKey: IconJumbleRandomFolderKey)
            screenSaverDefaults?.set(libraryDefaults, forKey: IconJumbleLibraryDefaultsKey)
            notify()
        }
    }
    
    /**
     Reverts the current values to the values saved on disk and notifies the observers.
     */
    func revert() {
        saveChanges = false
        // Revert all changes to properties.
        if let value = screenSaverDefaults?.string(forKey: IconJumbleSourceToDisplayKey) {
            sourceToDisplay = value
        }
        if let value = screenSaverDefaults?.bool(forKey: IconJumbleRandomFolderKey) {
            randomFolder = value
        }
        if let value = screenSaverDefaults?.object(forKey: IconJumbleLibraryDefaultsKey) as? [String: [String: Float]] {
            libraryDefaults = value
        }
        saveChanges = true
    }
    
    /**
     Notifies the observers that the values changed.
     */
    func notify() {
        NotificationCenter.default.post(name: Notification.Name(rawValue:IconJumbleConfigurationDidChangeNotificationName), object: nil)
    }
}

public extension Int {
    
    public static func random(_ n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    public static func random(_ min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max - min + 1))) + min
    }
}
