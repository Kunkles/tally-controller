import Foundation

/// Cleans up a user-entered address into a bare hostname or IP.
/// - Strips http:// / https://
/// - Strips any path (/status, /tally/on, etc.)
/// - Strips port numbers
/// - Appends .local if it looks like a plain hostname with no dots
func sanitizeAddress(_ input: String) -> String {
    var s = input.trimmingCharacters(in: .whitespaces).lowercased()

    // Strip scheme
    for scheme in ["https://", "http://"] {
        if s.hasPrefix(scheme) { s = String(s.dropFirst(scheme.count)) }
    }

    // Strip path (everything from the first / onward)
    if let slash = s.firstIndex(of: "/") {
        s = String(s[s.startIndex ..< slash])
    }

    // Strip port (e.g. :80) — only if after the hostname, not inside an IPv6 address
    if !s.hasPrefix("["), let colon = s.lastIndex(of: ":") {
        let afterColon = s[s.index(after: colon)...]
        if afterColon.allSatisfy({ $0.isNumber }) {
            s = String(s[s.startIndex ..< colon])
        }
    }

    s = s.trimmingCharacters(in: .whitespaces)

    // If it's a plain hostname (no dots, not an IP), append .local
    let isIP = s.range(of: #"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$"#,
                       options: .regularExpression) != nil
    if !isIP && !s.isEmpty && !s.contains(".") {
        s += ".local"
    }

    return s
}
