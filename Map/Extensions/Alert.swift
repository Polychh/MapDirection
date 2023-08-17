//
//  Alert.swift
//  Map
//
//  Created by USER on 22.03.2023.
//

import UIKit

extension UIViewController{
    
    func alertAddAddress(title: String, placeholder: String, completionHandler: @escaping (String) -> Void){ // escaping чтобы использовать completionHandler за пределами области видимости функции то есть в замыкании для ОК кнопки
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        //Add TextField
        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
        }
        
        //Add Buttons Ok and Cancel
        alertController.addAction(UIAlertAction(title: "Ok", style: .default) { (action) in
            
            let tfText = alertController.textFields?.first
            guard let text = tfText?.text else {return}
            completionHandler(text)
            
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        //Present alertController
        present(alertController, animated: true, completion: nil)
    }
    
    func alertError(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Ok", style: .default)
        
        alertController.addAction(alertOk)
        
        present(alertController, animated: true, completion: nil)
    }
}
