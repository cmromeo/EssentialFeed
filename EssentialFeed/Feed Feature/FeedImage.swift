//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Romeo Flauta on 4/1/21.
//

import Foundation
//Remember: Feed Item should not have any knowledge of the API, no hard coded coding keys
public struct FeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL){
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
