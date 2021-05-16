//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Romeo Flauta on 5/1/21.
//

import Foundation

 struct RemoteFeedItem: Decodable {
     let id: UUID
     let description: String?
     let location: String?
     let image: URL
}
