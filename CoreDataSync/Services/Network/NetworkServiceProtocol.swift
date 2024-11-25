//
//  NetworkServiceProtocol.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

import Foundation

protocol NetworkServiceProtocol {
    func sendData(entityName: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void)
    func fetchData(entityName: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void)
}
