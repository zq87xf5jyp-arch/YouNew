import SwiftUI

extension View {
    func homeReadableBand(horizontalPadding: CGFloat = AppSpacing.screenHorizontal) -> some View {
        self
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: 760, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
