//
//  Direction.swift
//  Map
//
//  Created by USER on 30.03.2023.
//

import Foundation
import MapKit
import CoreLocation


protocol DirectionProtocol{
    func createDirectionRequest(transportType:  MKDirectionsTransportType, startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, completionHandler: @escaping (Result<([MKRoute]),Error>) -> Void)
    
}
struct Direction: DirectionProtocol{
    
    func createDirectionRequest(transportType:  MKDirectionsTransportType, startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, completionHandler: @escaping (Result<([MKRoute]),Error>) -> Void){ // escaping так как request может занять долгое время и чтобы замыкание не отработала быстрее чем request помечаем его как escaping, такое замыкание продолжит существовать в памяти пока оно не будет выполнено и можно передать его в другой блок кода 
        
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation) // источник откуда начнется маршрут
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = transportType // строим пеший маршрут
        request.requestsAlternateRoutes = true // возможность показывать альтернативые маршруты чтобы в дальнейшем выбрать самый короткий маршрут между двумя точками
            
            
        let direction = MKDirections(request: request) //рассчитываем направление
        direction.calculate { (response, error) in
            
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            guard let response = response else {return}
            
            var alternativeRoutes = [MKRoute]()
            var minRoute = response.routes[0]// если маршрут один то он и будет минимальным если нет проходимся по каждому маршруту через цикл, routes там харанятся все маршруты
            
            for route in response.routes{
                alternativeRoutes.append(route) //сохраняем альтернативные маршрут помимо минимального
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            if let index = alternativeRoutes.firstIndex(of: minRoute){//удаляем из массива минимальный маршрут так как его рисуем отделаьно
                alternativeRoutes.remove(at: index)
                print("MinRouteIndex \(index)")
            }
            alternativeRoutes.insert(minRoute, at: 0)
            
            for route in alternativeRoutes{
                print("Distance exept min \(route.distance)")
            }
           
            completionHandler(.success((alternativeRoutes)))
        }
    }
}
