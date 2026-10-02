import json
import re
import sqlite3
import time
import urllib.request

def clean_title(wikitext, page_title):
    clean_p_title = page_title.replace('Wb/nia/', '').replace('_', ' ').strip()
    # If not a snippet subpage, use page_title directly
    if not clean_p_title.startswith('Wikipedia:Sura amilita/') and not clean_p_title.startswith('Sura amilita/'):
        return clean_p_title

    # 1. {{Baso|...}}
    baso_match = re.search(r'\{\{Baso\|([^}]+)\}\}', wikitext)
    if baso_match:
        return baso_match.group(1).replace('_', ' ').strip()
    # 2. [[Target|Baso...]]
    link_match = re.search(r'\[\[([^|\]]+)\|[\'\"]*Baso', wikitext, re.I)
    if link_match:
        return link_match.group(1).replace('_', ' ').strip()
    # 3. Bold title (allowing internal apostrophes for Nias words)
    bold_match = re.search(r"'''((?:(?!''')[\s\S])+)'''", wikitext)
    if bold_match:
        t = bold_match.group(1)
        t = re.sub(r'\[\[(?:[^|\]]*\|)?([^\]]+)\]\]', r'\1', t).strip()
        return t
    # Fallback to page_title
    return clean_p_title.replace('Wikipedia:Sura amilita/', 'Sura amilita ')

def remove_templates(text):
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

def clean_wikitext(wt):
    # Remove category tags
    wt = re.sub(r'\[\[(?:Kategori|Category):[^\]]+\]\]\s*', '', wt, flags=re.I)
    # Remove self-closing refs first to avoid consuming closing tags
    wt = re.sub(r'<ref\b[^>]*/>', '', wt, flags=re.I)
    # Remove paired ref tags
    wt = re.sub(r'<ref\b[^>]*>.*?</ref>', '', wt, flags=re.DOTALL | re.I)
    # Remove templates {{...}} including multi-line nested infoboxes
    wt = remove_templates(wt)
    # Remove (Baso dohu-tohunia...) or (Baso zanandrösa...)
    wt = re.sub(r'\(?\s*Baso (?:dohu-tohunia|zanandrösa[^\)]*)\s*\)?', '', wt, flags=re.I)
    # Normalize excessive newlines
    wt = re.sub(r'\n{3,}', '\n\n', wt)
    return wt.strip()

def main():
    print("Fetching category members with wikitext from nia.wikipedia.org...")
    url = 'https://nia.wikipedia.org/w/api.php?action=query&generator=categorymembers&gcmtitle=Kategori:Sura_amilita&gcmlimit=50&prop=revisions&rvprop=content|ids&format=json'
    req = urllib.request.Request(url, headers={'User-Agent': 'NiasHeritageBot/1.0 (https://github.com/niasheritage; contact@niasheritage.org)'})
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))
    
    pages = data.get('query', {}).get('pages', {})
    print(f"Found {len(pages)} pages in Kategori:Sura amilita")
    
    parsed_articles = []
    for pid_str, page_info in pages.items():
        page_id = int(pid_str)
        page_title = page_info['title']
        rev = page_info['revisions'][0]
        revid = rev['revid']
        wikitext = rev.get('*', '')
        
        title = clean_title(wikitext, page_title)
        text_content = clean_wikitext(wikitext)
        
        parsed_articles.append({
            'page_id': page_id,
            'page_title': page_title,
            'revid': revid,
            'title': title,
            'text': text_content,
        })

    print(f"\nParsed {len(parsed_articles)} articles successfully.")

    # Insert into SQLite databases
    now_ts = int(time.time() * 1000)
    for db_path in ['assets/niasheritage.sqlite', 'niasheritage.sqlite']:
        print(f"\nWriting to {db_path}...")
        conn = sqlite3.connect(db_path)
        cur = conn.cursor()
        
        # Delete existing featured articles if any
        cur.execute("DELETE FROM writings WHERE category = 'featured'")
        
        for a in parsed_articles:
            cur.execute("""
                INSERT INTO writings (page_id, category, title, text, description, editor)
                VALUES (?, 'featured', ?, ?, 'Wikipedia Nias', NULL)
            """, (a['page_id'], a['title'], a['text']))
            
            cur.execute("""
                INSERT INTO wiki_page_revisions (page_id, last_revid, page_title, page_type, last_updated)
                VALUES (?, ?, ?, 'featured_article', ?)
                ON CONFLICT(page_id) DO UPDATE SET
                    last_revid=excluded.last_revid,
                    page_title=excluded.page_title,
                    page_type=excluded.page_type,
                    last_updated=excluded.last_updated
            """, (a['page_id'], a['revid'], a['page_title'], now_ts))
            
        conn.commit()
        cur.execute("SELECT count(*) FROM writings WHERE category = 'featured'")
        print(f"Total featured articles in {db_path}: {cur.fetchone()[0]}")
        cur.execute("SELECT count(*) FROM wiki_page_revisions WHERE page_type = 'featured_article'")
        print(f"Total featured_article revisions in {db_path}: {cur.fetchone()[0]}")
        conn.close()

if __name__ == '__main__':
    main()
