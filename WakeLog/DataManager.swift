import Foundation

class DataManager: ObservableObject {
    @Published var entries: [WakeLogEntry] = []

    private let storageKey = "wakelog_entries"

    init() {
        loadEntries()
    }

    func addEntry(_ entry: WakeLogEntry) {
        entries.insert(entry, at: 0)
        saveEntries()
    }

    func deleteEntry(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveEntries()
    }

    func clearAllEntries() {
        entries.removeAll()
        saveEntries()
    }

    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            entries = try JSONDecoder().decode([WakeLogEntry].self, from: data)
        } catch {
            print("Failed to load entries: \(error)")
        }
    }

    private func saveEntries() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save entries: \(error)")
        }
    }

    func exportToCSV() -> String {
        var csv = "Date,Time,Reasons\n"
        for entry in entries.reversed() {
            csv += entry.toCSVRow() + "\n"
        }
        return csv
    }

    func getCSVFileURL() -> URL? {
        let csv = exportToCSV()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: Date())
        let fileName = "WakeLog_\(dateStr).csv"

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write CSV file: \(error)")
            return nil
        }
    }
}
