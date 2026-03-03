import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Select', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/select');
    await waitForHydration(page);
  });

  test('clicking trigger opens select listbox', async ({ page }) => {
    const trigger = page.locator('[role="combobox"]').first();
    await trigger.click();

    const listbox = page.locator('[role="listbox"]').first();
    await expect(listbox).toBeVisible({ timeout: 5000 });
  });

  test('trigger aria-expanded updates to true when open', async ({ page }) => {
    const trigger = page.locator('[role="combobox"]').first();
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');

    await trigger.click();

    await expect(trigger).toHaveAttribute('aria-expanded', 'true', { timeout: 5000 });
  });

  test('clicking an option selects it and closes dropdown', async ({ page }) => {
    const trigger = page.locator('[role="combobox"]').first();
    await trigger.click();

    const listbox = page.locator('[role="listbox"]').first();
    await expect(listbox).toBeVisible({ timeout: 5000 });

    const option = listbox.locator('[role="option"]').nth(1);
    const optionText = await option.textContent();
    await option.click();

    // Listbox should close
    await expect(listbox).not.toBeVisible({ timeout: 5000 });

    // Selected value should be displayed in trigger
    const display = page.locator('[data-select-display]').first();
    const displayText = await display.textContent();
    expect(displayText).toContain(optionText?.trim() || '');
  });

  test('Escape closes the select dropdown', async ({ page }) => {
    const trigger = page.locator('[role="combobox"]').first();
    await trigger.click();

    const listbox = page.locator('[role="listbox"]').first();
    await expect(listbox).toBeVisible({ timeout: 5000 });

    await page.keyboard.press('Escape');

    await expect(listbox).not.toBeVisible({ timeout: 5000 });
  });

  test('select has correct ARIA structure', async ({ page }) => {
    const trigger = page.locator('[role="combobox"]').first();
    await expect(trigger).toHaveAttribute('aria-haspopup', 'listbox');

    await trigger.click();

    const options = page.locator('[role="option"]');
    const count = await options.count();
    expect(count).toBeGreaterThan(0);
  });

  test('selected option has aria-selected=true', async ({ page }) => {
    const trigger = page.locator('[role="combobox"]').first();
    await trigger.click();

    const listbox = page.locator('[role="listbox"]').first();
    await expect(listbox).toBeVisible({ timeout: 5000 });

    const secondOption = listbox.locator('[role="option"]').nth(1);
    await secondOption.click();

    // Reopen
    await trigger.click();
    await expect(listbox).toBeVisible({ timeout: 5000 });

    // The second option should now be selected
    const selected = listbox.locator('[role="option"]').nth(1);
    await expect(selected).toHaveAttribute('aria-selected', 'true');
  });

  test('shows placeholder text before selection', async ({ page }) => {
    const display = page.locator('[data-select-display], [data-slot="select-value"]').first();
    await expect(display).toBeVisible();
    const text = await display.textContent();
    expect(text!.length).toBeGreaterThan(0);
  });

  test('trigger wrapper data-state updates with open/close', async ({ page }) => {
    const wrapper = page.locator('[data-select-trigger-wrapper]').first();
    await expect(wrapper).toHaveAttribute('data-state', 'closed');

    const trigger = page.locator('[role="combobox"]').first();
    await trigger.click();

    await expect(wrapper).toHaveAttribute('data-state', 'open', { timeout: 5000 });

    await page.keyboard.press('Escape');
    await expect(wrapper).toHaveAttribute('data-state', 'closed', { timeout: 5000 });
  });

  test('focus returns to trigger after close', async ({ page }) => {
    const trigger = page.locator('[role="combobox"]').first();
    await trigger.click();

    const listbox = page.locator('[role="listbox"]').first();
    await expect(listbox).toBeVisible({ timeout: 5000 });

    await page.keyboard.press('Escape');
    await expect(listbox).not.toBeVisible({ timeout: 5000 });

    await expect(trigger).toBeFocused();
  });

  test('multiple options are visible when dropdown opens', async ({ page }) => {
    const trigger = page.locator('[role="combobox"]').first();
    await trigger.click();

    const listbox = page.locator('[role="listbox"]').first();
    await expect(listbox).toBeVisible({ timeout: 5000 });

    const options = listbox.locator('[role="option"]');
    const count = await options.count();
    expect(count).toBeGreaterThan(1);
  });

  test('content has data-state=closed initially', async ({ page }) => {
    const content = page.locator('[data-select-content]').first();
    await expect(content).toHaveAttribute('data-state', 'closed');
    await expect(content).not.toBeVisible();
  });
});
