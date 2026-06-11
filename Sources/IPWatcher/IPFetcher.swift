import Foundation

struct IPInfo {
    var ip: String
    var countryCode: String
}

enum IPFetcher {
    static func fetchCurrentIP() async throws -> IPInfo {
        // Primary: ip-api.com returns IP + country in one call
        if let info = try? await fetchFromIPAPI() { return info }
        // Fallback: plain IP only, no country
        let ip = try await fetchPlainIP()
        return IPInfo(ip: ip, countryCode: "")
    }

    private static func fetchFromIPAPI() async throws -> IPInfo {
        let url = URL(string: "http://ip-api.com/json/?fields=query,countryCode")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONDecoder().decode(IPAPIResponse.self, from: data)
        return IPInfo(ip: json.query, countryCode: json.countryCode)
    }

    private static let fallbackServices = [
        "https://api.ipify.org",
        "https://icanhazip.com",
        "https://checkip.amazonaws.com",
    ]

    private static func fetchPlainIP() async throws -> String {
        var lastError: Error = URLError(.cannotConnectToHost)
        for urlString in fallbackServices {
            do {
                let (data, _) = try await URLSession.shared.data(from: URL(string: urlString)!)
                let ip = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !ip.isEmpty { return ip }
            } catch { lastError = error }
        }
        throw lastError
    }
}

private struct IPAPIResponse: Decodable {
    var query: String
    var countryCode: String
}

func flagEmoji(for countryCode: String) -> String {
    guard countryCode.count == 2 else { return "🌐" }
    let base: UInt32 = 127397
    var emoji = ""
    for scalar in countryCode.uppercased().unicodeScalars {
        guard let s = Unicode.Scalar(base + scalar.value) else { return "🌐" }
        emoji.append(Character(s))
    }
    return emoji
}
