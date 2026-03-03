import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Tooltip', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/tooltip');
    await waitForHydration(page);
  });

  test('tooltip content is hidden by default', async ({ page }) => {
    // Tooltip content elements exist in SSR but should be hidden
    const tooltipContent = page.locator('[role="tooltip"]').first();
    await expect(tooltipContent).not.toBeVisible();
  });

  test('hovering trigger shows tooltip content', async ({ page }) => {
    // Find the first visible tooltip trigger button (inner button with text, not the
    // outer wrapper button which has 0x0 dimensions due to nested <button> in HTML)
    const trigger = page.locator('[data-tooltip-trigger-wrapper]').first();
    const visibleButton = trigger.locator('button:visible').first();

    await visibleButton.hover();

    // Wait for tooltip to appear (may have delay)
    const tooltipContent = page.locator('[role="tooltip"]');
    await expect(tooltipContent.first()).toBeVisible({ timeout: 5000 });
  });

  test('tooltip trigger data-state updates on hover', async ({ page }) => {
    const trigger = page.locator('[data-tooltip-trigger-wrapper]').first();
    await expect(trigger).toHaveAttribute('data-state', 'closed');

    const visibleButton = trigger.locator('button:visible').first();
    await visibleButton.hover();

    await expect(trigger).toHaveAttribute('data-state', 'open', { timeout: 5000 });
  });
});
