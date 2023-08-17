//
//  TimeInterval.swift
//  Map
//
//  Created by USER on 31.03.2023.
//

import Foundation

extension TimeInterval {
    
    func convertToHoursMinutesFormat(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d", hours, minutes)
    }
}
