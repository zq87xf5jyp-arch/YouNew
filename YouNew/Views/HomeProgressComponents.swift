import SwiftUI

// MARK: - Dutch Phrase of the Day

struct HomeDutchPhraseCard: View {
    let language: AppLanguage

    private var phrase: DutchDailyPhrase {
        Self.selectedPhrase
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                LinearGradient(
                    colors: [AppColors.dutchOrange, AppColors.dutchOrange.opacity(0.72)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Text("🇳🇱")
                    .font(.system(size: 22))
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: AppColors.dutchOrange.opacity(0.32), radius: 10, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.dutchOrange)
                    .textCase(.uppercase)
                    .tracking(1.0)

                TypewriterText(fullText: phrase.dutch, speed: 0.05)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
                    .fixedSize(horizontal: false, vertical: true)

                Text(phrase.translation(language))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(GlassPanelBackground(accent: AppColors.dutchOrange, cornerRadius: 22))
        .accessibilityIdentifier("home.dutch.phrase.card")
    }

    private var title: String {
        switch language {
        case .russian: return "Фраза дня"
        case .dutch: return "Zin van de dag"
        case .english: return "Phrase of the Day"
        }
    }

    private static let phrases: [DutchDailyPhrase] = [
        DutchDailyPhrase(dutch: "Goedemorgen!", ru: "Доброе утро!", en: "Good morning!", nl: "Goedemorgen!"),
        DutchDailyPhrase(dutch: "Hoe gaat het?", ru: "Как дела?", en: "How are you?", nl: "Hoe gaat het?"),
        DutchDailyPhrase(dutch: "Dank je wel!", ru: "Большое спасибо!", en: "Thank you very much!", nl: "Dank je wel!"),
        DutchDailyPhrase(dutch: "Tot ziens!", ru: "До свидания!", en: "Goodbye!", nl: "Tot ziens!"),
        DutchDailyPhrase(dutch: "Mag ik u helpen?", ru: "Могу ли я вам помочь?", en: "Can I help you?", nl: "Mag ik u helpen?"),
        DutchDailyPhrase(dutch: "Waar is het station?", ru: "Где находится вокзал?", en: "Where is the station?", nl: "Waar is het station?"),
        DutchDailyPhrase(dutch: "Ik woon in Nederland.", ru: "Я живу в Нидерландах.", en: "I live in the Netherlands.", nl: "Ik woon in Nederland."),
        DutchDailyPhrase(dutch: "Spreekt u Engels?", ru: "Вы говорите по-английски?", en: "Do you speak English?", nl: "Spreekt u Engels?"),
        DutchDailyPhrase(dutch: "Alsjeblieft!", ru: "Пожалуйста!", en: "Please / Here you go!", nl: "Alsjeblieft!"),
        DutchDailyPhrase(dutch: "Ik begrijp het niet.", ru: "Я не понимаю.", en: "I don't understand.", nl: "Ik begrijp het niet."),
        DutchDailyPhrase(dutch: "Welkom in Nederland!", ru: "Добро пожаловать в Нидерланды!", en: "Welcome to the Netherlands!", nl: "Welkom in Nederland!"),
        DutchDailyPhrase(dutch: "Gezellig!", ru: "Уютно и хорошо!", en: "Cozy / Convivial!", nl: "Gezellig!"),
        DutchDailyPhrase(dutch: "Fijne dag!", ru: "Хорошего дня!", en: "Have a nice day!", nl: "Fijne dag!"),
        DutchDailyPhrase(dutch: "Ik ben nieuwkomer.", ru: "Я новоприбывший.", en: "I am a newcomer.", nl: "Ik ben nieuwkomer.")
    ]

    private static let selectedPhrase: DutchDailyPhrase = {
        let dayIndex = (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1) - 1
        return phrases[dayIndex % phrases.count]
    }()
}

private struct DutchDailyPhrase {
    let dutch: String
    let ru: String
    let en: String
    let nl: String

    func translation(_ lang: AppLanguage) -> String {
        switch lang {
        case .russian: return ru
        case .english: return en
        case .dutch: return nl
        }
    }
}

// MARK: - Journey Progress

struct HomeJourneyProgressCard: View {
    let title: String
    let nextStepText: String
    let completedStepsText: String
    let completedCount: Int
    let totalCount: Int
    let progress: Double
    let milestoneTitles: [String]
    let completedMilestones: Int

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        NavigationLink(value: AppDestination.checklistList) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 34 : 30, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)

                    Text(nextStepText)
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 19 : 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ProgressView(value: progress)
                    .tint(AppColors.cyanGlow)

                HomeJourneyMilestones(
                    titles: milestoneTitles,
                    completedMilestones: completedMilestones
                )

                HStack {
                    Text(completedStepsText)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.82)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 10)

                    Text("\(completedCount) / \(totalCount)")
                        .font(.system(.headline, design: .rounded).weight(.black))
                        .foregroundStyle(AppColors.cyanGlow)
                }
            }
            .padding(22)
            .background(GlassPanelBackground(accent: AppColors.cyanGlow, cornerRadius: 34))
        }
        .buttonStyle(NLTileButtonStyle())
    }
}

private struct HomeJourneyMilestones: View {
    let titles: [String]
    let completedMilestones: Int

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
                    milestone(title: title, index: index, isComplete: index < completedMilestones)
                }
            }
            .padding(.vertical, 2)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
    }

    private func milestone(title: String, index: Int, isComplete: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isComplete ? AppColors.cyanGlow.opacity(0.92) : Color.white.opacity(0.08))
                    .frame(width: 34, height: 34)

                Image(systemName: isComplete ? "checkmark" : "\(index + 1)")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(isComplete ? AppColors.navyDeep : AppColors.textSecondary)
            }

            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(isComplete ? AppColors.textPrimary : AppColors.textTertiary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: dynamicTypeSize.isAccessibilitySize ? 84 : 72, alignment: .top)
    }
}
