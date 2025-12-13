//
//  BookEditSheet.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct BookEditSheet: View {
  let book: Book
  @Environment(\.dismiss) private var dismiss
  @State private var isSaving = false

  // Book metadata fields
  @State private var title: String
  @State private var summary: String
  @State private var number: String
  @State private var numberSort: String
  @State private var releaseDate: Date?
  @State private var isbn: String
  @State private var authors: [Author]
  @State private var tags: [String]
  @State private var links: [WebLink]

  @State private var newAuthorName: String = ""
  @State private var newAuthorRole: AuthorRole = .writer
  @State private var showCustomRoleInput: Bool = false
  @State private var customRoleName: String = ""
  @State private var newTag: String = ""
  @State private var newLinkLabel: String = ""
  @State private var newLinkURL: String = ""

  init(book: Book) {
    self.book = book
    _title = State(initialValue: book.metadata.title)
    _summary = State(initialValue: book.metadata.summary ?? "")
    _number = State(initialValue: book.metadata.number)
    _numberSort = State(initialValue: String(book.metadata.numberSort))

    // Parse release date from string
    if let dateString = book.metadata.releaseDate, !dateString.isEmpty {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withFullDate]
      _releaseDate = State(initialValue: formatter.date(from: dateString))
    } else {
      _releaseDate = State(initialValue: nil)
    }

    _isbn = State(initialValue: book.metadata.isbn ?? "")
    _authors = State(initialValue: book.metadata.authors ?? [])
    _tags = State(initialValue: book.metadata.tags ?? [])
    _links = State(initialValue: book.metadata.links ?? [])
  }

  var body: some View {
    SheetView(title: String(localized: "Edit Book"), size: .large, applyFormStyle: true) {
      Form {
        Section("Basic Information") {
          TextField("Title", text: $title)
          TextField("Number", text: $number)
          TextField("Number Sort", text: $numberSort)
            #if os(iOS) || os(tvOS)
              .keyboardType(.decimalPad)
            #endif

          DatePicker(
            "Release Date",
            selection: Binding(
              get: { releaseDate ?? Date() },
              set: { releaseDate = $0 }
            ),
            displayedComponents: .date
          )
          .datePickerStyle(.compact)

          if releaseDate != nil {
            Button("Clear Date") {
              releaseDate = nil
            }
            .foregroundColor(.red)
          }

          TextField("ISBN", text: $isbn)
            #if os(iOS) || os(tvOS)
              .keyboardType(.default)
            #endif
          TextField("Summary", text: $summary, axis: .vertical)
            .lineLimit(3...10)
        }

        Section("Authors") {
          ForEach(authors.indices, id: \.self) { index in
            HStack {
              VStack(alignment: .leading) {
                Text(authors[index].name)
                  .font(.body)
                Text(authors[index].role.displayName)
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              Spacer()
              Button(role: .destructive) {
                authors.remove(at: index)
              } label: {
                Image(systemName: "trash")
              }
            }
          }
          VStack {
            HStack {
              TextField("Name", text: $newAuthorName)
              Picker("Role", selection: $newAuthorRole) {
                ForEach(AuthorRole.predefinedCases, id: \.self) { role in
                  Text(role.displayName).tag(role)
                }
                Text("Custom").tag(AuthorRole.custom(""))
              }
              .frame(maxWidth: 150)
            }

            if case .custom = newAuthorRole {
              HStack {
                TextField("Custom Role", text: $customRoleName)
                  .textFieldStyle(.roundedBorder)
              }
            }

            Button {
              if !newAuthorName.isEmpty {
                let finalRole: AuthorRole
                if case .custom = newAuthorRole {
                  finalRole = .custom(customRoleName.isEmpty ? "Custom" : customRoleName)
                } else {
                  finalRole = newAuthorRole
                }
                authors.append(Author(name: newAuthorName, role: finalRole))
                newAuthorName = ""
                newAuthorRole = .writer
                customRoleName = ""
              }
            } label: {
              Label("Add Author", systemImage: "plus.circle.fill")
            }
            .disabled(newAuthorName.isEmpty)
          }
        }

        Section("Tags") {
          ForEach(tags.indices, id: \.self) { index in
            HStack {
              Text(tags[index])
              Spacer()
              Button(role: .destructive) {
                tags.remove(at: index)
              } label: {
                Image(systemName: "trash")
              }
            }
          }
          HStack {
            TextField("Tag", text: $newTag)
            Button {
              if !newTag.isEmpty && !tags.contains(newTag) {
                tags.append(newTag)
                newTag = ""
              }
            } label: {
              Image(systemName: "plus.circle.fill")
            }
            .disabled(newTag.isEmpty)
          }
        }

        Section("Links") {
          ForEach(links.indices, id: \.self) { index in
            VStack(alignment: .leading) {
              HStack {
                Text(links[index].label)
                  .font(.body)
                Spacer()
                Button(role: .destructive) {
                  links.remove(at: index)
                } label: {
                  Image(systemName: "trash")
                }
              }
              Text(links[index].url)
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          VStack {
            TextField("Label", text: $newLinkLabel)
            TextField("URL", text: $newLinkURL)
              #if os(iOS) || os(tvOS)
                .keyboardType(.URL)
                .autocapitalization(.none)
              #endif
            Button {
              if !newLinkLabel.isEmpty && !newLinkURL.isEmpty {
                links.append(WebLink(label: newLinkLabel, url: newLinkURL))
                newLinkLabel = ""
                newLinkURL = ""
              }
            } label: {
              Label("Add Link", systemImage: "plus.circle.fill")
            }
            .disabled(newLinkLabel.isEmpty || newLinkURL.isEmpty)
          }
        }
      }
    } controls: {
      Button(action: saveChanges) {
        if isSaving {
          ProgressView()
        } else {
          Label("Save", systemImage: "checkmark")
        }
      }
      .disabled(isSaving)
    }
  }

  private func saveChanges() {
    isSaving = true
    Task {
      do {
        var metadata: [String: Any] = [:]

        if title != book.metadata.title {
          metadata["title"] = title
        }
        if summary != (book.metadata.summary ?? "") {
          metadata["summary"] = summary.isEmpty ? NSNull() : summary
        }
        if number != book.metadata.number {
          metadata["number"] = number
        }
        if let numberSortDouble = Double(numberSort), numberSortDouble != book.metadata.numberSort {
          metadata["numberSort"] = numberSortDouble
        }
        if let date = releaseDate {
          let formatter = ISO8601DateFormatter()
          formatter.formatOptions = [.withFullDate]
          let dateString = formatter.string(from: date)
          if dateString != (book.metadata.releaseDate ?? "") {
            metadata["releaseDate"] = dateString
          }
        } else if book.metadata.releaseDate != nil {
          metadata["releaseDate"] = NSNull()
        }
        if isbn != (book.metadata.isbn ?? "") {
          metadata["isbn"] = isbn.isEmpty ? NSNull() : isbn
        }

        let currentAuthors = book.metadata.authors ?? []
        if authors != currentAuthors {
          metadata["authors"] = authors.map { ["name": $0.name, "role": $0.role] }
        }

        let currentTags = book.metadata.tags ?? []
        if tags != currentTags {
          metadata["tags"] = tags
        }

        let currentLinks = book.metadata.links ?? []
        if links != currentLinks {
          metadata["links"] = links.map { ["label": $0.label, "url": $0.url] }
        }

        if !metadata.isEmpty {
          try await BookService.shared.updateBookMetadata(bookId: book.id, metadata: metadata)
          await MainActor.run {
            ErrorManager.shared.notify(message: String(localized: "notification.book.updated"))
            dismiss()
          }
        } else {
          await MainActor.run {
            dismiss()
          }
        }
      } catch {
        await MainActor.run {
          ErrorManager.shared.alert(error: error)
        }
      }
      await MainActor.run {
        isSaving = false
      }
    }
  }
}
