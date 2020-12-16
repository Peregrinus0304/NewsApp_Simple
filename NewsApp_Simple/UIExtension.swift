//
//  UIExtension.swift
//  NewsApp_Simple
//
//  Created by Ozzy on 16.12.2020.
//  Copyright © 2020 Taras Motruk. All rights reserved.
//

import Foundation
import UIKit

extension ViewController {
    
    func createUI() {
        
        // MARK: - Initialize UI elements
        
        
        titleLabel.textColor = .systemPink
        titleLabel.font = UIFont(name: "Geeza Pro", size: 28)
        titleLabel.textAlignment = .center
        titleLabel.text = "\(news.country) - \(news.category)"
        navigationBar.topItem?.titleView = titleLabel
        
        // Add Refresh Control to the CollectionView
        if #available(iOS 10.0, *) {
            newsCollectionView.refreshControl = refreshControl
        } else {
            newsCollectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshNewsData(_:)), for: .valueChanged)
        refreshControl.tintColor = .systemPink
        refreshControl.attributedTitle = NSAttributedString(string: "Getting news...", attributes: nil)
        
        // create UIPickerView
        picker = UIPickerView(frame: CGRect(x: 0, y: self.view.bounds.height - 200, width: self.view.bounds.width, height: 200))
        picker.backgroundColor = UIColor(displayP3Red: 191.0/255.0, green: 235.0/255.0, blue: 234.0/255.0, alpha: 1)
        picker.tintColor = .white
        
        view.addSubview(picker)
        
        // create UIToolbar with items
        toolbar = UIToolbar(frame: CGRect(x: 0, y: picker.frame.origin.y-40, width: self.view.frame.size.width, height: 40))
        toolbar.barStyle = .default
        toolbar.tintColor = .systemPink
        view.addSubview(toolbar)
        
        let doneButtonItem = UIBarButtonItem(title: "done", style: .done, target: self, action: #selector(donePressed(sender:)))
        let cancelButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(cancelPressed(sender:)))
        toolbar.setItems([doneButtonItem, cancelButtonItem], animated: true)
        
        
        zeroRectTextField = UITextField(frame: CGRect.zero)
        zeroRectTextField.inputView = picker
        view.addSubview(zeroRectTextField)
        
        
    }
    
}
