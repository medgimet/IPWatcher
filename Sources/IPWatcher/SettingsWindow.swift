import AppKit

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private var ipField = NSTextField()
    private var intervalField = NSTextField()
    private var onSave: (Settings) -> Void

    init(current: Settings?, onSave: @escaping (Settings) -> Void) {
        self.onSave = onSave

        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 160),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        w.title = "IPWatcher — Настройки"
        w.center()
        super.init(window: w)
        w.delegate = self

        buildUI(current: current)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildUI(current: Settings?) {
        guard let view = window?.contentView else { return }

        func label(_ text: String) -> NSTextField {
            let f = NSTextField(labelWithString: text)
            f.alignment = .right
            return f
        }

        ipField.placeholderString = "например, 1.2.3.4"
        ipField.stringValue = current?.targetIP ?? ""

        intervalField.placeholderString = "60"
        intervalField.stringValue = current.map { String($0.intervalSeconds) } ?? "60"

        let ipLabel = label("Целевой IP:")
        let intervalLabel = label("Интервал (сек):")

        let saveBtn = NSButton(title: "Сохранить", target: self, action: #selector(save))
        saveBtn.bezelStyle = .rounded
        saveBtn.keyEquivalent = "\r"

        for sub in [ipLabel, ipField, intervalLabel, intervalField, saveBtn] as [NSView] {
            sub.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sub)
        }

        NSLayoutConstraint.activate([
            ipLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ipLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            ipLabel.widthAnchor.constraint(equalToConstant: 110),

            ipField.leadingAnchor.constraint(equalTo: ipLabel.trailingAnchor, constant: 8),
            ipField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            ipField.centerYAnchor.constraint(equalTo: ipLabel.centerYAnchor),

            intervalLabel.leadingAnchor.constraint(equalTo: ipLabel.leadingAnchor),
            intervalLabel.topAnchor.constraint(equalTo: ipLabel.bottomAnchor, constant: 16),
            intervalLabel.widthAnchor.constraint(equalToConstant: 110),

            intervalField.leadingAnchor.constraint(equalTo: ipField.leadingAnchor),
            intervalField.widthAnchor.constraint(equalToConstant: 80),
            intervalField.centerYAnchor.constraint(equalTo: intervalLabel.centerYAnchor),

            saveBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
        ])
    }

    @objc private func save() {
        let ip = ipField.stringValue.trimmingCharacters(in: .whitespaces)
        let interval = Int(intervalField.stringValue) ?? Settings.defaultInterval
        guard !ip.isEmpty else {
            showAlert("Введите целевой IP-адрес")
            return
        }
        let s = Settings(targetIP: ip, intervalSeconds: max(10, interval))
        s.save()
        onSave(s)
        window?.close()
    }

    private func showAlert(_ msg: String) {
        let a = NSAlert()
        a.messageText = msg
        a.runModal()
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func show() {
        NSApp.setActivationPolicy(.regular)
        showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
