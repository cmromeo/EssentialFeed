//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Romeo Flauta on 4/1/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error) //temporarily Error as we do not know yet future error types and we want to avoid too many upfront decisions
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
