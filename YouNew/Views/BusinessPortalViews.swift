import SwiftUI

struct HomePlacesToVisitSection: View {
    let places: [PlaceItem]
    let city: String
    let language: AppLanguage
    @EnvironmentObject private var savedStore: SavedItemsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(localized("Discover near you", "Ontdek in de buurt", "Куда сходить рядом"))
                        .font(.title3.bold())
                        .foregroundStyle(AppColors.textPrimary)
                    Text(localized("Curated places in \(city)", "Geselecteerde plekken in \(city)", "Проверенные места в городе \(city)"))
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                NavigationLink(value: AppDestination.mapHub) {
                    Text(localized("View all", "Alles", "Все"))
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColors.accent)
                }
            }

            if places.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label(localized("Discover places in this city", "Ontdek plekken in deze stad", "Откройте места в этом городе"), systemImage: "map.fill")
                        .font(AppTypography.bodyStrong)
                    Text(localized("The city guide remains available while curated local cards are being verified.", "De stadsgids blijft beschikbaar terwijl lokale kaarten worden gecontroleerd.", "Городской гид доступен, пока локальные карточки проходят проверку."))
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(14)
                .appGlassCardStyle(padding: 0, cornerRadius: 17, accent: AppColors.cyanGlow)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(places) { place in
                            discoveryCard(place)
                                .frame(width: 244)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
            }
        }
        .accessibilityIdentifier("home.placesToVisit")
    }

    private func discoveryCard(_ place: PlaceItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink(value: place.destination) {
                ZStack(alignment: .bottomLeading) {
                    placeImage(place)
                    LinearGradient(colors: [.clear, AppColors.navyDeep.opacity(0.94)], startPoint: .center, endPoint: .bottom)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(commercialLabel(for: place))
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.cyanGlow)
                        Text(place.title)
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                    }
                    .padding(12)
                }
                .frame(height: 142)
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
            }
            .buttonStyle(AppPressableCardButtonStyle())
            .accessibilityIdentifier("home.place.\(place.id)")

            Text(place.description)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)

            HStack(spacing: 8) {
                NavigationLink(value: place.destination) {
                    Label(localized("Open", "Open", "Открыть"), systemImage: "arrow.up.right")
                        .font(AppTypography.captionStrong)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 11))
                        .foregroundStyle(.white)
                }
                Button {
                    savedStore.toggle(id: place.id, kind: .place, title: place.title, subtitle: place.cityId, destination: place.destination)
                } label: {
                    Image(systemName: savedStore.isSaved(place.id) ? "heart.fill" : "heart")
                        .frame(width: 42, height: 38)
                        .foregroundStyle(savedStore.isSaved(place.id) ? AppColors.error : AppColors.textPrimary)
                        .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 11))
                }
                .accessibilityLabel(localized("Save \(place.title)", "Bewaar \(place.title)", "Сохранить \(place.title)"))
            }
        }
        .padding(11)
        .appGlassCardStyle(padding: 0, cornerRadius: 20, accent: AppColors.cyanGlow)
    }

    private func placeImage(_ place: PlaceItem) -> some View {
        PremiumImageView(
            asset: imageAsset(for: place),
            language: language,
            height: 142,
            aspectRatio: nil,
            mode: .fill,
            cornerRadius: 0,
            overlayStyle: .none,
            fallbackCategory: .city,
            accessibilityLabel: place.title,
            targetPixelWidth: 640,
            role: .thumbnail,
            overlayPolicy: .none
        )
    }

    private func imageAsset(for place: PlaceItem) -> AppImageAsset? {
        guard let raw = place.image, let url = URL(string: raw) else { return nil }
        return AppImageAsset(
            id: "home-discovery-\(place.id)",
            url: url,
            sourcePageURL: place.source?.url,
            imageURL: url,
            thumbnailURL: url,
            title: place.title,
            description: place.description,
            sourceName: place.source?.institution ?? place.source?.title ?? "Curated place catalog",
            sourceURL: place.source?.url,
            license: nil,
            attribution: place.source?.title,
            width: nil,
            height: nil,
            type: .cardThumbnail,
            verified: place.source != nil
        )
    }

    private func commercialLabel(for place: PlaceItem) -> String {
        // Canonical city places are editorial/organic. Commercial partners use LocalPartner labels.
        localized("Organic · \(place.primaryCategory.rawValue)", "Organisch · \(place.primaryCategory.rawValue)", "Органическое · \(place.primaryCategory.rawValue)")
    }

    private func localized(_ en: String, _ nl: String, _ ru: String) -> String {
        switch language { case .english: en; case .dutch: nl; case .russian: ru }
    }
}

struct HomeBusinessEntryCard: View {
    let language: AppLanguage
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(localized("FOR BUSINESSES", "VOOR BEDRIJVEN", "ДЛЯ БИЗНЕСА"), systemImage: "storefront.fill")
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.cyanGlow)
            Text(localized("Grow your business with YouNew", "Groei uw bedrijf met YouNew", "Развивайте бизнес с YouNew"))
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.textPrimary)
            Text(localized("Reach newcomers, students, locals and visitors in the Netherlands.", "Bereik nieuwkomers, studenten, inwoners en bezoekers in Nederland.", "Расскажите о бизнесе новым жителям, студентам, местным и гостям Нидерландов."))
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
            HStack(spacing: 8) {
                NavigationLink(value: AppDestination.businessGrowth) {
                    Text(localized("Add your business", "Bedrijf toevoegen", "Добавить бизнес"))
                        .font(AppTypography.captionStrong).frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 11)).foregroundStyle(.white)
                }
                NavigationLink(value: AppDestination.businessLogin) {
                    Text(localized("Business login", "Zakelijk inloggen", "Вход для бизнеса"))
                        .font(AppTypography.captionStrong).frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 11)).foregroundStyle(AppColors.textPrimary)
                }
            }
        }
        .padding(16)
        .appGlassCardStyle(padding: 0, cornerRadius: 18, accent: AppColors.cyanGlow)
        .accessibilityIdentifier("home.businessEntry")
    }
    private func localized(_ en: String, _ nl: String, _ ru: String) -> String {
        switch language { case .english: en; case .dutch: nl; case .russian: ru }
    }
}

struct BusinessPortalLandingView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var store = BusinessPortalStore.shared
    @State private var showRegistration = false
    private var language: AppLanguage { languageManager.appLanguage }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                CategoryHeroVisual(assetName: nil, title: "YouNew Business", subtitle: localized("Create and manage a transparent local listing. Every submission is reviewed before publication.", "Maak en beheer een transparante lokale vermelding. Elke inzending wordt beoordeeld.", "Создайте прозрачную локальную карточку. Любая публикация проходит проверку."), symbol: "storefront.fill", badgeText: localized("Separate business workspace", "Aparte zakelijke omgeving", "Отдельный бизнес-кабинет"), accent: AppColors.accent, asset: ContentMediaRegistry.workImage, height: 220, language: language)
                Button { showRegistration = true } label: {
                    Label(localized("Create business account", "Zakelijk account maken", "Создать бизнес-аккаунт"), systemImage: "plus.circle.fill").frame(maxWidth: .infinity)
                }.buttonStyle(PrimaryPremiumButtonStyle()).accessibilityIdentifier("business.createAccount")
                NavigationLink(value: AppDestination.businessLogin) {
                    Label(localized("Log in", "Inloggen", "Войти"), systemImage: "person.crop.circle").frame(maxWidth: .infinity).padding(13)
                        .background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 14)).foregroundStyle(AppColors.textPrimary)
                }
                Label(localized("Personal profile data is not shared with the business workspace.", "Persoonlijke profielgegevens worden niet gedeeld met de zakelijke omgeving.", "Данные личного профиля не передаются в бизнес-кабинет."), systemImage: "lock.shield.fill")
                    .font(AppTypography.footnote).foregroundStyle(AppColors.textSecondary).padding(14).appGlassCardStyle(padding: 0, cornerRadius: 16, accent: AppColors.success)
            }.padding(18)
        }
        .accessibilityIdentifier("business.landing")
        .appSceneBackground(.more).navigationTitle("YouNew Business")
        .sheet(isPresented: $showRegistration) { NavigationStack { BusinessRegistrationView(store: store) } }
    }
    private func localized(_ en: String, _ nl: String, _ ru: String) -> String { switch language { case .english: en; case .dutch: nl; case .russian: ru } }
}

struct BusinessPortalLoginView: View {
    @StateObject private var store = BusinessPortalStore.shared
    @State private var email = ""
    @State private var message = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Business login").font(.largeTitle.bold()).foregroundStyle(AppColors.textPrimary)
                Text("Local preview access only. Production authentication and account recovery require the secure business backend.")
                    .font(AppTypography.body).foregroundStyle(AppColors.textSecondary)
                TextField("business@company.com", text: $email).textInputAutocapitalization(.never).keyboardType(.emailAddress)
                    .padding(14).background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 14))
                Button("Continue") {
                    store.createLocalAccount(email: email)
                    message = store.snapshot.account == nil ? "Enter a valid email." : "Local workspace ready. No server session was created."
                }.buttonStyle(PrimaryPremiumButtonStyle()).disabled(!email.contains("@"))
                if !message.isEmpty { Text(message).font(AppTypography.footnote).foregroundStyle(AppColors.textSecondary) }
                if store.snapshot.account != nil {
                    NavigationLink(value: AppDestination.businessDashboard) { Label("Open dashboard", systemImage: "rectangle.grid.2x2.fill") }
                        .buttonStyle(PrimaryPremiumButtonStyle())
                }
                HStack { NavigationLink(value: AppDestination.termsOfUse) { Text("Terms") }; Spacer(); NavigationLink(value: AppDestination.privacyDataControl) { Text("Privacy") } }
                    .font(AppTypography.footnote)
            }.padding(18)
        }.appSceneBackground(.more).navigationTitle("Business login").accessibilityIdentifier("business.login")
    }
}

struct BusinessRegistrationView: View {
    @ObservedObject var store: BusinessPortalStore
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var email = ""
    @State private var profile = BusinessProfile(id: UUID().uuidString, accountID: "")
    private let titles = ["Business identity", "Location", "Business details", "Media", "Plan", "Review and submit"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ProgressView(value: Double(step + 1), total: 6).tint(AppColors.accent)
                Text("Step \(step + 1) of 6 · \(titles[step])").font(.title2.bold()).foregroundStyle(AppColors.textPrimary)
                stepContent
                HStack {
                    if step > 0 { Button("Back") { step -= 1 }.buttonStyle(.bordered) }
                    Spacer()
                    Button(step == 5 ? "Submit for review" : "Continue") { advance() }
                        .buttonStyle(PrimaryPremiumButtonStyle()).disabled(!canAdvance)
                }
            }.padding(18)
        }.appSceneBackground(.more).navigationTitle("Add your business").toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
            .accessibilityIdentifier("business.registration.step.\(step + 1)")
    }

    @ViewBuilder private var stepContent: some View {
        switch step {
        case 0:
            field("Business name", text: $profile.name); field("Category", text: $profile.category); field("KvK number (kept private)", text: $profile.kvkNumber); field("Website", text: $profile.website); field("Business email", text: $email); field("Public phone", text: $profile.publicPhone)
        case 1:
            field("City", text: $profile.location.city); field("Public business address", text: $profile.location.address); field("Service area", text: $profile.location.serviceArea); Toggle("Online only", isOn: $profile.location.isOnlineOnly)
        case 2:
            field("Short description", text: $profile.summary, axis: .vertical); field("Languages (comma separated)", text: Binding(get: { profile.languages.joined(separator: ", ") }, set: { profile.languages = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } })); field("Opening hours (optional; reviewed)", text: $profile.openingHours); field("Booking link", text: $profile.bookingURL); Toggle("Family friendly", isOn: $profile.isFamilyFriendly)
        case 3:
            Label("Add and moderate images from Gallery after the local workspace is created. Images are never published automatically.", systemImage: "photo.on.rectangle.angled")
        case 4:
            Picker("Plan", selection: $profile.plan) { ForEach(BusinessPlan.allCases) { Text($0.rawValue.capitalized).tag($0) } }.pickerStyle(.inline)
        default:
            summaryRow("Business", profile.name); summaryRow("Category", profile.category); summaryRow("City", profile.location.city); summaryRow("Plan", profile.plan.rawValue.capitalized)
            Toggle("I consent to publish the business details above after review", isOn: $profile.consentToPublish)
        }
    }

    private func field(_ title: String, text: Binding<String>, axis: Axis = .horizontal) -> some View { TextField(title, text: text, axis: axis).padding(14).background(AppColors.glassSurfaceElevated, in: RoundedRectangle(cornerRadius: 13)) }
    private func summaryRow(_ title: String, _ value: String) -> some View { HStack { Text(title).foregroundStyle(AppColors.textSecondary); Spacer(); Text(value.isEmpty ? "Not provided" : value).foregroundStyle(AppColors.textPrimary) }.font(AppTypography.body).padding(12).appGlassCardStyle(padding: 0, cornerRadius: 12, accent: AppColors.softBlue) }
    private var canAdvance: Bool { step != 0 || (!profile.name.isEmpty && !profile.category.isEmpty && email.contains("@")); }
    private func advance() {
        if step == 0 { store.createLocalAccount(email: email); if let account = store.snapshot.account { profile.accountID = account.id; profile.publicEmail = email } }
        store.saveProfile(profile)
        if step < 5 { step += 1 } else { store.submitForReview(); dismiss() }
    }
}

struct BusinessPortalDashboardView: View {
    @StateObject private var store = BusinessPortalStore.shared
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(store.snapshot.profile?.name.nonEmpty ?? "Business workspace").font(.largeTitle.bold()).foregroundStyle(AppColors.textPrimary)
                statusCard
                dashboardLink("Business profile", "person.text.rectangle", BusinessProfileEditorView(store: store))
                dashboardLink("Gallery", "photo.on.rectangle.angled", BusinessGalleryView(store: store))
                dashboardLink("Calendar", "calendar", BusinessCalendarView(store: store))
                dashboardLink("Offers", "tag.fill", BusinessOffersView(store: store))
                unavailable("Analytics", "Metrics appear only after a reviewed listing receives real interactions.", "chart.line.uptrend.xyaxis")
                unavailable("Leads & messages", "Requires secure server delivery and role-based access.", "bubble.left.and.bubble.right.fill")
                unavailable("Billing", "No payment method or billing data is stored in this build.", "creditcard.fill")
            }.padding(18)
        }.appSceneBackground(.more).navigationTitle("Business dashboard").accessibilityIdentifier("business.dashboard")
    }
    private var statusCard: some View { VStack(alignment: .leading, spacing: 8) { Label(store.snapshot.profile?.moderationStatus.rawValue.capitalized ?? "Draft", systemImage: "checkmark.shield"); ProgressView(value: store.snapshot.profile?.completionFraction ?? 0); Text("Profile completeness").font(AppTypography.caption).foregroundStyle(AppColors.textSecondary) }.padding(14).appGlassCardStyle(padding: 0, cornerRadius: 16, accent: AppColors.warning) }
    private func dashboardLink<Destination: View>(_ title: String, _ icon: String, _ destination: Destination) -> some View { NavigationLink(destination: destination) { Label(title, systemImage: icon).font(AppTypography.bodyStrong).foregroundStyle(AppColors.textPrimary).frame(maxWidth: .infinity, alignment: .leading).padding(14).appGlassCardStyle(padding: 0, cornerRadius: 15, accent: AppColors.accent) } }
    private func unavailable(_ title: String, _ detail: String, _ icon: String) -> some View { VStack(alignment: .leading, spacing: 4) { Label(title, systemImage: icon).font(AppTypography.bodyStrong); Text(detail).font(AppTypography.footnote).foregroundStyle(AppColors.textSecondary); Text("Unavailable").font(AppTypography.metadata).foregroundStyle(AppColors.warning) }.padding(14).appGlassCardStyle(padding: 0, cornerRadius: 15, accent: AppColors.stroke) }
}

struct BusinessProfileEditorView: View {
    @ObservedObject var store: BusinessPortalStore
    @State private var profile: BusinessProfile
    init(store: BusinessPortalStore) { self.store = store; _profile = State(initialValue: store.snapshot.profile ?? BusinessProfile(id: UUID().uuidString, accountID: store.snapshot.account?.id ?? "")) }
    var body: some View { Form { TextField("Business name", text: $profile.name); TextField("Category", text: $profile.category); TextField("City", text: $profile.location.city); TextField("Description", text: $profile.summary, axis: .vertical); Toggle("Consent to public business details", isOn: $profile.consentToPublish); Button("Save draft") { store.saveProfile(profile) }; Button("Submit for review") { store.saveProfile(profile); store.submitForReview() }.disabled(!profile.consentToPublish) }.navigationTitle("Business profile") }
}

struct BusinessGalleryView: View {
    @ObservedObject var store: BusinessPortalStore
    @State private var filename = ""
    @State private var altText = ""
    @State private var role: BusinessMediaAsset.Role = .interior
    var body: some View {
        List {
            Section("Add local media draft") { TextField("Filename", text: $filename); TextField("Alt text", text: $altText); Picker("Role", selection: $role) { ForEach(BusinessMediaAsset.Role.allCases) { Text($0.rawValue.capitalized).tag($0) } }; Button("Add for review") { store.addMedia(filename: filename, role: role, altText: altText); filename = ""; altText = "" }.disabled(filename.isEmpty || altText.isEmpty) }
            Section("Gallery") { ForEach(store.snapshot.gallery.assets.sorted { $0.order < $1.order }) { asset in HStack { Image(systemName: asset.isCover ? "photo.fill" : "photo"); VStack(alignment: .leading) { Text(asset.filename); Text("\(asset.role.rawValue) · \(asset.moderationStatus.rawValue)").font(.caption).foregroundStyle(.secondary) }; Spacer(); if !asset.isCover { Button("Cover") { store.setCover(id: asset.id) }.font(.caption) } }.swipeActions { Button(role: .destructive) { store.removeMedia(id: asset.id) } label: { Label("Delete", systemImage: "trash") } } }.onMove(perform: store.moveMedia) }
            Section { Text("Original files remain local in this prototype. Production upload, compression, thumbnails, rights checks and moderation require the media backend.").font(.footnote) }
        }.toolbar { EditButton() }.navigationTitle("Gallery").accessibilityIdentifier("business.gallery")
    }
}

struct BusinessCalendarView: View {
    @ObservedObject var store: BusinessPortalStore
    @State private var showEditor = false
    var body: some View { List { ForEach(store.snapshot.events.sorted { $0.startDate < $1.startDate }) { event in VStack(alignment: .leading) { Text(event.title); Text("\(event.startDate.formatted()) · \(event.status.rawValue)").font(.caption).foregroundStyle(.secondary) } }; if store.snapshot.events.isEmpty { Text("No events yet. Create a factual event draft for moderation.") } }.navigationTitle("Business calendar").toolbar { Button { showEditor = true } label: { Label("New event", systemImage: "plus") } }.sheet(isPresented: $showEditor) { NavigationStack { BusinessEventEditorView(store: store) } }.accessibilityIdentifier("business.calendar") }
}

struct BusinessEventEditorView: View {
    @ObservedObject var store: BusinessPortalStore
    @Environment(\.dismiss) private var dismiss
    @State private var event: BusinessEvent
    init(store: BusinessPortalStore) { self.store = store; _event = State(initialValue: BusinessEvent(id: UUID().uuidString, businessID: store.snapshot.profile?.id ?? "", city: store.snapshot.profile?.location.city ?? "")) }
    var body: some View { Form { TextField("Title", text: $event.title); TextField("Description", text: $event.details, axis: .vertical); TextField("Category", text: $event.category); DatePicker("Starts", selection: $event.startDate); DatePicker("Ends", selection: $event.endDate); TextField("City", text: $event.city); TextField("Location", text: $event.location); TextField("Booking URL", text: $event.bookingURL); Picker("Status", selection: $event.status) { Text("Draft").tag(BusinessEventStatus.draft); Text("Pending review").tag(BusinessEventStatus.pendingReview) }; Button("Save event") { store.saveEvent(event); dismiss() }.disabled(event.title.isEmpty || event.city.isEmpty || event.endDate <= event.startDate) }.navigationTitle("Create event") }
}

struct BusinessOffersView: View {
    @ObservedObject var store: BusinessPortalStore
    @State private var title = ""
    @State private var details = ""
    var body: some View { Form { Section("New offer draft") { TextField("Title", text: $title); TextField("Description", text: $details, axis: .vertical); Button("Save draft") { store.saveOffer(BusinessOffer(id: UUID().uuidString, businessID: store.snapshot.profile?.id ?? "", title: title, details: details)); title = ""; details = "" }.disabled(title.isEmpty || details.isEmpty) }; Section("Offers") { ForEach(store.snapshot.offers) { offer in VStack(alignment: .leading) { Text(offer.title); Text(offer.moderationStatus.rawValue).font(.caption).foregroundStyle(.secondary) } } }; Section { Text("Expired and unapproved offers are excluded from user-facing discovery.").font(.footnote) } }.navigationTitle("Offers") }
}

private extension String { var nonEmpty: String? { isEmpty ? nil : self } }
