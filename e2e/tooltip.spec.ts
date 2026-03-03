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
    // Find the first tooltip trigger
    const trigger = page.locator('[data-tooltip-trigger-wrapper]').first();
    const triggerChild = trigger.locator('*').first();

    await triggerChild.hover();

    // Wait for tooltip to appear (may have delay)
    const tooltipContent = page.locator('[role="tooltip"]');
    await expect(tooltipContent.first()).toBeVisible({ timeout: 5000 });
  });

  test('tooltip trigger data-state updates on hover', async ({ page }) => {
    const trigger = page.locator('[data-tooltip-trigger-wrapper]').first();
    await expect(trigger).toHaveAttribute('data-state', 'closed');

    const triggerChild = trigger.locator('*').first();
    await triggerChild.hover();

    await expect(trigger).toHaveAttribute('data-state', 'open', { timeout: 5000 });
  });
});
