//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Romeo Flauta on 5/11/21.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
            perform { context in
                completion(Result {
                    try ManagedCache.find(in: context).map {
                        return CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp!)
                    }
                })
            }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        print("FUNC DEleteCachedFeed CoreData")
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)

                try context.save()
            })
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        print("FUNC DEleteCachedFeed CoreData")
        perform { context in
            print("hello perform delete cachefeed")
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                print("FUNC DEleteCachedFeed success call back")
            })
        }
    }
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        print("hello perform")
        context.perform { action(context) }
    }
}
