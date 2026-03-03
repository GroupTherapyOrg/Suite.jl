import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Menubar', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./components/menubar');
    await waitForHydration(page);
  });

  // --- Static / Initial State ---

  test('menubar has role=menubar', async ({ page }) => {
    const menubar = page.locator('[role="menubar"]').first();
    await expect(menubar).toBeVisible();
  });

  test('menubar triggers are visible', async ({ page }) => {
    const triggers = page.locator('[data-menubar-trigger]');
    const count = await triggers.count();
    expect(count).toBeGreaterThan(0);
  });

  test('menu content is hidden initially', async ({ page }) => {
    const content = page.locator('[data-menubar-content]').first();
    await expect(content).not.toBeVisible();
  });

  test('triggers have aria-haspopup=menu', async ({ page }) => {
    const trigger = page.locator('[data-menubar-trigger]').first();
    await expect(trigger).toHaveAttribute('aria-haspopup', 'menu');
  });

  // --- Interaction: Open ---

  test('clicking trigger opens menu content', async ({ page }) => {
    const trigger = page.locator('[data-menubar-trigger]').first();
    await trigger.click();

    const content = page.locator('[data-menubar-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });

  test('open menu has role=menu', async ({ page }) => {
    const trigger = page.locator('[data-menubar-trigger]').first();
    await trigger.click();

    const menu = page.locator('[data-menubar-content][role="menu"]').first();
    await expect(menu).toBeVisible({ timeout: 5000 });
  });

  test('trigger aria-expanded updates to true when open', async ({ page }) => {
    const trigger = page.locator('[data-menubar-trigger]').first();
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');

    await trigger.click();

    await expect(trigger).toHaveAttribute('aria-expanded', 'true', { timeout: 5000 });
  });

  test('menu shows items with role=menuitem', async ({ page }) => {
    const trigger = page.locator('[data-menubar-trigger]').first();
    await trigger.click();

    const content = page.locator('[data-menubar-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const items = content.locator('[role="menuitem"]');
    const count = await items.count();
    expect(count).toBeGreaterThan(0);
  });

  // --- Interaction: Close ---

  test('Escape key closes menu', async ({ page }) => {
    const trigger = page.locator('[data-menubar-trigger]').first();
    await trigger.click();

    const content = page.locator('[data-menubar-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    await page.keyboard.press('Escape');

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('clicking a menu item closes menu', async ({ page }) => {
    const trigger = page.locator('[data-menubar-trigger]').first();
    await trigger.click();

    const content = page.locator('[data-menubar-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const item = content.locator('[role="menuitem"]').first();
    await item.click();

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  // --- Interaction: Menu Switching ---

  test('clicking second trigger opens second menu', async ({ page }) => {
    const triggers = page.locator('[data-menubar-trigger]');
    const secondTrigger = triggers.nth(1);

    await secondTrigger.click();

    // Find the menu content for the second menu
    const contents = page.locator('[data-menubar-content]');
    const secondContent = contents.nth(1);
    await expect(secondContent).toBeVisible({ timeout: 5000 });
  });

  test('checkbox menu item toggles aria-checked', async ({ page }) => {
    const trigger = page.locator('[data-menubar-trigger]').first();
    await trigger.click();

    const content = page.locator('[data-menubar-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const checkbox = content.locator('[role="menuitemcheckbox"]').first();
    const checkboxExists = await checkbox.count();
    if (checkboxExists > 0) {
      const initial = await checkbox.getAttribute('aria-checked');
      await checkbox.click();

      // Reopen to check state
      await trigger.click();
      const reopened = page.locator('[data-menubar-content]').first();
      await expect(reopened).toBeVisible({ timeout: 5000 });

      const updated = reopened.locator('[role="menuitemcheckbox"]').first();
      const after = await updated.getAttribute('aria-checked');
      expect(after).not.toBe(initial);
    }
  });
});
