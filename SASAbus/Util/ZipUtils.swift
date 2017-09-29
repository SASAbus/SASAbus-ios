//
//  ZipUtils.swift
//  SASAbus
//
//  Created by Alex Lardschneider on 27/09/2017.
//  Copyright © 2017 SASA AG. All rights reserved.
//

import Foundation

import SSZipArchive

class ZipUtils {
    
    static func unzipFile(from: URL, to: URL) throws {
        let success = try SSZipArchive.unzipFileAtPath(
            from.path, toDestination: to.path, overwrite: false, password: nil, delegate: nil
        )
        
        if success {
            Log.warning("Unzipped file \(from) to \(to)")
        } else {
            Log.error("Could not unzip files: No error thrown")
        }
    }
}
