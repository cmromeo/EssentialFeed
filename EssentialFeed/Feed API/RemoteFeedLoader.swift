//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Romeo Flauta on 4/1/21.
//

import Foundation

//API Module
public final class RemoteFeedLoader: FeedLoader{
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity //for client errors
        case invalidData
    }
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient){
        self.url = url
        self.client = client
    }
    //2
    public func load(completion: @escaping (Result) -> Void){
        
        client.get(from: url){[weak self] result in
            guard self != nil else {return}
            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, from: response))
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
}




