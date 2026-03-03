import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

test.describe('Slider', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/components/slider');
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

  test('clicking track changes thumb value', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const track = island.locator('[data-slider-track]').first();
    const thumb = island.locator('[role="slider"]').first();

    const initialValue = await thumb.getAttribute('aria-valuenow');

    const trackBox = await track.boundingBox();
    if (trackBox) {
      // Click near the right end of the track
      await page.mouse.click(
        trackBox.x + trackBox.width * 0.8,
        trackBox.y + trackBox.height / 2
      );
    }

    const newValue = await thumb.getAttribute('aria-valuenow');
    expect(newValue).not.toBe(initialValue);
  });

  // --- Interaction: Keyboard ---

  test('ArrowRight increases value', async ({ page }) => {
    const thumb = page.locator('[role="slider"]').first();
    const initialValue = Number(await thumb.getAttribute('aria-valuenow'));

    await thumb.focus();
    await page.keyboard.press('ArrowRight');

    const newValue = Number(await thumb.getAttribute('aria-valuenow'));
    expect(newValue).toBeGreaterThan(initialValue);
  });

  test('ArrowLeft decreases value', async ({ page }) => {
    const thumb = page.locator('[role="slider"]').first();

    // First move right to have room to go left
    await thumb.focus();
    await page.keyboard.press('ArrowRight');
    await page.keyboard.press('ArrowRight');
    const midValue = Number(await thumb.getAttribute('aria-valuenow'));

    await page.keyboard.press('ArrowLeft');
    const newValue = Number(await thumb.getAttribute('aria-valuenow'));
    expect(newValue).toBeLessThan(midValue);
  });

  // --- Slider Range ---

  test('slider range element is visible', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const range = island.locator('[data-slider-range]');
    await expect(range.first()).toBeVisible();
  });
});
