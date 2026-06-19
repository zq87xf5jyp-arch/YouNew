import SwiftUI

struct BreadcrumbTrail: View {
    let segments: [String]

    var body: some View {
        if !segments.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.xSmall) {
                    ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                        Text(segment)
                            .font(AppTypography.caption)
                            .foregroundStyle(index == segments.count - 1 ? AppColors.textPrimary : AppColors.textSecondary)
                        if index < segments.count - 1 {
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.xSmall)
                .padding(.vertical, AppSpacing.xSmall)
                .background(AppColors.chipBackground)
                .clipShape(Capsule())
            }
        }
    }
}
