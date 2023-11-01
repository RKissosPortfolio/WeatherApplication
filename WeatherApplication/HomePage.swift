//
//  HomePage.swift
//  WeatherApplication
//
//  Created by Ronnie Kissos on 11/1/23.
//

import SwiftUI

struct HomePage: View {
    
    @StateObject var viewModel: WeatherViewModel = WeatherViewModel(lat: 33.7489924, lon: -84.3902644, networkManager: NetworkManager())
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH"
        return df
    }()
    
    var body: some View {
        
        ZStack {
            getMainContentView()
            loadingView
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
            }
        }
        .frame(width: 393, height: 852)
        .background(backgroundGradient)
        .onAppear(perform: fetchData)
        .refreshable {
            fetchData()
        }
    }

    // MARK: - Subviews
    @ViewBuilder
    func getMainContentView() -> some View{
        
        VStack {
            Spacer().frame(height: 50)
            Spacer()
            
            ScrollView {
                VStack(spacing: 16) {
                    if let currentWeather = viewModel.currentWeather {
                        CurrentWeatherCard(weatherData: currentWeather, viewModel: viewModel)
                    }
                    ForEach(0..<7) { index in
                        WeatherContainerView(weatherData: viewModel.forecastData(for: index), viewModel: viewModel)
                    }
                }
                .padding()
            }
            
            Spacer()
            
            BottomBar()
        
        }
    }
//    private var mainContent: some View

    private var loadingView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .background(Color.black.opacity(0.45))
                    .cornerRadius(8)
            }
        }
    }

    private var forecastListView: some View {
        Group {
            ForEach(0..<5, id: \.self) { i in
                if i % 3 < 3 && i < viewModel.fiveDayForecast.count {
                    let forecast = viewModel.fiveDayForecast[i]
                    Text("\(formattedDate(from: forecast.dtTxt))h")
                        .foregroundColor(.white)
                    Text("\(forecast.main.temp)°")
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func errorView(_ errorMessage: String) -> some View {
        Text("Error: \(errorMessage)")
            .foregroundColor(.red)
            .padding()
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.24, green: 0.51, blue: 0.82), location: 0.00),
                Gradient.Stop(color: Color(red: 0.73, green: 0.85, blue: 1), location: 1.00),
            ],
            startPoint: UnitPoint(x: 0, y: 0),
            endPoint: UnitPoint(x: 1, y: 1)
        )
    }

    // MARK: - Functions

    struct DailyForecastCell: View {
        var forecast: List  // Using the List structure as our daily forecast model

        var body: some View {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 100) // Increased height to accommodate the date
                    .background(Color(red: 1, green: 0.62, blue: 0.37))
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                    .padding(.top, 20)
                HStack {
                    Text(forecast.dtTxt)  // Display the date
                        .font(.body)
                    
                    Spacer()
                    
                    Image(systemName: forecast.weather.first?.icon ?? "cloud")  // Display the weather icon. This is a placeholder for now, as you might need to map the icon string from the API to a corresponding SwiftUI system icon or use custom images.
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Spacer()
                    
                    Text("\(Int(forecast.main.tempMin)) - \(Int(forecast.main.tempMax))°")  // Display the temperature range
                        .font(.body)
                }
                .padding()
            }

        }
    }
    
    func formattedDate(from string: String) -> String {
        if let date = dateFormatter.date(from: string) {
            return dateFormatter.string(from: date)
        }
        return string
    }


    func fetchData() {
        Task {
            await viewModel.fetchCurrentWeather(endpoint: viewModel.generateURL(endpoint: "weather"))
            await viewModel.fetchFiveDayForecast(endpoint:viewModel.generateURL(endpoint: "forecast"))
        }
    }
}

struct CurrentWeatherCard: View {
    var weatherData: CurrrentWeatherData
    var viewModel:WeatherViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Weather")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: iconName(for: weatherData.weather[0].main))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(String(format: "%.1f",viewModel.kelvinToFahrenheit(weatherData.main.temp)))°")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(weatherData.weather[0].description.rawValue.capitalized)
                        .font(.title3)
                }
            }
            
            Text("Feels like: \(String(format: "%.1f", viewModel.kelvinToFahrenheit(weatherData.main.temp)))°")
                .font(.subheadline)
            
            Text("Pressure: \(String(format: "%.1f", weatherData.main.pressure)) m/s")
                .font(.subheadline)
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
    
    func iconName(for condition: MainEnum) -> String {
        // Map your weather conditions to appropriate image names
        switch condition {
        case .clear:
            return "sun.max.fill"
        case .clouds:
            return "cloud.fill"
        }
    }
}

struct WeatherHourlyView: View {
    var weatherData: [List]
    
    func formattedHour(from string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = dateFormatter.date(from: string) {
            dateFormatter.dateFormat = "h a"
            return dateFormatter.string(from: date)
        }
        return string
    }
    
    func iconName(for condition: String) -> String {
        switch condition {
        case "Clear":
            return "sunny"
        case "Clouds":
            return "cloudy"
        case "Rain":
            return "rainy"
        default:
            return "sunny"
        }
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 140) // Increased height to accommodate the date
                .background(Color(red: 1, green: 0.62, blue: 0.37))
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
            
            VStack {
                // Add the date label at the top
                Text(formattedDate(from: weatherData.first?.dtTxt ?? ""))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(weatherData.prefix(8), id: \.dt) { data in
                            VStack(alignment: .center, spacing: 5) {
                                Text("\(formattedHour(from: data.dtTxt))")
                                    .foregroundColor(.white)
                                Image(iconName(for: data.weather[0].main.rawValue))
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                Text("\(String(format: "%0.f°", data.main.temp))")
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 10) // Consistent horizontal padding
                }
            }
        }
    }
}

struct WeatherContainerView: View {
    var weatherData: [List]
    @ObservedObject var viewModel: WeatherViewModel

    // Define a list of colors for the cells
    let cellColors: [Color] = [.blue, .green, .yellow, .orange, .red]

    var body: some View {
        VStack {
            ForEach(0..<5, id: \.self) { day in
                let dailyData = viewModel.forecastData(for: day)
                let minTemp = dailyData.min { $0.main.temp < $1.main.temp }?.main.temp ?? 0
                let maxTemp = dailyData.max { $0.main.temp < $1.main.temp }?.main.temp ?? 0
                
                // Use the refactored method to get the weather condition
                let condition = weatherCondition(for: day)
                
                // Extract the date from the first item of dailyData
                let date = dailyData.first?.dtTxt ?? ""
                
                // Use the cell color based on the day index
                WeatherDailyView(date: date, minTemp: minTemp, maxTemp: maxTemp, cellColor: cellColors[day % cellColors.count], weatherCondition: condition)
            }
        }
    }

    // Refactored method to get the weather condition
    private func weatherCondition(for day: Int) -> MainEnum {
        if day < weatherData.count {
            return weatherData[day].weather.first?.main ?? .clear
        } else {
            // Return a default value if the index is out of range
            return .clear
        }
    }

}


struct WeatherDailyView: View {
    var date: String
    var minTemp: Double
    var maxTemp: Double
    var cellColor: Color
    var weatherCondition: MainEnum
    
    func formattedDate(from string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = dateFormatter.date(from: string) {
            dateFormatter.dateFormat = "EEEE, MMMM d"
            return dateFormatter.string(from: date)
        }
        return string
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(formattedDate(from: date))
                .font(.headline)
            
            HStack {
                // Display the icon here
                Image(systemName: iconName(for: weatherCondition))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)  // Adjust size as necessary

                Text("Min: \(String(format: "%.1f", minTemp))°F")
                    .padding(.leading)
                Spacer()
                Text("Max: \(String(format: "%.1f", maxTemp))°F")
                    .padding(.trailing)
            }
        }
        .padding()
        .background(cellColor.opacity(0.5))
        .cornerRadius(8)
    }

    func iconName(for condition: MainEnum) -> String {
        // Map your weather conditions to appropriate image names
        switch condition {
        case .clear:
            return "sun.max.fill"
        case .clouds:
            return "cloud.fill"
        // Add other cases as necessary
        }
    }
}

struct BottomBar: View {
    var body: some View {
        ZStack {
            Color(red: 0.47, green: 0.52, blue: 0.76)
            
            HStack(spacing: 16) {
                cityView(imageName: "atlanta", cityName: "Atlanta")
                cityView(imageName: "new-york", cityName: "Boston")
                cityView(imageName: "tokyo", cityName: "Tokyo")
                cityView(imageName: "paris", cityName: "Paris")
                cityView(imageName: "london", cityName: "London")
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 120)
    }
    
    func cityView(imageName: String, cityName: String) -> some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50) // Smaller image
            Text(cityName)
                .font(.system(size: 17)) // Smaller font size
                .foregroundColor(.white)
        }
    }
}

extension WeatherViewModel {
    func viewModelForDay(_ day: Int) -> WeatherViewModel {
        let newViewModel = WeatherViewModel(lat: self.latitude, lon: self.longitude, networkManager:  NetworkManager())
        newViewModel.fiveDayForecast = self.forecastData(for: day)
        return newViewModel
    }
}

extension List {
    static var `default`: List {
        return List(dt: 0, main: MainClass(temp: 0.0, feelsLike: 0.0, tempMin: 0.0, tempMax: 0.0, pressure: 0, seaLevel: 0, grndLevel: 0, humidity: 0, tempKf: 0.0), weather: [Weather(id: 0, main: .clear, description: .clearSky, icon: "")], clouds: Clouds(all: 0), wind: Wind(speed: 0.0, deg: 0, gust: 0.0), visibility: 0, pop: 0, sys: Sys(pod: .d), dtTxt: "")
    }
}

func formattedDate(from string: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    if let date = dateFormatter.date(from: string) {
        dateFormatter.dateFormat = "EEEE, MMM d"
        return dateFormatter.string(from: date)
    }
    return string
}
