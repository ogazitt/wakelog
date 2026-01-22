import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var shareItem: ShareItem?
    @State private var showDeleteConfirmation: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if dataManager.entries.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "moon.zzz")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No wake-ups logged yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(dataManager.entries) { entry in
                            EntryRow(entry: entry)
                        }
                        .onDelete(perform: dataManager.deleteEntry)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Wake-Up History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !dataManager.entries.isEmpty {
                        Menu {
                            Button(action: exportCSV) {
                                Label("Export to CSV", systemImage: "square.and.arrow.up")
                            }
                            Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                                Label("Clear All", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title3)
                        }
                    }
                }
            }
            .sheet(item: $shareItem) { item in
                ShareSheet(url: item.url)
            }
            .alert("Clear All Entries?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear All", role: .destructive) {
                    dataManager.clearAllEntries()
                }
            } message: {
                Text("This will permanently delete all logged wake-ups. This cannot be undone.")
            }
        }
    }

    private func exportCSV() {
        if let url = dataManager.getCSVFileURL() {
            shareItem = ShareItem(url: url)
        }
    }
}

struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct EntryRow: View {
    let entry: WakeLogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.formattedTime)
                .font(.headline)
            Text(entry.reasonsDescription)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    HistoryView()
        .environmentObject(DataManager())
}
