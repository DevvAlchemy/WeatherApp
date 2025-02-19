//
//  WeatherDetail.swift
//  WeatherApp
//
//  Created by Royal K on 2025-02-19.
//

import SwiftUI

struct DetailView: View {
    let cityName: String
    @State private var weather: WeatherDetail?
    @State private var forecast: [DailyForecast] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(message: error)
                } else if let weather = weather {
                    WeatherContentView(weather: weather, forecast: forecast)
                }
            }
            .padding()
        }
        .navigationTitle("Weather Details")
        .task {
            await loadWeatherData()
        }
        .refreshable {
            await loadWeatherData()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Fetching weather data...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Error")
                .font(.title)
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task {
                    await loadWeatherData()
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func loadWeatherData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let weatherTask = WeatherService.shared.fetchWeather(for: cityName)
            async let forecastTask = WeatherService.shared.fetchForecast(for: cityName)

            let (weatherData, forecastData) = try await (weatherTask, forecastTask)

            weather = weatherData
            forecast = forecastData
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

struct WeatherContentView: View {
    let weather: WeatherDetail
    let forecast: [DailyForecast]

    var body: some View {
        VStack(spacing: 24) {
            // Current Weather Section
            VStack(spacing: 16) {
                Image(systemName: weather.weatherIcon)
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text(weather.cityName)
                    .font(.largeTitle)
                    .bold()

                Text(weather.temperatureString)
                    .font(.system(size: 70, weight: .medium))
                    .foregroundStyle(.primary)

                Text(weather.condition.capitalized)
                    .font(.title2)
                    .foregroundStyle(.secondary)

                HStack(spacing: 20) {
                    WeatherDataItem(title: "Feels Like", value: String(format: "%.1f°", weather.feelsLike))
                    WeatherDataItem(title: "Humidity", value: "\(weather.humidity)%")
                }
            }

            // Forecast Section
            if !forecast.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("4-Day Forecast")
                        .font(.title2)
                        .bold()

                    ForEach(forecast) { day in
                        HStack {
                            Text(day.date)
                                .frame(width: 100, alignment: .leading)

                            Image(systemName: day.weatherIcon)
                                .foregroundStyle(.blue)

                            Spacer()

                            Text(day.temperatureString)
                                .frame(width: 80, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

struct WeatherDataItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .bold()
        }
    }
}

#Preview {
    NavigationStack {
        DetailView(cityName: "London")
    }
}
