//
//  ContentView.swift
//  WeatherApp
//
//  Created by Royal K on 2025-02-19.
//

import SwiftUI

struct ContentView: View {
    @State private var cities: [String] = UserDefaults.standard.stringArray(forKey: "SavedCities") ?? ["New York", "London", "Tokyo"]
    @State private var weatherData: [WeatherDetail] = []  // Changed from CityWeather to WeatherDetail
    @State private var isLoading = true
    @State private var newCity = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {

                HStack {
                    TextField("Enter city name", text: $newCity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                        .disabled(isLoading)

                    Button(action: addCity) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title)
                    }
                    .disabled(isLoading || newCity.trim().isEmpty)
                }
                .padding()

                // Weather List
                if isLoading {
                    ProgressView("Fetching Weather...")
                } else if let error = errorMessage {
                    ErrorView(message: error) {
                        Task {
                            await loadWeather()
                        }
                    }
                } else {
                    List {
                        ForEach(weatherData) { weather in
                            NavigationLink(destination: DetailView(cityName: weather.cityName)) {
                                WeatherRowView(weather: weather)
                            }
                        }
                        .onDelete(perform: removeCity)
                    }
                    .refreshable {
                        await loadWeather()
                    }
                    .navigationTitle("Weather App")
                }
            }
        }
        .task {
            await loadWeather()
        }
    }

    private func loadWeather() async {
        guard !cities.isEmpty else {
            weatherData = []
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            weatherData = try await withThrowingTaskGroup(of: WeatherDetail?.self) { group in
                for city in cities {
                    group.addTask {
                        try? await WeatherService.shared.fetchWeather(for: city)
                    }
                }

                var results: [WeatherDetail] = []
                for try await result in group {
                    if let weather = result {
                        results.append(weather)
                    }
                }
                return results.sorted { $0.cityName < $1.cityName }
            }
        } catch {
            errorMessage = "Failed to load weather data: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func addCity() {
        let city = newCity.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !city.isEmpty, !cities.contains(where: { $0.lowercased() == city.lowercased() }) else {
            return
        }

        cities.append(city)
        UserDefaults.standard.set(cities, forKey: "SavedCities")
        newCity = ""

        Task {
            await loadWeather()
        }
    }

    private func removeCity(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
        UserDefaults.standard.set(cities, forKey: "SavedCities")

        // Remove from weatherData as well
        offsets.forEach { index in
            if index < weatherData.count {
                weatherData.remove(at: index)
            }
        }

        Task {
            await loadWeather()
        }
    }
}

// MARK: - Supporting Views
struct WeatherRowView: View {
    let weather: WeatherDetail

    var body: some View {
        HStack {
            Image(systemName: weather.weatherIcon)
                .foregroundColor(.blue)
                .imageScale(.large)

            Text(weather.cityName)
                .font(.headline)

            Spacer()

            Text(weather.temperatureString)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 5)
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button("Try Again", action: retryAction)
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - String Extension
extension String {
    func trim() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    ContentView()
}
