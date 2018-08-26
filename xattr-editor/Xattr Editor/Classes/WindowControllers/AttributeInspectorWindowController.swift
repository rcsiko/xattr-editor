//
//  AttributeInspectorWindowController.swift
//  Xattr Editor
//
//  Created by Richard Csiko on 2017. 01. 21..
//

import Cocoa

class AttributeInspectorWindowController: NSWindowController {

    // MARK: Properties

    @IBOutlet weak var tableView: NSTableView?
    @IBOutlet weak var attributeValueField: NSTextView!
    @IBOutlet weak var refreshButton: NSButton!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!

    fileprivate var fileAttributes: Array? = [Attribute]()

    fileprivate var selectedAttribute: Attribute? {
        didSet {
            updateAttributeValueField(withAttribute: selectedAttribute)
        }
    }

    public var fileURL: URL? {
        didSet {
            window?.title = fileURL?.lastPathComponent ?? "-"
            self.refresh(nil)
        }
    }

    // MARK: Overrides

    override func windowDidLoad() {
        super.windowDidLoad()
        tableView?.reloadData()

        refreshButton.image = NSImage(named: NSImage.refreshTemplateName)
        addButton.image = NSImage(named: NSImage.addTemplateName)
        removeButton.image = NSImage(named: NSImage.removeTemplateName)

        attributeValueField.isAutomaticQuoteSubstitutionEnabled = false
    }

    // MARK: Utils

    func readExtendedAttributes(fromURL url: URL?) throws -> [Attribute]? {
        guard let attrs = try url?.attributes() else { return nil }
        var xAttrs = [Attribute]()

        for (key, value) in attrs {
            xAttrs.append(Attribute(name: key, value: value))
        }

        return xAttrs
    }

    func updateAttributeValueField(withAttribute attribute: Attribute?) {
        attributeValueField.string = attribute?.value ?? ""
    }

    func showErrorModal(_ error: NSError) {
        let alert = NSAlert()
        alert.messageText = "Error code: \(error.code)"
        alert.informativeText = error.domain
        alert.alertStyle = .critical
        alert.runModal()
    }

    // MARK: Actions

    @IBAction func saveExtendedAttributes(_ sender: AnyObject?) {
        guard let attributes = fileAttributes else { return }
        guard let url = fileURL else { return }

        for attribute in attributes where attribute.isModified {
            do {
                try url.removeAttribute(name: attribute.originalName)
                try url.setAttribute(name: attribute.name, value: attribute.value ?? "")
            } catch let error as NSError {
                showErrorModal(error)
            }
        }
    }

    @IBAction func refresh(_ sender: AnyObject?) {
        do {
            try fileAttributes = readExtendedAttributes(fromURL: fileURL)
            tableView?.reloadData()
        } catch let error as NSError {
            showErrorModal(error)
        }

    }

    @IBAction func addAttribute(_ sender: AnyObject?) {
        guard let url = fileURL else { return }

        let alert = NSAlert()
        alert.messageText = "Extended attribute name:"
        alert.addButton(withTitle: "Ok")
        alert.addButton(withTitle: "Cancel")

        let inputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        inputField.bezelStyle = .roundedBezel
        alert.accessoryView = inputField

        alert.beginSheetModal(for: self.window!) { [weak self] response in
            if response == .alertSecondButtonReturn || inputField.stringValue.isEmpty {
                return
            }

            do {
                try url.setAttribute(name: inputField.stringValue, value: "")
                self?.refresh(nil)
            } catch let error as NSError {
                self?.showErrorModal(error)
            }
        }
    }

    @IBAction func removeAttribute(_ sender: AnyObject?) {
        guard let attrubute = selectedAttribute else { return }
        guard let url = fileURL else { return }

        do {
            try url.removeAttribute(name: attrubute.name)
            refresh(nil)
        } catch let error as NSError {
            showErrorModal(error)
        }
    }
}

extension AttributeInspectorWindowController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let attr = fileAttributes?[row] else {
            return nil
        }

        let identifier = NSUserInterfaceItemIdentifier(rawValue: "AttributeCellIdentifier")

        if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? AttributeCellView {
            cell.attribute = attr
            cell.attributeDidChangeCallback = { [weak self] in
                self?.saveExtendedAttributes(nil)
            }
            return cell
        }

        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tblView = tableView else { return }

        if tblView.selectedRow == -1 {
            selectedAttribute = nil
            return
        }

        selectedAttribute = fileAttributes?[tblView.selectedRow]
    }

}

extension AttributeInspectorWindowController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return fileAttributes?.count ?? 0
    }

}

extension AttributeInspectorWindowController: NSTextDelegate {

    func textDidChange(_ notification: Notification) {
        guard let editor = notification.object as? NSTextView else { return }
        guard let attribute = selectedAttribute else { return }
        if editor.string == attribute.value { return }

        selectedAttribute!.value = editor.string
    }

    func textDidEndEditing(_ notification: Notification) {
        saveExtendedAttributes(nil)
    }
}
