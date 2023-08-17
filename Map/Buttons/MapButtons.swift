//
//  MapButtons.swift
//  Map
//
//  Created by USER on 29.03.2023.
//

import UIKit

class MapButtons: UIButton {
    
    override init(frame: CGRect) { //потому что мы наследуемся от класса UIButton
        super.init(frame: frame)
    }

     init(nameImage: String, hidden: Bool){ // Designed initialiser 
        super.init(frame: .zero)// в назначенном иницилизаторе можно изменять унаследованные свойства только после super.init(), если есть свои собственные свойсва у назначенного иницилизатора то вызывать до super.init()
        setImage(UIImage(named: nameImage), for: .normal)
        isHidden = hidden
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

