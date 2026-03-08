import Dispatch

public final class Loader: Component {
    public struct LoaderTheme: Sendable {
        public var spinner: AnsiStyling.Style
        public var message: AnsiStyling.Style

        public init(spinner: @escaping AnsiStyling.Style, message: @escaping AnsiStyling.Style) {
            self.spinner = spinner
            self.message = message
        }

        public static let `default` = LoaderTheme(
            spinner: AnsiStyling.color(36),
            message: { AnsiStyling.dim($0) })
    }

    private static let frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

    // private let renderTarget: RenderTarget
    private var theme: LoaderTheme
    private var frameIndex = 0
    // Timer runs on the main queue; frames are cheap so main-queue delivery is fine.
    private var timer: DispatchSourceTimer?
    private let textComponent = Text(text: "", paddingX: 1, paddingY: 0)

    public private(set) var message: String {
        didSet { self.updateText() }
    }

    public init(message: String = "Loading...", autoStart: Bool = true, theme: LoaderTheme = .default) {
        self.message = message
        self.theme = theme
        super.init()
        self.updateText()
        if autoStart { self.start() }
    }

    deinit {
        stop()
    }

    public func start() {
        guard timer == nil else { return }
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: .milliseconds(80))
        timer.setEventHandler { [weak self] in
            self?.tick()
        }
        timer.resume()
        self.timer = timer
    }

    public func stop() {
        self.timer?.cancel()
        self.timer = nil
    }

    public func setMessage(_ newMessage: String) {
        self.message = newMessage
    }

    public override func render(width: Int) -> [String] {
        [""] + self.textComponent.render(width: width)
    }

    func tick() {
        self.frameIndex = (self.frameIndex + 1) % Loader.frames.count
        self.updateText()
        self.notifyRender()
    }

    private func notifyRender() {
        // Task { [weak _tui] in await _tui?.requestRender() }
        let root = self.root as? TUI
        Task { [root] in
           await root?.requestRender()
        }
    }

    private func updateText() {
        let frame = Loader.frames[self.frameIndex]
        self.textComponent.text = "\(self.theme.spinner(frame)) \(self.theme.message(self.message))"
    }

    public override func invalidate() {
        self.textComponent.invalidate()
    }

    public override func apply(theme: ThemePalette) {
        self.theme = theme.loader
        self.textComponent.invalidate()
    }
}
