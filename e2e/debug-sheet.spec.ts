import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

// Helper: find a demo sheet island (same as sheet.spec.ts)
function demoSheet(page: import('@playwright/test').Page) {
  return page.locator('therapy-island[data-component="sheet"]').filter({
    has: page.locator('[data-sheet-trigger-wrapper] button'),
  }).first();
}

test('debug overlay click handler', async ({ page }) => {
  const logs: string[] = [];
  page.on('console', msg => logs.push(`[${msg.type()}] ${msg.text()}`));

  await page.goto('/components/sheet');
  await waitForHydration(page);

  const sheet = demoSheet(page);
  const trigger = sheet.locator('[data-sheet-trigger-wrapper] button').first();
  await trigger.click();

  const content = sheet.locator('[data-sheet-content]').first();
  await expect(content).toBeVisible({ timeout: 5000 });

  // Debug: check DOM relationships and handler state
  const debug = await page.evaluate(() => {
    // Find the demo sheet island (one with trigger wrapper button)
    const allSheets = document.querySelectorAll('therapy-island[data-component="sheet"]');
    let sheetIsland: Element | null = null;
    for (const s of allSheets) {
      if (s.querySelector('[data-sheet-trigger-wrapper] button')) {
        sheetIsland = s;
        break;
      }
    }
    if (!sheetIsland) return { error: 'No sheet island found' };

    const overlay = sheetIsland.querySelector('[data-sheet-overlay]');
    const contentEl = sheetIsland.querySelector('[data-sheet-content]');
    const hydrateState = (sheetIsland as any)._hydrateState;
    const firstChild = sheetIsland.firstElementChild;

    // Check if overlay is a descendant of the show_descendants root
    const result: any = {
      hasHydrateState: !!hydrateState,
      bindingCount: hydrateState?.bindings?.length ?? 0,
      bindings: hydrateState?.bindings?.map((b: any) => ({
        type: b.type,
        signal_idx: b.signal_idx,
        el_id: b.el_id,
      })) ?? [],
      elementCount: hydrateState?.elements?.length ?? 0,
      overlayFound: !!overlay,
      overlayDataState: overlay?.getAttribute('data-state'),
      contentDataState: contentEl?.getAttribute('data-state'),
      firstChildTag: firstChild?.tagName,
      firstChildHasClsH: !!(firstChild as any)?._clsH,
    };

    // Check each element in state to see which one is the show_descendants root
    if (hydrateState?.elements) {
      result.elementDetails = hydrateState.elements.map((el: any, i: number) => ({
        index: i,
        tag: el?.tagName,
        dataState: el?.getAttribute?.('data-state'),
        containsOverlay: el?.contains?.(overlay),
        hasClsH: !!el?._clsH,
      }));
    }

    // Try clicking the overlay directly via JS and see what happens
    // First, check the trigger island for instRef
    const triggerIsland = sheetIsland.querySelector('therapy-island[data-component="sheettrigger"]');
    result.triggerIslandFound = !!triggerIsland;
    result.triggerHasState = !!(triggerIsland as any)?._hydrateState;

    return result;
  });
  console.log('Debug info:', JSON.stringify(debug, null, 2));

  // Now try clicking the overlay directly via JS dispatching
  const jsClickResult = await page.evaluate(() => {
    const allSheets = document.querySelectorAll('therapy-island[data-component="sheet"]');
    let sheetIsland: Element | null = null;
    for (const s of allSheets) {
      if (s.querySelector('[data-sheet-trigger-wrapper] button')) {
        sheetIsland = s;
        break;
      }
    }
    const overlay = sheetIsland?.querySelector('[data-sheet-overlay]');
    if (!overlay) return { error: 'No overlay' };

    // Dispatch a synthetic click event on the overlay
    overlay.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));

    // Wait a tick and check state
    return new Promise(resolve => {
      setTimeout(() => {
        const contentEl = sheetIsland?.querySelector('[data-sheet-content]');
        resolve({
          overlayDataStateAfterJsClick: overlay.getAttribute('data-state'),
          contentDataStateAfterJsClick: contentEl?.getAttribute('data-state'),
          contentDisplayAfterJsClick: contentEl ? getComputedStyle(contentEl).display : 'N/A',
        });
      }, 500);
    });
  });
  console.log('After JS overlay click:', JSON.stringify(jsClickResult, null, 2));

  // Print relevant logs
  const relevantLogs = logs.filter(l => l.includes('bridge') || l.includes('handler') || l.includes('click') || l.includes('Error') || l.includes('error'));
  if (relevantLogs.length > 0) {
    console.log('Relevant logs:', relevantLogs.join('\n'));
  }

  expect(true).toBe(true);
});
