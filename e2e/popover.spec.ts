import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Popover', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./components/popover');
    await waitForHydration(page);
  });

  test('clicking trigger opens popover content', async ({ page }) => {
    const trigger = page.locator('[data-popover-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-popover-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });

  test('trigger aria-expanded updates to true when open', async ({ page }) => {
    const wrapper = page.locator('[data-popover-trigger-wrapper]').first();
    await expect(wrapper).toHaveAttribute('aria-expanded', 'false');

    const trigger = wrapper.locator('button').first();
    await trigger.click();

    await expect(wrapper).toHaveAttribute('aria-expanded', 'true', { timeout: 5000 });
  });

  test('popover content has role=dialog', async ({ page }) => {
    const trigger = page.locator('[data-popover-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-popover-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
    await expect(content).toHaveAttribute('role', 'dialog');
  });

  test('Escape key closes the popover', async ({ page }) => {
    const trigger = page.locator('[data-popover-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-popover-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    await page.keyboard.press('Escape');

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('clicking trigger again closes the popover', async ({ page }) => {
    const trigger = page.locator('[data-popover-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-popover-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    await trigger.click();

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('popover data-state updates on open', async ({ page }) => {
    const content = page.locator('[data-popover-content]').first();
    await expect(content).toHaveAttribute('data-state', 'closed');

    const trigger = page.locator('[data-popover-trigger-wrapper] button').first();
    await trigger.click();

    await expect(content).toHaveAttribute('data-state', 'open', { timeout: 5000 });
  });

  test('trigger has aria-haspopup=dialog', async ({ page }) => {
    const wrapper = page.locator('[data-popover-trigger-wrapper]').first();
    await expect(wrapper).toHaveAttribute('aria-haspopup', 'dialog');
  });

  test.skip('focus returns to trigger after close', async ({ page }) => {
    // DEFERRED: restore_active_element() wasm call works in isolation but focus-return
    // is unreliable in parallel test execution — browser window loses focus when other
    // workers navigate. Passes consistently when run alone (npx playwright test e2e/popover.spec.ts:76).
    // Requires: Serial test execution or browser focus management improvement.
    const trigger = page.locator('[data-popover-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-popover-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    await page.keyboard.press('Escape');
    await expect(content).not.toBeVisible({ timeout: 5000 });

    await expect(trigger).toBeFocused({ timeout: 3000 });
  });
});
