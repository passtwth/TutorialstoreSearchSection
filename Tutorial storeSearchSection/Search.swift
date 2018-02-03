//
//  Search.swift
//  Tutorial storeSearchSection
//
//  Created by HuangMing on 2018/2/2.
//  Copyright © 2018年 passtwth. All rights reserved.
//

import Foundation

typealias SearchComplete = (Bool) -> Void
class Search {
   
    private var dataTask: URLSessionDataTask? = nil
    private(set) var state: State = .notSearchedYet
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult])
    }
    
    enum Category: Int {
        case all = 0
        case music = 1
        case sofeware = 2
        case ebooks = 3
        
        var type: String {
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .ebooks: return "ebook"
            case .sofeware: return "sofeware"
            }
        }
    }
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete ) {
        print("searching...")
        
        if !text.isEmpty {
            dataTask?.cancel()
            state = .loading
            
            let url = iTunesURL(searchText: text, category: category)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
                var success = false
                var newState = State.notSearchedYet
                if let error = error as NSError? ,error.code == -999 {
                        return
                }

                if let httpresponse = response as? HTTPURLResponse, httpresponse.statusCode == 200, let data = data {
                    var searchResults = self.parse(data: data)
                    if searchResults.isEmpty {
                        newState = .noResults
                    } else {
                        searchResults.sort(by: < )
                        newState = .results(searchResults)
                    }
 
                    print("Success")
                    success = true
                }

                DispatchQueue.main.async {
                    
                    self.state = newState
                    completion(success)
                }
                
            })
            dataTask?.resume()
            
            
            
        }
    }
    
    private func iTunesURL(searchText: String, category: Category) -> URL {
        let kind = category.type
        let encoding = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let stringURL = "https://itunes.apple.com/search?" + "term=\(encoding)&limit=200&entity=\(kind)"
        let url = URL(string: stringURL)
        return url!
    }
    
    private func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            
            return result.results
        }
        catch {
            print("JSON Error: \(error)")
            return []
        }
        
    }
}
