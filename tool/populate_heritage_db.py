import json
import re
import sqlite3
import time
import urllib.request
from html.parser import HTMLParser

class TextExtractor(HTMLParser):
    def __init__(self):
        super().__init__()
        self.pieces = []
    def handle_data(self, data):
        self.pieces.append(data)
    def get_text(self):
        return "".join(self.pieces)

articles = [
    # Introduction Section
    {"page_id": 5037, "category": "intro", "title": "Mangai Mangawuli Manö-Manö Nono Niha", "page_title": "Sangoguna:Slaia/Mangai Mangawuli Manö-Manö Nono Niha"},
    {"page_id": 5034, "category": "intro", "title": "Merebut Kembali Narasi Nias (Ceramah)", "page_title": "Sangoguna:Slaia/Merebut Kembali Narasi Nias (Ceramah)"},
    {"page_id": 5032, "category": "intro", "title": "Merebut Kembali Narasi Nias", "page_title": "Sangoguna:Slaia/Merebut Kembali Narasi Nias"},
    {"page_id": 5033, "category": "intro", "title": "Reclaiming the Nias Narrative", "page_title": "Sangoguna:Slaia/Reclaiming the Nias Narrative"},
    {"page_id": 5029, "category": "intro", "title": "Reclaiming the Nias Narrative (Paper)", "page_title": "Sangoguna:Slaia/Reclaiming the Nias Narrative (Paper)"},

    # 1. Architecture Section
    {"page_id": 5038, "category": "architecture", "title": "Fangotomosi Omo Niha", "page_title": "Sangoguna:Slaia/Fangotomosi Omo Niha"},
    {"page_id": 5030, "category": "architecture", "title": "Arsitektur Rumah Tradisional Nias", "page_title": "Sangoguna:Slaia/Arsitektur Rumah Tradisional Nias"},
    {"page_id": 5031, "category": "architecture", "title": "Nias Traditional House Architecture", "page_title": "Sangoguna:Slaia/Nias Traditional House Architecture"},

    # 2. Megaliths Section
    {"page_id": 5039, "category": "megalith", "title": "Gowe Megalit", "page_title": "Sangoguna:Slaia/Gowe Megalit"},
    {"page_id": 5035, "category": "megalith", "title": "Batu Megalit Nias", "page_title": "Sangoguna:Slaia/Batu Megalit Nias"},
    {"page_id": 5036, "category": "megalith", "title": "Nias Megalithic Stones", "page_title": "Sangoguna:Slaia/Nias Megalithic Stones"},

    # 3. Arts Section
    {"page_id": 5040, "category": "arts", "title": "Nekhe-Nekhe", "page_title": "Sangoguna:Slaia/Nekhe-Nekhe"},
    {"page_id": 5041, "category": "arts", "title": "Seni dan Budaya Nias", "page_title": "Sangoguna:Slaia/Seni dan Budaya Nias"},
    {"page_id": 5042, "category": "arts", "title": "Nias Arts and Culture", "page_title": "Sangoguna:Slaia/Nias Arts and Culture"},

    # 4. Attire/Clothing Section
    {"page_id": 5044, "category": "clothing", "title": "Baru ba Gama-Gama", "page_title": "Sangoguna:Slaia/Baru ba Gama-Gama"},
    {"page_id": 5043, "category": "clothing", "title": "Busana Nias dan Perkakas", "page_title": "Sangoguna:Slaia/Busana Nias dan Perkakas"},
    {"page_id": 5045, "category": "clothing", "title": "Nias Attire and Tools", "page_title": "Sangoguna:Slaia/Nias Attire and Tools"},

    # 5. Village Section
    {"page_id": 5046, "category": "village", "title": "Banua ba Amakhoita", "page_title": "Sangoguna:Slaia/Banua ba Amakhoita"},
    {"page_id": 5047, "category": "village", "title": "Sistem Sosial Nias", "page_title": "Sangoguna:Slaia/Sistem Sosial Nias"},
    {"page_id": 5048, "category": "village", "title": "Nias Social System", "page_title": "Sangoguna:Slaia/Nias Social System"},

    # 6. Origin Section
    {"page_id": 5050, "category": "origin", "title": "Böröta Nono Niha", "page_title": "Sangoguna:Slaia/Böröta Nono Niha"},
    {"page_id": 5049, "category": "origin", "title": "Asal-usul Orang Nias", "page_title": "Sangoguna:Slaia/Asal-usul Orang Nias"},
    {"page_id": 5051, "category": "origin", "title": "Origin of Ono Niha", "page_title": "Sangoguna:Slaia/Origin of Ono Niha"},

    # 7. Timeline Section
    {"page_id": 5053, "category": "timeline", "title": "Ofanöŵa Ginötö", "page_title": "Sangoguna:Slaia/Ofanöŵa Ginötö"},
    {"page_id": 5052, "category": "timeline", "title": "Linimasa Sejarah Nias", "page_title": "Sangoguna:Slaia/Linimasa Sejarah Nias"},
    {"page_id": 5054, "category": "timeline", "title": "Nias History Timeline", "page_title": "Sangoguna:Slaia/Nias History Timeline"},
]

hero_images = {
    'intro': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/heritage.jpg',
    'architecture': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/omo_hada.jpg',
    'megalith': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/gowe.jpg',
    'arts': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/famaena.jpg',
    'clothing': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/oholu.jpg',
    'village': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/banua.jpg',
    'origin': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/origin.jpg',
    'timeline': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/timeline.jpg',
}

import html

def sanitize_title(raw_title, fallback=""):
    clean = re.sub(r'<[^>]*>', '', raw_title).strip()
    clean = re.sub(r'^(?:Sangoguna|User):Slaia\/', '', clean, flags=re.IGNORECASE)
    clean = re.sub(r'^Wikipedia:', '', clean, flags=re.IGNORECASE)
    clean = clean.replace('_', ' ').strip()
    return clean if clean else fallback

def clean_html_and_extract(raw_html, default_title):
    # Remove all variations of mw-editsection spans, brackets, and edit links completely
    cleaned = re.sub(r'<span class="mw-editsection"[^>]*>.*?</span>\s*</span>', '', raw_html, flags=re.DOTALL)
    cleaned = re.sub(r'<span class="mw-editsection"[^>]*>.*?</span>', '', cleaned, flags=re.DOTALL)
    cleaned = re.sub(r'<span class="mw-editsection-bracket"[^>]*>.*?</span>', '', cleaned, flags=re.DOTALL)
    cleaned = re.sub(r'<span class="mw-editsection-divider"[^>]*>.*?</span>', '', cleaned, flags=re.DOTALL)
    cleaned = re.sub(r'<a[^>]+href="[^"]*(?:action=edit|veaction=edit)[^"]*"[^>]*>.*?</a>', '', cleaned, flags=re.DOTALL)
    cleaned = re.sub(r'<!--.*?-->', '', cleaned, flags=re.DOTALL)

    # Extract image
    img_match = re.search(r'<img[^>]+src="([^">]+)"', cleaned)
    image_url = None
    if img_match:
        url = img_match.group(1)
        if url.startswith("//"):
            image_url = "https:" + url
        elif url.startswith("http"):
            image_url = url

    # Extract plain text
    parser = TextExtractor()
    parser.feed(cleaned)
    text_content = parser.get_text().strip()

    # Extract footnotes
    footnotes = []
    fn_idx = 1
    pattern = re.compile(r'<li[^>]+id=[\"\']?cite(?:_|&#95;)note-([^\"\'>\s]+)[\"\']?[^>]*>(.*?)</li>', re.DOTALL | re.IGNORECASE)
    for ref_id, content in pattern.findall(cleaned):
        clean_content = re.sub(r'<span class="mw-cite-backlink">.*?</span>', '', content, flags=re.DOTALL)
        clean_content = re.sub(r'<a href="#cite_ref[^"]*">.*?</a>', '', clean_content, flags=re.DOTALL)
        clean_content = re.sub(r'<[^>]+>', '', clean_content).strip()
        clean_content = re.sub(r'^\s*[\^↑]\s*', '', clean_content).strip()
        clean_content = html.unescape(clean_content)

        url_match = re.search(r'<a[^>]+href="([^"]+)"[^>]*class="[^"]*external[^"]*"', content)
        if not url_match:
            url_match = re.search(r'<a[^>]+href="(https?://[^"]+)"', content)
        ref_url = url_match.group(1) if url_match else None

        clean_ref_id = ref_id.replace('&#95;', '_')
        norm_id = f'cite_note-{clean_ref_id}'

        footnotes.append({
            'index': fn_idx,
            'id': norm_id,
            'text': clean_content,
            'url': ref_url
        })
        fn_idx += 1

    return text_content, cleaned, image_url, json.dumps(footnotes)

def clean_all_existing_data():
    db_paths = ["niasheritage.sqlite", "assets/niasheritage.sqlite"]
    for db_path in db_paths:
        con = sqlite3.connect(db_path)
        cur = con.cursor()
        rows = cur.execute("SELECT page_id, title, html FROM heritage_articles").fetchall()
        updated_titles = 0
        updated_content = 0
        for page_id, raw_title, raw_html in rows:
            clean_title = sanitize_title(raw_title)
            if clean_title != raw_title:
                cur.execute("UPDATE heritage_articles SET title = ? WHERE page_id = ?", (clean_title, page_id))
                updated_titles += 1

            if raw_html:
                text_content, cleaned_html, img_url, fns_json = clean_html_and_extract(raw_html, clean_title)
                cur.execute("""
                    UPDATE heritage_articles 
                    SET html = ?, text = ?, footnotes = ?
                    WHERE page_id = ?
                """, (cleaned_html, text_content, fns_json, page_id))
                updated_content += 1

        con.commit()
        con.close()
        print(f"[{db_path}] Cleaned {updated_titles} titles, updated content & footnotes for {updated_content} articles.")

def update_databases():
    db_paths = ["niasheritage.sqlite", "assets/niasheritage.sqlite"]
    now = int(time.time())

    for art in articles:
        page_id = art["page_id"]
        category = art["category"]
        title = art["title"]
        page_title = art["page_title"]

        # Check if already populated in local DB
        con_check = sqlite3.connect("niasheritage.sqlite")
        cur_check = con_check.cursor()
        cur_check.execute("SELECT last_revid FROM heritage_articles WHERE page_id = ?", (page_id,))
        row = cur_check.fetchone()
        con_check.close()
        if row and row[0] and row[0] > 0:
            print(f"Skipping [{page_id}] (already populated with revid {row[0]})...")
            continue

        print(f"Fetching [{page_id}] {page_title}...")
        url = f"https://nia.wikipedia.org/w/api.php?action=parse&pageid={page_id}&prop=text|revid|displaytitle&format=json"
        req = urllib.request.Request(url, headers={"User-Agent": "NiasHeritagePopulate/1.0 (https://github.com/sslaia/niasheritage; contact@example.com)"})
        time.sleep(1.2)

        try:
            with urllib.request.urlopen(req) as resp:
                data = json.loads(resp.read().decode('utf-8'))
                parse_data = data.get("parse")
                if not parse_data:
                    print(f"  Error: {data.get('error')}")
                    continue

                online_revid = parse_data.get("revid", 0)
                online_title = parse_data.get("title", page_title)
                raw_display_title = parse_data.get("displaytitle", title)
                display_title = sanitize_title(raw_display_title, fallback=title)
                raw_html = parse_data.get("text", {}).get("*", "")

                text_content, cleaned_html, img_url, footnotes_json = clean_html_and_extract(raw_html, title)
                final_img = img_url or hero_images.get(category)

                for db_path in db_paths:
                    con = sqlite3.connect(db_path)
                    cur = con.cursor()

                    # Insert or replace in heritage_articles
                    cur.execute("""
                        INSERT OR REPLACE INTO heritage_articles 
                        (page_id, category, wiki_host, page_title, title, text, html, footnotes, image_url, last_revid, last_updated)
                        VALUES (?, ?, 'nia.wikipedia.org', ?, ?, ?, ?, ?, ?, ?, ?)
                    """, (page_id, category, online_title, display_title, text_content, cleaned_html, footnotes_json, final_img, online_revid, now))

                    # Insert or replace in wiki_page_revisions
                    cur.execute("""
                        INSERT OR REPLACE INTO wiki_page_revisions
                        (page_id, last_revid, page_title, page_type, last_updated)
                        VALUES (?, ?, ?, 'heritage', ?)
                    """, (page_id, online_revid, online_title, now))

                    con.commit()
                    con.close()

                print(f"  Successfully saved [{page_id}] (revid: {online_revid}) to both databases!")
        except Exception as e:
            print(f"  Failed for [{page_id}]: {e}")

if __name__ == "__main__":
    clean_all_existing_data()
    update_databases()
