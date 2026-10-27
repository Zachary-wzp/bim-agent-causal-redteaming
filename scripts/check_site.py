#!/usr/bin/env python3
"""Check static output, including the project-site baseurl and local anchors."""
import argparse
import re
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit


class Document(HTMLParser):
    def __init__(self, text):
        super().__init__()
        self.links, self.ids, self.h1 = [], set(), 0
        self.feed(text)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if 'id' in attrs:
            assert attrs['id'] not in self.ids, f"Duplicate id {attrs['id']}"
            self.ids.add(attrs['id'])
        self.h1 += tag == 'h1'
        for key in ('href', 'src'):
            if attrs.get(key):
                self.links.append(attrs[key])
        if tag == 'img':
            assert attrs.get('alt', '').strip(), 'Image lacks meaningful alt'


def check(root, base):
    paths = list(root.rglob('*.html'))
    assert paths, 'No generated HTML'
    docs = {p: Document(p.read_text()) for p in paths}
    for route in ('', 'platform', 'cases', 'statistics', 'progress', 'resources'):
        assert root.joinpath(route, 'index.html').is_file(), f'Missing page {route}'
    for path, doc in docs.items():
        assert doc.h1 == 1, f'{path}: expected one h1, got {doc.h1}'
        for link in doc.links:
            parsed = urlsplit(link)
            if parsed.scheme or parsed.netloc:
                assert parsed.scheme == 'https', f'Unsafe or unexpected URL {link}'
                continue
            if parsed.path:
                assert parsed.path.startswith(base + '/'), f'{path}: baseurl mismatch {link}'
                relative = unquote(parsed.path[len(base):]).lstrip('/')
                target = root / relative
                if parsed.path.endswith('/'):
                    target /= 'index.html'
                assert target.is_file(), f'{path}: broken local link {link}'
            else:
                target = path
            if parsed.fragment and target in docs:
                assert unquote(parsed.fragment) in docs[target].ids, f'{path}: broken anchor {link}'
    forbidden = ['README.md', 'docs', 'scripts', 'tests', 'Gemfile', 'Gemfile.lock', 'vendor', '.github', '_cases', '_updates']
    for name in forbidden:
        assert not (root / name).exists(), f'Development/private source leaked: {name}'
    assert not list(root.glob('*Execution_Plan*')), 'Execution plan leaked into public output'
    print(f'Static output checks passed: {len(paths)} HTML pages; baseurl={base or "/"}.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('root', nargs='?', default='_site')
    parser.add_argument('--baseurl', default='/bim-agent-causal-redteaming')
    args = parser.parse_args()
    check(Path(args.root).resolve(), args.baseurl.rstrip('/'))
