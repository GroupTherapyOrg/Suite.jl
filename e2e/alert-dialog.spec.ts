import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

// Helper: find the first demo alert dialog island
function demoAlertDialog(page: import('@playwright/test').Page) {
  return page.locator('therapy-island[data-component="alertdialog"]').filter({
    has: page.locator('[data-alert-dialog-content]'),
  }).first();
}

test.describe('AlertDialog', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./components/alert-dialog');
    await waitForHydration(page);
  });

  test('trigger button exists with aria-haspopup', async ({ page }) => {
    const trigger = page.locator('therapy-island[data-component="alertdialogtrigger"]').first();
    const wrapper = trigger.locator('[aria-haspopup]');
    await expect(wrapper).toBeAttached();
  });

  test('clicking trigger opens alert dialog', async ({ page }) => {
    const triggerBtn = page.locator('therapy-island[data-component="alertdialogtrigger"] button').first();
    await triggerBtn.click();

    const alertDialog = demoAlertDialog(page);
    const content = alertDialog.locator('[data-alert-dialog-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });

  test('open alert dialog has role=alertdialog', async ({ page }) => {
    const triggerBtn = page.locator('therapy-island[data-component="alertdialogtrigger"] button').first();
    await triggerBtn.click();

    const alertDialog = demoAlertDialog(page);
    const content = alertDialog.locator('[data-alert-dialog-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
    await expect(content).toHaveAttribute('role', 'alertdialog');
  });

  test('cancel button closes the alert dialog', async ({ page }) => {
    const triggerBtn = page.locator('therapy-island[data-component="alertdialogtrigger"] button').first();
    await triggerBtn.click();

    const alertDialog = demoAlertDialog(page);
    const content = alertDialog.locator('[data-alert-dialog-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });

    // Cancel is a <span data-alert-dialog-cancel> with display:contents — click via dispatchEvent
    await page.evaluate(() => {
      const island = document.querySelector('therapy-island[data-component="alertdialog"]');
      const cancel = island?.querySelector('[data-alert-dialog-cancel]');
      if (cancel) cancel.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));
    });

    await expect(content).not.toBeVisible({ timeout: 5000 });
  });
});
