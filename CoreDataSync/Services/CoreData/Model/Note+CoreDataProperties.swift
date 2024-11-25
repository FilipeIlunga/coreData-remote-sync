//
//  Note+CoreDataProperties.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var modifiedAt: Date?
    @NSManaged public var content: String?
    @NSManaged public var id: String?
    @NSManaged public var needsSync: Bool

}

extension Note : Identifiable {

}

extension Note: Syncable {
    
    func toDictionary() -> [String : Any] {
        return [
            "id": id ?? "",
            "content": content ?? "",
            "modifiedAt": modifiedAt?.iso8601String() ?? ""
        ]
    }

    func update(from dictionary: [String : Any]) {
        id = dictionary["id"] as? String
        content = dictionary["content"] as? String
        if let dateString = dictionary["modifiedAt"] as? String {
            modifiedAt = Date.fromISO8601String(dateString)
        }
    }
    
    func toDomainModel() -> NoteModel {
        return NoteModel(
            id: self.id ?? "",
            content: self.content ?? "",
            modifiedAt: self.modifiedAt ?? Date()
        )
    }

    func fromDomainModel(_ model: NoteModel) {
        self.id = model.id
        self.content = model.content
        self.modifiedAt = model.modifiedAt
        self.needsSync = true
    }
}

