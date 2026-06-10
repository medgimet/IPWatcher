import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var settings: Settings?
    private var timer: Timer?
    private var lastKnownIP: String?
    private var settingsWindowController: SettingsWindowController?

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
        setTitle("🌐 …")

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Настройки…", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Проверить сейчас", action: #selector(checkNow), keyEquivalent: "r"))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Завершить", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    private func setTitle(_ s: String) {
        DispatchQueue.main.async {
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
                let ip = try await IPFetcher.fetchCurrentIP()
                await MainActor.run { self.handleIP(ip) }
            } catch {
                self.setTitle("⚠️ ошибка")
            }
        }
    }

    private func handleIP(_ ip: String) {
        guard let target = settings?.targetIP else { return }
        let changed = (lastKnownIP != nil && lastKnownIP != ip)
        let mismatch = (ip != target)

        if changed || (lastKnownIP == nil && mismatch) {
            Notifier.send(
                title: "IP изменился!",
                body: "Было: \(lastKnownIP ?? target)  →  Стало: \(ip)"
            )
        }

        lastKnownIP = ip
        setTitle(mismatch ? "⚠️ \(ip)" : "🌐 \(ip)")
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
