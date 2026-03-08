import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Tabs', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./components/tabs');
    await waitForHydration(page);
  });

  // --- Static / Initial State ---

  test('tab list has role=tablist', async ({ page }) => {
    const tablist = page.locator('[role="tablist"]').first();
    await expect(tablist).toBeVisible();
  });

  test('tab triggers have role=tab', async ({ page }) => {
    const tabs = page.locator('[role="tab"]');
    const count = await tabs.count();
    expect(count).toBeGreaterThan(1);
  });

  test('first tab is active by default', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="tabs"]').first();
    const firstTrigger = island.locator('[data-tabs-trigger]').first();
    await expect(firstTrigger).toHaveAttribute('data-state', 'active');
    await expect(firstTrigger).toHaveAttribute('aria-selected', 'true');
  });

  test('non-active tabs have data-state=inactive', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="tabs"]').first();
    const secondTrigger = island.locator('[data-tabs-trigger]').nth(1);
    await expect(secondTrigger).toHaveAttribute('data-state', 'inactive');
    await expect(secondTrigger).toHaveAttribute('aria-selected', 'false');
  });

  test('active tab content panel is visible', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="tabs"]').first();
    const firstTrigger = island.locator('[data-tabs-trigger]').first();
    const firstValue = await firstTrigger.getAttribute('data-tabs-trigger');

    const firstContent = island.locator(`[data-tabs-content="${firstValue}"]`);
    await expect(firstContent).toBeVisible();
  });

  // --- Interaction: Tab Switching ---

  test('clicking second tab switches active panel', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="tabs"]').first();
    const secondTrigger = island.locator('[data-tabs-trigger]').nth(1);
    const secondValue = await secondTrigger.getAttribute('data-tabs-trigger');

    await secondTrigger.click();

    // Second tab content should become visible
    const secondContent = island.locator(`[data-tabs-content="${secondValue}"]`);
    await expect(secondContent).toBeVisible({ timeout: 3000 });
  });

  test('clicking second tab updates data-state to active', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="tabs"]').first();
    const secondTrigger = island.locator('[data-tabs-trigger]').nth(1);

    await secondTrigger.click();

    await expect(secondTrigger).toHaveAttribute('data-state', 'active', { timeout: 3000 });
  });

  test('clicking second tab updates aria-selected to true', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="tabs"]').first();
    const secondTrigger = island.locator('[data-tabs-trigger]').nth(1);

    await secondTrigger.click();

    await expect(secondTrigger).toHaveAttribute('aria-selected', 'true', { timeout: 3000 });
  });

  test('clicking second tab deactivates first tab', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="tabs"]').first();
    const firstTrigger = island.locator('[data-tabs-trigger]').first();
    const secondTrigger = island.locator('[data-tabs-trigger]').nth(1);

    await secondTrigger.click();

    await expect(firstTrigger).toHaveAttribute('data-state', 'inactive', { timeout: 3000 });
    await expect(firstTrigger).toHaveAttribute('aria-selected', 'false', { timeout: 3000 });
  });

  test('only one tab is active at a time', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="tabs"]').first();
    const secondTrigger = island.locator('[data-tabs-trigger]').nth(1);
    await secondTrigger.click();

    // Wait for state update
    await expect(secondTrigger).toHaveAttribute('data-state', 'active', { timeout: 3000 });

    const activeTabs = island.locator('[data-tabs-trigger][data-state="active"]');
    const count = await activeTabs.count();
    expect(count).toBe(1);
  });

  test('switching back to first tab restores it', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="tabs"]').first();
    const firstTrigger = island.locator('[data-tabs-trigger]').first();
    const secondTrigger = island.locator('[data-tabs-trigger]').nth(1);

    // Click second, then first
    await secondTrigger.click();
    await expect(secondTrigger).toHaveAttribute('data-state', 'active', { timeout: 3000 });

    await firstTrigger.click();
    await expect(firstTrigger).toHaveAttribute('data-state', 'active', { timeout: 3000 });
    await expect(firstTrigger).toHaveAttribute('aria-selected', 'true', { timeout: 3000 });
  });

  // SKIP: Keyboard navigation requires :on_keydown handlers which are not compiled in
  // the current @island pipeline. Tabs use click-only event delegation.
  // ArrowRight/Left focus management needs keydown listener infrastructure.

  test.skip('ArrowRight moves focus to next tab', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="tabs"]').first();
    const firstTrigger = island.locator('[data-tabs-trigger]').first();
    const secondTrigger = island.locator('[data-tabs-trigger]').nth(1);

    await firstTrigger.focus();
    await page.keyboard.press('ArrowRight');

    await expect(secondTrigger).toBeFocused();
  });

  test.skip('ArrowLeft moves focus to previous tab', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="tabs"]').first();
    const firstTrigger = island.locator('[data-tabs-trigger]').first();
    const secondTrigger = island.locator('[data-tabs-trigger]').nth(1);

    await secondTrigger.focus();
    await page.keyboard.press('ArrowLeft');

    await expect(firstTrigger).toBeFocused();
  });
});
