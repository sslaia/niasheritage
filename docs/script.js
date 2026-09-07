(function () {
  const STORAGE_KEY = 'nias_heritage_lang';

  function detectLanguage() {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved === 'id' || saved === 'en') {
      return saved;
    }
    const userLang = (navigator.language || navigator.userLanguage || '').toLowerCase();
    if (userLang.startsWith('id')) {
      return 'id';
    }
    return 'en';
  }

  function setLanguage(lang) {
    document.body.classList.remove('lang-en', 'lang-id');
    document.body.classList.add('lang-' + lang);
    localStorage.setItem(STORAGE_KEY, lang);

    document.querySelectorAll('.lang-btn').forEach(btn => {
      if (btn.getAttribute('data-set-lang') === lang) {
        btn.classList.add('active');
      } else {
        btn.classList.remove('active');
      }
    });
  }

  document.addEventListener('DOMContentLoaded', () => {
    const currentLang = detectLanguage();
    setLanguage(currentLang);

    document.querySelectorAll('.lang-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const lang = btn.getAttribute('data-set-lang');
        if (lang) {
          setLanguage(lang);
        }
      });
    });
  });
})();
