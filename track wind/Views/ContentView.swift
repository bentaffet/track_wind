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
    
    @State private var tracks: [Track] = [
        Track(name: "Wesleyan University", latitude: 41.555, longitude: -72.656, direction: 261),
        Track(name: "Amherst College", latitude: 42.368514, longitude: -72.524181, direction: 120),
        Track(name: "Trinity College", latitude: 41.748, longitude: -72.690, direction: 357),
        Track(name: "Connecticut College", latitude: 41.381476, longitude: -72.101230, direction: 166),
        Track(name: "Coast Guard Academy", latitude: 41.375648, longitude: -72.097870, direction: 170)
    ]
    

    
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

                let allDates: [Date] = result.hourly.time.compactMap { TimeUtils.toDate($0) }

                let now = Date()
                let indexedTimes = Array(result.hourly.time.enumerated())

                let futureIndexedTimes = indexedTimes.filter {
                    guard let date = TimeUtils.toDate($0.element) else { return false }
                    return date > now
                }

                let timesToUse = futureIndexedTimes.isEmpty ? indexedTimes : futureIndexedTimes

                self.dateTimes = timesToUse.compactMap { TimeUtils.toDate($0.element) }

                self.dateToIndex = Dictionary(uniqueKeysWithValues: zip(
                    self.dateTimes,
                    timesToUse.map { $0.offset }
                ))

                

                if let existingIndex = dateToIndex[selectedDate] {
                    selectedIndex = existingIndex
                    updateResult(result: result)
                } else if let firstDate = dateTimes.first,
                          let index = dateToIndex[firstDate] {
                    selectedDate = firstDate
                    selectedIndex = index
                    updateResult(result: result)
                }

                self.times = self.dateTimes.map { TimeUtils.inputFormatter.string(from: $0) }
            }
        }
    }
    
    // MARK: - Update wind results
    func updateResult(result: WeatherResponse) {
        // windSpeed is in km/h
        let windSpeed = result.hourly.wind_speed_10m[selectedIndex]
        print("windSpeed")
        print(windSpeed)
        let windDirFrom = result.hourly.wind_direction_10m[selectedIndex]
        let windGust = result.hourly.wind_gusts_10m[selectedIndex]
        let time = result.hourly.time[selectedIndex]
        
        let windTo = (windDirFrom + 180).truncatingRemainder(dividingBy: 360)
        guard let homeDirValue = Double(homeDir) else { return }
        
        // homeCalc uses km/h
        let homeCalc = WindCalculator.effectiveWind(runDir: homeDirValue, windTo: windTo, windSpeed: windSpeed)
        let backCalc = WindCalculator.effectiveWind(runDir: homeDirValue + 180, windTo: windTo, windSpeed: windSpeed)

        let homeGustCalc = WindCalculator.effectiveWind(runDir: homeDirValue, windTo: windTo, windSpeed: windGust)
        let backGustCalc = WindCalculator.effectiveWind(runDir: homeDirValue + 180, windTo: windTo, windSpeed: windGust)
        
        homeSpeed = homeCalc.0
        backSpeed = backCalc.0

        homeGustSpeed = homeGustCalc.0
        backGustSpeed = backGustCalc.0
    
        
        homeCategory = WindCalculator.windCategory(
            effectKmh: homeSpeed,
            windDir: windDirFrom,
            homeDir: homeDirValue
        )

        backCategory = WindCalculator.windCategory(
            effectKmh: backSpeed,
            windDir: windDirFrom,
            homeDir: homeDirValue + 180
        )
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
                        
                        
                        HeaderView(tracks: $tracks, showMap: $showMap)
                    
                        EnterInfoCard(
                            latitude: $latitude,
                            longitude: $longitude,
                            homeDir: $homeDir,
                            showMap: $showMap,
                            tracks: $tracks
                        )
                        
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
                            
                            RecommendationCard2(
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


                        
   
                        
                    }
                    .padding()
                }
            }
            VStack {
                Picker("Units", selection: $unit) {
                    ForEach(WindUnit.allCases, id: \.self) { u in
                        Text(u.rawValue).tag(u)
                    }
                }
                .pickerStyle(.segmented)
                
                .frame(maxWidth: 300)
                
                
            }
            
        }
        .fullScreenCover(isPresented: $showMap) {
            MapPickerView(
                initialCoordinate: {
                    if let lat = Double(latitude),
                       let lon = Double(longitude) {
                        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    } else {
                        return nil // fallback to current location or default
                    }
                }(),
                onSelect: { coord in
                    latitude = "\(coord.latitude)"
                    longitude = "\(coord.longitude)"
                }
            )
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
