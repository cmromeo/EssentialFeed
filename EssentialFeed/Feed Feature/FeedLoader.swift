//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Romeo Flauta on 4/1/21.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>

    func load(completion: @escaping (Result) -> Void)
}
