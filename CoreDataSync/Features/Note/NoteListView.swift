//
//  NoteListView.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

import SwiftUI

struct NoteListView: View {
    @StateObject private var viewModel: NoteListViewModel

    init(viewModel: NoteListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @State private var isAddingNote = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.notes) { note in
                    NavigationLink(destination: NoteDetailView(viewModel: NoteDetailViewModel(note: note, noteRepository: viewModel.noteRepository))) {
                        NoteRowView(note: note)
                    }
                }
                .onDelete(perform: viewModel.deleteNotes)
            }
            .navigationTitle("Notas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isAddingNote = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingNote) {
                NoteEditView(viewModel: NoteEditViewModel(noteRepository: viewModel.noteRepository) {
                    isAddingNote = false
                    viewModel.fetchNotes()
                })
            }
            .onAppear {
                viewModel.fetchNotes()
            }
        }
    }
}
