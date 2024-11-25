//
//  NoteEditViewModel.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

import Foundation

class NoteEditViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var errorMessage: String?

    private let noteRepository: NoteRepositoryProtocol
    let onComplete: () -> Void

    init(noteRepository: NoteRepositoryProtocol, onComplete: @escaping () -> Void) {
        self.noteRepository = noteRepository
        self.onComplete = onComplete
    }

    func saveNote() {
        let newNote = NoteModel(
            id: UUID().uuidString,
            content: content,
            modifiedAt: Date()
        )
        noteRepository.addNote(newNote) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.onComplete()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
