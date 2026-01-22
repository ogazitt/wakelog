import SwiftUI
import Charts

enum TimePeriod: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case allTime = "All Time"

    var id: String { rawValue }

    var startDate: Date? {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now)
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: now)
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: now)
        case .allTime:
            return nil
        }
    }
}

struct ReasonCount: Identifiable {
    let id: String
    let name: String
    let count: Int
    let color: Color
}

struct ChartsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedPeriod: TimePeriod = .allTime

    var filteredEntries: [WakeLogEntry] {
        guard let startDate = selectedPeriod.startDate else {
            return dataManager.entries
        }
        return dataManager.entries.filter { $0.timestamp >= startDate }
    }

    var reasonCounts: [ReasonCount] {
        var counts: [String: Int] = [:]

        for entry in filteredEntries {
            for reasonId in entry.reasonIds {
                counts[reasonId, default: 0] += 1
            }
        }

        let allReasons = dataManager.allReasons

        return counts.map { (reasonId, count) in
            let name: String
            if reasonId == WakeReason.otherReasonId {
                name = "Other"
            } else if let reason = allReasons.first(where: { $0.id == reasonId }) {
                name = reason.name
            } else {
                name = reasonId
            }

            let color = ReasonColors.color(for: reasonId, in: allReasons)

            return ReasonCount(id: reasonId, name: name, count: count, color: color)
        }
        .sorted {
            if $0.count != $1.count {
                return $0.count > $1.count
            }
            return $0.name < $1.name
        }
    }

    var maxCount: Int {
        reasonCounts.map { $0.count }.max() ?? 1
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Period Selector
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if reasonCounts.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No data for this period")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    // Bar Chart
                    Chart(reasonCounts) { item in
                        BarMark(
                            x: .value("Count", item.count),
                            y: .value("Reason", item.name)
                        )
                        .foregroundStyle(item.color)
                        .cornerRadius(6)
                        .annotation(position: .trailing, alignment: .leading) {
                            Text("\(item.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                        }
                    }
                    .chartXScale(domain: 0...(maxCount + 1))
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 5)) { value in
                            AxisGridLine()
                            AxisValueLabel()
                        }
                    }
                    .padding()
                    .frame(minHeight: CGFloat(reasonCounts.count * 50 + 60))

                    // Summary
                    VStack(spacing: 8) {
                        Text("Total wake-ups: \(filteredEntries.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let topReason = reasonCounts.first {
                            Text("Most common: \(topReason.name) (\(topReason.count))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()

                    Spacer()
                }
            }
            .navigationTitle("Charts")
        }
    }
}

#Preview {
    ChartsView()
        .environmentObject(DataManager())
}
