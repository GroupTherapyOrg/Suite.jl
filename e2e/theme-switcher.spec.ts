import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('ThemeSwitcher', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/toggle');
    await page.evaluate(() => localStorage.removeItem('suite-active-theme'));
    await page.goto('/components/toggle');
    await waitForHydration(page);
  });

  test('click trigger opens theme dropdown', async ({ page }) => {
    const trigger = page.locator('button[aria-label="Switch theme"]').first();
    await trigger.click();

    const content = page.locator('[data-theme-switcher-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });

  test('trigger aria-expanded updates to true when open', async ({ page }) => {
    const trigger = page.locator('button[aria-label="Switch theme"]').first();
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');

    await trigger.click();

    await expect(trigger).toHaveAttribute('aria-expanded', 'true', { timeout: 5000 });
  });

  test('dropdown has role=menu and theme options have role=menuitem', async ({ page }) => {
    const trigger = page.locator('button[aria-label="Switch theme"]').first();
    await trigger.click();

    const content = page.locator('[data-theme-switcher-content]').first();
    await expect(content).toHaveAttribute('role', 'menu');

    const options = content.locator('[role="menuitem"]');
    const count = await options.count();
    expect(count).toBeGreaterThanOrEqual(4); // default, ocean, minimal, nature (possibly islands)
  });

  test('selecting a theme changes data-theme on html element', async ({ page }) => {
    const trigger = page.locator('button[aria-label="Switch theme"]').first();
    await trigger.click();

    // Click the "ocean" theme option
    const oceanOption = page.locator('[data-theme-option="ocean"]').first();
    await expect(oceanOption).toBeVisible({ timeout: 5000 });
    await oceanOption.click();

    // html element should have data-theme="ocean"
    const html = page.locator('html');
    await expect(html).toHaveAttribute('data-theme', 'ocean', { timeout: 3000 });
  });

  test('theme selection persists in localStorage', async ({ page }) => {
    const trigger = page.locator('button[aria-label="Switch theme"]').first();
    await trigger.click();

    const oceanOption = page.locator('[data-theme-option="ocean"]').first();
    await expect(oceanOption).toBeVisible({ timeout: 5000 });
    await oceanOption.click();

    const stored = await page.evaluate(() => localStorage.getItem('suite-active-theme'));
    expect(stored).toBe('ocean');
  });

  test('second trigger click closes dropdown', async ({ page }) => {
    const trigger = page.locator('button[aria-label="Switch theme"]').first();

    // Open
    await trigger.click();
    const content = page.locator('[data-theme-switcher-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    // Close
    await trigger.click();
    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('dropdown data-state updates to open on trigger click', async ({ page }) => {
    const trigger = page.locator('button[aria-label="Switch theme"]').first();
    const content = page.locator('[data-theme-switcher-content]').first();

    await expect(content).toHaveAttribute('data-state', 'closed');

    await trigger.click();

    await expect(content).toHaveAttribute('data-state', 'open', { timeout: 5000 });
  });

  test('all themes are selectable', async ({ page }) => {
    const themes = ['default', 'ocean', 'minimal', 'nature'];
    const trigger = page.locator('button[aria-label="Switch theme"]').first();

    for (const theme of themes) {
      await trigger.click();
      const option = page.locator(`[data-theme-option="${theme}"]`).first();
      await expect(option).toBeVisible({ timeout: 5000 });
      await option.click();

      if (theme === 'default') {
        // Default theme may not set data-theme or sets it to "default"
        const dataTheme = await page.locator('html').getAttribute('data-theme');
        expect(!dataTheme || dataTheme === 'default').toBeTruthy();
      } else {
        await expect(page.locator('html')).toHaveAttribute('data-theme', theme, { timeout: 3000 });
      }
    }
  });
});
