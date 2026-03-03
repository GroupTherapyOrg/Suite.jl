import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Toggle', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/toggle');
    await waitForHydration(page);
  });

  test('default toggle renders with aria-pressed=false and data-state=off', async ({ page }) => {
    // First toggle on page (B button) starts unpressed
    const toggle = page.locator('therapy-island[data-component="toggle"]').first().locator('button');
    await expect(toggle).toHaveAttribute('aria-pressed', 'false');
    await expect(toggle).toHaveAttribute('data-state', 'off');
  });

  test('click toggles aria-pressed from false to true', async ({ page }) => {
    const toggle = page.locator('therapy-island[data-component="toggle"]').first().locator('button');
    await expect(toggle).toHaveAttribute('aria-pressed', 'false');

    await toggle.click();

    await expect(toggle).toHaveAttribute('aria-pressed', 'true');
    await expect(toggle).toHaveAttribute('data-state', 'on');
  });

  test('click again toggles aria-pressed back to false', async ({ page }) => {
    const toggle = page.locator('therapy-island[data-component="toggle"]').first().locator('button');

    // Click to turn on
    await toggle.click();
    await expect(toggle).toHaveAttribute('aria-pressed', 'true');

    // Click to turn off
    await toggle.click();
    await expect(toggle).toHaveAttribute('aria-pressed', 'false');
    await expect(toggle).toHaveAttribute('data-state', 'off');
  });

  test('default-pressed toggle renders with aria-pressed=true and data-state=on', async ({ page }) => {
    // Find the toggle with data-props containing pressed:true (the "Bold" button)
    const pressedIsland = page.locator('therapy-island[data-component="toggle"][data-props*="pressed"]');
    const toggle = pressedIsland.first().locator('button');
    await expect(toggle).toHaveAttribute('aria-pressed', 'true');
    await expect(toggle).toHaveAttribute('data-state', 'on');
  });

  test('clicking default-pressed toggle changes to off', async ({ page }) => {
    const pressedIsland = page.locator('therapy-island[data-component="toggle"][data-props*="pressed"]');
    const toggle = pressedIsland.first().locator('button');
    await expect(toggle).toHaveAttribute('aria-pressed', 'true');

    await toggle.click();

    await expect(toggle).toHaveAttribute('aria-pressed', 'false');
    await expect(toggle).toHaveAttribute('data-state', 'off');
  });

  test('multiple rapid clicks toggle correctly', async ({ page }) => {
    const toggle = page.locator('therapy-island[data-component="toggle"]').first().locator('button');

    // Start: off
    await expect(toggle).toHaveAttribute('aria-pressed', 'false');

    // Click 1: on
    await toggle.click();
    await expect(toggle).toHaveAttribute('aria-pressed', 'true');

    // Click 2: off
    await toggle.click();
    await expect(toggle).toHaveAttribute('aria-pressed', 'false');

    // Click 3: on
    await toggle.click();
    await expect(toggle).toHaveAttribute('aria-pressed', 'true');
  });

  test('toggle has type="button" attribute', async ({ page }) => {
    const toggle = page.locator('therapy-island[data-component="toggle"]').first().locator('button');
    await expect(toggle).toHaveAttribute('type', 'button');
  });
});
