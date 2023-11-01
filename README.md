# Weather App

This SwiftUI iOS app offers users intuitive weather forecasts, decoding data from an API and presenting current conditions and daily summaries through a sleek interface, all managed by the WeatherViewModel.

## Project Description 

This project is a SwiftUI-based iOS application designed to provide users with detailed weather forecasts. Utilizing a series of data structures, the app decodes JSON data from a weather API and presents it in an intuitive interface. Features include a current weather card displaying conditions with corresponding icons and daily weather summaries. The core logic and data retrieval are managed by the WeatherViewModel, ensuring accurate and timely updates for users.

## Table of Contents

Introduction
    Overview of the Weather App
    Purpose and Target Audience
Design and Layout
    SwiftUI Overview
    Interface Elements: Cards, Icons, and Views
Data Management
    Introduction to Codable in Swift
    Structs and Data Models:
        City
        Weather
        List
WeatherViewModel
    Role and Responsibilities
    Data Fetching and Processing
    Functions and Methods Overview
Views and Interface
    CurrentWeatherCard: Displaying Live Weather Data
    WeatherDailyView: Summarizing Daily Forecasts
Error Handling and Debugging
    Handling "Index out of range" and Other Common Errors
    Tips for Debugging in SwiftUI
Conclusion and Future Improvements
    Summary of the App's Features
    Potential Additions and Enhancements for Future Versions


# Installation
Software:
    Xcode: The latest version that supports SwiftUI. As of my last update in January 2022, Xcode 13 is the latest, but you should always check for the most recent version.
    macOS: A version that supports the required Xcode version. For Xcode 13, macOS Big Sur 11.3 or later is needed.
Hardware:
    A Mac computer compatible with the required macOS version.
    For testing: An iPhone, iPad, or Mac device that supports the iOS or macOS version your app targets. Alternatively, you can use Xcode's built-in simulator.
APIs and Services:
    A valid API key if the app fetches data from a weather service like OpenWeatherMap, Weather API, etc.
    Ensure you're adhering to the terms of service of the API provider, especially regarding request limits.
Internet Connection:
    A stable internet connection is required for downloading dependencies, accessing the weather API, and installing any necessary updates.

# Framework
SwiftUI 

# Architecture
This application uses MVVM

# Design Patterns
MVVM (Model-View-ViewModel):
    This is evident from the separation between the UI components (like CurrentWeatherCard and WeatherDailyView) and the logic/data components (WeatherViewModel).
    In MVVM, the ViewModel handles the logic and prepares data for the View. The View simply displays the data and informs the ViewModel about user actions. The Model represents the data structures or entities.
Observer Pattern:
    The use of @ObservedObject in SwiftUI is an implementation of the Observer pattern. The View observes changes in the ViewModel. When properties in the ViewModel change (and they are marked with @Published), the View is automatically notified and can update itself.
Decorator Pattern:
    SwiftUI's view modifiers (like .font(), .background(), .cornerRadius(), etc.) can be seen as a form of the Decorator pattern. Each modifier decorates or wraps the original view with additional functionality or styling without modifying its structure.

# Testing
Mocking:
In MockManager.swift, there's a mechanism to mock the data returned from network calls. This is a crucial part of unit testing because it allows you to test your logic without making actual network calls.
    The MockManager class provides mocked data responses (like ValidResponseCurrentWeather.json) to simulate different scenarios.
Unit Testing:
    The WeatherViewModelTests.swift file indicates that unit tests are being written to test the WeatherViewModel.
    Unit tests are used to verify individual parts of the software in isolation (in this case, the ViewModel) to ensure they work as expected.
    Tests are written to check if the data is being parsed correctly
Asynchronous Testing:
    The tests handle asynchronous operations, because network calls are inherently asynchronous. XCTest provides mechanisms like expectation and waitForExpectations to handle these scenarios.
    This ensures that the test waits for async operations to complete before making assertions.
JSON Stubbing:
    The ValidResponseCurrentWeather.json file is a stubbed JSON response. This is used in conjunction with the mocking mechanism to provide predefined responses for certain test cases.
    By using stubbed responses, you can test how the code handles specific data scenarios without relying on a live API.
Assertions:
    In the tests, various assertions (like XCTAssertEqual, XCTAssertNotNil, etc.) are used to verify that the output of the code matches the expected results.
Testing Error Scenarios:
    There are tests to handle error scenarios. Testing how your code responds to errors (like network failures, malformed data, etc.) is a crucial aspect of a robust testing suite.

# Screenshots
In the root folder and a video is included

|List of Planet Screen|DetailScreen|
|---|---|
| | |
