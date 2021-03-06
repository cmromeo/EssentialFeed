//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Romeo Flauta on 4/1/21.
//

import Foundation
import XCTest
import EssentialFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL(){
        //Arrange
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url:url)
        
        //Act
        sut.load(){_ in}
        
        //Assert
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice(){
        //Arrange
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url:url)
        
        //Act
        sut.load(){_ in}
        sut.load(){_ in}
        
        //Assert
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError(){
        
        //arrange
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(RemoteFeedLoader.Error
                                                .connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        
        //arrange
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach{ index, code in
            
            expect(sut, toCompleteWith: failure(RemoteFeedLoader.Error.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    //200 response but invalid json
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON(){
        
        //arrange
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(RemoteFeedLoader.Error.invalidData), when: {
            let invalidJSON = Data("Invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
//    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList(){
//
//        //arrange
//        let (sut, client) = makeSUT()
//
//        expect(sut, toCompleteWith: LoadFeedResult.success([]), when:{
//            let emptyListJSON = makeItemsJSON([])
//            client.complete(withStatusCode: 200, data: emptyListJSON)
//        })
//    }
    //happy path
//    func test_load_deliversItemsOn200HTTPResponseWithJSONList(){
//
//        //arrange
//        let (sut, client) = makeSUT()
//
//        let item1 = makeItem(
//            id: UUID(),
//            imageURL: URL(string: "https://a-url.com")!
//        )
//
//        let item2 = makeItem(
//            id: UUID(),
//            description: "a description",
//            location: "a location",
//            imageURL: URL(string: "https://another-url.com")!
//        )
//
//        let items = [item1.model, item2.model]
//
//        expect(sut, toCompleteWith: LoadFeedResult.success(items), when: {
//            let json = makeItemsJSON([item1.json, item2.json])
//            client.complete(withStatusCode: 200, data: json)
//        })
//    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated(){
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load{capturedResults.append($0)}
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }

    
    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result{
        return .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        var json:[String: Any] = [
            "id": id.uuidString,
            "image": imageURL.absoluteString
        ]
        if let description = description {
            json["description"] = description
        }
        if let location = location {
            json["location"] = location
        }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String:Any]]) -> Data {
        let json = ["items":items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line){
        
        let exp = expectation(description: "Wait for load completion")
        sut.load{ receivedResult in
            switch(receivedResult, expectedResult){
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 2.0)
    }
    
    //spies must only capture values
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map{$0.url}
        }
      
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
           //5 did not call completion here
            messages.append((url:url, completion: completion))
        }
        
        func complete(with error: Error, at index:Int = 0){
            messages[index].completion(.failure(error))
        }
        func complete(withStatusCode code: Int, data: Data, at index:Int = 0){
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
}

