//
//  DataArchiver.swift
//  LocalizationLab
//
//  Created by Jack Nutting on 2023-2-14.
//

import Foundation

// This type is a wrapper for archiving a data file in the app's Documents directory, and
// at the same time remembering the URL path to that file by storing it in UserDefaults.
//
// Concrete types implementing this only need to specify the strings to be used for a filename
// (which is the same each time in our one and only use so far) but could vary, and for a
// key used to contain the URL referencing the file (which would probably be the same for any
// concrete type).

public protocol DataArchiver {
    // The filename that will be used to create a file to hold the Data
    var cachedStringsFilename: String { get }

    // The key that will be used for remembering the filename
    var cachedStringsUrlKey: String { get }

    // Saves a Data object to a file and remembers the filename. No validation of the
    // Data object is performed here, so make sure that it contains what you expect before
    // calling this.
    func save(_ data: Data) throws

    // Returns the URL for a previously-archived file, if any exists.
    func cachedStringsUrl() -> URL?
}

// Base implementations of the methods described in the protocol. Concrete types should not need
// to implement these themselves.
public extension DataArchiver {
    func save(_ data: Data) throws {
        let fileURL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
            .appendingPathComponent(cachedStringsFilename)

        // In case the data can't be saved for some reason (e.g. an error thrown inside
        // of `data.write`) this ensures that we don't actually have any saved URL, so
        // no one can try to retrieve data (whose value we don't know) from it later.
        //
        // In the current usage with LocalizedStringsArchiver, this means that we would
        // revert to using the app's embedded strings.
        UserDefaults().removeObject(forKey: cachedStringsUrlKey)

        try data.write(to: fileURL)

        UserDefaults().set(fileURL, forKey: cachedStringsUrlKey)
    }

    // Returns the URL for a previously-archived file, if any exists.
    func cachedStringsUrl() -> URL? {
        return UserDefaults().url(forKey: cachedStringsUrlKey)
    }
}
