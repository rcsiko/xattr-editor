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

var LineNumberViewAssociatedObjectKey: UInt8 = 0

extension NSTextView {
    
    var lineNumberView: LineNumberView {
        get {
            return objc_getAssociatedObject(self, &LineNumberViewAssociatedObjectKey) as! LineNumberView
        }
        set {
            objc_setAssociatedObject(self, &LineNumberViewAssociatedObjectKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(_frameDidChange), name: NSNotification.Name.NSViewFrameDidChange, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(_textDidChange), name: NSNotification.Name.NSTextDidChange, object: self)
    }
    
    @objc func _frameDidChange(notification: NSNotification) {
        lineNumberView.needsDisplay = true
    }
    
    @objc func _textDidChange(notification: NSNotification) {
        lineNumberView.needsDisplay = true
    }
}
