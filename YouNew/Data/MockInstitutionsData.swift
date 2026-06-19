import Foundation

nonisolated enum MockInstitutionsData {
    static let items: [Institution] = [
        Institution(
            name: "IND",
            shortExplanationByLanguage: [
                .english: "Immigration and Naturalisation Service.",
                .dutch:   "Immigratie- en Naturalisatiedienst.",
                .russian: "Служба иммиграции и натурализации."
            ],
            usageByLanguage: [
                .english: "Residence permits and immigration procedures.",
                .dutch:   "Verblijfsvergunningen en immigratieprocedures.",
                .russian: "Разрешения на проживание и иммиграционные процедуры."
            ],
            whenToUseByLanguage: [
                .english: "You may interact with IND for residence status questions or permit updates.",
                .dutch:   "Je kunt contact opnemen met IND voor vragen over verblijfsstatus of vergunningsupdates.",
                .russian: "Вам может понадобиться IND при вопросах о статусе проживания или обновлении разрешения."
            ],
            commonConfusionByLanguage: [
                .english: "People often confuse IND updates with municipality updates. These are separate processes.",
                .dutch:   "Mensen verwarren IND-updates vaak met gemeentelijke updates. Dit zijn aparte processen.",
                .russian: "Многие путают обновления IND с обновлениями в муниципалитете. Это разные процессы."
            ],
            officialWebsiteURL: AppURL.make("https://ind.nl"),
            warningByLanguage: [
                .english: "Always verify information directly on ind.nl.",
                .dutch:   "Verifieer informatie altijd rechtstreeks op ind.nl.",
                .russian: "Всегда проверяйте информацию напрямую на ind.nl."
            ],
            personaTags: [.refugee, .nonEU, .highlySkilledMigrant]
        ),
        Institution(
            name: "DUO",
            shortExplanationByLanguage: [
                .english: "Education Executive Agency.",
                .dutch:   "Dienst Uitvoering Onderwijs.",
                .russian: "Исполнительное агентство по образованию."
            ],
            usageByLanguage: [
                .english: "Student finance and education administration.",
                .dutch:   "Studiefinanciering en onderwijsadministratie.",
                .russian: "Студенческие выплаты и администрирование образования."
            ],
            whenToUseByLanguage: [
                .english: "Students may use DUO for education-related requests and messages.",
                .dutch:   "Studenten kunnen DUO gebruiken voor onderwijs gerelateerde verzoeken en berichten.",
                .russian: "Студенты могут обращаться в DUO по вопросам образования и сообщениям."
            ],
            commonConfusionByLanguage: [
                .english: "Many newcomers think all student matters go through schools only. Some may go through DUO.",
                .dutch:   "Veel nieuwkomers denken dat alle studentenzaken alleen via scholen lopen. Sommige gaan via DUO.",
                .russian: "Многие новички думают, что все студенческие вопросы решаются только через школу. Часть — через DUO."
            ],
            officialWebsiteURL: AppURL.make("https://duo.nl"),
            warningByLanguage: [
                .english: "Always verify information directly on duo.nl.",
                .dutch:   "Verifieer informatie altijd rechtstreeks op duo.nl.",
                .russian: "Всегда проверяйте информацию напрямую на duo.nl."
            ],
            personaTags: [.student, .refugee, .family]
        ),
        Institution(
            name: "UWV",
            shortExplanationByLanguage: [
                .english: "Dutch employee insurance and work agency.",
                .dutch:   "Uitvoeringsinstituut Werknemersverzekeringen.",
                .russian: "Агентство страхования работников и трудоустройства."
            ],
            usageByLanguage: [
                .english: "Work-related benefits and employment support.",
                .dutch:   "Werkgerelateerde uitkeringen en ondersteuning bij werk.",
                .russian: "Пособия по безработице и поддержка в трудоустройстве."
            ],
            whenToUseByLanguage: [
                .english: "Workers may interact with UWV during job transitions or benefit-related situations.",
                .dutch:   "Werknemers kunnen contact opnemen met UWV bij baanwisselingen of uitkeringssituaties.",
                .russian: "Работники могут обращаться в UWV при смене работы или вопросах о пособиях."
            ],
            commonConfusionByLanguage: [
                .english: "UWV is not the same as Belastingdienst or IND.",
                .dutch:   "UWV is niet hetzelfde als Belastingdienst of IND.",
                .russian: "UWV — это не то же самое, что Belastingdienst или IND."
            ],
            officialWebsiteURL: AppURL.make("https://www.uwv.nl"),
            warningByLanguage: [
                .english: "Always verify information directly on uwv.nl.",
                .dutch:   "Verifieer informatie altijd rechtstreeks op uwv.nl.",
                .russian: "Всегда проверяйте информацию напрямую на uwv.nl."
            ],
            personaTags: [.worker, .refugee]
        ),
        Institution(
            name: "Belastingdienst",
            shortExplanationByLanguage: [
                .english: "Dutch Tax Administration.",
                .dutch:   "Nederlandse belastingdienst.",
                .russian: "Налоговая служба Нидерландов."
            ],
            usageByLanguage: [
                .english: "Taxes, allowances, and tax letters.",
                .dutch:   "Belastingen, toeslagen en belastingbrieven.",
                .russian: "Налоги, пособия и налоговые письма."
            ],
            whenToUseByLanguage: [
                .english: "You may receive tax letters after registration, employment, or benefit changes.",
                .dutch:   "Je kunt belastingbrieven ontvangen na registratie, werk of wijzigingen in toeslagen.",
                .russian: "Вы можете получать налоговые письма после регистрации, трудоустройства или изменения пособий."
            ],
            commonConfusionByLanguage: [
                .english: "People often assume all letters are payment requests. Some letters are informational.",
                .dutch:   "Mensen denken vaak dat alle brieven betalingsverzoeken zijn. Sommige zijn informatief.",
                .russian: "Многие думают, что все письма — это требования об оплате. Некоторые — просто информационные."
            ],
            officialWebsiteURL: AppURL.make("https://www.belastingdienst.nl"),
            warningByLanguage: [
                .english: "Always verify information directly on belastingdienst.nl.",
                .dutch:   "Verifieer informatie altijd rechtstreeks op belastingdienst.nl.",
                .russian: "Всегда проверяйте информацию напрямую на belastingdienst.nl."
            ],
            personaTags: [.worker, .family, .eu, .highlySkilledMigrant, .entrepreneur]
        ),
        Institution(
            name: "DigiD",
            shortExplanationByLanguage: [
                .english: "Digital login for many government services.",
                .dutch:   "Digitale inlogmethode voor overheidsdiensten.",
                .russian: "Цифровой вход для государственных сервисов."
            ],
            usageByLanguage: [
                .english: "Identity verification for official online portals.",
                .dutch:   "Identiteitsverificatie voor officiële online portalen.",
                .russian: "Подтверждение личности на официальных онлайн-порталах."
            ],
            whenToUseByLanguage: [
                .english: "You may need DigiD when checking records or responding to official requests online.",
                .dutch:   "Je hebt DigiD mogelijk nodig bij het inzien van gegevens of reageren op officiële online verzoeken.",
                .russian: "DigiD потребуется при просмотре записей или ответе на официальные онлайн-запросы."
            ],
            commonConfusionByLanguage: [
                .english: "DigiD itself is a login method, not a decision-making institution.",
                .dutch:   "DigiD zelf is een inlogmethode, geen besluitvormende instelling.",
                .russian: "DigiD — это метод входа, а не организация, принимающая решения."
            ],
            officialWebsiteURL: AppURL.make("https://www.digid.nl"),
            warningByLanguage: [
                .english: "Always verify information directly on digid.nl.",
                .dutch:   "Verifieer informatie altijd rechtstreeks op digid.nl.",
                .russian: "Всегда проверяйте информацию напрямую на digid.nl."
            ],
            personaTags: [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        ),
        Institution(
            name: "CJIB",
            shortExplanationByLanguage: [
                .english: "Central Judicial Collection Agency.",
                .dutch:   "Centraal Justitieel Incassobureau.",
                .russian: "Центральное агентство по взысканию судебных платежей."
            ],
            usageByLanguage: [
                .english: "Government payment collection, including many traffic-related fines.",
                .dutch:   "Overheidsincasso, waaronder verkeersboetes.",
                .russian: "Взыскание государственных платежей, включая штрафы за нарушения ПДД."
            ],
            whenToUseByLanguage: [
                .english: "You may interact with CJIB if you receive an official payment notice.",
                .dutch:   "Je kunt contact opnemen met CJIB als je een officiële betalingskennisgeving ontvangt.",
                .russian: "Вы можете получить уведомление от CJIB при наличии официального требования об оплате."
            ],
            commonConfusionByLanguage: [
                .english: "Scam messages may imitate CJIB. Verify domain and letter details carefully.",
                .dutch:   "Oplichters kunnen CJIB nabootsen. Controleer domein en briefdetails zorgvuldig.",
                .russian: "Мошеннические сообщения могут имитировать CJIB. Тщательно проверяйте домен и реквизиты письма."
            ],
            officialWebsiteURL: AppURL.make("https://www.cjib.nl"),
            warningByLanguage: [
                .english: "Always verify information directly on cjib.nl.",
                .dutch:   "Verifieer informatie altijd rechtstreeks op cjib.nl.",
                .russian: "Всегда проверяйте информацию напрямую на cjib.nl."
            ],
            personaTags: [.worker, .tourist, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur]
        ),
        Institution(
            name: "RDW",
            shortExplanationByLanguage: [
                .english: "Vehicle authority in the Netherlands.",
                .dutch:   "Rijksdienst voor het Wegverkeer.",
                .russian: "Служба регистрации транспортных средств Нидерландов."
            ],
            usageByLanguage: [
                .english: "Vehicle registration and driving-related checks.",
                .dutch:   "Voertuigregistratie en rijgerelateerde controles.",
                .russian: "Регистрация транспортных средств и проверка водительских документов."
            ],
            whenToUseByLanguage: [
                .english: "Drivers and vehicle owners may need RDW information.",
                .dutch:   "Bestuurders en voertuigeigenaren hebben mogelijk RDW-informatie nodig.",
                .russian: "Водителям и владельцам транспортных средств может понадобиться информация от RDW."
            ],
            commonConfusionByLanguage: [
                .english: "RDW procedures can differ from municipal registration requirements.",
                .dutch:   "RDW-procedures kunnen afwijken van gemeentelijke registratievereisten.",
                .russian: "Процедуры RDW могут отличаться от требований муниципальной регистрации."
            ],
            officialWebsiteURL: AppURL.make("https://www.rdw.nl"),
            warningByLanguage: [
                .english: "Always verify information directly on rdw.nl.",
                .dutch:   "Verifieer informatie altijd rechtstreeks op rdw.nl.",
                .russian: "Всегда проверяйте информацию напрямую на rdw.nl."
            ],
            personaTags: [.worker, .tourist, .eu, .highlySkilledMigrant, .entrepreneur]
        ),
        Institution(
            name: "Juridisch Loket",
            shortExplanationByLanguage: [
                .english: "First-line legal information service.",
                .dutch:   "Eerste lijn juridische informatiedienst.",
                .russian: "Служба первичной юридической информации."
            ],
            usageByLanguage: [
                .english: "Basic legal orientation and referral.",
                .dutch:   "Basisjuridische oriëntatie en doorverwijzing.",
                .russian: "Базовая юридическая ориентация и направление к специалистам."
            ],
            whenToUseByLanguage: [
                .english: "You may use it when you need initial legal information in plain language.",
                .dutch:   "Je kunt het gebruiken als je initiële juridische informatie in begrijpelijke taal nodig hebt.",
                .russian: "Вы можете обратиться сюда, когда нужна первичная юридическая информация простым языком."
            ],
            commonConfusionByLanguage: [
                .english: "It provides guidance and referral, not full legal representation in every case.",
                .dutch:   "Het biedt begeleiding en doorverwijzing, geen volledige juridische vertegenwoordiging in elk geval.",
                .russian: "Служба предоставляет консультации и направления, а не полное юридическое представление."
            ],
            officialWebsiteURL: AppURL.make("https://www.juridischloket.nl"),
            warningByLanguage: [
                .english: "Always verify information directly on juridischloket.nl.",
                .dutch:   "Verifieer informatie altijd rechtstreeks op juridischloket.nl.",
                .russian: "Всегда проверяйте информацию напрямую на juridischloket.nl."
            ],
            personaTags: [.worker, .refugee, .family, .entrepreneur, .lgbt]
        ),
        Institution(
            name: "Government.nl",
            shortExplanationByLanguage: [
                .english: "Official Dutch government information portal.",
                .dutch:   "Officieel informatieportaal van de Nederlandse overheid.",
                .russian: "Официальный информационный портал правительства Нидерландов."
            ],
            usageByLanguage: [
                .english: "General rules, procedures, and public information.",
                .dutch:   "Algemene regels, procedures en openbare informatie.",
                .russian: "Общие правила, процедуры и публичная информация."
            ],
            whenToUseByLanguage: [
                .english: "Use it to cross-check broad topics before following local institution instructions.",
                .dutch:   "Gebruik het om brede onderwerpen te controleren voordat je lokale instructies volgt.",
                .russian: "Используйте для перекрёстной проверки общих тем перед выполнением инструкций организаций."
            ],
            commonConfusionByLanguage: [
                .english: "General guidance may still require a municipality or institution-specific step.",
                .dutch:   "Algemene richtlijnen vereisen mogelijk nog een gemeente- of instellingsspecifieke stap.",
                .russian: "Общие рекомендации могут потребовать дополнительного шага в муниципалитете или организации."
            ],
            officialWebsiteURL: AppURL.make("https://www.government.nl"),
            warningByLanguage: [
                .english: "Always verify information directly on government.nl.",
                .dutch:   "Verifieer informatie altijd rechtstreeks op government.nl.",
                .russian: "Всегда проверяйте информацию напрямую на government.nl."
            ],
            personaTags: [.universal]
        ),
        Institution(
            name: "Municipality",
            shortExplanationByLanguage: [
                .english: "Your local city administration.",
                .dutch:   "Uw lokale gemeentebestuur.",
                .russian: "Местная городская администрация."
            ],
            usageByLanguage: [
                .english: "Address registration and local civic services.",
                .dutch:   "Adresregistratie en lokale burgerlijke diensten.",
                .russian: "Регистрация адреса и местные гражданские услуги."
            ],
            whenToUseByLanguage: [
                .english: "Most newcomers may interact with their municipality early after arrival.",
                .dutch:   "De meeste nieuwkomers kunnen al vroeg na aankomst contact hebben met hun gemeente.",
                .russian: "Большинство новичков обращаются в свой муниципалитет вскоре после приезда."
            ],
            commonConfusionByLanguage: [
                .english: "Municipal requirements can differ by city, so verify locally.",
                .dutch:   "Gemeentelijke vereisten kunnen per stad verschillen, dus controleer dit lokaal.",
                .russian: "Требования муниципалитетов могут отличаться в зависимости от города, уточняйте на месте."
            ],
            officialWebsiteURL: AppURL.make("https://www.government.nl/topics/municipalities"),
            warningByLanguage: [
                .english: "Always verify information directly with your local municipality.",
                .dutch:   "Verifieer informatie altijd rechtstreeks bij uw lokale gemeente.",
                .russian: "Всегда проверяйте информацию напрямую в своём муниципалитете."
            ],
            personaTags: [.worker, .refugee, .family, .eu, .nonEU, .highlySkilledMigrant, .entrepreneur, .lgbt]
        )
    ]
}
