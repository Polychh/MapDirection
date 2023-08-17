//
//  MapLabels.swift
//  Map
//
//  Created by USER on 31.03.2023.
//

import UIKit

class MapLabels: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    convenience init(textAlignment: NSTextAlignment, fontSize: CGFloat, hidden: Bool){
        self.init(frame: .zero)
        self.isHidden = hidden
        self.textAlignment = textAlignment
        self.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(){
        textColor = .systemGreen
        backgroundColor = .clear
        numberOfLines = 0
        translatesAutoresizingMaskIntoConstraints = false
    }
}

