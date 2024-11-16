//
//  FileManager+Extensions.swift
//  HP Quiz
//
//  Created by Fernando Draghi on 15/11/2024.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return URL(fileURLWithPath: paths.first!)
    }
}
