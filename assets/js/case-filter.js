(() => {
  const explorer = document.querySelector('[data-case-explorer]');
  if (!explorer) return;
  const form = explorer.querySelector('[data-filters]');
  const cards = Array.from(explorer.querySelectorAll('[data-case]'));
  const selects = Array.from(form.querySelectorAll('select'));
  const search = form.querySelector('input[type="search"]');
  const count = explorer.querySelector('[data-result-count]');
  const empty = explorer.querySelector('[data-no-results]');
  const labels = {
    over_collection: 'Over collection', direct_exposure: 'Direct exposure',
    indirect_exposure: 'Indirect exposure', unknown: 'Unknown',
    leakage_observed: 'Leakage observed', no_leakage_observed: 'No leakage observed',
    inconclusive: 'Inconclusive'
  };
  selects.forEach((select) => {
    const values = [...new Set(cards.map((card) => card.getAttribute(`data-${select.name}`)))].sort();
    values.forEach((value) => {
      const option = document.createElement('option');
      option.value = value;
      option.textContent = labels[value] || value;
      select.append(option);
    });
  });
  const apply = () => {
    const query = search.value.trim().toLocaleLowerCase();
    let visible = 0;
    cards.forEach((card) => {
      const text = `${card.dataset.caseId} ${card.dataset.title}`.toLocaleLowerCase();
      const matches = text.includes(query) && selects.every((select) => !select.value || card.getAttribute(`data-${select.name}`) === select.value);
      card.hidden = !matches;
      if (matches) visible++;
    });
    count.textContent = `${visible} of ${cards.length} Published Cases`;
    empty.hidden = visible !== 0 || cards.length === 0;
  };
  form.addEventListener('submit', (event) => event.preventDefault());
  form.addEventListener('input', apply);
  form.addEventListener('change', apply);
  form.addEventListener('reset', () => { setTimeout(apply, 0); });
  form.hidden = false;
  apply();
})();
