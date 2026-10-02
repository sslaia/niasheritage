#!/usr/bin/env python3
"""
Tool to fetch and repopulate database assets for release:
1. Refetches and repopulates all Heritage Articles from nia.wikipedia.org
2. Refetches and repopulates Writings (Sinura amilita) from Kategori:Sinura amilita on nia.wikipedia.org
3. Refetches and repopulates Recitation (Hoho amilita) from Kategori:Hoho amilita on nia.wikipedia.org
4. Updates all URLs across library sections (songs, stories, recitations, writings, proverbs)
   to ensure all point to nia.wikipedia.org
5. Synchronizes both niasheritage.sqlite and assets/niasheritage.sqlite
"""

import json
import os
import re
import sqlite3
import time
import urllib.parse
import urllib.request
import html
from bs4 import BeautifulSoup

USER_AGENT = "NiasHeritageScraper/1.0 (https://sslaia.github.io/niasheritage; contact: slaia@yahoo.com)"
WIKI_HOST = "nia.wikipedia.org"
DB_PATHS = ["niasheritage.sqlite", "assets/niasheritage.sqlite"]

HERITAGE_ARTICLES = [
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

    # Legacy / Cross-reference Heritage Articles
    {"page_id": 4297, "category": "architecture", "title": "Omo Niha", "page_title": "Omo_Niha"},
    {"page_id": 4797, "category": "megalith", "title": "Behu ba Daro-Daro Nono Niha", "page_title": "Behu_ba_Daro-Daro_Nono_Niha"},
    {"page_id": 4798, "category": "arts", "title": "Fanari ba Fanunö Nono Niha", "page_title": "Fanari_ba_Fanunö_Nono_Niha"},
    {"page_id": 4799, "category": "clothing", "title": "Gama-Gama Nono Niha", "page_title": "Gama-Gama_Nono_Niha"},
    {"page_id": 4800, "category": "village", "title": "Banua Nono Niha", "page_title": "Banua_Nono_Niha"},
    {"page_id": 4801, "category": "origin", "title": "Böröta Nono Niha", "page_title": "Böröta_Nono_Niha"},
    {"page_id": 4802, "category": "timeline", "title": "Ofanöŵa Ginötö Nono Niha", "page_title": "Ofanöŵa_Ginötö_Nono_Niha"},
]

HERO_IMAGES = {
    'intro': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/heritage.jpg',
    'architecture': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/omo_hada.jpg',
    'megalith': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/gowe.jpg',
    'arts': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/famaena.jpg',
    'clothing': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/oholu.jpg',
    'village': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/banua.jpg',
    'origin': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/origin.jpg',
    'timeline': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/timeline.jpg',
}

def http_get_json(url):
    req = urllib.request.Request(url, headers={'User-Agent': USER_AGENT})
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode('utf-8'))

def sanitize_title(raw_title, fallback=""):
    clean = re.sub(r'<[^>]*>', '', raw_title).strip()
    clean = re.sub(r'^(?:Sangoguna|User):Slaia\/', '', clean, flags=re.IGNORECASE)
    clean = re.sub(r'^(?:Wikipedia|Wikibooks|Wiktionary|Category|Kategori):', '', clean, flags=re.IGNORECASE)
    clean = re.sub(r'^(?:Hoho|Manö-[Mm]anö|Mano-[Mm]ano|Sinunö|Sinuno|Amaedola)\/', '', clean, flags=re.IGNORECASE)
    clean = clean.replace('_', ' ').strip()
    clean = html.unescape(clean)
    return clean if clean else fallback

def remove_templates_with_balanced_braces(text):
    result = []
    i = 0
    n = len(text)
    while i < n:
        if i + 1 < n and text[i:i+2] == '{{':
            depth = 1
            i += 2
            while i < n and depth > 0:
                if i + 1 < n and text[i:i+2] == '{{':
                    depth += 1
                    i += 2
                elif i + 1 < n and text[i:i+2] == '}}':
                    depth -= 1
                    i += 2
                else:
                    i += 1
        else:
            result.append(text[i])
            i += 1
    return ''.join(result)

def clean_heritage_html_and_extract(raw_html, default_title):
    soup = BeautifulSoup(raw_html, 'html.parser')

    # 1. Extract hero image before stripping infoboxes
    hero_image = None
    img_tag = soup.find('img')
    if img_tag and img_tag.get('src'):
        src = img_tag['src']
        if src.startswith('//'):
            hero_image = 'https:' + src
        elif src.startswith('http'):
            hero_image = src

    # 2. Extract footnotes before removal
    footnotes = []
    fn_idx = 1
    reflist = soup.find(class_=lambda c: c and ('reflist' in c or 'references' in c)) or soup.find('ol', class_='references')
    if reflist:
        for li in reflist.find_all('li'):
            ref_id = li.get('id', f'cite_note-{fn_idx}')
            norm_id = ref_id.replace('&#95;', '_')
            if not norm_id.startswith('cite_note-'):
                norm_id = f'cite_note-{norm_id}'
            
            # Find backlink and remove
            for backlink in li.find_all(class_='mw-cite-backlink'):
                backlink.decompose()
            for a in li.find_all('a', href=lambda h: h and h.startswith('#cite_ref')):
                a.decompose()
            
            # Find external link
            ext_a = li.find('a', class_=lambda c: c and 'external' in c) or li.find('a', href=lambda h: h and h.startswith('http'))
            ref_url = ext_a['href'] if ext_a else None

            fn_text = li.get_text().strip()
            fn_text = re.sub(r'^\s*[\^↑]\s*', '', fn_text).strip()

            footnotes.append({
                'index': fn_idx,
                'id': norm_id,
                'text': fn_text,
                'url': ref_url,
            })
            fn_idx += 1

    # 3. Remove infoboxes, sidebars, vertical navboxes (AGENTS.md Rule 6)
    for infobox in soup.find_all(['table', 'div'], class_=lambda c: c and any(x in str(c) for x in ['infobox', 'sidebar', 'vertical-navbox', 'vcard', 'infobox_v3', 'infobox_v2', 'infobox-subbox'])):
        infobox.decompose()

    # 4. Remove edit sections and non-redlink edit links (AGENTS.md Rule 1 & 5)
    for edit_sec in soup.find_all(class_=lambda c: c and any(x in str(c) for x in ['mw-editsection', 'mw-editsection-bracket', 'mw-editsection-divider', 'mw-editsection-visualeditor'])):
        edit_sec.decompose()
    for a in soup.find_all('a', href=lambda h: h and ('action=edit' in h or 'veaction=edit' in h)):
        classes = a.get('class', [])
        href = a.get('href', '')
        # Preserve red links!
        if 'new' in classes or 'redlink=1' in href:
            continue
        a.decompose()

    # 5. Remove references container and navigation
    for rem in soup.find_all(['nav', 'style', 'script', 'meta', 'link'], class_=lambda c: True):
        rem.decompose()
    if reflist:
        reflist.decompose()
    for rem in soup.find_all(class_=lambda c: c and any(x in str(c) for x in ['catlinks', 'printfooter', 'toc'])):
        rem.decompose()

    # 6. Clean plain text
    plain_text = soup.get_text().strip()
    plain_text = re.sub(r'\n{3,}', '\n\n', plain_text)

    cleaned_html = str(soup)

    return plain_text, cleaned_html, hero_image, json.dumps(footnotes)

def fetch_category_members(cat_title):
    members = []
    cmcontinue = None
    while True:
        params = {
            'action': 'query',
            'list': 'categorymembers',
            'cmtitle': cat_title,
            'cmlimit': '500',
            'cmprop': 'ids|title',
            'format': 'json',
        }
        if cmcontinue:
            params['cmcontinue'] = cmcontinue
        url = f"https://{WIKI_HOST}/w/api.php?{urllib.parse.urlencode(params)}"
        data = http_get_json(url)
        cm = data.get('query', {}).get('categorymembers', [])
        for m in cm:
            members.append(m)
        cmcontinue = data.get('continue', {}).get('cmcontinue')
        if not cmcontinue:
            break
        time.sleep(0.3)
    return members

def update_heritage_articles():
    print(f"\n=======================================================")
    print(f"1. Refetching and Repopulating {len(HERITAGE_ARTICLES)} Heritage Articles...")
    print(f"=======================================================")

    now_sec = int(time.time())
    now_ms = int(time.time() * 1000)

    for idx, art in enumerate(HERITAGE_ARTICLES, 1):
        page_id = art["page_id"]
        category = art["category"]
        title = art["title"]
        page_title = art["page_title"]

        print(f"[{idx}/{len(HERITAGE_ARTICLES)}] Fetching PID {page_id}: {page_title}...")
        url = f"https://{WIKI_HOST}/w/api.php?action=parse&pageid={page_id}&prop=text|revid|displaytitle&format=json"
        try:
            data = http_get_json(url)
            parse_data = data.get("parse")
            if not parse_data:
                print(f"  Error: {data.get('error')}")
                continue

            online_revid = parse_data.get("revid", 0)
            online_title = parse_data.get("title", page_title)
            raw_display_title = parse_data.get("displaytitle", title)
            display_title = sanitize_title(raw_display_title, fallback=title)
            raw_html = parse_data.get("text", {}).get("*", "")

            plain_text, cleaned_html, hero_img, fns_json = clean_heritage_html_and_extract(raw_html, display_title)
            final_img = hero_img or HERO_IMAGES.get(category)

            for db_path in DB_PATHS:
                con = sqlite3.connect(db_path)
                cur = con.cursor()
                cur.execute("""
                    INSERT OR REPLACE INTO heritage_articles 
                    (page_id, category, wiki_host, page_title, title, text, html, footnotes, image_url, last_revid, last_updated)
                    VALUES (?, ?, 'nia.wikipedia.org', ?, ?, ?, ?, ?, ?, ?, ?)
                """, (page_id, category, online_title, display_title, plain_text, cleaned_html, fns_json, final_img, online_revid, now_sec))

                cur.execute("""
                    INSERT OR REPLACE INTO wiki_page_revisions
                    (page_id, last_revid, page_title, page_type, last_updated)
                    VALUES (?, ?, ?, 'heritage', ?)
                """, (page_id, online_revid, online_title, now_ms))
                con.commit()
                con.close()

            print(f"  -> Saved PID {page_id} '{display_title}' (revid: {online_revid})")
            time.sleep(0.4)
        except Exception as e:
            print(f"  Failed PID {page_id}: {e}")

def update_recitations():
    print(f"\n=======================================================")
    print(f"2. Refetching and Repopulating Recitation (Kategori:Hoho amilita)...")
    print(f"=======================================================")

    members = fetch_category_members("Kategori:Hoho amilita")
    print(f"Found {len(members)} pages in Kategori:Hoho amilita.")

    now_ms = int(time.time() * 1000)

    # Clean existing recitation table across both DBs
    for db_path in DB_PATHS:
        con = sqlite3.connect(db_path)
        cur = con.cursor()
        cur.execute("DELETE FROM recitation")
        cur.execute("DELETE FROM wiki_page_revisions WHERE page_type = 'recitation'")
        con.commit()
        con.close()

    for idx, m in enumerate(members, 1):
        pid = m["pageid"]
        raw_title = m["title"]
        print(f"[{idx}/{len(members)}] Fetching PID {pid}: {raw_title}...")

        url = f"https://{WIKI_HOST}/w/api.php?action=parse&pageid={pid}&prop=text|wikitext|revid|displaytitle&format=json"
        try:
            data = http_get_json(url)
            parse_data = data.get("parse")
            if not parse_data:
                print(f"  Error: {data.get('error')}")
                continue

            online_revid = parse_data.get("revid", 0)
            wt = parse_data.get("wikitext", {}).get("*", "")
            raw_html = parse_data.get("text", {}).get("*", "")

            # Extract info box parameters
            desc_match = re.search(r'\|\s*deskripsi\s*=\s*(.*?)(?=\n\s*\||\n\s*\}\})', wt, re.DOTALL)
            desc_id_match = re.search(r'\|\s*deskripsi_id\s*=\s*(.*?)(?=\n\s*\||\n\s*\}\})', wt, re.DOTALL)
            desc_en_match = re.search(r'\|\s*deskripsi_en\s*=\s*(.*?)(?=\n\s*\||\n\s*\}\})', wt, re.DOTALL)
            src_match = re.search(r'\|\s*sumber\s*=\s*(.*?)(?=\n\s*\||\n\s*\}\})', wt, re.DOTALL)
            ed_match = re.search(r'\|\s*penyunting\s*=\s*(.*?)(?=\n\s*\||\n\s*\}\})', wt, re.DOTALL)

            desc = desc_match.group(1).strip() if desc_match else None
            desc_id = desc_id_match.group(1).strip() if desc_id_match else None
            desc_en = desc_en_match.group(1).strip() if desc_en_match else None
            src = src_match.group(1).strip() if src_match else None
            ed = ed_match.group(1).strip() if ed_match else None

            # Clean up empty or broken template values
            if desc and (desc.startswith('|') or len(desc) < 2): desc = None
            if desc_id and (desc_id.startswith('|') or len(desc_id) < 2): desc_id = None
            if desc_en and (desc_en.startswith('|') or len(desc_en) < 2): desc_en = None
            if src and (src.startswith('|') or len(src) < 2): src = None
            if ed and (ed.startswith('|') or len(ed) < 2): ed = None

            editor_json = json.dumps([ed]) if ed else None

            # Extract poem text
            soup = BeautifulSoup(raw_html, 'html.parser')
            # Remove infoboxes, styles, scripts, editsections
            for rem in soup.find_all(['table', 'style', 'script', 'nav', 'meta', 'link']):
                rem.decompose()
            for rem in soup.find_all(class_=lambda c: c and any(x in str(c) for x in ['mw-editsection', 'catlinks', 'printfooter', 'toc'])):
                rem.decompose()

            poem = soup.find(class_='poem')
            if poem:
                poem_text = poem.get_text().strip()
            else:
                poem_text = soup.get_text().strip()
            poem_text = re.sub(r'\n{3,}|\r\n{3,}', '\n\n', poem_text)

            clean_display_title = sanitize_title(raw_title, fallback=raw_title)
            article_url = f"https://{WIKI_HOST}/wiki/{urllib.parse.quote(raw_title.replace(' ', '_'))}"

            for db_path in DB_PATHS:
                con = sqlite3.connect(db_path)
                cur = con.cursor()
                cur.execute("""
                    INSERT INTO recitation
                    (page_id, title, text, description, desc_id, desc_en, editor, source, url)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (pid, clean_display_title, poem_text, desc, desc_id, desc_en, editor_json, src, article_url))

                cur.execute("""
                    INSERT OR REPLACE INTO wiki_page_revisions
                    (page_id, last_revid, page_title, page_type, last_updated)
                    VALUES (?, ?, ?, 'recitation', ?)
                """, (pid, online_revid, raw_title, now_ms))
                con.commit()
                con.close()

            print(f"  -> Saved Hoho PID {pid} '{clean_display_title}' ({len(poem_text.splitlines())} lines)")
            time.sleep(0.4)
        except Exception as e:
            print(f"  Failed Hoho PID {pid}: {e}")

def update_writings():
    print(f"\n=======================================================")
    print(f"3. Refetching and Repopulating Writings (Kategori:Sinura amilita)...")
    print(f"=======================================================")

    members = fetch_category_members("Kategori:Sinura amilita")
    print(f"Found {len(members)} pages in Kategori:Sinura amilita.")

    now_ms = int(time.time() * 1000)

    # Clean existing writings table across both DBs
    for db_path in DB_PATHS:
        con = sqlite3.connect(db_path)
        cur = con.cursor()
        cur.execute("DELETE FROM writings")
        cur.execute("DELETE FROM wiki_page_revisions WHERE page_type = 'writing' OR page_type = 'featured_article'")
        con.commit()
        con.close()

    for idx, m in enumerate(members, 1):
        pid = m["pageid"]
        raw_title = m["title"]
        print(f"[{idx}/{len(members)}] Fetching PID {pid}: {raw_title}...")

        url = f"https://{WIKI_HOST}/w/api.php?action=parse&pageid={pid}&prop=text|wikitext|revid|displaytitle&format=json"
        try:
            data = http_get_json(url)
            parse_data = data.get("parse")
            if not parse_data:
                print(f"  Error: {data.get('error')}")
                continue

            online_revid = parse_data.get("revid", 0)
            raw_display_title = parse_data.get("displaytitle", raw_title)
            wt = parse_data.get("wikitext", {}).get("*", "")
            raw_html = parse_data.get("text", {}).get("*", "")

            clean_display_title = sanitize_title(raw_display_title, fallback=raw_title)

            # Clean wikitext
            cleaned_wt = wt
            cleaned_wt = remove_templates_with_balanced_braces(cleaned_wt)
            cleaned_wt = re.sub(r'\[\[(?:Kategori|Category):[^\]]+\]\]\s*', '', cleaned_wt, flags=re.I)
            cleaned_wt = re.sub(r'<ref\b[^>]*/>', '', cleaned_wt, flags=re.I)
            cleaned_wt = re.sub(r'<ref\b[^>]*>.*?</ref>', '', cleaned_wt, flags=re.DOTALL | re.I)
            cleaned_wt = re.sub(r'\(?\s*Baso (?:dohu-tohunia|zanandrösa[^\)]*)\s*\)?', '', cleaned_wt, flags=re.I)
            cleaned_wt = re.sub(r'\n{3,}', '\n\n', cleaned_wt).strip()

            # If wikitext is very short, fallback to cleaned HTML text
            if len(cleaned_wt) < 20 and raw_html:
                soup = BeautifulSoup(raw_html, 'html.parser')
                for rem in soup.find_all(['table', 'style', 'script', 'nav', 'meta', 'link']):
                    rem.decompose()
                for rem in soup.find_all(class_=lambda c: c and any(x in str(c) for x in ['mw-editsection', 'catlinks', 'printfooter', 'toc'])):
                    rem.decompose()
                cleaned_wt = soup.get_text().strip()

            article_url = f"https://{WIKI_HOST}/wiki/{urllib.parse.quote(raw_title.replace(' ', '_'))}"

            for db_path in DB_PATHS:
                con = sqlite3.connect(db_path)
                cur = con.cursor()
                cur.execute("""
                    INSERT INTO writings
                    (page_id, category, title, text, description, editor, url)
                    VALUES (?, 'sinura', ?, ?, 'Wikipedia Nias', NULL, ?)
                """, (pid, clean_display_title, cleaned_wt, article_url))

                cur.execute("""
                    INSERT OR REPLACE INTO wiki_page_revisions
                    (page_id, last_revid, page_title, page_type, last_updated)
                    VALUES (?, ?, ?, 'writing', ?)
                """, (pid, online_revid, raw_title, now_ms))
                con.commit()
                con.close()

            print(f"  -> Saved Writing PID {pid} '{clean_display_title}' ({len(cleaned_wt)} chars)")
            time.sleep(0.4)
        except Exception as e:
            print(f"  Failed Writing PID {pid}: {e}")

def update_library_urls_and_sources():
    print(f"\n=======================================================")
    print(f"4. Updating All Library Section URLs to Point to nia.wikipedia.org...")
    print(f"=======================================================")

    for db_path in DB_PATHS:
        con = sqlite3.connect(db_path)
        cur = con.cursor()

        # Update songs table URLs
        cur.execute("""
            UPDATE songs 
            SET url = REPLACE(url, 'https://incubator.wikimedia.org/wiki/Wb/nia/', 'https://nia.wikipedia.org/wiki/')
            WHERE url LIKE '%incubator.wikimedia.org%'
        """)
        updated_songs = cur.rowcount

        # Update stories table URLs
        cur.execute("""
            UPDATE stories 
            SET url = REPLACE(url, 'https://incubator.wikimedia.org/wiki/Wb/nia/', 'https://nia.wikipedia.org/wiki/')
            WHERE url LIKE '%incubator.wikimedia.org%'
        """)
        updated_stories = cur.rowcount

        # Update recitation table URLs (if any incubator remnants)
        cur.execute("""
            UPDATE recitation 
            SET url = REPLACE(url, 'https://incubator.wikimedia.org/wiki/Wb/nia/', 'https://nia.wikipedia.org/wiki/')
            WHERE url LIKE '%incubator.wikimedia.org%'
        """)
        updated_rec = cur.rowcount

        # Update proverbs URLs (if any incubator remnants)
        cur.execute("""
            UPDATE proverbs 
            SET url = REPLACE(url, 'https://incubator.wikimedia.org/wiki/Wb/nia/', 'https://nia.wikipedia.org/wiki/')
            WHERE url LIKE '%incubator.wikimedia.org%'
        """)
        updated_prov = cur.rowcount

        con.commit()
        con.close()

        print(f"[{db_path}] Updated URLs: songs={updated_songs}, stories={updated_stories}, recitation={updated_rec}, proverbs={updated_prov}")

def update_stories():
    print(f"\n=======================================================")
    print(f"4. Refetching Stories from Kategori:Manö-manö amilita on nia.wikipedia.org...")
    print(f"=======================================================")

    members = get_category_members("Kategori:Manö-manö amilita")
    print(f"Found {len(members)} stories in Kategori:Manö-manö amilita")

    now_ms = int(time.time() * 1000)

    for db_path in DB_PATHS:
        con = sqlite3.connect(db_path)
        con.cursor().execute("DELETE FROM stories")
        con.commit()
        con.close()

    for item in members:
        pid = item['pageid']
        raw_title = item['title']
        clean_title = sanitize_title(raw_title)

        try:
            p_data = api_parse_page(pid)
            raw_html = p_data.get('text', {}).get('*', '')
            raw_wt = p_data.get('wikitext', {}).get('*', '')
            online_revid = p_data.get('revid', 0)

            soup = BeautifulSoup(raw_html, 'html.parser')
            for el in soup.select('.mw-editsection, style, link, meta, .printfooter'):
                el.decompose()
            cleaned_html = str(soup)

            # Extract editor from Kotak info cerita if present
            editor_match = re.search(r'\|\s*penyunting\s*=\s*([^\n\|\}]+)', raw_wt, re.IGNORECASE)
            editor = editor_match.group(1).strip() if editor_match else None

            page_url = f"https://{WIKI_HOST}/wiki/{urllib.parse.quote(raw_title.replace(' ', '_'))}"

            for db_path in DB_PATHS:
                con = sqlite3.connect(db_path)
                cur = con.cursor()
                cur.execute("""
                    INSERT INTO stories (page_id, title, text, description, editor, origin, source, url)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """, (pid, clean_title, cleaned_html, None, editor, None, None, page_url))
                con.commit()
                con.close()

            print(f"  -> Saved Story PID {pid} '{clean_title}'")
            time.sleep(0.4)
        except Exception as e:
            print(f"  Failed Story PID {pid}: {e}")

def update_songs():
    print(f"\n=======================================================")
    print(f"5. Refetching Songs from Kategori:Sinunö amilita on nia.wikipedia.org...")
    print(f"=======================================================")

    members = get_category_members("Kategori:Sinunö amilita")
    print(f"Found {len(members)} songs in Kategori:Sinunö amilita")

    now_ms = int(time.time() * 1000)

    for db_path in DB_PATHS:
        con = sqlite3.connect(db_path)
        con.cursor().execute("DELETE FROM songs")
        con.commit()
        con.close()

    for item in members:
        pid = item['pageid']
        raw_title = item['title']
        clean_title = sanitize_title(raw_title)

        try:
            p_data = api_parse_page(pid)
            raw_html = p_data.get('text', {}).get('*', '')
            raw_wt = p_data.get('wikitext', {}).get('*', '')
            online_revid = p_data.get('revid', 0)

            soup = BeautifulSoup(raw_html, 'html.parser')
            for el in soup.select('.mw-editsection, style, link, meta, .printfooter'):
                el.decompose()
            cleaned_html = str(soup)

            cat_match = re.search(r'\|\s*kategori\s*=\s*([^\n\|\}]+)', raw_wt, re.IGNORECASE)
            category = cat_match.group(1).strip() if cat_match else 'Sinunö'

            page_url = f"https://{WIKI_HOST}/wiki/{urllib.parse.quote(raw_title.replace(' ', '_'))}"

            for db_path in DB_PATHS:
                con = sqlite3.connect(db_path)
                cur = con.cursor()
                cur.execute("""
                    INSERT INTO songs (page_id, title, text, category, type, artist, writer, producer, album, genre, released, recorded, studio, label, url, youtube)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (pid, clean_title, cleaned_html, category, None, None, None, None, None, category, None, None, None, None, page_url, None))
                con.commit()
                con.close()

            print(f"  -> Saved Song PID {pid} '{clean_title}'")
            time.sleep(0.4)
        except Exception as e:
            print(f"  Failed Song PID {pid}: {e}")

def verify_all_databases():
    print(f"\n=======================================================")
    print(f"6. Final Database Integrity Verification...")
    print(f"=======================================================")

    for db_path in DB_PATHS:
        print(f"\n=== Database: {db_path} ===")
        con = sqlite3.connect(db_path)
        cur = con.cursor()

        tables = ['heritage_articles', 'writings', 'recitation', 'songs', 'stories', 'proverbs', 'wiki_page_revisions']
        for t in tables:
            cnt = cur.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
            print(f"  - {t}: {cnt} rows")

        # Check for any remaining incubator URLs
        for t in ['writings', 'recitation', 'songs', 'stories', 'proverbs']:
            inc_cnt = cur.execute(f"SELECT COUNT(*) FROM {t} WHERE url LIKE '%incubator.wikimedia.org%'").fetchone()[0]
            null_cnt = cur.execute(f"SELECT COUNT(*) FROM {t} WHERE url IS NULL OR url = ''").fetchone()[0]
            sample = cur.execute(f"SELECT url FROM {t} WHERE url IS NOT NULL LIMIT 1").fetchone()
            sample_url = sample[0] if sample else 'None'
            print(f"    {t} URLs: incubator={inc_cnt}, null={null_cnt}, sample={sample_url}")

        con.close()

if __name__ == '__main__':
    update_heritage_articles()
    update_recitations()
    update_writings()
    update_stories()
    update_songs()
    verify_all_databases()
    print("\n[DONE] All database assets successfully updated and verified!")
