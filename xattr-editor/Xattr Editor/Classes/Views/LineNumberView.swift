//
//  LineNumberView.swift
//  Xattr Editor
//
//  Created by Mark Sinkovics on 2018. 08. 24..
//
//
//  Based on: https://github.com/yichizhang/NSTextView-LineNumberView

import Cocoa

class LineNumberView : NSRulerView {
    
    var font: NSFont! {
        didSet {
            self.needsDisplay = true
        }
    }
    
    let lineNumberAttributes: [String : Any]
 
    init(textView: NSTextView) {
        font = textView.font ?? NSFont.systemFont(ofSize: NSFont.smallSystemFontSize())
        lineNumberAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: NSColor.gray
        ]
        super.init(scrollView: textView.enclosingScrollView!, orientation: NSRulerView.Orientation.verticalRuler)
        clientView = textView
        ruleThickness = 35
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func draw(lineNumber: String, textView: NSTextView, rect: CGRect) {
        let relativePoint = self.convert(NSPoint.zero, from: textView)
        let attributedString = NSAttributedString(string: lineNumber, attributes: lineNumberAttributes)
        let x = self.bounds.width - attributedString.size().width - 8
        attributedString.draw(at: NSPoint(x: x, y: relativePoint.y + rect.minY))
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        
        guard let textView = self.clientView as? NSTextView,
                let layoutManager = textView.layoutManager,
                let textContainer = textView.textContainer,
                let textViewString = textView.string
        else {
            return
        }

        let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textContainer)
        let firstVisibleGlyphCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)
        
        // The line number for the first visible line
        let range = Range(NSRange(location: 0, length: firstVisibleGlyphCharacterIndex), in: textViewString)
        var lineNumberCounter = textViewString.substring(with: range!).components(separatedBy: "\n").count
        var glyphIndexForStringLine = visibleGlyphRange.location
        
        // Go through the text line by line
        while glyphIndexForStringLine < NSMaxRange(visibleGlyphRange) {
            
            guard let str = textViewString as NSString? else { return }
    
            // Range of current line in the string.
            let characterRangeForStringLine = str.lineRange(for: NSRange(location: layoutManager.characterIndexForGlyph(at: glyphIndexForStringLine), length: 0))
            let glyphRangeForStringLine = layoutManager.glyphRange(forCharacterRange: characterRangeForStringLine, actualCharacterRange: nil)

            var glyphIndexForGlyphLine = glyphIndexForStringLine
            var glyphLineCount = 0

            while (glyphIndexForGlyphLine < NSMaxRange(glyphRangeForStringLine)) {

                // See if the current line in the string spread across
                // several lines of glyphs
                var effectiveRange = NSMakeRange(0, 0)

                // Range of current "line of glyphs". If a line is wrapped,
                // then it will have more than one "line of glyphs"
                let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndexForGlyphLine, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)

                let lineNumber = (glyphLineCount > 0 ? "-" :  "\(lineNumberCounter)")
                draw(lineNumber: lineNumber, textView: textView, rect: lineRect)

                glyphLineCount += 1
                glyphIndexForGlyphLine = NSMaxRange(effectiveRange)
            }

            glyphIndexForStringLine = NSMaxRange(glyphRangeForStringLine)
            lineNumberCounter += 1
        }
        
        // Draw line number for the extra line at the end of the text
        if layoutManager.extraLineFragmentTextContainer != nil {
            draw(lineNumber: "\(lineNumberCounter)", textView: textView, rect: layoutManager.extraLineFragmentRect)
        }
    }
}
