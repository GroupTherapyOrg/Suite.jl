import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test('debug dialog - click trigger button', async ({ page }) => {
  const logs: string[] = [];
  page.on('console', msg => logs.push(msg.text()));

  await page.goto('/components/dialog');
  await waitForHydration(page);
  await page.waitForTimeout(500);

  // Check dialog trigger island structure
  const structure = await page.evaluate(() => {
    const triggerIsland = document.querySelector('therapy-island[data-component="dialogtrigger"]');
    if (!triggerIsland) return 'no dialogtrigger island found';

    const wrapper = triggerIsland.querySelector('[data-dialog-trigger-wrapper]');
    const btn = wrapper?.querySelector('button');

    // Check if the trigger island has a click listener
    // (we can't directly check event listeners, but we can check data attributes)
    return {
      islandHydrated: triggerIsland.getAttribute('data-hydrated'),
      wrapperTag: wrapper?.tagName,
      wrapperState: wrapper?.getAttribute('data-state'),
      buttonExists: !!btn,
      buttonText: btn?.textContent?.trim().substring(0, 30),
    };
  });
  console.log('Structure:', JSON.stringify(structure, null, 2));

  // Click the button inside the trigger wrapper
  const triggerBtn = page.locator('[data-dialog-trigger-wrapper] button').first();
  await triggerBtn.click({ force: true });
  await page.waitForTimeout(1000);

  // Check all dialog-related elements after click
  const afterClick = await page.evaluate(() => {
    const triggerWrapper = document.querySelector('[data-dialog-trigger-wrapper]');
    const dialogContent = document.querySelector('[data-dialog-content]');
    const dialogOverlay = document.querySelector('[data-dialog-overlay]');
    const roleDialog = document.querySelector('[role="dialog"]');

    return {
      triggerState: triggerWrapper?.getAttribute('data-state'),
      triggerAriaExpanded: triggerWrapper?.getAttribute('aria-expanded'),
      contentExists: !!dialogContent,
      contentState: dialogContent?.getAttribute('data-state'),
      contentDisplay: dialogContent ? window.getComputedStyle(dialogContent).display : null,
      overlayExists: !!dialogOverlay,
      overlayState: dialogOverlay?.getAttribute('data-state'),
      overlayDisplay: dialogOverlay ? window.getComputedStyle(dialogOverlay).display : null,
      roleDialogExists: !!roleDialog,
      roleDialogDisplay: roleDialog ? window.getComputedStyle(roleDialog).display : null,
    };
  });
  console.log('After click:', JSON.stringify(afterClick, null, 2));

  // Print relevant logs
  console.log('\n--- Console logs ---');
  for (const l of logs) {
    if (!l.includes('WebSocket') && !l.includes('[WS]'))
      console.log('  ', l);
  }

  expect(true).toBe(true);
});
