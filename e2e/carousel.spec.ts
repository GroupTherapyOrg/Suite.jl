import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Carousel', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./components/carousel');
    await waitForHydration(page);
  });

  // Helper: get the first carousel island
  function firstCarousel(page: any) {
    return page.locator('therapy-island[data-component="carousel"]').first();
  }

  test('renders as therapy-island with data-component=carousel', async ({ page }) => {
    const carousel = firstCarousel(page);
    await expect(carousel).toBeVisible();
    await expect(carousel).toHaveAttribute('data-component', 'carousel');
  });

  test('first slide starts with data-state=open', async ({ page }) => {
    const carousel = firstCarousel(page);
    const slides = carousel.locator('[data-carousel-item]');

    await expect(slides.first()).toHaveAttribute('data-state', 'open');
    await expect(slides.first()).toBeVisible();
  });

  test('second slide starts with data-state=closed and is hidden', async ({ page }) => {
    const carousel = firstCarousel(page);
    const slides = carousel.locator('[data-carousel-item]');

    await expect(slides.nth(1)).toHaveAttribute('data-state', 'closed');
    await expect(slides.nth(1)).not.toBeVisible();
  });

  test('slides have correct data-index attributes', async ({ page }) => {
    const carousel = firstCarousel(page);
    const slides = carousel.locator('[data-carousel-item]');

    await expect(slides.nth(0)).toHaveAttribute('data-index', '0');
    await expect(slides.nth(1)).toHaveAttribute('data-index', '1');
    await expect(slides.nth(2)).toHaveAttribute('data-index', '2');
  });

  test('nav buttons have data-index 100 and 101', async ({ page }) => {
    const carousel = firstCarousel(page);
    const prev = carousel.locator('[data-carousel-prev]');
    const next = carousel.locator('[data-carousel-next]');

    await expect(prev).toHaveAttribute('data-index', '100');
    await expect(next).toHaveAttribute('data-index', '101');
  });

  test('clicking next button advances to slide 2', async ({ page }) => {
    const carousel = firstCarousel(page);
    const slides = carousel.locator('[data-carousel-item]');
    const next = carousel.locator('[data-carousel-next]');

    // Initially slide 0 is open
    await expect(slides.nth(0)).toHaveAttribute('data-state', 'open');
    await expect(slides.nth(1)).toHaveAttribute('data-state', 'closed');

    // Click next
    await next.click();

    // Slide 1 should now be open, slide 0 closed
    await expect(slides.nth(0)).toHaveAttribute('data-state', 'closed');
    await expect(slides.nth(1)).toHaveAttribute('data-state', 'open');
  });

  test('clicking prev button from slide 2 goes back to slide 1', async ({ page }) => {
    const carousel = firstCarousel(page);
    const slides = carousel.locator('[data-carousel-item]');
    const next = carousel.locator('[data-carousel-next]');
    const prev = carousel.locator('[data-carousel-prev]');

    // Go to slide 2
    await next.click();
    await expect(slides.nth(1)).toHaveAttribute('data-state', 'open');

    // Click prev
    await prev.click();
    await expect(slides.nth(0)).toHaveAttribute('data-state', 'open');
    await expect(slides.nth(1)).toHaveAttribute('data-state', 'closed');
  });

  test('clicking next multiple times advances through slides', async ({ page }) => {
    const carousel = firstCarousel(page);
    const slides = carousel.locator('[data-carousel-item]');
    const next = carousel.locator('[data-carousel-next]');

    // Click next twice → slide 2 (index 2)
    await next.click();
    await next.click();

    await expect(slides.nth(0)).toHaveAttribute('data-state', 'closed');
    await expect(slides.nth(1)).toHaveAttribute('data-state', 'closed');
    await expect(slides.nth(2)).toHaveAttribute('data-state', 'open');
  });

  test('prev does nothing on first slide (no loop)', async ({ page }) => {
    const carousel = firstCarousel(page);
    const slides = carousel.locator('[data-carousel-item]');
    const prev = carousel.locator('[data-carousel-prev]');

    // Already on first slide, click prev
    await prev.click();

    // Should still be on first slide (clamped)
    await expect(slides.nth(0)).toHaveAttribute('data-state', 'open');
  });

  test('next does nothing on last slide (no loop)', async ({ page }) => {
    const carousel = firstCarousel(page);
    const slides = carousel.locator('[data-carousel-item]');
    const next = carousel.locator('[data-carousel-next]');

    // Go to last slide
    await next.click();
    await next.click();
    await expect(slides.nth(2)).toHaveAttribute('data-state', 'open');

    // Click next again — should stay on last slide
    await next.click();
    await expect(slides.nth(2)).toHaveAttribute('data-state', 'open');
  });

  test.describe('Loop mode', () => {
    // The third carousel on the page has loop=true
    function loopCarousel(page: any) {
      return page.locator('therapy-island[data-component="carousel"]').nth(2);
    }

    test('next wraps from last to first slide', async ({ page }) => {
      const carousel = loopCarousel(page);
      const slides = carousel.locator('[data-carousel-item]');
      const next = carousel.locator('[data-carousel-next]');

      // Go to last slide
      await next.click();
      await next.click();
      await expect(slides.nth(2)).toHaveAttribute('data-state', 'open');

      // Click next — should wrap to first
      await next.click();
      await expect(slides.nth(0)).toHaveAttribute('data-state', 'open');
    });

    test('prev wraps from first to last slide', async ({ page }) => {
      const carousel = loopCarousel(page);
      const slides = carousel.locator('[data-carousel-item]');
      const prev = carousel.locator('[data-carousel-prev]');

      // On first slide, click prev — should wrap to last
      await prev.click();
      await expect(slides.nth(2)).toHaveAttribute('data-state', 'open');
    });
  });
});
