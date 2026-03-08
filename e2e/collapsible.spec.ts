import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Collapsible', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./components/collapsible');
    await waitForHydration(page);
  });

  test('default collapsible starts with content hidden', async ({ page }) => {
    const collapsible = page.locator('therapy-island[data-component="collapsible"]').first();
    const content = collapsible.locator('[data-collapsible-content]');
    await expect(content).toHaveAttribute('data-state', 'closed');
    await expect(content).not.toBeVisible();
  });

  test('clicking trigger opens the content', async ({ page }) => {
    const trigger = page.locator('therapy-island[data-component="collapsibletrigger"]').first();
    const triggerEl = trigger.locator('[data-collapsible-trigger]');

    await triggerEl.click();

    // The parent collapsible content should be visible
    const collapsible = page.locator('therapy-island[data-component="collapsible"]').first();
    const content = collapsible.locator('[data-collapsible-content]');
    await expect(content).toBeVisible({ timeout: 5000 });
    await expect(content).toHaveAttribute('data-state', 'open');
  });

  test('trigger aria-expanded updates on open', async ({ page }) => {
    const trigger = page.locator('therapy-island[data-component="collapsibletrigger"]').first();
    const triggerEl = trigger.locator('[data-collapsible-trigger]');

    await expect(triggerEl).toHaveAttribute('aria-expanded', 'false');

    await triggerEl.click();

    await expect(triggerEl).toHaveAttribute('aria-expanded', 'true');
  });

  test('clicking trigger again closes the content', async ({ page }) => {
    const trigger = page.locator('therapy-island[data-component="collapsibletrigger"]').first();
    const triggerEl = trigger.locator('[data-collapsible-trigger]');
    const collapsible = page.locator('therapy-island[data-component="collapsible"]').first();
    const content = collapsible.locator('[data-collapsible-content]');

    // Open
    await triggerEl.click();
    await expect(content).toBeVisible({ timeout: 5000 });

    // Close
    await triggerEl.click();
    await expect(content).not.toBeVisible({ timeout: 5000 });
    await expect(triggerEl).toHaveAttribute('aria-expanded', 'false');
  });

  test.skip('initially open collapsible shows content', async () => {
    // DEFERRED: IslandTransform cannot compile prop-dependent signal initialization
    // (create_signal(Int32(open ? 1 : 0))). Wasm always starts at Int32(0).
    // Requires: WasmTarget.jl prop-dependent ternary in create_signal (not in scope)
  });

  test('disabled collapsible cannot be toggled', async ({ page }) => {
    // The third collapsible on the page is disabled
    const collapsible = page.locator('therapy-island[data-component="collapsible"]').nth(2);
    const content = collapsible.locator('[data-collapsible-content]');
    const trigger = page.locator('therapy-island[data-component="collapsibletrigger"]').nth(2);
    const triggerEl = trigger.locator('[data-collapsible-trigger]');

    // Content should start hidden
    await expect(content).not.toBeVisible();

    // Click the trigger — content should STAY hidden (disabled)
    await triggerEl.click({ force: true });
    await page.waitForTimeout(500);
    await expect(content).not.toBeVisible();
    await expect(content).toHaveAttribute('data-state', 'closed');
  });

  test('multiple open/close cycles work correctly', async ({ page }) => {
    const trigger = page.locator('therapy-island[data-component="collapsibletrigger"]').first();
    const triggerEl = trigger.locator('[data-collapsible-trigger]');
    const collapsible = page.locator('therapy-island[data-component="collapsible"]').first();
    const content = collapsible.locator('[data-collapsible-content]');

    // Cycle 1
    await triggerEl.click();
    await expect(content).toBeVisible({ timeout: 5000 });
    await triggerEl.click();
    await expect(content).not.toBeVisible({ timeout: 5000 });

    // Cycle 2
    await triggerEl.click();
    await expect(content).toBeVisible({ timeout: 5000 });
    await triggerEl.click();
    await expect(content).not.toBeVisible({ timeout: 5000 });
  });
});
