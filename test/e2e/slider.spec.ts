import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Slider', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./components/slider');
    await waitForHydration(page);
  });

  // --- Static / Initial State ---

  test('slider track is visible', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const track = island.locator('[data-slider-track]');
    await expect(track.first()).toBeVisible();
  });

  test('slider thumb is visible', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const thumb = island.locator('[data-slider-thumb]');
    await expect(thumb.first()).toBeVisible();
  });

  test('slider thumb has role=slider', async ({ page }) => {
    const thumb = page.locator('[role="slider"]').first();
    await expect(thumb).toBeVisible();
  });

  test('slider thumb has aria-valuenow', async ({ page }) => {
    const thumb = page.locator('[role="slider"]').first();
    const value = await thumb.getAttribute('aria-valuenow');
    expect(value).toBeTruthy();
  });

  test('slider thumb has aria-valuemin and aria-valuemax', async ({ page }) => {
    const thumb = page.locator('[role="slider"]').first();
    const min = await thumb.getAttribute('aria-valuemin');
    const max = await thumb.getAttribute('aria-valuemax');
    expect(min).toBeTruthy();
    expect(max).toBeTruthy();
  });

  // --- Interaction: Click Track ---

  test('clicking track moves slider fill', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const track = island.locator('[data-slider-track]').first();
    const range = island.locator('[data-slider-range]').first();

    const trackBox = await track.boundingBox();
    expect(trackBox).toBeTruthy();

    // Click near the 75% mark of the track
    await page.mouse.click(
      trackBox!.x + trackBox!.width * 0.75,
      trackBox!.y + trackBox!.height / 2
    );

    // Range fill should have a width style set by the Wasm handler
    const rangeStyle = await range.getAttribute('style');
    expect(rangeStyle).toContain('width:');
  });

  // --- Interaction: Keyboard ---

  test('dragging slider updates range fill', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const track = island.locator('[data-slider-track]').first();
    const range = island.locator('[data-slider-range]').first();

    const trackBox = await track.boundingBox();
    expect(trackBox).toBeTruthy();

    const startX = trackBox!.x + trackBox!.width * 0.2;
    const endX = trackBox!.x + trackBox!.width * 0.8;
    const y = trackBox!.y + trackBox!.height / 2;

    // Click and drag from 20% to 80%
    await page.mouse.move(startX, y);
    await page.mouse.down();
    await page.mouse.move(endX, y, { steps: 5 });
    await page.mouse.up();

    // Range fill should have width updated by the Wasm pointermove handler
    const rangeStyle = await range.getAttribute('style');
    expect(rangeStyle).toContain('width:');
    // Width should be roughly 80% (between 70% and 90%)
    const match = rangeStyle?.match(/width:\s*([\d.]+)%/);
    expect(match).toBeTruthy();
    const widthPct = parseFloat(match![1]);
    expect(widthPct).toBeGreaterThan(60);
    expect(widthPct).toBeLessThan(95);
  });

  // --- Slider Range ---

  test('slider range element is visible', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const range = island.locator('[data-slider-range]');
    await expect(range.first()).toBeVisible();
  });
});
