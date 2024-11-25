//
//  NoteListViewModel.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

import Foundation
import Combine

class NoteListViewModel: ObservableObject {
    @Published var notes: [NoteModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    let noteRepository: NoteRepositoryProtocol

    init(noteRepository: NoteRepositoryProtocol) {
        self.noteRepository = noteRepository

        fetchNotes()
    }

    func fetchNotes() {
        isLoading = true
        noteRepository.fetchNotes { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let notes):
                    self?.notes = notes
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func deleteNotes(at offsets: IndexSet) {
        offsets.forEach { index in
            let note = notes[index]
            noteRepository.deleteNote(note) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.notes.remove(at: index)
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}


