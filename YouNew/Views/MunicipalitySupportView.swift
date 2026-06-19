import SwiftUI

struct MunicipalitySupportView: View {
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }

    private var selectedMunicipality: MunicipalityProfile? {
        MockExpansionData.municipalities.first(where: { $0.name == appState.userProfile.municipality })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                SectionHeader(
                    title: L10n.t("municipality.support_title", lang),
                    subtitle: L10n.t("municipality.support_subtitle", lang)
                )

                Picker(L10n.t("municipality.picker", lang), selection: Binding(
                    get: { appState.userProfile.municipality },
                    set: { appState.userProfile.municipality = $0 }
                )) {
                    ForEach(MockExpansionData.municipalities) { municipality in
                        Text(municipality.name).tag(municipality.name)
                    }
                }
                .pickerStyle(.menu)
                .appCardStyle()

                if let selectedMunicipality {
                    InstitutionCard(institution: Institution(
                        name: selectedMunicipality.name,
                        shortExplanationByLanguage: [
                            .english: "Municipality profile",
                            .dutch:   "Gemeenteprofiel",
                            .russian: "Профиль муниципалитета"
                        ],
                        usageByLanguage: [
                            .english: selectedMunicipality.registrationInfo,
                            .dutch:   selectedMunicipality.registrationInfo,
                            .russian: selectedMunicipality.registrationInfo
                        ],
                        whenToUseByLanguage: [
                            .english: "Use for local registration, appointments, and practical local services.",
                            .dutch:   "Gebruik voor lokale registratie, afspraken en praktische lokale diensten.",
                            .russian: "Используйте для регистрации, записи и локальных городских сервисов."
                        ],
                        commonConfusionByLanguage: [
                            .english: "Local requirements may differ from other cities.",
                            .dutch:   "Lokale vereisten kunnen afwijken van andere steden.",
                            .russian: "Требования могут отличаться от других городов."
                        ],
                        officialWebsiteURL: selectedMunicipality.website,
                        warningByLanguage: [
                            .english: "Always verify information directly.",
                            .dutch:   "Verifieer informatie altijd rechtstreeks.",
                            .russian: "Всегда проверяйте информацию в официальных источниках."
                        ]
                    ))

                    InfoCard(title: L10n.t("municipality.appointment_page", lang), subtitle: selectedMunicipality.name, detail: selectedMunicipality.appointmentPage.absoluteString, icon: "calendar.badge.plus")
                    InfoCard(title: L10n.t("municipality.waste_guide", lang), subtitle: L10n.t("municipality.local_living", lang), detail: selectedMunicipality.wasteGuide, icon: "trash")
                    InfoCard(title: L10n.t("municipality.parking_basics", lang), subtitle: L10n.t("municipality.local_transport", lang), detail: selectedMunicipality.parkingBasics, icon: "car")
                    InfoCard(title: L10n.t("municipality.emergency_contacts", lang), subtitle: L10n.t("municipality.local_safety", lang), detail: selectedMunicipality.emergencyContact, icon: "phone")
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.medium)
            .tabBarScrollReserve()
        }
        .appSceneBackground()
        .navigationTitle(L10n.t("municipality.picker", lang))
    }
}
