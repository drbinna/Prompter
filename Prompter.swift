// Prompter: a floating teleprompter that screen recordings can't see.
//
// The window sets `sharingType = .none`, which tells macOS to leave it out of
// screen captures (QuickTime, OBS, Screen Studio, Loom, Cmd-Shift-5). You see
// it; the recording doesn't.
//
// Build:  ./build.sh          (needs Xcode Command Line Tools: xcode-select --install)
// Run:    ./prompter scripts/insertion-sort.md
//
// Keys (click the prompter first so it has focus):
//   space      play / pause auto-scroll
//   ↑ ↓        nudge the text up or down
//   [ ]        slower / faster
//   - =        smaller / larger text
//   , .        more / less transparent
//   r          back to the top
//   q          quit
//   drag       move the window; drag an edge to resize
//   wheel      scroll by hand (works even when the browser has focus)

import AppKit

final class PrompterWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

final class Prompter: NSObject, NSApplicationDelegate {
    var window: PrompterWindow!
    var scroll: NSScrollView!
    var text: NSTextView!
    var hud: NSTextField!
    var timer: Timer?
    var playing = false
    var speed: Double = 28          // points per second
    var fontSize: CGFloat = 26
    var source = ""

    func applicationDidFinishLaunching(_ note: Notification) {
        let args = CommandLine.arguments
        let path = args.count > 1 ? args[1] : NSString(string: "~/Desktop/script.md").expandingTildeInPath
        source = (try? String(contentsOfFile: path, encoding: .utf8))
            ?? "Could not read \(path)\n\nRun it as:  ./prompter path/to/script.md"

        let screen = (NSScreen.main ?? NSScreen.screens[0]).visibleFrame
        let frame = NSRect(x: screen.minX + 24, y: screen.maxY - 440, width: 520, height: 400)
        window = PrompterWindow(contentRect: frame, styleMask: [.borderless, .resizable],
                                backing: .buffered, defer: false)
        window.sharingType = .none                       // invisible to screen capture
        window.level = .floating                         // above the browser
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        window.isOpaque = false
        window.backgroundColor = NSColor(calibratedWhite: 0.07, alpha: 0.86)
        window.hasShadow = false
        window.isMovableByWindowBackground = true
        window.minSize = NSSize(width: 280, height: 160)
        window.title = "Prompter"

        let content = NSView(frame: window.contentView!.bounds)
        content.wantsLayer = true
        content.layer?.cornerRadius = 12
        content.layer?.masksToBounds = true
        content.autoresizingMask = [.width, .height]
        window.contentView = content

        scroll = NSScrollView(frame: NSRect(x: 0, y: 28, width: content.bounds.width, height: content.bounds.height - 28))
        scroll.autoresizingMask = [.width, .height]
        scroll.hasVerticalScroller = false
        scroll.drawsBackground = false
        scroll.verticalScrollElasticity = .none

        text = NSTextView(frame: scroll.bounds)
        text.isEditable = false
        text.isSelectable = false
        text.drawsBackground = false
        text.textContainerInset = NSSize(width: 18, height: 24)
        text.isVerticallyResizable = true
        text.isHorizontallyResizable = false
        text.autoresizingMask = [.width]
        text.textContainer?.widthTracksTextView = true
        scroll.documentView = text
        content.addSubview(scroll)

        hud = NSTextField(labelWithString: "")
        hud.frame = NSRect(x: 14, y: 6, width: content.bounds.width - 28, height: 16)
        hud.autoresizingMask = [.width]
        hud.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        hud.textColor = NSColor(calibratedWhite: 1, alpha: 0.45)
        hud.lineBreakMode = .byTruncatingTail
        content.addSubview(hud)

        render()
        updateHud()

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] e in
            guard let self = self else { return e }
            return self.handle(key: e) ? nil : e
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(timer!, forMode: .common)

        NSApp.setActivationPolicy(.accessory)            // no Dock icon, no menu bar entry
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    // MARK: - Scrolling

    func tick() {
        guard playing else { return }
        scroll(by: speed / 60.0)
    }

    func scroll(by dy: CGFloat) {
        let clip = scroll.contentView
        var origin = clip.bounds.origin
        let maxY = max(0, text.frame.height - clip.bounds.height)
        origin.y = min(max(0, origin.y + dy), maxY)
        clip.setBoundsOrigin(origin)
        scroll.reflectScrolledClipView(clip)
        if origin.y >= maxY && playing { playing = false; updateHud() }
    }

    func handle(key e: NSEvent) -> Bool {
        guard window.isKeyWindow else { return false }
        switch e.charactersIgnoringModifiers ?? "" {
        case " ": playing.toggle()
        case "[": speed = max(6, speed - 4)
        case "]": speed = min(120, speed + 4)
        case "-", "_": fontSize = max(14, fontSize - 2); render()
        case "=", "+": fontSize = min(60, fontSize + 2); render()
        case ",": window.alphaValue = max(0.25, window.alphaValue - 0.1)
        case ".": window.alphaValue = min(1.0, window.alphaValue + 0.1)
        case "r": scroll.contentView.setBoundsOrigin(.zero); scroll.reflectScrolledClipView(scroll.contentView)
        case "q": NSApp.terminate(nil)
        default:
            switch e.keyCode {
            case 126: scroll(by: -40)   // up arrow
            case 125: scroll(by: 40)    // down arrow
            default: return false
            }
        }
        updateHud()
        return true
    }

    func updateHud() {
        let state = playing ? "▶ playing" : "⏸ paused"
        hud.stringValue = "\(state)  \(Int(speed)) pt/s   space play/pause · ↑↓ nudge · [ ] speed · - = size · , . fade · r top · q quit"
    }

    // MARK: - Rendering the script (a small subset of Markdown)

    func render() {
        let out = NSMutableAttributedString()
        let body = NSFont.systemFont(ofSize: fontSize)
        let bold = NSFont.boldSystemFont(ofSize: fontSize)
        let mono = NSFont.monospacedSystemFont(ofSize: fontSize * 0.92, weight: .medium)
        let white = NSColor(calibratedWhite: 0.96, alpha: 1)
        let dim = NSColor(calibratedWhite: 0.6, alpha: 1)
        let gold = NSColor(calibratedRed: 0.95, green: 0.78, blue: 0.4, alpha: 1)
        let code = NSColor(calibratedRed: 0.55, green: 0.88, blue: 0.78, alpha: 1)

        func para(spacingBefore: CGFloat = 0, spacingAfter: CGFloat = 10, indent: CGFloat = 0) -> NSParagraphStyle {
            let p = NSMutableParagraphStyle()
            p.paragraphSpacingBefore = spacingBefore
            p.paragraphSpacing = spacingAfter
            p.lineSpacing = fontSize * 0.28
            p.headIndent = indent
            p.firstLineHeadIndent = indent
            return p
        }

        // inline: **bold** and `code`
        func inline(_ s: String, baseFont: NSFont, color: NSColor, style: NSParagraphStyle) -> NSAttributedString {
            let r = NSMutableAttributedString()
            var rest = Substring(s)
            while !rest.isEmpty {
                if rest.hasPrefix("**"), let end = rest.dropFirst(2).range(of: "**") {
                    let inner = String(rest[rest.index(rest.startIndex, offsetBy: 2)..<end.lowerBound])
                    r.append(NSAttributedString(string: inner, attributes: [.font: bold, .foregroundColor: color, .paragraphStyle: style]))
                    rest = rest[end.upperBound...]
                } else if rest.hasPrefix("`"), let end = rest.dropFirst().firstIndex(of: "`") {
                    let inner = String(rest[rest.index(after: rest.startIndex)..<end])
                    r.append(NSAttributedString(string: inner, attributes: [.font: mono, .foregroundColor: code, .paragraphStyle: style]))
                    rest = rest[rest.index(after: end)...]
                } else {
                    let next = rest.dropFirst().firstIndex(where: { $0 == "*" || $0 == "`" }) ?? rest.endIndex
                    r.append(NSAttributedString(string: String(rest[rest.startIndex..<next]), attributes: [.font: baseFont, .foregroundColor: color, .paragraphStyle: style]))
                    rest = rest[next...]
                }
            }
            return r
        }

        var inFence = false
        for rawLine in source.components(separatedBy: "\n") {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("```") { inFence.toggle(); if !inFence { out.append(NSAttributedString(string: "\n")) }; continue }
            if inFence {
                out.append(NSAttributedString(string: rawLine + "\n", attributes: [.font: mono, .foregroundColor: code, .paragraphStyle: para(spacingAfter: 0, indent: 16)]))
                continue
            }
            if line.isEmpty { continue }
            if line.hasPrefix("# ") {
                out.append(NSAttributedString(string: String(line.dropFirst(2)) + "\n", attributes: [.font: NSFont.boldSystemFont(ofSize: fontSize * 1.3), .foregroundColor: gold, .paragraphStyle: para(spacingAfter: 18)]))
            } else if line.hasPrefix("## ") {
                out.append(NSAttributedString(string: String(line.dropFirst(3)).uppercased() + "\n", attributes: [.font: NSFont.boldSystemFont(ofSize: fontSize * 0.8), .foregroundColor: gold, .paragraphStyle: para(spacingBefore: 26, spacingAfter: 12)]))
            } else if line.hasPrefix("### ") {
                out.append(NSAttributedString(string: String(line.dropFirst(4)) + "\n", attributes: [.font: NSFont.boldSystemFont(ofSize: fontSize * 1.05), .foregroundColor: white, .paragraphStyle: para(spacingBefore: 18, spacingAfter: 8)]))
            } else if line.hasPrefix("**Type:**") || line.hasPrefix("**Do:**") {
                let label = line.hasPrefix("**Type:**") ? "TYPE  " : "DO  "
                let rest = String(line.drop(while: { $0 != ":" }).dropFirst(3)).trimmingCharacters(in: .whitespaces)
                let a = NSMutableAttributedString(string: label, attributes: [.font: NSFont.boldSystemFont(ofSize: fontSize * 0.7), .foregroundColor: gold, .paragraphStyle: para(spacingAfter: 8)])
                a.append(inline(rest, baseFont: mono, color: code, style: para(spacingAfter: 8)))
                a.append(NSAttributedString(string: "\n"))
                out.append(a)
            } else if line.hasPrefix("**Say") {
                // "**Say:**" or "**Say (when it finishes):**"
                guard let close = line.range(of: ":**") else { continue }
                let rest = String(line[close.upperBound...]).trimmingCharacters(in: .whitespaces)
                let a = NSMutableAttributedString(attributedString: inline(rest, baseFont: body, color: white, style: para(spacingAfter: 14)))
                a.append(NSAttributedString(string: "\n"))
                out.append(a)
            } else if line.hasPrefix("- ") {
                let a = NSMutableAttributedString(string: "•  ", attributes: [.font: body, .foregroundColor: dim, .paragraphStyle: para(spacingAfter: 6, indent: 0)])
                a.append(inline(String(line.dropFirst(2)), baseFont: body, color: white, style: para(spacingAfter: 6)))
                a.append(NSAttributedString(string: "\n"))
                out.append(a)
            } else {
                let a = NSMutableAttributedString(attributedString: inline(line, baseFont: body, color: dim, style: para(spacingAfter: 10)))
                a.append(NSAttributedString(string: "\n"))
                out.append(a)
            }
        }
        // room to scroll the last line up to the top
        out.append(NSAttributedString(string: String(repeating: "\n", count: 14), attributes: [.font: body]))
        text.textStorage?.setAttributedString(out)
        text.sizeToFit()
    }
}

let app = NSApplication.shared
let delegate = Prompter()
app.delegate = delegate
app.run()
