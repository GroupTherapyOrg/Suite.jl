import { test, expect } from '@playwright/test';

test('debug collapsible wasm load', async ({ page }) => {
  const logs: string[] = [];
  page.on('console', msg => logs.push(`[${msg.type()}] ${msg.text()}`));
  page.on('pageerror', err => logs.push(`[PAGE_ERROR] ${err.message}`));

  await page.goto('http://localhost:3456/components/collapsible');
  await page.waitForTimeout(5000);

  // Check fetch of collapsible.wasm
  const wasmCheck = await page.evaluate(async () => {
    const results: any = {};
    try {
      const resp = await fetch('/Suite.jl/collapsible.wasm');
      results.collapsibleWasm = { ok: resp.ok, status: resp.status, url: resp.url };
    } catch (e: any) {
      results.collapsibleWasm = { error: e.message };
    }
    try {
      const resp = await fetch('/Suite.jl/collapsibletrigger.wasm');
      results.triggerWasm = { ok: resp.ok, status: resp.status, url: resp.url };
    } catch (e: any) {
      results.triggerWasm = { error: e.message };
    }
    // Check all islands
    const islands = document.querySelectorAll('therapy-island');
    results.islands = Array.from(islands).map(el => ({
      component: el.getAttribute('data-component'),
      hydrated: el.getAttribute('data-hydrated'),
      wasm: el.getAttribute('data-wasm'),
      props: el.getAttribute('data-props'),
    }));
    return results;
  });
  console.log('Wasm check:', JSON.stringify(wasmCheck, null, 2));
  
  // Print ALL console logs
  console.log('All logs:', logs.join('\n'));

  expect(true).toBe(true);
});
