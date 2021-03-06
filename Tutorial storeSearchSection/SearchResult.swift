//
//  SearchResult.swift
//  Tutorial storeSearchSection
//
//  Created by HuangMing on 2018/1/2.
//  Copyright © 2018年 Fruit. All rights reserved.
//

import Foundation

class ResultArray: Codable {
    var resultCount = 0
    var results = [SearchResult]()
    
}
class SearchResult: Codable, CustomStringConvertible {
    
    var kind: String? = ""
    var artistName = ""
    var trackName: String? = ""
    
    var trackPrice: Double? = 0.0
    var currency = ""
    
    var imageSmall = ""
    var imageLarge = ""
    
    var trackViewUrl: String?
    var collectionViewUrl: String?
    var collectionName: String?
    var collectionPrice: Double?
    var itemPrice: Double?
    var itemGenre: String?
    var bookGenre: [String]?
    
    
    
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case kind, artistName, currency
        case trackName, trackPrice, trackViewUrl
        case collectionName, collectionPrice, collectionViewUrl
        
    }
    
    var name: String {
        return trackName ?? collectionName ?? ""
    }
    
    var storeURL: String {
        return trackViewUrl ?? collectionViewUrl ?? ""
    }
    
    var price: Double {
        return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }
    
    var grene: String {
        if let genre = itemGenre {
            return genre
        } else if let genres = bookGenre {
            return genres.joined(separator: ", ")
        }
        return ""
    }
    var type: String {
        let kind = self.kind ?? "audiobook"
        switch kind {
        case "album": return NSLocalizedString("Album", comment: "Localized kind: Album")
        case "audiobook": return "Audio Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return NSLocalizedString("Song", comment: "Localized kind: Song")
        case "tv-episode": return "TV Episode"
        default: break
        }
        
        return "Unknown"
    }
    
    var description: String {
        return "Kind: \(kind ?? ""), Name: \(name), artistName: \(artistName)"
    }
    
    static func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }

    static func > (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.name.localizedStandardCompare(rhs.name) == .orderedDescending
    }
}
