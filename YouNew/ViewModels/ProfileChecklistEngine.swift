import Foundation

enum ChecklistRelevanceBucket {
    case recommended
    case later
    case notRelevant
}

struct ProfileChecklistContext {
    let status: UserStatus
    let hasBSN: Bool
    let hasDigiD: Bool
    let hasHealthInsurance: Bool
    let hasRegisteredAddress: Bool
}

struct StepInsight {
    let why: [AppLanguage: String]
    let riskIfIgnored: [AppLanguage: String]
    let needed: [AppLanguage: String]
    let typicalWait: [AppLanguage: String]
    let commonMistake: [AppLanguage: String]
    let appointmentNeeded: [AppLanguage: String]
    let possibleCost: [AppLanguage: String]
}

enum ProfileChecklistEngine {
    static func categorize(_ item: ChecklistItem, context: ProfileChecklistContext) -> ChecklistRelevanceBucket {
        let title = item.title(.english).lowercased()
        let blueprint = ProfileBlueprint.forStatus(context.status)

        if let relevantProfileTypes = item.relevantProfileTypes,
           let mappedProfile = context.status.correspondingProfileType,
           !relevantProfileTypes.contains(mappedProfile) {
            return .notRelevant
        }

        let isExcluded = blueprint.checklistExcludeKeywords.contains(where: { title.contains($0) })
        if isExcluded { return .notRelevant }

        if !isAllowedCategory(item.category, title: title, status: context.status) {
            return .notRelevant
        }

        if context.status == .tourist {
            let blockedForTourist = ["bsn", "digid", "duo", "uwv", "register your address"]
            if blockedForTourist.contains(where: { title.contains($0) }) {
                return .notRelevant
            }
        }

        if title.contains("bsn") && context.hasBSN { return .later }
        if title.contains("digid") && context.hasDigiD { return .later }
        if title.contains("insurance") && context.hasHealthInsurance { return .later }
        if title.contains("register your address") && context.hasRegisteredAddress { return .later }

        if !context.hasBSN && title.contains("digid") {
            return .later
        }

        let isIncluded = blueprint.checklistIncludeKeywords.contains(where: { title.contains($0) })
        if isIncluded {
            return item.priority == .high ? .recommended : .later
        }

        switch item.priority {
        case .high: return .recommended
        case .medium, .low: return .later
        }
    }

    private static func isAllowedCategory(_ category: ChecklistCategory, title: String, status: UserStatus) -> Bool {
        switch status {
        case .student:
            return category == .education
                || category == .housing
                || category == .insurance
                || category == .transport
                || (category == .documents && (title.contains("duo") || title.contains("student")))
        case .worker:
            return [.registration, .documents, .insurance, .work, .taxes, .housing, .transport].contains(category)
        case .refugee, .ukrainian:
            return [.registration, .documents, .insurance, .housing, .education, .transport].contains(category)
        case .family:
            return [.registration, .documents, .insurance, .housing, .education, .transport].contains(category)
        case .highlySkilledMigrant, .expat, .euCitizen:
            return [.registration, .documents, .insurance, .work, .taxes, .housing, .transport, .education].contains(category)
        case .tourist:
            return [.documents, .insurance, .transport].contains(category)
        case .entrepreneur:
            return [.registration, .documents, .insurance, .work, .taxes, .housing, .transport].contains(category)
        case .lgbtNewcomer:
            return [.documents, .insurance, .housing, .transport].contains(category)
        }
    }

    static func rationale(for status: UserStatus, language: AppLanguage) -> String {
        let blueprint = ProfileBlueprint.forStatus(status)
        let priorities = blueprint.topPriorities.prefix(3).compactMap { $0.text[language] }
        let joined = priorities.joined(separator: ", ")
        switch language {
        case .russian:
            return "Эти шаги выбраны для вашего профиля: \(joined). Нерелевантные шаги скрыты, а срочные задачи вынесены вверх."
        case .english:
            return "These steps are selected for your profile: \(joined). Irrelevant items are hidden and urgent tasks are moved up."
        case .dutch:
            return "Deze stappen zijn gekozen voor uw profiel: \(joined). Niet-relevante stappen zijn verborgen en urgente taken staan bovenaan."
        }
    }

    static func insight(for item: ChecklistItem, status: UserStatus?) -> StepInsight {
        let title = item.title(.english).lowercased()
        if title.contains("digid") {
            return StepInsight(
                why: [.russian: "DigiD нужен для налогов, медицины и сервисов государства.", .english: "DigiD is needed for taxes, healthcare, and government services.", .dutch: "DigiD is nodig voor belastingen, zorg en overheidsdiensten."],
                riskIfIgnored: [.russian: "Вы не сможете быстро подтверждать действия в госкабинетах.", .english: "You may be blocked from timely actions in government portals.", .dutch: "U kunt tijdige acties in overheidsportalen missen."],
                needed: [.russian: "BSN, адрес регистрации, доступ к почте.", .english: "BSN, registered address, access to mail.", .dutch: "BSN, geregistreerd adres, toegang tot post."],
                typicalWait: [.russian: "Обычно несколько дней до письма активации.", .english: "Usually several days for activation letter.", .dutch: "Meestal enkele dagen voor activatiebrief."],
                commonMistake: [.russian: "Пытаются активировать без завершённой регистрации адреса.", .english: "Trying to activate before address registration is complete.", .dutch: "Activeren voordat adresregistratie is afgerond."],
                appointmentNeeded: [.russian: "Обычно нет.", .english: "Usually no.", .dutch: "Meestal niet."],
                possibleCost: [.russian: "Обычно бесплатно.", .english: "Usually free.", .dutch: "Meestal gratis."]
            )
        }

        if title.contains("bsn") || item.category == .registration {
            return StepInsight(
                why: [.russian: "Без этого шага блокируются многие базовые процессы в NL.", .english: "Without this step, many core NL processes remain blocked.", .dutch: "Zonder deze stap blijven veel basisprocessen in NL geblokkeerd."],
                riskIfIgnored: [.russian: "Задержки с работой, страховкой, налогами и письмами.", .english: "Delays with work, insurance, taxes, and official letters.", .dutch: "Vertraging bij werk, verzekering, belastingen en officiële brieven."],
                needed: [.russian: "Паспорт/ВНЖ, подтверждение адреса, документы статуса.", .english: "Passport/residence docs, address proof, status documents.", .dutch: "Paspoort/verblijfsdocument, adresbewijs, statusdocumenten."],
                typicalWait: [.russian: "Обычно 1-3 недели в зависимости от gemeente.", .english: "Usually 1-3 weeks depending on municipality.", .dutch: "Meestal 1-3 weken afhankelijk van gemeente."],
                commonMistake: [.russian: "Не проверяют актуальный список документов конкретной gemeente.", .english: "Not checking the municipality-specific document list.", .dutch: "De gemeentelijke documentenlijst niet vooraf controleren."],
                appointmentNeeded: [.russian: "Часто да.", .english: "Often yes.", .dutch: "Vaak wel."],
                possibleCost: [.russian: "Обычно бесплатно, но проверьте местные сборы.", .english: "Usually free, but local fees may apply.", .dutch: "Meestal gratis, maar lokale kosten kunnen gelden."]
            )
        }

        if item.category == .insurance {
            return StepInsight(
                why: [.russian: "Страховка влияет на доступ к медицине и финансовые риски.", .english: "Insurance affects healthcare access and financial risk.", .dutch: "Verzekering beïnvloedt zorgtoegang en financieel risico."],
                riskIfIgnored: [.russian: "Возможны штрафы и большие расходы на лечение.", .english: "You may face penalties and high treatment costs.", .dutch: "U kunt boetes en hoge zorgkosten krijgen."],
                needed: [.russian: "BSN/документы статуса и адрес.", .english: "BSN/status documents and address.", .dutch: "BSN/statusdocumenten en adres."],
                typicalWait: [.russian: "Обычно 1-7 дней на оформление.", .english: "Usually 1-7 days to set up.", .dutch: "Meestal 1-7 dagen om te regelen."],
                commonMistake: [.russian: "Выбирают план без проверки покрытия и дедактибла.", .english: "Choosing a plan without checking coverage and deductible.", .dutch: "Een polis kiezen zonder dekking en eigen risico te controleren."],
                appointmentNeeded: [.russian: "Нет.", .english: "No.", .dutch: "Nee."],
                possibleCost: [.russian: "Ежемесячная премия зависит от плана.", .english: "Monthly premium depends on the plan.", .dutch: "Maandpremie hangt af van de polis."]
            )
        }

        let isTourist = (status == .tourist)
        return StepInsight(
            why: [.russian: "Этот шаг снижает риск ошибок в вашей ситуации.", .english: "This step reduces risk in your situation.", .dutch: "Deze stap verlaagt risico in uw situatie."],
            riskIfIgnored: [.russian: "Можно пропустить дедлайн или важное действие.", .english: "You might miss a deadline or key action.", .dutch: "U kunt een deadline of belangrijke actie missen."],
            needed: [.russian: "Паспорт/ID, письма и подтверждения по теме шага.", .english: "Passport/ID, letters, and related confirmations.", .dutch: "Paspoort/ID, brieven en relevante bevestigingen."],
            typicalWait: [.russian: isTourist ? "Обычно быстро, если шаг информационный." : "Обычно от нескольких дней до пары недель.", .english: isTourist ? "Usually quick when informational." : "Usually from several days to a few weeks.", .dutch: isTourist ? "Meestal snel als het informatief is." : "Meestal van enkele dagen tot enkele weken."],
            commonMistake: [.russian: "Откладывают до последнего момента.", .english: "Postponing until the last moment.", .dutch: "Uitstellen tot het laatste moment."],
            appointmentNeeded: [.russian: "Зависит от учреждения.", .english: "Depends on the institution.", .dutch: "Afhankelijk van de instantie."],
            possibleCost: [.russian: "Проверьте официальный источник: сборы могут отличаться.", .english: "Check official source: fees can vary.", .dutch: "Controleer officiële bron: kosten kunnen verschillen."]
        )
    }
}
