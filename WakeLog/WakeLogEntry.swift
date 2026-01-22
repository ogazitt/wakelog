import Foundation

struct WakeLogEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let reasons: [WakeReason]
    let otherText: String?

    init(id: UUID = UUID(), timestamp: Date = Date(), reasons: [WakeReason], otherText: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.reasons = reasons
        self.otherText = otherText
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var reasonsDescription: String {
        var descriptions = reasons.map { $0.displayName }
        if let other = otherText, !other.isEmpty {
            if let index = descriptions.firstIndex(of: WakeReason.other.displayName) {
                descriptions[index] = "Other: \(other)"
            }
        }
        return descriptions.joined(separator: ", ")
    }

    func toCSVRow() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: timestamp)

        formatter.dateFormat = "HH:mm:ss"
        let timeStr = formatter.string(from: timestamp)

        let reasonsStr = reasonsDescription.replacingOccurrences(of: "\"", with: "\"\"")

        return "\"\(dateStr)\",\"\(timeStr)\",\"\(reasonsStr)\""
    }
}

enum WakeReason: String, Codable, CaseIterable, Identifiable {
    case abdominalPain = "abdominal_pain"
    case restlessLeg = "restless_leg"
    case needToUrinate = "need_to_urinate"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .abdominalPain: return "Abdominal pain"
        case .restlessLeg: return "Restless Leg"
        case .needToUrinate: return "Need to urinate"
        case .other: return "Other"
        }
    }
}
