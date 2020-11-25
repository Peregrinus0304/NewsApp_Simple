//
//  NewsModel.swift
//  NewsApp_Simple
//
//  Created by Ozzy on 24.11.2020.
//  Copyright © 2020 Taras Motruk. All rights reserved.
//

import Foundation

class News: Codable {

  
    
    
    
    //MARK: - Struct
    
    private struct Result: Codable {
        var status: String
        var totalResults: Int
        var articles: [Articles]
    }
    
    private struct Articles: Codable {
        var source: Source
        var author: String?
        var title: String
        var description: String
        var url: String
        var urlToImage: String
        var publishedAt: String
        var content: String
    }
    
    private struct Source: Codable {
        var id: String?
        var name: String
    }
    
  var country = ""
  var category = ""
   private var result: Result
    
    
    //MARK: - Reference
    
    
    let apiKey = "9d22dc6191124789b5721d6f482ec503"
    //MARK: - Parsing
    
    func getData(completed: @escaping () -> ()){
       
        // Create URL
        let urlString = "http://newsapi.org/v2/top-headlines?country=\(self.country)&category=\(self.category)&apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("ERROR: incorrect URL \(urlString)")
            return
        }
    
        let session = URLSession.shared
        
        // Get data with data task
        
        let dataTask = session.dataTask(with: url) { (data, responce, error) in
            if let error = error{
                print("ERROR!\(error.localizedDescription)")
            }
            do {
                 let result = try JSONDecoder().decode(Result.self, from: data!)
                self.result = result
                print("\(result)")
                
            } catch {
                print("ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        dataTask.resume()
    }
}
