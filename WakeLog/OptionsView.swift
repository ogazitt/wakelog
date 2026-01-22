import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showAddSheet: Bool = false
    @State private var editingReason: WakeReason?

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(dataManager.customReasons) { reason in
                        Button(action: { editingReason = reason }) {
                            HStack {
                                Text(reason.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: dataManager.deleteReason)
                    .onMove(perform: dataManager.moveReason)

                    // "Other" row - not editable or deletable
                    HStack {
                        Text("Other")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("Always shown")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Wake-up Reasons")
                } footer: {
                    Text("Tap to edit, swipe to delete. \"Other\" cannot be removed and always appears last.")
                }

                Section {
                    Button(action: { showAddSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Add Reason")
                        }
                    }
                    .disabled(!dataManager.canAddReason)
                } footer: {
                    if !dataManager.canAddReason {
                        Text("Maximum of \(WakeReason.maxCustomReasons) custom reasons reached.")
                    } else {
                        Text("\(dataManager.customReasons.count) of \(WakeReason.maxCustomReasons) custom reasons used.")
                    }
                }
            }
            .navigationTitle("Options")
            .toolbar {
                EditButton()
            }
            .sheet(isPresented: $showAddSheet) {
                ReasonEditSheet(mode: .add) { name in
                    dataManager.addReason(name: name)
                }
            }
            .sheet(item: $editingReason) { reason in
                ReasonEditSheet(mode: .edit(reason)) { name in
                    dataManager.updateReason(id: reason.id, name: name)
                }
            }
        }
    }
}

struct ReasonEditSheet: View {
    enum Mode {
        case add
        case edit(WakeReason)

        var title: String {
            switch self {
            case .add: return "Add Reason"
            case .edit: return "Edit Reason"
            }
        }

        var initialName: String {
            switch self {
            case .add: return ""
            case .edit(let reason): return reason.name
            }
        }
    }

    let mode: Mode
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Reason name", text: $name)
                        .font(.title3)
                } header: {
                    Text("Name")
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(name.trimmingCharacters(in: .whitespaces))
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                name = mode.initialName
            }
        }
    }
}

#Preview {
    OptionsView()
        .environmentObject(DataManager())
}
