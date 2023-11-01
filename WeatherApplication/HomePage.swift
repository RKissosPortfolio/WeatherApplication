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
