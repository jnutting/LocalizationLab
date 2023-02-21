//
//  Utilities.swift
//  LocalizationLab
//
//  Created by Jack Nutting on 2023-2-8.
//

import Foundation

// The URL given as a parameter is assumed to be read from such a file, not from the
// network, and must therefore be a "file" URL.
func modelFromJson<T: Decodable>(_ url: URL) throws -> T {
    assert(url.isFileURL, "Only file URLs are accepted here")
    let data = try Data(contentsOf: url)
    return try modelFromJson(data)
}

func modelFromJson<T: Decodable>(_ data: Data) throws -> T {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(T.self, from: data)
}

