//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Royal K on 2025-02-19.
//
// Models/WeatherModels.swift
import Foundation

// API Response Models
struct WeatherAPIResponse: Codable {
    let name: String
    let main: MainWeather
    let weather: [WeatherCondition]
}

struct MainWeather: Codable {
    let temp: Double
    let humidity: Int
    let feelsLike: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case humidity
        case feelsLike = "feels_like"
    }
}

struct WeatherCondition: Codable {
    let description: String
    let icon: String
}

// Forecast Response Models
struct ForecastResponse: Codable {
    let list: [ForecastItem]

    struct ForecastItem: Codable {
        let dt: TimeInterval
        let main: MainWeather
        let weather: [WeatherCondition]
    }
}

// UI Models
struct WeatherDetail: Identifiable {
    let id = UUID()
    let cityName: String
    let temperature: Double
    let feelsLike: Double
    let humidity: Int
    let condition: String

    var temperatureString: String {
        String(format: "%.1f°C", temperature)
    }

    var weatherIcon: String {
        switch condition.lowercased() {
        case "clear sky": return "sun.max.fill"
        case "few clouds", "scattered clouds", "broken clouds": return "cloud.sun.fill"
        case "overcast clouds": return "cloud.fill"
        case "shower rain", "rain": return "cloud.rain.fill"
        case "thunderstorm": return "cloud.bolt.rain.fill"
        case "snow": return "snowflake"
        case "mist", "fog", "haze": return "cloud.fog.fill"
        default: return "questionmark.circle.fill"
        }
    }

    static func from(_ apiResponse: WeatherAPIResponse) -> WeatherDetail {
        WeatherDetail(
            cityName: apiResponse.name,
            temperature: apiResponse.main.temp,
            feelsLike: apiResponse.main.feelsLike,
            humidity: apiResponse.main.humidity,
            condition: apiResponse.weather.first?.description ?? "Unknown"
        )
    }
}

struct DailyForecast: Identifiable {
    let id = UUID()
    let date: String
    let temperature: Double
    let condition: String

    var temperatureString: String {
        String(format: "%.1f°C", temperature)
    }

    var weatherIcon: String {
        switch condition.lowercased() {
        case "clear sky": return "sun.max.fill"
        case "few clouds", "scattered clouds", "broken clouds": return "cloud.sun.fill"
        case "overcast clouds": return "cloud.fill"
        case "shower rain", "rain": return "cloud.rain.fill"
        case "thunderstorm": return "cloud.bolt.rain.fill"
        case "snow": return "snowflake"
        case "mist", "fog", "haze": return "cloud.fog.fill"
        default: return "questionmark.circle.fill"
        }
    }
}
