//
//  CurrentWeatherResponse.swift
//  WeatherApplication
//
//  Created by Ronnie Kissos on 11/1/23.
//

import Foundation

struct CurrrentWeatherData:Decodable{
    let coord:CoordinatesData
    let weather:[Weather]
    let base:String
    let main:TemperatureData
    let name:String

}

struct CoordinatesData:Decodable{
    let lon:Double
    let lat:Double
}


struct TemperatureData:Decodable{
    let temp:Double
    let pressure:Double
    let humidity:Double
    let temp_min:Double
    let temp_max:Double

}

