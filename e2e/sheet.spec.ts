import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Sheet', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/sheet');
    await waitForHydration(page);
  });

  test('clicking trigger opens sheet content', async ({ page }) => {
    const trigger = page.locator('[data-sheet-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-sheet-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });

  test('open sheet has role=dialog and aria-modal=true', async ({ page }) => {
    const trigger = page.locator('[data-sheet-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-sheet-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
    await expect(content).toHaveAttribute('role', 'dialog');
    await expect(content).toHaveAttribute('aria-modal', 'true');
  });

  test('trigger aria-expanded updates to true when open', async ({ page }) => {
    const wrapper = page.locator('[data-sheet-trigger-wrapper]').first();
    await expect(wrapper).toHaveAttribute('aria-expanded', 'false');

    const trigger = wrapper.locator('button').first();
    await trigger.click();

    await expect(wrapper).toHaveAttribute('aria-expanded', 'true', { timeout: 5000 });
  });

  test('close button closes the sheet', async ({ page }) => {
    const trigger = page.locator('[data-sheet-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-sheet-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const closeBtn = content.locator('button[aria-label="Close"], [data-sheet-close]').first();
    await closeBtn.click();

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('Escape key closes the sheet', async ({ page }) => {
    const trigger = page.locator('[data-sheet-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-sheet-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    await page.keyboard.press('Escape');

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('overlay click closes the sheet', async ({ page }) => {
    const trigger = page.locator('[data-sheet-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-sheet-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const overlay = page.locator('[data-sheet-overlay]').first();
    await overlay.click({ force: true });

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('sheet content data-state updates on open/close', async ({ page }) => {
    const content = page.locator('[data-sheet-content]').first();
    await expect(content).toHaveAttribute('data-state', 'closed');

    const trigger = page.locator('[data-sheet-trigger-wrapper] button').first();
    await trigger.click();

    await expect(content).toHaveAttribute('data-state', 'open', { timeout: 5000 });
  });

  test('overlay becomes visible when sheet opens', async ({ page }) => {
    const trigger = page.locator('[data-sheet-trigger-wrapper] button').first();
    await trigger.click();

    const overlay = page.locator('[data-sheet-overlay]').first();
    await expect(overlay).toBeVisible({ timeout: 5000 });
  });

  test('trigger data-state reverts to closed after dismiss', async ({ page }) => {
    const wrapper = page.locator('[data-sheet-trigger-wrapper]').first();
    const trigger = wrapper.locator('button').first();

    await trigger.click();
    await expect(wrapper).toHaveAttribute('data-state', 'open', { timeout: 5000 });

    await page.keyboard.press('Escape');
    await expect(wrapper).toHaveAttribute('data-state', 'closed', { timeout: 5000 });
  });

  test('focus returns to trigger after close', async ({ page }) => {
    const trigger = page.locator('[data-sheet-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-sheet-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    await page.keyboard.press('Escape');
    await expect(content).not.toBeVisible({ timeout: 5000 });

    await expect(trigger).toBeFocused();
  });
});
