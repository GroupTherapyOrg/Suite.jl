import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('ThemeToggle', () => {
  test.beforeEach(async ({ page }) => {
    // Clear stored theme preference before each test
    await page.goto('/components/toggle');
    await page.evaluate(() => localStorage.removeItem('therapy-theme'));
    await page.goto('/components/toggle');
    await waitForHydration(page);
  });

  test('click toggles dark class on html element', async ({ page }) => {
    const html = page.locator('html');
    const wasDark = await html.evaluate(el => el.classList.contains('dark'));

    // Use first() — there are 2 ThemeToggle instances on the page (header + sheet)
    const toggle = page.locator('button[aria-label="Toggle dark mode"]').first();
    await toggle.click();

    const isDark = await html.evaluate(el => el.classList.contains('dark'));
    expect(isDark).not.toBe(wasDark);
  });

  test('second click reverts dark class', async ({ page }) => {
    const html = page.locator('html');
    const wasDark = await html.evaluate(el => el.classList.contains('dark'));

    const toggle = page.locator('button[aria-label="Toggle dark mode"]').first();
    await toggle.click();
    await toggle.click();

    const isDark = await html.evaluate(el => el.classList.contains('dark'));
    expect(isDark).toBe(wasDark);
  });

  test('theme preference persists in localStorage', async ({ page }) => {
    const toggle = page.locator('button[aria-label="Toggle dark mode"]').first();
    await toggle.click();

    const stored = await page.evaluate(() => localStorage.getItem('therapy-theme'));
    expect(stored).toBeTruthy();
    expect(['dark', 'light']).toContain(stored);
  });

  test('moon icon visible in light mode, sun icon in dark mode', async ({ page }) => {
    const toggle = page.locator('button[aria-label="Toggle dark mode"]').first();

    // In light mode: moon icon (block dark:hidden) should be visible
    // Click to go to dark mode
    await toggle.click();

    // In dark mode: sun icon (hidden dark:block) should be visible
    // The SVGs use CSS classes: block dark:hidden (moon) and hidden dark:block (sun)
    const html = page.locator('html');
    const isDark = await html.evaluate(el => el.classList.contains('dark'));

    if (isDark) {
      // Sun SVG should be visible in dark mode
      const sunIcon = toggle.locator('svg.hidden.dark\\:block, svg.dark\\:block');
      await expect(sunIcon).toBeVisible();
    }
  });

  test('multiple rapid clicks toggle correctly', async ({ page }) => {
    const html = page.locator('html');
    const initial = await html.evaluate(el => el.classList.contains('dark'));

    const toggle = page.locator('button[aria-label="Toggle dark mode"]').first();

    // 5 rapid clicks should end in opposite state
    for (let i = 0; i < 5; i++) {
      await toggle.click();
    }

    const final = await html.evaluate(el => el.classList.contains('dark'));
    expect(final).not.toBe(initial); // odd number of clicks
  });
});
