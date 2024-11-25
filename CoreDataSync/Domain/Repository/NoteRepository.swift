//
//  NoteRepository.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//
import CoreData
import Foundation

class NoteRepository: NoteRepositoryProtocol {
    
    private let persistentContainer: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    private let syncEngine: SyncEngine

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.backgroundContext = persistentContainer.newBackgroundContext()
        self.syncEngine = SyncEngine(persistentContainer: persistentContainer, networkService: NetworkService())
        synchronizeAll()
    }
    
    func synchronizeAll() {
        let entitiesToSync: [Syncable.Type] = [Note.self]
        let group = DispatchGroup()
        var errors: [Error] = []
        
        for entity in entitiesToSync {
            group.enter()
            syncEngine.synchronize(entityType: entity) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if errors.isEmpty {
                print("Sincronização concluída com sucesso.")
            } else {
                print("Erros durante a sincronização: \(errors)")
            }
        }
    }
    

    func fetchNotes(completion: @escaping (Result<[NoteModel], Error>) -> Void) {
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Note.modifiedAt, ascending: false)]
            do {
                let notes = try self.backgroundContext.fetch(fetchRequest)
                let models = notes.map { $0.toDomainModel() }
                completion(.success(models))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func addNote(_ note: NoteModel, completion: @escaping (Result<Void, Error>) -> Void) {
        backgroundContext.perform {
            let newNote = Note(context: self.backgroundContext)
            newNote.fromDomainModel(note)
            do {
                try self.backgroundContext.save()
                self.syncEngine.synchronize(entityType: Note.self) { _ in }
                completion(.success(()))
            } catch {
                self.backgroundContext.rollback()
                completion(.failure(error))
            }
        }
    }

    func updateNote(_ note: NoteModel, completion: @escaping (Result<Void, Error>) -> Void) {
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", note.id)
            do {
                if let existingNote = try self.backgroundContext.fetch(fetchRequest).first {
                    existingNote.fromDomainModel(note)
                    try self.backgroundContext.save()
                    self.syncEngine.synchronize(entityType: Note.self) { _ in }
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Nota não encontrada"])))
                }
            } catch {
                self.backgroundContext.rollback()
                completion(.failure(error))
            }
        }
    }

    func deleteNote(_ note: NoteModel, completion: @escaping (Result<Void, Error>) -> Void) {
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", note.id)
            do {
                if let existingNote = try self.backgroundContext.fetch(fetchRequest).first {
                    self.backgroundContext.delete(existingNote)
                    try self.backgroundContext.save()
                    self.syncEngine.synchronize(entityType: Note.self) { _ in }
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Nota não encontrada"])))
                }
            } catch {
                self.backgroundContext.rollback()
                completion(.failure(error))
            }
        }
    }
}
