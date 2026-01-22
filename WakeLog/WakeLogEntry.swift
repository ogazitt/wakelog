import Foundation
import SwiftUI

struct WakeLogEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let reasonIds: [String]
    let otherText: String?
    let reasonNames: [String: String]?  // Maps reason ID to name at time of logging

    init(id: UUID = UUID(), timestamp: Date = Date(), reasonIds: [String], otherText: String? = nil, reasonNames: [String: String]? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.reasonIds = reasonIds
        self.otherText = otherText
        self.reasonNames = reasonNames
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
            } else if let storedName = reasonNames?[reasonId] {
                // Use stored name for deleted reasons
                descriptions.append(storedName)
            } else {
                // Fallback for old entries without stored names
                descriptions.append("(deleted)")
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

// Color palette that works well in both light and dark mode
struct ReasonColors {
    // Vibrant colors that are visible in both light and dark modes
    static let palette: [Color] = [
        Color(red: 0.35, green: 0.55, blue: 0.95),  // Blue
        Color(red: 0.95, green: 0.45, blue: 0.45),  // Coral Red
        Color(red: 0.30, green: 0.75, blue: 0.55),  // Teal Green
        Color(red: 0.95, green: 0.65, blue: 0.25),  // Orange
        Color(red: 0.70, green: 0.45, blue: 0.85),  // Purple
        Color(red: 0.85, green: 0.55, blue: 0.70),  // Pink
        Color(red: 0.50, green: 0.70, blue: 0.35),  // Lime Green
    ]

    static func color(for index: Int) -> Color {
        palette[index % palette.count]
    }

    static func color(for reasonId: String, in reasons: [WakeReason]) -> Color {
        // "Other" always gets the last color in the palette
        if reasonId == WakeReason.otherReasonId {
            return palette.last ?? .gray
        }

        // Find the index of this reason (excluding "Other")
        let customReasons = reasons.filter { !$0.isOther }
        if let index = customReasons.firstIndex(where: { $0.id == reasonId }) {
            return color(for: index)
        }

        return .gray
    }
}
