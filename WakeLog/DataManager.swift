import Foundation

class DataManager: ObservableObject {
    @Published var entries: [WakeLogEntry] = []
    @Published var customReasons: [WakeReason] = []

    private let entriesStorageKey = "wakelog_entries"
    private let reasonsStorageKey = "wakelog_reasons"

    var allReasons: [WakeReason] {
        customReasons + [WakeReason.otherReason]
    }

    init() {
        loadReasons()
        loadEntries()
    }

    // MARK: - Entry Management

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
        guard let data = UserDefaults.standard.data(forKey: entriesStorageKey) else { return }
        do {
            entries = try JSONDecoder().decode([WakeLogEntry].self, from: data)
        } catch {
            print("Failed to load entries: \(error)")
        }
    }

    private func saveEntries() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: entriesStorageKey)
        } catch {
            print("Failed to save entries: \(error)")
        }
    }

    // MARK: - Reason Management

    var canAddReason: Bool {
        customReasons.count < WakeReason.maxCustomReasons
    }

    func addReason(name: String) {
        guard canAddReason else { return }
        let id = UUID().uuidString
        let reason = WakeReason(id: id, name: name)
        customReasons.append(reason)
        saveReasons()
    }

    func updateReason(id: String, name: String) {
        guard let index = customReasons.firstIndex(where: { $0.id == id }) else { return }
        customReasons[index].name = name
        saveReasons()
    }

    func deleteReason(at offsets: IndexSet) {
        customReasons.remove(atOffsets: offsets)
        saveReasons()
    }

    func deleteReason(id: String) {
        customReasons.removeAll { $0.id == id }
        saveReasons()
    }

    func moveReason(from source: IndexSet, to destination: Int) {
        customReasons.move(fromOffsets: source, toOffset: destination)
        saveReasons()
    }

    private func loadReasons() {
        guard let data = UserDefaults.standard.data(forKey: reasonsStorageKey) else {
            customReasons = WakeReason.defaultReasons
            return
        }
        do {
            customReasons = try JSONDecoder().decode([WakeReason].self, from: data)
        } catch {
            print("Failed to load reasons: \(error)")
            customReasons = WakeReason.defaultReasons
        }
    }

    private func saveReasons() {
        do {
            let data = try JSONEncoder().encode(customReasons)
            UserDefaults.standard.set(data, forKey: reasonsStorageKey)
        } catch {
            print("Failed to save reasons: \(error)")
        }
    }

    // MARK: - CSV Export

    func exportToCSV() -> String {
        var csv = "Date,Time,Reasons\n"
        for entry in entries.reversed() {
            csv += entry.toCSVRow(using: allReasons) + "\n"
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
