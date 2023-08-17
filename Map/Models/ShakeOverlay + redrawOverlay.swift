//
//  DrawRoutes.swift
//  Map
//
//  Created by USER on 16.08.2023.
//

import Foundation
import MapKit
import CoreLocation


struct DrawRoutes {
    
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
       }
       return array
   }
    
    func redrawOverlay(overlay: MKOverlay, color: UIColor, mapView:MKMapView){
       mapView.removeOverlay(overlay)
       Variables.lineColor = color
       mapView.addOverlay(overlay,level: .aboveLabels)
   }
}
