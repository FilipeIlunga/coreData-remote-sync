//
//  NoteRepositoryProtocol.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

protocol NoteRepositoryProtocol {
    func fetchNotes(completion: @escaping (Result<[NoteModel], Error>) -> Void)
    func addNote(_ note: NoteModel, completion: @escaping (Result<Void, Error>) -> Void)
    func updateNote(_ note: NoteModel, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteNote(_ note: NoteModel, completion: @escaping (Result<Void, Error>) -> Void)
}
