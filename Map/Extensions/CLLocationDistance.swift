//
//  CLLocationDistance.swift
//  Map
//
//  Created by USER on 31.03.2023.
//

import Foundation
import CoreLocation

extension CLLocationDistance {
    
    func convertToKilometrsFormat(distance: TimeInterval) -> String {
        let distance = Int(distance)
        let kilometrs = distance / 1000
        let meters = distance % 1000
        return String(format: "%01dkm %01dm", kilometrs, meters)
    }
}
