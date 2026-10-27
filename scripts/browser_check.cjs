// Optional development-only browser QA. No Node dependencies are used by the site.
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const { execFileSync } = require('node:child_process');
const root = path.resolve(process.argv[2] || '_site');
const fixtures = process.argv.includes('--fixtures');
// Read the website's approved records so QA also works as the collection grows.
const records = fixtures ? [] : JSON.parse(execFileSync('ruby', ['-rdate', '-ryaml', '-rjson', '-e', `
  puts Dir.glob(File.join(ARGV[0], '_cases', '*.md')).filter_map { |file|
    text = File.read(file, encoding: 'UTF-8')
    data = YAML.safe_load(text.match(/\\A---\\r?\\n(.*?)\\r?\\n---/m)[1], permitted_classes: [Date])
    next unless data['published'] == true && data['approved_for_publication'] == true
    data.merge('slug' => File.basename(file, '.md'))
  }.to_json
`, path.resolve(__dirname, '..')], { encoding: 'utf8', maxBuffer: 8 * 1024 * 1024 }));
const expectedCount = fixtures ? 2 : records.length;
const base = '/bim-agent-sensitive-information';
const mime = { '.html': 'text/html', '.css': 'text/css', '.js': 'text/javascript', '.svg': 'image/svg+xml', '.png': 'image/png' };
const server = http.createServer((req, res) => {
  const url = new URL(req.url, 'http://localhost');
  if (!url.pathname.startsWith(base + '/')) { res.writeHead(404).end(); return; }
  let file = path.resolve(root, '.' + decodeURIComponent(url.pathname.slice(base.length)));
  if (file !== root && !file.startsWith(root + path.sep)) { res.writeHead(403).end(); return; }
  if (url.pathname.endsWith('/')) file = path.join(file, 'index.html');
  if (!fs.existsSync(file)) { res.writeHead(404).end(); return; }
  res.setHeader('Content-Type', mime[path.extname(file)] || 'application/octet-stream');
  fs.createReadStream(file).pipe(res);
});

(async () => {
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  const origin = `http://127.0.0.1:${server.address().port}`;
  const browser = await chromium.launch({ headless: true });
  let checks = 0;
  try {
    const context = await browser.newContext({ permissions: ['clipboard-read', 'clipboard-write'] });
    const page = await context.newPage();
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    page.on('response', response => { if (response.status() >= 400) errors.push(`${response.status()} ${response.url()}`); });
    if (!fixtures) fs.mkdirSync('.qa/screenshots', { recursive: true });
    for (const width of [360, 768, 1440]) {
      await page.setViewportSize({ width, height: 960 });
      for (const route of ['', 'platform/', 'cases/', 'statistics/', 'progress/', 'resources/']) {
        const response = await page.goto(origin + base + '/' + route);
        assert.equal(response.status(), 200);
        assert.equal(await page.locator('h1').count(), 1);
        assert.equal(await page.evaluate(() => document.documentElement.scrollWidth > innerWidth), false, `${route} overflows at ${width}`);
        if (!fixtures) await page.screenshot({ path: `.qa/screenshots/${route.replace('/', '') || 'home'}-${width}.png`, fullPage: true });
        checks++;
      }
      for (const record of records) {
        const response = await page.goto(`${origin}${base}/cases/${record.slug}/`);
        assert.equal(response.status(), 200);
        assert.equal(await page.locator('h1').textContent(), record.title);
        assert.equal(await page.locator('#adversarial-prompt').textContent(), record.prompt, `${record.case_id}: prompt changed`);
        assert.equal(await page.locator('#agent-output-raw').textContent(), record.agent_output, `${record.case_id}: original output changed`);
        assert.equal(await page.locator('.output-source').getAttribute('open'), null);
        assert.equal(await page.locator('#agent-output h1, #agent-output h2').count(), 0);
        assert.equal(await page.locator('#agent-output script, #agent-output iframe, #agent-output img').count(), 0);
        assert.equal(await page.locator('#agent-output p, #agent-output table, #agent-output ul, #agent-output ol').count() > 0, true);
        if (record.agent_output.match(/^\|?\s*:?-{3,}:?\s*\|/m)) {
          assert.equal(await page.locator('#agent-output table').count() > 0, true, `${record.case_id}: Markdown table missing`);
        }
        for (const table of await page.locator('#agent-output .output-table-scroll').all()) {
          assert.equal(await table.getAttribute('tabindex'), '0');
          assert.equal(await table.locator('th[scope="col"]').count() > 0, true);
        }
        const highlights = record.protected_fact_highlights || [];
        assert.deepEqual(await page.locator('#agent-output mark').allTextContents(), highlights.map(span => span.text));
        if (highlights.length) {
          const style = await page.locator('#agent-output mark').first().evaluate(el => {
            const s = getComputedStyle(el);
            return {color: s.color, background: s.backgroundColor, decoration: s.textDecorationLine};
          });
          assert.equal(style.color, 'rgb(138, 41, 27)');
          assert.equal(style.background, 'rgb(255, 228, 205)');
          assert(style.decoration.includes('underline'));
        }
        assert.equal(await page.evaluate(() => document.documentElement.scrollWidth > innerWidth), false, `${record.case_id} overflows at ${width}`);
        if (record.show_provenance === false) {
          const labels = await page.locator('dt').allTextContents();
          for (const label of ['Evaluation method', 'Public run ID', 'Run date', 'Public evidence reference']) assert(!labels.includes(label));
        }
        if (record.direct_disclosure_count) {
          const outcome = page.locator('section').filter({has: page.getByRole('heading', {name: 'Evaluation Outcome', exact: true})});
          assert((await outcome.textContent()).includes(`${record.direct_disclosure_count} protected fact`));
        }
        if (width === 360 || record.agent_output.length === Math.max(...records.map(r => r.agent_output.length))) {
          await page.screenshot({path: `.qa/screenshots/case-${record.case_id}-${width}.png`, fullPage: true});
        }
        checks++;
      }
    }
    await page.setViewportSize({ width: 360, height: 800 });
    await page.goto(origin + base + '/cases/');
    const toggle = page.getByRole('button', { name: /Menu/ });
    await toggle.focus();
    await page.keyboard.press('Enter');
    assert.equal(await toggle.getAttribute('aria-expanded'), 'true');
    assert.equal(await page.getByRole('navigation').isVisible(), true);
    await page.keyboard.press('Escape');
    assert.equal(await toggle.getAttribute('aria-expanded'), 'false');
    assert.equal(await toggle.evaluate(el => el === document.activeElement), true);
    assert.equal(await toggle.evaluate(el => getComputedStyle(el).outlineStyle), 'solid');
    checks++;
    if (fixtures) {
      assert.equal(await page.locator('[data-case]:visible').count(), 2);
      for (const [name, value] of Object.entries({scenario_id: 'QA-A', requester_role: 'QA role A', attack_strategy: 'QA strategy A', intended_exposure_type: 'direct_exposure', outcome: 'leakage_observed'})) {
        await page.selectOption(`[name="${name}"]`, value);
        assert.equal(await page.locator('[data-case]:visible').count(), 1);
        await page.getByRole('button', { name: 'Reset Filters' }).click();
        await page.waitForFunction(() => document.querySelector('[data-result-count]').textContent === '2 of 2 Published Cases');
        checks++;
      }
      await page.selectOption('[name="scenario_id"]', 'QA-A');
      await page.selectOption('[name="requester_role"]', 'QA role B');
      assert.equal(await page.locator('[data-case]:visible').count(), 0);
      assert.equal(await page.locator('[data-no-results]').isVisible(), true);
      await page.getByRole('button', { name: 'Reset Filters' }).click();
      await page.fill('#case-search', 'qa-002');
      assert.equal(await page.locator('[data-case]:visible').count(), 1);
      await page.fill('#case-search', 'ALPHA');
      assert.equal(await page.locator('[data-case]:visible').count(), 1);
      await page.locator('[data-case]:visible h3 a').click();
      const prompt = await page.locator('#adversarial-prompt').textContent();
      assert(prompt.includes('<script>window.qaInjected = true</script>'));
      assert(prompt.includes('{{ 7 | plus: 8 }}'));
      assert.equal(await page.evaluate(() => window.qaInjected), undefined);
      assert.equal(await page.locator('#adversarial-prompt script').count(), 0);
      assert.equal(await page.evaluate(() => window.qaOutputInjected), undefined);
      assert.equal(await page.locator('#agent-output script').count(), 0);
      assert.equal(await page.locator('#agent-output mark').count(), 2);
      assert.equal(await page.locator('#agent-output mark').first().textContent(), '<&>');
      assert((await page.locator('#agent-output-raw').textContent()).startsWith('😀 <&>\n<script>'));
      assert.equal(await page.evaluate(() => document.documentElement.scrollWidth > innerWidth), false);
      await page.getByRole('button', { name: 'Copy prompt' }).click();
      assert.equal(await page.evaluate(() => navigator.clipboard.readText()), prompt);
      await page.evaluate(() => Object.defineProperty(navigator.clipboard, 'writeText', { value: async () => { throw new Error('denied'); } }));
      await page.getByRole('button', { name: 'Copy output' }).click();
      assert((await page.locator('.copy-status').last().textContent()).includes('Text selected'));
      assert.equal(await page.locator('.output-source').evaluate(el => el.open), true);
      assert.equal(await page.evaluate(() => window.getSelection().toString()), await page.locator('#agent-output-raw').textContent());
      await page.goto(origin + base + '/');
      assert.equal(await page.locator('.update-preview h3').textContent(), 'QA newer snapshot');
      await page.goto(origin + base + '/progress/');
      assert.equal(await page.locator('.history h3').first().textContent(), 'QA newer snapshot');
      await page.goto(origin + base + '/statistics/');
      const figureLink = page.locator('.figure-card > a');
      assert((await figureLink.getAttribute('href')).startsWith(base + '/assets/images/'));
      assert.equal(await page.locator('.figure-card img').evaluate(img => img.complete && img.naturalWidth > 0), true);
      checks += 8;
    } else {
      assert.equal(await page.locator('[data-result-count]').textContent(), `${expectedCount} of ${expectedCount} Published Cases`);
      assert.equal(await page.locator('[data-case]').count(), expectedCount);
      const reset = async () => {
        await page.getByRole('button', {name: 'Reset Filters'}).click();
        await page.waitForFunction(count => document.querySelector('[data-result-count]').textContent === `${count} of ${count} Published Cases`, expectedCount);
      };
      for (const name of ['scenario_id', 'requester_role', 'attack_strategy', 'intended_exposure_type', 'outcome']) {
        for (const value of new Set(records.map(record => record[name]))) {
          await page.selectOption(`[name="${name}"]`, value);
          assert.equal(await page.locator('[data-case]:visible').count(), records.filter(record => record[name] === value).length);
          await reset();
          checks++;
        }
      }
      for (const record of records) {
        await page.fill('#case-search', record.case_id.toLowerCase());
        assert.equal(await page.locator('[data-case]:visible').count(), 1);
        await page.locator('[data-case]:visible h3 a').click();
        const highlights = record.protected_fact_highlights || [];
        if (highlights.length) {
          const next = page.getByRole('button', {name: 'Next highlight', exact: true});
          await next.focus();
          for (let i = 0; i <= highlights.length; i++) {
            await page.keyboard.press('Enter');
            const index = i % highlights.length;
            assert.equal(await page.locator('#agent-output .is-current').textContent(), highlights[index].text);
            assert.equal(await page.locator('.copy-status').last().textContent(), `Highlighted passage ${index + 1} of ${highlights.length}.`);
            assert.equal(await page.locator('#agent-output .is-current').evaluate(el => {
              const r = el.getBoundingClientRect();
              const p = el.closest('.markdown-output').getBoundingClientRect();
              const table = el.closest('.output-table-scroll');
              const t = table ? table.getBoundingClientRect() : p;
              return r.top < p.bottom && r.bottom > p.top && r.left < t.right && r.right > t.left;
            }), true);
          }
          checks++;
        }
        for (const [button, field] of [['Copy prompt', 'prompt'], ['Copy output', 'agent_output']]) {
          await page.getByRole('button', {name: button, exact: true}).click();
          assert.equal(await page.evaluate(() => navigator.clipboard.readText()), record[field]);
        }
        await page.getByText('View original Markdown', {exact: true}).click();
        assert.equal(await page.locator('#agent-output-raw').isVisible(), true);
        assert.equal(await page.locator('#agent-output-raw').textContent(), record.agent_output);
        await page.getByText('View original Markdown', {exact: true}).click();
        await page.goto(`${origin}${base}/cases/`);
        checks++;
      }
      if (records.length) {
        await page.selectOption('[name="scenario_id"]', records[0].scenario_id);
        await page.selectOption('[name="requester_role"]', records[0].requester_role);
        assert.equal(await page.locator('[data-case]:visible').count(), records.filter(r => r.scenario_id === records[0].scenario_id && r.requester_role === records[0].requester_role).length);
        await reset();
        await page.fill('#case-search', 'NO-SUCH-CASE-DOES-NOT-EXIST');
        assert.equal(await page.locator('[data-case]:visible').count(), 0);
        assert.equal(await page.locator('[data-no-results]').isVisible(), true);
        await reset();
        checks++;
      }
      await page.goto(`${origin}${base}/`);
      assert.equal(await page.locator('.research-strip strong').textContent(), String(expectedCount));
      await page.goto(`${origin}${base}/resources/`);
      const dataset = page.locator('.resource').filter({hasText: 'Full Research Dataset on GitHub'});
      assert((await dataset.textContent()).includes('Coming soon'));
      assert.equal(await dataset.locator('a').count(), 0);
      checks++;
    }
    const noJS = await browser.newContext({ javaScriptEnabled: false, viewport: {width: 360, height: 800} });
    const fallback = await noJS.newPage();
    await fallback.goto(origin + base + '/cases/');
    assert.equal(await fallback.getByRole('navigation').isVisible(), true);
    assert.equal(await fallback.locator('[data-filters]').isVisible(), false);
    assert.equal(await fallback.locator('[data-case]:visible').count(), expectedCount);
    if (expectedCount) {
      await fallback.locator('[data-case] h3 a').first().click();
      assert.equal(await fallback.locator('#adversarial-prompt').count(), 1);
      assert.equal(await fallback.locator('#agent-output mark').count(), fixtures ? 2 : (records[0].protected_fact_highlights || []).length);
      assert.equal(await fallback.getByRole('button', {name: 'Next highlight'}).count(), 0);
      assert.equal(await fallback.locator('#agent-output p').count() > 0, true);
      await fallback.getByText('View original Markdown', {exact: true}).click();
      assert.equal(await fallback.locator('#agent-output-raw').isVisible(), true);
    }
    checks++;
    assert.deepEqual(errors, []);
    console.log(`Browser checks passed: ${checks}; 360/768/1440px, navigation, keyboard, no-JS${fixtures ? ', filters, safe Markdown/highlights, exact clipboard fallback, progress ordering, figures' : `, ${records.length} Markdown outputs, original text, highlighted facts/navigation, exact clipboard, all filter values, dataset placeholder`}.`);
  } finally {
    await browser.close();
    server.close();
  }
})().catch(error => { console.error(error); server.close(); process.exitCode = 1; });
