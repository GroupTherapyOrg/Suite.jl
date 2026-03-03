import { test, expect } from '@playwright/test';

test.describe('Suite.jl Docs Smoke Test', () => {
  test('homepage loads successfully', async ({ page }) => {
    await page.goto('./');
    await expect(page).toHaveTitle(/.+/);
    await expect(page.locator('body')).toBeVisible();
  });

  test('component index page loads', async ({ page }) => {
    await page.goto('./components');
    await expect(page.locator('body')).toBeVisible();
  });

  test('toggle page has therapy-island element', async ({ page }) => {
    await page.goto('./components/toggle');
    const islands = page.locator('therapy-island');
    await expect(islands.first()).toBeAttached({ timeout: 5000 });
  });

  test('accordion page has therapy-island element', async ({ page }) => {
    await page.goto('./components/accordion');
    const islands = page.locator('therapy-island');
    await expect(islands.first()).toBeAttached({ timeout: 5000 });
  });

  test('dialog page has therapy-island element', async ({ page }) => {
    await page.goto('./components/dialog');
    const islands = page.locator('therapy-island');
    await expect(islands.first()).toBeAttached({ timeout: 5000 });
  });
});
