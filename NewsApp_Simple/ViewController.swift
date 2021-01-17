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
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var canBecome = false
    override var canBecomeFirstResponder: Bool {
        return canBecome
    }
    
    override var inputView: UIView? {
        return picker
    }
    
    override var inputAccessoryView: UIView? {
        return toolbar
    }
    
    //MARK: - Properties
    
    var shouldAnimatie = true
    var news = News()
    var titleLabel = UILabel()
    var zeroRectTextField = UITextField()
    let refreshControl = UIRefreshControl()
    let countryDict: [String: String] = ["ae":"United Arab Emirates","ar":"Argentina", "at":"Austria", "au":"Australia", "be":"Belgium", "bg":"Bulgaria", "br":"Brazil", "ca":"Canada", "ch":"Switzerland", "cn":"China", "co":"Colombia", "cu":"Cuba", "cz":"Czech Republic", "de":"Germany", "eg":"Egypt", "fr":"France", "gb":"United Kingdom", "gr":"Greece", "hk":"Hong Kong", "hu":"Hungary", "id":"Indonesia", "ie":"Ireland", "il":"Israel", "in":"India", "it":"Italy", "jp":"Japan", "kr":"South Korea", "lt":"Lithuania", "lv":"Latvia", "ma":"Morocco", "mx":"Mexico", "my":"Malaysia", "ng":"Nigeria", "nl":"Netherlands", "no":"Norway", "nz":"New Zealand", "ph":"Philippines", "pl":"Poland", "pt":"Portugal", "ro":"Romania", "rs":"Serbia", "ru":"rashka", "sa":"Saudi Arabia", "se":"Sweden", "sg":"Singapore", "si":"Slovenia", "sk":"Slovakia", "th":"Thailand", "tr":"Turkey", "tw":"Taiwan", "ua":"Ukraine", "us":"USA", "ve":"Venezuela", "za":"South Africa"]
    let country = ["ae", "ar", "at", "au", "be", "bg", "br", "ca", "ch", "cn", "co", "cu", "cz", "de", "eg", "fr", "gb", "gr", "hk", "hu", "id", "ie", "il", "in", "it", "jp", "kr", "lt", "lv", "ma", "mx", "my", "ng", "nl", "no", "nz", "ph", "pl", "pt", "ro", "rs", "ru", "sa", "se", "sg", "si", "sk", "th", "tr", "tw", "ua", "us", "ve", "za"]
    var category = ["business", "entertainment", "general", "health", "science", "sports", "technology"]
    
    //MARK: - Lifecycle
    
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
        becomeFirstResponder()
        reloadInputViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // start loading animation
        if shouldAnimatie {
            self.newsCollectionView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .systemPink, secondaryColor: UIColor(displayP3Red: 191.0/255.0, green: 235.0/255.0, blue: 234.0/255.0, alpha: 1)), animation: nil, transition: .crossDissolve(0.5)) }
        
    }
    
}

//MARK: - FilePrivate extension

fileprivate extension ViewController {
    
    func createUI() {
        
        // MARK: - Initialize UI elements
        
        titleLabel.textColor = .systemPink
        titleLabel.font = UIFont(name: "AmericanTypewriter", size: 40)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.text = "\(countryDict[news.country]!) - \(news.category)"
        titleLabel.minimumScaleFactor = 10/UIFont.labelFontSize
        titleLabel.adjustsFontSizeToFitWidth = true
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
        
        let doneButtonItem = UIBarButtonItem(title: "done", style: .done, target: self, action: #selector(donePressed(sender:)))
        let cancelButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(cancelPressed(sender:)))
        toolbar.setItems([doneButtonItem, cancelButtonItem], animated: true)
        zeroRectTextField = UITextField(frame: CGRect.zero)
        view.addSubview(zeroRectTextField)
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
    
    // refreshing the CollectionView
    @objc func refreshNewsData(_ sender: Any) {
        news.getData{
            DispatchQueue.main.async {
                self.newsCollectionView.reloadData()
            }
        }
        self.refreshControl.endRefreshing()
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
        titleLabel.text = "\(countryDict[news.country] ?? "" ) - \(news.category)"
        canBecome = false
        resignFirstResponder()
    }
    
    // hide the PickerView
    @objc func cancelPressed(sender: UIBarButtonItem) {
        canBecome = false
        resignFirstResponder()
    }
    
    // unhide the PickerView
    @IBAction func chooseParams(_ sender: UIBarButtonItem) {
        canBecome = true
        becomeFirstResponder()
    }
    
}

// MARK: - Extension UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate, SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "NewsCell"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return news.result?.articles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath) as! NewsCollectionViewCell
        cell.layer.cornerRadius = 25
        
        let articles = news.result?.articles[indexPath.row]
        
        cell.newsTitleLabel.text = articles?.title
        cell.newsAuthorLabel.text = articles?.author
        cell.newsDescriptionTextView.text = articles?.description
        cell.newsPublishedAtLabel.text = getDate(articles?.publishedAt)
        
        let articleImageURL = URL(string: articles?.urlToImage ?? "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.islandpacket.com%2F&psig=AOvVaw1uUxV67BUqInuSqRChYv64&ust=1608243550759000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCKjP16fE0-0CFQAAAAAdAAAAABAJ")!
        if let data = try? Data(contentsOf: articleImageURL) {
            cell.newsImageView.image = UIImage(data: data)
        } else {
//            cell.newsImageView.image = UIImage(data: data)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let articles = news.result?.articles[indexPath.row]
        
        if let articleURL = articles?.url {
            self.showArticle(articleURL)
        }
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
                label.text = countryDict[country[row]]
            default:
                label.text = category[row]
        }
        
        label.textColor = .systemPink
        label.font = UIFont(name: "AmericanTypewriter", size: 28)
        label.textAlignment = .center
        label.minimumScaleFactor = 10/UIFont.labelFontSize
        label.adjustsFontSizeToFitWidth = true
        view.addSubview(label)
        return view
    }
    
}

//MARK: - Extension format date

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
