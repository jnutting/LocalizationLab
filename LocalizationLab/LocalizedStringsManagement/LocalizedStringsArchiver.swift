//
//  LocalizedStringsArchiver.swift
//  LocalizationLab
//
//  Created by Jack Nutting on 2023-2-8.
//

import Foundation

// A specific type of DataArchiver that is meant to store a JSON file.
struct LocalizedStringsArchiver: DataArchiver {
    internal let cachedStringsFilename = "StringsCache.json"
    internal let cachedStringsUrlKey = "cachedStringsUrl"
}
