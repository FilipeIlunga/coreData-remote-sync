//
//  NoteDetailView.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

import SwiftUI

struct NoteDetailView: View {
    @StateObject var viewModel: NoteDetailViewModel

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.isEditing {
                TextEditor(text: $viewModel.note.content)
                    .padding()
            } else {
                Text(viewModel.note.content)
                    .padding()
            }
            Spacer()
        }
        .navigationTitle("Detalhes da Nota")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleEdit) {
                    Text(viewModel.isEditing ? "Salvar" : "Editar")
                }
            }
        }
        .alert(item: $viewModel.errorMessage) { errorMessage in
            Alert(title: Text("Erro"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func toggleEdit() {
        if viewModel.isEditing {
            viewModel.saveNote()
        } else {
            viewModel.isEditing = true
        }
    }
}
