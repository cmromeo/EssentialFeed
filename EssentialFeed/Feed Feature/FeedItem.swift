//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Romeo Flauta on 4/1/21.
//

import Foundation
//Remember: Feed Item should not have any knowledge of the API, no hard coded coding keys
public struct FeedItem: Equatable {
    public let id: String //UUID string
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: String, description: String?, location: String?, imageURL: URL){
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
