import { test, expect } from '@playwright/test';

test('menubar click-outside closes menu', async ({ page }) => {
  const logs: string[] = [];
  page.on('console', msg => logs.push(`[${msg.type()}] ${msg.text()}`));
  page.on('pageerror', err => logs.push(`[pageerror] ${err.message}`));

  await page.goto('./components/menubar');
  await page.waitForTimeout(3000);

  // Open File menu
  const trigger = page.locator('[data-menubar-trigger]').first();
  await trigger.click();
  await page.waitForTimeout(500);

  const content = page.locator('[data-menubar-content]').first();
  await expect(content).toBeVisible();

  // Click outside the menubar island
  await page.locator('h1').first().click();
  await page.waitForTimeout(1000);

  // Check if menu closed
  const state = await content.getAttribute('data-state');
  console.log('AFTER CLICK-OUTSIDE state:', state);
  console.log('VISIBLE:', await content.isVisible());

  const relevantLogs = logs.filter(l =>
    l.includes('outside') || l.includes('handler') || l.includes('error') || l.includes('Error')
  );
  console.log('LOGS:', JSON.stringify(relevantLogs));

  expect(state).toBe('closed');
});

test('nav menu click-outside closes menu', async ({ page }) => {
  await page.goto('./components/navigation-menu');
  await page.waitForTimeout(3000);

  const trigger = page.locator('[data-nav-menu-trigger]').first();
  await trigger.click();
  await page.waitForTimeout(500);

  const content = page.locator('[data-nav-menu-content]').first();
  await expect(content).toBeVisible();

  // Click outside
  await page.locator('h1').first().click();
  await page.waitForTimeout(1000);

  const state = await content.getAttribute('data-state');
  console.log('NAV AFTER CLICK-OUTSIDE state:', state);
  expect(state).toBe('closed');
});
