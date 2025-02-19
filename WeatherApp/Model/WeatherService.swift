//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Royal K on 2025-02-19.
//

import Foundation

class WeatherService {
    static let shared = WeatherService()
    private let apiKey = "62875b845da7de8ba8269643d4504a5a" // 🔥 Replace with your OpenWeather API key
    private let baseURL = "https://api.openweathermap.org/data/2.5"

    // Fetch current weather
    private init() {}

        func fetchWeather(for city: String) async throws -> WeatherDetail {
            let urlString = "\(baseURL)/weather?q=\(city)&units=metric&appid=\(apiKey)"
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            let apiResponse = try JSONDecoder().decode(WeatherAPIResponse.self, from: data)
            return WeatherDetail.from(apiResponse)
        }

        func fetchForecast(for city: String) async throws -> [DailyForecast] {
            let urlString = "\(baseURL)/forecast?q=\(city)&units=metric&appid=\(apiKey)"
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ForecastResponse.self, from: data)

            // Group forecast data by date
            let groupedData = Dictionary(grouping: response.list) { item -> String in
                let date = Date(timeIntervalSince1970: item.dt)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: date)
            }

            return groupedData.keys.sorted().prefix(4).compactMap { date in
                guard let forecasts = groupedData[date] else { return nil }

                let avgTemp = forecasts.map { $0.main.temp }.reduce(0, +) / Double(forecasts.count)
                let condition = forecasts.first?.weather.first?.description ?? "Unknown"

                return DailyForecast(
                    date: date,
                    temperature: avgTemp,
                    condition: condition
                )
            }
        }
    }
