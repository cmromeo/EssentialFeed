//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Romeo Flauta on 4/4/21.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    public let session: URLSession
    
    public init(session: URLSession = .shared){
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        //make it fail using wrong url:
//        let url = URL(string: "http://wrong-url.com")!
        session.dataTask(with: url) { data,response,error in
            if let error = error {
                completion(.failure(error))
            }else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            }else{
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
/*
extension URLSession: HTTPClient {
    
    private struct UnexpectedValuesRepresentation: Error {}
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
        //make it fail using wrong url:
//        let url = URL(string: "http://wrong-url.com")!
        dataTask(with: url) { data,response,error in
            if let error = error {
                completion(.failure(error))
            }else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            }else{
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
*/

