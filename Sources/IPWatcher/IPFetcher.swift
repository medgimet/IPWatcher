import Foundation

enum IPFetcher {
    static let services = [
        "https://api.ipify.org",
        "https://icanhazip.com",
        "https://checkip.amazonaws.com",
    ]

    static func fetchCurrentIP() async throws -> String {
        var lastError: Error = URLError(.cannotConnectToHost)
        for url in services {
            do {
                let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
                let ip = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !ip.isEmpty { return ip }
            } catch {
                lastError = error
            }
        }
        throw lastError
    }
}
