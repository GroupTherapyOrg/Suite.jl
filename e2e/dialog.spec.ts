import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

// Helper: find the first demo dialog island (not the Sheet sidebar or other dialogs)
function demoDialog(page: import('@playwright/test').Page) {
  return page.locator('therapy-island[data-component="dialog"]').filter({
    has: page.locator('[data-dialog-trigger-wrapper] button'),
  }).first();
}

test.describe('Dialog', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/dialog');
    await waitForHydration(page);
  });

  test('trigger button has aria-haspopup=dialog', async ({ page }) => {
    const dialog = demoDialog(page);
    const trigger = dialog.locator('[data-dialog-trigger-wrapper]').first();
    await expect(trigger).toHaveAttribute('aria-haspopup', 'dialog');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });

  test('clicking trigger opens dialog content', async ({ page }) => {
    const dialog = demoDialog(page);
    const triggerBtn = dialog.locator('[data-dialog-trigger-wrapper] button').first();
    await triggerBtn.click();

    const content = dialog.locator('[data-dialog-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });

  test('trigger aria-expanded updates to true when open', async ({ page }) => {
    const dialog = demoDialog(page);
    const wrapper = dialog.locator('[data-dialog-trigger-wrapper]').first();
    const triggerBtn = wrapper.locator('button');

    await triggerBtn.click();

    await expect(wrapper).toHaveAttribute('data-state', 'open');
    await expect(wrapper).toHaveAttribute('aria-expanded', 'true');
  });

  test('open dialog has role=dialog', async ({ page }) => {
    const dialog = demoDialog(page);
    const triggerBtn = dialog.locator('[data-dialog-trigger-wrapper] button').first();
    await triggerBtn.click();

    const content = dialog.locator('[data-dialog-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
    await expect(content).toHaveAttribute('role', 'dialog');
  });

  test('Escape key closes the dialog', async ({ page }) => {
    const dialog = demoDialog(page);
    const triggerBtn = dialog.locator('[data-dialog-trigger-wrapper] button').first();
    await triggerBtn.click();

    const content = dialog.locator('[data-dialog-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    await page.keyboard.press('Escape');

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('trigger data-state reverts to closed after dismiss', async ({ page }) => {
    const dialog = demoDialog(page);
    const wrapper = dialog.locator('[data-dialog-trigger-wrapper]').first();
    const triggerBtn = wrapper.locator('button');

    await triggerBtn.click();
    await expect(wrapper).toHaveAttribute('data-state', 'open');

    await page.keyboard.press('Escape');
    await expect(wrapper).toHaveAttribute('data-state', 'closed');
  });

  test('close button inside dialog closes it', async ({ page }) => {
    const dialog = demoDialog(page);
    const triggerBtn = dialog.locator('[data-dialog-trigger-wrapper] button').first();
    await triggerBtn.click();

    const content = dialog.locator('[data-dialog-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    // X close button is <button data-dialog-close=""> — click via dispatchEvent
    // to avoid fixed-position overlay interception issues with Playwright force:true
    await page.evaluate(() => {
      const allDialogs = document.querySelectorAll('therapy-island[data-component="dialog"]');
      for (const d of allDialogs) {
        if (d.querySelector('[data-dialog-trigger-wrapper] button')) {
          const btn = d.querySelector('button[data-dialog-close]');
          if (btn) btn.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));
          break;
        }
      }
    });

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });

  test('overlay click closes the dialog', async ({ page }) => {
    const dialog = demoDialog(page);
    const triggerBtn = dialog.locator('[data-dialog-trigger-wrapper] button').first();
    await triggerBtn.click();

    const content = dialog.locator('[data-dialog-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    // Dispatch click directly on overlay via JS (same approach as sheet.spec.ts)
    await page.evaluate(() => {
      const allDialogs = document.querySelectorAll('therapy-island[data-component="dialog"]');
      for (const d of allDialogs) {
        if (d.querySelector('[data-dialog-trigger-wrapper] button')) {
          const ov = d.querySelector('[data-dialog-overlay]');
          if (ov) ov.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));
          break;
        }
      }
    });

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });
});
