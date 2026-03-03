import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('ContextMenu', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/context-menu');
    await waitForHydration(page);
  });

  test('right-click on trigger area opens context menu', async ({ page }) => {
    const triggerArea = page.locator('[data-context-menu-trigger-wrapper]').first();
    await triggerArea.click({ button: 'right' });

    const content = page.locator('[data-context-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });

  test('context menu has role=menu', async ({ page }) => {
    const triggerArea = page.locator('[data-context-menu-trigger-wrapper]').first();
    await triggerArea.click({ button: 'right' });

    const content = page.locator('[data-context-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
    await expect(content).toHaveAttribute('role', 'menu');
  });

  test('clicking a menu item closes the context menu', async ({ page }) => {
    const triggerArea = page.locator('[data-context-menu-trigger-wrapper]').first();
    await triggerArea.click({ button: 'right' });

    const content = page.locator('[data-context-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const item = content.locator('[role="menuitem"]').first();
    await item.click();

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('Escape closes the context menu', async ({ page }) => {
    const triggerArea = page.locator('[data-context-menu-trigger-wrapper]').first();
    await triggerArea.click({ button: 'right' });

    const content = page.locator('[data-context-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    await page.keyboard.press('Escape');

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('context menu data-state updates on open', async ({ page }) => {
    const content = page.locator('[data-context-menu-content]').first();
    await expect(content).toHaveAttribute('data-state', 'closed');

    const triggerArea = page.locator('[data-context-menu-trigger-wrapper]').first();
    await triggerArea.click({ button: 'right' });

    await expect(content).toHaveAttribute('data-state', 'open', { timeout: 5000 });
  });
});
