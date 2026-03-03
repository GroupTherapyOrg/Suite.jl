import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Dialog', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/dialog');
    await waitForHydration(page);
  });

  test('trigger button has aria-haspopup=dialog', async ({ page }) => {
    const trigger = page.locator('[data-dialog-trigger-wrapper]').first();
    await expect(trigger).toHaveAttribute('aria-haspopup', 'dialog');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });

  test('clicking trigger opens dialog content', async ({ page }) => {
    const triggerBtn = page.locator('[data-dialog-trigger-wrapper] button').first();
    await triggerBtn.click();

    // Dialog content should become visible
    const dialogContent = page.locator('[role="dialog"]');
    await expect(dialogContent).toBeVisible({ timeout: 5000 });
  });

  test('trigger aria-expanded updates to true when open', async ({ page }) => {
    const triggerWrapper = page.locator('[data-dialog-trigger-wrapper]').first();
    const triggerBtn = triggerWrapper.locator('button');

    await triggerBtn.click();

    await expect(triggerWrapper).toHaveAttribute('data-state', 'open');
    await expect(triggerWrapper).toHaveAttribute('aria-expanded', 'true');
  });

  test('open dialog has role=dialog', async ({ page }) => {
    const triggerBtn = page.locator('[data-dialog-trigger-wrapper] button').first();
    await triggerBtn.click();

    const dialog = page.locator('[role="dialog"]');
    await expect(dialog).toBeVisible({ timeout: 5000 });
  });

  test('Escape key closes the dialog', async ({ page }) => {
    const triggerBtn = page.locator('[data-dialog-trigger-wrapper] button').first();
    await triggerBtn.click();

    const dialog = page.locator('[role="dialog"]');
    await expect(dialog).toBeVisible({ timeout: 5000 });

    await page.keyboard.press('Escape');

    await expect(dialog).not.toBeVisible({ timeout: 5000 });
  });

  test('trigger data-state reverts to closed after dismiss', async ({ page }) => {
    const triggerWrapper = page.locator('[data-dialog-trigger-wrapper]').first();
    const triggerBtn = triggerWrapper.locator('button');

    await triggerBtn.click();
    await expect(triggerWrapper).toHaveAttribute('data-state', 'open');

    await page.keyboard.press('Escape');
    await expect(triggerWrapper).toHaveAttribute('data-state', 'closed');
  });

  test('close button inside dialog closes it', async ({ page }) => {
    const triggerBtn = page.locator('[data-dialog-trigger-wrapper] button').first();
    await triggerBtn.click();

    const dialog = page.locator('[role="dialog"]');
    await expect(dialog).toBeVisible({ timeout: 5000 });

    // Find close button inside dialog (usually has sr-only text "Close" or an X icon)
    const closeBtn = dialog.locator('button').last();
    if (await closeBtn.isVisible()) {
      await closeBtn.click();
      await expect(dialog).not.toBeVisible({ timeout: 5000 });
    }
  });

  test('overlay click closes the dialog', async ({ page }) => {
    const triggerBtn = page.locator('[data-dialog-trigger-wrapper] button').first();
    await triggerBtn.click();

    const dialog = page.locator('[role="dialog"]');
    await expect(dialog).toBeVisible({ timeout: 5000 });

    // Click the overlay (outside the dialog content)
    const overlay = page.locator('[data-dialog-overlay]');
    if (await overlay.isVisible()) {
      await overlay.click({ position: { x: 10, y: 10 }, force: true });
      await expect(dialog).not.toBeVisible({ timeout: 5000 });
    }
  });
});
