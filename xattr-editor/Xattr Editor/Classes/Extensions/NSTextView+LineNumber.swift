//
//  NSTextView+LineNumber.swift
//  Xattr Editor
//
//  Created by Mark Sinkovics on 2018. 08. 24..
//
//
//  Based on: https://github.com/yichizhang/NSTextView-LineNumberView

import Cocoa
import ObjectiveC

var lineNumberViewAssociatedObjectKey: UInt8 = 0

extension NSTextView {

    var lineNumberView: LineNumberView? {
        get {
            return objc_getAssociatedObject(self, &lineNumberViewAssociatedObjectKey) as? LineNumberView
        }
        set {
            objc_setAssociatedObject(self,
                                     &lineNumberViewAssociatedObjectKey,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func showLineNumberView() {
        font = font ?? NSFont.systemFont(ofSize: 16)
        if let scrollView = enclosingScrollView {
            lineNumberView = LineNumberView(textView: self)
            scrollView.verticalRulerView = lineNumberView
            scrollView.hasVerticalRuler = true
            scrollView.rulersVisible = true
        }

        postsFrameChangedNotifications = true

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textView_frameDidChange),
                                               name: NSTextView.frameDidChangeNotification,
                                               object: self)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textView_textDidChange),
                                               name: NSTextView.didChangeNotification,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textView_selectionDidChange),
                                               name: NSTextView.didChangeSelectionNotification,
                                               object: self)
    }

    @objc func textView_frameDidChange(notification: NSNotification) {
        lineNumberView?.needsDisplay = true
    }

    @objc func textView_textDidChange(notification: NSNotification) {
        lineNumberView?.needsDisplay = true
    }

    @objc func textView_selectionDidChange(notification: NSNotification) {
        lineNumberView?.needsDisplay = true
    }
}
