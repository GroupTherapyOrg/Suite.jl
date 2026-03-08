import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('ToggleGroup', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./components/toggle-group');
    await waitForHydration(page);
  });

  test.describe('Single mode', () => {
    // First toggle group on page: single mode with default_value="center"
    function singleGroup(page: any) {
      return page.locator('[data-toggle-group="single"]').first();
    }

    test('default selected item has data-state=on and aria-checked=true', async ({ page }) => {
      const group = singleGroup(page);
      const centerItem = group.locator('[data-toggle-group-item="center"]');
      await expect(centerItem).toHaveAttribute('data-state', 'on');
      await expect(centerItem).toHaveAttribute('aria-checked', 'true');
    });

    test('non-selected items have data-state=off', async ({ page }) => {
      const group = singleGroup(page);
      const leftItem = group.locator('[data-toggle-group-item="left"]');
      await expect(leftItem).toHaveAttribute('data-state', 'off');
      await expect(leftItem).toHaveAttribute('aria-checked', 'false');
    });

    test('clicking a different item selects it and deselects the current', async ({ page }) => {
      const group = singleGroup(page);
      const leftItem = group.locator('[data-toggle-group-item="left"]');
      const centerItem = group.locator('[data-toggle-group-item="center"]');

      // Center starts selected
      await expect(centerItem).toHaveAttribute('data-state', 'on');

      // Click left
      await leftItem.click();

      // Left should be selected, center deselected
      await expect(leftItem).toHaveAttribute('data-state', 'on');
      await expect(leftItem).toHaveAttribute('aria-checked', 'true');
      await expect(centerItem).toHaveAttribute('data-state', 'off');
      await expect(centerItem).toHaveAttribute('aria-checked', 'false');
    });

    test('clicking the selected item deselects it', async ({ page }) => {
      const group = singleGroup(page);
      const centerItem = group.locator('[data-toggle-group-item="center"]');

      await expect(centerItem).toHaveAttribute('data-state', 'on');

      await centerItem.click();

      await expect(centerItem).toHaveAttribute('data-state', 'off');
      await expect(centerItem).toHaveAttribute('aria-checked', 'false');
    });

    test('group has role=group', async ({ page }) => {
      const group = singleGroup(page);
      await expect(group).toHaveAttribute('role', 'group');
    });

    test('items have role=radio in single mode', async ({ page }) => {
      const group = singleGroup(page);
      const items = group.locator('button[role="radio"]');
      const count = await items.count();
      expect(count).toBeGreaterThanOrEqual(3);
    });
  });

  test.describe('Multiple mode', () => {
    // Multiple toggle group on page
    function multipleGroup(page: any) {
      return page.locator('[data-toggle-group="multiple"]').first();
    }

    test('default selected items have data-state=on and aria-pressed=true', async ({ page }) => {
      const group = multipleGroup(page);
      const boldItem = group.locator('[data-toggle-group-item="bold"]');
      const italicItem = group.locator('[data-toggle-group-item="italic"]');

      await expect(boldItem).toHaveAttribute('data-state', 'on');
      await expect(boldItem).toHaveAttribute('aria-pressed', 'true');
      await expect(italicItem).toHaveAttribute('data-state', 'on');
      await expect(italicItem).toHaveAttribute('aria-pressed', 'true');
    });

    test('clicking a pressed item deselects only that item', async ({ page }) => {
      const group = multipleGroup(page);
      const boldItem = group.locator('[data-toggle-group-item="bold"]');
      const italicItem = group.locator('[data-toggle-group-item="italic"]');

      // Both start on
      await expect(boldItem).toHaveAttribute('aria-pressed', 'true');
      await expect(italicItem).toHaveAttribute('aria-pressed', 'true');

      // Click bold to deselect
      await boldItem.click();

      // Bold off, italic still on
      await expect(boldItem).toHaveAttribute('data-state', 'off');
      await expect(boldItem).toHaveAttribute('aria-pressed', 'false');
      await expect(italicItem).toHaveAttribute('data-state', 'on');
      await expect(italicItem).toHaveAttribute('aria-pressed', 'true');
    });

    test('clicking an unpressed item selects it while keeping others', async ({ page }) => {
      const group = multipleGroup(page);
      const items = group.locator('button');
      const thirdItem = items.nth(2); // underline

      // Deselect first, then check we can add
      const initialState = await thirdItem.getAttribute('data-state');

      if (initialState === 'off') {
        await thirdItem.click();
        await expect(thirdItem).toHaveAttribute('data-state', 'on');
        await expect(thirdItem).toHaveAttribute('aria-pressed', 'true');
      } else {
        // Already on, click to turn off, then back on
        await thirdItem.click();
        await expect(thirdItem).toHaveAttribute('data-state', 'off');

        await thirdItem.click();
        await expect(thirdItem).toHaveAttribute('data-state', 'on');
      }
    });

    test('items use aria-pressed in multiple mode', async ({ page }) => {
      const group = multipleGroup(page);
      const items = group.locator('button[aria-pressed]');
      const count = await items.count();
      expect(count).toBeGreaterThanOrEqual(2);
    });
  });
});
