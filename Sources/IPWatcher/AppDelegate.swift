import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var settings: Settings?
    private var timer: Timer?
    private var lastKnownIP: String?
    private var lastFlag: String = "🌐"
    private var settingsWindowController: SettingsWindowController?
    private var historyMenu = NSMenu()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()

        settings = Settings.load()
        if settings == nil {
            openSettings()
        } else {
            startMonitoring()
        }
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setStatus(flag: "🌐", ip: "…", mismatch: false)

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Check now", action: #selector(checkNow), keyEquivalent: "r"))

        let historyItem = NSMenuItem(title: "History", action: nil, keyEquivalent: "")
        historyItem.submenu = historyMenu
        menu.addItem(historyItem)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu

        refreshHistoryMenu()
    }

    private func refreshHistoryMenu() {
        historyMenu.removeAllItems()
        let entries = History.load()
        if entries.isEmpty {
            let empty = NSMenuItem(title: "No changes recorded yet", action: nil, keyEquivalent: "")
            empty.isEnabled = false
            historyMenu.addItem(empty)
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        for entry in entries {
            let title = "\(entry.oldIP)  →  \(entry.newIP)   \(formatter.string(from: entry.date))"
            let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            item.isEnabled = false
            historyMenu.addItem(item)
        }
    }

    private func setStatus(flag: String, ip: String, mismatch: Bool) {
        DispatchQueue.main.async {
            let btn = self.statusItem.button
            btn?.image = makeFlagImage(flag: flag, mismatch: mismatch)
            btn?.imagePosition = .imageLeft
            btn?.title = " \(ip)"
        }
    }

    private func setTitle(_ s: String) {
        DispatchQueue.main.async {
            self.statusItem.button?.image = nil
            self.statusItem.button?.title = s
        }
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        guard let s = settings else { return }
        timer?.invalidate()
        checkIP()
        timer = Timer.scheduledTimer(withTimeInterval: Double(s.intervalSeconds),
                                     repeats: true) { [weak self] _ in self?.checkIP() }
    }

    private func checkIP() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let info = try await IPFetcher.fetchCurrentIP()
                await MainActor.run { self.handleIP(info) }
            } catch {
                self.setTitle("⚠️ error")
            }
        }
    }

    private func handleIP(_ info: IPInfo) {
        guard let target = settings?.targetIP else { return }
        let ip = info.ip
        let flag = flagEmoji(for: info.countryCode)
        let changed = lastKnownIP != nil && lastKnownIP != ip
        let mismatch = ip != target

        if changed, let old = lastKnownIP {
            let entry = HistoryEntry(oldIP: old, newIP: ip, date: Date())
            History.append(entry)
            refreshHistoryMenu()
            Notifier.send(
                title: "IP changed!",
                body: "\(lastFlag) \(old)  →  \(flag) \(ip)"
            )
        }

        lastKnownIP = ip
        lastFlag = flag
        setStatus(flag: flag, ip: ip, mismatch: mismatch)
    }

    // MARK: - Actions

    @objc func openSettings() {
        settingsWindowController = SettingsWindowController(current: settings) { [weak self] newSettings in
            self?.settings = newSettings
            self?.startMonitoring()
        }
        settingsWindowController?.show()
    }

    @objc func checkNow() { checkIP() }

    @objc func quit() { NSApp.terminate(nil) }
}
