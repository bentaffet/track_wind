//
//  TimePickerCard.swift
//  track wind
//
//  Created by Benjamin Taffet on 3/25/26.
//

import SwiftUI

struct TimePickerCard: View {
    let dates: [Date]                 // All future hourly dates
    @Binding var selectedDate: Date

    // Precompute day → hours mapping once
    private let dayToHours: [Date: [Date]]
    private let days: [Date]

    @State private var selectedDayIndex = 0
    @State private var selectedHourIndex = 0

    // MARK: - Init
    init(dates: [Date], selectedDate: Binding<Date>) {
        self.dates = dates
        self._selectedDate = selectedDate

        // Group dates by day
        let mapping = Dictionary(grouping: dates, by: { Calendar.current.startOfDay(for: $0) })
        self.dayToHours = mapping
        self.days = mapping.keys.sorted()
    }

    // Current selected day & hours for that day
    private var selectedDay: Date { days[safe: selectedDayIndex] ?? Date() }
    private var hoursForSelectedDay: [Date] { dayToHours[selectedDay] ?? [] }
    private var selectedHour: Date { hoursForSelectedDay[safe: selectedHourIndex] ?? Date() }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Select Time").font(.headline)

            
            HStack(spacing: 0) {
                // Day Picker
                
                VStack(spacing: 0) {
                    
                    Text("Date").font(Font.caption.bold())
                    
                    Picker("", selection: $selectedDayIndex) {
                        ForEach(0..<days.count, id: \.self) { i in
                            Text(TimeUtils.dayFormatter.string(from: days[i])).tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .clipped()
                    .onChange(of: selectedDayIndex) {
                        selectedHourIndex = 0
                        selectedDate = selectedHour
                    }
                }
                
                VStack(spacing: 0) {
                    
                    Text("Hour").font(Font.caption.bold())
                    
                    // Hour Picker
                    Picker("", selection: $selectedHourIndex) {
                        ForEach(0..<hoursForSelectedDay.count, id: \.self) { i in
                            Text(TimeUtils.hourFormatter.string(from: hoursForSelectedDay[i])).tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .clipped()
                    .onChange(of: selectedHourIndex) { _ in
                        selectedDate = selectedHour
                    }
                    
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .onAppear {
            // Set initial selection to match current selectedDate
            if let dayIndex = days.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) }) {
                selectedDayIndex = dayIndex
            }
            if let hourIndex = hoursForSelectedDay.firstIndex(where: { $0 == selectedDate }) {
                selectedHourIndex = hourIndex
            }
        }
    }
}

// Safe array subscript to prevent out-of-bounds crashes
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
