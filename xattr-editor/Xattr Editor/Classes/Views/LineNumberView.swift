//
//  LineNumberView.swift
//  Xattr Editor
//
//  Created by Mark Sinkovics on 2018. 08. 24..
//
//
//  Based on: https://github.com/yichizhang/NSTextView-LineNumberView

import Cocoa

class LineNumberView: NSRulerView {

    var font: NSFont! {
        didSet {
            self.needsDisplay = true
        }
    }

    let lineNumberAttributes: [NSAttributedString.Key: Any]

    init(textView: NSTextView) {
        font = textView.font ?? NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        lineNumberAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: NSColor.gray
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
        let offsetX = self.bounds.width - attributedString.size().width - 8
        attributedString.draw(at: NSPoint(x: offsetX, y: relativePoint.y + rect.minY))
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {

        guard let textView = self.clientView as? NSTextView,
                let layoutManager = textView.layoutManager,
                let textContainer = textView.textContainer
        else {
            return
        }

        let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textContainer)
        let firstVisibleGlyphCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)

        // The line number for the first visible line
        let range = Range(NSRange(location: 0, length: firstVisibleGlyphCharacterIndex), in: textView.string)!
        var lineNumberCounter = textView.string[range.lowerBound..<range.upperBound].components(separatedBy: "\n").count
        var glyphIndexForStringLine = visibleGlyphRange.location

        // Go through the text line by line
        while glyphIndexForStringLine < NSMaxRange(visibleGlyphRange) {

            guard let str = textView.string as NSString? else { return }

            // Range of current line in the string.
            let range = NSRange(location: layoutManager.characterIndexForGlyph(at: glyphIndexForStringLine), length: 0)
            let characterRangeForStringLine = str.lineRange(for: range)
            let glyphRangeForStringLine = layoutManager.glyphRange(forCharacterRange: characterRangeForStringLine,
                                                                   actualCharacterRange: nil)

            var glyphIndexForGlyphLine = glyphIndexForStringLine
            var glyphLineCount = 0

            while glyphIndexForGlyphLine < NSMaxRange(glyphRangeForStringLine) {

                // See if the current line in the string spread across
                // several lines of glyphs
                var effectiveRange = NSRange(location: 0, length: 0)

                // Range of current "line of glyphs". If a line is wrapped,
                // then it will have more than one "line of glyphs"
                let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndexForGlyphLine,
                                                              effectiveRange: &effectiveRange,
                                                              withoutAdditionalLayout: true)

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
