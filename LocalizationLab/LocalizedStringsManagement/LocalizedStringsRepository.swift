//
//  LocalizedStringsRepository.swift
//  LocalizationLab
//
//  Created by Jack Nutting on 2023-1-31.
//

import Combine
import Foundation

// The basic type needed for string lookups. A Dictionary serves this purpose for now.
typealias LocalizedStrings = [String: String]

// Errors associated with accessing and decoding localized string data
enum LocalizedStringsRepositoryError: Error {
    case resourceNotFound(Error)
    case httpError(Int)
    case invalidHttpResponse
}

// Describes a type that is able to retrieve localized string data and output them through a publisher
protocol LocalizedStringsRepository {
    init(url: URL)
    func localizedStrings() -> AnyPublisher<LocalizedStrings, LocalizedStringsRepositoryError>
}

