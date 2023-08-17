//
//  ButtonForScrollView.swift
//  Map
//
//  Created by USER on 19.04.2023.
//

import UIKit

class ButtonForScrollView: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    convenience init(backgroundColor: UIColor){ //Convenience initialiser
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
    }
    
    private func configure() {
        layer.cornerRadius   = 10
        setTitleColor(.green, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
