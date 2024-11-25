//
//  SyncEngine.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

import Foundation
import CoreData

class SyncEngine {
    private let persistentContainer: NSPersistentContainer
    private let networkService: NetworkServiceProtocol
    private let backgroundContext: NSManagedObjectContext

    init(persistentContainer: NSPersistentContainer, networkService: NetworkServiceProtocol) {
        self.persistentContainer = persistentContainer
        self.networkService = networkService
        self.backgroundContext = persistentContainer.newBackgroundContext()
    }

    func synchronize<T: Syncable>(entityType: T.Type, completion: @escaping (Result<Void, Error>) -> Void) {
        let entityName = String(describing: entityType)

        pushLocalChanges(entityType: entityType) { result in
            switch result {
            case .success:
                self.pullRemoteChanges(entityType: entityType) { result in
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func pushLocalChanges<T: Syncable>(entityType: T.Type, completion: @escaping (Result<Void, Error>) -> Void) {
        backgroundContext.perform {
            let fetchRequest = T.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "needsSync == YES")

            do {
                let objectsToSync = try self.backgroundContext.fetch(fetchRequest) as! [T]
                let group = DispatchGroup()
                var errors: [Error] = []

                for object in objectsToSync {
                    group.enter()
                    let data = object.toDictionary()

                    self.networkService.sendData(entityName: String(describing: entityType), data: data) { result in
                        switch result {
                        case .success:
                            object.needsSync = false
                        case .failure(let error):
                            errors.append(error)
                        }
                        group.leave()
                    }
                }

                group.notify(queue: .global()) {
                    if errors.isEmpty {
                        do {
                            try self.backgroundContext.save()
                            completion(.success(()))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        completion(.failure(errors.first!))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func pullRemoteChanges<T: Syncable>(entityType: T.Type, completion: @escaping (Result<Void, Error>) -> Void) {
        networkService.fetchData(entityName: String(describing: entityType)) { result in
            switch result {
            case .success(let dataArray):
                self.backgroundContext.perform {
                    for data in dataArray {
                        guard let id = data["id"] as? String else { continue }

                        let fetchRequest = T.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

                        do {
                            let results = try self.backgroundContext.fetch(fetchRequest) as! [T]
                            let object = results.first ?? T(context: self.backgroundContext)
                            let serverModifiedAt = Date.fromISO8601String(data["modifiedAt"] as? String ?? "") ?? Date.distantPast

                            if let localModifiedAt = object.modifiedAt {
                                if serverModifiedAt > localModifiedAt {
                                    object.update(from: data)
                                }
                            } else {
                                object.update(from: data)
                            }
                        } catch {
                            completion(.failure(error))
                            return
                        }
                    }

                    do {
                        try self.backgroundContext.save()
                        completion(.success(()))
                    } catch {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
