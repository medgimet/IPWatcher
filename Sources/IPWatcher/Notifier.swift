import Foundation

enum Notifier {
    static func send(title: String, body: String) {
        let script = """
        display notification "\(body.replacing("\"", with: "\\\""))" with title "\(title.replacing("\"", with: "\\\""))"
        """
        let proc = Process()
        proc.launchPath = "/usr/bin/osascript"
        proc.arguments = ["-e", script]
        try? proc.run()
    }
}
