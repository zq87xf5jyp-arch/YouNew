import SwiftUI

struct TypedCategorySectionView: View {
    enum Section: Hashable {
        case housing(HousingSectionType)
        case government(GovernmentSectionType)
        case transport(TransportSectionType)
        case education(EducationSectionType)
        case work(WorkSectionType)
        case health(HealthSectionType)
    }

    let section: Section

    @EnvironmentObject private var languageManager: LanguageManager

    private var language: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            ResponsiveContentContainer(maxWidth: 760) {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    VStack(spacing: 10) {
                        ForEach(rows) { row in
                            NavigationLink(value: row.destination) {
                                HStack(spacing: 12) {
                                    Image(systemName: row.symbol)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(accent)
                                        .frame(width: 42, height: 42)
                                        .background(accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(row.title.value(language))
                                            .font(AppTypography.bodyStrong)
                                            .foregroundStyle(AppColors.textPrimary)
                                            .multilineTextAlignment(.leading)
                                        Text(row.subtitle.value(language))
                                            .font(AppTypography.caption)
                                            .foregroundStyle(AppColors.textSecondary)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(3)
                                    }

                                    Spacer(minLength: 8)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(AppColors.textTertiary)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(AppColors.stroke.opacity(0.65), lineWidth: 0.8)
                                        .allowsHitTesting(false)
                                }
                            }
                            .buttonStyle(NLTileButtonStyle())
                            .accessibilityIdentifier("category.section.detailLink.\(routeIdentifier).\(row.id)")
                        }
                    }

                    Color.clear.frame(height: AppSpacing.tabBarScrollReserve)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.medium)
            }
        }
        .appSceneBackground(.more)
        .navigationTitle(title.value(language))
        .nlNavigationInline()
        .accessibilityIdentifier("category.section.\(routeIdentifier)")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title.value(language), systemImage: symbol)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            Text(subtitle.value(language))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(accent.opacity(0.24), lineWidth: 1)
                .allowsHitTesting(false)
        }
    }

    private var rows: [CategorySectionRow] {
        switch section {
        case .housing(let type):
            switch type {
            case .overview:
                return [guideRow("housing-overview", "Housing basics", "Wonen: basis", "Основы жилья", "Rental checks, rights, and official next steps.", "Huurchecks, rechten en officiële vervolgstappen.", "Проверка аренды, права и официальные шаги.", "house.fill", .guideArticle(sectionID: "housing", articleID: "renting"))]
            case .rent:
                return [guideRow("rent", "Renting a home", "Een woning huren", "Аренда жилья", "Contracts, deposits, registration, and first checks.", "Contracten, borg, inschrijving en eerste controles.", "Договор, депозит, регистрация и первые проверки.", "key.fill", .guideArticle(sectionID: "housing", articleID: "renting"))]
            case .buy:
                return [guideRow("buy", "Buying a home", "Een woning kopen", "Покупка жилья", "Open the verified housing decision guide.", "Open de gecontroleerde beslisgids voor wonen.", "Откройте проверенный гид по жилищным решениям.", "house.and.flag.fill", .practicalGuide(.housingBasics))]
            case .studentHousing:
                return [guideRow("student-housing", "Student housing", "Studentenhuisvesting", "Студенческое жильё", "Rooms, registration permission, contracts, and scam checks.", "Kamers, inschrijving, contracten en controle op fraude.", "Комнаты, регистрация, договоры и проверка мошенничества.", "graduationcap.fill", .guideArticle(sectionID: "housing", articleID: "renting"))]
            case .socialHousing:
                return [
                    guideRow("social-housing", "Social housing", "Sociale huur", "Социальное жильё", "Eligibility, waiting lists, rent rules, and tenant rights.", "Toelating, wachttijden, huurregels en huurdersrechten.", "Право, очереди, правила аренды и права жильца.", "person.3.fill", .guideArticle(sectionID: "housing", articleID: "tenant-rights")),
                    guideRow("rent-allowance", "Rent allowance", "Huurtoeslag", "Субсидия на аренду", "Check the official allowance flow.", "Controleer de officiële toeslagroute.", "Проверьте официальный путь получения субсидии.", "eurosign.circle.fill", .guideArticle(sectionID: "housing", articleID: "huurtoeslag"))
                ]
            }

        case .government(let type):
            switch type {
            case .overview:
                return [
                    institutionRow("municipality", "Municipality", "Gemeente", "Муниципалитет", "Address registration and local civic services.", "Adresregistratie en lokale burgerzaken.", "Регистрация адреса и городские услуги.", "building.2.fill", "Municipality"),
                    institutionRow("ind", "IND", "IND", "IND", "Residence permits, immigration, and application status.", "Verblijfsvergunningen, immigratie en aanvraagstatus.", "ВНЖ, иммиграция и статус заявления.", "person.text.rectangle.fill", "IND"),
                    institutionRow("digid", "DigiD", "DigiD", "DigiD", "Secure access to Dutch public services.", "Veilige toegang tot Nederlandse overheidsdiensten.", "Безопасный доступ к государственным сервисам.", "lock.shield.fill", "DigiD"),
                    institutionRow("taxes", "Taxes and allowances", "Belasting en toeslagen", "Налоги и пособия", "Belastingdienst letters, returns, and allowances.", "Brieven, aangifte en toeslagen van de Belastingdienst.", "Письма, декларации и пособия Belastingdienst.", "banknote.fill", "Belastingdienst"),
                    guideRow("healthcare", "Healthcare basics", "Basiszorg", "Основы медицины", "Insurance, huisarts, pharmacy, and urgent care.", "Verzekering, huisarts, apotheek en spoedzorg.", "Страховка, huisarts, аптека и срочная помощь.", "cross.case.fill", .practicalGuide(.healthcareBasics))
                ]
            case .municipality:
                return [institutionRow("municipality", "Municipality", "Gemeente", "Муниципалитет", "Address registration and local civic services.", "Adresregistratie en lokale burgerzaken.", "Регистрация адреса и городские услуги.", "building.2.fill", "Municipality")]
            case .ind:
                return [institutionRow("ind", "IND", "IND", "IND", "Residence permits, immigration, and application status.", "Verblijfsvergunningen, immigratie en aanvraagstatus.", "ВНЖ, иммиграция и статус заявления.", "person.text.rectangle.fill", "IND")]
            case .digid:
                return [institutionRow("digid", "DigiD", "DigiD", "DigiD", "Secure access to Dutch public services.", "Veilige toegang tot Nederlandse overheidsdiensten.", "Безопасный доступ к государственным сервисам.", "lock.shield.fill", "DigiD")]
            case .taxes:
                return [institutionRow("taxes", "Taxes and allowances", "Belasting en toeslagen", "Налоги и пособия", "Belastingdienst letters, returns, and allowances.", "Brieven, aangifte en toeslagen van de Belastingdienst.", "Письма, декларации и пособия Belastingdienst.", "banknote.fill", "Belastingdienst")]
            case .healthcare:
                return [guideRow("healthcare", "Healthcare basics", "Basiszorg", "Основы медицины", "Insurance, huisarts, pharmacy, and urgent care.", "Verzekering, huisarts, apotheek en spoedzorg.", "Страховка, huisarts, аптека и срочная помощь.", "cross.case.fill", .practicalGuide(.healthcareBasics))]
            }

        case .transport(let type):
            switch type {
            case .overview:
                return [guideRow("transport-overview", "Transport basics", "Basis vervoer", "Основы транспорта", "Plan, pay, check in, and travel safely.", "Plan, betaal, check in en reis veilig.", "Планирование, оплата, check-in и безопасные поездки.", "tram.fill", .guideArticle(sectionID: "transport", articleID: "ov-chipkaart"))]
            case .train:
                return [guideRow("train", "NS trains", "NS-treinen", "Поезда NS", "Planning, tickets, platforms, and delays.", "Planning, tickets, perrons en vertragingen.", "Маршруты, билеты, платформы и задержки.", "train.side.front.car", .guideArticle(sectionID: "transport", articleID: "trains"))]
            case .bus:
                return [guideRow("bus", "Bus travel", "Reizen met de bus", "Автобусы", "Operators, check-in, fares, and transfers.", "Vervoerders, inchecken, tarieven en overstappen.", "Операторы, check-in, тарифы и пересадки.", "bus.fill", .guideArticle(sectionID: "transport", articleID: "ov-chipkaart"))]
            case .metro:
                return [guideRow("metro", "Metro travel", "Reizen met de metro", "Метро", "Networks, check-in, fares, and transfers.", "Netwerken, inchecken, tarieven en overstappen.", "Сети, check-in, тарифы и пересадки.", "tram.fill", .guideArticle(sectionID: "transport", articleID: "ov-chipkaart"))]
            case .bike:
                return [guideRow("bike", "Cycling", "Fietsen", "Велосипед", "Rules, lights, parking, and theft prevention.", "Regels, verlichting, parkeren en diefstalpreventie.", "Правила, свет, парковка и защита от кражи.", "bicycle", .guideArticle(sectionID: "transport", articleID: "bicycle"))]
            case .parking:
                return [guideRow("parking", "Parking rules", "Parkeerregels", "Правила парковки", "Permits, signs, removal zones, and fines.", "Vergunningen, borden, verwijderzones en boetes.", "Разрешения, знаки, эвакуация и штрафы.", "parkingsign.circle.fill", .practicalGuide(.transportBasics))]
            case .journeyPlanner:
                return [guideRow("journey-planner", "9292 journey planner", "9292-reisplanner", "Планировщик 9292", "Plan door-to-door trips across Dutch operators.", "Plan deur-tot-deurreizen met Nederlandse vervoerders.", "Планируйте поездки от двери до двери по всем операторам.", "point.topleft.down.to.point.bottomright.curvepath", .practicalGuide(.transportBasics))]
            case .ovChipkaart:
                return [guideRow("ov-chipkaart", "OV-chipkaart", "OV-chipkaart", "OV-chipkaart", "Balance, subscriptions, check-in, and missed check-out.", "Saldo, abonnementen, inchecken en gemiste check-out.", "Баланс, абонементы, check-in и пропущенный check-out.", "creditcard.fill", .guideArticle(sectionID: "transport", articleID: "ov-chipkaart"))]
            }

        case .education(let type):
            switch type {
            case .overview:
                return [
                    institutionRow("universities", "Universities and enrolment", "Universiteiten en inschrijving", "Университеты и поступление", "Higher education administration and official student steps.", "Hogeronderwijsadministratie en officiële studentenstappen.", "Администрирование высшего образования и официальные шаги.", "building.columns.fill", "DUO"),
                    institutionRow("duo", "DUO", "DUO", "DUO", "Education administration, exams, and student finance.", "Onderwijsadministratie, examens en studiefinanciering.", "Образование, экзамены и студенческие финансы.", "doc.text.fill", "DUO"),
                    guideRow("language-schools", "Dutch language learning", "Nederlands leren", "Изучение нидерландского", "Start with a structured A1-A2 learning module.", "Begin met een gestructureerde A1-A2-module.", "Начните со структурированного модуля A1-A2.", "character.book.closed.fill", .dutchA1A2Module("basics")),
                    institutionRow("driving-schools", "Driving and licence rules", "Rijden en rijbewijsregels", "Вождение и водительские права", "Verify licence, vehicle, and driving administration with RDW.", "Controleer rijbewijs, voertuig en administratie bij RDW.", "Проверьте права, автомобиль и правила через RDW.", "car.fill", "RDW"),
                    institutionRow("student-finance", "Student finance", "Studiefinanciering", "Студенческие финансы", "Official student-finance administration and messages.", "Officiële administratie en berichten over studiefinanciering.", "Официальное оформление и сообщения о студенческих финансах.", "eurosign.circle.fill", "DUO")
                ]
            case .universities:
                return [institutionRow("universities", "Universities and enrolment", "Universiteiten en inschrijving", "Университеты и поступление", "Higher education administration and official student steps.", "Hogeronderwijsadministratie en officiële studentenstappen.", "Администрирование высшего образования и официальные шаги.", "building.columns.fill", "DUO")]
            case .duo:
                return [institutionRow("duo", "DUO", "DUO", "DUO", "Education administration, exams, and student finance.", "Onderwijsadministratie, examens en studiefinanciering.", "Образование, экзамены и студенческие финансы.", "doc.text.fill", "DUO")]
            case .languageSchools:
                return [guideRow("language-schools", "Dutch language learning", "Nederlands leren", "Изучение нидерландского", "Start with a structured A1-A2 learning module.", "Begin met een gestructureerde A1-A2-module.", "Начните со структурированного модуля A1-A2.", "character.book.closed.fill", .dutchA1A2Module("basics"))]
            case .drivingSchools:
                return [institutionRow("driving-schools", "Driving and licence rules", "Rijden en rijbewijsregels", "Вождение и водительские права", "Verify licence, vehicle, and driving administration with RDW.", "Controleer rijbewijs, voertuig en administratie bij RDW.", "Проверьте права, автомобиль и правила через RDW.", "car.fill", "RDW")]
            case .studentFinance:
                return [institutionRow("student-finance", "Student finance", "Studiefinanciering", "Студенческие финансы", "Official student-finance administration and messages.", "Officiële administratie en berichten over studiefinanciering.", "Официальное оформление и сообщения о студенческих финансах.", "eurosign.circle.fill", "DUO")]
            }

        case .work(let type):
            let permits = guideRow(
                "permits-and-rights",
                "Work permit and right to work",
                "Werkvergunning en recht om te werken",
                "Разрешение и право на работу",
                "Permits, residence-card conditions, contracts, and official checks.",
                "Vergunningen, voorwaarden op de verblijfskaart, contracten en officiële controles.",
                "Разрешения, условия ВНЖ, договоры и официальные проверки.",
                "person.badge.shield.checkmark.fill",
                .guideArticle(sectionID: "work", articleID: "working-permit")
            )
            let salary = guideRow(
                "salary-taxes",
                "Salary, payslip, and taxes",
                "Salaris, loonstrook en belasting",
                "Зарплата, расчётный лист и налоги",
                "Bruto/netto, loonheffing, holiday allowance, and tax returns.",
                "Bruto/netto, loonheffing, vakantiegeld en belastingaangifte.",
                "Bruto/netto, loonheffing, отпускные и налоговая декларация.",
                "banknote.fill",
                .guideArticle(sectionID: "work", articleID: "salary-taxes")
            )
            let jobs = guideRow(
                "job-search",
                "Finding a job in the Netherlands",
                "Werk vinden in Nederland",
                "Поиск работы в Нидерландах",
                "Vacancies, CV preparation, interviews, contracts, and scam checks.",
                "Vacatures, cv, sollicitaties, contracten en controle op fraude.",
                "Вакансии, CV, собеседования, договоры и проверка мошенничества.",
                "magnifyingglass.circle.fill",
                .guideArticle(sectionID: "work", articleID: "job-search-nl")
            )
            switch type {
            case .overview: return [permits, salary, jobs]
            case .permitsAndRights: return [permits]
            case .salaryTaxes: return [salary]
            case .jobSearch: return [jobs]
            }

        case .health(let type):
            let insurance = guideRow(
                "insurance",
                "Health insurance",
                "Zorgverzekering",
                "Медицинская страховка",
                "Basisverzekering, eigen risico, and zorgtoeslag.",
                "Basisverzekering, eigen risico en zorgtoeslag.",
                "Basisverzekering, eigen risico и zorgtoeslag.",
                "shield.lefthalf.filled",
                .guideArticle(sectionID: "healthcare", articleID: "insurance")
            )
            let huisarts = guideRow(
                "huisarts",
                "Finding and using a huisarts",
                "Een huisarts vinden en bezoeken",
                "Поиск и посещение huisarts",
                "Registration, referrals, closed practices, and out-of-hours care.",
                "Inschrijving, verwijzingen, patiëntenstops en zorg buiten kantooruren.",
                "Регистрация, направления, закрытые списки и помощь вне рабочего времени.",
                "stethoscope",
                .guideArticle(sectionID: "healthcare", articleID: "huisarts")
            )
            let urgentCare = guideRow(
                "urgent-care",
                "Urgent medical care",
                "Dringende medische zorg",
                "Срочная медицинская помощь",
                "Huisarts, huisartsenpost, emergency department, and 112.",
                "Huisarts, huisartsenpost, spoedeisende hulp en 112.",
                "Huisarts, huisartsenpost, неотложная помощь и 112.",
                "cross.case.fill",
                .guideArticle(sectionID: "healthcare", articleID: "urgent-care")
            )
            switch type {
            case .overview: return [insurance, huisarts, urgentCare]
            case .insurance: return [insurance]
            case .huisarts: return [huisarts]
            case .urgentCare: return [urgentCare]
            }
        }
    }

    private var routeIdentifier: String {
        switch section {
        case .housing(let type): return "housing.\(type.rawValue)"
        case .government(let type): return "government.\(type.rawValue)"
        case .transport(let type): return "transport.\(type.rawValue)"
        case .education(let type): return "education.\(type.rawValue)"
        case .work(let type): return "work.\(type.rawValue)"
        case .health(let type): return "health.\(type.rawValue)"
        }
    }

    private var title: LocalizedCategoryText {
        switch section {
        case .housing(let type):
            switch type {
            case .overview: return text("Housing", "Wonen", "Жильё")
            case .rent: return text("Rent", "Huren", "Аренда")
            case .buy: return text("Buy", "Kopen", "Покупка")
            case .studentHousing: return text("Student housing", "Studentenhuisvesting", "Студенческое жильё")
            case .socialHousing: return text("Social housing", "Sociale huur", "Социальное жильё")
            }
        case .government(let type):
            switch type {
            case .overview: return text("Official services", "Officiële diensten", "Официальные сервисы")
            case .municipality: return text("Municipality", "Gemeente", "Муниципалитет")
            case .ind: return text("IND", "IND", "IND")
            case .digid: return text("DigiD", "DigiD", "DigiD")
            case .taxes: return text("Taxes", "Belastingen", "Налоги")
            case .healthcare: return text("Healthcare", "Zorg", "Медицина")
            }
        case .transport(let type):
            switch type {
            case .overview: return text("Transport", "Vervoer", "Транспорт")
            case .train: return text("Train", "Trein", "Поезд")
            case .bus: return text("Bus", "Bus", "Автобус")
            case .metro: return text("Metro", "Metro", "Метро")
            case .bike: return text("Bike", "Fiets", "Велосипед")
            case .parking: return text("Parking", "Parkeren", "Парковка")
            case .journeyPlanner: return text("9292", "9292", "9292")
            case .ovChipkaart: return text("OV-chipkaart", "OV-chipkaart", "OV-chipkaart")
            }
        case .education(let type):
            switch type {
            case .overview: return text("Education", "Onderwijs", "Образование")
            case .universities: return text("Universities", "Universiteiten", "Университеты")
            case .duo: return text("DUO", "DUO", "DUO")
            case .languageSchools: return text("Language schools", "Taalscholen", "Языковые школы")
            case .drivingSchools: return text("Driving schools", "Rijscholen", "Автошколы")
            case .studentFinance: return text("Student finance", "Studiefinanciering", "Студенческие финансы")
            }
        case .work(let type):
            switch type {
            case .overview: return text("Work & Money", "Werk & geld", "Работа и деньги")
            case .permitsAndRights: return text("Work permits & rights", "Werkvergunningen & rechten", "Разрешения и права")
            case .salaryTaxes: return text("Salary & taxes", "Salaris & belasting", "Зарплата и налоги")
            case .jobSearch: return text("Finding work", "Werk vinden", "Поиск работы")
            }
        case .health(let type):
            switch type {
            case .overview: return text("Health & Safety", "Gezondheid & veiligheid", "Здоровье и безопасность")
            case .insurance: return text("Health insurance", "Zorgverzekering", "Медицинская страховка")
            case .huisarts: return text("Huisarts", "Huisarts", "Huisarts")
            case .urgentCare: return text("Urgent care", "Dringende zorg", "Срочная помощь")
            }
        }
    }

    private var subtitle: LocalizedCategoryText {
        text(
            "Choose a verified item to open its details.",
            "Kies een gecontroleerd item om de details te openen.",
            "Выберите проверенный пункт, чтобы открыть подробности."
        )
    }

    private var symbol: String { rows.first?.symbol ?? "square.grid.2x2.fill" }

    private var accent: Color {
        switch section {
        case .housing: return AppColors.violet
        case .government: return AppColors.softBlue
        case .transport: return AppColors.emerald
        case .education: return AppColors.routeLine
        case .work: return AppColors.softBlue
        case .health: return AppColors.success
        }
    }

    private func guideRow(
        _ id: String,
        _ enTitle: String,
        _ nlTitle: String,
        _ ruTitle: String,
        _ enSubtitle: String,
        _ nlSubtitle: String,
        _ ruSubtitle: String,
        _ symbol: String,
        _ destination: AppDestination
    ) -> CategorySectionRow {
        CategorySectionRow(id: id, title: text(enTitle, nlTitle, ruTitle), subtitle: text(enSubtitle, nlSubtitle, ruSubtitle), symbol: symbol, destination: destination)
    }

    private func institutionRow(
        _ id: String,
        _ enTitle: String,
        _ nlTitle: String,
        _ ruTitle: String,
        _ enSubtitle: String,
        _ nlSubtitle: String,
        _ ruSubtitle: String,
        _ symbol: String,
        _ institution: String
    ) -> CategorySectionRow {
        guideRow(id, enTitle, nlTitle, ruTitle, enSubtitle, nlSubtitle, ruSubtitle, symbol, .institution(institution))
    }

    private func text(_ en: String, _ nl: String, _ ru: String) -> LocalizedCategoryText {
        LocalizedCategoryText(english: en, dutch: nl, russian: ru)
    }
}

private struct CategorySectionRow: Identifiable {
    let id: String
    let title: LocalizedCategoryText
    let subtitle: LocalizedCategoryText
    let symbol: String
    let destination: AppDestination
}

private struct LocalizedCategoryText {
    let english: String
    let dutch: String
    let russian: String

    func value(_ language: AppLanguage) -> String {
        switch language {
        case .english: return english
        case .dutch: return dutch
        case .russian: return russian
        }
    }
}
