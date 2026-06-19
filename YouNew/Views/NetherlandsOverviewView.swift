import SwiftUI

struct NetherlandsOverviewView: View {
    @EnvironmentObject private var languageManager: LanguageManager

    private var lang: AppLanguage { languageManager.appLanguage }
    private var text: NetherlandsOverviewText { NetherlandsOverviewText(lang: lang) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    CityImageView(
                        urlString: "https://commons.wikimedia.org/wiki/Special:FilePath/Amsterdam%20-%20canal%20houses%20%283416157844%29.jpg?width=1600",
                        height: 280,
                        cityName: "Netherlands",
                        fallbackColor: Color(hex: "#142A3E")
                    )

                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.3),
                            .init(color: Color(hex: "#06080F").opacity(0.8), location: 0.7),
                            .init(color: Color(hex: "#06080F"), location: 0.95)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        VStack(spacing: 0) {
                            Color(hex: "#AE1C28")
                            Color.white
                            Color(hex: "#21468B")
                        }
                        .frame(width: 52, height: 34)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .strokeBorder(.white.opacity(0.3), lineWidth: 0.5)
                        )

                        Text(text.countryName)
                            .font(.custom("Syne-ExtraBold", size: 28))
                            .foregroundStyle(.white)
                        Text(text.tagline)
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.65))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                LazyVStack(alignment: .leading, spacing: 24) {
                    overviewSection(text.keyFactsTitle) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(text.stats) { stat in
                                OverviewStatCard(icon: stat.icon, label: stat.label, value: stat.value)
                            }
                        }
                    }

                    overviewSection(text.countryOverviewTitle) {
                        Text(text.overview)
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.72))
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    overviewSection(text.factsTitle) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(text.fastFacts) { fact in
                                HStack(spacing: 12) {
                                    Text(fact.icon)
                                        .font(.system(size: 20))
                                        .frame(width: 32)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(fact.title)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(.white)
                                        Text(fact.value)
                                            .font(.system(size: 12))
                                            .foregroundStyle(.white.opacity(0.55))
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .padding(.vertical, 8)
                                Divider().background(Color.white.opacity(0.06))
                            }
                        }
                    }

                    overviewSection(text.governmentTitle) {
                        LazyVStack(spacing: 0) {
                            ForEach(text.governmentRows) { row in
                                InfoRow(label: row.label, value: row.value)
                            }
                        }
                    }

                    overviewSection(text.economyTitle) {
                        LazyVStack(spacing: 0) {
                            ForEach(text.economyRows) { row in
                                InfoRow(label: row.label, value: row.value)
                            }
                        }
                        OverviewTagCloud(title: text.keySectorsTitle, items: text.keySectors)
                        OverviewTagCloud(title: text.companiesTitle, items: text.companies)
                        OverviewNoteCard(text: text.economyNote, tint: Color(hex: "#F97316"))
                    }

                    overviewSection(text.educationTitle) {
                        LazyVStack(spacing: 0) {
                            ForEach(text.educationRows) { row in
                                InfoRow(label: row.label, value: row.value)
                            }
                        }
                        LazyVStack(spacing: 8) {
                            ForEach(text.topUniversities) { university in
                                UniversityOverviewRow(university: university)
                            }
                        }
                        OverviewNoteCard(text: text.educationNote, tint: Color(hex: "#2DD4BF"))
                    }

                    overviewSection(text.healthcareTitle) {
                        LazyVStack(spacing: 0) {
                            ForEach(text.healthcareRows) { row in
                                InfoRow(label: row.label, value: row.value)
                            }
                        }
                        OverviewTagCloud(title: text.majorHospitalsTitle, items: text.majorHospitals)
                        OverviewNoteCard(text: text.healthcareNote, tint: Color(hex: "#EF4444"))
                    }

                    overviewSection(text.housingTitle) {
                        LazyVStack(spacing: 0) {
                            ForEach(text.housingRows) { row in
                                InfoRow(label: row.label, value: row.value)
                            }
                        }
                        OverviewTagCloud(title: text.whereToSearchTitle, items: text.housingPlatforms)
                        OverviewNoteCard(text: text.housingNote, tint: Color(hex: "#8B5CF6"))
                    }

                    overviewSection(text.transportTitle) {
                        LazyVStack(spacing: 0) {
                            ForEach(text.transportRows) { row in
                                InfoRow(label: row.label, value: row.value)
                            }
                        }
                        OverviewTagCloud(title: text.internationalRoutesTitle, items: text.internationalRoutes)
                        OverviewTagCloud(title: text.airportsTitle, items: text.airports)
                        OverviewNoteCard(text: text.transportNote, tint: Color(hex: "#38BDF8"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 50)
            }
        }
        .background(Color(hex: "#06080F"))
        .navigationTitle(text.navigationTitle)
        .nlNavigationInline()
    }

    @ViewBuilder
    private func overviewSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom("Syne-Bold", size: 18))
                .foregroundStyle(.white)
            content()
        }
    }
}

private struct NetherlandsOverviewStat: Identifiable {
    let id: String
    let icon: String
    let label: String
    let value: String

    init(_ icon: String, _ label: String, _ value: String) {
        self.id = "\(label)-\(value)"
        self.icon = icon
        self.label = label
        self.value = value
    }
}

private struct NetherlandsOverviewRow: Identifiable {
    let id: String
    let label: String
    let value: String

    init(_ label: String, _ value: String) {
        self.id = "\(label)-\(value)"
        self.label = label
        self.value = value
    }
}

private struct NetherlandsOverviewFact: Identifiable {
    let id: String
    let icon: String
    let title: String
    let value: String

    init(_ icon: String, _ title: String, _ value: String) {
        self.id = title
        self.icon = icon
        self.title = title
        self.value = value
    }
}

private struct LocalizedUniversityInfo: Identifiable {
    let id: String
    let name: String
    let subtitle: String

    init(_ name: String, _ subtitle: String) {
        self.id = name
        self.name = name
        self.subtitle = subtitle
    }
}

private struct NetherlandsOverviewText {
    let lang: AppLanguage

    var countryName: String {
        localized("Kingdom of the Netherlands", "Koninkrijk der Nederlanden", "Королевство Нидерландов")
    }

    var navigationTitle: String {
        localized("Netherlands", "Nederland", "Нидерланды")
    }

    var tagline: String {
        localized(
            "Water, bikes, trade, design, and a practical culture shaped by centuries of engineering.",
            "Water, fietsen, handel, design en een praktische cultuur gevormd door eeuwen waterbouw.",
            "Вода, велосипеды, торговля, дизайн и практичная культура, сформированная веками инженерии."
        )
    }

    var keyFactsTitle: String { localized("Key facts", "Kerngegevens", "Ключевые факты") }
    var countryOverviewTitle: String { localized("Country overview", "Land in het kort", "Обзор страны") }
    var factsTitle: String { localized("Facts", "Feiten", "Факты") }
    var governmentTitle: String { localized("Government", "Bestuur", "Государство") }
    var economyTitle: String { localized("Economy", "Economie", "Экономика") }
    var educationTitle: String { localized("Education", "Onderwijs", "Образование") }
    var healthcareTitle: String { localized("Healthcare", "Zorg", "Здравоохранение") }
    var housingTitle: String { localized("Housing", "Wonen", "Жильё") }
    var transportTitle: String { localized("Transport", "Vervoer", "Транспорт") }
    var keySectorsTitle: String { localized("Key sectors", "Belangrijke sectoren", "Ключевые сектора") }
    var companiesTitle: String { localized("Companies", "Bedrijven", "Компании") }
    var majorHospitalsTitle: String { localized("Major hospitals", "Grote ziekenhuizen", "Крупные больницы") }
    var whereToSearchTitle: String { localized("Where to search", "Waar zoeken", "Где искать") }
    var internationalRoutesTitle: String { localized("International routes", "Internationale routes", "Международные маршруты") }
    var airportsTitle: String { localized("Airports", "Luchthavens", "Аэропорты") }

    var stats: [NetherlandsOverviewStat] {
        [
            NetherlandsOverviewStat("👥", localized("Population", "Bevolking", "Население"), localized("about 18 million", "ongeveer 18 miljoen", "около 18 миллионов")),
            NetherlandsOverviewStat("📐", localized("Area", "Oppervlakte", "Площадь"), "41,543 km²"),
            NetherlandsOverviewStat("💰", localized("GDP", "BBP", "ВВП"), localized("about €1.1 trillion", "ongeveer €1,1 biljoen", "около €1,1 трлн")),
            NetherlandsOverviewStat("🌍", localized("International life", "Internationaal leven", "Международная жизнь"), localized("major cities", "grote steden", "крупные города")),
            NetherlandsOverviewStat("🚲", localized("Bikes", "Fietsen", "Велосипеды"), localized("more than residents", "meer dan inwoners", "больше, чем жителей")),
            NetherlandsOverviewStat("🌷", localized("Flowers", "Bloemen", "Цветы"), localized("major export sector", "grote exportsector", "крупный экспортный сектор"))
        ]
    }

    var overview: String {
        localized(
            """
            The Netherlands (Nederland) is a country in Northwestern Europe, bordered by Germany to the east, Belgium to the south, and the North Sea to the north and west. Despite its small size, it is one of the world's most densely populated countries and a major exporter of food and agricultural products.

            The country is famous for its flat landscape, canal systems, windmills, tulip fields, cycling culture, and direct practical culture. A large share of the land lies below sea level and is protected by dikes, pumps, and water-management systems.

            The Netherlands became a major maritime and trading power in the 17th century, the Dutch Golden Age, when Amsterdam was one of the world's most important trading cities.
            """,
            """
            Nederland is een land in Noordwest-Europa, met Duitsland in het oosten, België in het zuiden en de Noordzee in het noorden en westen. Ondanks de kleine oppervlakte is het een van de dichtstbevolkte landen ter wereld en een belangrijke exporteur van voedsel en landbouwproducten.

            Het land staat bekend om vlak landschap, grachten, molens, tulpenvelden, fietscultuur en een directe, praktische cultuur. Een groot deel van het land ligt onder zeeniveau en wordt beschermd door dijken, gemalen en waterbeheersystemen.

            In de 17e eeuw, de Gouden Eeuw, werd Nederland een belangrijke zeevaart- en handelsmacht. Amsterdam was toen een van de belangrijkste handelssteden ter wereld.
            """,
            """
            Нидерланды (Nederland) — страна в Северо-Западной Европе: на востоке она граничит с Германией, на юге с Бельгией, а на севере и западе омывается Северным морем. Несмотря на небольшую площадь, это одна из самых густонаселённых стран мира и крупный экспортёр продовольствия и сельхозпродукции.

            Страна известна ровным ландшафтом, каналами, мельницами, тюльпанами, велосипедной культурой и прямым практичным стилем жизни. Значительная часть земли находится ниже уровня моря и защищена дамбами, насосами и системами управления водой.

            В XVII веке, во время Голландского золотого века, Нидерланды стали крупной морской и торговой державой, а Amsterdam был одним из важнейших торговых городов мира.
            """
        )
    }

    var fastFacts: [NetherlandsOverviewFact] {
        [
            NetherlandsOverviewFact("🌷", localized("Tulip country", "Tulpenland", "Страна тюльпанов"), localized("Major flower and bulb export sector", "Belangrijke exportsector voor bloemen en bollen", "Крупный экспорт цветов и луковиц")),
            NetherlandsOverviewFact("🚲", localized("Bike country", "Fietsland", "Страна велосипедов"), localized("More bicycles than residents", "Meer fietsen dan inwoners", "Велосипедов больше, чем жителей")),
            NetherlandsOverviewFact("💧", localized("Below sea level", "Onder zeeniveau", "Ниже уровня моря"), localized("A large share of land is below sea level", "Een groot deel van het land ligt onder zeeniveau", "Значительная часть земли ниже уровня моря")),
            NetherlandsOverviewFact("🏗️", localized("Delta Works", "Deltawerken", "Дельта-проект"), localized("One of the world's largest flood protection systems", "Een van de grootste waterkeringen ter wereld", "Одна из крупнейших систем защиты от наводнений")),
            NetherlandsOverviewFact("⚓", localized("Rotterdam Port", "Haven van Rotterdam", "Порт Роттердама"), localized("Largest seaport in Europe", "Grootste zeehaven van Europa", "Крупнейший морской порт Европы")),
            NetherlandsOverviewFact("🧀", localized("Cheese exports", "Kaasexport", "Экспорт сыра"), localized("Important dairy and food export sector", "Belangrijke zuivel- en voedselexport", "Важный экспорт молочных и пищевых продуктов")),
            NetherlandsOverviewFact("☁️", localized("Rainy days", "Regendagen", "Дождливые дни"), localized("Rain is common throughout the year", "Regen komt het hele jaar vaak voor", "Дожди возможны в любое время года")),
            NetherlandsOverviewFact("🌍", localized("International services", "Internationale diensten", "Международные сервисы"), localized("English-friendly services in major cities", "Engelstalige hulp is gebruikelijk in grote steden", "В крупных городах часто помогают на английском"))
        ]
    }

    var governmentRows: [NetherlandsOverviewRow] {
        [
            NetherlandsOverviewRow(localized("👑 Monarch", "👑 Koning", "👑 Монарх"), localized("King Willem-Alexander", "Koning Willem-Alexander", "Король Willem-Alexander")),
            NetherlandsOverviewRow(localized("🏛️ Anthem", "🏛️ Volkslied", "🏛️ Гимн"), localized("Het Wilhelmus, one of the oldest national anthems", "Het Wilhelmus, een van de oudste volksliederen", "Het Wilhelmus, один из старейших гимнов")),
            NetherlandsOverviewRow(localized("💶 Currency", "💶 Munt", "💶 Валюта"), localized("Euro (€)", "Euro (€)", "Евро (€)")),
            NetherlandsOverviewRow(localized("🗣️ Languages", "🗣️ Talen", "🗣️ Языки"), localized("Dutch, Frisian, and widely spoken English", "Nederlands, Fries en veel Engels", "Нидерландский, фризский и часто английский")),
            NetherlandsOverviewRow(localized("🕐 Time zone", "🕐 Tijdzone", "🕐 Часовой пояс"), localized("CET (UTC+1) · CEST in summer", "CET (UTC+1) · CEST in de zomer", "CET (UTC+1) · CEST летом")),
            NetherlandsOverviewRow(localized("📞 Country code", "📞 Landnummer", "📞 Код страны"), "+31"),
            NetherlandsOverviewRow(localized("🌐 Internet domain", "🌐 Internetdomein", "🌐 Интернет-домен"), ".nl"),
            NetherlandsOverviewRow(localized("🚗 Driving side", "🚗 Rijrichting", "🚗 Сторона движения"), localized("Right", "Rechts", "Правая"))
        ]
    }

    var economyRows: [NetherlandsOverviewRow] {
        [
            NetherlandsOverviewRow(localized("💰 GDP", "💰 BBP", "💰 ВВП"), localized("about €1.1 trillion", "ongeveer €1,1 biljoen", "около €1,1 трлн")),
            NetherlandsOverviewRow(localized("👤 GDP/person", "👤 BBP per persoon", "👤 ВВП на человека"), localized("about €61,500 per person", "ongeveer €61.500 per persoon", "около €61 500 на человека")),
            NetherlandsOverviewRow(localized("🏆 Rank", "🏆 Rang", "🏆 Ранг"), localized("Top 20 globally, top 5 in the EU", "Wereldwijd top 20, in de EU top 5", "Топ-20 в мире, топ-5 в ЕС")),
            NetherlandsOverviewRow(localized("📈 Stock exchange", "📈 Beurs", "📈 Биржа"), localized("Euronext Amsterdam is one of the world's oldest exchanges", "Euronext Amsterdam is een van de oudste beurzen ter wereld", "Euronext Amsterdam — одна из старейших бирж мира")),
            NetherlandsOverviewRow(localized("📉 Unemployment", "📉 Werkloosheid", "📉 Безработица"), localized("Low by EU comparison; check CBS for latest data", "Laag binnen de EU; controleer actuele CBS-cijfers", "Низкая по меркам ЕС; проверяйте свежие данные CBS")),
            NetherlandsOverviewRow(localized("🧾 Taxes", "🧾 Belastingen", "🧾 Налоги"), localized("Progressive income tax; check Belastingdienst", "Progressieve inkomstenbelasting; controleer Belastingdienst", "Прогрессивный подоходный налог; проверяйте Belastingdienst")),
            NetherlandsOverviewRow("🧾 BTW/VAT", localized("21% standard VAT / 9% reduced rate", "21% standaard-btw / 9% verlaagd tarief", "21% стандартный НДС / 9% сниженная ставка")),
            NetherlandsOverviewRow(localized("💶 Minimum wage", "💶 Minimumloon", "💶 Минимальная зарплата"), localized("Statutory hourly minimum wage; verify current rate", "Wettelijk minimumuurloon; controleer het actuele bedrag", "Законная почасовая минимальная оплата; проверяйте актуальную ставку")),
            NetherlandsOverviewRow(localized("🚢 Exports", "🚢 Export", "🚢 Экспорт"), localized("One of the world's largest goods exporters", "Een van de grootste goederenexporteurs ter wereld", "Один из крупнейших экспортёров товаров в мире")),
            NetherlandsOverviewRow(localized("🌾 Agri exports", "🌾 Landbouwexport", "🌾 Агроэкспорт"), localized("Major global exporter of food and agriculture", "Grote wereldwijde exporteur van voedsel en landbouw", "Крупный мировой экспортёр продовольствия и сельхозпродукции")),
            NetherlandsOverviewRow("⚓ Rotterdam", localized("Europe's largest seaport and logistics hub", "Grootste zeehaven van Europa en logistieke hub", "Крупнейший морской порт Европы и логистический центр")),
            NetherlandsOverviewRow(localized("💼 Work culture", "💼 Werkcultuur", "💼 Рабочая культура"), localized("Direct communication, punctuality, written agreements, work-life balance", "Directe communicatie, punctualiteit, schriftelijke afspraken en balans", "Прямое общение, пунктуальность, письменные договорённости и баланс"))
        ]
    }

    var keySectors: [String] {
        localizedArray(
            ["Finance", "Logistics", "Agriculture", "Technology", "Chemicals"],
            ["Financiën", "Logistiek", "Landbouw", "Technologie", "Chemie"],
            ["Финансы", "Логистика", "Сельское хозяйство", "Технологии", "Химия"]
        )
    }

    var companies: [String] {
        ["Philips", "Shell", "ING", "ABN AMRO", "Heineken", "ASML", "Booking.com", "Adyen"]
    }

    var economyNote: String {
        localized(
            "To work, you usually need a BSN, bank account, registered address, health insurance, and a clear employment contract.",
            "Om te werken hebt u meestal een BSN, bankrekening, geregistreerd adres, zorgverzekering en duidelijke arbeidsovereenkomst nodig.",
            "Для работы обычно нужны BSN, банковский счёт, зарегистрированный адрес, медицинская страховка и понятный трудовой договор."
        )
    }

    var educationRows: [NetherlandsOverviewRow] {
        [
            NetherlandsOverviewRow(localized("🎓 System", "🎓 Systeem", "🎓 Система"), localized("Primary school, secondary school, MBO, HBO, and WO", "Basisschool, voortgezet onderwijs, MBO, HBO en WO", "Начальная школа, средняя школа, MBO, HBO и WO")),
            NetherlandsOverviewRow(localized("👧 Compulsory", "👧 Leerplicht", "👧 Обязательное обучение"), localized("School is compulsory from about age 5 to 16, with qualification duty until 18", "Onderwijs is verplicht van ongeveer 5 tot 16 jaar, met kwalificatieplicht tot 18", "Школа обязательна примерно с 5 до 16 лет, затем действует обязанность получить квалификацию до 18")),
            NetherlandsOverviewRow(localized("🌍 International students", "🌍 Internationale studenten", "🌍 Иностранные студенты"), localized("Large international student population", "Grote internationale studentenpopulatie", "Много иностранных студентов")),
            NetherlandsOverviewRow(localized("🇬🇧 English", "🇬🇧 Engels", "🇬🇧 Английский"), localized("Many bachelor and master programmes are in English", "Veel bachelor- en masteropleidingen zijn Engelstalig", "Многие программы бакалавриата и магистратуры на английском")),
            NetherlandsOverviewRow(localized("💶 EU tuition", "💶 Collegegeld EU", "💶 Оплата для ЕС"), localized("Statutory tuition may apply; check DUO for the current year", "Wettelijk collegegeld kan gelden; controleer DUO voor het huidige jaar", "Может действовать установленная законом плата; проверяйте DUO на текущий год")),
            NetherlandsOverviewRow(localized("🌍 non-EU", "🌍 niet-EU", "🌍 не ЕС"), localized("Institutional tuition varies by programme and university", "Instellingscollegegeld verschilt per opleiding en universiteit", "Плата зависит от программы и университета")),
            NetherlandsOverviewRow(localized("🎁 Scholarships", "🎁 Beurzen", "🎁 Стипендии"), localized("Scholarships vary by university, nationality, and programme", "Beurzen verschillen per universiteit, nationaliteit en opleiding", "Стипендии зависят от университета, гражданства и программы")),
            NetherlandsOverviewRow("🏛️ DUO", localized("DUO handles student finance and education administration", "DUO regelt studiefinanciering en onderwijsadministratie", "DUO занимается студенческими финансами и образовательной администрацией")),
            NetherlandsOverviewRow("🧭 MBO/HBO/WO", localized("MBO is vocational, HBO is applied sciences, WO is research university", "MBO is beroepsonderwijs, HBO is toegepast, WO is universiteit", "MBO — профобразование, HBO — прикладное, WO — исследовательский университет"))
        ]
    }

    var topUniversities: [LocalizedUniversityInfo] {
        localizedUniversities
    }

    var educationNote: String {
        localized(
            "Register children through the municipality or directly with the school. Students should verify housing, insurance, and registration before arrival.",
            "Schrijf kinderen in via de gemeente of direct bij de school. Studenten controleren best huisvesting, verzekering en registratie voor aankomst.",
            "Детей записывают через муниципалитет или напрямую в школу. Студентам стоит заранее проверить жильё, страховку и регистрацию."
        )
    }

    var healthcareRows: [NetherlandsOverviewRow] {
        [
            NetherlandsOverviewRow(localized("🩺 System", "🩺 Systeem", "🩺 Система"), localized("Mandatory basic insurance from private insurers under public rules", "Verplichte basisverzekering bij private verzekeraars onder publieke regels", "Обязательная базовая страховка у частных страховщиков по государственным правилам")),
            NetherlandsOverviewRow(localized("💳 Premium", "💳 Premie", "💳 Премия"), localized("Monthly premiums vary by insurer and package", "Maandpremies verschillen per verzekeraar en pakket", "Ежемесячная премия зависит от страховщика и пакета")),
            NetherlandsOverviewRow("📌 Eigen risico", localized("A compulsory deductible applies to many healthcare costs", "Een verplicht eigen risico geldt voor veel zorgkosten", "Обязательная франшиза применяется ко многим медицинским расходам")),
            NetherlandsOverviewRow("💶 Zorgtoeslag", localized("Healthcare allowance may depend on income and household", "Zorgtoeslag kan afhangen van inkomen en huishouden", "Пособие на страховку зависит от дохода и состава семьи")),
            NetherlandsOverviewRow("👨‍⚕️ Huisarts", localized("Register with a GP; they are the usual route to specialist care", "Schrijf u in bij een huisarts; die verwijst meestal naar specialistische zorg", "Зарегистрируйтесь у семейного врача; через него обычно попадают к специалистам")),
            NetherlandsOverviewRow(localized("🚑 Emergency", "🚑 Spoed", "🚑 Экстренно"), localized("112 for emergencies; 0900-8844 for non-emergency police", "112 bij spoed; 0900-8844 voor politie zonder spoed", "112 для экстренных случаев; 0900-8844 для полиции без срочности")),
            NetherlandsOverviewRow("🧠 GGZ", localized("Mental healthcare usually starts with a GP referral", "Geestelijke gezondheidszorg start meestal via de huisarts", "Психологическая помощь обычно начинается с направления от врача")),
            NetherlandsOverviewRow(localized("🦷 Dentist", "🦷 Tandarts", "🦷 Стоматолог"), localized("Adult dental care is usually outside basic insurance", "Tandzorg voor volwassenen valt meestal buiten de basisverzekering", "Стоматология для взрослых обычно не входит в базовую страховку")),
            NetherlandsOverviewRow("💊 Apotheek", localized("A pharmacy provides prescribed medicine and advice", "Een apotheek levert voorgeschreven medicijnen en advies", "Аптека выдаёт рецептурные лекарства и консультирует")),
            NetherlandsOverviewRow(localized("⏱️ Deadline", "⏱️ Deadline", "⏱️ Срок"), localized("Arrange insurance promptly after the obligation starts", "Regel verzekering snel nadat de verplichting begint", "Оформите страховку вскоре после возникновения обязанности"))
        ]
    }

    var majorHospitals: [String] {
        ["Amsterdam UMC", "Erasmus MC Rotterdam", "UMCG Groningen", "UMC Utrecht", "MUMC+ Maastricht"]
    }

    var healthcareNote: String {
        localized(
            "Find a GP near your address, save your insurance policy number, and check whether you qualify for healthcare allowance.",
            "Zoek een huisarts bij uw adres, bewaar uw polisnummer en controleer of u recht hebt op zorgtoeslag.",
            "Найдите семейного врача рядом с адресом, сохраните номер полиса и проверьте право на zorgtoeslag."
        )
    }

    var housingRows: [NetherlandsOverviewRow] {
        [
            NetherlandsOverviewRow(localized("🏠 Studio", "🏠 Studio", "🏠 Студия"), localized("Studio rents are often high in larger cities", "Studiohuur is vaak hoog in grotere steden", "Аренда студий часто высокая в крупных городах")),
            NetherlandsOverviewRow(localized("🛏️ One bedroom", "🛏️ Een slaapkamer", "🛏️ Одна спальня"), localized("One-bedroom rents are usually highest in the Randstad", "Een-slaapkamerwoningen zijn meestal het duurst in de Randstad", "Квартиры с одной спальней обычно дороже всего в Randstad")),
            NetherlandsOverviewRow(localized("👨‍👩‍👧 Family home", "👨‍👩‍👧 Gezinswoning", "👨‍👩‍👧 Семейное жильё"), localized("Family housing is competitive in popular urban areas", "Gezinswoningen zijn schaars in populaire steden", "Семейное жильё востребовано в популярных городах")),
            NetherlandsOverviewRow("Amsterdam", localized("Usually among the most expensive rental markets", "Meestal een van de duurste huurmarkten", "Обычно один из самых дорогих рынков аренды")),
            NetherlandsOverviewRow("Rotterdam", localized("Competitive but often below Amsterdam prices", "Concurrerend, maar vaak lager dan Amsterdam", "Конкурентный рынок, но часто дешевле Amsterdam")),
            NetherlandsOverviewRow("Utrecht", localized("High demand and limited supply", "Veel vraag en beperkt aanbod", "Высокий спрос и ограниченное предложение")),
            NetherlandsOverviewRow("Leiden", localized("Strong student and expat demand", "Veel vraag van studenten en expats", "Высокий спрос со стороны студентов и экспатов")),
            NetherlandsOverviewRow("Groningen", localized("Student-heavy market with pressure on rooms", "Studentenstad met druk op kamers", "Студенческий город с дефицитом комнат")),
            NetherlandsOverviewRow(localized("🏘️ Social", "🏘️ Sociaal", "🏘️ Социальное"), localized("Waiting lists can be long, especially in major cities", "Wachtlijsten kunnen lang zijn, vooral in grote steden", "Очереди могут быть длинными, особенно в крупных городах")),
            NetherlandsOverviewRow("🔓 Vrije sector", localized("Private-sector rents depend on contract, points system, and local demand", "Vrije-sectorhuur hangt af van contract, puntensysteem en lokale vraag", "Свободная аренда зависит от договора, баллов и местного спроса")),
            NetherlandsOverviewRow("⚖️ Huurcommissie", localized("Can assess rent, service costs, and some tenancy disputes", "Kan huur, servicekosten en sommige huurgeschillen beoordelen", "Может оценивать аренду, сервисные расходы и некоторые споры")),
            NetherlandsOverviewRow(localized("🔑 Buying", "🔑 Kopen", "🔑 Покупка"), localized("Mortgage options depend on income, contract, debts, and valuation", "Hypotheek hangt af van inkomen, contract, schulden en taxatie", "Ипотека зависит от дохода, контракта, долгов и оценки")),
            NetherlandsOverviewRow(localized("🔐 Deposit", "🔐 Borg", "🔐 Депозит"), localized("Deposits are commonly one or two months of rent", "Borg is vaak een of twee maanden huur", "Депозит часто равен одному-двум месяцам аренды")),
            NetherlandsOverviewRow("📍 BRP", localized("Check whether registration is allowed at the address", "Controleer of inschrijving op het adres mag", "Проверьте, разрешена ли регистрация по адресу")),
            NetherlandsOverviewRow("💶 Huurtoeslag", localized("Rent benefit depends on rent, income, assets, age, and household", "Huurtoeslag hangt af van huur, inkomen, vermogen, leeftijd en huishouden", "Пособие зависит от аренды, дохода, имущества, возраста и семьи")),
            NetherlandsOverviewRow(localized("⚖️ Tenant rights", "⚖️ Huurrechten", "⚖️ Права арендатора"), localized("Rent and quality disputes can be checked with Huurcommissie or Juridisch Loket", "Huur- en kwaliteitsgeschillen kunnen via Huurcommissie of Juridisch Loket", "Споры по аренде и качеству можно проверить через Huurcommissie или Juridisch Loket"))
        ]
    }

    var housingPlatforms: [String] {
        ["Funda.nl", "Pararius.nl", "Kamernet.nl", "Huurwoningen.nl"]
    }

    var housingNote: String {
        localized(
            "Do not transfer a deposit without a contract. Verify the landlord and photograph the home condition when moving in.",
            "Maak geen borg over zonder contract. Controleer de verhuurder en fotografeer de woning bij intrek.",
            "Не переводите депозит без договора. Проверьте арендодателя и сфотографируйте состояние жилья при въезде."
        )
    }

    var transportRows: [NetherlandsOverviewRow] {
        [
            NetherlandsOverviewRow(localized("🚆 Rail", "🚆 Spoor", "🚆 Железная дорога"), "NS (Nederlandse Spoorwegen)"),
            NetherlandsOverviewRow(localized("🗺️ Network", "🗺️ Netwerk", "🗺️ Сеть"), localized("Dense national rail network with frequent services", "Dicht landelijk spoornet met frequente diensten", "Плотная железнодорожная сеть с частыми рейсами")),
            NetherlandsOverviewRow(localized("⚡ Fast route", "⚡ Snelle route", "⚡ Быстрый маршрут"), localized("Amsterdam-Rotterdam has fast Intercity Direct services", "Amsterdam-Rotterdam heeft snelle Intercity Direct-diensten", "Amsterdam-Rotterdam обслуживается быстрыми Intercity Direct")),
            NetherlandsOverviewRow(localized("🌍 International", "🌍 Internationaal", "🌍 Международно"), localized("Trains connect Amsterdam with Belgium, France, Germany, and the UK", "Treinen verbinden Amsterdam met Belgie, Frankrijk, Duitsland en het VK", "Поезда соединяют Amsterdam с Бельгией, Францией, Германией и Великобританией")),
            NetherlandsOverviewRow(localized("🚲 Cycling", "🚲 Fietsen", "🚲 Велосипед"), localized("Cycling is central to daily transport, with extensive bike lanes", "Fietsen is centraal in dagelijks vervoer, met veel fietspaden", "Велосипед важен в повседневном транспорте, сеть велодорожек обширна")),
            NetherlandsOverviewRow(localized("🅿️ Bike parking", "🅿️ Fietsparkeren", "🅿️ Велопарковка"), localized("Major stations provide large bicycle parking facilities", "Grote stations hebben grote fietsenstallingen", "На крупных станциях есть большие велопарковки")),
            NetherlandsOverviewRow(localized("💳 Payment", "💳 Betalen", "💳 Оплата"), localized("OV-chipkaart and OVpay support check-in/check-out", "OV-chipkaart en OVpay ondersteunen in- en uitchecken", "OV-chipkaart и OVpay поддерживают check-in/check-out")),
            NetherlandsOverviewRow(localized("🎓 OV pass", "🎓 OV-product", "🎓 Проездной OV"), localized("Student travel products and subscriptions depend on eligibility", "Studentenreisproducten en abonnementen hangen af van recht", "Студенческие проездные и абонементы зависят от права")),
            NetherlandsOverviewRow(localized("🚗 Speeds", "🚗 Snelheden", "🚗 Скорости"), localized("Speed limits vary by road, time, and vehicle type", "Snelheidslimieten verschillen per weg, tijd en voertuig", "Ограничения зависят от дороги, времени и типа транспорта")),
            NetherlandsOverviewRow(localized("⚠️ Rules", "⚠️ Regels", "⚠️ Правила"), localized("Use lights, working brakes, and correct parking", "Gebruik verlichting, werkende remmen en correcte parkeerplekken", "Нужны свет, исправные тормоза и правильная парковка"))
        ]
    }

    var internationalRoutes: [String] {
        localizedArray(
            ["Eurostar: Amsterdam-Brussels-Paris", "Eurostar: Amsterdam-London", "ICE: Amsterdam-Frankfurt"],
            ["Eurostar: Amsterdam-Brussel-Parijs", "Eurostar: Amsterdam-Londen", "ICE: Amsterdam-Frankfurt"],
            ["Eurostar: Amsterdam-Brussels-Paris", "Eurostar: Amsterdam-London", "ICE: Amsterdam-Frankfurt"]
        )
    }

    var airports: [String] {
        ["Amsterdam Airport Schiphol", "Rotterdam The Hague Airport", "Eindhoven Airport"]
    }

    var transportNote: String {
        localized(
            "For daily life, set up NS, 9292, OVpay, a strong bike lock, and routes to your municipality, GP, and workplace.",
            "Voor dagelijks leven: regel NS, 9292, OVpay, een sterk fietsslot en routes naar gemeente, huisarts en werk.",
            "Для повседневной жизни настройте NS, 9292, OVpay, купите хороший велозамок и сохраните маршруты к муниципалитету, врачу и работе."
        )
    }

    private var localizedUniversities: [LocalizedUniversityInfo] {
        [
            LocalizedUniversityInfo("Leiden University", localized("Leiden · founded 1575 · QS-ranked · law, medicine, humanities", "Leiden · opgericht in 1575 · QS-ranking · rechten, geneeskunde, geesteswetenschappen", "Leiden · основан в 1575 · рейтинг QS · право, медицина, гуманитарные науки")),
            LocalizedUniversityInfo("Delft University of Technology", localized("Delft · founded 1842 · QS-ranked · engineering, architecture, technology", "Delft · opgericht in 1842 · QS-ranking · techniek, architectuur, technologie", "Delft · основан в 1842 · рейтинг QS · инженерия, архитектура, технологии")),
            LocalizedUniversityInfo("Utrecht University", localized("Utrecht · founded 1636 · QS-ranked · life sciences, climate, education", "Utrecht · opgericht in 1636 · QS-ranking · levenswetenschappen, klimaat, onderwijs", "Utrecht · основан в 1636 · рейтинг QS · науки о жизни, климат, образование")),
            LocalizedUniversityInfo("University of Amsterdam", localized("Amsterdam · founded 1632 · QS-ranked · social sciences, economics, AI", "Amsterdam · opgericht in 1632 · QS-ranking · sociale wetenschappen, economie, AI", "Amsterdam · основан в 1632 · рейтинг QS · социальные науки, экономика, ИИ")),
            LocalizedUniversityInfo("Eindhoven University of Technology", localized("Eindhoven · founded 1956 · QS-ranked · high tech, design, engineering", "Eindhoven · opgericht in 1956 · QS-ranking · hightech, design, techniek", "Eindhoven · основан в 1956 · рейтинг QS · high tech, дизайн, инженерия")),
            LocalizedUniversityInfo("University of Groningen", localized("Groningen · founded 1614 · QS-ranked · medicine, energy, northern studies", "Groningen · opgericht in 1614 · QS-ranking · geneeskunde, energie, noordelijke studies", "Groningen · основан в 1614 · рейтинг QS · медицина, энергетика, северные исследования")),
            LocalizedUniversityInfo("Maastricht University", localized("Maastricht · founded 1976 · QS-ranked · international law, medicine, EU studies", "Maastricht · opgericht in 1976 · QS-ranking · internationaal recht, geneeskunde, EU-studies", "Maastricht · основан в 1976 · рейтинг QS · международное право, медицина, исследования ЕС"))
        ]
    }

    private func localizedArray(_ en: [String], _ nl: [String], _ ru: [String]) -> [String] {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }

    private func localized(_ en: String, _ nl: String, _ ru: String) -> String {
        switch lang {
        case .english: return en
        case .dutch: return nl
        case .russian: return ru
        }
    }
}

struct OverviewStatCard: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon)
                .font(.system(size: 22))
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.42))
                    .textCase(.uppercase)
                Text(value)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
        .padding(12)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 0.7))
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(maxWidth: 140, alignment: .leading)
                Text(value)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.vertical, 8)
            Divider().background(Color.white.opacity(0.05))
        }
    }
}

struct OverviewTagCloud: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.54))
                .textCase(.uppercase)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: 8)], spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .frame(maxWidth: .infinity, minHeight: 38, alignment: .leading)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 0.7))
                }
            }
        }
    }
}

struct OverviewNoteCard: View {
    let text: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tint)
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.82))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(tint.opacity(0.20), lineWidth: 0.7))
    }
}

private struct UniversityOverviewRow: View {
    let university: LocalizedUniversityInfo

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(hex: "#2DD4BF"))
                .frame(width: 30, height: 30)
                .background(Color(hex: "#2DD4BF").opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(university.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(university.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.58))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 0.7))
    }
}
