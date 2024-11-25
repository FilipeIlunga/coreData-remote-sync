//
//  NoteDetailViewModel.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

import Foundation

import Foundation

class NoteDetailViewModel: ObservableObject {
    @Published var note: NoteModel
    @Published var isEditing: Bool = false
    @Published var errorMessage: String?

    private let noteRepository: NoteRepositoryProtocol

    init(note: NoteModel, noteRepository: NoteRepositoryProtocol) {
        self.note = note
        self.noteRepository = noteRepository
    }

    func saveNote() {
        note.modifiedAt = Date()
        noteRepository.updateNote(note) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isEditing = false
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
