import Foundation

enum MockDeadlinesData {
    static let reminders: [DeadlineReminder] = [
        DeadlineReminder(
            title: "Check address registration status",
            detail: "Confirm your gemeente has not requested additional documents. Registration is needed before BSN and other services can proceed.",
            possibleDueDate: Calendar.current.date(byAdding: .day, value: 6, to: Date()),
            institutionName: "Gemeente",
            sourceURL: AppURL.make("https://www.government.nl/topics/municipalities")
        ),
        DeadlineReminder(
            title: "Complete your BSN steps",
            detail: "Check whether a separate appointment or confirmation step is needed for your BSN to be issued or confirmed.",
            possibleDueDate: Calendar.current.date(byAdding: .day, value: 9, to: Date()),
            institutionName: "Government.nl",
            sourceURL: AppURL.make("https://www.government.nl/topics/personal-data/citizen-service-number-bsn")
        ),
        DeadlineReminder(
            title: "Activate DigiD",
            detail: "If you have already applied for DigiD, complete activation using the letter sent to your registered address. Activation has a time limit.",
            possibleDueDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()),
            institutionName: "DigiD",
            sourceURL: AppURL.make("https://www.digid.nl/en")
        ),
        DeadlineReminder(
            title: "Check health insurance obligation",
            detail: "Confirm from which date Dutch basic health insurance (zorgverzekering) is required for your situation. Taking it out late may have financial consequences.",
            possibleDueDate: Calendar.current.date(byAdding: .day, value: 28, to: Date()),
            institutionName: "Government.nl",
            sourceURL: AppURL.make("https://www.government.nl/topics/health-insurance")
        ),
        DeadlineReminder(
            title: "Review tax letters from Belastingdienst",
            detail: "Open any letters from Belastingdienst and note the response or payment deadlines. Missing a deadline may result in additional charges.",
            possibleDueDate: Calendar.current.date(byAdding: .day, value: 24, to: Date()),
            institutionName: "Belastingdienst",
            sourceURL: AppURL.make("https://www.belastingdienst.nl")
        ),
        DeadlineReminder(
            title: "Check toeslagen eligibility",
            detail: "Review whether you qualify for zorgtoeslag, huurtoeslag, or other allowances. Apply via toeslagen.nl — allowances are not applied automatically.",
            possibleDueDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
            institutionName: "Belastingdienst Toeslagen",
            sourceURL: AppURL.make("https://www.toeslagen.nl")
        ),
        DeadlineReminder(
            title: "Apply for or activate DigiD app",
            detail: "Upgrade your DigiD with the app for stronger authentication. Some portals require the DigiD app for full access.",
            possibleDueDate: Calendar.current.date(byAdding: .day, value: 21, to: Date()),
            institutionName: "DigiD",
            sourceURL: AppURL.make("https://www.digid.nl/en")
        ),
        DeadlineReminder(
            title: "Check residence permit expiry",
            detail: "If you hold a verblijfsvergunning, check its expiry date. IND renewal procedures should be started well before the permit expires.",
            possibleDueDate: Calendar.current.date(byAdding: .day, value: 60, to: Date()),
            institutionName: "IND",
            sourceURL: AppURL.make("https://ind.nl/en")
        ),
        DeadlineReminder(
            title: "File annual tax return",
            detail: "The belastingaangifte for the previous year is typically due by 1 May. Filing early may speed up any refund. Check the Belastingdienst portal for your personal deadline.",
            possibleDueDate: Calendar.current.date(byAdding: .day, value: 45, to: Date()),
            institutionName: "Belastingdienst",
            sourceURL: AppURL.make("https://www.belastingdienst.nl")
        ),
        DeadlineReminder(
            title: "Register with a GP (huisarts)",
            detail: "Register with a local general practitioner as soon as possible after arriving. Practices have limited capacity and registering early avoids gaps in care access.",
            possibleDueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            institutionName: "Zorgwijzer.nl",
            sourceURL: AppURL.make("https://www.zorgwijzer.nl")
        )
    ]
}
