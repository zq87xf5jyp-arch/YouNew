import Foundation
import Testing
@testable import YouNew

@MainActor
struct BusinessPortalTests {
    private func store() -> BusinessPortalStore {
        let suite = "BusinessPortalTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return BusinessPortalStore(defaults: defaults)
    }

    @Test func accountAndProfileStaySeparateFromPersonalAppState() {
        let store = store()
        store.createLocalAccount(email: "owner@example.nl")
        #expect(store.snapshot.account?.email == "owner@example.nl")
        #expect(store.snapshot.profile?.accountID == store.snapshot.account?.id)
        #expect(store.snapshot.profile?.moderationStatus == .draft)
    }

    @Test func invalidLoginDoesNotCreateAccount() {
        let store = store()
        store.createLocalAccount(email: "invalid")
        #expect(store.snapshot.account == nil)
    }

    @Test func submissionRequiresConsentAndEntersReview() {
        let store = store()
        store.createLocalAccount(email: "owner@example.nl")
        var profile = store.snapshot.profile!
        profile.name = "Existing Business"
        store.saveProfile(profile)
        store.submitForReview()
        #expect(store.snapshot.profile?.moderationStatus == .draft)

        profile.consentToPublish = true
        store.saveProfile(profile)
        store.submitForReview()
        #expect(store.snapshot.profile?.moderationStatus == .pendingReview)
        #expect(store.snapshot.submissions.count == 1)
    }

    @Test func galleryRejectsDuplicateFilenamesAndMaintainsOneCover() {
        let store = store()
        store.addMedia(filename: "interior.jpg", role: .interior, altText: "Interior")
        store.addMedia(filename: "INTERIOR.JPG", role: .interior, altText: "Duplicate")
        store.addMedia(filename: "front.jpg", role: .exterior, altText: "Front")
        #expect(store.snapshot.gallery.assets.count == 2)
        #expect(store.snapshot.gallery.assets.filter(\.isCover).count == 1)
        let second = store.snapshot.gallery.assets[1]
        store.setCover(id: second.id)
        #expect(store.snapshot.gallery.assets.first(where: \.isCover)?.id == second.id)
    }

    @Test func onlyPublishedCurrentCityEventsCanBeUserFacing() {
        var event = BusinessEvent(id: "event-1", businessID: "business-1", title: "Workshop", startDate: Date(), endDate: Date().addingTimeInterval(3600), city: "Leiden", status: .published)
        #expect(event.isUserVisible)
        event.status = .pendingReview
        #expect(!event.isUserVisible)
        event.status = .published
        event.endDate = Date().addingTimeInterval(-60)
        #expect(!event.isUserVisible)
    }

    @Test func expiredAndUnapprovedOffersStayHidden() {
        var offer = BusinessOffer(id: "offer-1", businessID: "business-1", title: "Welcome", details: "Terms apply", moderationStatus: .approved)
        #expect(offer.isUserVisible)
        offer.validUntil = Date().addingTimeInterval(-1)
        #expect(!offer.isUserVisible)
        offer.validUntil = Date().addingTimeInterval(100)
        offer.moderationStatus = .pendingReview
        #expect(!offer.isUserVisible)
    }
}
