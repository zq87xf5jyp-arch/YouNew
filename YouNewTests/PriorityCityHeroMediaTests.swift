import Foundation
import Testing
@testable import YouNew

@MainActor
struct PriorityCityHeroMediaTests {
    private let priorityCities: [(name: String, province: String, id: String, expectedURLToken: String)] = [
        ("Amsterdam", "Noord-Holland", "amsterdam", "Canal%20houses%20and%20Oude%20Kerk"),
        ("Rotterdam", "Zuid-Holland", "rotterdam", "Erasmusbrug%20seen%20from%20Euromast"),
        ("Den Haag", "Zuid-Holland", "den-haag", "Friedenspalast_Den_Haag"),
        ("Utrecht", "Utrecht", "utrecht", "Utrecht%2C%20de%20Domtoren"),
        ("Leiden", "Zuid-Holland", "leiden", "Oude%20Vest%20canal"),
        ("Eindhoven", "Noord-Brabant", "eindhoven", "Eindhoven-Witte%20Dame"),
        ("Groningen", "Groningen", "groningen", "20100523%20Grote%20Markt"),
        ("Maastricht", "Limburg", "maastricht", "2022_Magisch_Maastricht")
    ]

    private let runtimeAuditedCityIds: Set<String> = [
        "amsterdam",
        "rotterdam",
        "den-haag",
        "leiden",
        "utrecht",
        "groningen",
        "nijmegen",
        "arnhem",
        "eindhoven",
        "maastricht",
        "delft",
        "haarlem"
    ]

    @Test func priorityPlaceIdsExistAndUseDistinctVerifiedHeroURLs() throws {
        var seenURLs = Set<String>()

        for city in priorityCities {
            let placeId = CuratedPlaceHeroMediaRegistry.cityPlaceId(cityName: city.name, provinceName: city.province)
            let media = try #require(CuratedPlaceHeroMediaRegistry.media(for: placeId))
            let remoteURL = try #require(media.remoteURL)
            let urlString = remoteURL.absoluteString

            #expect(placeId == "nl-city-\(city.province.lowercased().replacingOccurrences(of: "-", with: "_"))-\(city.id.replacingOccurrences(of: "-", with: "_"))")
            #expect(urlString.contains("Special:FilePath"))
            #expect(urlString.contains(city.expectedURLToken))
            #expect(!seenURLs.contains(urlString), "Duplicate hero URL assigned to \(city.name)")
            seenURLs.insert(urlString)
        }
    }

    @Test func priorityCityDataMatchesCuratedRegistryURLs() throws {
        for city in NLCity.all.filter({ priorityCities.map(\.id).contains($0.id) }) {
            let media = try #require(CuratedPlaceHeroMediaRegistry.media(for: city.placeId))
            let remoteURL = try #require(media.remoteURL?.absoluteString)

            #expect(city.imageURL == remoteURL)
        }
    }

    @Test func priorityHeroURLsReturnImages() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 8
        configuration.timeoutIntervalForResource = 16
        configuration.waitsForConnectivity = false
        let session = URLSession(configuration: configuration)

        for city in priorityCities {
            let placeId = CuratedPlaceHeroMediaRegistry.cityPlaceId(cityName: city.name, provinceName: city.province)
            let media = try #require(CuratedPlaceHeroMediaRegistry.media(for: placeId))
            let url = try #require(media.remoteURL)
            var request = URLRequest(url: url, timeoutInterval: 8)
            request.setValue("YouNew/1.0 (iOS; NetherlandsGuide)", forHTTPHeaderField: "User-Agent")

            let (data, response) = try await session.data(for: request)
            let httpResponse = try #require(response as? HTTPURLResponse)
            let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type")?.lowercased() ?? ""

            #expect(httpResponse.statusCode == 200, "\(city.name) returned HTTP \(httpResponse.statusCode)")
            #expect(contentType.hasPrefix("image/"), "\(city.name) returned \(contentType)")
            #expect(data.count > 8_000, "\(city.name) image response is unexpectedly small")
            #expect(httpResponse.statusCode != 404)
            #expect(httpResponse.statusCode != 403)
        }
    }

    @Test func runtimeAuditedCityHeroURLsAreUniqueAndSpecific() throws {
        let auditedCities = NLCity.all.filter { runtimeAuditedCityIds.contains($0.id) }
        #expect(auditedCities.count == runtimeAuditedCityIds.count)

        var seenNLCityURLs = Set<String>()
        var seenCuratedURLs = Set<String>()

        for city in auditedCities {
            #expect(!city.imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!city.imageURL.lowercased().contains("placeholder"))
            #expect(!seenNLCityURLs.contains(city.imageURL), "Duplicate NLCity hero URL assigned to \(city.name)")
            seenNLCityURLs.insert(city.imageURL)

            let media = try #require(CuratedPlaceHeroMediaRegistry.media(for: city.placeId))
            let remoteURL = try #require(media.remoteURL?.absoluteString)
            #expect(!remoteURL.lowercased().contains("placeholder"))
            #expect(!seenCuratedURLs.contains(remoteURL), "Duplicate curated hero URL assigned to \(city.name)")
            seenCuratedURLs.insert(remoteURL)
        }

        let haarlem = try #require(auditedCities.first { $0.id == "haarlem" })
        #expect(haarlem.imageURL.contains("Zijlstrat%20Grote%20Markt%20Haarlem.jpg"))
        #expect(CuratedPlaceHeroMediaRegistry.media(for: haarlem.placeId)?.remoteURL?.absoluteString.contains("Zijlstrat%20Grote%20Markt%20Haarlem.jpg") == true)
    }

    @Test func activeCitiesHaveUniqueRoleSpecificVisuals() throws {
        for city in NLCity.all {
            let placeId = city.placeId
            var seenURLs = Set<String>()

            for role in CityVisualRole.allCases {
                let visual = try #require(
                    CuratedPlaceHeroMediaRegistry.cityVisual(for: placeId, role: role),
                    "\(city.name) missing \(role.rawValue) visual"
                )
                let url = try #require(visual.remoteURL?.absoluteString)
                #expect(url.hasPrefix("https://"))
                #expect(!url.lowercased().contains("placeholder"))
                #expect(!seenURLs.contains(url), "\(city.name) reuses \(url) across visual roles")
                #expect(visual.minimumPixelWidth >= (role == .hero ? 2400 : 1200))
                #expect(!visual.why.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                seenURLs.insert(url)
            }
        }
    }

    @Test func activeCityRoleVisualsAreGloballyUnique() throws {
        var seenURLsByRole = [String: String]()

        for city in NLCity.all {
            for role in CityVisualRole.allCases {
                let visual = try #require(
                    CuratedPlaceHeroMediaRegistry.cityVisual(for: city.placeId, role: role),
                    "\(city.name) missing \(role.rawValue) visual"
                )
                let url = try #require(visual.remoteURL?.absoluteString)
                let normalizedURL = normalizedImageURL(url)
                let owner = "\(city.name) \(role.rawValue)"

                #expect(
                    seenURLsByRole[normalizedURL] == nil,
                    "\(owner) reuses city role image already assigned to \(seenURLsByRole[normalizedURL] ?? "unknown"): \(url)"
                )
                seenURLsByRole[normalizedURL] = owner
            }
        }
    }

    @Test func provinceVisualRolesAreCompleteAndUnique() throws {
        for province in NLProvince.all {
            let placeId = CuratedPlaceHeroMediaRegistry.provincePlaceId(provinceName: province.id)
            var seenURLs = Set<String>()

            for role in ProvinceVisualRole.allCases {
                let visual = try #require(
                    CuratedPlaceHeroMediaRegistry.provinceVisual(for: placeId, role: role),
                    "\(province.id) missing \(role.rawValue) visual"
                )
                let url = try #require(visual.remoteURL?.absoluteString)
                #expect(url.hasPrefix("https://"))
                #expect(!url.lowercased().contains("placeholder"))
                #expect(!seenURLs.contains(url), "\(province.id) reuses \(url) across province visual roles")
                #expect(visual.minimumPixelWidth >= (role == .landscape ? 2400 : 1200))
                #expect(!visual.why.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                seenURLs.insert(url)
            }
        }
    }

    @Test func provinceRoleVisualsAreGloballyUnique() throws {
        var seenURLsByRole = [String: String]()

        for province in NLProvince.all {
            let placeId = CuratedPlaceHeroMediaRegistry.provincePlaceId(provinceName: province.id)

            for role in ProvinceVisualRole.allCases {
                let visual = try #require(
                    CuratedPlaceHeroMediaRegistry.provinceVisual(for: placeId, role: role),
                    "\(province.id) missing \(role.rawValue) visual"
                )
                let url = try #require(visual.remoteURL?.absoluteString)
                let normalizedURL = normalizedImageURL(url)
                let owner = "\(province.id) \(role.rawValue)"

                #expect(
                    seenURLsByRole[normalizedURL] == nil,
                    "\(owner) reuses province role image already assigned to \(seenURLsByRole[normalizedURL] ?? "unknown"): \(url)"
                )
                seenURLsByRole[normalizedURL] = owner
            }
        }
    }

    @Test func runtimeTourismAttractionsHaveRequiredRelationshipMetadata() throws {
        let attractions = NLCity.all.flatMap(\.attractions)
        #expect(!attractions.isEmpty)

        var seenIDs = Set<String>()
        var seenURLs = Set<String>()

        for attraction in attractions {
            #expect(!attraction.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!seenIDs.contains(attraction.id), "Duplicate attraction id: \(attraction.id)")
            seenIDs.insert(attraction.id)

            #expect(attraction.imageURL.hasPrefix("https://"))
            #expect(!attraction.imageURL.lowercased().contains("placeholder"))
            #expect(!seenURLs.contains(attraction.imageURL), "Duplicate attraction image URL: \(attraction.imageURL)")
            seenURLs.insert(attraction.imageURL)

            #expect(!attraction.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!attraction.whyVisit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!attraction.bestSeason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!attraction.photoPurpose.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(requestedPixelWidth(in: attraction.imageURL).map { $0 >= 1200 } ?? true)
        }
    }

    @Test func tourismCatalogCoversAllCategoriesWithUniqueSpecificPhotos() throws {
        let records = TourismAttractionCatalog.records
        #expect(!records.isEmpty)
        #expect(Set(records.map(\.category)) == Set(TourismCategory.allCases))

        var seenIDs = Set<String>()
        var seenURLs = Set<String>()

        for record in records {
            #expect(!record.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!seenIDs.contains(record.id), "Duplicate tourism record id: \(record.id)")
            seenIDs.insert(record.id)

            #expect(record.photoURL.hasPrefix("https://"))
            #expect(!record.photoURL.lowercased().contains("placeholder"))
            #expect(!record.photoURL.lowercased().contains("unsplash"))
            #expect(!seenURLs.contains(record.photoURL), "Duplicate tourism photo URL: \(record.photoURL)")
            seenURLs.insert(record.photoURL)

            #expect(!record.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!record.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!record.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!record.whyVisit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!record.bestSeason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(requestedPixelWidth(in: record.photoURL).map { $0 >= 1200 } ?? true)
        }
    }

    @Test func visibleVisualSurfacesDoNotReuseSourceImageFiles() throws {
        var seenSurfacesByURL = [String: String]()

        func register(_ urlString: String, surface: String) {
            let normalizedURL = normalizedImageURL(urlString)
            #expect(
                seenSurfacesByURL[normalizedURL] == nil,
                "\(surface) reuses visible image file already assigned to \(seenSurfacesByURL[normalizedURL] ?? "unknown"): \(urlString)"
            )
            seenSurfacesByURL[normalizedURL] = surface
        }

        for city in NLCity.all {
            for role in CityVisualRole.allCases {
                let visual = try #require(
                    CuratedPlaceHeroMediaRegistry.cityVisual(for: city.placeId, role: role),
                    "\(city.name) missing \(role.rawValue) visual"
                )
                register(try #require(visual.remoteURL?.absoluteString), surface: "city \(city.name) \(role.rawValue)")
            }

            for attraction in city.attractions {
                register(attraction.imageURL, surface: "city attraction \(city.name) / \(attraction.name)")
            }
        }

        for province in NLProvince.all {
            let placeId = CuratedPlaceHeroMediaRegistry.provincePlaceId(provinceName: province.id)

            for role in ProvinceVisualRole.allCases {
                let visual = try #require(
                    CuratedPlaceHeroMediaRegistry.provinceVisual(for: placeId, role: role),
                    "\(province.id) missing \(role.rawValue) visual"
                )
                register(try #require(visual.remoteURL?.absoluteString), surface: "province \(province.id) \(role.rawValue)")
            }
        }

        for record in TourismAttractionCatalog.records {
            register(record.photoURL, surface: "tourism \(record.name)")
        }
    }

    @Test func runtimeCityAndProvinceHeroURLsRequestPremiumSizes() throws {
        for city in NLCity.all {
            #expect(requestedPixelWidth(in: city.imageURL).map { $0 >= 2400 } ?? true, "\(city.name) hero is below 2400px")
        }

        for province in NLProvince.all {
            #expect(requestedPixelWidth(in: province.imageURL).map { $0 >= 2400 } ?? true, "\(province.id) hero is below 2400px")
        }
    }

    @Test func denHaagPlacesUseRequestedLandmarks() throws {
        let denHaag = try #require(NLCity.all.first { $0.id == "den-haag" })
        let attractionNames = Set(denHaag.attractions.map(\.name))

        #expect(attractionNames.isSuperset(of: ["Binnenhof", "Peace Palace", "Scheveningen Beach", "Mauritshuis"]))
        #expect(denHaag.services.contains("Gemeente Den Haag"))
        #expect(!denHaag.services.contains("Gemeente Leiden"))

        for attraction in denHaag.attractions {
            let imageURL = attraction.imageURL.lowercased()
            #expect(!imageURL.contains("kinderdijk"), "Den Haag attraction \(attraction.name) uses windmill fallback imagery")
            #expect(!imageURL.contains("windmill"), "Den Haag attraction \(attraction.name) uses windmill imagery")
        }
    }

    private func requestedPixelWidth(in urlString: String) -> Int? {
        if let widthRange = urlString.range(of: #"width=(\d+)"#, options: .regularExpression) {
            return Int(urlString[widthRange].replacingOccurrences(of: "width=", with: ""))
        }

        if let pxRange = urlString.range(of: #"/(\d+)px[-_]"#, options: .regularExpression) {
            let token = String(urlString[pxRange])
            return Int(token.filter(\.isNumber))
        }

        return nil
    }

    private func normalizedImageURL(_ urlString: String) -> String {
        guard let components = URLComponents(string: urlString) else {
            return urlString.lowercased()
        }

        var path = components.percentEncodedPath
            .removingPercentEncoding?
            .lowercased()
            .replacingOccurrences(of: " ", with: "_") ?? components.percentEncodedPath.lowercased()

        path = path.replacingOccurrences(of: "/thumb/", with: "/")

        if let range = path.range(of: #"/(?:\d+px-|[0-9]+px_)[^/]+$"#, options: .regularExpression) {
            path.removeSubrange(range)
        }

        let host = components.host?.lowercased() ?? ""
        if path.contains("special:filepath") {
            return "\(host)\(path)"
        }
        return "\(host)\(path)?\(components.percentEncodedQuery ?? "")".trimmingCharacters(in: CharacterSet(charactersIn: "?"))
    }
}
