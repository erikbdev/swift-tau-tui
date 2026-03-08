/// Basic container used by the `TUI` runtime. Components are stored in-order
/// and rendered sequentially; consumers can subclass to add layout logic.
open class Component {
    public private(set) var children: [Component] = []
    public fileprivate(set) weak var parent: Component?

    public var root: Component { parent ?? self }

    public init(children: [Component] = []) {
        for c in children {
           self.addChild(c) 
        }
    }

    open func addChild(_ child: Component) {
        child.parent = self
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

    open func apply(theme: ThemePalette) {
        self.children.forEach { $0.apply(theme: theme) }
    }

    open func render(width: Int) -> [String] {
        self.children.flatMap { $0.render(width: width) }
    }

    open func handle(input: TerminalInput) {
        /* Default: ignore input */
    }
}
