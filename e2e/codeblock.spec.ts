import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('CodeBlock', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./components/code-block');
    await waitForHydration(page);
  });

  test('copy button is visible and positioned right', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="codeblockcopy"]').first();
    await expect(island).toBeVisible();

    // The ml-auto wrapper should push the copy button to the right
    const header = page.locator('[data-codeblock] .flex.items-center').first();
    const wrapper = header.locator('.ml-auto').first();
    await expect(wrapper).toBeVisible();

    // Verify wrapper (ml-auto) is to the right of header center
    const headerBox = await header.boundingBox();
    const wrapperBox = await wrapper.boundingBox();
    if (headerBox && wrapperBox) {
      const headerCenter = headerBox.x + headerBox.width / 2;
      expect(wrapperBox.x).toBeGreaterThan(headerCenter);
    }
  });

  test('copy button contains SVG icon', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="codeblockcopy"]').first();
    const svg = island.locator('svg');
    await expect(svg).toBeVisible();
  });

  test('copy button has code text in data-props', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="codeblockcopy"]').first();
    const props = await island.getAttribute('data-props');
    expect(props).toBeTruthy();
    const parsed = JSON.parse(props!);
    expect(parsed._c).toBeTruthy();
    expect(typeof parsed._c).toBe('string');
    expect(parsed._c.length).toBeGreaterThan(0);
  });

  test('clicking copy button copies code text to clipboard', async ({ page, context }) => {
    await context.grantPermissions(['clipboard-read', 'clipboard-write']);

    // Wait for wasm hydration
    const island = page.locator('therapy-island[data-component="codeblockcopy"]').first();
    await expect(island).toHaveAttribute('data-hydrated', 'true', { timeout: 10000 });

    // Clear clipboard
    await page.evaluate(() => navigator.clipboard.writeText(''));

    // Click copy button
    const button = island.locator('button');
    await button.click();
    await page.waitForTimeout(500);

    // Verify clipboard has actual code text (not empty, not an image)
    const clipText = await page.evaluate(() => navigator.clipboard.readText());
    expect(clipText.length).toBeGreaterThan(0);
    // The first code block has "using Suite" in it
    expect(clipText).toContain('using Suite');
  });

  test('multiple CodeBlocks each have their own copy island', async ({ page }) => {
    const islands = page.locator('therapy-island[data-component="codeblockcopy"]');
    const count = await islands.count();
    expect(count).toBeGreaterThan(1);

    // Each island should have different code in data-props
    const props0 = JSON.parse((await islands.nth(0).getAttribute('data-props'))!);
    const props1 = JSON.parse((await islands.nth(1).getAttribute('data-props'))!);
    // They may or may not have the same code — just verify both have _c
    expect(props0._c).toBeTruthy();
    expect(props1._c).toBeTruthy();
  });
});
