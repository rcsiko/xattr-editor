//
//  DragDestinationView.swift
//  Xattr Editor
//
//  Created by Csiko Richard on 2017. 01. 23..
//

import Cocoa

// https://stackoverflow.com/a/46514780
extension NSPasteboard.PasteboardType {
    static let backwardsCompatibleFileURL: NSPasteboard.PasteboardType = {
        if #available(OSX 10.13, *) {
            return NSPasteboard.PasteboardType.fileURL
        } else {
            return NSPasteboard.PasteboardType(kUTTypeFileURL as String)
        }
    } ()
}

class DragDestinationView: NSView {

    var dropCallback: ((_ url: URL) -> ())?

    private enum Appearance {
        static let lineWidth: CGFloat = 10.0
    }

    private var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }

    override func awakeFromNib() {
        registerForDraggedTypes([.backwardsCompatibleFileURL])
    }

    override func draw(_ dirtyRect: NSRect) {

        if !isReceivingDrag {
            return
        }

        NSColor.selectedControlColor.set()

        let path = NSBezierPath(rect:bounds)
        path.lineWidth = Appearance.lineWidth
        path.stroke()
    }

    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        return nil
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        isReceivingDrag = true
        return .copy
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }

    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {

        isReceivingDrag = false
        let pasteBoard = draggingInfo.draggingPasteboard

        guard let url = pasteBoard.readObjects(forClasses: [NSURL.self], options:nil) as? [URL] else { return false }
        guard let callback = dropCallback else { return false }

        for url in url {
            NSLog("\(url)")
            callback(url)
        }
        
        return false
    }
    
}
