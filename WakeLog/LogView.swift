import SwiftUI

struct LogView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedReasonIds: Set<String> = []
    @State private var otherText: String = ""
    @State private var showOtherModal: Bool = false
    @State private var showConfirmation: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("What woke you up?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 30)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(dataManager.allReasons) { reason in
                        ReasonCheckbox(
                            reason: reason,
                            isSelected: selectedReasonIds.contains(reason.id),
                            onTap: {
                                if reason.isOther {
                                    showOtherModal = true
                                }
                                toggleReason(reason)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }

            if !otherText.isEmpty && selectedReasonIds.contains(WakeReason.otherReasonId) {
                Text("Other: \(otherText)")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            Button(action: logWakeUp) {
                Text("Log Wake-Up")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(selectedReasonIds.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(20)
            }
            .disabled(selectedReasonIds.isEmpty)
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
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
        if selectedReasonIds.contains(reason.id) {
            selectedReasonIds.remove(reason.id)
            if reason.isOther {
                otherText = ""
            }
        } else {
            selectedReasonIds.insert(reason.id)
        }
    }

    private func logWakeUp() {
        let entry = WakeLogEntry(
            reasonIds: Array(selectedReasonIds),
            otherText: selectedReasonIds.contains(WakeReason.otherReasonId) ? otherText : nil
        )
        dataManager.addEntry(entry)

        selectedReasonIds.removeAll()
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

                Text(reason.name)
                    .font(.title2)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.vertical, 14)
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
