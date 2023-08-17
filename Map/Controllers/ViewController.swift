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
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let scrollView = MapScrollView(hidden: true)
    let stackViewH = UIStackView(axis: .horizontal, distribution: .fillEqually)
    var buttonScrollView = UIButton()
    var label = UILabel()
    
    let locationManager = CLLocationManager()
    var userLat: CLLocationDegrees?
    var userLon: CLLocationDegrees?
    
    let addAddressButton = MapButtons(nameImage: "addAddress", hidden: false)
    let resetButton = MapButtons(nameImage: "reset", hidden: true)
    let goButton = MapButtons(nameImage: "go", hidden: true)
    let locationButton = MapButtons(nameImage: "location", hidden: false)
    
    var segmentedControl: UISegmentedControl!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation() // срабатывает метод из расширения CLLocationManagerDelegate
        
        mapView.delegate = self
        
        addTarget()
        createSegmentController()
        setConstraints()
        setupLayoutScrollView()
        
        tappedPolyline()
    }

//MARK: - Buttons with targets
    func addTarget(){
        addAddressButton.addTarget(self, action: #selector(addAddressButtonTapped), for: .touchUpInside)
        goButton.addTarget(self, action: #selector(goButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
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
                    goButton.isHidden = false
                    resetButton.isHidden = false
                }
                // show annotation on the map
                mapView.showAnnotations(annotationArray, animated: true)
            }
        }
    }
    
    @objc func goButtonTapped(){
        
        mapView.removeOverlays(mapView.overlays) // удаляем маршруты от маршрута на машине
        
        for index in 0...annotationArray.count - 2 {
            direction.createDirectionRequest(transportType: .automobile, startCoordinate: annotationArray[index].coordinate,
                                             destinationCoordinate: annotationArray[index+1].coordinate)
            { [weak self] result  in
                guard let self = self else {return}
                
                switch result{
                case .success(var aleternativeRoutes):
                    self.drawRoutes(arrayRoutes: aleternativeRoutes, colorMinRoute: Constant.greenColor, colorRoutes: Constant.grayColor)
                    aleternativeRoutes = [] //чтобы в момент переключения видов маршрута в сегмент контроллере удалялись из массива маршруты с предыдущего выбранного типа маршрута
                    self.automobileArray = self.shakeOverlay(array: self.mapView.overlays)
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
        mapView.showAnnotations(annotationArray, animated: true)
    }
    
    @objc func resetButtonTapped(){
        mapView.removeOverlays(mapView.overlays) // удаляем все маршруты
        mapView.removeAnnotations(mapView.annotations) // удаляем все аннотации
        annotationArray = [MKPointAnnotation]()
        buttonsArray = []
        automobileArray = []
        walkingArray = []
        segmentedControl.selectedSegmentIndex = 0 
        stackViewH.removeFullyAllArrangedSubviews()
        goButton.isHidden = true
        resetButton.isHidden = true
        scrollView.isHidden = true
        segmentedControl.isHidden = true
    }
    
    //MARK: - SegmentController
    func createSegmentController(){
        let items = ["By Car","By Foot"]
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentControl(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.isHidden = true
    }
    
    @objc func carButtonSegmentWalking(){
        mapView.removeOverlays(mapView.overlays)

        for index in 0...annotationArray.count - 2 {
            direction.createDirectionRequest(transportType: .walking, startCoordinate: annotationArray[index].coordinate,
                                             destinationCoordinate: annotationArray[index+1].coordinate)
            { [weak self] result  in
                guard let self = self else {return}
                
                switch result{
                case .success(var aleternativeRoutes):
                    self.drawRoutes(arrayRoutes: aleternativeRoutes, colorMinRoute: Constant.grayColor, colorRoutes: Constant.redColor)
                    aleternativeRoutes = []
                    self.walkingArray = self.shakeOverlay(array: self.mapView.overlays)
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
            stackViewH.removeFullyAllArrangedSubviews()
            goButtonTapped()
        case 1:
            stackViewH.removeFullyAllArrangedSubviews()
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
                label = MapLabels(textAlignment: .center, fontSize: 18, hidden: false)
                buttonScrollView = ButtonForScrollView( backgroundColor: .white )
                label.text = self.converTimeDistance(route: route)
                buttonScrollView.addSubview(label)
                
                NSLayoutConstraint.activate([
                    self.label.centerXAnchor.constraint(equalTo: self.buttonScrollView.centerXAnchor),
                    self.label.leadingAnchor.constraint(equalTo: self.buttonScrollView.leadingAnchor, constant: 5),
                    self.label.topAnchor.constraint(equalTo: self.buttonScrollView.topAnchor, constant: 5),
                ])
                stackViewH.addArrangedSubview(self.buttonScrollView)
                buttonScrollView.addTarget(self, action: #selector(scrollViewButtonTapped), for: .touchUpInside)
                buttonsArray.append(buttonScrollView)
                
                Variables.lineColor = colorRoutes
                mapView.addOverlay(route.polyline)
            }
        } else{
            self.alertError(title: "Error", message: "route less than 1")
        }
        redrawOverlay(overlay: arrayRoutes[0].polyline, color: colorMinRoute, mapView: mapView)// для первого маршрута самого короткого меняем цвет
        presentMapAleretOnMainThread(scrollView: self.scrollView,  segmentedControl: self.segmentedControl)
    }
    
    //MARK: - TappedButtonScrollView
    @objc func scrollViewButtonTapped(sender: UIButton){
       var shakeArray = (segmentedControl.selectedSegmentIndex == 0) ? automobileArray : walkingArray // выбираем правильный массив для типа маршрута
        
        for (index,element) in buttonsArray.enumerated(){
            element.tag = index
        }
        
        for _ in buttonsArray{
            for (index, overlay) in shakeArray.enumerated(){
                if sender.tag == index{
                    let selectedRoute = overlay
                    shakeArray.remove(at: index)
                    
                    for overlay in shakeArray{
                        redrawOverlay(overlay: overlay, color: Constant.grayColor, mapView: mapView)
                    }
                    
                    shakeArray.insert(selectedRoute, at: index)
                    redrawOverlay(overlay: selectedRoute, color: Constant.redColor, mapView: mapView)
                    
                    break // чтобы после первого совпаденя индекса с сендер тэг не шла проверка следующих
                }
            }
            break // чтобы при первом нахождение кнопки совпадающей с индексом прерывался цикл а не повторялось столько раз сколько элементов в массиве кнопок
        }
    }
    //MARK: - TappedPolyline
    func tappedPolyline(){
        let mapTap = UITapGestureRecognizer(target: self, action: #selector(choosePoliline(_:)))
        mapView.addGestureRecognizer(mapTap)
    }
    
    @objc func choosePoliline(_ tap: UITapGestureRecognizer) {
        if tap.state == .recognized{
            // Get map coordinate from touch point
            let touchPt = tap.location(in: mapView)
            let coord = mapView.convert(touchPt, toCoordinateFrom: mapView)
            let mappoint = MKMapPoint(coord)
            
            // for every overlay ...
            var overlayArray = mapView.overlays
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
                                            
                        redrawOverlay(overlay: overlay, color: Constant.redColor,mapView: mapView)
                        
                        for overlay in overlayArray{
                            redrawOverlay(overlay: overlay, color: Constant.grayColor,mapView: mapView)
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
            mapView.centerLocation(location)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
//MARK: - Extension: Constrains
extension ViewController {
    
    func setConstraints(){
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0), //right
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0), //left
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        mapView.addSubview(addAddressButton)
        NSLayoutConstraint.activate([
            addAddressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            addAddressButton.widthAnchor.constraint(equalToConstant: 60),
            addAddressButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        mapView.addSubview(locationButton)
        NSLayoutConstraint.activate([
            locationButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            locationButton.widthAnchor.constraint(equalToConstant: 60),
            locationButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        mapView.addSubview(goButton)
        NSLayoutConstraint.activate([
            goButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            goButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -100),
            goButton.widthAnchor.constraint(equalToConstant: 90),
            goButton.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -110),
            resetButton.widthAnchor.constraint(equalToConstant: 60),
            resetButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        mapView.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            segmentedControl.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 45),
            segmentedControl.bottomAnchor.constraint(equalTo: addAddressButton.topAnchor, constant: -15),
            segmentedControl.bottomAnchor.constraint(equalTo: locationButton.topAnchor, constant: -15),
        ])
    }
    
    func setupLayoutScrollView() {
        configureStackView()
        setupScrollView()
    }
    
    func configureStackView() {
        stackViewH.backgroundColor = .clear
        stackViewH.spacing = 10
    }
    
    func setupScrollView() {
        mapView.addSubview(scrollView)
        scrollView.addSubview(stackViewH)
        
        NSLayoutConstraint.activate([
            scrollView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
            scrollView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 60),
            
            stackViewH.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackViewH.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackViewH.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackViewH.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])
    }
}
