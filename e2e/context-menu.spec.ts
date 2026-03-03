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

  test('trigger area is visible', async ({ page }) => {
    const trigger = page.locator('[data-context-menu-trigger-wrapper]').first();
    await expect(trigger).toBeVisible();
  });

  test('checkbox menu item toggles aria-checked', async ({ page }) => {
    const triggerArea = page.locator('[data-context-menu-trigger-wrapper]').first();
    await triggerArea.click({ button: 'right' });

    const content = page.locator('[data-context-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const checkbox = content.locator('[role="menuitemcheckbox"]').first();
    const checkboxExists = await checkbox.count();
    if (checkboxExists > 0) {
      const initial = await checkbox.getAttribute('aria-checked');
      await checkbox.click();

      // Reopen to check state
      await triggerArea.click({ button: 'right' });
      await expect(content).toBeVisible({ timeout: 5000 });

      const updated = content.locator('[role="menuitemcheckbox"]').first();
      const after = await updated.getAttribute('aria-checked');
      expect(after).not.toBe(initial);
    }
  });

  test('context menu appears near right-click position', async ({ page }) => {
    const triggerArea = page.locator('[data-context-menu-trigger-wrapper]').first();
    const box = await triggerArea.boundingBox();
    expect(box).toBeTruthy();

    const clickX = box!.x + box!.width / 2;
    const clickY = box!.y + box!.height / 2;
    await page.mouse.click(clickX, clickY, { button: 'right' });

    const content = page.locator('[data-context-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const contentBox = await content.boundingBox();
    expect(contentBox).toBeTruthy();
    // Allow 200px tolerance for positioning
    expect(Math.abs(contentBox!.x - clickX)).toBeLessThan(200);
    expect(Math.abs(contentBox!.y - clickY)).toBeLessThan(200);
  });
});
