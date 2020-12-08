//
//  ViewController.swift
//  NewsApp_Simple
//
//  Created by Ozzy on 23.11.2020.
//  Copyright © 2020 Taras Motruk. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
    
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var newsCollectionView: UICollectionView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var news = News()
    var zeroRectTextField = UITextField()
    var picker = UIPickerView()
    var toolbar = UIToolbar()
    private let refreshControl = UIRefreshControl()
    var country = ["ae", "ar", "at", "au", "be", "bg", "br", "ca", "ch", "cn", "co", "cu", "cz", "de", "eg", "fr", "gb", "gr", "hk", "hu", "id", "ie", "il", "in", "it", "jp", "kr", "lt", "lv", "ma", "mx", "my", "ng", "nl", "no", "nz", "ph", "pl", "pt", "ro", "rs", "ru", "sa", "se", "sg", "si", "sk", "th", "tr", "tw", "ua", "us", "ve", "za"]
    var category = ["business", "entertainment", "general", "health", "science", "sports", "technology"]
    var selectedCategory = "business"
    var selectedCountry = "us"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // getting data from the model
        news.getData{
            DispatchQueue.main.async {
                self.newsCollectionView.reloadData()
            }
        }
        
        // MARK: - Initialize UI elements
        
        navigationBar.topItem!.title = "\(news.country) - \(news.category)"
        
        // Add Refresh Control to the CollectionView
        if #available(iOS 10.0, *) {
            newsCollectionView.refreshControl = refreshControl
        } else {
            newsCollectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
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
        
        
        picker.isHidden = true
        toolbar.isHidden = true
        
        newsCollectionView.delegate = self
        newsCollectionView.dataSource = self
        picker.delegate = self
        picker.dataSource = self
    }
   
    @objc private func refreshWeatherData(_ sender: Any) {
      news.getData{
            DispatchQueue.main.async {
                self.newsCollectionView.reloadData()
            }
        }
        self.refreshControl.endRefreshing()
    }
    
    func showArticle(_ which: String) {
        if let url = URL(string: which) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    @IBAction func chooseParams(_ sender: UIBarButtonItem) {
        picker.isHidden = false
        toolbar.isHidden = false
        picker.becomeFirstResponder()
    }
    
    @objc func donePressed(sender: UIBarButtonItem) {
        
        news.getData{
            DispatchQueue.main.async {
                self.newsCollectionView.reloadData()
            }
        }
        navigationBar.topItem!.title = "\(news.country) - \(news.category)"
        picker.resignFirstResponder()
        picker.isHidden = true
        toolbar.isHidden = true
    }
    
    @objc func cancelPressed(sender: UIBarButtonItem) {
        picker.isHidden = true
        toolbar.isHidden = true
        picker.resignFirstResponder()
    }
} // the end of the class

// MARK: - UICollectionView protocols
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return news.result?.articles.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath) as! NewsCollectionViewCell
        cell.layer.cornerRadius = 25
        let articles = news.result?.articles[indexPath.row]
        
        cell.newsTitleLabel.text = articles?.title
        cell.newsAuthorLabel.text = articles?.author
        cell.newsDescriptionTextView.text = articles?.description
        cell.newsPublishedAtLabel.text = articles?.publishedAt
        
        let articleImageURL = URL(string: articles?.urlToImage ?? "https://e3.365dm.com/20/11/768x432/skynews-brexit-breaking-news_5177180.jpg?20201123152327")!
        if let data = try? Data(contentsOf: articleImageURL) {
            cell.newsImageView.image = UIImage(data: data)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let articles = news.result?.articles[indexPath.row]
        
        let articleURL = articles?.url
        self.showArticle(articleURL!)
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
                news.country = country[row]
            case 1:
                news.category = category[row]
            default:
                return
        }
    }
}
