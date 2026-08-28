(() => {
  const shots = Array.from(document.querySelectorAll('.phone-shot'));
  const dots = Array.from(document.querySelectorAll('[data-phone-index]'));
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  let activeIndex = 0;
  let cycleTimer;

  function showPhoneScreen(index) {
    activeIndex = index;
    shots.forEach((shot, shotIndex) => shot.classList.toggle('is-active', shotIndex === index));
    dots.forEach((dot, dotIndex) => {
      const isActive = dotIndex === index;
      dot.classList.toggle('is-active', isActive);
      dot.setAttribute('aria-pressed', String(isActive));
    });
  }

  function startCycle() {
    if (prefersReducedMotion || shots.length < 2) return;
    window.clearInterval(cycleTimer);
    cycleTimer = window.setInterval(() => showPhoneScreen((activeIndex + 1) % shots.length), 4200);
  }

  dots.forEach((dot) => {
    dot.addEventListener('click', () => {
      showPhoneScreen(Number(dot.dataset.phoneIndex));
      startCycle();
    });
  });

  showPhoneScreen(0);
  startCycle();
})();
