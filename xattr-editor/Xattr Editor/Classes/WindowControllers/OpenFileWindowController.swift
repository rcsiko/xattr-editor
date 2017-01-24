//
//  OpenFileWindowController.swift
//  Xattr Editor
//
//  Created by Richard Csiko on 2017. 01. 21..
//

import Cocoa

class OpenFileWindowController: NSWindowController {

    @IBOutlet weak var dragView: DragDestinationView!

    public var openCallback: ((_ url: URL) -> ())? {
        didSet {
            dragView.dropCallback = openCallback
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
