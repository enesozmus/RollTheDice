//
//  FileManager-DocumentsDirectory.swift
//  RollTheDice
//
//  Created by enesozmus on 14.04.2024.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
