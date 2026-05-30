import SwiftUI

struct ContentView: View {
    @StateObject private var store = TallyStore()
    @State private var showingAddTally    = false
    @State private var showingDiscovery   = false
    @State private var editMode           = false
    @State private var selectedIDs        = Set<UUID>()

    var body: some View {
        NavigationStack {
            List {

                // --- Gang Control ---
                Section {
                    Toggle("Gang Mode", isOn: $store.gangEnabled)
                        .tint(.red)

                    if store.gangEnabled {
                        HStack(spacing: 12) {
                            Button("RECORD ON") {
                                Task { await store.gangOn() }
                            }
                            .buttonStyle(TallyButtonStyle(active: true))
                            .frame(maxWidth: .infinity)

                            Button("RECORD OFF") {
                                Task { await store.gangOff() }
                            }
                            .buttonStyle(TallyButtonStyle(active: false))
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Gang Control")
                } footer: {
                    if store.gangEnabled {
                        Text("Individual controls are disabled while gang mode is on.")
                    }
                }

                // --- Individual Units ---
                Section {
                    ForEach(store.units) { unit in
                        TallyRow(
                            unit: unit,
                            gangEnabled: store.gangEnabled,
                            editMode: editMode,
                            isSelected: selectedIDs.contains(unit.id),
                            onSelect: { selected in
                                if selected { selectedIDs.insert(unit.id) }
                                else        { selectedIDs.remove(unit.id) }
                            },
                            onToggle: { on in
                                Task { await store.setTally(unit, on: on) }
                            },
                            onUpdate: { updated in
                                store.updateUnit(updated)
                            }
                        )
                        .contextMenu {
                            Button(role: .destructive) {
                                if let idx = store.units.firstIndex(where: { $0.id == unit.id }) {
                                    store.removeUnits(at: IndexSet([idx]))
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text("Units  (\(store.units.count))")
                }
            }
            .navigationTitle("Tally Controller")
            .toolbar {
                // Delete selected (edit mode only)
                ToolbarItem(placement: .primaryAction) {
                    if editMode && !selectedIDs.isEmpty {
                        Button(role: .destructive) {
                            deleteSelected()
                        } label: {
                            Label("Delete Selected", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }

                // Discover + Add buttons (normal mode only)
                ToolbarItem(placement: .primaryAction) {
                    if !editMode {
                        HStack {
                            Button {
                                showingDiscovery = true
                            } label: {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                            }
                            .help("Discover tally units on the network")

                            Button {
                                showingAddTally = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            .help("Add unit manually")
                        }
                    }
                }

                // Edit / Done
                ToolbarItem(placement: .primaryAction) {
                    Button(editMode ? "Done" : "Edit") {
                        editMode.toggle()
                        if !editMode { selectedIDs.removeAll() }
                    }
                }
            }
            .task {
                await store.startPolling()
            }
            .sheet(isPresented: $showingAddTally) {
                AddTallyView { name, ip in
                    store.addUnit(name: name, ipAddress: ip)
                }
            }
            .sheet(isPresented: $showingDiscovery) {
                DiscoveryView(
                    existingHosts: Set(store.units.map { $0.ipAddress })
                ) { name, host in
                    store.addUnit(name: name, ipAddress: host)
                }
            }
        }
    }

    private func deleteSelected() {
        let offsets = store.units.enumerated()
            .filter { selectedIDs.contains($0.element.id) }
            .map    { $0.offset }
        store.removeUnits(at: IndexSet(offsets))
        selectedIDs.removeAll()
        editMode = false
    }
}
