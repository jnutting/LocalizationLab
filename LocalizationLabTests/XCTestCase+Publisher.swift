//
//  XCTestCase+Publisher.swift
//  LocalizationLabTests
//
//  Created by Jack Nutting on 2023-2-2.
//

import Combine
import XCTest

extension XCTestCase {
    // Copied from John Sundell
    // https://www.swiftbysundell.com/articles/unit-testing-combine-based-swift-code/
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")
        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)

                case .finished:
                    break
                }
                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )
        waitForExpectations(timeout: timeout)
        cancellable.cancel()
        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )
        return try unwrappedResult.get()
    }

    // Use this variant when you know that the Publisher already contains a value
    // that you want to read synchronously, such as if it's a Subject
    func preloadedValueInPublisher<T: Publisher>(
        _ publisher: T,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        var result: Result<T.Output, Error>?
        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)

                case .finished:
                    break
                }
            },
            receiveValue: { value in
                result = .success(value)
            }
        )
        cancellable.cancel()
        let unwrappedResult = try XCTUnwrap(
            result,
            "No preloaded value in publisher",
            file: file,
            line: line
        )
        return try unwrappedResult.get()
    }
}
