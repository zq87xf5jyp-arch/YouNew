import SwiftUI

#if DEBUG
struct TapHighlighter: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func tapHighlighterForDebugAudit() -> some View {
        modifier(TapHighlighter())
    }
}
#endif
