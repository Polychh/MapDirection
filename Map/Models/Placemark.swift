//
//  Model.swift
//  Map
//
//  Created by USER on 29.03.2023.
//

import UIKit
import MapKit
import CoreLocation

protocol PlacemarkProtocol{
    func setPlacemarket(addressPlace: String, completionHandler: @escaping (Result<MKPointAnnotation, Error>) -> Void)
    func userCurentLocationCoordinate(lat: CLLocationDegrees, lon: CLLocationDegrees,completionHandler: @escaping (MKPointAnnotation) -> Void)
}

struct Placemark: PlacemarkProtocol{

    func setPlacemarket(addressPlace: String, completionHandler: @escaping (Result<MKPointAnnotation, Error>) -> Void){
        
        let geocader = CLGeocoder()
        geocader.geocodeAddressString(addressPlace) { (placemarks, error) in
            
            if let error = error{
                print(error)
                completionHandler(.failure(error))
                return
            }
            guard let placemarks = placemarks else {return}
            
            let placemark = placemarks.first // берем первый из массива и считаем что первый самый точный адрес
            let annotation = MKPointAnnotation()
            annotation.title = "\(addressPlace)" // подписываем точку на карте с нужным адресом
            guard let placemerkLocation = placemark?.location else {return}
            annotation.coordinate = placemerkLocation.coordinate // задаем координаты аннотации такие же как и координаты placemark
            
            completionHandler(.success(annotation))
        }
    }
    
    func userCurentLocationCoordinate(lat: CLLocationDegrees, lon: CLLocationDegrees,completionHandler: @escaping (MKPointAnnotation) -> Void){
        let userCurrentLocation = MKPointAnnotation()
        userCurrentLocation.title = "User Current Location"
        userCurrentLocation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        completionHandler(userCurrentLocation)
    }
}


