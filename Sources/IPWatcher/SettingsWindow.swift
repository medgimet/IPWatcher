import AppKit

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private var ipField = NSTextField()
    private var intervalField = NSTextField()
    private var hideIPCheckbox = NSButton(checkboxWithTitle: "", target: nil, action: nil)
    private var languagePopup = NSPopUpButton()
    private var ipLabel = NSTextField()
    private var intervalLabel = NSTextField()
    private var languageLabel = NSTextField()
    private var hideIPLabel = NSTextField()
    private var saveBtn = NSButton()
    private var onSave: (Settings) -> Void

    init(current: Settings?, onSave: @escaping (Settings) -> Void) {
        self.onSave = onSave
        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 230),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        w.center()
        w.isReleasedWhenClosed = false
        super.init(window: w)
        w.delegate = self
        buildUI(current: current)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func makeLabel(_ text: String) -> NSTextField {
        let f = NSTextField(labelWithString: text)
        f.alignment = .right
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }

    private func buildUI(current: Settings?) {
        guard let view = window?.contentView else { return }

        ipLabel = makeLabel(L10n.t(.targetIP))
        intervalLabel = makeLabel(L10n.t(.intervalSeconds))
        languageLabel = makeLabel(L10n.t(.language))

        ipField.placeholderString = "e.g. 1.2.3.4"
        ipField.stringValue = current?.targetIP ?? ""
        ipField.translatesAutoresizingMaskIntoConstraints = false

        intervalField.placeholderString = "60"
        intervalField.stringValue = current.map { String($0.intervalSeconds) } ?? "60"
        intervalField.translatesAutoresizingMaskIntoConstraints = false

        languagePopup.removeAllItems()
        languagePopup.addItems(withTitles: AppLanguage.allCases.map { $0.displayName })
        if let idx = AppLanguage.allCases.firstIndex(of: current?.language ?? .en) {
            languagePopup.selectItem(at: idx)
        }
        languagePopup.target = self
        languagePopup.action = #selector(languageChanged)
        languagePopup.translatesAutoresizingMaskIntoConstraints = false

        hideIPCheckbox.title = L10n.t(.hideIP)
        hideIPCheckbox.setButtonType(.switch)
        hideIPCheckbox.state = (current?.hideIP == true) ? .on : .off
        hideIPCheckbox.translatesAutoresizingMaskIntoConstraints = false

        saveBtn = NSButton(title: L10n.t(.save), target: self, action: #selector(save))
        saveBtn.bezelStyle = .rounded
        saveBtn.keyEquivalent = "\r"
        saveBtn.translatesAutoresizingMaskIntoConstraints = false

        let subviews: [NSView] = [
            ipLabel, ipField,
            intervalLabel, intervalField,
            languageLabel, languagePopup,
            hideIPCheckbox,
            saveBtn
        ]
        subviews.forEach { view.addSubview($0) }

        let labelWidth: CGFloat = 110

        NSLayoutConstraint.activate([
            ipLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ipLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            ipLabel.widthAnchor.constraint(equalToConstant: labelWidth),

            ipField.leadingAnchor.constraint(equalTo: ipLabel.trailingAnchor, constant: 8),
            ipField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            ipField.centerYAnchor.constraint(equalTo: ipLabel.centerYAnchor),

            intervalLabel.leadingAnchor.constraint(equalTo: ipLabel.leadingAnchor),
            intervalLabel.topAnchor.constraint(equalTo: ipLabel.bottomAnchor, constant: 16),
            intervalLabel.widthAnchor.constraint(equalToConstant: labelWidth),

            intervalField.leadingAnchor.constraint(equalTo: ipField.leadingAnchor),
            intervalField.widthAnchor.constraint(equalToConstant: 80),
            intervalField.centerYAnchor.constraint(equalTo: intervalLabel.centerYAnchor),

            languageLabel.leadingAnchor.constraint(equalTo: ipLabel.leadingAnchor),
            languageLabel.topAnchor.constraint(equalTo: intervalLabel.bottomAnchor, constant: 16),
            languageLabel.widthAnchor.constraint(equalToConstant: labelWidth),

            languagePopup.leadingAnchor.constraint(equalTo: ipField.leadingAnchor),
            languagePopup.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            languagePopup.centerYAnchor.constraint(equalTo: languageLabel.centerYAnchor),

            hideIPCheckbox.leadingAnchor.constraint(equalTo: ipField.leadingAnchor),
            hideIPCheckbox.topAnchor.constraint(equalTo: languageLabel.bottomAnchor, constant: 16),

            saveBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
        ])

        updateTitles()
    }

    private func updateTitles() {
        window?.title = L10n.t(.settingsTitle)
        ipLabel.stringValue = L10n.t(.targetIP)
        intervalLabel.stringValue = L10n.t(.intervalSeconds)
        languageLabel.stringValue = L10n.t(.language)
        hideIPCheckbox.title = L10n.t(.hideIP)
        saveBtn.title = L10n.t(.save)
    }

    @objc private func languageChanged() {
        let idx = languagePopup.indexOfSelectedItem
        guard idx >= 0 else { return }
        L10n.current = AppLanguage.allCases[idx]
        updateTitles()
    }

    @objc private func save() {
        let ip = ipField.stringValue.trimmingCharacters(in: .whitespaces)
        guard !ip.isEmpty else {
            let a = NSAlert()
            a.messageText = L10n.t(.enterTargetIP)
            if let w = window { a.beginSheetModal(for: w) }
            return
        }
        let idx = max(0, languagePopup.indexOfSelectedItem)
        let lang = AppLanguage.allCases[idx]
        L10n.current = lang
        let s = Settings(
            targetIP: ip,
            intervalSeconds: max(10, Int(intervalField.stringValue) ?? Settings.defaultInterval),
            hideIP: hideIPCheckbox.state == .on,
            language: lang
        )
        s.save()
        onSave(s)
        window?.orderOut(nil)
        window?.close()
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func show() {
        NSApp.setActivationPolicy(.regular)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        window?.makeFirstResponder(ipField)
    }
}
