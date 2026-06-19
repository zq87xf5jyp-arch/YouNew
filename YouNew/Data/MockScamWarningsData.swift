import Foundation

enum MockScamWarningsData {
    static let items: [ScamWarning] = [

        // MARK: - Phishing

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:fake-digid-sms-account-blocked"),
            title: "Fake DigiD SMS — Account Blocked",
            category: .phishing,
            howItWorks: "You receive an SMS claiming your DigiD account is blocked or about to expire. The message includes a link to a convincing fake website that looks like digid.nl and asks you to log in and confirm your details.",
            warningSignals: [
                "Urgent language: 'Your account will be blocked in 24 hours'",
                "Link does not go to digid.nl",
                "Request for your BSN or password via a link",
                "Sender number is unfamiliar or international"
            ],
            whatToDo: "Do not click the link. Go directly to digid.nl by typing it yourself. Report the SMS to Fraudehelpdesk.nl and delete it.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:fake-belastingdienst-tax-refund-email"),
            title: "Fake Belastingdienst Tax Refund Email",
            category: .phishing,
            howItWorks: "An email claiming to be from the Dutch Tax Administration (Belastingdienst) tells you that you are owed a tax refund. You are asked to click a link and provide your bank account number to receive the money.",
            warningSignals: [
                "Belastingdienst does not send refunds via email with a link",
                "Email address is not @belastingdienst.nl",
                "Request for IBAN directly via email or a web form",
                "Unusual urgency or deadline pressure"
            ],
            whatToDo: "Do not provide bank details. Log in to Mijn Belastingdienst at belastingdienst.nl directly to check any real communications. Report to Fraudehelpdesk.nl.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:bank-impersonation-phone-call"),
            title: "Bank Impersonation Phone Call",
            category: .phishing,
            howItWorks: "A caller claims to be from your bank's fraud department, saying your account has been compromised. They ask you to confirm your card details, PIN, or transfer money to a 'safe account' they provide.",
            warningSignals: [
                "Your bank will never ask for your PIN or full card number by phone",
                "Request to transfer money to an unfamiliar 'safe' account",
                "Caller creates extreme urgency and discourages you from hanging up",
                "Caller knows your name or partial account details (obtained from data leaks)"
            ],
            whatToDo: "Hang up immediately. Call your bank directly using the number on their official website or the back of your card. Report to Fraudehelpdesk.nl.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:fake-uwv-benefits-email"),
            title: "Fake UWV Benefits Email",
            category: .phishing,
            howItWorks: "An email appearing to be from UWV (employee insurance agency) tells you your benefit payment needs to be confirmed or your bank details updated via a link.",
            warningSignals: [
                "UWV communicates through MijnUWV portal, not via email links",
                "Sender address is not @uwv.nl",
                "Link leads to a site that is not uwv.nl",
                "Request for your DigiD credentials or bank details"
            ],
            whatToDo: "Log in to mijn.uwv.nl directly to check your messages. Do not follow links in emails. Report to Fraudehelpdesk.nl.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        // MARK: - Impostor

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:fake-police-officer-demanding-payment"),
            title: "Fake Police Officer Demanding Payment",
            category: .impostor,
            howItWorks: "Someone calls or approaches you claiming to be a police officer. They say you owe a fine and must pay immediately in cash or via bank transfer to avoid arrest. Real police do not collect fines this way.",
            warningSignals: [
                "Real police never demand immediate cash payment for fines",
                "Caller refuses to give an official badge number",
                "Pressure to act immediately without verification",
                "Payment requested via unusual methods (vouchers, crypto, cash)"
            ],
            whatToDo: "Do not pay. Ask for the person's name and badge number. Call the police non-emergency line (0900-8844) to verify. Official fines are sent by post from CJIB.",
            reportTo: "Politie.nl — 0900-8844",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.politie.nl"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:fake-ind-letter-requesting-payment"),
            title: "Fake IND Letter Requesting Payment",
            category: .impostor,
            howItWorks: "You receive a letter, email, or call claiming to be from the IND (Immigration Service) saying your permit application has an issue and you must pay a fee immediately to avoid cancellation.",
            warningSignals: [
                "IND fees are paid via official channels at ind.nl, not via SMS or phone",
                "Urgent payment deadline with threat of visa cancellation",
                "Request for payment via bank transfer to an unknown account",
                "Message contains spelling errors or unusual formatting"
            ],
            whatToDo: "Do not pay. Check your official IND portal at mijn.ind.nl or call IND directly via 088 043 0430. All real IND communications come through official post or the MijnIND portal.",
            reportTo: "IND — ind.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://ind.nl/en"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:fake-debt-collector-threatening-legal-action"),
            title: "Fake Debt Collector Threatening Legal Action",
            category: .impostor,
            howItWorks: "Someone calls claiming to be a bailiff (deurwaarder) or debt collection agency. They say you have an unpaid debt and must pay immediately or face consequences. They may have some of your personal details to seem legitimate.",
            warningSignals: [
                "Real bailiffs always send a registered letter before visiting",
                "Caller refuses to provide official written documentation",
                "Payment demanded via untraceable methods",
                "Extreme urgency and threats of immediate arrest or seizure"
            ],
            whatToDo: "Ask for the company name, reference number, and a written notice. Verify with the creditor directly. Real debt collection always involves written documentation. Report suspicious calls to Fraudehelpdesk.nl.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:fake-government-whatsapp-requesting-digid"),
            title: "Fake Government WhatsApp Requesting DigiD",
            category: .impostor,
            howItWorks: "A WhatsApp message appears to come from a government body, municipality, or official service. It asks you to share your DigiD login or verify your identity by logging in through a link.",
            warningSignals: [
                "Dutch government agencies do not contact you via WhatsApp for sensitive actions",
                "Request to share your DigiD credentials",
                "Profile picture shows an official logo but the number is unknown",
                "Message claims urgency around a benefit, permit, or fine"
            ],
            whatToDo: "Do not respond or click any links. Government bodies communicate via official post, MijnOverheid, or their own portals. Report the message to Fraudehelpdesk.nl.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        // MARK: - Rental

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:fake-rental-listing-pay-deposit-and-never-get-the-key"),
            title: "Fake Rental Listing — Pay Deposit and Never Get the Key",
            category: .rental,
            howItWorks: "A rental listing on a housing platform or social media shows an attractively priced apartment. The 'landlord' says they are abroad and will mail you the key after you pay a deposit or first month's rent.",
            warningSignals: [
                "Landlord is 'abroad' and cannot show the property in person",
                "Price is significantly below market rate",
                "Request for payment before signing any contract",
                "Communication is rushed and discourages questions"
            ],
            whatToDo: "Never transfer money before viewing a property in person and signing a proper rental contract. Verify the landlord's identity. Use official platforms like Funda.nl or verified agencies.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:landlord-demands-excessive-cash-deposit-without-contract"),
            title: "Landlord Demands Excessive Cash Deposit Without Contract",
            category: .rental,
            howItWorks: "A landlord requests a large cash deposit — sometimes several months of rent — without providing a proper rental contract. After payment, the landlord becomes unreachable or denies the agreement.",
            warningSignals: [
                "Deposit requested in cash only, no paper trail",
                "Rental contract not provided before payment",
                "Landlord pressures you to decide immediately",
                "Amount exceeds two months' rent (the legal maximum deposit)"
            ],
            whatToDo: "Always insist on a written rental contract before paying anything. Deposits should be paid by bank transfer for a paper trail. The legal maximum deposit in the Netherlands is typically two months' rent.",
            reportTo: "Juridisch Loket — juridischloket.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.juridischloket.nl"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:fake-housing-association-email-about-rent-arrears"),
            title: "Fake Housing Association Email About Rent Arrears",
            category: .rental,
            howItWorks: "You receive an email claiming to be from your housing association (woningcorporatie) saying you have rent arrears and must pay immediately to avoid eviction. The email contains a payment link.",
            warningSignals: [
                "Sender email domain does not match your housing association",
                "Payment link goes to an unfamiliar website",
                "Threat of immediate eviction without prior official notices",
                "Request for payment outside your normal rent payment process"
            ],
            whatToDo: "Do not click the link. Contact your housing association directly using the contact details from their official website. Check your rent account through their official portal.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        // MARK: - Financial

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:investment-scam-promising-guaranteed-returns"),
            title: "Investment Scam Promising Guaranteed Returns",
            category: .financial,
            howItWorks: "You are approached online or via social media with an investment opportunity promising unusually high, guaranteed returns with no risk. You invest money, see fake 'profits' on a dashboard, but cannot withdraw.",
            warningSignals: [
                "Guaranteed high returns — legitimate investments always carry risk",
                "Pressure to invest quickly before a deadline",
                "Website or platform has no verifiable registration with AFM (Dutch financial regulator)",
                "Profits are visible on a dashboard but withdrawals are blocked or require more fees"
            ],
            whatToDo: "Check if the company is registered at afm.nl before investing. Never invest money you cannot afford to lose. Report suspected investment fraud to AFM and Fraudehelpdesk.nl.",
            reportTo: "AFM — afm.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.afm.nl"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:advance-fee-fraud-pay-to-receive-a-benefit"),
            title: "Advance Fee Fraud — Pay to Receive a Benefit",
            category: .financial,
            howItWorks: "You are told you are eligible for a large benefit, inheritance, or prize but must pay a small 'administration fee' or 'tax' first to release the funds. No funds ever arrive.",
            warningSignals: [
                "You are promised money you did not expect or apply for",
                "Small upfront payment required to release larger funds",
                "Communications are informal, via personal email or WhatsApp",
                "Each payment is followed by a request for another fee"
            ],
            whatToDo: "Legitimate benefits and winnings never require advance payment. Do not transfer any money. Report to Fraudehelpdesk.nl.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:fake-utilities-company-demanding-immediate-payment"),
            title: "Fake Utilities Company Demanding Immediate Payment",
            category: .financial,
            howItWorks: "A caller or email claims to be your energy or utilities provider, saying your service will be cut off unless you pay an outstanding amount immediately via a direct payment link.",
            warningSignals: [
                "Your actual provider name is not mentioned or is slightly misspelled",
                "Immediate payment deadline within hours",
                "Payment via unusual methods rather than your normal billing process",
                "Caller does not know your account details but insists the bill is overdue"
            ],
            whatToDo: "Log in to your utilities provider account directly through their official website. Call the number on your contract or bill. Do not pay via links in calls or emails.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        // MARK: - Employment

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:job-offer-requiring-upfront-payment"),
            title: "Job Offer Requiring Upfront Payment",
            category: .employment,
            howItWorks: "You see a job offer, often with very attractive pay. Before you can start, the employer asks you to pay for training materials, a background check, a uniform, or a registration fee. The job then disappears.",
            warningSignals: [
                "Legitimate employers never ask new hires to pay for standard onboarding",
                "Offer is unusually well-paid for minimal qualifications",
                "Communication is via personal email or messaging app, not a company address",
                "You are asked to pay before any formal contract is signed"
            ],
            whatToDo: "Never pay to get a job. Verify the employer's existence via KVK (Chamber of Commerce) at kvk.nl. Report to Fraudehelpdesk.nl.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:fake-visa-or-work-permit-service"),
            title: "Fake Visa or Work Permit Service",
            category: .employment,
            howItWorks: "A company or individual offers to arrange your work permit or residence permit for a fee, claiming to have special access or a faster process. They collect money and personal documents but provide nothing official.",
            warningSignals: [
                "Claims of 'guaranteed' permit approval or special government connections",
                "Requests original documents to be mailed or shared",
                "No verifiable registration as an authorised agent",
                "Fees are unusually high or vague"
            ],
            whatToDo: "Residence and work permits must be applied for through the IND (ind.nl) directly or via a verified legal professional. Never give original documents to unverified parties.",
            reportTo: "IND — ind.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://ind.nl/en"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:money-mule-courier-job-scam"),
            title: "Money Mule Courier Job Scam",
            category: .employment,
            howItWorks: "A job offer asks you to receive packages or payments at your address and then forward them onward. You are acting as an unknowing 'money mule' — part of a money laundering or fraud chain. This is illegal even if you did not know.",
            warningSignals: [
                "Job involves receiving and reshipping packages or transferring money",
                "No clear business purpose is explained",
                "High pay for very simple work",
                "Employer emphasises secrecy about the nature of the work"
            ],
            whatToDo: "Do not accept or reshipping packages or money for unknown parties. Participating — even unknowingly — can result in criminal investigation. Report suspicious job offers to Fraudehelpdesk.nl.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        // MARK: - Digital Identity

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:someone-asks-to-use-your-digid"),
            title: "Someone Asks to Use Your DigiD",
            category: .digitalIdentity,
            howItWorks: "Someone — sometimes a person you know slightly or met online — asks to borrow your DigiD login to help with their application, or to earn money by 'renting' your DigiD. This allows them to commit fraud using your identity.",
            warningSignals: [
                "Anyone asking to use or borrow your DigiD login",
                "Offer of payment for access to your DigiD",
                "Claims that it is 'just for one form' and nothing will go wrong",
                "Pressure from someone in an authority or helping role"
            ],
            whatToDo: "Never share your DigiD with anyone for any reason. It is your personal digital identity. Sharing it can make you liable for fraud committed in your name. Report to DigiD at digid.nl.",
            reportTo: "DigiD — digid.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.digid.nl/en"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:fake-ideal-payment-request"),
            title: "Fake iDEAL Payment Request",
            category: .digitalIdentity,
            howItWorks: "You receive a payment request via SMS, email, or messaging app that appears to use iDEAL. The link goes to a fake banking page that harvests your login credentials.",
            warningSignals: [
                "iDEAL payment links should come from the seller's platform, not unsolicited messages",
                "The bank login page looks slightly different from your real bank",
                "URL does not match your bank's official domain",
                "Unusual amount or payment reference that you did not initiate"
            ],
            whatToDo: "Only complete iDEAL payments from within trusted platforms (webshops, apps). Never follow payment links received unsolicited. Check the URL carefully before entering any bank credentials.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:fake-survey-collecting-personal-data"),
            title: "Fake Survey Collecting Personal Data",
            category: .digitalIdentity,
            howItWorks: "You are invited to complete a survey, often claiming to be from a government body or well-known company, with a prize or benefit on completion. The survey collects your BSN, address, passport copy, or other sensitive information.",
            warningSignals: [
                "Request for BSN, passport, or financial details as part of a survey",
                "Unsolicited invitation via email or social media",
                "Prize or reward seems disproportionately large",
                "Survey website domain does not match the claimed organisation"
            ],
            whatToDo: "Never provide BSN, passport details, or financial information via a survey link. Legitimate government surveys do not offer prizes. Report to Fraudehelpdesk.nl.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        ),

        ScamWarning(
            id: StableRouteID.uuid("scam-warning:helpdesk-scam-remote-access-to-your-computer"),
            title: "Helpdesk Scam — Remote Access to Your Computer",
            category: .digitalIdentity,
            howItWorks: "You receive a call or pop-up claiming your computer has a virus or your bank account has been compromised. A 'technician' asks you to install software granting them remote access to fix the problem.",
            warningSignals: [
                "Unsolicited contact claiming you have a computer virus",
                "Request to install remote access software (AnyDesk, TeamViewer, etc.)",
                "Pop-up with a phone number claiming to be Microsoft, Apple, or your bank",
                "They ask to see your banking app or DigiD during the 'help session'"
            ],
            whatToDo: "Hang up or close the pop-up. Microsoft, Apple, and banks never contact you this way. If you already granted access, disconnect immediately, restart your device, and contact your bank. Report to Fraudehelpdesk.nl.",
            reportTo: "Fraudehelpdesk.nl",
            reportURL: AppURL.validatedWebURL(URL(string: "https://www.fraudehelpdesk.nl"))
        )
    ]
}
