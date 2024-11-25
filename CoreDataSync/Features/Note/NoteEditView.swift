//
//  NoteEditView.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

import SwiftUI

struct NoteEditView: View {
    @ObservedObject var viewModel: NoteEditViewModel

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $viewModel.content)
                    .padding()
                Spacer()
            }
            .navigationTitle("Nova Nota")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { viewModel.onComplete() }) {
                        Text("Cancelar")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.saveNote) {
                        Text("Salvar")
                    }
                    .disabled(viewModel.content.isEmpty)
                }
            }
            .alert(item: $viewModel.errorMessage) { errorMessage in
                Alert(title: Text("Erro"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
