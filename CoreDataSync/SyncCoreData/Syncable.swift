//
//  Syncable.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

import CoreData

protocol Syncable: NSManagedObject {
    var id: String? { get set }
    var modifiedAt: Date? { get set }
    var needsSync: Bool { get set }

    func toDictionary() -> [String: Any]
    func update(from dictionary: [String: Any])
}
