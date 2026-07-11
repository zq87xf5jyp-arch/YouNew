import Foundation

enum ProfileType: String, CaseIterable, Identifiable, Codable {
    case worker
    case student
    case expat
    case refugeeStatusHolder
    case temporaryWorker

    var id: String { rawValue }

    var title: String { localized(.english) }

    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .worker:              return L10n.t("profile.type.worker", lang)
        case .student:             return L10n.t("profile.type.student", lang)
        case .expat:               return L10n.t("profile.type.expat", lang)
        case .refugeeStatusHolder: return L10n.t("profile.type.refugee", lang)
        case .temporaryWorker:     return L10n.t("profile.type.temporary_worker", lang)
        }
    }

    var icon: String {
        switch self {
        case .worker:              return "briefcase"
        case .student:             return "graduationcap"
        case .expat:               return "globe.europe.africa"
        case .refugeeStatusHolder: return "person.badge.shield.checkmark"
        case .temporaryWorker:     return "calendar.badge.clock"
        }
    }

    var onboardingSubtitle: String { onboardingSubtitleLocalized(.english) }

    func onboardingSubtitleLocalized(_ lang: AppLanguage) -> String {
        switch self {
        case .worker:              return L10n.t("profile.type.worker.subtitle", lang)
        case .student:             return L10n.t("profile.type.student.subtitle", lang)
        case .expat:               return L10n.t("profile.type.expat.subtitle", lang)
        case .refugeeStatusHolder: return L10n.t("profile.type.refugee.subtitle", lang)
        case .temporaryWorker:     return L10n.t("profile.type.temporary_worker.subtitle", lang)
        }
    }
}

enum ArrivalStatus: String, CaseIterable, Identifiable, Codable {
    case arrivingSoon
    case arrivedRecently
    case alreadyLivingInNL

    var id: String { rawValue }

    var title: String { localized(.english) }

    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .arrivingSoon:      return L10n.t("profile.arrival.arriving_soon", lang)
        case .arrivedRecently:   return L10n.t("profile.arrival.arrived_recently", lang)
        case .alreadyLivingInNL: return L10n.t("profile.arrival.already_living", lang)
        }
    }
}

enum TimeInNL: String, CaseIterable, Identifiable, Codable {
    case justArrived
    case lessThan3Months
    case threeToTwelveMonths
    case moreThanYear

    var id: String { rawValue }

    var title: String { localized(.english) }

    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .justArrived:         return L10n.t("profile.time_in_nl.just_arrived", lang)
        case .lessThan3Months:     return L10n.t("profile.time_in_nl.less_than_3_months", lang)
        case .threeToTwelveMonths: return L10n.t("profile.time_in_nl.three_to_twelve_months", lang)
        case .moreThanYear:        return L10n.t("profile.time_in_nl.more_than_year", lang)
        }
    }

    var icon: String {
        switch self {
        case .justArrived:         return "airplane.arrival"
        case .lessThan3Months:     return "calendar.badge.clock"
        case .threeToTwelveMonths: return "calendar"
        case .moreThanYear:        return "house"
        }
    }
}

enum LifePriority: String, CaseIterable, Identifiable, Codable {
    case documents
    case housing
    case work
    case taxes
    case healthInsurance
    case education
    case finesAndLetters
    case integration
    case studentFinance
    case studentTransport
    case studentJobs
    case language
    case cityLife
    case transport
    case pension
    case workerTraining
    case benefits
    case healthcare
    case workPermission
    case supportOrganizations
    case schools
    case childcare
    case childBenefits
    case activities
    case municipalServices
    case emergency
    case freeTime
    case businessRegistration
    case banking
    case permits
    case legalSafety
    case community
    case family

    var id: String { rawValue }

    var title: String { localized(.english) }

    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .documents:       return L10n.t("profile.priority.documents", lang)
        case .housing:         return L10n.t("profile.priority.housing", lang)
        case .work:            return L10n.t("profile.priority.work", lang)
        case .taxes:           return L10n.t("profile.priority.taxes", lang)
        case .healthInsurance: return L10n.t("profile.priority.health_insurance", lang)
        case .education:       return L10n.t("profile.priority.education", lang)
        case .finesAndLetters: return L10n.t("profile.priority.fines_and_letters", lang)
        case .integration:     return L10n.t("profile.priority.integration", lang)
        case .studentFinance:  return localized(lang, "Student finance", "Studiefinanciering", "Студенческие финансы")
        case .studentTransport: return localized(lang, "Student transport", "Studentenvervoer", "Студенческий транспорт")
        case .studentJobs:     return localized(lang, "Student jobs", "Studentenbanen", "Студенческая работа")
        case .language:        return localized(lang, "Language", "Taal", "Язык")
        case .cityLife:        return localized(lang, "City life", "Stadsleven", "Городская жизнь")
        case .transport:       return localized(lang, "Transport", "Vervoer", "Транспорт")
        case .pension:         return localized(lang, "Pension", "Pensioen", "Пенсия")
        case .workerTraining:  return localized(lang, "Worker training", "Werknemerstraining", "Обучение работников")
        case .benefits:        return localized(lang, "Benefits", "Uitkeringen", "Пособия")
        case .healthcare:      return localized(lang, "Healthcare", "Zorg", "Медицина")
        case .workPermission:  return localized(lang, "Work permission", "Werktoestemming", "Разрешение на работу")
        case .supportOrganizations: return localized(lang, "Support organizations", "Steunorganisaties", "Организации поддержки")
        case .schools:         return localized(lang, "Schools", "Scholen", "Школы")
        case .childcare:       return localized(lang, "Childcare", "Kinderopvang", "Детский сад")
        case .childBenefits:   return localized(lang, "Child benefits", "Kinderbijslag", "Детские пособия")
        case .activities:      return localized(lang, "Activities", "Activiteiten", "Активности")
        case .municipalServices: return localized(lang, "Municipal services", "Gemeentediensten", "Муниципальные услуги")
        case .emergency:       return localized(lang, "Emergency", "Noodhulp", "Экстренная помощь")
        case .freeTime:        return localized(lang, "Free time", "Vrije tijd", "Свободное время")
        case .businessRegistration: return localized(lang, "Business registration", "Bedrijfsregistratie", "Регистрация бизнеса")
        case .banking:         return localized(lang, "Banking", "Bankieren", "Банкинг")
        case .permits:         return localized(lang, "Permits", "Vergunningen", "Разрешения")
        case .legalSafety:     return localized(lang, "Legal safety", "Juridische veiligheid", "Правовая безопасность")
        case .community:       return localized(lang, "Community", "Gemeenschap", "Сообщество")
        case .family:          return localized(lang, "Family", "Gezin", "Семья")
        }
    }

    var icon: String {
        switch self {
        case .documents:       return "doc.text"
        case .housing:         return "house"
        case .work:            return "briefcase"
        case .taxes:           return "eurosign.circle"
        case .healthInsurance: return "cross.case"
        case .education:       return "book"
        case .finesAndLetters: return "envelope.badge.shield.half.filled"
        case .integration:     return "figure.2"
        case .studentFinance:  return "creditcard"
        case .studentTransport: return "tram"
        case .studentJobs:     return "briefcase"
        case .language:        return "text.book.closed"
        case .cityLife:        return "building.2"
        case .transport:       return "tram"
        case .pension:         return "person.crop.circle.badge.clock"
        case .workerTraining:  return "wrench.and.screwdriver"
        case .benefits:        return "banknote"
        case .healthcare:      return "cross.case"
        case .workPermission:  return "doc.badge.gearshape"
        case .supportOrganizations: return "person.3"
        case .schools:         return "graduationcap"
        case .childcare:       return "figure.and.child.holdinghands"
        case .childBenefits:   return "person.2"
        case .activities:      return "calendar"
        case .municipalServices: return "building.columns"
        case .emergency:       return "phone"
        case .freeTime:        return "sparkles"
        case .businessRegistration: return "building.columns"
        case .banking:         return "creditcard"
        case .permits:         return "doc.badge.gearshape"
        case .legalSafety:     return "shield"
        case .community:       return "heart"
        case .family:          return "person.2"
        }
    }

    private func localized(_ lang: AppLanguage, _ english: String, _ dutch: String, _ russian: String) -> String {
        switch lang {
        case .english: return english
        case .dutch: return dutch
        case .russian: return russian
        }
    }
}

enum WorkStatus: String, CaseIterable, Identifiable, Codable {
    case employed = "Employed"
    case seekingWork = "Seeking work"
    case notApplicable = "Not applicable"
    var id: String { rawValue }

    var title: String { localized(.english) }

    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .employed:      return L10n.t("profile.work_status.employed", lang)
        case .seekingWork:   return L10n.t("profile.work_status.seeking_work", lang)
        case .notApplicable: return L10n.t("profile.work_status.not_applicable", lang)
        }
    }
}

enum StudentStatus: String, CaseIterable, Identifiable, Codable {
    case enrolled = "Enrolled"
    case applying = "Applying"
    case notStudent = "Not a student"
    var id: String { rawValue }

    var title: String { localized(.english) }

    func localized(_ lang: AppLanguage) -> String {
        switch self {
        case .enrolled:    return L10n.t("profile.student_status.enrolled", lang)
        case .applying:    return L10n.t("profile.student_status.applying", lang)
        case .notStudent:  return L10n.t("profile.student_status.not_student", lang)
        }
    }
}

// MARK: - User Status (7 situational identities for Home screen)

enum UserStatus: String, CaseIterable, Identifiable, Sendable, Codable {
    case refugee
    case ukrainian
    case student
    case worker
    case expat
    case highlySkilledMigrant
    case euCitizen
    case family
    case tourist
    case entrepreneur
    case lgbtNewcomer

    var id: String { rawValue }

    private func titleKey() -> String {
        switch self {
        case .refugee:   return "status.refugee.title"
        case .ukrainian: return "status.ukrainian.title"
        case .student:   return "status.student.title"
        case .worker:    return "status.worker.title"
        case .expat:     return "status.expat.title"
        case .highlySkilledMigrant: return "Highly Skilled Migrant"
        case .euCitizen: return "EU Citizen"
        case .family:    return "status.family.title"
        case .tourist:   return "status.tourist.title"
        case .entrepreneur: return "Entrepreneur"
        case .lgbtNewcomer: return "LGBT Newcomer"
        }
    }

    private func subtitleKey() -> String {
        switch self {
        case .refugee:   return "status.refugee.subtitle"
        case .ukrainian: return "status.ukrainian.subtitle"
        case .student:   return "status.student.subtitle"
        case .worker:    return "status.worker.subtitle"
        case .expat:     return "status.expat.subtitle"
        case .highlySkilledMigrant: return "IND sponsor, BSN, DigiD, salary, tax, housing, insurance, and family relocation."
        case .euCitizen: return "Registration, BSN, DigiD, work rights, healthcare, housing, taxes, and municipality services."
        case .family:    return "status.family.subtitle"
        case .tourist:   return "status.tourist.subtitle"
        case .entrepreneur: return "KvK, business registration, VAT, taxes, banking, insurance, permits, and contracts."
        case .lgbtNewcomer: return "Safety, rights, healthcare, mental health, community, legal support, and housing safety."
        }
    }

    func localized(_ lang: AppLanguage) -> String {
        let key = titleKey()
        if key.hasPrefix("status.") { return L10n.t(key, lang) }
        return key
    }

    func subtitle(_ lang: AppLanguage) -> String {
        let key = subtitleKey()
        if key.hasPrefix("status.") { return L10n.t(key, lang) }
        return key
    }

    var icon: String {
        switch self {
        case .refugee:   return "person.badge.shield.checkmark"
        case .ukrainian: return "flag.fill"
        case .student:   return "graduationcap"
        case .worker:    return "briefcase"
        case .expat:     return "globe.europe.africa"
        case .highlySkilledMigrant: return "person.text.rectangle"
        case .euCitizen: return "eurosign.circle"
        case .family:    return "figure.2.and.child.holdinghands"
        case .tourist:   return "suitcase"
        case .entrepreneur: return "building.2.crop.circle"
        case .lgbtNewcomer: return "heart.circle"
        }
    }

    struct RecommendedStep: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let destination: AppDestination
        let isUrgent: Bool
    }

    @MainActor private static func step(_ titleKey: String, _ descKey: String, _ dest: AppDestination, urgent: Bool, lang: AppLanguage) -> RecommendedStep {
        RecommendedStep(
            title: L10n.t(titleKey, lang),
            description: L10n.t(descKey, lang),
            destination: dest,
            isUrgent: urgent
        )
    }

    @MainActor func recommendedSteps(_ lang: AppLanguage) -> [RecommendedStep] {
        let s = UserStatus.step
        switch self {
        case .refugee:
            return [
                s("status.step.gemeente_registration", "status.step.gemeente_registration.desc", .institutionsList,  true,  lang),
                s("status.step.digid",                 "status.step.digid.desc",                .beginnerGuidesList, true,  lang),
                s("status.step.health_insurance",      "status.step.health_insurance.desc",     .checklistList,      true,  lang),
                s("status.step.toeslagen",             "status.step.toeslagen.desc",            .beginnerGuidesList, false, lang),
                s("status.step.legal_help",            "status.step.legal_help.desc",           .institutionsList,   false, lang)
            ]
        case .ukrainian:
            return [
                s("status.step.gemeente_registration", "status.step.gemeente_registration.desc", .institutionsList,  true,  lang),
                s("status.step.document_check",        "status.step.document_check.desc",       .checklistList,      true,  lang),
                s("status.step.work_and_bsn",          "status.step.work_and_bsn.desc",         .beginnerGuidesList, true,  lang),
                s("status.step.housing",               "status.step.housing.desc",              .beginnerGuidesList, false, lang),
                s("status.step.health_insurance",      "status.step.health_insurance.desc",     .checklistList,      true,  lang)
            ]
        case .student:
            return [
                s("status.step.gemeente_registration", "status.step.gemeente_registration.desc", .institutionsList,  true,  lang),
                s("status.step.bsn",                   "status.step.bsn.desc",                  .beginnerGuidesList, true,  lang),
                s("status.step.duo",                   "status.step.duo.desc",                  .institutionsList,   false, lang),
                s("status.step.student_housing",       "status.step.student_housing.desc",      .beginnerGuidesList, false, lang),
                s("status.step.health_insurance",      "status.step.health_insurance.desc",     .checklistList,      true,  lang)
            ]
        case .worker:
            return [
                s("status.step.bsn",              "status.step.bsn.desc",               .beginnerGuidesList, true,  lang),
                s("status.step.digid",            "status.step.digid.desc",             .beginnerGuidesList, true,  lang),
                s("status.step.work_contract",    "status.step.work_contract.desc",     .beginnerGuidesList, true,  lang),
                s("status.step.taxes",            "status.step.taxes.desc",             .beginnerGuidesList, false, lang),
                s("status.step.health_insurance", "status.step.health_insurance.desc",  .checklistList,      true,  lang)
            ]
        case .expat:
            return [
                s("status.step.bsn",              "status.step.bsn.desc",              .beginnerGuidesList, true,  lang),
                s("status.step.digid",            "status.step.digid.desc",            .beginnerGuidesList, true,  lang),
                s("status.step.30percent_ruling", "status.step.30percent_ruling.desc", .beginnerGuidesList, false, lang),
                s("status.step.taxes",            "status.step.taxes.desc",            .beginnerGuidesList, false, lang),
                s("status.step.health_insurance", "status.step.health_insurance.desc", .checklistList,      true,  lang)
            ]
        case .highlySkilledMigrant:
            return [
                s("status.step.bsn",              "status.step.bsn.desc",              .beginnerGuidesList, true,  lang),
                s("status.step.digid",            "status.step.digid.desc",            .beginnerGuidesList, true,  lang),
                s("status.step.30percent_ruling", "status.step.30percent_ruling.desc", .beginnerGuidesList, false, lang),
                s("status.step.taxes",            "status.step.taxes.desc",            .beginnerGuidesList, false, lang),
                s("status.step.health_insurance", "status.step.health_insurance.desc", .checklistList,      true,  lang)
            ]
        case .euCitizen:
            return [
                s("status.step.address_registration", "status.step.address_registration.desc", .institutionsList, true, lang),
                s("status.step.bsn",                  "status.step.bsn.desc",                  .beginnerGuidesList, true, lang),
                s("status.step.digid",                "status.step.digid.desc",                .beginnerGuidesList, true, lang),
                s("status.step.health_insurance",     "status.step.health_insurance.desc",     .checklistList, true, lang),
                s("status.step.taxes",                "status.step.taxes.desc",                .beginnerGuidesList, false, lang)
            ]
        case .family:
            return [
                s("status.step.address_registration", "status.step.address_registration.desc", .institutionsList,  true,  lang),
                s("status.step.school_daycare",       "status.step.school_daycare.desc",       .beginnerGuidesList, false, lang),
                s("status.step.health_insurance",     "status.step.health_insurance.desc",     .checklistList,      true,  lang),
                s("status.step.toeslagen",            "status.step.toeslagen.desc",            .beginnerGuidesList, false, lang),
                s("status.step.gemeente",             "status.step.gemeente.desc",             .institutionsList,   false, lang)
            ]
        case .tourist:
            return [
                s("status.step.document_check",   "status.step.document_check.desc",    .checklistList,      true,  lang),
                s("status.step.health_insurance", "status.step.health_insurance.desc",  .checklistList,      true,  lang),
                s("status.step.official_sites",   "status.step.official_sites.desc",    .institutionsList,   false, lang),
                s("status.step.gemeente",         "status.step.gemeente.desc",          .institutionsList,   false, lang)
            ]
        case .entrepreneur:
            return [
                s("status.step.address_registration", "status.step.address_registration.desc", .institutionsList, true, lang),
                s("status.step.digid",                "status.step.digid.desc",                .beginnerGuidesList, true, lang),
                s("status.step.taxes",                "status.step.taxes.desc",                .beginnerGuidesList, true, lang),
                s("status.step.health_insurance",     "status.step.health_insurance.desc",     .checklistList, false, lang),
                s("status.step.official_sites",       "status.step.official_sites.desc",       .institutionsList, false, lang)
            ]
        case .lgbtNewcomer:
            return [
                s("status.step.legal_help",        "status.step.legal_help.desc",        .lgbtqSupport, true, lang),
                s("status.step.health_insurance",  "status.step.health_insurance.desc",  .checklistList, false, lang),
                s("status.step.gemeente",          "status.step.gemeente.desc",          .institutionsList, false, lang),
                s("status.step.official_sites",    "status.step.official_sites.desc",    .institutionsList, false, lang)
            ]
        }
    }

    var correspondingProfileType: ProfileType? {
        switch self {
        case .refugee:   return .refugeeStatusHolder
        case .ukrainian: return .refugeeStatusHolder
        case .student:   return .student
        case .worker:    return .worker
        case .expat, .highlySkilledMigrant: return .expat
        case .euCitizen: return nil
        case .family:    return nil
        case .tourist:   return nil
        case .entrepreneur: return nil
        case .lgbtNewcomer: return nil
        }
    }
}

// MARK: - UserProfile

enum OnboardingProfile: String, CaseIterable, Identifiable, Codable, Hashable, Sendable {
    case tourist
    case student
    case worker
    case newResident
    case businessOwner
    case refugeeStatusHolder
    case family

    var id: String { rawValue }

    var userStatus: UserStatus {
        switch self {
        case .tourist: return .tourist
        case .student: return .student
        case .worker: return .worker
        case .newResident: return .euCitizen
        case .businessOwner: return .entrepreneur
        case .refugeeStatusHolder: return .refugee
        case .family: return .family
        }
    }

    static func from(_ status: UserStatus?) -> OnboardingProfile? {
        switch status {
        case .tourist: return .tourist
        case .student: return .student
        case .worker, .expat, .highlySkilledMigrant: return .worker
        case .euCitizen, .lgbtNewcomer: return .newResident
        case .entrepreneur: return .businessOwner
        case .refugee, .ukrainian: return .refugeeStatusHolder
        case .family: return .family
        case nil: return nil
        }
    }

    func localized(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.tourist, .russian): return "Турист"
        case (.tourist, .dutch): return "Toerist"
        case (.tourist, .english): return "Tourist"
        case (.student, .russian): return "Студент"
        case (.student, .dutch): return "Student"
        case (.student, .english): return "Student"
        case (.worker, .russian): return "Работник"
        case (.worker, .dutch): return "Werker"
        case (.worker, .english): return "Worker"
        case (.newResident, .russian): return "Новый резидент"
        case (.newResident, .dutch): return "Nieuwe inwoner"
        case (.newResident, .english): return "New resident"
        case (.businessOwner, .russian): return "Владелец бизнеса"
        case (.businessOwner, .dutch): return "Ondernemer"
        case (.businessOwner, .english): return "Business owner"
        case (.refugeeStatusHolder, .russian): return "Беженец / статусхолдер"
        case (.refugeeStatusHolder, .dutch): return "Vluchteling / statushouder"
        case (.refugeeStatusHolder, .english): return "Refugee / Status holder"
        case (.family, .russian): return "Семья"
        case (.family, .dutch): return "Gezin"
        case (.family, .english): return "Family"
        }
    }

    var icon: String {
        switch self {
        case .tourist: return "suitcase"
        case .student: return "graduationcap"
        case .worker: return "briefcase"
        case .newResident: return "house"
        case .businessOwner: return "building.2"
        case .refugeeStatusHolder: return "person.badge.shield.checkmark"
        case .family: return "figure.2.and.child.holdinghands"
        }
    }
}

enum OnboardingSituation: String, CaseIterable, Identifiable, Codable, Hashable, Sendable {
    case shortStay
    case applyingToStudy
    case enrolledStudent
    case lookingForWork
    case employed
    case recentlyMoved
    case alreadyLiving
    case startingBusiness
    case runningBusiness
    case asylumProcess
    case statusHolder
    case movingWithChildren
    case familyAlreadyHere

    var id: String { rawValue }

    static func options(for profile: OnboardingProfile?) -> [OnboardingSituation] {
        switch profile {
        case .tourist:
            return [.shortStay]
        case .student:
            return [.applyingToStudy, .enrolledStudent, .recentlyMoved]
        case .worker:
            return [.lookingForWork, .employed, .recentlyMoved]
        case .newResident:
            return [.recentlyMoved, .alreadyLiving]
        case .businessOwner:
            return [.startingBusiness, .runningBusiness, .recentlyMoved]
        case .refugeeStatusHolder:
            return [.asylumProcess, .statusHolder, .recentlyMoved]
        case .family:
            return [.movingWithChildren, .familyAlreadyHere, .recentlyMoved]
        case nil:
            return [.recentlyMoved, .alreadyLiving]
        }
    }

    var priorityHints: [LifePriority] {
        switch self {
        case .shortStay: return [.transport, .healthcare, .freeTime]
        case .applyingToStudy: return [.education, .housing, .studentFinance]
        case .enrolledStudent: return [.studentFinance, .studentTransport, .housing]
        case .lookingForWork: return [.work, .documents, .housing]
        case .employed: return [.work, .taxes, .healthInsurance]
        case .recentlyMoved: return [.documents, .housing, .healthInsurance]
        case .alreadyLiving: return [.municipalServices, .healthcare, .transport]
        case .startingBusiness: return [.businessRegistration, .banking, .taxes]
        case .runningBusiness: return [.taxes, .permits, .banking]
        case .asylumProcess: return [.documents, .supportOrganizations, .healthcare]
        case .statusHolder: return [.municipalServices, .housing, .integration]
        case .movingWithChildren: return [.schools, .childcare, .healthcare]
        case .familyAlreadyHere: return [.schools, .childBenefits, .activities]
        }
    }

    func localized(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.shortStay, .russian): return "Короткое пребывание"
        case (.shortStay, .dutch): return "Kort verblijf"
        case (.shortStay, .english): return "Short stay"
        case (.applyingToStudy, .russian): return "Поступаю или жду начало учёбы"
        case (.applyingToStudy, .dutch): return "Ik meld me aan of wacht op de start"
        case (.applyingToStudy, .english): return "Applying or waiting to start"
        case (.enrolledStudent, .russian): return "Уже учусь"
        case (.enrolledStudent, .dutch): return "Ik studeer al"
        case (.enrolledStudent, .english): return "Already enrolled"
        case (.lookingForWork, .russian): return "Ищу работу"
        case (.lookingForWork, .dutch): return "Ik zoek werk"
        case (.lookingForWork, .english): return "Looking for work"
        case (.employed, .russian): return "Уже работаю"
        case (.employed, .dutch): return "Ik werk al"
        case (.employed, .english): return "Already working"
        case (.recentlyMoved, .russian): return "Недавно переехал"
        case (.recentlyMoved, .dutch): return "Onlangs verhuisd"
        case (.recentlyMoved, .english): return "Recently moved"
        case (.alreadyLiving, .russian): return "Уже живу здесь"
        case (.alreadyLiving, .dutch): return "Ik woon hier al"
        case (.alreadyLiving, .english): return "Already living here"
        case (.startingBusiness, .russian): return "Начинаю бизнес"
        case (.startingBusiness, .dutch): return "Ik start een bedrijf"
        case (.startingBusiness, .english): return "Starting a business"
        case (.runningBusiness, .russian): return "Уже веду бизнес"
        case (.runningBusiness, .dutch): return "Ik heb al een bedrijf"
        case (.runningBusiness, .english): return "Already running a business"
        case (.asylumProcess, .russian): return "В процедуре убежища"
        case (.asylumProcess, .dutch): return "In asielprocedure"
        case (.asylumProcess, .english): return "In asylum process"
        case (.statusHolder, .russian): return "Есть статус / ВНЖ"
        case (.statusHolder, .dutch): return "Statushouder"
        case (.statusHolder, .english): return "Status holder"
        case (.movingWithChildren, .russian): return "Переезжаю с детьми"
        case (.movingWithChildren, .dutch): return "Verhuizen met kinderen"
        case (.movingWithChildren, .english): return "Moving with children"
        case (.familyAlreadyHere, .russian): return "Семья уже здесь"
        case (.familyAlreadyHere, .dutch): return "Gezin is al hier"
        case (.familyAlreadyHere, .english): return "Family already here"
        }
    }
}

enum OptionalInterest: String, CaseIterable, Identifiable, Codable, Hashable, Sendable {
    case culture
    case history
    case restaurants
    case nature
    case events
    case shopping
    case museums

    var id: String { rawValue }

    func localized(_ lang: AppLanguage) -> String {
        switch (self, lang) {
        case (.culture, .russian): return "Культура"
        case (.culture, .dutch): return "Cultuur"
        case (.culture, .english): return "Culture"
        case (.history, .russian): return "История"
        case (.history, .dutch): return "Geschiedenis"
        case (.history, .english): return "History"
        case (.restaurants, .russian): return "Рестораны"
        case (.restaurants, .dutch): return "Restaurants"
        case (.restaurants, .english): return "Restaurants"
        case (.nature, .russian): return "Природа"
        case (.nature, .dutch): return "Natuur"
        case (.nature, .english): return "Nature"
        case (.events, .russian): return "События"
        case (.events, .dutch): return "Events"
        case (.events, .english): return "Events"
        case (.shopping, .russian): return "Покупки"
        case (.shopping, .dutch): return "Winkelen"
        case (.shopping, .english): return "Shopping"
        case (.museums, .russian): return "Музеи"
        case (.museums, .dutch): return "Musea"
        case (.museums, .english): return "Museums"
        }
    }

    var icon: String {
        switch self {
        case .culture: return "theatermasks"
        case .history: return "book.closed"
        case .restaurants: return "fork.knife"
        case .nature: return "leaf"
        case .events: return "calendar"
        case .shopping: return "bag"
        case .museums: return "building.columns"
        }
    }
}

struct UserProfile: Codable {
    var profileType: ProfileType
    var arrivalStatus: ArrivalStatus
    var preferredLanguage: String
    var remindersEnabled: Bool
    var nationalityPlaceholder: String
    var municipality: String
    var arrivalMonthYear: String
    var workStatus: WorkStatus
    var studentStatus: StudentStatus

    var timeInNL: TimeInNL
    var priorities: [LifePriority]
    var onboardingProfile: OnboardingProfile?
    var onboardingSituation: OnboardingSituation?
    var selectedRegionOrProvince: String
    var optionalInterests: [OptionalInterest]
    var hasBSN: Bool
    var hasDigiD: Bool
    var hasHealthInsuranceNL: Bool
    var hasBankAccountNL: Bool
    var hasRegisteredAddress: Bool

    static let `default` = UserProfile(
        profileType: .worker,
        arrivalStatus: .arrivedRecently,
        preferredLanguage: "English",
        remindersEnabled: false,
        nationalityPlaceholder: "",
        municipality: "Amsterdam",
        arrivalMonthYear: "2026-05",
        workStatus: .employed,
        studentStatus: .notStudent,
        timeInNL: .lessThan3Months,
        priorities: [.documents, .healthInsurance],
        onboardingProfile: nil,
        onboardingSituation: nil,
        selectedRegionOrProvince: "",
        optionalInterests: [],
        hasBSN: false,
        hasDigiD: false,
        hasHealthInsuranceNL: false,
        hasBankAccountNL: false,
        hasRegisteredAddress: false
    )
}
