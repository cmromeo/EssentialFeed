//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Romeo Flauta on 4/1/21.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
