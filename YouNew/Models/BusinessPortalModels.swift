import SwiftUI
import Combine

enum BusinessCommercialStatus: String, Codable, CaseIterable, Identifiable {
    case organic, verified, partner, featured, sponsored
    var id: String { rawValue }
}

enum BusinessPlan: String, Codable, CaseIterable, Identifiable {
    case free, verified, featured, sponsored
    var id: String { rawValue }
}

enum BusinessModerationStatus: String, Codable, CaseIterable, Identifiable {
    case draft, pendingReview, approved, needsChanges, rejected, suspended
    var id: String { rawValue }
}

enum BusinessEventStatus: String, Codable, CaseIterable, Identifiable {
    case draft, pendingReview, published, expired, cancelled
    var id: String { rawValue }
}

struct BusinessAccount: Codable, Equatable, Identifiable {
    let id: String
    var email: String
    var createdAt: Date
}

struct BusinessLocation: Codable, Equatable {
    var city: String = ""
    var address: String = ""
    var latitude: Double?
    var longitude: Double?
    var serviceArea: String = ""
    var isOnlineOnly = false
}

struct BusinessProfile: Codable, Equatable, Identifiable {
    let id: String
    var accountID: String
    var name: String = ""
    var category: String = ""
    var kvkNumber: String = ""
    var website: String = ""
    var publicEmail: String = ""
    var publicPhone: String = ""
    var location = BusinessLocation()
    var summary: String = ""
    var languages: [String] = []
    var openingHours: String = ""
    var priceRange: String = ""
    var accessibilityNotes: String = ""
    var isFamilyFriendly = false
    var bookingURL: String = ""
    var plan: BusinessPlan = .free
    var moderationStatus: BusinessModerationStatus = .draft
    var consentToPublish = false

    var completionFraction: Double {
        let values = [name, category, website, publicEmail, location.city, summary]
        let completed = values.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
        return Double(completed) / Double(values.count)
    }
}

struct BusinessMediaAsset: Codable, Equatable, Identifiable {
    enum Role: String, Codable, CaseIterable, Identifiable {
        case cover, logo, interior, exterior, product, food, room, team, facility, service, seasonal
        var id: String { rawValue }
    }

    let id: String
    var localIdentifier: String
    var filename: String
    var role: Role
    var altText: String
    var isCover: Bool
    var order: Int
    var pixelWidth: Int?
    var pixelHeight: Int?
    var moderationStatus: BusinessModerationStatus
}

struct BusinessGallery: Codable, Equatable {
    var assets: [BusinessMediaAsset] = []

    mutating func setCover(_ id: String) {
        for index in assets.indices { assets[index].isCover = assets[index].id == id }
    }

    mutating func move(from offsets: IndexSet, to destination: Int) {
        var ordered = assets.sorted { $0.order < $1.order }
        ordered.move(fromOffsets: offsets, toOffset: destination)
        for index in ordered.indices { ordered[index].order = index }
        assets = ordered
    }
}

struct BusinessEvent: Codable, Equatable, Identifiable {
    let id: String
    var businessID: String
    var title: String = ""
    var details: String = ""
    var category: String = "Event"
    var startDate = Date()
    var endDate = Date().addingTimeInterval(3600)
    var recurringRule: String = "None"
    var capacity: Int?
    var price: String = ""
    var bookingURL: String = ""
    var location: String = ""
    var city: String = ""
    var imageAssetID: String?
    var languages: [String] = []
    var ageRestriction: String = ""
    var accessibilityNotes: String = ""
    var status: BusinessEventStatus = .draft

    var isUserVisible: Bool {
        status == .published && endDate > Date() && startDate <= endDate && !city.isEmpty
    }
}

struct BusinessOffer: Codable, Equatable, Identifiable {
    let id: String
    var businessID: String
    var title: String = ""
    var details: String = ""
    var validFrom = Date()
    var validUntil = Date().addingTimeInterval(7 * 86_400)
    var eligibility: String = ""
    var promoCode: String = ""
    var redemptionInstructions: String = ""
    var terms: String = ""
    var moderationStatus: BusinessModerationStatus = .draft

    var isUserVisible: Bool {
        moderationStatus == .approved && validFrom <= Date() && validUntil >= Date()
    }
}

struct BusinessVerification: Codable, Equatable {
    var status: BusinessModerationStatus = .draft
    var reviewerMessage: String = ""
    var submittedAt: Date?
}

struct BusinessAnalytics: Codable, Equatable {
    var views: Int?
    var taps: Int?
    var saves: Int?
    var websiteClicks: Int?
    var routeRequests: Int?
}

struct BusinessLead: Codable, Equatable, Identifiable {
    let id: String
    var businessID: String
    var createdAt: Date
    var kind: String
}

struct BusinessSubmission: Codable, Equatable, Identifiable {
    let id: String
    var businessID: String
    var status: BusinessModerationStatus
    var submittedAt: Date
    var reviewerMessage: String
}

struct BusinessPortalSnapshot: Codable, Equatable {
    var account: BusinessAccount?
    var profile: BusinessProfile?
    var gallery = BusinessGallery()
    var events: [BusinessEvent] = []
    var offers: [BusinessOffer] = []
    var verification = BusinessVerification()
    var analytics = BusinessAnalytics()
    var submissions: [BusinessSubmission] = []
}

@MainActor
final class BusinessPortalStore: ObservableObject {
    static let shared = BusinessPortalStore()
    @Published private(set) var snapshot: BusinessPortalSnapshot
    private let storageKey = "younew.business.portal.v1"

    init(defaults: UserDefaults = .standard) {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(BusinessPortalSnapshot.self, from: data) {
            snapshot = decoded
        } else {
            snapshot = BusinessPortalSnapshot()
        }
        self.defaults = defaults
    }

    private let defaults: UserDefaults

    func createLocalAccount(email: String) {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalized.contains("@") else { return }
        let account = snapshot.account ?? BusinessAccount(id: UUID().uuidString, email: normalized, createdAt: Date())
        snapshot.account = account
        if snapshot.profile == nil {
            snapshot.profile = BusinessProfile(id: UUID().uuidString, accountID: account.id, publicEmail: normalized)
        }
        persist()
    }

    func saveProfile(_ profile: BusinessProfile) {
        snapshot.profile = profile
        persist()
    }

    func submitForReview() {
        guard var profile = snapshot.profile, profile.consentToPublish else { return }
        profile.moderationStatus = .pendingReview
        snapshot.profile = profile
        snapshot.verification = BusinessVerification(status: .pendingReview, reviewerMessage: "", submittedAt: Date())
        snapshot.submissions.append(BusinessSubmission(id: UUID().uuidString, businessID: profile.id, status: .pendingReview, submittedAt: Date(), reviewerMessage: ""))
        persist()
    }

    func addMedia(filename: String, role: BusinessMediaAsset.Role, altText: String, pixelWidth: Int? = nil, pixelHeight: Int? = nil) {
        let normalized = filename.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty,
              !snapshot.gallery.assets.contains(where: { $0.filename.caseInsensitiveCompare(normalized) == .orderedSame }) else { return }
        let asset = BusinessMediaAsset(
            id: UUID().uuidString,
            localIdentifier: UUID().uuidString,
            filename: normalized,
            role: role,
            altText: altText,
            isCover: snapshot.gallery.assets.isEmpty,
            order: snapshot.gallery.assets.count,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            moderationStatus: .pendingReview
        )
        snapshot.gallery.assets.append(asset)
        persist()
    }

    func removeMedia(id: String) {
        snapshot.gallery.assets.removeAll { $0.id == id }
        if !snapshot.gallery.assets.contains(where: \.isCover), let first = snapshot.gallery.assets.first {
            snapshot.gallery.setCover(first.id)
        }
        persist()
    }

    func setCover(id: String) { snapshot.gallery.setCover(id); persist() }
    func moveMedia(from offsets: IndexSet, to destination: Int) { snapshot.gallery.move(from: offsets, to: destination); persist() }

    func saveEvent(_ event: BusinessEvent) {
        if let index = snapshot.events.firstIndex(where: { $0.id == event.id }) { snapshot.events[index] = event }
        else { snapshot.events.append(event) }
        persist()
    }

    func cancelEvent(id: String) {
        guard let index = snapshot.events.firstIndex(where: { $0.id == id }) else { return }
        snapshot.events[index].status = .cancelled
        persist()
    }

    func saveOffer(_ offer: BusinessOffer) {
        if let index = snapshot.offers.firstIndex(where: { $0.id == offer.id }) { snapshot.offers[index] = offer }
        else { snapshot.offers.append(offer) }
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(snapshot) { defaults.set(data, forKey: storageKey) }
        objectWillChange.send()
    }
}
