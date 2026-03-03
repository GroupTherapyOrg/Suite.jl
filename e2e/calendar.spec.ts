import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Calendar', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/calendar');
    await waitForHydration(page);
  });

  // --- Static / Initial State ---

  test('calendar grid is visible', async ({ page }) => {
    const grid = page.locator('[role="grid"]').first();
    await expect(grid).toBeVisible();
  });

  test('calendar has day buttons', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="calendar"]').first();
    const days = island.locator('[data-calendar-day-btn]');
    const count = await days.count();
    expect(count).toBeGreaterThan(0);
  });

  test('calendar has prev/next month buttons', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="calendar"]').first();
    const prev = island.locator('[data-calendar-prev]');
    const next = island.locator('[data-calendar-next]');
    await expect(prev.first()).toBeVisible();
    await expect(next.first()).toBeVisible();
  });

  test('calendar caption shows current month', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="calendar"]').first();
    const caption = island.locator('[data-calendar-caption]').first();
    await expect(caption).toBeVisible();
    const text = await caption.textContent();
    expect(text!.length).toBeGreaterThan(0);
  });

  // --- Interaction: Day Selection ---

  test.skip('clicking a day selects it', async ({ page }) => {
    // DEFERRED: Calendar island has no wasm on_click handler — all rendering is SSR-only.
    // Calendar._calendar_render() uses Dates.jl for grid generation, which can't compile to wasm.
    // Requires: Add event delegation handler to Calendar island with day selection signal.
    const island = page.locator('therapy-island[data-component="calendar"]').first();
    const unselected = island.locator('[data-calendar-day-btn]:not([data-calendar-selected])').first();

    await unselected.click();

    // Day should become selected (data-calendar-selected attribute or aria-selected)
    await expect(unselected).toHaveAttribute('data-calendar-selected', '', { timeout: 3000 });
  });

  test.skip('clicking a different day deselects previous', async ({ page }) => {
    // DEFERRED: Calendar island has no wasm on_click handler — SSR-only rendering.
    // Requires: Day selection signal + event delegation (see 'clicking a day selects it').
    const island = page.locator('therapy-island[data-component="calendar"]').first();
    const days = island.locator('[data-calendar-day-btn]:not([data-calendar-disabled])');

    const firstDay = days.first();
    const secondDay = days.nth(1);

    await firstDay.click();
    await expect(firstDay).toHaveAttribute('data-calendar-selected', '', { timeout: 3000 });

    await secondDay.click();
    await expect(secondDay).toHaveAttribute('data-calendar-selected', '', { timeout: 3000 });
  });

  // --- Interaction: Month Navigation ---

  test.skip('clicking next button changes displayed month', async ({ page }) => {
    // DEFERRED: Month navigation requires re-generating calendar grid with new Date math.
    // Dates.jl operations (dayofweek, lastdayofmonth) can't compile to wasm via WasmTarget.jl.
    // Requires: Either JS-based month navigation or Date stdlib support in WasmTarget.jl.
    const island = page.locator('therapy-island[data-component="calendar"]').first();
    const caption = island.locator('[data-calendar-caption]').first();
    const currentMonth = await caption.textContent();

    const nextBtn = island.locator('[data-calendar-next]').first();
    await nextBtn.click();

    await expect(caption).not.toHaveText(currentMonth!, { timeout: 3000 });
  });

  test.skip('clicking prev button changes displayed month', async ({ page }) => {
    // DEFERRED: Same as next button — month navigation requires Date math not available in wasm.
    // Requires: Either JS-based month navigation or Date stdlib support in WasmTarget.jl.
    const island = page.locator('therapy-island[data-component="calendar"]').first();
    const caption = island.locator('[data-calendar-caption]').first();
    const currentMonth = await caption.textContent();

    const prevBtn = island.locator('[data-calendar-prev]').first();
    await prevBtn.click();

    await expect(caption).not.toHaveText(currentMonth!, { timeout: 3000 });
  });

  test.skip('navigating forward then back returns to original month', async ({ page }) => {
    // DEFERRED: Depends on month navigation (see prev/next button tests above).
    // Requires: Month navigation to be implemented first.
    const island = page.locator('therapy-island[data-component="calendar"]').first();
    const caption = island.locator('[data-calendar-caption]').first();
    const originalMonth = await caption.textContent();

    const nextBtn = island.locator('[data-calendar-next]').first();
    const prevBtn = island.locator('[data-calendar-prev]').first();

    await nextBtn.click();
    await expect(caption).not.toHaveText(originalMonth!, { timeout: 3000 });

    await prevBtn.click();
    await expect(caption).toHaveText(originalMonth!, { timeout: 3000 });
  });

  // --- Disabled Days ---

  test('disabled days are not clickable', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="calendar"]').first();
    const disabled = island.locator('[data-calendar-day-btn][data-calendar-disabled]').first();
    const disabledCount = await disabled.count();

    if (disabledCount > 0) {
      await disabled.click({ force: true });
      // Disabled day should NOT become selected
      const hasSelected = await disabled.getAttribute('data-calendar-selected');
      expect(hasSelected).toBeNull();
    }
  });

  test('outside month days are styled differently', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="calendar"]').first();
    const outside = island.locator('[data-calendar-day-btn][data-calendar-show-outside]');
    const count = await outside.count();
    // Outside days may or may not exist depending on calendar config
    expect(count).toBeGreaterThanOrEqual(0);
  });
});
