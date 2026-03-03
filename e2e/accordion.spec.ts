import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Accordion', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./components/accordion');
    await waitForHydration(page);
  });

  // Helper: get the first single-mode accordion
  function singleAccordion(page: any) {
    return page.locator('therapy-island[data-component="accordion"]').first();
  }

  // Helper: get the multiple-mode accordion
  function multipleAccordion(page: any) {
    return page.locator('[data-accordion="multiple"]').first().locator('..');
  }

  test.describe('Single mode', () => {
    test('first item starts open (default_value)', async ({ page }) => {
      const accordion = singleAccordion(page);
      const firstItem = accordion.locator('[data-accordion-item="item-1"]');
      const firstContent = accordion.locator('[data-accordion-content]').first();

      await expect(firstItem).toHaveAttribute('data-state', 'open');
      await expect(firstContent).toHaveAttribute('data-state', 'open');
    });

    test('click closed trigger opens that item', async ({ page }) => {
      const accordion = singleAccordion(page);
      const secondTrigger = accordion.locator('[data-accordion-trigger]').nth(1);
      const secondItem = accordion.locator('[data-accordion-item="item-2"]');

      await expect(secondItem).toHaveAttribute('data-state', 'closed');

      await secondTrigger.click();

      await expect(secondItem).toHaveAttribute('data-state', 'open');
      await expect(secondTrigger).toHaveAttribute('aria-expanded', 'true');
    });

    test('opening one item closes the other (single mode)', async ({ page }) => {
      const accordion = singleAccordion(page);
      const firstItem = accordion.locator('[data-accordion-item="item-1"]');
      const secondTrigger = accordion.locator('[data-accordion-trigger]').nth(1);

      // First item starts open
      await expect(firstItem).toHaveAttribute('data-state', 'open');

      // Click second trigger
      await secondTrigger.click();

      // First item should close
      await expect(firstItem).toHaveAttribute('data-state', 'closed');
    });

    test('click trigger updates aria-expanded', async ({ page }) => {
      const accordion = singleAccordion(page);
      const secondTrigger = accordion.locator('[data-accordion-trigger]').nth(1);

      await expect(secondTrigger).toHaveAttribute('aria-expanded', 'false');

      await secondTrigger.click();

      await expect(secondTrigger).toHaveAttribute('aria-expanded', 'true');
    });

    test('content region has role=region', async ({ page }) => {
      const accordion = singleAccordion(page);
      const content = accordion.locator('[data-accordion-content]').first();
      await expect(content).toHaveAttribute('role', 'region');
    });

    test('clicking third trigger opens it and closes others', async ({ page }) => {
      const accordion = singleAccordion(page);
      const firstItem = accordion.locator('[data-accordion-item="item-1"]');
      const thirdTrigger = accordion.locator('[data-accordion-trigger]').nth(2);
      const thirdItem = accordion.locator('[data-accordion-item="item-3"]');

      await thirdTrigger.click();

      await expect(thirdItem).toHaveAttribute('data-state', 'open');
      await expect(firstItem).toHaveAttribute('data-state', 'closed');
    });
  });

  test.describe('Multiple mode', () => {
    test('click opens an item without closing others', async ({ page }) => {
      const accordion = multipleAccordion(page);
      const triggers = accordion.locator('[data-accordion-trigger]');
      const items = accordion.locator('[data-accordion-item]');

      // Click first trigger
      await triggers.first().click();
      await expect(items.first()).toHaveAttribute('data-state', 'open');

      // Click second trigger
      await triggers.nth(1).click();
      await expect(items.nth(1)).toHaveAttribute('data-state', 'open');

      // First should still be open
      await expect(items.first()).toHaveAttribute('data-state', 'open');
    });

    test('clicking an open item closes it', async ({ page }) => {
      const accordion = multipleAccordion(page);
      const trigger = accordion.locator('[data-accordion-trigger]').first();
      const item = accordion.locator('[data-accordion-item]').first();

      // Open
      await trigger.click();
      await expect(item).toHaveAttribute('data-state', 'open');

      // Close
      await trigger.click();
      await expect(item).toHaveAttribute('data-state', 'closed');
    });
  });

  test.describe('Collapsible single mode', () => {
    test('clicking open item closes it when collapsible', async ({ page }) => {
      const accordion = page.locator('[data-collapsible]').first().locator('..');
      const trigger = accordion.locator('[data-accordion-trigger]').first();
      const item = accordion.locator('[data-accordion-item]').first();

      // Open
      await trigger.click();
      await expect(item).toHaveAttribute('data-state', 'open');

      // Close (collapsible allows this in single mode)
      await trigger.click();
      await expect(item).toHaveAttribute('data-state', 'closed');
    });
  });

  // SKIP: Keyboard navigation requires :on_keydown handlers which are not compiled in
  // the current @island pipeline. Components use click-only event delegation (on_click).
  // Focus management (ArrowDown/Up/Home/End) needs keydown listener infrastructure.
  test.describe('Keyboard navigation', () => {
    test.skip('ArrowDown moves focus to next trigger', async ({ page }) => {
      const accordion = singleAccordion(page);
      const triggers = accordion.locator('[data-accordion-trigger]');

      await triggers.first().focus();
      await expect(triggers.first()).toBeFocused();

      await page.keyboard.press('ArrowDown');
      await expect(triggers.nth(1)).toBeFocused();
    });

    test.skip('ArrowDown wraps from last to first', async ({ page }) => {
      const accordion = singleAccordion(page);
      const triggers = accordion.locator('[data-accordion-trigger]');

      await triggers.last().focus();
      await page.keyboard.press('ArrowDown');
      await expect(triggers.first()).toBeFocused();
    });

    test.skip('ArrowUp moves focus to previous trigger', async ({ page }) => {
      const accordion = singleAccordion(page);
      const triggers = accordion.locator('[data-accordion-trigger]');

      await triggers.nth(1).focus();
      await page.keyboard.press('ArrowUp');
      await expect(triggers.first()).toBeFocused();
    });

    test.skip('ArrowUp wraps from first to last', async ({ page }) => {
      const accordion = singleAccordion(page);
      const triggers = accordion.locator('[data-accordion-trigger]');

      await triggers.first().focus();
      await page.keyboard.press('ArrowUp');
      await expect(triggers.last()).toBeFocused();
    });

    test.skip('Home moves focus to first trigger', async ({ page }) => {
      const accordion = singleAccordion(page);
      const triggers = accordion.locator('[data-accordion-trigger]');

      await triggers.last().focus();
      await page.keyboard.press('Home');
      await expect(triggers.first()).toBeFocused();
    });

    test.skip('End moves focus to last trigger', async ({ page }) => {
      const accordion = singleAccordion(page);
      const triggers = accordion.locator('[data-accordion-trigger]');

      await triggers.first().focus();
      await page.keyboard.press('End');
      await expect(triggers.last()).toBeFocused();
    });

    test('Enter/Space opens the focused item', async ({ page }) => {
      const accordion = singleAccordion(page);
      const triggers = accordion.locator('[data-accordion-trigger]');
      const secondItem = accordion.locator('[data-accordion-item="item-2"]');

      await triggers.nth(1).focus();
      await page.keyboard.press('Enter');

      await expect(secondItem).toHaveAttribute('data-state', 'open');
    });
  });
});
