//
//  NoteModel.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//
import Foundation

struct NoteModel: Identifiable {
    let id: String
    var content: String
    var modifiedAt: Date
}
