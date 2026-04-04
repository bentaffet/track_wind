//
//  TimeUtils.swift
//  track wind
//
//  Created by Benjamin Taffet on 3/25/26.
//

import Foundation

struct TimeUtils {
    static let inputFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()

    static let outputFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        df.timeZone = .current
        return df
    }()

    static let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d"  // e.g., Mar 29
        return df
    }()

    static let hourFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"  // e.g., 08:00
        return df
    }()

    static func toDate(_ isoString: String) -> Date? {
        inputFormatter.date(from: isoString)
    }
    
    static let shortFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "ha"       // "3PM"
        f.timeZone = TimeZone(identifier: "America/New_York") // ✅ force Eastern
        return f
    }()

    static func shortTime(_ timeString: String) -> String {
        guard let date = toDate(timeString) else {
            return timeString
        }
        return shortFormatter.string(from: date)
    }
}

