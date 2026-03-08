import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('DropdownMenu', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./components/dropdown-menu');
    await waitForHydration(page);
  });

  test('clicking trigger opens dropdown menu', async ({ page }) => {
    const trigger = page.locator('[data-dropdown-menu-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-dropdown-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });

  test('dropdown menu has role=menu', async ({ page }) => {
    const trigger = page.locator('[data-dropdown-menu-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-dropdown-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
    await expect(content).toHaveAttribute('role', 'menu');
  });

  test('menu items have role=menuitem', async ({ page }) => {
    const trigger = page.locator('[data-dropdown-menu-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-dropdown-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const items = content.locator('[role="menuitem"]');
    const count = await items.count();
    expect(count).toBeGreaterThan(0);
  });

  test.skip('clicking a menu item closes the dropdown', async ({ page }) => {
    // Skip: requires wasm handler for menu-item-click → close delegation
    const trigger = page.locator('[data-dropdown-menu-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-dropdown-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const item = content.locator('[role="menuitem"]').first();
    await item.click();

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('Escape closes the dropdown', async ({ page }) => {
    const trigger = page.locator('[data-dropdown-menu-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-dropdown-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    await page.keyboard.press('Escape');

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('dropdown data-state updates on open', async ({ page }) => {
    const content = page.locator('[data-dropdown-menu-content]').first();
    await expect(content).toHaveAttribute('data-state', 'closed');

    const trigger = page.locator('[data-dropdown-menu-trigger-wrapper] button').first();
    await trigger.click();

    await expect(content).toHaveAttribute('data-state', 'open', { timeout: 5000 });
  });

  test('checkbox menu item toggles aria-checked on click', async ({ page }) => {
    const trigger = page.locator('[data-dropdown-menu-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-dropdown-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const checkbox = content.locator('[role="menuitemcheckbox"]').first();
    const existsCheckbox = await checkbox.count();

    if (existsCheckbox > 0) {
      const initial = await checkbox.getAttribute('aria-checked');
      await checkbox.click();

      // Reopen to check state
      await trigger.click();
      const updatedContent = page.locator('[data-dropdown-menu-content]').first();
      await expect(updatedContent).toBeVisible({ timeout: 5000 });

      const updated = updatedContent.locator('[role="menuitemcheckbox"]').first();
      const after = await updated.getAttribute('aria-checked');
      expect(after).not.toBe(initial);
    }
  });

  test('trigger has aria-haspopup=menu', async ({ page }) => {
    const wrapper = page.locator('[data-dropdown-menu-trigger-wrapper]').first();
    await expect(wrapper).toHaveAttribute('aria-haspopup', 'menu');
    await expect(wrapper).toHaveAttribute('aria-expanded', 'false');
  });

  test('clicking trigger again closes the menu', async ({ page }) => {
    const trigger = page.locator('[data-dropdown-menu-trigger-wrapper] button').first();

    // Open
    await trigger.click();
    const content = page.locator('[data-dropdown-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    // Close
    await trigger.click();
    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('disabled menu items do not close the menu', async ({ page }) => {
    const trigger = page.locator('[data-dropdown-menu-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-dropdown-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const disabledItem = content.locator('[data-disabled]').first();
    const disabledExists = await disabledItem.count();
    if (disabledExists > 0) {
      await disabledItem.click({ force: true });
      // Menu should stay open
      await expect(content).toBeVisible();
    }
  });

  test('sub-trigger has aria-haspopup=menu', async ({ page }) => {
    const trigger = page.locator('[data-dropdown-menu-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-dropdown-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const subTrigger = content.locator('[data-menu-sub-trigger]').first();
    const subExists = await subTrigger.count();
    if (subExists > 0) {
      await expect(subTrigger).toHaveAttribute('aria-haspopup', 'menu');
    }
  });
});
