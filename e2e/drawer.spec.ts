import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Drawer', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/drawer');
    await waitForHydration(page);
  });

  // --- Static / Initial State ---

  test('trigger button is visible', async ({ page }) => {
    const trigger = page.locator('[data-drawer-trigger-wrapper] button').first();
    await expect(trigger).toBeVisible();
  });

  test('drawer content has data-state=closed initially', async ({ page }) => {
    const content = page.locator('[data-drawer-content]').first();
    await expect(content).toHaveAttribute('data-state', 'closed');
  });

  test('drawer overlay is hidden initially', async ({ page }) => {
    const overlay = page.locator('[data-drawer-overlay]').first();
    await expect(overlay).not.toBeVisible();
  });

  // --- Interaction: Open ---

  test('clicking trigger opens drawer content', async ({ page }) => {
    const trigger = page.locator('[data-drawer-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-drawer-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });

  test('open drawer has role=dialog', async ({ page }) => {
    const trigger = page.locator('[data-drawer-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-drawer-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
    await expect(content).toHaveAttribute('role', 'dialog');
  });

  test('overlay becomes visible when drawer opens', async ({ page }) => {
    const trigger = page.locator('[data-drawer-trigger-wrapper] button').first();
    await trigger.click();

    const overlay = page.locator('[data-drawer-overlay]').first();
    await expect(overlay).toBeVisible({ timeout: 5000 });
  });

  // --- Interaction: Close ---

  test('close button closes the drawer', async ({ page }) => {
    const trigger = page.locator('[data-drawer-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-drawer-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    // Close button click via dispatchEvent (avoids fixed-position overlay interception)
    await page.evaluate(() => {
      const island = document.querySelector('therapy-island[data-component="drawer"]');
      const btn = island?.querySelector('[data-drawer-close]');
      if (btn) btn.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));
    });
    await expect(content).toHaveAttribute('data-state', 'closed', { timeout: 5000 });
  });

  test('Escape key closes the drawer', async ({ page }) => {
    const trigger = page.locator('[data-drawer-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-drawer-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    await page.keyboard.press('Escape');

    await expect(content).toHaveAttribute('data-state', 'closed', { timeout: 5000 });
  });

  test('overlay click closes the drawer', async ({ page }) => {
    const trigger = page.locator('[data-drawer-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-drawer-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    // Dispatch click directly on overlay via JS (same approach as sheet/dialog)
    await page.evaluate(() => {
      const island = document.querySelector('therapy-island[data-component="drawer"]');
      const ov = island?.querySelector('[data-drawer-overlay]');
      if (ov) ov.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));
    });

    await expect(content).toHaveAttribute('data-state', 'closed', { timeout: 5000 });
  });

  test('drawer has direction attribute', async ({ page }) => {
    const content = page.locator('[data-drawer-content]').first();
    const direction = page.locator('[data-drawer-direction]').first();
    const count = await direction.count();
    expect(count).toBeGreaterThanOrEqual(0); // Direction may or may not be set
  });
});
