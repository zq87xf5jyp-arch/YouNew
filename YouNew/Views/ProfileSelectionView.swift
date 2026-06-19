import SwiftUI

struct ProfileSelectionView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                SectionHeader(title: L10n.t("profile.section.type", lang))

                ForEach(UserStatus.allCases) { status in
                    Button {
                        appState.selectedUserStatus = status
                        if let profileType = status.correspondingProfileType {
                            appState.userProfile.profileType = profileType
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(status.localized(lang))
                                    .font(AppTypography.bodyStrong)
                                    .foregroundStyle(AppColors.textPrimary)

                                Text(status.subtitle(lang))
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .lineLimit(2)
                            }

                            Spacer()

                            if appState.selectedUserStatus == status {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCardStyle()
                    }
                    .buttonStyle(.plain)
                }

                SectionHeader(title: L10n.t("profile.section.arrival", lang))
                Picker(L10n.t("profile.picker.arrival", lang), selection: $appState.userProfile.arrivalStatus) {
                    ForEach(ArrivalStatus.allCases) { status in
                        Text(status.localized(lang)).tag(status)
                    }
                }
                .pickerStyle(.menu)
                .appCardStyle()

                SectionHeader(title: L10n.t("profile.section.work_study", lang))
                Picker(L10n.t("profile.picker.work_status", lang), selection: $appState.userProfile.workStatus) {
                    ForEach(WorkStatus.allCases) { status in
                        Text(status.localized(lang)).tag(status)
                    }
                }
                .pickerStyle(.menu)
                .appCardStyle()

                Picker(L10n.t("profile.picker.student_status", lang), selection: $appState.userProfile.studentStatus) {
                    ForEach(StudentStatus.allCases) { status in
                        Text(status.localized(lang)).tag(status)
                    }
                }
                .pickerStyle(.menu)
                .appCardStyle()

                SectionHeader(title: L10n.t("profile.section.additional", lang))
                TextField(L10n.t("profile.field.nationality", lang), text: $appState.userProfile.nationalityPlaceholder)
                    .textFieldStyle(.plain)
                    .appInputStyle()
                TextField(L10n.t("profile.municipality", lang), text: $appState.userProfile.municipality)
                    .textFieldStyle(.plain)
                    .appInputStyle()
                TextField(L10n.t("profile.field.arrival_date", lang), text: $appState.userProfile.arrivalMonthYear)
                    .textFieldStyle(.plain)
                    .appInputStyle()
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("profile.title", lang))
    }
}
