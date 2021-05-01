//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Romeo Flauta on 5/1/21.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
