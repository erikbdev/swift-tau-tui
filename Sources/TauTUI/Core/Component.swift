/// Basic container used by the `TUI` runtime. Components are stored in-order
/// and rendered sequentially; consumers can subclass to add layout logic.
open class Component {
    public private(set) var children: [Component] = []

    // TODO: refer to renderer to request new renders if component
    // changes
    // weak var renderer: any Renderer

    public init(children: [Component] = []) {
        self.children = children
    }

    open func addChild(_ child: Component) {
        self.children.append(child)
    }

    open func removeChild(_ child: Component) {
        guard let index = children.firstIndex(where: { $0 === child }) else {
            return
        }
        self.children.remove(at: index)
    }

    open func clear() {
        self.children.removeAll()
    }

    open func invalidate() {
        self.children.forEach { $0.invalidate() }
    }

    @MainActor open func apply(theme: ThemePalette) {
        self.children.forEach { $0.apply(theme: theme) }
    }

    open func render(width: Int) -> [String] {
        self.children.flatMap { $0.render(width: width) }
    }

    open func handle(input: TerminalInput) {
        /* Default: ignore input */
    }
}
