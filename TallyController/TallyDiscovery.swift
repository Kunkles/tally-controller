import Foundation

struct DiscoveredUnit: Identifiable {
    let id   = UUID()
    let name: String  // mDNS service name → used as display name
    let host: String  // resolved hostname → used as address
}

class TallyDiscovery: NSObject, ObservableObject {
    @Published var discovered: [DiscoveredUnit] = []
    @Published var isScanning = false

    private var browser  = NetServiceBrowser()
    private var pending: [NetService] = []  // retain until resolved

    func startScan() {
        DispatchQueue.main.async {
            self.discovered.removeAll()
            self.pending.removeAll()
            self.isScanning = true
        }
        browser.delegate = self
        browser.searchForServices(ofType: "_tally._tcp.", inDomain: "local.")
    }

    func stopScan() {
        browser.stop()
        DispatchQueue.main.async { self.isScanning = false }
    }
}

extension TallyDiscovery: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser,
                           didFind service: NetService,
                           moreComing: Bool) {
        pending.append(service)
        service.delegate = self
        service.resolve(withTimeout: 5)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser,
                           didNotSearch errorDict: [String: NSNumber]) {
        DispatchQueue.main.async { self.isScanning = false }
    }
}

extension TallyDiscovery: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        var host = sender.hostName ?? "\(sender.name).local"
        if host.hasSuffix(".") { host = String(host.dropLast()) }
        let unit = DiscoveredUnit(name: sender.name, host: host)

        DispatchQueue.main.async {
            guard !self.discovered.contains(where: { $0.host == unit.host }) else { return }
            self.discovered.append(unit)
        }
    }

    func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) {
        pending.removeAll { $0 === sender }
    }
}
