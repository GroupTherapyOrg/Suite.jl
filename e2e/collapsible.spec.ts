import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Collapsible', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/collapsible');
    await waitForHydration(page);
  });

  test('default collapsible starts closed', async ({ page }) => {
    const collapsible = page.locator('therapy-island[data-component="collapsible"]').first();
    const root = collapsible.locator('[data-collapsible]');
    await expect(root).toHaveAttribute('data-state', 'closed');
  });

  test('clicking trigger opens the content', async ({ page }) => {
    const trigger = page.locator('therapy-island[data-component="collapsibletrigger"]').first();
    const triggerEl = trigger.locator('[data-collapsible-trigger]');

    await triggerEl.click();

    // The parent collapsible should be open
    const collapsible = page.locator('therapy-island[data-component="collapsible"]').first();
    const root = collapsible.locator('[data-collapsible]');
    await expect(root).toHaveAttribute('data-state', 'open');
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
    const root = collapsible.locator('[data-collapsible]');

    // Open
    await triggerEl.click();
    await expect(root).toHaveAttribute('data-state', 'open');

    // Close
    await triggerEl.click();
    await expect(root).toHaveAttribute('data-state', 'closed');
    await expect(triggerEl).toHaveAttribute('aria-expanded', 'false');
  });

  test('initially open collapsible has data-state=open', async ({ page }) => {
    const openCollapsible = page.locator('therapy-island[data-component="collapsible"][data-props*="open"]');
    const count = await openCollapsible.count();
    if (count === 0) {
      test.skip(true, 'No initially-open collapsible on page');
      return;
    }
    const root = openCollapsible.first().locator('[data-collapsible]');
    await expect(root).toHaveAttribute('data-state', 'open');
  });

  test('disabled collapsible has data-disabled attribute', async ({ page }) => {
    const disabledCollapsible = page.locator('therapy-island[data-component="collapsible"][data-props*="disabled"]');
    const count = await disabledCollapsible.count();
    if (count === 0) {
      test.skip(true, 'No disabled collapsible on page');
      return;
    }
    const root = disabledCollapsible.first().locator('[data-collapsible]');
    await expect(root).toHaveAttribute('data-disabled', '');
  });

  test('multiple open/close cycles work correctly', async ({ page }) => {
    const trigger = page.locator('therapy-island[data-component="collapsibletrigger"]').first();
    const triggerEl = trigger.locator('[data-collapsible-trigger]');
    const collapsible = page.locator('therapy-island[data-component="collapsible"]').first();
    const root = collapsible.locator('[data-collapsible]');

    // Cycle 1
    await triggerEl.click();
    await expect(root).toHaveAttribute('data-state', 'open');
    await triggerEl.click();
    await expect(root).toHaveAttribute('data-state', 'closed');

    // Cycle 2
    await triggerEl.click();
    await expect(root).toHaveAttribute('data-state', 'open');
    await triggerEl.click();
    await expect(root).toHaveAttribute('data-state', 'closed');
  });
});
