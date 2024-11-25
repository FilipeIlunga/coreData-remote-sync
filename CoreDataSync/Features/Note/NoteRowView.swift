//
//  NoteRowView.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

import SwiftUI

struct NoteRowView: View {
    let note: NoteModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(note.content)
                .font(.headline)
            Text("Modificado em: \(formattedDate(note.modifiedAt))")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
