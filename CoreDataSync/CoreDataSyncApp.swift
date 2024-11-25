//
//  CoreDataSyncApp.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

import SwiftUI

@main
struct CoreDataSyncApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NoteListView(
                        viewModel: NoteListViewModel(
                               noteRepository: NoteRepository(persistentContainer: persistenceController.container)
                           )
                       )
        }
    }
}
