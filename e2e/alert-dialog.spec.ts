import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('AlertDialog', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/alert-dialog');
    await waitForHydration(page);
  });

  test('trigger button exists with aria-haspopup', async ({ page }) => {
    // AlertDialog uses the same split-island pattern as Dialog
    const trigger = page.locator('therapy-island[data-component="alertdialogtrigger"]').first();
    const wrapper = trigger.locator('[aria-haspopup]');
    await expect(wrapper).toBeAttached();
  });

  test('clicking trigger opens alert dialog', async ({ page }) => {
    const triggerBtn = page.locator('therapy-island[data-component="alertdialogtrigger"] button').first();
    await triggerBtn.click();

    // AlertDialog should become visible
    const dialog = page.locator('[role="alertdialog"]');
    await expect(dialog).toBeVisible({ timeout: 5000 });
  });

  test('open alert dialog has role=alertdialog', async ({ page }) => {
    const triggerBtn = page.locator('therapy-island[data-component="alertdialogtrigger"] button').first();
    await triggerBtn.click();

    const dialog = page.locator('[role="alertdialog"]');
    await expect(dialog).toBeVisible({ timeout: 5000 });
    await expect(dialog).toHaveAttribute('role', 'alertdialog');
  });

  test('cancel button closes the alert dialog', async ({ page }) => {
    const triggerBtn = page.locator('therapy-island[data-component="alertdialogtrigger"] button').first();
    await triggerBtn.click();

    const dialog = page.locator('[role="alertdialog"]');
    await expect(dialog).toBeVisible({ timeout: 5000 });

    // Find cancel button (usually the first button in the footer)
    const cancelBtn = dialog.locator('button').first();
    if (await cancelBtn.isVisible()) {
      await cancelBtn.click();
      await expect(dialog).not.toBeVisible({ timeout: 5000 });
    }
  });
});
