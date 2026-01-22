import SwiftUI

struct LogView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedReasons: Set<WakeReason> = []
    @State private var otherText: String = ""
    @State private var showOtherModal: Bool = false
    @State private var showConfirmation: Bool = false

    var body: some View {
        VStack(spacing: 30) {
            Text("What woke you up?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            VStack(spacing: 20) {
                ForEach(WakeReason.allCases) { reason in
                    ReasonCheckbox(
                        reason: reason,
                        isSelected: selectedReasons.contains(reason),
                        onTap: {
                            if reason == .other {
                                showOtherModal = true
                            }
                            toggleReason(reason)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)

            if !otherText.isEmpty && selectedReasons.contains(.other) {
                Text("Other: \(otherText)")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            Spacer()

            Button(action: logWakeUp) {
                Text("Log Wake-Up")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 25)
                    .background(selectedReasons.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(20)
            }
            .disabled(selectedReasons.isEmpty)
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .sheet(isPresented: $showOtherModal) {
            OtherReasonModal(otherText: $otherText, isPresented: $showOtherModal)
        }
        .overlay(
            Group {
                if showConfirmation {
                    ConfirmationOverlay()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showConfirmation = false
                            }
                        }
                }
            }
        )
    }

    private func toggleReason(_ reason: WakeReason) {
        if selectedReasons.contains(reason) {
            selectedReasons.remove(reason)
            if reason == .other {
                otherText = ""
            }
        } else {
            selectedReasons.insert(reason)
        }
    }

    private func logWakeUp() {
        let entry = WakeLogEntry(
            reasons: Array(selectedReasons),
            otherText: selectedReasons.contains(.other) ? otherText : nil
        )
        dataManager.addEntry(entry)

        selectedReasons.removeAll()
        otherText = ""
        showConfirmation = true
    }
}

struct ReasonCheckbox: View {
    let reason: WakeReason
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title)
                    .foregroundColor(isSelected ? .blue : .gray)

                Text(reason.displayName)
                    .font(.title2)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct OtherReasonModal: View {
    @Binding var otherText: String
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("What else woke you up?")
                    .font(.title2)
                    .padding(.top, 30)

                TextField("Enter reason", text: $otherText)
                    .font(.title3)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Other Reason")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .font(.headline)
                }
            }
        }
    }
}

struct ConfirmationOverlay: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            Text("Logged!")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding(40)
        .background(Color(.systemBackground).opacity(0.95))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

#Preview {
    LogView()
        .environmentObject(DataManager())
}
