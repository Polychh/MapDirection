//
//  MainMapView.swift
//  Map
//
//  Created by USER on 30.08.2023.
//

import UIKit
import MapKit

class MainMapView: UIView {

    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    lazy var scrollView = MapScrollView(hidden: true)
    lazy var stackViewH = UIStackView(axis: .horizontal, distribution: .fillEqually)
    
    lazy var  addAddressButton = MapButtons(nameImage: "addAddress", hidden: false)
    lazy var  resetButton = MapButtons(nameImage: "reset", hidden: true)
    lazy var  goButton = MapButtons(nameImage: "go", hidden: true)
    lazy var  locationButton = MapButtons(nameImage: "location", hidden: false)
    
    lazy var segmentedControl: UISegmentedControl = {
        var segmentedControl = UISegmentedControl()
        let items = ["By Car","By Foot"]
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.isHidden = true
        return segmentedControl
    }()
    
    var buttonScrollView = UIButton()
    var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConstraints()
        setupLayoutScrollView()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setConstraints(){
        addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0), //right
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0), //left
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
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
