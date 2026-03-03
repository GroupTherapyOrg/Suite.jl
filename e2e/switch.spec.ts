import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Switch', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/switch');
    await waitForHydration(page);
  });

  test('default switch has role=switch and aria-checked=false', async ({ page }) => {
    const switchEl = page.locator('therapy-island[data-component="switch"]').first().locator('[role="switch"]');
    await expect(switchEl).toHaveAttribute('role', 'switch');
    await expect(switchEl).toHaveAttribute('aria-checked', 'false');
    await expect(switchEl).toHaveAttribute('data-state', 'unchecked');
  });

  test('click toggles aria-checked from false to true', async ({ page }) => {
    const switchEl = page.locator('therapy-island[data-component="switch"]').first().locator('[role="switch"]');
    await expect(switchEl).toHaveAttribute('aria-checked', 'false');

    await switchEl.click();

    await expect(switchEl).toHaveAttribute('aria-checked', 'true');
    await expect(switchEl).toHaveAttribute('data-state', 'checked');
  });

  test('click again toggles aria-checked back to false', async ({ page }) => {
    const switchEl = page.locator('therapy-island[data-component="switch"]').first().locator('[role="switch"]');

    await switchEl.click();
    await expect(switchEl).toHaveAttribute('aria-checked', 'true');

    await switchEl.click();
    await expect(switchEl).toHaveAttribute('aria-checked', 'false');
    await expect(switchEl).toHaveAttribute('data-state', 'unchecked');
  });

  test('thumb data-state updates with switch state', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="switch"]').first();
    const switchEl = island.locator('[role="switch"]');
    const thumb = island.locator('[data-state]').last(); // thumb is child span

    await expect(thumb).toHaveAttribute('data-state', 'unchecked');

    await switchEl.click();

    await expect(thumb).toHaveAttribute('data-state', 'checked');
  });

  test('initially checked switch has correct state', async ({ page }) => {
    // Find a switch with checked=true prop
    const checkedIsland = page.locator('therapy-island[data-component="switch"][data-props*="checked"]');
    const count = await checkedIsland.count();
    if (count === 0) {
      test.skip(true, 'No initially-checked switch on page');
      return;
    }
    const switchEl = checkedIsland.first().locator('[role="switch"]');
    await expect(switchEl).toHaveAttribute('aria-checked', 'true');
    await expect(switchEl).toHaveAttribute('data-state', 'checked');
  });

  test('switch has type=button', async ({ page }) => {
    const switchEl = page.locator('therapy-island[data-component="switch"]').first().locator('[role="switch"]');
    await expect(switchEl).toHaveAttribute('type', 'button');
  });
});
