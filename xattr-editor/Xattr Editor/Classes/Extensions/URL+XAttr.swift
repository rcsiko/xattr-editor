//
//  URL+XAttr.swift
//  Xattr Editor
//
//  Created by Richard Csiko on 2017. 01. 21..
//

import Foundation

fileprivate let XattrResultError: Int32 = -1

extension URL {

    func setAttribute(name: String, value: String) throws {
        guard let data = value.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            throw NSError(domain: String(cString: strerror(errno)), code: Int(errno), userInfo: nil)
        }

        try data.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            let rawPtr = UnsafeRawPointer(u8Ptr)
            if setxattr(self.path, name, rawPtr, data.count, 0, 0) == XattrResultError {
                throw NSError(domain: String(cString: strerror(errno)), code: Int(errno), userInfo: nil)
            }
        }
    }

    func removeAttribute(name: String) throws {
        if removexattr(self.path, name, 0) == XattrResultError {
            throw NSError(domain: String(cString: strerror(errno)), code: Int(errno), userInfo: nil)
        }
    }

    func getAttribute(name: String) throws -> String? {
        let length = getxattr(self.path, name, nil, 0, 0, 0)
        if length == -1 {
            throw NSError(domain: String(cString: strerror(errno)), code: Int(errno), userInfo: nil)
        }

        let bytes = UnsafeMutableRawPointer.allocate(byteCount: length, alignment: 0)
        if getxattr(self.path, name, bytes, length, 0, 0) == -1 {
            throw NSError(domain: String(cString: strerror(errno)), code: Int(errno), userInfo: nil)
        }

        return (String(data: NSData(bytes: bytes, length: length) as Data,
                       encoding: String.Encoding.utf8))
    }

    func attributes() throws -> [String : String?]? {
        let length = listxattr(self.path, nil, 0, 0)
        if length == -1 {
            throw NSError(domain: String(cString: strerror(errno)), code: Int(errno), userInfo: nil)
        }

        let bytes = UnsafeMutablePointer<Int8>.allocate(capacity: length)

        if listxattr(self.path, bytes, length, 0) == Int(XattrResultError) {
            throw NSError(domain: String(cString: strerror(errno)), code: Int(errno), userInfo: nil)
        }

        if var names = NSString(bytes: bytes, length: length,
                                encoding: String.Encoding.utf8.rawValue)?.components(separatedBy: "\0") {
            names.removeLast()
            var attributes: [String : String?] = [:]
            for name in names {
                attributes[name] = try getAttribute(name: name)
            }
            return attributes
        }

        return nil
    }
    
}
