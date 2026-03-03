import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('NavigationMenu', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/navigation-menu');
    await waitForHydration(page);
  });

  // --- Static / Initial State ---

  test('navigation menu root is visible', async ({ page }) => {
    const nav = page.locator('[data-nav-menu]').first();
    await expect(nav).toBeVisible();
  });

  test('navigation triggers are visible', async ({ page }) => {
    const triggers = page.locator('[data-nav-menu-trigger]');
    const count = await triggers.count();
    expect(count).toBeGreaterThan(0);
  });

  test('navigation content is hidden initially', async ({ page }) => {
    const content = page.locator('[data-nav-menu-content]').first();
    await expect(content).not.toBeVisible();
  });

  test('triggers have aria-haspopup=menu', async ({ page }) => {
    const trigger = page.locator('[data-nav-menu-trigger]').first();
    await expect(trigger).toHaveAttribute('aria-haspopup', 'menu');
  });

  // --- Interaction: Hover/Click to Open ---

  test('hovering trigger shows navigation content', async ({ page }) => {
    const trigger = page.locator('[data-nav-menu-trigger]').first();
    await trigger.hover();

    const content = page.locator('[data-nav-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });

  test('clicking trigger shows navigation content', async ({ page }) => {
    const trigger = page.locator('[data-nav-menu-trigger]').first();
    await trigger.click();

    const content = page.locator('[data-nav-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });

  test('trigger aria-expanded updates to true when open', async ({ page }) => {
    const trigger = page.locator('[data-nav-menu-trigger]').first();
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');

    await trigger.click();

    await expect(trigger).toHaveAttribute('aria-expanded', 'true', { timeout: 5000 });
  });

  test('navigation content has links', async ({ page }) => {
    const trigger = page.locator('[data-nav-menu-trigger]').first();
    await trigger.click();

    const content = page.locator('[data-nav-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    const links = content.locator('[data-nav-menu-link], a');
    const count = await links.count();
    expect(count).toBeGreaterThan(0);
  });

  // --- Interaction: Close ---

  test('moving mouse away from navigation content closes it', async ({ page }) => {
    const trigger = page.locator('[data-nav-menu-trigger]').first();
    await trigger.hover();

    const content = page.locator('[data-nav-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    // Move mouse away
    await page.mouse.move(0, 0);

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('Escape key closes navigation content', async ({ page }) => {
    const trigger = page.locator('[data-nav-menu-trigger]').first();
    await trigger.click();

    const content = page.locator('[data-nav-menu-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    await page.keyboard.press('Escape');

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });
});
