//
//  AppDelegate.swift
//  Xattr Editor
//
//  Created by Richard Csiko on 2017. 01. 21..
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let openWindowController = OpenFileWindowController(windowNibName: "OpenFileWindow")
    var inspectorWindowControllers = [NSWindowController]()

    func openFileAttributeInspector(forFile fileURL: URL) {
        let attributeInspectorWindowController = AttributeInspectorWindowController(windowNibName: "AttributeInspectorWindow")
        inspectorWindowControllers.append(attributeInspectorWindowController)

        attributeInspectorWindowController.fileURL = fileURL
        attributeInspectorWindowController.showWindow(nil)
        openWindowController.close()
    }

    @IBAction func showOpenDialog(_ sender: AnyObject) {

        let fileDialog: NSOpenPanel = NSOpenPanel()
        fileDialog.runModal()

        if let url = fileDialog.url {
            openFileAttributeInspector(forFile: url)
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        openWindowController.showWindow(nil)
        openWindowController.openCallback = { [weak self] url in
            self?.openFileAttributeInspector(forFile: url)
        }
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)

        openFileAttributeInspector(forFile: url)

        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        } else {
            openWindowController.window?.makeKeyAndOrderFront(nil);
            return true
        }
    }
}
