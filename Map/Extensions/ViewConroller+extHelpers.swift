//
//  ViewConroller+extDispatch.swift
//  Map
//
//  Created by USER on 05.05.2023.
//

import UIKit
import MapKit
import CoreLocation

extension UIViewController{
    func presentMapAleretOnMainThread(scrollView: MapScrollView, segmentedControl: UISegmentedControl){
        DispatchQueue.main.async {
            scrollView.isHidden = false
            segmentedControl.isHidden = false
        }
    }

    func converTimeDistance(route: MKRoute) -> String {
        let result = route.distance.convertToKilometrsFormat(distance: route.distance) + "\n" + route.expectedTravelTime.convertToHoursMinutesFormat(interval: route.expectedTravelTime)
        return result
    }
    
    func shakeOverlay (array: [MKOverlay]) -> [MKOverlay]{
       var array = array
       for overlay in array{
           print("aaray overlay: \(overlay)")
       }
       let route = array.last
       if let minRoute = route{
           if let index = array.firstIndex(where: {$0.isEqual(minRoute)}){
               array.remove(at: index)
           }
           array.insert(minRoute, at: 0)
       } else {
           alertError(title: "error", message: "error")
       }
       return array
   }

    func redrawOverlay(overlay: MKOverlay, color: UIColor, mapView:MKMapView){
       mapView.removeOverlay(overlay)
       Variables.lineColor = color
       mapView.addOverlay(overlay,level: .aboveLabels)
   }
}

    
