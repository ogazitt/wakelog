import Foundation

struct WakeLogEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let reasonIds: [String]
    let otherText: String?

    init(id: UUID = UUID(), timestamp: Date = Date(), reasonIds: [String], otherText: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.reasonIds = reasonIds
        self.otherText = otherText
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    func reasonsDescription(using reasons: [WakeReason]) -> String {
        var descriptions: [String] = []
        for reasonId in reasonIds {
            if reasonId == WakeReason.otherReasonId {
                if let other = otherText, !other.isEmpty {
                    descriptions.append("Other: \(other)")
                } else {
                    descriptions.append("Other")
                }
            } else if let reason = reasons.first(where: { $0.id == reasonId }) {
                descriptions.append(reason.name)
            } else {
                descriptions.append(reasonId)
            }
        }
        return descriptions.joined(separator: ", ")
    }

    func toCSVRow(using reasons: [WakeReason]) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: timestamp)

        formatter.dateFormat = "HH:mm:ss"
        let timeStr = formatter.string(from: timestamp)

        let reasonsStr = reasonsDescription(using: reasons).replacingOccurrences(of: "\"", with: "\"\"")

        return "\"\(dateStr)\",\"\(timeStr)\",\"\(reasonsStr)\""
    }
}

struct WakeReason: Identifiable, Codable, Equatable {
    let id: String
    var name: String

    static let otherReasonId = "other"
    static let maxCustomReasons = 6

    static let otherReason = WakeReason(id: otherReasonId, name: "Other")

    static let defaultReasons: [WakeReason] = [
        WakeReason(id: "abdominal_pain", name: "Abdominal pain"),
        WakeReason(id: "restless_leg", name: "Restless Leg"),
        WakeReason(id: "need_to_urinate", name: "Need to urinate")
    ]

    var isOther: Bool {
        id == WakeReason.otherReasonId
    }
}
