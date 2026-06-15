import AppKit

func makeFlagImage(flag: String, mismatch: Bool) -> NSImage {
    let font = NSFont.systemFont(ofSize: 14)
    let attrs: [NSAttributedString.Key: Any] = [.font: font]
    let str = NSAttributedString(string: flag, attributes: attrs)

    // Measure actual glyph bounds (tighter than .size())
    let line = CTLineCreateWithAttributedString(str)
    var ascent: CGFloat = 0
    var descent: CGFloat = 0
    var leading: CGFloat = 0
    let width = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
    let height = ascent + descent

    let pad: CGFloat = mismatch ? 1.5 : 0
    let imgSize = NSSize(width: width + pad * 2, height: height + pad * 2)
    let image = NSImage(size: imgSize)

    image.lockFocus()
    defer { image.unlockFocus() }

    str.draw(at: NSPoint(x: pad, y: pad + descent - descent)) // baseline offset

    if mismatch {
        let borderRect = NSRect(x: 0.75, y: 0.75, width: imgSize.width - 1.5, height: imgSize.height - 1.5)
        let path = NSBezierPath(roundedRect: borderRect, xRadius: 2.5, yRadius: 2.5)
        path.lineWidth = 1.5
        NSColor.systemRed.setStroke()
        path.stroke()
    }

    return image
}
