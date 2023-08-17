//
//  MapSegmentControl.swift
//  Map
//
//  Created by USER on 16.08.2023.
//

import Foundation


class MapSegmentControl: UISegmentControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    convenience init( hidden: Bool){
        self.init(frame: .zero)
        self.isHidden = hidden
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(){
        backgroundColor = .red
        alwaysBounceHorizontal = true
        showsHorizontalScrollIndicator = true
//        intrinsicContentSize.width
        translatesAutoresizingMaskIntoConstraints = false
    }
}
