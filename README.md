# Nias Heritage (Ondröita Nono Niha)

<a href="https://play.google.com/store/apps/details?id=io.github.sslaia.niasheritage"><img alt="Get it on Google Play" src="https://play.google.com/intl/en_us/badges/images/apps/en-play-badge.png" height="80pt"/></a>
<a href="https://apps.microsoft.com/detail/9n8dpc8pnvhm"><img alt="Get it from Microsoft Store" src="https://get.microsoft.com/images/en-us%20dark.svg" height="80pt"/></a>

**Nias Heritage** (*Ondröita Nono Niha*) is a comprehensive, curated digital museum and knowledge repository dedicated to preserving, documenting, and showcasing the rich cultural heritage, oral literature, customary traditions, language, and living community knowledge of Nias Island (*Tanö Niha*), Indonesia.

---

## 🌟 Main Features

### 🏛️ Cultural Heritage Exhibitions (*Ondröita*)
In-depth cultural exhibition articles curated from verified ethnographic and linguistic research:
- **Architecture (*Omo Niha / Omo Hada*)**: Earth-quake-resistant vernacular wooden architecture, pillar construction (*ehomo*), and roof craft.
- **Megalithic Culture (*Behu ba Daro-Daro*)**: Ancestral stone monuments, obelisks (*behu*), and seated stones (*daro-daro*).
- **Music & Dance (*Fanari ba Fanunö*)**: Traditional ritual dances (*Maena, Hiŵö-hiŵö, Fatele, Moyo*), songs, and stone-jumping (*Fahombo*).
- **Customary Clothing (*Gama-Gama / Baru Oholu*)**: Bark garments, woven vests, gold ceremonial jewelry, and warrior attire.
- **Customary Villages (*Banua Nono Niha*)**: Ancient hilltop village layout, paved courtyards (*eŵali*), and community structures.
- **Origins & Genetics (*Böröta Nono Niha*)**: Austronesian human migration, genetic origins, and mythological genealogy (*Tetehöli Ana'a*).
- **Historical Timeline (*Ofanöŵa Ginötö*)**: 12,000+ years of Nias history from the Tögi Ndrawa cave prehistory to modern times.
- **Interactive Reading Experience**: Floating collapsible Table of Contents (TOC) with section jumping, interactive footnote citations bottom sheets, and responsive typography.

### 📚 Digital Cultural Library (*Pustaka*)
A centralized repository of classical and oral Nias literature:
- **Amaedola (Proverbs & Wisdom)**: Over 740+ classical proverbs (*amaedola*) categorized and translated with Nias definitions (*Eluaha*), Indonesian, and English meanings, featuring instant search and alphabetical letter filtering.
- **Sura Ni'amoni'ö (Nias Holy Bible)**: Complete Nias Bible reader covering all Old and New Testament books with chapter navigation, verse readers, and search.
- **Hoho (Oral Epics & Poetry)**: Ancient ritual poetry, ancestral genealogies, and oral epics recited during festivals.
- **Manö-manö (Folktales & Legends)**: Traditional folklore, moral stories, and cosmological myths of Tanö Niha.

### 🧩 Interactive & Community Modules (*Aya-Aya Dödö & Komunikasi*)
Engaging educational and community-driven learning tools:
- **Nias Crosswords (*Dahö-Dahö Li Niha*)**: Interactive Nias language crossword puzzles with dynamic scoring, timer, hints, and integrated Nias Wiktionary definition lookups.
- **Community Newsletter (*Turia Komunitas*)**: Community news publication reader synced with Nias Wikipedia, complete with hero banner images, expandable floating TOC, and offline fallback.
- **Language Course (*Famahaö Li Niha / Sulu*)**: Guided language learning lessons based on Nias Wiktionary (*Wikikamus:Sulu*), featuring dynamic course titles, illustrative imagery, and offline reading.
- **Media Gallery (*Fondröni Gambara*)**: High-resolution curated cultural photo gallery showcasing traditional houses, megaliths, artifacts, and customary ceremonies with full-screen lightbox zoom.

---

## 🎨 Design & Typography System

- **Editorial Aesthetics**:
  - **Headings & Subheadings**: **Google Fonts Newsreader** (editorial serif providing classic authority and elegance).
  - **Body & UI Elements**: **Google Fonts Plus Jakarta Sans** (modern, clean, and legible across all viewport sizes).
- **Tactile Heritage Palette**:
  - **Dark Mode (Default)**: Inspired by the interior ambiance of an *Omo Hada* (rich charcoal, carved stone grey, and royal gold accents).
  - **Light Mode**: Warm natural stone and parchment tones.
- **Adaptive Layout**: Fully responsive across mobile (Android), tablet, and desktop form factors.

---

## 🌐 Localization & Offline First

- **Trilingual Support**: Full application-wide translation in:
  - **Li Niha** (Nias)
  - **Bahasa Indonesia** (Indonesian)
  - **English**
- **Offline-First Resilience**: Pre-seeded local SQLite database ensures the app is fully functional without internet access. When online, the app seamlessly checks for and syncs updated community content revisions.

---

## 📜 Version History

### Version 1.0.0
- Official release of Nias Heritage (*Ondröita Nono Niha*).
- Complete 7 Heritage Exhibition articles with interactive footnotes and floating Table of Contents.
- Amaedola Library with 740+ proverbs, multi-language explanations, search, and letter indexes.
- Sura Ni'amoni'ö (Nias Bible) reader with Old & New Testament book navigation.
- Hoho and Manö-manö traditional literature archives.
- Four Interactive Community modules:
  - Nias Crosswords (*Dahö-Dahö Li Niha*)
  - Community Newsletter (*Turia Komunitas*)
  - Language Course (*Famahaö Li Niha / Sulu*)
  - Media Gallery (*Fondröni Gambara*)
- Unified typography system featuring Google Fonts Newsreader and Plus Jakarta Sans.
- Offline-first local database caching with live Wikimedia synchronization.
- Dark and Light adaptive themes.

---

## 🛠️ Tech Stack & Modular Architecture

- **Core Framework**: [Flutter](https://flutter.dev) (Dart SDK ^3.13)
- **State Management**: [Flutter Riverpod](https://riverpod.dev)
- **Local Persistence**: [Drift](https://drift.simonbinder.eu) (SQLite) with pre-seeded database
- **Localization**: [easy_localization](https://pub.dev/packages/easy_localization)
- **Routing**: [go_router](https://pub.dev/packages/go_router)
- **Typography**: [google_fonts](https://pub.dev/packages/google_fonts) (Newsreader & Plus Jakarta Sans)
- **Modular Community Modules**:
  - `wiki_crosswords`
  - `wiki_newsletter_reader`
  - `wiki_course_reader`
  - `wiki_media_gallery`
- **Markdown & HTML**: [flutter_markdown](https://pub.dev/packages/flutter_markdown), [html](https://pub.dev/packages/html)

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
