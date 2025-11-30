//
//  SettingsDashboardView.swift
//  Komga
//
//  Created by Komga iOS Client
//

import SwiftUI

struct SettingsDashboardView: View {
  @State private var sections: [DashboardSection] = AppConfig.dashboardSections

  private func isSectionVisible(_ section: DashboardSection) -> Bool {
    return sections.contains(section)
  }

  private func toggleSectionVisibility(_ section: DashboardSection) {
    if let index = sections.firstIndex(of: section) {
      // Remove from array (hide)
      sections.remove(at: index)
    } else {
      // Add to array (show) - add at the end or find a good position
      // Try to maintain relative order with allCases
      if let referenceIndex = DashboardSection.allCases.firstIndex(of: section) {
        var insertIndex = sections.count
        // Find position based on allCases order
        for (idx, existingSection) in sections.enumerated() {
          if let existingIndex = DashboardSection.allCases.firstIndex(of: existingSection),
            existingIndex > referenceIndex
          {
            insertIndex = idx
            break
          }
        }
        sections.insert(section, at: insertIndex)
      } else {
        sections.append(section)
      }
    }
    AppConfig.dashboardSections = sections
  }

  private func moveSections(from source: IndexSet, to destination: Int) {
    sections.move(fromOffsets: source, toOffset: destination)
    AppConfig.dashboardSections = sections
  }

  #if os(tvOS)
    private func moveSectionUp(_ section: DashboardSection) {
      guard let index = sections.firstIndex(of: section),
        index > 0
      else { return }
      sections.swapAt(index, index - 1)
      AppConfig.dashboardSections = sections
    }

    private func moveSectionDown(_ section: DashboardSection) {
      guard let index = sections.firstIndex(of: section),
        index < sections.count - 1
      else { return }
      sections.swapAt(index, index + 1)
      AppConfig.dashboardSections = sections
    }
  #endif

  private var hiddenSections: [DashboardSection] {
    DashboardSection.allCases.filter { !isSectionVisible($0) }
  }

  var body: some View {
    List {
      Section(header: Text("Dashboard Sections")) {
        #if os(iOS) || os(macOS)
          ForEach(sections) { section in
            HStack {
              Label {
                Text(section.displayName)
              } icon: {
                Image(systemName: section.icon)
              }
              Spacer()
              Toggle(
                "",
                isOn: Binding(
                  get: { isSectionVisible(section) },
                  set: { _ in toggleSectionVisibility(section) }
                ))
            }
          }
          .onMove(perform: moveSections)
        #else
          ForEach(sections) { section in
            HStack {
              Label {
                Text(section.displayName)
              } icon: {
                Image(systemName: section.icon)
              }
              Spacer()
              Toggle(
                "",
                isOn: Binding(
                  get: { isSectionVisible(section) },
                  set: { _ in toggleSectionVisibility(section) }
                ))
              HStack(spacing: 16) {
                Button {
                  moveSectionUp(section)
                } label: {
                  Image(systemName: "arrow.up.circle.fill")
                    .font(.title3)
                }
                .buttonStyle(.plain)
                Button {
                  moveSectionDown(section)
                } label: {
                  Image(systemName: "arrow.down.circle.fill")
                    .font(.title3)
                }
                .buttonStyle(.plain)
              }
            }
          }
        #endif
      }

      if !hiddenSections.isEmpty {
        Section(header: Text("Hidden Sections")) {
          ForEach(hiddenSections) { section in
            HStack {
              Label {
                Text(section.displayName)
              } icon: {
                Image(systemName: section.icon)
              }
              Spacer()
              Toggle(
                "",
                isOn: Binding(
                  get: { isSectionVisible(section) },
                  set: { _ in toggleSectionVisibility(section) }
                ))
            }
          }
        }
      }

      Section {
        Button {
          // Reset to default
          sections = DashboardSection.allCases
          AppConfig.dashboardSections = sections
        } label: {
          HStack {
            Spacer()
            Text("Reset to Default")
            Spacer()
          }
        }
      }
    }
    .optimizedListStyle()
    .inlineNavigationBarTitle("Dashboard")
    .onAppear {
      sections = AppConfig.dashboardSections
    }
  }
}
