import json
import urllib.parse
import urllib.request

USER_AGENT = 'NiasHeritage/1.0 (https://github.com/sslaia/niasheritage; contact@example.com)'
STANDARD_SIZES = [1280, 960, 500, 330]

def clean_url(url: str) -> str:
    return url.split('?')[0] if url else ''

def main():
    json_path = 'assets/data/gallery.json'
    with open(json_path, 'r', encoding='utf-8') as f:
        gallery_data = json.load(f)

    all_files = set()
    for lang, categories in gallery_data.items():
        for cat, items in categories.items():
            for item in items:
                fn = item.get('fileName', '')
                if fn:
                    if not fn.startswith('File:'):
                        fn = 'File:' + fn
                    all_files.add(fn)

    unique_files = sorted(list(all_files))
    print(f'Total unique files to resolve: {len(unique_files)}')

    # 1. Fetch image dimensions via single batch query
    print('Fetching image sizes from Wikimedia Commons...')
    query_titles = '|'.join(urllib.parse.quote(t) for t in unique_files)
    size_url = f'https://commons.wikimedia.org/w/api.php?action=query&prop=imageinfo&iiprop=size&titles={query_titles}&format=json'
    req = urllib.request.Request(size_url, headers={'User-Agent': USER_AGENT})
    with urllib.request.urlopen(req) as resp:
        size_res = json.load(resp)

    normalized = {n['to']: n['from'] for n in size_res.get('query', {}).get('normalized', [])}
    sizes = {}
    for p in size_res['query']['pages'].values():
        title = p['title']
        orig_t = normalized.get(title, title)
        ii = p['imageinfo'][0]
        sizes[orig_t] = (ii['width'], ii['height'])
        sizes[title] = (ii['width'], ii['height'])

    # 2. Batch query URLs for each Wikimedia standard thumbnail step
    print('Fetching URLs for standard thumbnail steps (330, 500, 960, 1280)...')
    urls_by_width = {}
    for w in [330, 500, 960, 1280]:
        q_url = f'https://commons.wikimedia.org/w/api.php?action=query&prop=imageinfo&iiprop=url&iiurlwidth={w}&titles={query_titles}&format=json'
        r = urllib.request.Request(q_url, headers={'User-Agent': USER_AGENT})
        with urllib.request.urlopen(r) as resp:
            d_res = json.load(resp)
        w_map = {}
        for p in d_res['query']['pages'].values():
            title = p['title']
            orig_t = normalized.get(title, title)
            thumb = p['imageinfo'][0].get('thumburl', '')
            # Only keep URLs that are strictly on thumb.wikimedia.org (never unscaled raw upload.wikimedia.org)
            if 'thumb.wikimedia.org' in thumb:
                clean = clean_url(thumb)
                w_map[orig_t] = clean
                w_map[title] = clean
                if orig_t.startswith('File:'):
                    w_map[orig_t[5:]] = clean
                if title.startswith('File:'):
                    w_map[title[5:]] = clean
        urls_by_width[w] = w_map

    # 3. Resolve compliant thumbnail and highres URLs
    resolved_thumbs = {}
    resolved_highres = {}
    for fn in unique_files:
        w, h = sizes[fn]
        
        # Thumbnail: 330 if original < 500, else 500
        tw = 330 if w < 500 else 500
        t_url = urls_by_width[tw].get(fn)
        if not t_url:
            t_url = urls_by_width[330].get(fn)
        resolved_thumbs[fn] = t_url

        # Highres: largest standard size <= w that is on thumb.wikimedia.org
        h_url = None
        for hw in STANDARD_SIZES:
            if w >= hw and fn in urls_by_width[hw]:
                h_url = urls_by_width[hw][fn]
                break
        if not h_url:
            h_url = t_url
        resolved_highres[fn] = h_url

    # 4. Update gallery.json
    matched = 0
    total = 0
    for lang, categories in gallery_data.items():
        for cat, items in categories.items():
            for item in items:
                total += 1
                fn = item.get('fileName', '')
                full_fn = fn if fn.startswith('File:') else 'File:' + fn

                t = resolved_thumbs.get(fn) or resolved_thumbs.get(full_fn)
                h = resolved_highres.get(fn) or resolved_highres.get(full_fn)

                if t and h:
                    item['thumbnailUrl'] = t
                    item['imageUrl'] = h
                    matched += 1
                else:
                    print(f'Warning: Could not resolve URLs for {fn}')

    print(f'Successfully updated {matched} / {total} items across all languages.')
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(gallery_data, f, indent=2, ensure_ascii=False)
    print(f'Saved updated {json_path}.')

if __name__ == '__main__':
    main()
