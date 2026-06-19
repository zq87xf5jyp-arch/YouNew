import Foundation

enum MockDailyLifeData {
    static let items: [DailyLifeTip] = [

        // MARK: - Healthcare

        DailyLifeTip(
            title: "Register with a GP (Huisarts)",
            category: .healthcare,
            summary: "In the Netherlands, a GP is your first point of contact for almost all healthcare needs.",
            detail: "Everyone living in the Netherlands should register with a local general practitioner (huisarts). The GP is the gatekeeper to the healthcare system — you cannot see a specialist without a GP referral. GPs handle routine illness, prescriptions, mental health referrals, and chronic disease management. Registration is usually straightforward: contact a nearby practice and ask if they accept new patients.",
            practicalTip: "Register as soon as you arrive, even if you feel healthy. Popular practices fill up fast, especially in cities. Use the GP finder on zorgwijzer.nl to find practices near you.",
            officialSourceName: "Zorgwijzer.nl",
            officialSourceURL: AppURL.validatedWebURL(URL(string: "https://www.zorgwijzer.nl"))
        ),

        DailyLifeTip(
            title: "How Health Insurance Works",
            category: .healthcare,
            summary: "Basic health insurance (basisverzekering) is mandatory for everyone in the Netherlands.",
            detail: "Every resident must take out basic health insurance (basisverzekering) within four months of registering. The basic package covers GP visits, hospital care, and essential medicines. You pay a monthly premium plus an annual excess (eigen risico). The mandatory eigen risico is set by the government and can change, so check the current amount with your insurer or on Government.nl before choosing a policy. Once you spend your eigen risico on eligible healthcare, the insurer covers the rest. You can also choose supplementary insurance (aanvullende verzekering) for extras like dental and physiotherapy.",
            practicalTip: "Compare insurers each year in November/December when you can switch providers. Zorgvergelijker.nl is a reliable comparison tool. If you have a low income, check if you qualify for zorgtoeslag (healthcare allowance).",
            officialSourceName: "Rijksoverheid — Health Insurance",
            officialSourceURL: AppURL.validatedWebURL(URL(string: "https://www.government.nl/topics/health-insurance"))
        ),

        DailyLifeTip(
            title: "Getting a Specialist Referral",
            category: .healthcare,
            summary: "You need a GP referral to see almost any specialist or hospital department.",
            detail: "The Dutch system relies heavily on the huisarts as gatekeeper. If you need to see a specialist — a dermatologist, cardiologist, or physiotherapist — you first make an appointment with your GP. The GP assesses the situation and, if needed, writes a referral. Without this referral, your insurance typically will not cover the specialist visit. Emergencies are the exception — for urgent situations, go to the spoedeisende hulp (A&E) or call 112.",
            practicalTip: "Describe your symptoms clearly and calmly to your GP. If you feel the GP has dismissed something important, you have the right to request a second opinion or ask for a referral specifically.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "Dental Care and Insurance",
            category: .healthcare,
            summary: "Adult dental care is not covered by the basic insurance package.",
            detail: "Basic health insurance does not cover routine dental care for adults (18+). You can purchase supplementary dental insurance (tandartsverzekering) or pay out-of-pocket. Children under 18 are covered for basic dental care. Dental costs in the Netherlands are structured by a national tariff system (NZa tarieven) — dentists cannot charge above these rates. Finding an English-speaking dentist is possible in most cities.",
            practicalTip: "Register with a dentist (tandarts) shortly after arriving, as practices also have waiting lists. Even with supplementary insurance, check the annual coverage maximum before expecting full reimbursement.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "Non-Emergency Medical Line — 0900-8833",
            category: .healthcare,
            summary: "For urgent but non-life-threatening medical questions outside GP hours, call the GP emergency post.",
            detail: "Outside regular GP hours (evenings, weekends, public holidays), you can call the huisartsenpost (HAP) for urgent medical questions. The number varies by region but is typically 0900-8833 or found via your GP's answering machine. For life-threatening emergencies, always call 112. The HAP can give phone advice, arrange a consultation, or direct you to the nearest emergency department.",
            practicalTip: "Save your local HAP number in your phone. When you call, explain your symptoms clearly. The triage nurse will assess urgency and direct you to the right care.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        // MARK: - Banking

        DailyLifeTip(
            title: "Opening a Dutch Bank Account",
            category: .banking,
            summary: "You need a Dutch bank account for rent, salary, and almost all daily transactions.",
            detail: "Most Dutch transactions — rent, salary, utility bills, online shopping — require a Dutch IBAN. Major banks include ING, ABN AMRO, Rabobank, and Bunq (more flexible for newcomers). Requirements typically include: valid ID (passport or residence permit), BSN number, and sometimes proof of address. Some banks, especially Bunq and Revolut, have faster digital onboarding and may be accessible before you have a BSN.",
            practicalTip: "Open a bank account as early as possible after receiving your BSN. Without a Dutch bank account, receiving salary or paying rent becomes very difficult. Bunq is popular among expats for its English interface and flexible requirements.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "How iDEAL Works",
            category: .banking,
            summary: "iDEAL is the dominant Dutch online payment system — used for almost all online purchases.",
            detail: "iDEAL allows you to pay directly from your Dutch bank account when shopping online or paying bills. At checkout, you select iDEAL, choose your bank, and authenticate in your banking app. The payment is instant and direct — no card details needed. iDEAL is integrated into virtually every Dutch webshop, government portal, and service provider.",
            practicalTip: "To use iDEAL, you need a Dutch bank account and the bank's mobile app set up. Make sure your banking app is configured and working before you need to pay rent or government fees.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "Tikkie — Splitting Bills Dutch Style",
            category: .banking,
            summary: "Tikkie is a payment request app widely used to split costs and request money from others.",
            detail: "Tikkie is an ABN AMRO-developed app (but usable by customers of most Dutch banks) that lets you send a payment request link to anyone. It is extremely common in the Netherlands for splitting restaurant bills, sharing household costs, or paying back friends. You receive a Tikkie link, tap it, and pay via iDEAL. Sending Tikkie requests is free; you do not need to have an ABN AMRO account to receive one.",
            practicalTip: "The Dutch are known for going 'Dutch' on costs — splitting everything equally. Tikkie is the standard way to settle up. Download the app and link it to your Dutch bank account.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "IBAN and Dutch Bank Transfers",
            category: .banking,
            summary: "Dutch bank account numbers use the IBAN format and transfers are typically free and instant.",
            detail: "Dutch IBANs start with NL followed by 2 check digits, 4 bank letters, and 10 digits (e.g. NL91 ABNA 0417 1643 00). Bank transfers (overboekingen) within the Netherlands are typically free and instant. Recurring payments can be set up as a direct debit (automatische incasso). When giving your bank details for salary, always provide your full IBAN.",
            practicalTip: "You can share your IBAN safely for receiving payments — your IBAN is not a secret. However, never share your bank login, password, or card PIN with anyone.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        // MARK: - Transport

        DailyLifeTip(
            title: "How the OV-chipkaart Works",
            category: .transport,
            summary: "The OV-chipkaart is the standard travel card for buses, trams, metros, and trains.",
            detail: "The OV-chipkaart (public transport chip card) is used across nearly all Dutch public transport. You check in when boarding and check out when leaving — forgetting to check out results in a maximum fare being charged. The card can be anonymous (disposable) or personal (linked to your name, recoverable if lost). You can top up the balance at machines, stations, and online.",
            practicalTip: "Always tap in AND tap out. A personal OV-chipkaart is better value — you can set up an auto-reload and recover it if lost. Get yours at major train stations or via ov-chipkaart.nl.",
            officialSourceName: "OV-chipkaart",
            officialSourceURL: AppURL.validatedWebURL(URL(string: "https://www.ov-chipkaart.nl"))
        ),

        DailyLifeTip(
            title: "NS Trains — Tickets and Subscriptions",
            category: .transport,
            summary: "NS (Dutch Railways) operates the national train network. You can buy single tickets or choose a subscription.",
            detail: "NS trains connect almost all Dutch cities. You can pay with your OV-chipkaart (check-in/check-out), buy a single ticket via the NS app or machines, or get a subscription (abonnement). Popular subscriptions include the Dal Voordeel (40% off off-peak) and Dal Vrij (unlimited off-peak travel). The NS app is available in English and is the easiest way to plan journeys and buy tickets.",
            practicalTip: "If you commute regularly by train, calculate whether a subscription saves money. Off-peak hours (before 6:30, after 9:00 and 16:00–18:30 on weekdays) are when most subscriptions apply.",
            officialSourceName: "NS — ns.nl",
            officialSourceURL: AppURL.validatedWebURL(URL(string: "https://www.ns.nl/en"))
        ),

        DailyLifeTip(
            title: "Bus, Tram, and Metro — Local Networks",
            category: .transport,
            summary: "Local public transport in each city is operated by regional companies and uses the OV-chipkaart.",
            detail: "Each region has its own public transport operator: GVB (Amsterdam), RET (Rotterdam), HTM (Den Haag), U-OV (Utrecht), and others. All use the OV-chipkaart for check-in/check-out. Most cities have tram, bus, and in Amsterdam and Rotterdam, metro lines. Journey planner apps like 9292 (9292.nl) are excellent for planning multi-modal trips including transfers.",
            practicalTip: "Download the 9292 app — it plans routes across all operators and modes of transport in real time. You can also use Google Maps for public transport in the Netherlands.",
            officialSourceName: "9292.nl",
            officialSourceURL: AppURL.validatedWebURL(URL(string: "https://9292.nl"))
        ),

        DailyLifeTip(
            title: "Getting a Dutch Driving Licence",
            category: .transport,
            summary: "EU driving licences are valid in the Netherlands. Non-EU licences may need to be exchanged.",
            detail: "EU/EEA driving licences are valid in the Netherlands without exchange. Non-EU licence holders may be able to exchange their licence for a Dutch one without taking a full test, depending on their country. The Netherlands has a mutual recognition agreement with several countries (check rdw.nl for the current list). If exchange is not possible, you must take the full Dutch driving theory and practical tests.",
            practicalTip: "Check rdw.nl to see if your country has an exchange agreement with the Netherlands. Start early — exchange appointments can have waiting times. Your licence must be exchanged within a certain period of residency.",
            officialSourceName: "RDW — rdw.nl",
            officialSourceURL: AppURL.validatedWebURL(URL(string: "https://www.rdw.nl/en"))
        ),

        DailyLifeTip(
            title: "Parking Rules and Zones",
            category: .transport,
            summary: "Parking in Dutch cities is regulated and paid parking zones are common.",
            detail: "Dutch cities use colour-coded parking zones with different hourly rates. You pay via parking meters, the park-and-pay apps (like EasyPark or Parkmobile), or by SMS. Blue zones (blauwe zones) require a parking disc showing your arrival time — these are usually free for short periods. Parking without paying in a paid zone results in a municipal fine from CJIB. P+R (Park and Ride) facilities on the outskirts of cities are a cheaper way to drive into a city.",
            practicalTip: "Download the municipality's recommended parking app before driving in a new city. Amsterdam, Rotterdam, and Utrecht have very limited and expensive central parking — public transport or cycling is strongly preferred.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        // MARK: - Cycling

        DailyLifeTip(
            title: "Dutch Cycling Rules",
            category: .cycling,
            summary: "Cycling has its own right-of-way rules and traffic laws in the Netherlands.",
            detail: "The Netherlands has an extensive network of dedicated cycle paths (fietspaden). Key rules: cyclists on a cycle path have right of way over turning cars at junctions; you must use a white front light and red rear light after dark; riding under the influence of alcohol is illegal; using your phone while cycling is illegal and fined. The 'right of way from the right' rule applies to unmarked junctions.",
            practicalTip: "Use bike lights — police enforce this actively and fines apply. When in doubt at junctions, slow down and give way. Cycling confidently and predictably is safer than hesitating.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "Where to Park Your Bike Safely",
            category: .cycling,
            summary: "Bikes must be parked in designated areas in most Dutch cities.",
            detail: "Dutch cities provide bike parking racks (fietsenrekken) throughout city centres. Locking your bike to a random object may result in the bike being removed by the municipality. Covered and staffed bike storage (fietsenstalling) is available at train stations, often free for the first 24 hours. Lock your bike with at least two locks — a frame lock and a heavy chain through the frame and back wheel.",
            practicalTip: "Always use two locks and lock your bike to a fixed object. Bike theft is extremely common in Dutch cities. Never leave an unlocked bike unattended even for a few minutes.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "Preventing Bike Theft",
            category: .cycling,
            summary: "Bike theft is extremely common in the Netherlands — good locks are essential.",
            detail: "Hundreds of thousands of bikes are stolen in the Netherlands every year. Best practices: use a heavy AXA, Kryptonite, or Abus chain lock through the frame AND rear wheel AND a fixed object; additionally use the frame lock; avoid leaving your bike overnight in exposed public locations; register your bike at fietsendiefstal.nl or with your municipality. If your bike is stolen, file a report with the police (politie.nl) — you will need a report number for insurance claims.",
            practicalTip: "Invest in a quality lock worth at least 10% of your bike's value. A €200 bike with a €5 lock is a gift to a thief. Consider bike insurance — some home insurance policies include bikes.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "OV-fiets — Rental Bikes at Train Stations",
            category: .cycling,
            summary: "OV-fiets lets you rent a bike at train stations using your OV-chipkaart for the last mile.",
            detail: "OV-fiets is a nationwide bike rental scheme at most NS train stations. You rent a standard bike for a time-based fee published by NS. To use it, you need a personal OV-chipkaart with an OV-fiets subscription; check the current subscription and rental conditions on NS before your first trip. Unlock the bike with your OV-chipkaart at the rental point. Return it to any OV-fiets location.",
            practicalTip: "OV-fiets is excellent for 'last mile' travel from a train station to your destination. Activate the subscription on your personal OV-chipkaart before your first trip — you cannot do it at the station in real time.",
            officialSourceName: "NS OV-fiets",
            officialSourceURL: AppURL.validatedWebURL(URL(string: "https://www.ns.nl/en/door-to-door/ov-fiets"))
        ),

        // MARK: - Waste & Recycling

        DailyLifeTip(
            title: "Waste Separation — What Goes Where",
            category: .waste,
            summary: "The Netherlands has a detailed recycling system. Separating waste correctly is expected.",
            detail: "Standard Dutch waste categories: GFT (groente, fruit, tuinafval) — organic kitchen and garden waste; Plastic, blik, drinkpakken (PMD) — plastic, metal tins, and drink cartons; Oud papier en karton — paper and cardboard; Glas — glass jars and bottles (by colour in public containers); Restafval — everything that does not fit another category. Some municipalities also have a textile container. Electrical waste (e-waste) goes to the milieustraat.",
            practicalTip: "Check your municipality's website for the exact collection schedule and which types of bins are provided at your address. Rules vary by municipality.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "Bin Collection Days",
            category: .waste,
            summary: "Waste is collected on specific days — putting bins out on the wrong day may result in a fine in some municipalities.",
            detail: "Each municipality has a fixed collection schedule for each waste type. You can find your personal collection calendar (afvalwijzer) on your municipality's website or via the Afvalwijzer app. In some cities, bins must be outside by a specific time the night before. In apartment buildings, shared underground containers are common — these are emptied on a set schedule and do not require scheduling.",
            practicalTip: "Download the Afvalwijzer app or check your municipality website to get your waste calendar. Set a reminder so you do not miss collection days — especially for GFT, which should not sit too long.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "Milieustraat — Waste Drop-off Points",
            category: .waste,
            summary: "The milieustraat is a municipal facility where you can drop off large or special waste items.",
            detail: "Every municipality has one or more milieupunten or milieustraten — free drop-off facilities for: e-waste (old electronics); white goods (fridges, washing machines); garden waste in bulk; paints and chemicals; large items (furniture, wood). You typically need to prove residency in the municipality (show your ID or postcode). Check your local municipality website for opening hours and accepted items.",
            practicalTip: "Do not leave large items on the street — this is illegal and results in a fine in most municipalities. Use the milieustraat for anything that does not fit a regular bin.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "Statiegeld — Deposit on Bottles and Cans",
            category: .waste,
            summary: "The Netherlands has a deposit refund system (statiegeld) for plastic bottles and large cans.",
            detail: "Statiegeld (deposit) applies to many plastic bottles and cans. Deposit rules and amounts can change by packaging type, so check the label, supermarket signage, or the current Statiegeld Nederland guidance. You return the empties to the statiegeldautomaat (reverse vending machine) found in most supermarkets. You receive a voucher to spend in the store. Standard glass jars and bottles usually go in the glass container unless they are part of a separate deposit system.",
            practicalTip: "Keep your bottles and cans until you have a bag worth returning. Scan them at the statiegeldautomaat in any supermarket — the receipt can be used as a voucher against your shopping.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        // MARK: - Culture & Customs

        DailyLifeTip(
            title: "Direct Dutch Communication",
            category: .culture,
            summary: "Dutch people communicate very directly — this is not rudeness, it is a cultural norm.",
            detail: "The Netherlands has a low-context communication culture. People say what they mean, give direct opinions, and do not use much indirect language or 'face-saving' softeners. Disagreeing openly is normal and healthy. This can feel blunt to people from cultures where indirectness is the norm. Equally, the Dutch respect directness from others — you are expected to speak up if something is wrong.",
            practicalTip: "If someone gives you feedback that sounds harsh, it is likely honest and not intended as an insult. Asking direct questions yourself — 'Is this correct?' 'What should I do?' — is completely acceptable and appreciated.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "Making Appointments (Afspraken)",
            category: .culture,
            summary: "The Dutch plan their time carefully — dropping by without an appointment is unusual.",
            detail: "Dutch culture is highly calendar-oriented. Social visits, professional meetings, and even casual gatherings are typically planned in advance. Showing up unannounced (without an afspraak) at someone's home or workplace is uncommon and may be unwelcome. Plan ahead and use tools like Calendly, email, or messaging to agree on a time. Being on time is important — arriving more than 5–10 minutes late is considered disrespectful.",
            practicalTip: "For any official appointment (municipality, doctor, bank), you almost always need to make one in advance via the institution's website or phone. Walk-in availability is rare.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "Dutch Birthday Culture",
            category: .culture,
            summary: "Birthdays are taken seriously in the Netherlands — congratulating the family is expected.",
            detail: "Birthdays (verjaardagen) are socially significant in the Netherlands. It is customary to congratulate not just the birthday person but also their family members ('Gefeliciteerd met je vrouw/man/vader'). Many Dutch people have a verjaardagskalender (birthday calendar) hanging in the bathroom. Bringing a small gift or flowers to a birthday visit is normal. Office birthdays often involve the birthday person bringing cake (taart) for their colleagues.",
            practicalTip: "When someone's birthday comes up at work or in your social group, joining in the congratulations — even with a brief 'Gefeliciteerd!' — is a simple way to connect with Dutch culture.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "Work-Life Balance and Boundaries",
            category: .culture,
            summary: "The Netherlands has a strong culture of work-life balance. Overtime expectations are low.",
            detail: "Most Dutch workplaces operate on a 38–40 hour working week with clear expectations about after-hours availability. Sending emails after 5pm or expecting immediate weekend responses is unusual and often unwelcome. Part-time work is extremely common — the Netherlands has one of Europe's highest rates of part-time employment, particularly among women. Childcare leave and parental rights are enshrined in law.",
            practicalTip: "Do not feel pressure to answer work messages outside hours unless your contract or role specifically requires it. Establishing boundaries early is respected in Dutch workplaces.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "Gezelligheid — The Dutch Concept of Cosiness",
            category: .culture,
            summary: "Gezelligheid is a central Dutch concept describing warmth, togetherness, and conviviality.",
            detail: "Gezellig (the adjective) describes a warm, cosy, friendly atmosphere — a good café with friends, a candlelit dinner, a relaxed family gathering. The Dutch use this word constantly. Creating and enjoying gezelligheid is genuinely important to Dutch social life. Something being 'niet gezellig' (not gezellig) is a mild but real criticism of an atmosphere or situation.",
            practicalTip: "Using the word gezellig when you enjoy something — a gathering, a café, a colleague's party — will be warmly received by Dutch people. It shows cultural awareness and appreciation.",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        // MARK: - Shopping

        DailyLifeTip(
            title: "Supermarkets and Loyalty Cards",
            category: .shopping,
            summary: "Albert Heijn is the largest supermarket chain. Their bonus card unlocks significant savings.",
            detail: "Albert Heijn (AH) is the dominant Dutch supermarket and its bonus card (Bonuskaart) gives automatic discounts on many items. You can register for free at ah.nl. Other major supermarkets include Jumbo, Lidl, Aldi, and Plus. AH runs a weekly set of bonus items — prices shown in the app or store. Supermarkets are typically open 08:00–22:00, including most Sundays in larger cities.",
            practicalTip: "Download the AH app and register your Bonuskaart. The app shows the weekly deals and lets you build a shopping list with automatic bonus prices applied. Even small savings add up over time.",
            officialSourceName: "Albert Heijn",
            officialSourceURL: AppURL.validatedWebURL(URL(string: "https://www.ah.nl"))
        ),

        DailyLifeTip(
            title: "Sunday Shopping Hours",
            category: .shopping,
            summary: "Sunday shopping is widely available in cities but restricted in smaller towns.",
            detail: "Dutch law allows municipalities to set their own rules for Sunday opening (koopzondag). In large cities like Amsterdam, Rotterdam, and Utrecht, most shops are open on Sunday (often 12:00–18:00, earlier opening in tourist areas). In smaller towns and villages, Sunday shopping may be restricted. Supermarkets in most cities are open on Sunday. Public holidays may mean reduced or no trading.",
            practicalTip: "Plan your shopping around opening hours — Dutch shops often close earlier than you might expect (many close by 18:00 on weekdays). Large shopping centres typically stay open until 21:00 on Thursdays (koopavond).",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        DailyLifeTip(
            title: "Markets (Markten) in Dutch Cities",
            category: .shopping,
            summary: "Weekly outdoor markets are a Dutch tradition offering fresh produce, clothing, and household goods.",
            detail: "Most Dutch towns and cities have a weekly markt (market) one or more days a week. Markets sell fresh vegetables, fruit, fish, cheese, flowers, clothing, and more — typically at competitive prices. Famous markets include Albert Cuyp in Amsterdam, Binnenwegplein in Rotterdam, and the Markt in Delft. Markets run approximately 09:00–17:00 on their designated days.",
            practicalTip: "Markets are excellent for buying fresh, affordable produce. Bring cash — not all stalls accept cards, though this is changing. Bring your own shopping bag (tas).",
            officialSourceName: nil,
            officialSourceURL: nil
        ),

        // MARK: - Emergency

        DailyLifeTip(
            title: "112 vs 0900-8844 — Which to Call",
            category: .emergency,
            summary: "112 is for immediate life-threatening emergencies. 0900-8844 is for non-urgent police matters.",
            detail: "112 is the Dutch emergency number for fire (brandweer), ambulance (ambulance), and urgent police response. Call 112 only for genuine emergencies — serious accidents, fires, life-threatening medical events, crimes in progress. For non-urgent police matters — reporting a theft, a nuisance, or an incident after the fact — call 0900-8844 or use the police website (politie.nl). The number 116000 is for missing persons. 0800-7000 is for anonymous tips.",
            practicalTip: "Save both 112 and 0900-8844 in your phone. Speaking Dutch is not required for 112 — operators handle calls in English and will connect you to a translator if needed.",
            officialSourceName: "Politie.nl",
            officialSourceURL: AppURL.validatedWebURL(URL(string: "https://www.politie.nl"))
        ),

        DailyLifeTip(
            title: "NL-Alert — Emergency Notification System",
            category: .emergency,
            summary: "NL-Alert is the Dutch government's emergency SMS broadcast system.",
            detail: "NL-Alert sends emergency messages directly to all mobile phones in a geographic area — no app required. These messages are used for disasters, chemical incidents, or public safety threats. The message arrives in Dutch and sometimes English. If you receive an NL-Alert, follow the instructions, which typically include: stay inside, close windows, and turn off ventilation (shelter-in-place) for chemical incidents.",
            practicalTip: "You do not need to do anything to receive NL-Alert — it uses a cell broadcast system that reaches any active SIM card in the area. Keep your phone on to receive these critical warnings.",
            officialSourceName: "NL-Alert — nl-alert.nl",
            officialSourceURL: AppURL.validatedWebURL(URL(string: "https://www.nl-alert.nl"))
        ),

        DailyLifeTip(
            title: "What to Do If You Witness a Crime",
            category: .emergency,
            summary: "Report crimes to the police — call 112 if ongoing, 0900-8844 or politie.nl for after-the-fact reports.",
            detail: "If you witness a crime in progress or see someone in danger, call 112 immediately. For crimes that have already occurred — theft, vandalism, fraud — you can report online at politie.nl, via 0900-8844, or visit your local police station. If you witnessed something, you may be asked to give a statement. Anonymous reports can be made via Meld Misdaad Anoniem (0800-7000 or meldmisdaadanoniem.nl).",
            practicalTip: "Reporting crimes, even minor ones, helps police identify patterns and areas of concern. You do not need to speak Dutch to report — police stations in major cities have English-speaking officers.",
            officialSourceName: "Politie.nl",
            officialSourceURL: AppURL.validatedWebURL(URL(string: "https://www.politie.nl"))
        )
    ]
}
