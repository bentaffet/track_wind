//
//  ContentView.swift
//  track wind
//
//  Created by Benjamin Taffet on 3/25/26.
//

import SwiftUI
import MapKit

enum WindUnit: String, CaseIterable {
    case ms = "m/s"
    case mph = "mph"
    case kmh = "km/h"
    
    func convert(fromKmh value: Double) -> Double {
        switch self {
        case .ms: return value / 3.6
        case .mph: return value * 0.621371
        case .kmh: return value
        }
    }
}

struct ContentView: View {
    
    @State private var times: [String] = []
    @State private var selectedIndex = 0
    @State private var weatherData: WeatherResponse?
    @State private var currentWind: (speed: Double, direction: Double, gust: Double, time: String)?
    @State private var homeSpeed: Double = 0
    @State private var backSpeed: Double = 0
    @State private var homeGustSpeed: Double = 0
    @State private var backGustSpeed: Double = 0
    @State private var recommendation: String = ""
    @State private var homeCategory: String = ""
    @State private var backCategory: String = ""
    @State private var unit: WindUnit = .ms
    
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var homeDir: String = ""
    
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var showMap = false
    @State private var selectedDate: Date = Date()
    @State private var dateTimes: [Date] = []
    @State private var dateToIndex: [Date: Int] = [:]
    

    
    let service = WeatherService()
    
    // MARK: - Fetch weather
    func fetchWeather() {
        guard let lat = Double(latitude), let lon = Double(longitude) else {
            print("❌ Invalid lat/lon")
            return
        }

        service.fetchWeather(lat: lat, lon: lon) { result in
            guard let result = result else { return }

            DispatchQueue.main.async {
                self.weatherData = result

                // Convert all times to Date objects
                let allDates: [Date] = result.hourly.time.compactMap { TimeUtils.toDate($0) }

                // Keep only future times
                let now = Date()
                let futureDates = allDates.filter { $0 > now }

                // If no future times, fallback to all
                let datesToUse = futureDates.isEmpty ? allDates : futureDates
                self.dateTimes = datesToUse

                // Build fast lookup: date -> index
                self.dateToIndex = Dictionary(uniqueKeysWithValues: zip(datesToUse, datesToUse.indices))

                // Set initial selected date
                if let firstDate = datesToUse.first {
                    self.selectedDate = firstDate
                    self.selectedIndex = self.dateToIndex[firstDate] ?? 0
                    updateResult(result: result)
                }

                // Optional: store string times for display elsewhere
                self.times = datesToUse.map { TimeUtils.inputFormatter.string(from: $0) }
            }
        }
    }
    
    // MARK: - Update wind results
    func updateResult(result: WeatherResponse) {
        let windSpeed = result.hourly.wind_speed_10m[selectedIndex]
        let windDirFrom = result.hourly.wind_direction_10m[selectedIndex]
        let windGust = result.hourly.wind_gusts_10m[selectedIndex]
        let time = result.hourly.time[selectedIndex]
        
        let windTo = (windDirFrom + 180).truncatingRemainder(dividingBy: 360)
        guard let homeDirValue = Double(homeDir) else { return }
        
        let homeCalc = WindCalculator.effectiveWind(runDir: homeDirValue, windTo: windTo, windSpeed: windSpeed)
        let backCalc = WindCalculator.effectiveWind(runDir: homeDirValue + 180, windTo: windTo, windSpeed: windSpeed)
        
        let homeGustCalc = WindCalculator.effectiveWind(runDir: homeDirValue, windTo: windTo, windSpeed: windGust)
        let backGustCalc = WindCalculator.effectiveWind(runDir: homeDirValue + 180, windTo: windTo, windSpeed: windGust)
        
        homeSpeed = homeCalc.0
        backSpeed = backCalc.0
        homeGustSpeed = homeGustCalc.0
        backGustSpeed = backGustCalc.0
    
        
        homeCategory = WindCalculator.windCategory(homeSpeed)
        backCategory = WindCalculator.windCategory(backSpeed)
        
        currentWind = (speed: windSpeed, direction: windDirFrom, gust: windGust, time: time)
    }
    
    
    func indexForSelectedDate() -> Int? {
        return dateToIndex[selectedDate]
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.15), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        header
                        
                        // MARK: - Track / Manual / Map Inputs
                        VStack(spacing: 16) {

                            VStack(alignment: .leading, spacing: 6) {
                                TrackMatcher(
                                    latitude: $latitude,
                                    longitude: $longitude,
                                    homeDir: $homeDir
                                )
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Or enter manually")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                VStack(spacing: 10) {
                                    
                                    HStack {
                                        TextField("Latitude", text: $latitude)
                                            .keyboardType(.decimalPad)
                                            .textFieldStyle(.roundedBorder)

                                        TextField("Longitude", text: $longitude)
                                            .keyboardType(.decimalPad)
                                            .textFieldStyle(.roundedBorder)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Button(action: { showMap = true }) {
                                            HStack {
                                                Image(systemName: "map")
                                                Text("Select Location on Map")
                                            }
                                            .padding(8)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.gray.opacity(0.1))
                                            .foregroundColor(.primary)
                                            .cornerRadius(8)
                                        }
                                    }

                                    TextField("Home Straight Direction (°)", text: $homeDir)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        
                        Button(action: { fetchWeather() }) {
                            HStack {
                                Spacer()
                                Text("Update Weather")
                                    .font(.headline)
                                    .bold()
                                Spacer()
                            }
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .controlSize(.regular)

                        
                        if let wind = currentWind {
                            
                            TimePickerCard(
                                dates: dateTimes,
                                selectedDate: $selectedDate
                            )
                            
                            windSummaryCard(
                                speed: unit.convert(fromKmh: wind.speed),
                                direction: wind.direction,
                                gust: unit.convert(fromKmh: wind.gust),
                                unit: unit
                            )
                            
                            RecommendationCard(
                                homeMps: homeSpeed,
                                backMps: backSpeed,
                                homeGustMps: homeGustSpeed,
                                backGustMps: backGustSpeed,
                                homeCategory: homeCategory,
                                backCategory: backCategory,
                                unit: unit
                            )
                            
                            if let weatherData = weatherData, !dateTimes.isEmpty {
                                NavigationLink(
                                    destination: HourlyForecastView(
                                        weatherData: weatherData,
                                        dates: dateTimes,
                                        homeDir: Double(homeDir) ?? 0,
                                        unit: $unit
                                    )
                                ) {
                                    Text("View Hourly Forecast")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                            
                            }
                            
                            TrackCard(
                                homeDir: Double(homeDir) ?? 0,
                                windDirection: currentWind?.direction
                            )
                        }


                        
                        
                        Picker("Units", selection: $unit) {
                            ForEach(WindUnit.allCases, id: \.self) { u in
                                Text(u.rawValue).tag(u)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                }
            }
        }
        .fullScreenCover(isPresented: $showMap) {
            MapPickerView { coordinate in
                self.selectedCoordinate = coordinate
                self.latitude = "\(coordinate.latitude)"
                self.longitude = "\(coordinate.longitude)"
                self.showMap = false
                fetchWeather()
            }
        }
        .onChange(of: selectedDate) {
            if let result = weatherData,
               let index = indexForSelectedDate() {
                selectedIndex = index
                updateResult(result: result)
            }
        }
    }
}

#Preview {
    ContentView()
}
