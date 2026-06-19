import Foundation

enum MockRulesGuideData {
    static let topics: [RuleGuideTopic] = [
        topic("Bicycle rules", "Bicycle Lights at Night", "Bike lights are required at night and in low visibility.", "Visibility prevents crashes with trams, cars, and scooters.", "Removable lights run out of battery and people forget to check.", "Approx. EUR 60-75", "Fine can increase and repeat checks are common near stations.", "Police and municipality", "Pay on time, keep proof, and check CJIB status for updates.", "Police.nl", "https://www.politie.nl", "Police checks are frequent near city centers after sunset.", "Charge lights before evening rides."),
        topic("Scooter / moped rules", "Helmet and Road Position", "Helmet and lane rules depend on scooter type and local signs.", "Rules reduce injury risk and lane conflicts with cyclists.", "Newcomers use bike lanes when local rules require road lane.", "Approx. EUR 100+", "You can be stopped, fined, and ordered to correct behavior immediately.", "Police", "Verify scooter class, then pay or file objection in stated deadline.", "Government.nl", "https://www.government.nl", "Rental scooters often confuse visitors about lane usage.", "Read local lane signs before starting trip."),
        topic("Car rules", "Phone Use While Driving", "Handheld phone use while driving is prohibited.", "Distraction is a major crash cause.", "Drivers check maps in hand at red lights and assume it is allowed.", "Approx. EUR 400+", "Fine is high and repeat violations raise enforcement attention.", "Police / CJIB", "Pay via official CJIB channel only and keep transaction receipt.", "CJIB", "https://www.cjib.nl/en", "Camera and on-road checks are used in larger cities.", "Use hands-free mount before driving."),
        topic("Public transport fines", "Check-In / Check-Out", "You must check in and out correctly with OV card or valid ticket.", "Fare system depends on complete trip registration.", "Passengers forget to check out when changing lines.", "Approx. EUR 50-100", "Operator fine can escalate if left unpaid.", "Transport operator / CJIB", "Keep ticket evidence, pay in time, and review objection process.", "NS", "https://www.ns.nl/en", "Many fines happen on short local rides.", "Set a phone reminder for check-out."),
        topic("Smoking rules", "Smoke-Free Public Zones", "Smoking is prohibited in many indoor public places and marked zones.", "Public health and fire safety.", "People smoke near entrances where signage forbids it.", "Approx. EUR 100+", "On-site enforcement and municipality penalties may apply.", "NVWA / Municipality", "Stop violation immediately and follow ticket instructions.", "Government.nl", "https://www.government.nl", "Warnings are common near stations and schools.", "Watch for no-smoking signs before lighting."),
        topic("Trash / garbage rules", "Waste Separation and Collection Time", "Garbage must be separated and disposed in city-defined bins and times.", "Keeps streets clean and reduces sorting costs.", "Bags are left outside too early or wrong bin is used.", "Approx. EUR 100-150", "Municipality can fine and repeat violations are tracked.", "Municipality", "Check municipality portal, then pay or contest using case reference.", "Government.nl", "https://www.government.nl", "Address labels in trash can identify violator.", "Follow local collection calendar exactly."),
        topic("Noise complaints", "Quiet Hours", "Loud noise during designated quiet hours can trigger complaints.", "Protects neighborhood safety and rest.", "Late parties continue after warning from neighbors.", "Approx. EUR 150+", "Police visit, warning, and possible ticket if repeated.", "Municipality / Police", "If fined, document facts and use official objection route.", "Police.nl", "https://www.politie.nl", "Shared buildings report repeated incidents quickly.", "Lower volume after evening hours."),
        topic("Parking fines", "Permit and Paid Zone Compliance", "Parking requires valid payment or permit in paid/permit zones.", "Space management in dense city centers.", "Visitors assume Sunday or evening is always free.", "Approx. EUR 70+ plus tax", "Debt can increase when collection starts.", "Municipality / CJIB", "Pay via official notice and verify area rules for next time.", "CJIB", "https://www.cjib.nl/en", "ANPR and street checks are both used.", "Check zone app before leaving car."),
        topic("ID/passport obligations", "Carrying Valid ID", "You must show valid ID when authorities legally request it.", "Identity verification for enforcement and safety.", "Photo copy is treated as full replacement.", "Approx. EUR 100+", "Immediate fine and additional checks possible.", "Police", "Present original valid document and follow fine instruction calmly.", "Government.nl", "https://www.government.nl", "Tourists and students are commonly checked around stations.", "Carry original ID during city travel."),
        topic("Alcohol/drug rules", "Public Intoxication and Drug Possession Limits", "Public intoxication and drug rules vary by municipality and location.", "Public order and safety.", "Visitors assume coffee shop tolerance applies everywhere.", "From warning to fine; can be high", "Fines, confiscation, and police report can occur.", "Police / Municipality", "Do not ignore paperwork; confirm legal route and deadlines.", "Government.nl", "https://www.government.nl", "Festival areas have strict controls.", "Do not apply one-city rule to all cities."),
        topic("Work violations", "Illegal Work and Contract Abuse", "Working without required registration or violating labor rules can trigger sanctions.", "Protects workers and tax system integrity.", "People accept cash-only work without contract.", "Can be significant for employer and worker", "Can affect residence/work status and finances.", "Labour Inspectorate / UWV", "Gather payslips/messages and ask legal help before deadlines.", "Nederlandse Arbeidsinspectie", "https://www.nlarbeidsinspectie.nl", "Underpayment cases often begin with missing payslips.", "Never start work without clear contract terms."),
        topic("Housing violations", "Illegal Subletting and Unsafe Rentals", "Unregistered subletting and unsafe housing can violate local rules.", "Tenant protection and neighborhood safety.", "Tenant pays deposit for room without legal registration.", "Varies by municipality and case", "Eviction risk, lost deposit, and legal disputes.", "Municipality / Rent Tribunal", "Save contract and chats, then contact legal help quickly.", "Juridisch Loket", "https://www.juridischloket.nl", "Fake landlords push urgent cash payments.", "Do not transfer deposit without verification."),
        topic("Municipality rules", "BRP Address Registration", "You must keep your registered address accurate in BRP.", "Government services depend on correct address.", "People delay address update after moving.", "May include administrative fine", "Service access and letters can be disrupted.", "Municipality", "Book address update immediately and keep appointment evidence.", "Government.nl", "https://www.government.nl", "Blue letters often go to old address first.", "Update BRP right after any move."),
        topic("Tourist mistakes", "Overstay and Insurance Gaps", "Tourists must respect stay duration and maintain suitable coverage.", "Immigration and health risk management.", "Assuming Schengen stay resets after quick border trip.", "Can include fines and entry restrictions", "Future entry can be affected.", "IND / Border Police", "Collect travel docs and check formal options fast.", "IND", "https://ind.nl/en", "Short overstays still appear in records.", "Track stay days weekly, not monthly."),
        topic("Scam warnings", "Fake CJIB/Bank/Housing Messages", "Fraud messages imitate official institutions and demand urgent payment.", "Prevents theft of money and identity.", "User clicks payment link from SMS without checking domain.", "Loss can exceed any fine", "Bank fraud and identity abuse risks.", "Police / Fraud Helpdesk", "Do not pay. Report scam and contact your bank immediately.", "Fraudehelpdesk", "https://www.fraudehelpdesk.nl", "Scam texts often mention CJIB urgency.", "Always verify sender on official website.")
    ]

    static let scenarios: [RuleScenario] = [
        scenario("Police stopped me without ID", "You may be asked to identify yourself under Dutch law.", "A check does not automatically mean criminal trouble.", ["Stay calm and polite.", "Show valid original ID if available.", "If fined, note reference and deadline."], "Police", "https://www.politie.nl"),
        scenario("I got a transport fine", "You likely missed check-in/out or had an invalid ticket.", "Most first-time cases are procedural and fixable through official channels.", ["Read issuer and deadline on notice.", "Pay or object through official operator/CJIB path.", "Keep payment proof."], "Transport operator / CJIB", "https://www.cjib.nl/en"),
        scenario("Landlord ignores repairs", "Landlord obligations exist for basic living standards.", "You are not required to accept unsafe conditions.", ["Document issue with photos and dates.", "Send written request.", "Contact legal/rent support if ignored."], "Juridisch Loket / Huurcommissie", "https://www.juridischloket.nl"),
        scenario("I received a blue envelope", "Blue envelopes are often official tax letters.", "Receiving one does not always mean immediate debt.", ["Check sender and letter type.", "Read deadline.", "Call Belastingdienst if unclear."], "Belastingdienst", "https://www.belastingdienst.nl"),
        scenario("I crashed on bicycle", "Even minor crashes can involve liability and insurance steps.", "Not every crash leads to severe legal outcome.", ["Check safety and call 112 if injury.", "Exchange contact details.", "Document scene and report if needed."], "Police / Insurer", "https://www.politie.nl"),
        scenario("My BSN appointment is delayed", "Municipality delays can affect downstream services.", "Delays are common and usually manageable.", ["Keep appointment confirmation.", "Ask municipality for earliest slot.", "Inform employer/school about delay."], "Municipality", "https://www.government.nl"),
        scenario("I got a fake housing offer", "Scammers mimic landlords and demand urgent deposits.", "You can stop losses quickly if you act fast.", ["Stop payment attempts.", "Report account/message.", "Use verified housing channels only."], "Fraudehelpdesk / Police", "https://www.fraudehelpdesk.nl"),
        scenario("Employer pays incorrectly", "Incorrect payslips can mean underpayment or contract breaches.", "You have labor rights and support channels.", ["Collect payslips and contract.", "Request correction in writing.", "Escalate to legal/labor support."], "Labour Inspectorate / Juridisch Loket", "https://www.nlarbeidsinspectie.nl"),
        scenario("I received CJIB letter", "CJIB letters are official and deadline-sensitive.", "Most cases are manageable when handled early.", ["Verify letter reference on official site.", "Pay or object before deadline.", "Keep receipt and status check."], "CJIB", "https://www.cjib.nl/en")
    ]

    private static func topic(_ category: String, _ title: String, _ rule: String, _ reason: String, _ mistake: String, _ fine: String, _ consequence: String, _ authority: String, _ action: String, _ sourceName: String, _ source: String, _ example: String, _ warning: String) -> RuleGuideTopic {
        let severity = inferredSeverity(from: fine, consequence: consequence)
        return RuleGuideTopic(
            id: StableRouteID.uuid("rule-topic:\(stableRouteKey(title))"),
            category: category,
            title: title,
            severity: severity,
            rule: rule,
            reason: reason,
            commonMistake: mistake,
            estimatedFineRange: fine,
            approximateFine: fine,
            consequence: consequence,
            authority: authority,
            alreadyFinedAction: action,
            officialSourceName: sourceName,
            officialSourceURL: AppURL.make(source),
            realLifeExample: example,
            avoidWarning: warning,
            relatedTopics: curatedRelatedTopics(for: title)
        )
    }

    private static func scenario(_ title: String, _ meaning: String, _ doNotPanic: String, _ steps: [String], _ institution: String, _ source: String) -> RuleScenario {
        RuleScenario(
            id: StableRouteID.uuid("rule-scenario:\(stableRouteKey(title))"),
            title: title,
            meaning: meaning,
            doNotPanic: doNotPanic,
            nextSteps: steps,
            institution: institution,
            officialSourceURL: AppURL.make(source)
        )
    }

    private static func stableRouteKey(_ value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }

    private static func inferredSeverity(from fine: String, consequence: String) -> RuleSeverity {
        let text = "\(fine.lowercased()) \(consequence.lowercased())"
        if text.contains("loss") || text.contains("residence") || text.contains("significant") || text.contains("high") {
            return .critical
        }
        if text.contains("400") || text.contains("150") || text.contains("100+") {
            return .high
        }
        if text.contains("70") || text.contains("75") || text.contains("50") {
            return .medium
        }
        return .low
    }

    private static func curatedRelatedTopics(for title: String) -> [String] {
        switch title {
        case "Bicycle Lights at Night":
            return ["Parking fines", "Public transport fines", "Tourist mistakes"]
        case "Helmet and Road Position":
            return ["Bicycle rules", "Car rules", "Parking fines"]
        case "Phone Use While Driving":
            return ["Parking fines", "Alcohol/drug rules", "ID/passport obligations"]
        case "Check-In / Check-Out":
            return ["Bicycle rules", "Tourist mistakes", "Scam warnings"]
        case "Smoke-Free Public Zones":
            return ["Municipality rules", "Noise complaints", "Tourist mistakes"]
        case "Waste Separation and Collection Time":
            return ["Municipality rules", "Housing violations", "Noise complaints"]
        case "Quiet Hours":
            return ["Housing violations", "Municipality rules", "Tourist mistakes"]
        case "Permit and Paid Zone Compliance":
            return ["Car rules", "Bicycle rules", "Municipality rules"]
        case "Carrying Valid ID":
            return ["Tourist mistakes", "Car rules", "Scam warnings"]
        case "Public Intoxication and Drug Possession Limits":
            return ["Car rules", "Tourist mistakes", "Noise complaints"]
        case "Illegal Work and Contract Abuse":
            return ["Housing violations", "Scam warnings", "Municipality rules"]
        case "Illegal Subletting and Unsafe Rentals":
            return ["Work violations", "Scam warnings", "Municipality rules"]
        case "BRP Address Registration":
            return ["ID/passport obligations", "Housing violations", "Work violations"]
        case "Overstay and Insurance Gaps":
            return ["ID/passport obligations", "Public transport fines", "Scam warnings"]
        case "Fake CJIB/Bank/Housing Messages":
            return ["Housing violations", "Work violations", "ID/passport obligations"]
        default:
            return ["Municipality rules", "ID/passport obligations", "Scam warnings"]
        }
    }
}
