//
//  ViewController.swift
//  NewsApp_Simple
//
//  Created by Ozzy on 23.11.2020.
//  Copyright © 2020 Taras Motruk. All rights reserved.
//

import UIKit
import SafariServices
import SkeletonView

class ViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var shouldAnimatie = true
    var news = News()
    var titleLabel = UILabel()
    var zeroRectTextField = UITextField()
    var picker = UIPickerView()
    var toolbar = UIToolbar()
    let refreshControl = UIRefreshControl()
    var country = ["ae", "ar", "at", "au", "be", "bg", "br", "ca", "ch", "cn", "co", "cu", "cz", "de", "eg", "fr", "gb", "gr", "hk", "hu", "id", "ie", "il", "in", "it", "jp", "kr", "lt", "lv", "ma", "mx", "my", "ng", "nl", "no", "nz", "ph", "pl", "pt", "ro", "rs", "ru", "sa", "se", "sg", "si", "sk", "th", "tr", "tw", "ua", "us", "ve", "za"]
    var category = ["business", "entertainment", "general", "health", "science", "sports", "technology"]
    var selectedCategory = "business"
    var selectedCountry = "us"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // getting data from News API
        news.getData{
            DispatchQueue.main.async {
                self.newsCollectionView.stopSkeletonAnimation()
                self.newsCollectionView.hideSkeleton()
                self.newsCollectionView.reloadData()
            }
        }
        // initialing UI
        createUI()
        
        picker.isHidden = true
        toolbar.isHidden = true
        
        newsCollectionView.delegate = self
        newsCollectionView.dataSource = self
        picker.delegate = self
        picker.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       
        // start loading animation
        if shouldAnimatie {
            self.newsCollectionView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .systemPink, secondaryColor: UIColor(displayP3Red: 191.0/255.0, green: 235.0/255.0, blue: 234.0/255.0, alpha: 1)), animation: nil, transition: .crossDissolve(0.5)) }
    }
    
    // refreshing the CollectionView
    @objc func refreshNewsData(_ sender: Any) {
        
        news.getData{
            DispatchQueue.main.async {
                self.newsCollectionView.reloadData()
            }
        }
        self.refreshControl.endRefreshing()
    }
    
    // go to article page using SFSafariViewController
    func showArticle(_ which: String) {
        shouldAnimatie = false
        if let url = URL(string: which) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    // unhide the PickerView
    @IBAction func chooseParams(_ sender: UIBarButtonItem) {
        picker.isHidden = false
        toolbar.isHidden = false
        picker.becomeFirstResponder()
    }
    
    // get new data with params chosen in PickerView
    @objc func donePressed(sender: UIBarButtonItem) {
        // start animated loading
        self.newsCollectionView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .systemPink, secondaryColor: UIColor(displayP3Red: 191.0/255.0, green: 235.0/255.0, blue: 234.0/255.0, alpha: 1)), animation: nil, transition: .crossDissolve(0.5))
        news.getData{
            DispatchQueue.main.async {
                self.newsCollectionView.stopSkeletonAnimation()
                self.newsCollectionView.hideSkeleton()
                self.newsCollectionView.reloadData()
            }
        }
        titleLabel.text = "\(news.country) - \(news.category)"
        picker.resignFirstResponder()
        picker.isHidden = true
        toolbar.isHidden = true
    }
    
    // hide the PickerView
    @objc func cancelPressed(sender: UIBarButtonItem) {
        picker.isHidden = true
        toolbar.isHidden = true
        picker.resignFirstResponder()
    }
}


// MARK: - UICollectionView protocols

extension ViewController: UICollectionViewDelegate, SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "NewsCell"
    }
    
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
        cell.newsPublishedAtLabel.text = getDate(articles?.publishedAt)
        
        let articleImageURL = URL(string: articles?.urlToImage ?? "https://opengameart.org/sites/default/files/Transparency500.png")!
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
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 45))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 45))
        
        switch component {
            case 0:
                label.text = country[row]
            default:
                label.text = category[row]
        }
        
        label.textColor = .systemPink
        label.font = UIFont(name: "Geeza Pro", size: 28)
        label.textAlignment = .center
        
        view.addSubview(label)
        return view
    }
    
}

// format ISO8601Date string
extension ViewController {
    
    func getDate(_ ISOString:String?)->String {
        var result = "some time ago"
        let ISOformatter = ISO8601DateFormatter()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM"
        
        if let unwrappedString = ISOString {
            let date = ISOformatter.date(from: unwrappedString)
            
            let stringDate = formatter.string(from: date!)
            result = stringDate
        }
        
        return result
    }
}


