//
//  SettingsLibrariesView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftData
import SwiftUI

struct SettingsLibrariesView: View {
  @State private var libraryPendingDelete: KomgaLibrary?
  @State private var deleteConfirmationText: String = ""

  private var isDeleteAlertPresented: Binding<Bool> {
    Binding(
      get: { libraryPendingDelete != nil },
      set: {
        if !$0 {
          libraryPendingDelete = nil
          deleteConfirmationText = ""
        }
      }
    )
  }

  var body: some View {
    LibraryListContent(
      showMetrics: true,
      showDeleteAction: true,
      onDeleteLibrary: { library in
        libraryPendingDelete = library
        deleteConfirmationText = ""
      }
    )
    .inlineNavigationBarTitle("Libraries")
    .alert("Delete Library?", isPresented: isDeleteAlertPresented) {
      if let libraryPendingDelete {
        TextField("Enter library name", text: $deleteConfirmationText)
        Button("Delete", role: .destructive) {
          deleteConfirmedLibrary(libraryPendingDelete)
        }
        .disabled(deleteConfirmationText != libraryPendingDelete.name)
        Button("Cancel", role: .cancel) {
          deleteConfirmationText = ""
        }
      }
    } message: {
      if let libraryPendingDelete {
        Text(
          "This will permanently delete \(libraryPendingDelete.name) from Komga.\n\nTo confirm, please type the library name: \(libraryPendingDelete.name)"
        )
      }
    }
  }

  private func deleteConfirmedLibrary(_ library: KomgaLibrary) {
    Task {
      do {
        try await LibraryService.shared.deleteLibrary(id: library.libraryId)
        await LibraryManager.shared.refreshLibraries()
        await MainActor.run {
          ErrorManager.shared.notify(message: "Library deleted")
        }
      } catch {
        _ = await MainActor.run {
          ErrorManager.shared.alert(error: error)
        }
      }
      _ = await MainActor.run {
        libraryPendingDelete = nil
        deleteConfirmationText = ""
      }
    }
  }
}

// MARK: - Sheet Wrapper

struct SettingsLibrariesSheetView: View {
  @State private var libraryPendingDelete: KomgaLibrary?
  @State private var deleteConfirmationText: String = ""

  private var isDeleteAlertPresented: Binding<Bool> {
    Binding(
      get: { libraryPendingDelete != nil },
      set: {
        if !$0 {
          libraryPendingDelete = nil
          deleteConfirmationText = ""
        }
      }
    )
  }

  var body: some View {
    SheetView(title: "Libraries", size: .large) {
      LibraryListContent(
        showMetrics: true,
        showDeleteAction: true,
        loadMetrics: false,
        onDeleteLibrary: { library in
          libraryPendingDelete = library
          deleteConfirmationText = ""
        }
      )
      .alert("Delete Library?", isPresented: isDeleteAlertPresented) {
        if let libraryPendingDelete {
          TextField("Enter library name", text: $deleteConfirmationText)
          Button("Delete", role: .destructive) {
            deleteConfirmedLibrary(libraryPendingDelete)
          }
          .disabled(deleteConfirmationText != libraryPendingDelete.name)
          Button("Cancel", role: .cancel) {
            deleteConfirmationText = ""
          }
        }
      } message: {
        if let libraryPendingDelete {
          Text(
            "This will permanently delete \(libraryPendingDelete.name) from Komga.\n\nTo confirm, please type the library name: \(libraryPendingDelete.name)"
          )
        }
      }
    }
  }

  private func deleteConfirmedLibrary(_ library: KomgaLibrary) {
    Task {
      do {
        try await LibraryService.shared.deleteLibrary(id: library.libraryId)
        await LibraryManager.shared.refreshLibraries()
        await MainActor.run {
          ErrorManager.shared.notify(message: "Library deleted")
        }
      } catch {
        _ = await MainActor.run {
          ErrorManager.shared.alert(error: error)
        }
      }
      _ = await MainActor.run {
        libraryPendingDelete = nil
        deleteConfirmationText = ""
      }
    }
  }
}
