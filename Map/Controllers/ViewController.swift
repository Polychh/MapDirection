//
//  ViewController.swift
//  Map
//
//  Created by USER on 22.03.2023.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    var mainMapView = MainMapView()
    
    let locationManager = CLLocationManager()
    var userLat: CLLocationDegrees?
    var userLon: CLLocationDegrees?
    
    var placemark: PlacemarkProtocol
    var direction: DirectionProtocol
    
    init(placemark: PlacemarkProtocol, direction: DirectionProtocol ){
        self.placemark = placemark
        self.direction = direction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var annotationArray = [MKPointAnnotation]()
    var buttonsArray = [UIButton]()
    
    var automobileArray = [MKOverlay]()
    var walkingArray = [MKOverlay]()
    
    override func loadView() {
        view = mainMapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation() // срабатывает метод из расширения CLLocationManagerDelegate
        
        mainMapView.mapView.delegate = self
        
        addTarget()

        tappedPolyline()
    }

//MARK: - Buttons with targets
    func addTarget(){
        mainMapView.addAddressButton.addTarget(self, action: #selector(addAddressButtonTapped), for: .touchUpInside)
        mainMapView.goButton.addTarget(self, action: #selector(goButtonTapped), for: .touchUpInside)
        mainMapView.resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        mainMapView.locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        mainMapView.segmentedControl.addTarget(self, action: #selector(segmentControl(_:)), for: .valueChanged)
    }
    
    @objc func addAddressButtonTapped(){
        alertAddAddress(title: "Add", placeholder: "Write Location") { [self] (text) in
            placemark.setPlacemarket(addressPlace: text) {  result  in
                
                switch result{
                case .success(let annotation):
                    annotationArray.append(annotation)
                case .failure(let error):
                    print(error)
                    alertError(title: "Mistake", message: "Server is not available")
                }
                
                if annotationArray.count > 1 {
                    mainMapView.goButton.isHidden = false
                    mainMapView.resetButton.isHidden = false
                }
                // show annotation on the map
                mainMapView.mapView.showAnnotations(annotationArray, animated: true)
            }
        }
    }
    
    @objc func goButtonTapped(){
        
        mainMapView.mapView.removeOverlays(mainMapView.mapView.overlays) // удаляем маршруты от маршрута на машине
        
        for index in 0...annotationArray.count - 2 {
            direction.createDirectionRequest(transportType: .automobile, startCoordinate: annotationArray[index].coordinate,
                                             destinationCoordinate: annotationArray[index+1].coordinate)
            { [weak self] result  in
                guard let self = self else {return}
                
                switch result{
                case .success(var aleternativeRoutes):
                    self.drawRoutes(arrayRoutes: aleternativeRoutes, colorMinRoute: Constant.greenColor, colorRoutes: Constant.grayColor)
                    aleternativeRoutes = [] //чтобы в момент переключения видов маршрута в сегмент контроллере удалялись из массива маршруты с предыдущего выбранного типа маршрута
                    self.automobileArray = self.shakeOverlay(array: self.mainMapView.mapView.overlays)
                case .failure(let error):
                    print(error)
                    self.alertError(title: "Error", message: "Can not calculate direction")
                }
            }
        }
    }
    
    @objc func locationButtonTapped(){
        locationManager.requestLocation()
        guard let lat = userLat else {return}
        guard let lon = userLon else {return}
        placemark.userCurentLocationCoordinate(lat: lat, lon: lon) { annotation in
            self.annotationArray.append(annotation)
        }
        mainMapView.mapView.showAnnotations(annotationArray, animated: true)
    }
    
    @objc func resetButtonTapped(){
        mainMapView.mapView.removeOverlays(mainMapView.mapView.overlays) // удаляем все маршруты
        mainMapView.mapView.removeAnnotations(mainMapView.mapView.annotations) // удаляем все аннотации
        annotationArray = [MKPointAnnotation]()
        buttonsArray = []
        automobileArray = []
        walkingArray = []
        mainMapView.segmentedControl.selectedSegmentIndex = 0
        mainMapView.stackViewH.removeFullyAllArrangedSubviews()
        mainMapView.goButton.isHidden = true
        mainMapView.resetButton.isHidden = true
        mainMapView.scrollView.isHidden = true
        mainMapView.segmentedControl.isHidden = true
    }
    
    //MARK: - SegmentController
    
    @objc func carButtonSegmentWalking(){
        mainMapView.mapView.removeOverlays(mainMapView.mapView.overlays)

        for index in 0...annotationArray.count - 2 {
            direction.createDirectionRequest(transportType: .walking, startCoordinate: annotationArray[index].coordinate,
                                             destinationCoordinate: annotationArray[index+1].coordinate)
            { [weak self] result  in
                guard let self = self else {return}
                
                switch result{
                case .success(var aleternativeRoutes):
                    self.drawRoutes(arrayRoutes: aleternativeRoutes, colorMinRoute: Constant.greenColor, colorRoutes: Constant.grayColor)
                    aleternativeRoutes = []
                    self.walkingArray = self.shakeOverlay(array: self.mainMapView.mapView.overlays)
                case .failure(let error):
                    print(error)
                    self.alertError(title: "Error", message: "Can not calculate direction")
                }
            }
        }
    }
    
    @objc func segmentControl(_ segmentedControl: UISegmentedControl) {
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            mainMapView.stackViewH.removeFullyAllArrangedSubviews()
            goButtonTapped()
        case 1:
            mainMapView.stackViewH.removeFullyAllArrangedSubviews()
            carButtonSegmentWalking()
        default:
            print("default")
        }
    }
    
    //MARK: - DrawRoutes
    func drawRoutes(arrayRoutes: [MKRoute], colorMinRoute: UIColor, colorRoutes: UIColor){
        buttonsArray = [] // чтобы индексация в массиве кнопок каждый раз заново проставлялась и можно было сопоставлять с массивом оверлеев
        if arrayRoutes.count >= 1{
            for route in arrayRoutes{
                // рисуем для всех маршрутов включая первый
                print("route resulte: \(route.polyline)")
                mainMapView.label = MapLabels(textAlignment: .center, fontSize: 18, hidden: false)
                mainMapView.buttonScrollView = ButtonForScrollView( backgroundColor: .white )
                mainMapView.label.text = self.converTimeDistance(route: route)
                mainMapView.buttonScrollView.addSubview(mainMapView.label)
                
                NSLayoutConstraint.activate([
                    self.mainMapView.label.centerXAnchor.constraint(equalTo: self.mainMapView.buttonScrollView.centerXAnchor),
                    self.mainMapView.label.leadingAnchor.constraint(equalTo: self.mainMapView.buttonScrollView.leadingAnchor, constant: 5),
                    self.mainMapView.label.topAnchor.constraint(equalTo: self.mainMapView.buttonScrollView.topAnchor, constant: 5),
                ])
                mainMapView.stackViewH.addArrangedSubview(self.mainMapView.buttonScrollView)
                mainMapView.buttonScrollView.addTarget(self, action: #selector(scrollViewButtonTapped), for: .touchUpInside)
                buttonsArray.append(mainMapView.buttonScrollView)
                
                Variables.lineColor = colorRoutes
                mainMapView.mapView.addOverlay(route.polyline)
            }
        } else{
            self.alertError(title: "Error", message: "route less than 1")
        }
        redrawOverlay(overlay: arrayRoutes[0].polyline, color: colorMinRoute, mapView: mainMapView.mapView)// для первого маршрута самого короткого меняем цвет
        presentMapAleretOnMainThread(scrollView: self.mainMapView.scrollView,  segmentedControl: self.mainMapView.segmentedControl)
    }
    
    //MARK: - TappedButtonScrollView
    @objc func scrollViewButtonTapped(sender: UIButton){
        var shakeArray = (mainMapView.segmentedControl.selectedSegmentIndex == 0) ? automobileArray : walkingArray // выбираем правильный массив для типа маршрута
        
        for (index,element) in buttonsArray.enumerated(){
            element.tag = index
        }
        
        for _ in buttonsArray{
            for (index, overlay) in shakeArray.enumerated(){
                if sender.tag == index{
                    let selectedRoute = overlay
                    shakeArray.remove(at: index)
                    
                    for overlay in shakeArray{
                        redrawOverlay(overlay: overlay, color: Constant.grayColor, mapView: mainMapView.mapView)
                    }
                    
                    shakeArray.insert(selectedRoute, at: index)
                    redrawOverlay(overlay: selectedRoute, color: Constant.blueColor, mapView: mainMapView.mapView)
                    
                    break // чтобы после первого совпаденя индекса с сендер тэг не шла проверка следующих
                }
            }
            break // чтобы при первом нахождение кнопки совпадающей с индексом прерывался цикл а не повторялось столько раз сколько элементов в массиве кнопок
        }
    }
    //MARK: - TappedPolyline
    func tappedPolyline(){
        let mapTap = UITapGestureRecognizer(target: self, action: #selector(choosePoliline(_:)))
        mainMapView.mapView.addGestureRecognizer(mapTap)
    }
    
    @objc func choosePoliline(_ tap: UITapGestureRecognizer) {
        if tap.state == .recognized{
            // Get map coordinate from touch point
            let touchPt = tap.location(in: mainMapView.mapView)
            let coord = mainMapView.mapView.convert(touchPt, toCoordinateFrom: mainMapView.mapView)
            let mappoint = MKMapPoint(coord)
            
            // for every overlay ...
            var overlayArray = mainMapView.mapView.overlays
            overlayArray.reverse()

            for  overlay in overlayArray {
                if overlay is MKPolyline {
                    let renderer = MKPolylineRenderer(overlay: overlay)
                    let tapPoint = renderer.point(for: mappoint)
                    var selectedRoute: MKOverlay
                    if renderer.path.contains(tapPoint) {
                        selectedRoute = overlay
                        if let index = overlayArray.firstIndex(where: {$0.isEqual(selectedRoute)}){//удаляем из массива выбранный маршрут
                            overlayArray.remove(at: index)
                        }
                                            
                        redrawOverlay(overlay: overlay, color: Constant.redColor,mapView: mainMapView.mapView)
                        
                        for overlay in overlayArray{
                            redrawOverlay(overlay: overlay, color: Constant.grayColor,mapView: mainMapView.mapView)
                        }
                        overlayArray.reverse()
                        overlayArray.insert(selectedRoute, at: 0)

                        break // If you have overlapping overlays then you'll need an array of overlays which the touch is in, so remove this line.
                    }
                }
            }
        }
    }
}
//MARK: - Extension: MKMapViewDelegate

extension ViewController: MKMapViewDelegate{ // для корректной отрисовки машрута
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = Variables.lineColor
        renderer.lineWidth = 8
        return renderer
    } 
}
//MARK: - Extension: MKMapView - centerLocation
extension MKMapView {
    func centerLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 10000){
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
//MARK: - Extension: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{ // to take last item in array [CLLocation] более точная последняя
            locationManager.stopUpdatingLocation()
            userLat = location.coordinate.latitude
            userLon = location.coordinate.longitude
            mainMapView.mapView.centerLocation(location)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
