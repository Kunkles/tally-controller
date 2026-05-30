import SwiftUI

struct AddTallyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name      = ""
    @State private var ipAddress = ""

    let onAdd: (String, String) -> Void

    var isValid: Bool { !name.isEmpty && !ipAddress.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name  (e.g. Camera 1)", text: $name)
                    TextField("IP Address or hostname", text: $ipAddress)
                        .autocorrectionDisabled()
                } footer: {
                    Text("Enter the IP address shown on the device's status page, or its .local hostname (e.g. tally-cam1.local).")
                }
            }
            .navigationTitle("Add Tally")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(name, ipAddress)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}
