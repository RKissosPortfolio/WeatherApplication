//
//  WeatherViewModel.swift
//  WeatherApplication
//
//  Created by Ronnie Kissos on 11/1/23.
//

import Foundation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var currentWeather: CurrrentWeatherData?
    @Published var fiveDayForecast: [List] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var weatherData: [List] = []


    private var networkManager: Networking
    var latitude: Double
    var longitude: Double

    init(lat: Double, lon: Double, networkManager: Networking) {
        self.latitude = lat
        self.longitude = lon
        self.networkManager = networkManager
    }

    func fetchCurrentWeather(endpoint:String) async {
        isLoading = true

        do {
            let fetchedResponse: CurrrentWeatherData = try await networkManager.request(url: endpoint, modelType: CurrrentWeatherData.self)
            self.currentWeather = fetchedResponse
                self.isLoading = false
        } catch {
            handle(error: error)
        }
    }

    func fetchFiveDayForecast(endpoint:String) async {
        isLoading = true

        do {
            var response: ForcastWeatherResponse = try await networkManager.request(url: endpoint, modelType: ForcastWeatherResponse.self)
            response = await convertToFahrenheit(response: response)
                self.fiveDayForecast = response.list
                self.isLoading = false
        } catch {
            handle(error: error)
        }
    }

     func generateURL(endpoint: String) -> String {
        return "https://api.openweathermap.org/data/2.5/\(endpoint)?lat=\(latitude)&lon=\(longitude)&appid=fd93c91807a4cccf4a75514701bae768"
    }


    private func handle(error: Error) {
        print("Error occurred: \(error.localizedDescription)")
            self.isLoading = false
        errorMessage = "Error occurred: \(error.localizedDescription)"
    }


    private func convertToFahrenheit(response: ForcastWeatherResponse) async -> ForcastWeatherResponse {
        var modifiedList: [List] = []
        for item in response.list {
            var modifiedMain = item.main
            modifiedMain.temp = kelvinToFahrenheit(modifiedMain.temp)
            modifiedMain.feelsLike = kelvinToFahrenheit(modifiedMain.feelsLike)
            modifiedMain.tempMin = kelvinToFahrenheit(modifiedMain.tempMin)
            modifiedMain.tempMax = kelvinToFahrenheit(modifiedMain.tempMax)
            
            var modifiedItem = item
            modifiedItem.main = modifiedMain
            modifiedList.append(modifiedItem)
        }
        return ForcastWeatherResponse( list: modifiedList)
    }

     func kelvinToFahrenheit(_ kelvin: Double) -> Double {
        return (kelvin * 9/5) - 459.67
    }
}

extension WeatherViewModel {
    func forecastData(for day: Int) -> [List] {
        let start = day * 8
        let end = start + 8
        
        guard start < fiveDayForecast.count, end <= fiveDayForecast.count else {
            return []
        }
        
        return Array(fiveDayForecast[start..<end])
    }
}
