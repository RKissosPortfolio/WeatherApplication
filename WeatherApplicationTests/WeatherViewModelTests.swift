//
//  WeatherViewModelTests.swift
//  WeatherApplicationTests
//
//  Created by Ronnie Kissos on 11/1/23.
//

import XCTest
@testable import WeatherApplication

final class WeatherViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchCurrentWeather_WhenEveryThingGoesCorrect() async throws {
        let viewModel =  await WeatherViewModel(lat: 33.7489924, lon: -84.3902644,networkManager: MockManager())
        
        await viewModel.fetchCurrentWeather(endpoint: "ValidResponseCurrentWeather")
        XCTAssertNotNil(viewModel)
        
        let currentWeather = await viewModel.currentWeather
        XCTAssertEqual(currentWeather?.name, "Atlanta")
        XCTAssertEqual(currentWeather?.base, "stations")
        let errorMessage = await viewModel.errorMessage
        XCTAssertNil(errorMessage)

    }
    
    func testFetchCurrentWeather_WhenWeExpectError() async throws {
        let viewModel =  await WeatherViewModel(lat: 33.7489924, lon: -84.3902644,networkManager: MockManager())
        await viewModel.fetchCurrentWeather(endpoint: "")
        XCTAssertNotNil(viewModel)
        let currentWeather = await viewModel.currentWeather
        XCTAssertNil(currentWeather)
        let errorMessage = await viewModel.errorMessage
        XCTAssertNotNil(errorMessage)
        
    }
    func testFetchCurrentWeather_WhenWeExpectError_UrlIsWrong() async throws {
        let viewModel =  await WeatherViewModel(lat: 33.7489924, lon: -84.3902644,networkManager: MockManager())
        await viewModel.fetchCurrentWeather(endpoint: "SomeWringURL")
        XCTAssertNotNil(viewModel)
        let currentWeather = await viewModel.currentWeather
        XCTAssertNil(currentWeather)
        let errorMessage = await viewModel.errorMessage
        XCTAssertNotNil(errorMessage)
        
    }
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
