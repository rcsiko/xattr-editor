//
//  Attribute.swift
//  Xattr Editor
//
//  Created by Richard Csiko on 2017. 01. 21..
//

class Attribute {
    let originalName: String
    let originalValue: String?

    var name: String
    var value: String?
    var isModified: Bool {
        return name != originalName || value != originalValue
    }

    init(name: String, value: String? = nil) {
        self.originalName = name
        self.name = name

        self.originalValue = value
        self.value = value
    }
}
