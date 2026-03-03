import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('HoverCard', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/hover-card');
    await waitForHydration(page);
  });

  test('hover card content is hidden by default', async ({ page }) => {
    const content = page.locator('[data-hover-card-content]').first();
    await expect(content).not.toBeVisible();
  });

  test('hovering trigger shows hover card content after delay', async ({ page }) => {
    const triggerWrapper = page.locator('[data-hover-card-trigger-wrapper]').first();
    const trigger = triggerWrapper.locator('a, button, span').first();
    await trigger.hover();

    // HoverCard has a 700ms open delay by default
    const content = page.locator('[data-hover-card-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });

  test('hover card data-state updates to open on hover', async ({ page }) => {
    const content = page.locator('[data-hover-card-content]').first();
    await expect(content).toHaveAttribute('data-state', 'closed');

    const triggerWrapper = page.locator('[data-hover-card-trigger-wrapper]').first();
    const trigger = triggerWrapper.locator('a, button, span').first();
    await trigger.hover();

    await expect(content).toHaveAttribute('data-state', 'open', { timeout: 5000 });
  });

  test('moving mouse away hides hover card after delay', async ({ page }) => {
    const triggerWrapper = page.locator('[data-hover-card-trigger-wrapper]').first();
    const trigger = triggerWrapper.locator('a, button, span').first();
    await trigger.hover();

    const content = page.locator('[data-hover-card-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    // Move mouse away from trigger and card
    await page.mouse.move(0, 0);

    // HoverCard has a 300ms close delay
    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('content stays open while hovering over it', async ({ page }) => {
    const triggerWrapper = page.locator('[data-hover-card-trigger-wrapper]').first();
    const trigger = triggerWrapper.locator('a, button, span').first();

    // Hover trigger to open
    await trigger.hover();
    const content = page.locator('[data-hover-card-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    // Move to content area
    await content.hover();
    await page.waitForTimeout(500);

    // Content should still be visible
    await expect(content).toBeVisible();
    await expect(content).toHaveAttribute('data-state', 'open');
  });

  test('brief hover does not open content', async ({ page }) => {
    const triggerWrapper = page.locator('[data-hover-card-trigger-wrapper]').first();
    const trigger = triggerWrapper.locator('a, button, span').first();

    // Brief hover (less than 700ms open delay)
    await trigger.hover();
    await page.waitForTimeout(100);
    await page.mouse.move(0, 0);

    // Wait a bit and verify content did NOT open
    await page.waitForTimeout(300);
    const content = page.locator('[data-hover-card-content]').first();
    await expect(content).not.toBeVisible();
  });
});
