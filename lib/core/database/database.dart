import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'database.g.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    try {
      final decoded = jsonDecode(fromDb);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}

class HeritageItems extends Table {
  TextColumn get id => text()();
  TextColumn get titleEn => text()();
  TextColumn get titleId => text()();
  TextColumn get titleNia => text()();
  TextColumn get descriptionEn => text()();
  TextColumn get descriptionId => text()();
  TextColumn get descriptionNia => text()();
  TextColumn get category => text()();
  TextColumn get imageUrl => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class TimelineEvents extends Table {
  TextColumn get id => text()();
  TextColumn get year => text()();
  TextColumn get titleEn => text()();
  TextColumn get titleId => text()();
  TextColumn get titleNia => text()();
  TextColumn get descriptionEn => text()();
  TextColumn get descriptionId => text()();
  TextColumn get descriptionNia => text()();
  TextColumn get imageUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Amaedola')
class Amaedolas extends Table {
  @override
  String get tableName => 'amaedola';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get pageId => integer().named('page_id')();
  TextColumn get textContent => text().named('text')();
  TextColumn get meaning => text()();
  TextColumn get meaningId => text().named('meaning_id').nullable()();
  TextColumn get meaningEn => text().named('meaning_en').nullable()();
  TextColumn get label => text()();
  TextColumn get url => text().nullable()();
  TextColumn get note => text().nullable()();
}

@DataClassName('Bible')
@TableIndex(name: 'bible_page_verse_idx', columns: {#pageId, #verse}, unique: true)
class Bibles extends Table {
  @override
  String get tableName => 'bible';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get pageId => integer().named('page_id')();
  TextColumn get category => text()(); // 'OT' or 'NT'
  TextColumn get book => text()();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer()();
  TextColumn get textContent => text().named('text')();
  TextColumn get reference => text().map(const StringListConverter()).nullable()();
  TextColumn get note => text().nullable()();
}

@DataClassName('WikiPageRevision')
class WikiPageRevisions extends Table {
  @override
  String get tableName => 'wiki_page_revisions';

  IntColumn get pageId => integer().named('page_id')();
  IntColumn get lastRevid => integer().named('last_revid')();
  TextColumn get pageTitle => text().named('page_title')();
  TextColumn get pageType => text().named('page_type')(); // 'amaedola' or 'bible'
  DateTimeColumn get lastUpdated => dateTime().named('last_updated')();

  @override
  Set<Column> get primaryKey => {pageId};
}

@DataClassName('Song')
@TableIndex(name: 'songs_page_id_idx', columns: {#pageId}, unique: true)
class Songs extends Table {
  @override
  String get tableName => 'songs';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get pageId => integer().named('page_id')();
  TextColumn get title => text()();
  TextColumn get textContent => text().named('text')();
  TextColumn get category => text()(); // 'maena', 'sinunö', 'hendri-hendri', 'lailö'
  TextColumn get type => text().nullable()();
  TextColumn get artist => text().map(const StringListConverter()).nullable()();
  TextColumn get writer => text().map(const StringListConverter()).nullable()();
  TextColumn get producer => text().map(const StringListConverter()).nullable()();
  TextColumn get album => text().nullable()();
  TextColumn get genre => text().nullable()();
  TextColumn get released => text().nullable()(); // dd-mm-yyyy
  TextColumn get recorded => text().nullable()(); // dd-mm-yyyy
  TextColumn get studio => text().nullable()();
  TextColumn get label => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get youtube => text().nullable()();
}

@DataClassName('ManoMano')
@TableIndex(name: 'mano_mano_page_id_idx', columns: {#pageId}, unique: true)
class ManoManos extends Table {
  @override
  String get tableName => 'mano_mano';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get pageId => integer().named('page_id')();
  TextColumn get title => text()();
  TextColumn get textContent => text().named('text')();
  TextColumn get description => text().nullable()();
  TextColumn get editor => text().map(const StringListConverter()).nullable()();
  TextColumn get origin => text().nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get url => text().nullable()();
}

@DataClassName('Article')
@TableIndex(name: 'articles_page_id_idx', columns: {#pageId}, unique: true)
class Articles extends Table {
  @override
  String get tableName => 'articles';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get pageId => integer().named('page_id')();
  TextColumn get category => text()(); // e.g. general, health, technology, blog, opinion
  TextColumn get title => text()();
  TextColumn get textContent => text().named('text')();
  TextColumn get description => text().nullable()();
  TextColumn get editor => text().map(const StringListConverter()).nullable()();
}

@DataClassName('Hoho')
@TableIndex(name: 'hohos_page_id_idx', columns: {#pageId}, unique: true)
class Hohos extends Table {
  @override
  String get tableName => 'hoho';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get pageId => integer().named('page_id')();
  TextColumn get title => text()();
  TextColumn get textContent => text().named('text')();
  TextColumn get description => text().nullable()();
  TextColumn get descId => text().named('desc_id').nullable()();
  TextColumn get descEn => text().named('desc_en').nullable()();
  TextColumn get editor => text().map(const StringListConverter()).nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get url => text().nullable()();
}

@DataClassName('HeritageArticle')
@TableIndex(name: 'heritage_articles_page_id_idx', columns: {#pageId}, unique: true)
class HeritageArticles extends Table {
  @override
  String get tableName => 'heritage_articles';

  IntColumn get pageId => integer().named('page_id')();
  TextColumn get category => text()(); // 'architecture', 'megalith', 'dance', 'clothing', 'village', 'origin', 'timeline'
  TextColumn get wikiHost => text().named('wiki_host').withDefault(const Constant('nia.wikipedia.org'))();
  TextColumn get pageTitle => text().named('page_title')();
  TextColumn get title => text()();
  TextColumn get textContent => text().named('text')();
  TextColumn get htmlContent => text().named('html').nullable()();
  TextColumn get footnotes => text().nullable()(); // JSON string List<ArticleFootnote>
  TextColumn get imageUrl => text().named('image_url').nullable()();
  IntColumn get lastRevid => integer().named('last_revid').withDefault(const Constant(0))();
  DateTimeColumn get lastUpdated => dateTime().named('last_updated').nullable()();

  @override
  Set<Column> get primaryKey => {pageId};
}

@DriftDatabase(tables: [HeritageItems, TimelineEvents, Amaedolas, Bibles, WikiPageRevisions, Songs, ManoManos, Articles, Hohos, HeritageArticles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(NativeDatabase.memory());
  AppDatabase.memory() : super(NativeDatabase.memory());
  AppDatabase.forFile(File file) : super(NativeDatabase(file));
  AppDatabase.forExecutor(super.e);

  Future<bool> updateAmaedola(Amaedola item) => update(amaedolas).replace(item);
  Future<int> deleteAmaedola(int id) => (delete(amaedolas)..where((t) => t.id.equals(id))).go();

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDatabase();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(bibles);
        await _seedBibleData();
      }
      if (from < 3) {
        await m.addColumn(amaedolas, amaedolas.pageId);
        await m.addColumn(bibles, bibles.pageId);
      }
      if (from < 4) {
        await m.createTable(wikiPageRevisions);
      }
      if (from < 5) {
        await m.createTable(songs);
      }
      if (from < 6) {
        await m.createTable(manoManos);
        await m.createTable(articles);
      }
      if (from < 7) {
        await m.createTable(hohos);
      }
      if (from < 8) {
        await m.renameColumn(articles, 'note', articles.description);
        await m.addColumn(articles, articles.editor);
      }
      if (from < 9) {
        await m.createTable(heritageArticles);
      }
    },
  );


  Future<void> _seedDatabase() async {
    // 1. Seed Heritage Items
    await batch((b) {
      b.insertAll(heritageItems, [
        HeritageItem(
          id: 'item-1',
          titleEn: 'Omo Niha (Traditional House)',
          titleId: 'Omo Niha (Rumah Adat Nias)',
          titleNia: 'Omo Niha',
          descriptionEn: 'Earthquake-resistant traditional houses built on massive vertical wooden pillars without nails.',
          descriptionId: 'Rumah tradisional tahan gempa yang dibangun di atas tiang kayu vertikal raksasa tanpa menggunakan paku.',
          descriptionNia: 'Omo Niha no omo hada silö afatö na alua ndrulu danö, nifatumbu\'ö ba hogu geu silö moguna faku.',
          category: 'architecture',
          imageUrl: 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/omo_hada.jpg',
          createdAt: DateTime.now(),
        ),
        HeritageItem(
          id: 'item-2',
          titleEn: 'Behu (Megalithic Stone Carvings)',
          titleId: 'Behu (Batu Megalitik Nias)',
          titleNia: 'Behu / Gowe Kara',
          descriptionEn: 'Carved stone monuments (gowe and darodaro) erected to commemorate ancestors and denote village social status.',
          descriptionId: 'Monumen batu berukir (gowe dan darodaro) yang didirikan untuk mengenang leluhur serta menandai status sosial desa.',
          descriptionNia: 'Gowe Kara awö darodaro no tandra mbawandruhö nifazökhi ndra satua föna ba wamazökhi fa\'asura ba mbawa hada.',
          category: 'megalith',
          imageUrl: 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/gowe.jpg',
          createdAt: DateTime.now(),
        ),
        HeritageItem(
          id: 'item-3',
          titleEn: 'Dances & Ritual Performances',
          titleId: 'Tari & Seni Pertunjukan',
          titleNia: 'Fanari & Famaena',
          descriptionEn: 'Traditional group dances (Maena, Hiŵö-hiŵö, Fatele, Fahombo) performed to welcome honored guests during ceremonies and festivals.',
          descriptionId: 'Tarian kelompok tradisional (Maena, Hiŵö-hiŵö, Fatele, Fahombo) yang dibawakan untuk menyambut tamu kehormatan dalam upacara dan festival.',
          descriptionNia: 'Fanari, Maena, Hiŵö-hiŵö, Fatele, ba Fahombo no famaena ba wamowai tome awö ba zowato falöwö hada ba Danö Niha.',
          category: 'dance',
          imageUrl: 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/famaena.jpg',
          createdAt: DateTime.now(),
        ),
        HeritageItem(
          id: 'item-4',
          titleEn: 'Baru Oholu (Traditional Attire)',
          titleId: 'Baru Oholu (Pakaian Adat)',
          titleNia: 'Baru Oholu',
          descriptionEn: 'Traditional Nias garments historically crafted from hammered tree bark fibers (oholu) and decorated with intricate metalwork.',
          descriptionId: 'Pakaian tradisional Nias yang secara historis dibuat dari serat kulit kayu yang dipukul (oholu) dan dihiasi ornamen logam.',
          descriptionNia: 'Baru Oholu no baru hada ndra niha föna nifazökhi moroi ba uli geu nifasao ba nihaogö faoma ngawalö ornamente maso.',
          category: 'clothing',
          imageUrl: 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/oholu.jpg',
          createdAt: DateTime.now(),
        ),
        HeritageItem(
          id: 'item-5',
          titleEn: 'Banua Niha (Traditional Villages)',
          titleId: 'Banua Niha (Desa Adat Nias)',
          titleNia: 'Banua Niha',
          descriptionEn: 'Fortified hilltop settlements featuring stone-paved streets (lali gowe), traditional houses (omo niha), and megaliths organized under customary governance.',
          descriptionId: 'Pemukiman bukit bersejarah dengan jalan beraspal batu (lali gowe), rumah adat (omo niha), dan megalit yang dikelola berdasarkan hukum adat.',
          descriptionNia: 'Banua Niha no mbanua satua mege si so lali gowe, omo niha, ba behu kara nifa\'anö molo\'ö hada Nono Niha.',
          category: 'village',
          imageUrl: 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/banua.jpg',
          createdAt: DateTime.now(),
        ),
        HeritageItem(
          id: 'item-6',
          titleEn: 'The Origin of Ono Niha',
          titleId: 'Asal-usul Ono Niha',
          titleNia: 'Böröta Nono Niha',
          descriptionEn: 'DNA and archaeological research shed light on the origin of Nias people as part of ancient human migration from the Asian continent across the Indonesian archipelago, extending westwards to Madagascar and eastwards to Oceania-Pacific.',
          descriptionId: 'Penelitian DNA dan arkeologi mengungkap asal-usul masyarakat Nias sebagai bagian dari migrasi manusia kuno dari benua Asia melintasi kepulauan Indonesia, membentang ke barat hingga Madagaskar dan ke timur hingga Oseania-Pasifik.',
          descriptionNia: 'Famaresa DNA ba arkeologi no i\'oroma\'ö wa\'atomösi Nono Niha moroi ba wa\'amufanö niha moroi ba Asia, irugi Madagaskar ba gaekhula ba Oseania-Pasifik ba gatumbukha.',
          category: 'origin',
          imageUrl: 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/origin.jpg',
          createdAt: DateTime.now(),
        ),
        HeritageItem(
          id: 'item-7',
          titleEn: 'Nias History Timeline',
          titleId: 'Lini Masa Sejarah Nias',
          titleNia: 'Ofanöŵa Ginötö',
          descriptionEn: 'Begins 12,000 years ago, with written records appearing in the 1st century AD onwards, accelerating through colonial times up to independence.',
          descriptionId: 'Dimulai sejak 12.000 tahun lalu, dengan catatan tertulis mulai muncul sejak abad ke-1 Masehi, lalu berkembang pesat sejak era kolonial hingga kemerdekaan.',
          descriptionNia: 'Ofanöŵa ginötö i\'otarai 12.000 fakhe si lalö, so zura i\'otarai abad 1 Masehi irugi ginötö kemerdekaan.',
          category: 'timeline',
          imageUrl: 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/timeline.jpg',
          createdAt: DateTime.now(),
        ),
      ]);


      b.insertAll(timelineEvents, [
        TimelineEvent(
          id: 'time-1',
          year: '12,000 BC',
          titleEn: 'First Cave Dwellers (Tögi Ndrawa)',
          titleId: 'Penghuni Goa Pertama (Tögi Ndrawa)',
          titleNia: 'Inhabitants ba Dögi Ndrawa',
          descriptionEn: 'Archaeological excavations in Tögi Ndrawa cave reveal human habitation dating back 12,000 years, indicating the earliest migration and settlement on Nias Island.',
          descriptionId: 'Ekskavasi arkeologi di goa Tögi Ndrawa mengungkap hunian manusia berumur 12.000 tahun, menunjukkan migrasi dan pemukiman paling awal di Pulau Nias.',
          descriptionNia: 'Famakha famaresa ba Dögi Ndrawa no lahöli ia wa no so niha sanguri ba dögi da\'a i\'atarai 12.000 fakhe si lalö, tandra wa no i\'otarai föna so niha ba Danö Niha.',
          imageUrl: 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/togi_ndrawa.jpg',
        ),
        TimelineEvent(
          id: 'time-2',
          year: '900 AD',
          titleEn: 'Flourishing of Megalithic Culture',
          titleId: 'Puncak Kebudayaan Megalitik',
          titleNia: 'Fa\'alawo Hada Gowe Kara',
          descriptionEn: 'Establishment of stone-carving traditions. Villages begin erecting massive stone monuments and constructing the initial stone-paved paths (*Lali Gowe*) connecting hill settlements.',
          descriptionId: 'Pembentukan tradisi memahat batu. Desa-desa mulai mendirikan monumen batu besar dan membangun jalan beraspal batu (*Lali Gowe*) yang menghubungkan pemukiman bukit.',
          descriptionNia: 'Famaza\'a gowe kara ba Danö Niha no labörötaigö ba fakhe da\'a, lahaogö lali gowe mbanua ba wamaola ngawalö wa\'auri niha ba mbanua.',
          imageUrl: 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/megalith_era.jpg',
        ),
        TimelineEvent(
          id: 'time-3',
          year: '1840 AD',
          titleEn: 'European Documentation of Nias',
          titleId: 'Dokumentasi Eropa tentang Nias',
          titleNia: 'Fangurusi ndra Niha Belanda',
          descriptionEn: 'Expeditions from the Netherlands and Germany document Nias traditional customs (Omo Hada, Bawomataluo) and introduce Nias culture to international ethnography catalogs.',
          descriptionId: 'Ekspedisi dari Belanda dan Jerman mendokumentasikan adat istiadat Nias (Omo Hada, Bawomataluo) dan memperkenalkan budaya Nias ke katalog etnografi internasional.',
          descriptionNia: 'Folohe ndra niha Belanda ba famaresa ngawalö omo hada ba zifasui Danö Niha, ba wolohe hara da\'a ba negara Belanda ba wamaresa ethnografi.',
          imageUrl: 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/colonial_docs.jpg',
        ),
        TimelineEvent(
          id: 'time-4',
          year: '2000 AD',
          titleEn: 'UNESCO World Heritage Tentative List',
          titleId: 'Daftar Tentatif Warisan Dunia UNESCO',
          titleNia: 'Daftar Tentatif UNESCO',
          descriptionEn: 'The traditional settlement of Bawomataluo is submitted to the UNESCO World Heritage Tentative List to protect and preserve its unique architecture, megaliths, and rituals.',
          descriptionId: 'Pemukiman tradisional Bawomataluo diajukan ke Daftar Tentatif Warisan Dunia UNESCO untuk melindungi dan melestarikan arsitektur, megalit, dan ritualnya yang unik.',
          descriptionNia: 'Banua hada Bawomataluo lafaogö ia ba daftar tentatif warisan dunia UNESCO ba wamaola fa\'atobali hada gowe kara ba omo hada si lö tesa\'adö ba zisagörö ulidanö.',
          imageUrl: 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/bawomataluo_unesco.jpg',
        ),
      ]);
    });
    await _seedBibleData();
  }

  Future<void> _seedBibleData() async {
    // Left empty so table is populated via bin/fetch_bible.dart scraper
  }
}
