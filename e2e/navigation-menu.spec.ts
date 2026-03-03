import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('NavigationMenu', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./components/navigation-menu');
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

  test.skip('hovering trigger shows navigation content', async ({ page }) => {
    // DEFERRED: NavigationMenu uses Pattern B event delegation (single on_click on root)
    // which doesn't support hover events. Hover-to-open requires per-trigger child islands
    // with :on_pointerenter/:on_pointerleave (like Tooltip's TooltipTrigger pattern).
    // Requires: Convert NavigationMenuTrigger to child @island with pointer event handlers.
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

  test.skip('moving mouse away from navigation content closes it', async ({ page }) => {
    // DEFERRED: Requires hover-to-open (see skip above) plus timer-based pointerleave
    // with cross-island coordination. Same limitation as HoverCard hover-persist.
    // Requires: Per-trigger child islands + timer-based close delay.
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
