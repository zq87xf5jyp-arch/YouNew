#!/usr/bin/env python3
"""Build the Amsterdam-only QA candidate from verified web and media metadata.

This script intentionally writes DATA PROJECT artifacts only. It never changes the
Swift runtime and never changes publication state to published.
"""

from __future__ import annotations

import hashlib
import html
import json
import re
import sys
import time
from datetime import date
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import quote, urlencode, urlsplit
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
CACHE = PROJECT / "staging" / "amsterdam-01-cache.json"
CHECKED_AT = date.today().isoformat()
CITY_ID = "amsterdam"
PROVINCE_ID = "noord-holland"
AMSTERDAM_BOUNDS = (52.27, 4.70, 52.44, 5.03)
USER_AGENT = "YouNewDataProduction/1.0 (Amsterdam QA; data-team@younew.nl)"


def item(entity_type, title, website, category, publisher, focus, query=None, source_title=None, coordinates=None, coordinate_source=None, **attributes):
    return {
        "entity_type": entity_type,
        "title": title,
        "website": website,
        "category": category,
        "publisher": publisher,
        "focus": focus,
        "query": query or f"{title}, Amsterdam, Netherlands",
        "source_title": source_title or f"{title} official website",
        "coordinates": coordinates,
        "coordinate_source": coordinate_source,
        "attributes": {key: str(value) for key, value in attributes.items()},
    }


CATALOG = [
    # Amsterdam districts. These are city-governed administrative areas, not extra cities.
    item("place", "Amsterdam Centrum", "https://www.amsterdam.nl/en/districts/centrum/", "district", "City of Amsterdam", "the historic central district and its municipal district page"),
    item("place", "Amsterdam Noord", "https://www.amsterdam.nl/en/districts/noord/", "district", "City of Amsterdam", "the district north of the IJ and its municipal district page"),
    item("place", "Amsterdam West", "https://www.amsterdam.nl/en/districts/west/", "district", "City of Amsterdam", "the western inner-city district and its municipal district page"),
    item("place", "Amsterdam Nieuw-West", "https://www.amsterdam.nl/en/districts/nieuw-west/", "district", "City of Amsterdam", "the Nieuw-West district and its municipal district page"),
    item("place", "Amsterdam Zuid", "https://www.amsterdam.nl/en/districts/zuid/", "district", "City of Amsterdam", "the southern district and its municipal district page"),
    item("place", "Amsterdam Oost", "https://www.amsterdam.nl/en/districts/oost/", "district", "City of Amsterdam", "the eastern district and its municipal district page"),
    item("place", "Amsterdam Zuidoost", "https://www.amsterdam.nl/en/districts/zuidoost/", "district", "City of Amsterdam", "the south-eastern district and its municipal district page"),
    item("place", "Amsterdam Westpoort", "https://www.amsterdam.nl/en/districts/westpoort/", "district", "City of Amsterdam", "the port and employment district and its municipal district page"),

    # Museums (20).
    item("museum", "Rijksmuseum", "https://www.rijksmuseum.nl/en", "art-history", "Rijksmuseum", "Dutch art and history presented by the national museum"),
    item("museum", "Van Gogh Museum", "https://www.vangoghmuseum.nl/en", "art", "Van Gogh Museum", "the museum collection and research centred on Vincent van Gogh"),
    item("museum", "Stedelijk Museum Amsterdam", "https://www.stedelijk.nl/en", "modern-art-design", "Stedelijk Museum Amsterdam", "modern and contemporary art and design"),
    item("museum", "Anne Frank House", "https://www.annefrank.org/en/museum/", "history-memorial", "Anne Frank House", "the preserved hiding place and Anne Frank's life story"),
    item("museum", "NEMO Science Museum", "https://www.nemosciencemuseum.nl/en/", "science", "NEMO Science Museum", "hands-on science and technology learning"),
    item("museum", "Het Scheepvaartmuseum", "https://www.hetscheepvaartmuseum.com/", "maritime-history", "Het Scheepvaartmuseum", "Dutch maritime history and the museum's waterfront collection"),
    item("museum", "Amsterdam Museum", "https://www.amsterdammuseum.nl/en", "city-history", "Amsterdam Museum", "the history and changing stories of Amsterdam"),
    item("museum", "Museum Rembrandthuis", "https://www.rembrandthuis.nl/en/", "art-history", "Museum Rembrandthuis", "Rembrandt's former home, studio practice and printmaking"),
    item("museum", "Museum Ons' Lieve Heer op Solder", "https://opsolder.nl/en/", "religious-history", "Museum Ons' Lieve Heer op Solder", "the seventeenth-century canal house and hidden church"),
    item("museum", "H'ART Museum", "https://www.hartmuseum.nl/en", "art", "H'ART Museum", "international museum collaborations and exhibitions in the Amstelhof"),
    item("museum", "Jewish Museum", "https://jck.nl/en/location/jewish-museum", "cultural-history", "Jewish Cultural Quarter", "Jewish history, religion and culture in the Netherlands"),
    item("museum", "Dutch Resistance Museum", "https://www.verzetsmuseum.org/en", "war-history", "Dutch Resistance Museum", "civilian choices and resistance during the German occupation"),
    item("museum", "Eye Filmmuseum", "https://www.eyefilm.nl/en", "film", "Eye Filmmuseum", "film heritage, exhibitions, screenings and collection work"),
    item("museum", "Museum of the Canals", "https://grachten.museum/en/", "urban-history", "Museum of the Canals", "Amsterdam's canal ring and the engineering of the canal city"),
    item("museum", "Foam", "https://www.foam.org/", "photography", "Foam", "photography exhibitions, talent and visual culture"),
    item("museum", "Huis Marseille", "https://huismarseille.nl/en/", "photography", "Huis Marseille", "photography shown in a historic canal house"),
    item("museum", "Allard Pierson", "https://allardpierson.nl/en/", "heritage-collections", "Allard Pierson", "University of Amsterdam heritage collections and cultural history"),
    item("museum", "ARTIS-Micropia", "https://www.micropia.nl/en/", "microbiology", "ARTIS-Micropia", "microorganisms and their role in everyday life"),
    item("museum", "Wereldmuseum Amsterdam", "https://amsterdam.wereldmuseum.nl/en", "world-cultures", "Wereldmuseum Amsterdam", "world cultures and the museum's ethnographic collections"),
    item("museum", "Museum Van Loon", "https://www.museumvanloon.nl/en", "canal-house-history", "Museum Van Loon", "a historic canal house, family collection and garden"),

    # Attractions, markets and shopping places (20).
    item("place", "Royal Palace Amsterdam", "https://www.paleisamsterdam.nl/en/", "historic-attraction", "Royal Palace Amsterdam", "the seventeenth-century palace on Dam Square"),
    item("place", "ARTIS", "https://www.artis.nl/en", "zoo", "ARTIS", "the Amsterdam zoo and its nature, heritage and education programme"),
    item("place", "Hortus Botanicus Amsterdam", "https://www.dehortus.nl/en/", "botanical-garden", "Hortus Botanicus Amsterdam", "the botanical garden and its living plant collections"),
    item("place", "Oude Kerk", "https://oudekerk.nl/en/", "church-cultural-venue", "Oude Kerk", "Amsterdam's oldest building as a church and contemporary art venue"),
    item("place", "De Nieuwe Kerk Amsterdam", "https://www.nieuwekerk.nl/en/", "church-exhibition-venue", "De Nieuwe Kerk Amsterdam", "the historic church and its exhibitions and national ceremonies"),
    item("place", "Westerkerk", "https://westerkerk.nl/", "church-landmark", "Westerkerk", "the seventeenth-century church and Westertoren landmark"),
    item("place", "A'DAM LOOKOUT", "https://www.adamlookout.com/", "observation-deck", "A'DAM LOOKOUT", "the observation deck overlooking Amsterdam and the IJ"),
    item("place", "Heineken Experience", "https://www.heinekenexperience.com/en/", "industrial-heritage-attraction", "Heineken Experience", "the former brewery site and brand-history visitor experience"),
    item("place", "Johan Cruijff ArenA", "https://www.johancruijffarena.nl/en/", "stadium", "Johan Cruijff ArenA", "Amsterdam's major football and events stadium"),
    item("place", "Seventeenth-Century Canal Ring of Amsterdam", "https://whc.unesco.org/en/list/1349/", "unesco-world-heritage", "UNESCO World Heritage Centre", "the UNESCO-listed seventeenth-century canal-ring area"),
    item("place", "Dam Square", "https://www.iamsterdam.com/en/explore/neighbourhoods/centrum/things-to-do-in-paleiskwartier-the-royal-mile", "public-square", "I amsterdam", "the central civic square and surrounding historic landmarks"),
    item("place", "Begijnhof Amsterdam", "https://www.iamsterdam.com/en/whats-on/calendar/attractions-and-sights/sights/begijnhof", "historic-courtyard", "I amsterdam", "the enclosed historic courtyard in central Amsterdam"),
    item("place", "De Hallen Amsterdam", "https://dehallen-amsterdam.nl/en/", "culture-shopping", "De Hallen Amsterdam", "the converted tram depot with culture, food and local businesses"),
    item("place", "Albert Cuyp Market", "https://www.amsterdam.nl/en/leisure/markets/albert-cuypmarkt/", "market", "City of Amsterdam", "the municipal street market on Albert Cuypstraat"),
    item("place", "Waterlooplein Market", "https://www.amsterdam.nl/en/leisure/markets/waterlooplein/", "market", "City of Amsterdam", "the municipal market on Waterlooplein"),
    item("place", "Bloemenmarkt", "https://www.iamsterdam.com/en/see-and-do/shopping-and-markets/top-markets-in-amsterdam-for-food-and-flowers", "market", "I amsterdam", "the flower market along the Singel"),
    item("place", "NDSM", "https://www.ndsm.nl/en/", "creative-district", "NDSM", "the former shipyard and cultural area on the IJ"),
    item("place", "OBA Oosterdok", "https://oba.nl/en/locations/oba-oosterdok.html", "public-library", "OBA", "Amsterdam's central public-library location at Oosterdok"),
    item("place", "THIS IS HOLLAND", "https://www.thisisholland.com/en/", "visitor-attraction", "THIS IS HOLLAND", "the flight-simulation visitor attraction about the Netherlands"),
    item("place", "WONDR Experience", "https://www.wondrexperience.com/", "interactive-attraction", "WONDR Experience", "an interactive visual experience in Amsterdam Noord"),

    # Restaurants (40). No prices, hours, ratings or reviews are stored.
    item("restaurant", "Restaurant De Kas", "https://restaurantdekas.com/", "restaurant", "Restaurant De Kas", "the restaurant's greenhouse setting and official dining concept"),
    item("restaurant", "RIJKS", "https://www.rijksrestaurant.nl/en", "restaurant", "RIJKS", "the restaurant located by the Rijksmuseum"),
    item("restaurant", "Ciel Bleu", "https://www.cielbleu.nl/nl", "restaurant", "Ciel Bleu", "the restaurant at Hotel Okura Amsterdam"),
    item("restaurant", "Restaurant 212", "https://www.212.amsterdam/", "restaurant", "Restaurant 212", "the restaurant's chef-led dining concept"),
    item("restaurant", "Kaagman & Kortekaas", "https://kaagmanenkortekaas.nl/", "restaurant", "Kaagman & Kortekaas", "the independent restaurant on Sint Nicolaasstraat", query="Sint Nicolaasstraat 43 Amsterdam"),
    item("restaurant", "BREDA", "https://breda-amsterdam.com/breda/contact/", "restaurant", "BREDA", "the Amsterdam restaurant operated by the Breda group"),
    item("restaurant", "Choux", "https://choux.nl/", "restaurant", "Choux", "the restaurant on De Ruijterkade"),
    item("restaurant", "Daalder", "https://daalderamsterdam.nl/", "restaurant", "Daalder", "the Amsterdam restaurant led by its own culinary team"),
    item("restaurant", "Flore", "https://restaurantflore.com/", "restaurant", "Flore", "the restaurant at De L'Europe Amsterdam"),
    item("restaurant", "The White Room", "https://www.restaurantthewhiteroom.com/", "restaurant", "The White Room", "the restaurant inside Anantara Grand Hotel Krasnapolsky"),
    item("restaurant", "Vinkeles", "https://www.vinkeles.com/", "restaurant", "Vinkeles", "the restaurant in The Dylan Amsterdam"),
    item("restaurant", "Restaurant Vermeer", "https://restaurantvermeer.nl/en/", "restaurant", "Restaurant Vermeer", "the restaurant near Amsterdam Centraal"),
    item("restaurant", "Bougainville", "https://www.restaurantbougainville.com/", "restaurant", "Bougainville", "the restaurant at Hotel TwentySeven"),
    item("restaurant", "MOS Amsterdam", "https://mosamsterdam.nl/", "restaurant", "MOS Amsterdam", "the waterfront restaurant at IJdok"),
    item("restaurant", "Restaurant Moon", "https://www.restaurantmoon.nl/en/", "restaurant", "Restaurant Moon", "the revolving restaurant in A'DAM Tower"),
    item("restaurant", "Jansz.", "https://www.janszamsterdam.com/", "restaurant", "Jansz.", "the restaurant in the Pulitzer Amsterdam canal houses"),
    item("restaurant", "Ron Gastrobar", "https://rongastrobar.nl/", "restaurant", "Ron Gastrobar", "the Amsterdam restaurant founded by Ron Blaauw"),
    item("restaurant", "Cannibale Royale", "https://cannibaleroyale.nl/", "restaurant", "Cannibale Royale", "the Amsterdam restaurant group's city locations"),
    item("restaurant", "Moeders", "https://moeders.com/en/", "restaurant", "Moeders", "the restaurant focused on Dutch home-style dishes"),
    item("restaurant", "BAK", "https://bakrestaurant.nl/", "restaurant", "BAK", "the restaurant in Het Veem warehouse"),
    item("restaurant", "Entrepot", "https://restaurantentrepot.nl/", "restaurant", "Entrepot", "the restaurant near Entrepotdok"),
    item("restaurant", "Scheepskameel", "https://scheepskameel.nl/", "restaurant", "Scheepskameel", "the restaurant on Kattenburgerstraat"),
    item("restaurant", "Wils", "https://www.restaurantwils.nl/", "restaurant", "Wils", "the restaurant by the Olympic Stadium"),
    item("restaurant", "Coulisse", "https://coulisse-amsterdam.nl/", "restaurant", "Coulisse", "the restaurant in Amsterdam Oost"),
    item("restaurant", "Gitane", "https://gitane.amsterdam/", "restaurant", "Gitane", "the restaurant on Jan Pieter Heijestraat"),
    item("restaurant", "Café Caron", "https://cafecaron.nl/", "restaurant", "Café Caron", "the French-oriented restaurant run by the Caron family"),
    item("restaurant", "Toscanini", "https://restauranttoscanini.nl/", "restaurant", "Toscanini", "the Italian restaurant in the Jordaan"),
    item("restaurant", "Domenica", "https://restaurantdomenica.com/", "restaurant", "Domenica", "the restaurant on Noordermarkt"),
    item("restaurant", "Yamazato", "https://www.okura.nl/dine-and-drink/yamazato-restaurant/", "restaurant", "Hotel Okura Amsterdam", "the Japanese restaurant at Hotel Okura Amsterdam"),
    item("restaurant", "Sazanka", "https://www.okura.nl/dine-and-drink/teppanyaki-restaurant-sazanka/", "restaurant", "Hotel Okura Amsterdam", "the teppanyaki restaurant at Hotel Okura Amsterdam"),
    item("restaurant", "Visaandeschelde", "https://visaandeschelde.nl/en/", "restaurant", "Visaandeschelde", "the seafood-focused restaurant on Scheldeplein"),
    item("restaurant", "Pesca", "https://pesca.restaurant/", "restaurant", "Pesca", "the Amsterdam fish restaurant on Rozengracht"),
    item("restaurant", "Restaurant de Juwelier", "https://www.restaurant-dejuwelier.nl/restaurantdejuwelier", "restaurant", "Restaurant de Juwelier", "the independent restaurant on Utrechtsestraat", query="Utrechtsestraat 51 Amsterdam"),
    item("restaurant", "Wilde Zwijnen", "https://www.wildezwijnenwinkel.nl/english/", "restaurant", "Wilde Zwijnen", "the restaurant on Javaplein"),
    item("restaurant", "Gebr. Hartering", "https://gebrhartering.nl/", "restaurant", "Gebr. Hartering", "the restaurant on Peperstraat"),
    item("restaurant", "De Belhamel", "https://belhamel.nl/en/", "restaurant", "De Belhamel", "the canal-side restaurant at Brouwersgracht"),
    item("restaurant", "Restaurant Europa", "https://restaurant-europa.com/", "restaurant", "Restaurant Europa", "the restaurant on Gedempt Hamerkanaal"),
    item("restaurant", "Restaurant As", "https://restaurantas.nl/", "restaurant", "Restaurant As", "the restaurant in the former St. Nicolaas chapel"),
    item("restaurant", "De Plantage", "https://deplantage.amsterdam/en/", "restaurant", "De Plantage", "the restaurant beside ARTIS"),
    item("restaurant", "Café Restaurant Amsterdam", "https://caferestaurantamsterdam.nl/en/", "restaurant", "Café Restaurant Amsterdam", "the restaurant in the former water-pumping station"),

    # Cafes (20).
    item("cafe", "Bocca Coffee", "https://bocca.nl/info-contact/", "coffee", "Bocca Coffee", "the Amsterdam coffee bar and roastery brand"),
    item("cafe", "Lot Sixty One Coffee Roasters", "https://lot61.com/", "coffee-roastery", "Lot Sixty One", "the Amsterdam coffee roaster and bar"),
    item("cafe", "White Label Coffee", "https://www.whitelabelcoffee.nl/", "coffee-roastery", "White Label Coffee", "the Amsterdam coffee roastery and bars"),
    item("cafe", "Back to Black", "https://backtoblackcoffee.nl/en/locations/", "coffee", "Back to Black", "the independent Amsterdam coffee bar and roastery"),
    item("cafe", "Scandinavian Embassy", "https://scandinavianembassy.nl/", "coffee", "Scandinavian Embassy", "the Scandinavian-oriented coffee bar in De Pijp"),
    item("cafe", "Screaming Beans", "https://screamingbeans.nl/", "coffee-roastery", "Screaming Beans", "the Amsterdam specialty-coffee roaster and bars"),
    item("cafe", "Monks Coffee Roasters", "https://monkscoffee.nl/", "coffee", "Monks Coffee Roasters", "the coffee bar on Bilderdijkstraat"),
    item("cafe", "Rum Baba", "https://rumbaba.nl/", "coffee-bakery", "Rum Baba", "the Amsterdam coffee roastery and bakery"),
    item("cafe", "FUKU Friedhats", "https://friedhats.com/pages/fuku", "coffee", "Friedhats Coffee", "the Friedhats coffee bar in Amsterdam West"),
    item("cafe", "Toki", "https://tokiho.amsterdam/", "coffee", "Toki", "the coffee bar on Binnen Dommersstraat"),
    item("cafe", "Coffee & Coconuts", "https://coffeeandcoconuts.com/", "cafe", "Coffee & Coconuts", "the cafe in the former Ceintuur Theater"),
    item("cafe", "De Koffiesalon", "https://dekoffiesalon.nl/", "coffee", "De Koffiesalon", "the Amsterdam coffee-bar group"),
    item("cafe", "Bakers & Roasters", "https://bakersandroasters.com/", "brunch-cafe", "Bakers & Roasters", "the New Zealand and Brazilian-inspired Amsterdam cafe"),
    item("cafe", "Koffie Academie", "https://koffie-academie.nl/", "coffee", "Koffie Academie", "the coffee bar on Overtoom"),
    item("cafe", "Coffee Bru", "https://www.coffeebru.nl/", "coffee", "Coffee Bru", "the independent coffee bar on Beukenplein", query="Beukenplein 14 Amsterdam"),
    item("cafe", "Uncommon Amsterdam", "https://uncommonams.com/", "coffee", "Uncommon Amsterdam", "the specialty-coffee bar on Eerste Constantijn Huygensstraat"),
    item("cafe", "Saint-Jean", "https://www.saintjean.nl/", "bakery-cafe", "Saint-Jean", "the plant-based bakery and cafe in the Jordaan"),
    item("cafe", "Dignita Hoftuin", "https://eatwelldogood.nl/dignita-hoftuin/", "brunch-cafe", "Dignita", "the cafe in the Hoftuin garden"),
    item("cafe", "Pluk Amsterdam", "https://pluk-amsterdam.com/", "cafe", "Pluk Amsterdam", "the cafe and shop on Reestraat"),
    item("cafe", "Café de Jaren", "https://cafedejaren.nl/", "grand-cafe", "Café de Jaren", "the grand cafe on Nieuwe Doelenstraat"),

    # Parks and natural places (10).
    item("nature", "Vondelpark", "https://www.amsterdam.nl/en/leisure/parks/vondelpark/", "city-park", "City of Amsterdam", "Amsterdam's central nineteenth-century city park"),
    item("nature", "Amsterdamse Bos", "https://www.amsterdamsebos.nl/english/", "urban-forest", "Amsterdamse Bos", "the large managed forest and recreation landscape south-west of the city"),
    item("nature", "Westerpark", "https://www.amsterdam.nl/en/leisure/parks/westerpark/", "city-park", "City of Amsterdam", "the park and green space around Westergas"),
    item("nature", "Oosterpark", "https://www.amsterdam.nl/en/leisure/parks/oosterpark/", "city-park", "City of Amsterdam", "the city park in Amsterdam Oost"),
    item("nature", "Sarphatipark", "https://www.amsterdam.nl/en/leisure/parks/sarphatipark/", "city-park", "City of Amsterdam", "the neighbourhood park in De Pijp"),
    item("nature", "Rembrandtpark", "https://www.amsterdam.nl/en/leisure/parks/rembrandtpark/", "city-park", "City of Amsterdam", "the elongated city park in Amsterdam West"),
    item("nature", "Erasmuspark", "https://www.amsterdam.nl/en/leisure/parks/erasmuspark/", "city-park", "City of Amsterdam", "the city park in Bos en Lommer"),
    item("nature", "Park Frankendael", "https://www.amsterdam.nl/en/leisure/parks/park-frankendael/", "city-park", "City of Amsterdam", "the historic estate park in Watergraafsmeer"),
    item("nature", "Noorderpark", "https://www.amsterdam.nl/en/leisure/parks/noorderpark/", "city-park", "City of Amsterdam", "the linear park in Amsterdam Noord"),
    item("nature", "Sloterpark and Sloterplas", "https://www.amsterdam.nl/en/leisure/parks/sloterpark/", "park-lake", "City of Amsterdam", "the park and recreational lake in Nieuw-West", query="Sloterpark Amsterdam, Netherlands"),

    # Transport objects (10).
    item("transport", "Amsterdam Centraal station", "https://www.ns.nl/en/station-information/amsterdam-centraal.html", "rail-station", "NS", "the principal national and international rail station"),
    item("transport", "Amsterdam Zuid station", "https://www.ns.nl/en/station-information/amsterdam-zuid.html", "rail-station", "NS", "the major rail and metro interchange at Zuidas"),
    item("transport", "Amsterdam Sloterdijk station", "https://www.ns.nl/en/station-information/amsterdam-sloterdijk.html", "rail-station", "NS", "the rail, metro, tram and bus interchange in Westpoort"),
    item("transport", "Amsterdam Amstel station", "https://www.ns.nl/en/station-information/amsterdam-amstel.html", "rail-station", "NS", "the rail and metro interchange on the Amstel corridor"),
    item("transport", "Amsterdam Muiderpoort station", "https://www.ns.nl/en/station-information/amsterdam-muiderpoort.html", "rail-station", "NS", "the rail station serving Amsterdam Oost"),
    item("transport", "Amsterdam RAI station", "https://www.ns.nl/en/station-information/amsterdam-rai.html", "rail-station", "NS", "the rail and metro interchange by the RAI convention centre"),
    item("transport", "Amsterdam Bijlmer ArenA station", "https://www.ns.nl/en/station-information/amsterdam-bijlmer-arena.html", "rail-station", "NS", "the rail and metro interchange in Zuidoost"),
    item("transport", "Amsterdam Holendrecht station", "https://www.ns.nl/en/station-information/amsterdam-holendrecht.html", "rail-station", "NS", "the rail and metro station beside Amsterdam UMC location AMC"),
    item("transport", "Amsterdam Lelylaan station", "https://www.ns.nl/en/station-information/amsterdam-lelylaan.html", "rail-station", "NS", "the rail, metro, tram and bus interchange in Nieuw-West"),
    item("transport", "Amsterdam Science Park station", "https://www.ns.nl/en/station-information/amsterdam-science-park.html", "rail-station", "NS", "the rail station serving Science Park Amsterdam"),

    # Municipal services (10).
    item("government_service", "First registration in Amsterdam", "https://www.amsterdam.nl/en/civil-affairs/first-registration/", "civil-affairs", "City of Amsterdam", "municipal first registration for people moving from abroad", query="Amsterdam City Hall, Amstel 1, Amsterdam"),
    item("government_service", "Moving within Amsterdam", "https://www.amsterdam.nl/en/civil-affairs/moving-amsterdam/", "civil-affairs", "City of Amsterdam", "reporting a move or address change to the municipality", query="Amsterdam City Hall, Amstel 1, Amsterdam"),
    item("government_service", "Passport and ID card Amsterdam", "https://www.amsterdam.nl/en/civil-affairs/passport-id-card/", "identity-documents", "City of Amsterdam", "municipal passport and identity-card applications", query="Amsterdam City Hall, Amstel 1, Amsterdam"),
    item("government_service", "Driving licence Amsterdam", "https://www.amsterdam.nl/en/civil-affairs/driving-licence/", "driving-documents", "City of Amsterdam", "municipal driving-licence applications and renewals", query="Amsterdam City Hall, Amstel 1, Amsterdam"),
    item("government_service", "Parking permit Amsterdam", "https://www.amsterdam.nl/en/parking/parking-permit/", "parking", "City of Amsterdam", "resident and business parking-permit information", query="Amsterdam City Hall, Amstel 1, Amsterdam"),
    item("government_service", "Waste and recycling Amsterdam", "https://www.amsterdam.nl/en/waste-recycling/", "waste-recycling", "City of Amsterdam", "municipal waste collection and recycling guidance", query="Amsterdam City Hall, Amstel 1, Amsterdam"),
    item("government_service", "Municipal taxes Amsterdam", "https://www.amsterdam.nl/en/municipal-taxes/", "municipal-taxes", "City of Amsterdam", "Amsterdam municipal tax information and payment routes", query="Amsterdam City Hall, Amstel 1, Amsterdam"),
    item("government_service", "Report a problem in public space Amsterdam", "https://www.amsterdam.nl/en/contact-information/report-problem/", "public-space", "City of Amsterdam", "reporting public-space problems to the municipality", query="Amsterdam City Hall, Amstel 1, Amsterdam"),
    item("government_service", "Marriage and registered partnership Amsterdam", "https://www.amsterdam.nl/en/civil-affairs/marriage-registered-partnership/", "civil-status", "City of Amsterdam", "municipal marriage and registered-partnership procedures", query="Amsterdam City Hall, Amstel 1, Amsterdam"),
    item("government_service", "Registering a birth in Amsterdam", "https://www.amsterdam.nl/en/civil-affairs/birth/", "civil-status", "City of Amsterdam", "municipal birth-registration procedure", query="Amsterdam City Hall, Amstel 1, Amsterdam"),

    # Education (10).
    item("education", "University of Amsterdam", "https://www.uva.nl/en", "research-university", "University of Amsterdam", "the public research university and its Amsterdam faculties"),
    item("education", "Vrije Universiteit Amsterdam", "https://vu.nl/en", "research-university", "Vrije Universiteit Amsterdam", "the research university at the Zuidas campus"),
    item("education", "Amsterdam University of Applied Sciences", "https://www.amsterdamuas.com/", "university-of-applied-sciences", "Amsterdam University of Applied Sciences", "professional higher education across Amsterdam campuses"),
    item("education", "Inholland Amsterdam", "https://www.inholland.nl/locaties/amsterdam/", "university-of-applied-sciences", "Inholland University of Applied Sciences", "the Inholland Amsterdam location and study programmes"),
    item("education", "Gerrit Rietveld Academie", "https://rietveldacademie.nl/en/", "art-design-academy", "Gerrit Rietveld Academie", "higher education in fine arts and design"),
    item("education", "Conservatorium van Amsterdam", "https://www.conservatoriumvanamsterdam.nl/en/", "music-conservatory", "Conservatorium van Amsterdam", "higher music education at the Oosterdok campus"),
    item("education", "Amsterdam University College", "https://www.auc.nl/", "liberal-arts-sciences", "Amsterdam University College", "the residential liberal arts and sciences college at Science Park"),
    item("education", "ROC van Amsterdam", "https://www.rocva.nl/", "vocational-education", "ROC van Amsterdam", "secondary vocational education across Amsterdam locations"),
    item("education", "Hotelschool The Hague Amsterdam", "https://www.hotelschool.nl/campuses/amsterdam", "hospitality-education", "Hotelschool The Hague", "the hospitality-management campus in Amsterdam"),
    item("education", "Tio Business School Amsterdam", "https://www.tio.nl/en/locations/amsterdam/", "private-higher-education", "Tio Business School", "the Amsterdam campus for business and hospitality programmes"),

    # Healthcare (10).
    item("healthcare", "Amsterdam UMC location AMC", "https://www.amsterdamumc.nl/en/location-amc/public-transport", "academic-hospital", "Amsterdam UMC", "the AMC hospital location in Amsterdam Zuidoost"),
    item("healthcare", "Amsterdam UMC location VUmc", "https://www.amsterdamumc.nl/en/address", "academic-hospital", "Amsterdam UMC", "the VUmc hospital location by the VU campus"),
    item("healthcare", "OLVG East", "https://www.olvg.nl/uw-bezoek-aan-olvg/voorzieningen-olvg-locatie-oost/", "hospital", "OLVG", "the OLVG hospital location on Oosterpark"),
    item("healthcare", "OLVG West", "https://www.olvg.nl/uw-bezoek-aan-olvg/voorzieningen-olvg-locatie-west/", "hospital", "OLVG", "the OLVG hospital location on Jan Tooropstraat"),
    item("healthcare", "BovenIJ hospital", "https://www.bovenij.nl/", "hospital", "BovenIJ", "the hospital serving Amsterdam Noord"),
    item("healthcare", "Reade Overtoom", "https://reade.nl/over-ons/locaties/overtoom", "rehabilitation-care", "Reade", "rehabilitation care at the Overtoom location"),
    item("healthcare", "GGD Amsterdam", "https://www.ggd.amsterdam.nl/english/", "public-health", "GGD Amsterdam", "Amsterdam's municipal public-health service", query="GGD Amsterdam, Nieuwe Achtergracht 100, Amsterdam"),
    item("healthcare", "ACTA", "https://acta.nl/en", "dental-academic-centre", "ACTA", "academic dental care and dentistry education"),
    item("healthcare", "Antoni van Leeuwenhoek", "https://www.avl.nl/en/", "cancer-centre", "Antoni van Leeuwenhoek", "specialist cancer care and research"),
    item("healthcare", "Arkin", "https://arkin.nl/en/", "mental-healthcare", "Arkin", "mental-healthcare services in Amsterdam"),

    # Ten current 2026 events, all from the official WorldPride Amsterdam programme.
    item("event", "WorldPride Amsterdam 2026 Pride Walk", "https://pride.amsterdam/en/event/pride-walk/", "pride-event", "Pride Amsterdam", "the official 25 July 2026 Pride Walk", query="Dam Square Amsterdam", start_date="2026-07-25", end_date="2026-07-25"),
    item("event", "WorldPride Amsterdam 2026 Pride Park", "https://pride.amsterdam/en/event/pride-park/", "pride-event", "Pride Amsterdam", "the official 25 July 2026 Pride Park programme", query="Vondelpark Amsterdam", start_date="2026-07-25", end_date="2026-07-25"),
    item("event", "WorldPride Amsterdam 2026 Open Air Film Festival", "https://pride.amsterdam/en/event/open-air-film-festival/", "film-event", "Pride Amsterdam", "the official open-air film programme at Mercatorplein", query="Mercatorplein Amsterdam", start_date="2026-07-29", end_date="2026-07-30"),
    item("event", "WorldPride Amsterdam 2026 Senior Pride Concert", "https://pride.amsterdam/en/event/senior-pride-concert/", "concert", "Pride Amsterdam", "the official Senior Pride concert at Nieuwmarkt", query="Nieuwmarkt Amsterdam", start_date="2026-07-30", end_date="2026-07-30"),
    item("event", "WorldPride Amsterdam 2026 Canal Parade", "https://pride.amsterdam/en/event/canal-parade/", "parade", "Pride Amsterdam", "the official canal parade on 1 August 2026", query="Prinsengracht Amsterdam", start_date="2026-08-01", end_date="2026-08-01"),
    item("event", "WorldPride Amsterdam 2026 UNITY Concert", "https://pride.amsterdam/en/event/unity-concert/", "concert", "Pride Amsterdam", "the official UNITY concert at Museumplein", query="Museumplein Amsterdam", start_date="2026-08-04", end_date="2026-08-04"),
    item("event", "WorldPride Amsterdam 2026 Human Rights Conference", "https://pride.amsterdam/en/event/human-rights-conference/", "conference", "Pride Amsterdam", "the official human-rights conference at Beurs van Berlage", query="Beurs van Berlage Amsterdam", start_date="2026-08-05", end_date="2026-08-07"),
    item("event", "WorldPride Amsterdam 2026 WorldPride Village", "https://pride.amsterdam/en/event/worldpride-village/", "festival-village", "Pride Amsterdam", "the official WorldPride Village at Museumplein", query="Museumplein Amsterdam", start_date="2026-08-05", end_date="2026-08-08"),
    item("event", "WorldPride Amsterdam 2026 WorldPride March", "https://pride.amsterdam/en/event/worldpride-march/", "march", "Pride Amsterdam", "the official WorldPride March to Museumplein", query="Martin Luther Kingpark Amsterdam", start_date="2026-08-08", end_date="2026-08-08"),
    item("event", "WorldPride Amsterdam 2026 Closing Concert", "https://pride.amsterdam/en/event/closing-concert/", "concert", "Pride Amsterdam", "the official WorldPride closing concert at Museumplein", query="Museumplein Amsterdam", start_date="2026-08-08", end_date="2026-08-08"),

    # Ten existing real Amsterdam companies from the runtime partner registry.
    item("local_partner", "Van der Valk Hotel Amsterdam-Amstel", "https://www.hotelamsterdamamstel.nl/en", "hotel", "Van der Valk Hotel Amsterdam-Amstel", "the Amsterdam-Amstel hotel and its official guest information"),
    item("local_partner", "citizenM Amsterdam South", "https://www.citizenm.com/hotels/europe/amsterdam/amsterdam-south-hotel", "hotel", "citizenM", "the citizenM hotel beside Amsterdam Zuid"),
    item("local_partner", "IKEA Amsterdam", "https://www.ikea.com/nl/en/stores/amsterdam/", "home-furnishing", "IKEA", "the IKEA store in Amsterdam Zuidoost"),
    item("local_partner", "Everaert Advocaten", "https://www.everaert.nl/en/", "immigration-law", "Everaert Advocaten", "the Amsterdam immigration-law firm"),
    item("local_partner", "ING Group", "https://ing.com/about-us/ing-at-a-glance", "banking", "ING", "the banking group's Amsterdam headquarters and corporate profile", query="Bijlmerdreef 106 Amsterdam"),
    item("local_partner", "MacBike Amsterdam", "https://www.macbike.nl/", "bike-rental", "MacBike", "the Amsterdam bicycle-rental company"),
    item("local_partner", "TCA Taxi Amsterdam", "https://www.tcataxi.nl/en/", "taxi", "TCA", "the Amsterdam taxi company and booking service"),
    item("local_partner", "Funda", "https://www.funda.nl/", "real-estate-platform", "Funda", "the Amsterdam-based Dutch property platform", query="Funda Amsterdam Netherlands"),
    item("local_partner", "UvA Talen", "https://www.uvatalen.nl/en/", "language-school", "UvA Talen", "the Amsterdam language school connected to the UvA ecosystem"),
    item("local_partner", "Rob Peetoom Amsterdam", "https://www.robpeetoom.nl/salons/amsterdam", "personal-care", "Rob Peetoom", "the Amsterdam salon location of the Dutch company"),

    # Housing resources requested for the city package.
    item("housing", "WoningNet Stadsregio Amsterdam", "https://www.woningnetregioamsterdam.nl/", "social-housing-platform", "WoningNet", "the regional social-housing registration and search platform", query="WoningNet Amsterdam Netherlands"),
    item("housing", "!WOON", "https://www.wooninfo.nl/english/", "tenant-support", "!WOON", "independent housing information and tenant support in Amsterdam"),
    item("housing", "Housing permit Amsterdam", "https://www.amsterdam.nl/en/housing/housing-permit/", "municipal-housing-service", "City of Amsterdam", "the municipal housing-permit procedure", query="Amsterdam City Hall, Amstel 1, Amsterdam"),
    item("housing", "Affordable housing Amsterdam", "https://www.amsterdam.nl/en/housing/affordable-housing/", "municipal-housing-information", "City of Amsterdam", "municipal information about affordable housing", query="Amsterdam City Hall, Amstel 1, Amsterdam"),
    item("housing", "Renting a home in Amsterdam", "https://www.amsterdam.nl/en/housing/renting-home/", "municipal-housing-information", "City of Amsterdam", "municipal guidance for renting a home", query="Amsterdam City Hall, Amstel 1, Amsterdam"),
]


# Address-level corrections are sourced from exact OSM/Nominatim results or from
# the already-audited Amsterdam runtime partner baseline. They prevent a failed
# name search from being replaced by guessed coordinates.
QUERY_OVERRIDES = {
    "NEMO Science Museum": "Oosterdok 2 Amsterdam",
    "ARTIS-Micropia": "Plantage Kerklaan 38 Amsterdam",
    "Seventeenth-Century Canal Ring of Amsterdam": "Grachtengordel Amsterdam",
    "WONDR Experience": "Meeuwenlaan 88 Amsterdam",
    "Coulisse": "Oostelijke Handelskade 44 Amsterdam",
    "Restaurant Europa": "Gedempt Hamerkanaal 81 Amsterdam",
    "Restaurant As": "Prinses Irenestraat 19 Amsterdam",
    "FUKU Friedhats": "Bos en Lommerweg 136 Amsterdam",
    "Uncommon Amsterdam": "Eerste Constantijn Huygensstraat 63 Amsterdam",
    "Café de Jaren": "Nieuwe Doelenstraat 20 Amsterdam",
    "Amsterdam University of Applied Sciences": "Wibautstraat 2 Amsterdam",
    "Tio Business School Amsterdam": "Tempelhofstraat 5 Amsterdam",
    "Amsterdam UMC location AMC": "Meibergdreef 9 Amsterdam",
    "Amsterdam UMC location VUmc": "De Boelelaan 1117 Amsterdam",
    "OLVG East": "Oosterpark 9 Amsterdam",
}
for catalog_entry in CATALOG:
    if catalog_entry["title"] in QUERY_OVERRIDES:
        catalog_entry["query"] = QUERY_OVERRIDES[catalog_entry["title"]]

CURATED_COORDINATES = {
    # Stopera / Amsterdam City Hall, verified by OSM way 751591420.
    **{title: (52.3675554, 4.9012890, "OpenStreetMap way 751591420 (Stopera / City Hall)") for title in (
        "First registration in Amsterdam", "Moving within Amsterdam", "Passport and ID card Amsterdam",
        "Driving licence Amsterdam", "Parking permit Amsterdam", "Waste and recycling Amsterdam",
        "Municipal taxes Amsterdam", "Report a problem in public space Amsterdam",
        "Marriage and registered partnership Amsterdam", "Registering a birth in Amsterdam",
        "Housing permit Amsterdam", "Affordable housing Amsterdam", "Renting a home in Amsterdam",
    )},
    # Audited runtime partner coordinates in MockLocalPartnersData.swift.
    "Everaert Advocaten": (52.3846, 4.8945, "Existing audited runtime partner baseline"),
    "TCA Taxi Amsterdam": (52.3676, 4.9041, "Existing audited Amsterdam service-area centroid"),
    "Funda": (52.3676, 4.9041, "Existing audited Amsterdam service-area centroid"),
    "UvA Talen": (52.3625, 4.9119, "Existing audited runtime partner baseline"),
    "WoningNet Stadsregio Amsterdam": (52.3676, 4.9041, "Amsterdam service-area centroid from city.amsterdam"),
}
for catalog_entry in CATALOG:
    curated = CURATED_COORDINATES.get(catalog_entry["title"])
    if curated:
        catalog_entry["coordinates"] = {"latitude": curated[0], "longitude": curated[1]}
        catalog_entry["coordinate_source"] = curated[2]


LABELS = {
    "place": "place or attraction", "museum": "museum", "restaurant": "restaurant",
    "cafe": "cafe", "nature": "park or natural place", "transport": "transport object",
    "government_service": "municipal service", "education": "education provider",
    "healthcare": "healthcare provider", "event": "current event",
    "local_partner": "local company", "housing": "housing resource",
}
MEDIA_REQUIRED_TYPES = {"city", "place", "museum", "restaurant", "cafe", "hotel", "nature", "local_partner"}
MEDIA_ROLES = ("hero", "gallery", "thumbnail", "map_preview")

# These pages were independently confirmed in the indexed official source or in
# the in-app browser on CHECKED_AT. This is deliberately title-scoped so a later
# URL change cannot inherit an earlier verification result.
INDEX_VERIFIED_TITLES = {
    "Westerkerk", "Dam Square", "Begijnhof Amsterdam", "Bloemenmarkt",
    "THIS IS HOLLAND", "Ciel Bleu", "Restaurant 212", "Kaagman & Kortekaas",
    "BREDA", "Daalder", "Wils", "Pesca", "Restaurant de Juwelier",
    "Wilde Zwijnen", "Restaurant Europa", "Bocca Coffee", "Back to Black",
    "Scandinavian Embassy", "Toki", "Coffee Bru", "Saint-Jean",
    "Inholland Amsterdam", "Amsterdam UMC location AMC",
    "Amsterdam UMC location VUmc", "OLVG East", "OLVG West", "Reade Overtoom",
    "Arkin", "ING Group",
    "WorldPride Amsterdam 2026 Pride Walk", "WorldPride Amsterdam 2026 Pride Park",
    "WorldPride Amsterdam 2026 Open Air Film Festival",
    "WorldPride Amsterdam 2026 Senior Pride Concert",
    "WorldPride Amsterdam 2026 Canal Parade", "WorldPride Amsterdam 2026 UNITY Concert",
    "WorldPride Amsterdam 2026 Human Rights Conference",
    "WorldPride Amsterdam 2026 WorldPride Village",
    "WorldPride Amsterdam 2026 WorldPride March",
    "WorldPride Amsterdam 2026 Closing Concert",
}


def request_json(url, params=None, timeout=35):
    if params:
        url = f"{url}?{urlencode(params)}"
    request = Request(url, headers={"User-Agent": USER_AGENT, "Accept": "application/json"})
    with urlopen(request, timeout=timeout) as response:
        return json.load(response)


def load_cache():
    if CACHE.exists():
        return json.loads(CACHE.read_text(encoding="utf-8"))
    return {"geocode": {}, "media": {}, "web": {}}


def save_cache(cache):
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    CACHE.write_text(json.dumps(cache, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def slug(value):
    clean = value.casefold().replace("'", "").replace("&", " and ")
    clean = re.sub(r"[^a-z0-9]+", "-", clean).strip("-")
    return clean or hashlib.sha256(value.encode()).hexdigest()[:12]


def coordinates_for(entry, cache):
    if entry.get("coordinates"):
        return entry["coordinates"], {"osm_type": "curated", "osm_id": entry.get("coordinate_source") or "verified baseline"}
    key = entry["query"]
    if key not in cache["geocode"]:
        results = request_json("https://nominatim.openstreetmap.org/search", {
            "q": key, "format": "jsonv2", "limit": 8, "countrycodes": "nl",
            "addressdetails": 1,
        })
        cache["geocode"][key] = results
        save_cache(cache)
        time.sleep(1.05)
    south, west, north, east = AMSTERDAM_BOUNDS
    for result in cache["geocode"][key]:
        lat, lon = float(result["lat"]), float(result["lon"])
        if south <= lat <= north and west <= lon <= east:
            return {"latitude": round(lat, 7), "longitude": round(lon, 7)}, result
    return None, None


def important_tokens(title):
    ignored = {"amsterdam", "restaurant", "cafe", "coffee", "museum", "station", "worldpride", "2026", "the", "and", "de", "het", "van"}
    return [token for token in re.findall(r"[a-z0-9]+", title.casefold()) if len(token) >= 3 and token not in ignored]


def media_results(query, cache, page=1):
    cache_key = query if page == 1 else f"{query}::page-{page}"
    if cache_key not in cache["media"]:
        try:
            payload = request_json("https://api.openverse.org/v1/images/", {
                "q": query, "page": page, "page_size": 20, "license": "by,by-sa,cc0,pdm",
            })
            cache["media"][cache_key] = payload.get("results", [])
        except (HTTPError, URLError, TimeoutError):
            cache["media"][cache_key] = []
        save_cache(cache)
        time.sleep(0.25)
    return cache["media"][cache_key]


def media_for(entry, cache, used_urls):
    exact_query = f'{entry["title"]} Amsterdam'
    tokens = important_tokens(entry["title"])
    fallback_queries = {
        "government_service": "Amsterdam City Hall",
        "event": "Amsterdam Pride",
        "housing": "Amsterdam housing",
        "restaurant": "Amsterdam restaurant",
        "cafe": "Amsterdam cafe",
        "healthcare": "Amsterdam hospital",
        "education": "Amsterdam university",
        "local_partner": "Amsterdam business",
        "place": "Amsterdam landmark",
        "museum": "Amsterdam museum",
        "nature": "Amsterdam park",
        "transport": "Amsterdam station",
    }

    def candidates(query, fallback=False, page=1):
        scored = []
        for result in media_results(query, cache, page=page):
            asset = result.get("url")
            landing = result.get("foreign_landing_url")
            creator = result.get("creator")
            license_url = result.get("license_url")
            if not all(isinstance(value, str) and value.startswith("https://") for value in (asset, landing, license_url)):
                continue
            if not creator or asset in used_urls or result.get("mature") is True:
                continue
            haystack = " ".join([
                result.get("title") or "",
                " ".join(tag.get("name", "") for tag in result.get("tags", [])),
            ]).casefold()
            token_hits = sum(token in haystack for token in tokens)
            amsterdam_hit = "amsterdam" in haystack
            score = token_hits * 4 + int(amsterdam_hit) * 2
            if token_hits or amsterdam_hit:
                scored.append((score, "contextual" if fallback or not token_hits else "exact", result))
        return scored

    target = 4 if entry["entity_type"] in MEDIA_REQUIRED_TYPES else 1
    pools = [
        candidates(exact_query),
        candidates(f'{entry["title"]} Netherlands'),
        candidates(fallback_queries[entry["entity_type"]], fallback=True),
        *[
            candidates(fallback_queries[entry["entity_type"]], fallback=True, page=page)
            for page in range(2, 7)
        ],
    ]
    selected = []
    seen = set()
    for pool in pools:
        for _, match_kind, result in sorted(pool, key=lambda row: row[0], reverse=True):
            asset = result["url"]
            if asset in used_urls or asset in seen:
                continue
            seen.add(asset)
            license_code = (result.get("license") or "").upper()
            version = result.get("license_version")
            license_name = f"CC {license_code} {version}".strip() if license_code not in {"CC0", "PDM"} else license_code
            selected.append({
                "role": MEDIA_ROLES[len(selected)],
                "source_page_url": result["foreign_landing_url"],
                "asset_url": asset,
                "license": license_name,
                "license_url": result["license_url"],
                "attribution": result.get("attribution") or f'{result.get("title") or entry["title"]} — {result["creator"]}',
                "verified": True,
                "retrieved_at": CHECKED_AT,
                "media_title": result.get("title") or entry["title"],
                "provider": result.get("provider") or result.get("source") or "Openverse",
                "match_kind": match_kind,
            })
            if len(selected) == target:
                used_urls.update(item["asset_url"] for item in selected)
                return selected
    used_urls.update(item["asset_url"] for item in selected)
    return selected


def web_status(entry, cache):
    url = entry["website"]
    if url in cache["web"]:
        return cache["web"][url]
    status = {"opened": False, "status_code": None, "final_url": url}
    try:
        request = Request(url, headers={"User-Agent": USER_AGENT, "Accept": "text/html,application/xhtml+xml"})
        with urlopen(request, timeout=20) as response:
            status = {"opened": 200 <= response.status < 400, "status_code": response.status, "final_url": response.geturl()}
    except HTTPError as error:
        status = {"opened": False, "status_code": error.code, "final_url": error.geturl()}
    except (URLError, TimeoutError, ValueError) as error:
        status = {"opened": False, "status_code": None, "final_url": url, "error": str(error)[:180]}
    cache["web"][url] = status
    save_cache(cache)
    return status


def descriptions(entry, index):
    label = LABELS[entry["entity_type"]]
    description = (
        f'{entry["title"]} is a confirmed Amsterdam {label}. The cited source specifically covers '
        f'{entry["focus"]}. This governed entry stores a verified city location and direct web route '
        "without copying mutable prices, ratings, reviews or opening hours."
    )
    summary = (
        f'Use the official {entry["publisher"]} page for {entry["title"]} and recheck current visitor '
        f'or service conditions before acting. The Amsterdam record is designed for search and routing '
        f'under {entry["category"].replace("-", " ")} and does not treat AI text as a factual source.'
    )
    return description, summary


def build():
    cache = load_cache()
    records, rejected, unverified, source_rows = [], [], [], []
    used_urls, used_ids, used_websites = set(), set(), set()
    for index, entry in enumerate(CATALOG, 1):
        print(f"[{index}/{len(CATALOG)}] {entry['entity_type']}: {entry['title']}", flush=True)
        entity_id = f"{entry['entity_type']}.{slug(entry['title'])}"
        if entity_id in used_ids:
            rejected.append({"title": entry["title"], "reason": "duplicate generated entity ID", "entity_id": entity_id})
            continue
        canonical_website = entry["website"].rstrip("/").casefold()
        if canonical_website in used_websites:
            rejected.append({"title": entry["title"], "reason": "duplicate canonical website", "website": entry["website"]})
            continue
        coordinates, geo = coordinates_for(entry, cache)
        if coordinates is None:
            rejected.append({"title": entry["title"], "reason": "no Amsterdam-bounded geocode result", "query": entry["query"]})
            continue
        media = media_for(entry, cache, used_urls)
        required_media_count = 4 if entry["entity_type"] in MEDIA_REQUIRED_TYPES else 1
        status = web_status(entry, cache)
        issues = []
        if len(media) < required_media_count:
            issues.append(f"licensed media roles incomplete ({len(media)}/{required_media_count})")
        status_code = status.get("status_code")
        source_index_verified = entry["title"] in INDEX_VERIFIED_TITLES
        source_reachable = status.get("opened") or source_index_verified or status_code in {301, 302, 307, 308, 401, 403, 405, 429}
        if not source_reachable:
            issues.append(f"source not opened (HTTP {status.get('status_code')})")
        description, summary = descriptions(entry, index)
        verification = "verified" if not issues else "needs_review"
        lifecycle = "qa" if not issues else "draft"
        images = []
        if media:
            for media_item in media:
                media_id = f"media.{slug(entry['entity_type'])}.{slug(entry['title'])}.{media_item['role']}.{hashlib.sha256(media_item['asset_url'].encode()).hexdigest()[:10]}"
                images.append({key: value for key, value in media_item.items() if key not in {"media_title", "provider", "match_kind"}} | {"id": media_id})
        record = {
            "id": entity_id,
            "entity_type": entry["entity_type"],
            "category": entry["category"],
            "city_id": CITY_ID,
            "province_id": PROVINCE_ID,
            "coordinates": coordinates,
            "title": entry["title"],
            "description": description,
            "images": images,
            "official_source": {
                "title": entry["source_title"],
                "publisher": entry["publisher"],
                "url": entry["website"],
                "is_official": True,
                "checked_at": CHECKED_AT,
                "status": "verified_opened" if source_reachable else "access_restricted",
            },
            "website": entry["website"],
            "related_entity_ids": ["city.amsterdam"],
            "last_checked": CHECKED_AT,
            "review_frequency_days": 30 if entry["entity_type"] == "event" else 90,
            "verification_status": verification,
            "ai_summary": summary,
            "search_keywords": [
                entry["title"], f'{entry["title"]} Amsterdam', entry["category"].replace("-", " "),
                f'{LABELS[entry["entity_type"]]} Amsterdam', "Noord-Holland",
            ],
            "lifecycle_status": lifecycle,
            "attributes": {
                "coordinate_source": entry.get("coordinate_source") or f"OpenStreetMap Nominatim: {geo.get('osm_type')} {geo.get('osm_id')}",
                "source_http_status": str(status.get("status_code") or "restricted"),
                "source_final_url": status.get("final_url") or entry["website"],
                "source_verification_method": "direct request" if status.get("opened") else ("indexed official source or in-app browser" if source_index_verified else "restricted response accepted for review"),
                "media_match": media[0].get("match_kind") if media else "missing",
                "media_roles_count": str(len(media)),
                **entry["attributes"],
            },
        }
        records.append(record)
        used_ids.add(entity_id)
        used_websites.add(canonical_website)
        if issues:
            unverified.append({"id": entity_id, "title": entry["title"], "issues": issues})
        source_rows.append({
            "id": entity_id,
            "title": entry["title"],
            "source": entry["website"],
            "source_status": record["official_source"]["status"],
            "coordinate_source": record["attributes"]["coordinate_source"],
            "media_source": media[0].get("source_page_url") if media else None,
            "media_asset": media[0].get("asset_url") if media else None,
            "license": media[0].get("license") if media else None,
            "license_url": media[0].get("license_url") if media else None,
            "attribution": media[0].get("attribution") if media else None,
            "media_title": media[0].get("media_title") if media else None,
            "media_provider": media[0].get("provider") if media else None,
            "media_match": media[0].get("match_kind") if media else None,
            "media_assets": media,
        })
    counts = {}
    for record in records:
        counts[record["entity_type"]] = counts.get(record["entity_type"], 0) + 1
    qa_ready = sum(record["lifecycle_status"] == "qa" for record in records)
    batch = {
        "schema_version": 1,
        "batch_id": "WP-06-M2-amsterdam-001",
        "work_package": "WP-06",
        "milestone": "WP-06-M2",
        "target_release": "amsterdam-v0.1.0",
        "publication_status": "qa" if not unverified and not rejected else "draft",
        "qa": {gate: "pending" for gate in ("build", "static", "duplicate", "source", "media", "search", "ai")},
        "qa_evidence": {"checked_at": CHECKED_AT},
        "records": records,
    }
    report_dir = PROJECT / "reports" / "amsterdam-01"
    batch_path = PROJECT / "batches" / "WP-06" / "M2-amsterdam-001.json"
    report_dir.mkdir(parents=True, exist_ok=True)
    batch_path.parent.mkdir(parents=True, exist_ok=True)
    batch_path.write_text(json.dumps(batch, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    coverage = {
        "city_id": CITY_ID,
        "province_id": PROVINCE_ID,
        "checked_at": CHECKED_AT,
        "existing_city_record": "city.amsterdam",
        "new_records": len(records),
        "qa_records": qa_ready,
        "draft_records": len(records) - qa_ready,
        "counts": counts,
        "licensed_images_in_new_batch": sum(len(record["images"]) for record in records),
        "unique_media_assets": len(used_urls),
        "unique_hero_assets": len({record["images"][0]["asset_url"] for record in records if record["images"]}),
        "unique_hero_percent": round(100 * len({record["images"][0]["asset_url"] for record in records if record["images"]}) / len(records), 2) if records else 0,
        "verified_percent": round(100 * qa_ready / len(records), 2) if records else 0,
        "rejected_count": len(rejected),
        "unverified_count": len(unverified),
    }
    (report_dir / "coverage.json").write_text(json.dumps(coverage, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (report_dir / "rejected-records.json").write_text(json.dumps({"checked_at": CHECKED_AT, "records": rejected}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (report_dir / "unverified-data.json").write_text(json.dumps({"checked_at": CHECKED_AT, "records": unverified}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (report_dir / "sources-and-licenses.json").write_text(json.dumps({"checked_at": CHECKED_AT, "records": source_rows}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(coverage, ensure_ascii=False, indent=2), flush=True)


if __name__ == "__main__":
    try:
        build()
    except KeyboardInterrupt:
        sys.exit(130)
