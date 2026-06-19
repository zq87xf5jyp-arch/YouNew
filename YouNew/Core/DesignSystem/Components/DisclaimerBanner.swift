import SwiftUI

struct DisclaimerBanner: View {
    let text: String
    var tone: Color = AppColors.dutchOrange

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.xSmall) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(tone)
            Text(text)
                .font(AppTypography.footnote)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.xSmall)
        .background(AppColors.textSecondary.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))
    }
}
