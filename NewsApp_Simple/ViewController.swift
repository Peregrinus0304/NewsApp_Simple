//
//  ViewController.swift
//  NewsApp_Simple
//
//  Created by Ozzy on 23.11.2020.
//  Copyright © 2020 Taras Motruk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var newsCollectionView: UICollectionView!
    
    
    var news: News!
    var picker: UIPickerView!
    var country = ["US", "Poland", "Ukraine"]
    var category = ["Economy", "Sport", "Military"]
    var selectedCategory = ""
    var selectedCountry = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
         // create UIPickerView
               let picker = UIPickerView(frame: CGRect(x: 0, y: self.view.bounds.height - 200, width: self.view.bounds.width, height: 200))
               super.view.addSubview(picker)
               
               
               
               
               // create UIToolbar
               let toolbar = UIToolbar(frame: CGRect(x: 0, y: picker.frame.origin.y-40, width: self.view.frame.size.width, height: 40))
               toolbar.barStyle = .black
               toolbar.tintColor = .red
               view.addSubview(toolbar)
               let doneButtonItem = UIBarButtonItem(title: "done", style: .done, target: self, action: #selector(donePressed(sender:)))
               
               let cancelButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(cancelPressed(sender:)))
               
               toolbar.setItems([doneButtonItem, cancelButtonItem], animated: true)
    
        newsCollectionView.delegate = self
        newsCollectionView.dataSource = self
        picker.delegate = self
        picker.dataSource = self
    }
    
    
    
    @IBAction func chooseParams(_ sender: UIBarButtonItem) {
    }
    
    
    
    @objc func pickerValueChanged(sender: UIPickerView) {
        
    }
    
    @objc func donePressed(sender: UIBarButtonItem) {
       print(selectedCountry)
        print(selectedCategory)
    }
    
    @objc func cancelPressed(sender: UIBarButtonItem) {
    }
    
    
    
    
    
} // the end of the class

// MARK: - UICollectionView protocols
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath) as! NewsCollectionViewCell
        
        return cell
    }
}




// MARK: - UIPickerView protocols
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch component {
            case 0:
              return country.count
            case 1:
            return category.count
            default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch component {
            case 0:
            return country[row]
            case 1:
             return category[row]
            default:
            return "ERROR: Can`t execute titleForRow func"
       
    }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
            case 0:
                selectedCountry = country[row]
            case 1:
            selectedCategory = category[row]
            default:
            return
        }
        
       
    }
    
}
