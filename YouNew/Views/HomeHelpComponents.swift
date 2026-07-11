import SwiftUI

// MARK: - Help Topics

struct HomeHelpTopicsSection: View {
    let title: String
    let viewAllLabel: String
    let showAllCategoriesLink: Bool
    let topics: [HomeHelpTopic]
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            topicsRow
        }
        .homeReadableBand()
        .padding(.top, 10)
        .padding(.bottom, 34)
        .background(.clear)
    }

    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .lastTextBaseline) {
                titleText
                Spacer(minLength: 12)
                viewAllLink
            }

            VStack(alignment: .leading, spacing: 8) {
                titleText
                viewAllLink
            }
        }
    }

    private var titleText: some View {
        Text(title)
            .font(.system(size: 20, weight: .semibold, design: .default))
            .foregroundStyle(AppColors.textPrimary)
            .lineLimit(2)
            .minimumScaleFactor(0.84)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var viewAllLink: some View {
        if showAllCategoriesLink {
            NavigationLink(value: AppDestination.categoriesHub) {
                Label(viewAllLabel, systemImage: "square.grid.2x2")
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .foregroundStyle(AppColors.dutchOrange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
        }
    }

    private var topicsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(topics) { topic in
                    NavigationLink(value: topic.destination) {
                        HelpTopicIcon(topic: topic, language: language)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, 2)
        }
        .padding(.horizontal, -AppSpacing.screenHorizontal)
        .clipped()
    }
}
