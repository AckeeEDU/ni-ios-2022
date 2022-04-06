//
//  UnitTests.swift
//  UnitTests
//
//  Created by Lukáš Hromadník on 06.04.2022.
//

import XCTest
@testable import Tests

final class MockAPIService: APIServicing {
    var fetchResult: Result<WeatherResult, Error>!
    func fetch(completion: @escaping (Result<WeatherResult, Error>) -> Void) {
        completion(fetchResult)
    }
}

class ContentViewModelTests: XCTestCase {
    private var viewModel: ContentViewModel!
    private var api: MockAPIService!

    override func setUp() {
        super.setUp()

        api = MockAPIService()
        viewModel = ContentViewModel(api: api)
    }

    func testEmptyText() throws {
        viewModel.text = ""

        viewModel.validate()

        let errors = try XCTUnwrap(viewModel.errors)
        XCTAssertFalse(errors.isEmpty)
        XCTAssertEqual(errors.count, 2)
    }

    func testAtLeast3Chars() throws {
        viewModel.text = "ab"

        viewModel.validate()

        let errors = try XCTUnwrap(viewModel.errors)
        XCTAssertFalse(errors.isEmpty)
        XCTAssertEqual(errors.count, 1)
    }

    func testAtMost8Chars() throws {
        viewModel.text = "abcdefghijk"

        viewModel.validate()

        let errors = try XCTUnwrap(viewModel.errors)
        XCTAssertFalse(errors.isEmpty)
        XCTAssertEqual(errors.count, 1)
    }

    func testNoNumbers() throws {
        viewModel.text = "abc123"

        viewModel.validate()

        let errors = try XCTUnwrap(viewModel.errors)
        XCTAssertFalse(errors.isEmpty)
        XCTAssertEqual(errors.count, 1)
    }

    func testValidUsername() throws {
        viewModel.text = "abcdef"

        viewModel.validate()

        let errors = try XCTUnwrap(viewModel.errors)
        XCTAssertTrue(errors.isEmpty)
    }

    struct MyError: Error { }

    func testFetch() {
        viewModel.weather = nil
        api.fetchResult = .success(
            WeatherResult(
                title: "London",
                consolidatedWeather: [
                    .init(weatherStateName: "Heavy Rain", applicableDate: "2022-12-01")
                ]
            )
        )
//        api.fetchResult = .failure(MyError())

        let exp = expectation(description: "Fetch completed")
        viewModel.fetch {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        XCTAssertNotNil(viewModel.weather)
    }
}
