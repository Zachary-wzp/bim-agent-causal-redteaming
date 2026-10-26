(() => {
  const toggle = document.querySelector('.nav-toggle');
  const nav = document.querySelector('.primary-nav');
  if (toggle && nav) {
    toggle.hidden = false;
    nav.classList.add('enhanced');
    toggle.addEventListener('click', () => {
      const open = toggle.getAttribute('aria-expanded') !== 'true';
      toggle.setAttribute('aria-expanded', String(open));
      nav.classList.toggle('open', open);
    });
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && toggle.getAttribute('aria-expanded') === 'true') {
        toggle.setAttribute('aria-expanded', 'false');
        nav.classList.remove('open');
        toggle.focus();
      }
    });
  }
  document.querySelectorAll('[data-next-highlight]').forEach((button) => {
    const target = document.getElementById(button.dataset.nextHighlight);
    const groups = new Map();
    target.querySelectorAll('.protected-fact').forEach((mark) => {
      const key = mark.dataset.highlightIndex;
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key).push(mark);
    });
    const passages = Array.from(groups.values());
    if (!passages.length) return;
    const status = button.parentElement.querySelector('.copy-status');
    let current = -1;
    button.hidden = false;
    button.addEventListener('click', () => {
      if (current >= 0) passages[current].forEach(mark => mark.classList.remove('is-current'));
      current = (current + 1) % passages.length;
      passages[current].forEach(mark => mark.classList.add('is-current'));
      passages[current][0].scrollIntoView({ block: 'center', inline: 'nearest' });
      status.textContent = `Highlighted passage ${current + 1} of ${passages.length}.`;
    });
  });
  document.querySelectorAll('[data-copy]').forEach((button) => {
    button.hidden = false;
    button.addEventListener('click', async () => {
      const target = document.getElementById(button.dataset.copy);
      const status = button.parentElement.querySelector('.copy-status');
      try {
        await navigator.clipboard.writeText(target.textContent);
        status.textContent = 'Copied to clipboard.';
      } catch {
        const source = target.closest('details');
        if (source) source.open = true;
        target.focus({ preventScroll: true });
        target.scrollIntoView({ block: 'nearest' });
        const selection = window.getSelection();
        const range = document.createRange();
        range.selectNodeContents(target);
        selection.removeAllRanges();
        selection.addRange(range);
        status.textContent = 'Copy unavailable. Text selected; use your device’s copy command.';
      }
    });
  });
})();
