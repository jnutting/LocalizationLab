//
//  LocalizationLabTests.swift
//  LocalizationLabTests
//
//  Created by Jack Nutting on 2023-1-31.
//

import XCTest
@testable import LocalizationLab

final class LocalizationLabTests: XCTestCase {

    func testReadEmbeddedStrings() throws {
        let sut: LocalizedStringsRepository = OnDeviceStringsRepository()

        let publisher = sut.localizedStrings()

        let localizedStrings = try preloadedValueInPublisher(publisher)
        XCTAssertEqual(localizedStrings.count, 2)

        
    }
}
