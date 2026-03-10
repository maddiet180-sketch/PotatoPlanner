//
//  IntUtils.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/10/26.
//

import Foundation

extension Int {
    private var hms: (h: Int, m: Int, s: Int) {
        guard self >= 0 else { return (0, 0, 0)}
        let h = self / 3600
        let m = ( self % 3600) / 60
        let s = self % 60
        return (h, m, s)
    }

    // "MM:SS" or "HH:MM:SS" (only shows hours if > 0)
    var asHHMMSS: String {
        let (h, m, s) = hms
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }

    // "1h 5m", "2h", "12m", or "—"
    var asHMS: String {
        guard self >= 60 else { return "—" }
        return Self.hmFormatter.string(from: Double(self)) ?? "—"
    }

    var asHours: Int { hms.h }
    var asRemainingMinutes: Int { hms.m }
    
    private static let hmFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute]
        f.unitsStyle = .abbreviated
        f.zeroFormattingBehavior = [.dropAll] // avoids 0h
        return f
    }()
}
