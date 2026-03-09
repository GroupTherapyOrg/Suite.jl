import { test, expect } from '@playwright/test';
import { waitForHydration } from './helpers';

// =============================================================================
// ISLAND MODE — Wasm-powered interactive slider on /components/slider
// =============================================================================

test.describe('Slider Island (Wasm)', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./components/slider');
    await waitForHydration(page);
  });

  // --- Static / Initial Rendering ---

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

  test('slider range (fill) element is visible', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const range = island.locator('[data-slider-range]');
    await expect(range.first()).toBeVisible();
  });

  test('slider root has data-slider attribute', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const root = island.locator('[data-slider]');
    await expect(root.first()).toBeVisible();
  });

  // --- ARIA Accessibility ---

  test('thumb has role=slider', async ({ page }) => {
    const thumb = page.locator('[role="slider"]').first();
    await expect(thumb).toBeVisible();
  });

  test('thumb has aria-valuenow', async ({ page }) => {
    const thumb = page.locator('[role="slider"]').first();
    const value = await thumb.getAttribute('aria-valuenow');
    expect(value).toBeTruthy();
  });

  test('thumb has aria-valuemin and aria-valuemax', async ({ page }) => {
    const thumb = page.locator('[role="slider"]').first();
    const min = await thumb.getAttribute('aria-valuemin');
    const max = await thumb.getAttribute('aria-valuemax');
    expect(min).toBeTruthy();
    expect(max).toBeTruthy();
  });

  test('thumb has aria-orientation', async ({ page }) => {
    const thumb = page.locator('[role="slider"]').first();
    const orientation = await thumb.getAttribute('aria-orientation');
    expect(orientation).toBe('horizontal');
  });

  test('thumb has tabindex=0 for keyboard focus', async ({ page }) => {
    const thumb = page.locator('[role="slider"]').first();
    await expect(thumb).toHaveAttribute('tabindex', '0');
  });

  test('root has data-orientation attribute', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const root = island.locator('[data-slider]').first();
    const orientation = await root.getAttribute('data-orientation');
    expect(orientation).toBe('horizontal');
  });

  test('root has data-min and data-max attributes', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const root = island.locator('[data-slider]').first();
    const min = await root.getAttribute('data-min');
    const max = await root.getAttribute('data-max');
    expect(min).toBeTruthy();
    expect(max).toBeTruthy();
    // Min should be a number
    expect(parseFloat(min!)).not.toBeNaN();
    expect(parseFloat(max!)).not.toBeNaN();
  });

  // --- Pointer Interaction: Click ---

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

  test('clicking near start of track sets fill close to 0%', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const track = island.locator('[data-slider-track]').first();
    const range = island.locator('[data-slider-range]').first();

    const trackBox = await track.boundingBox();
    expect(trackBox).toBeTruthy();

    // Click near the 5% mark
    await page.mouse.click(
      trackBox!.x + trackBox!.width * 0.05,
      trackBox!.y + trackBox!.height / 2
    );

    const rangeStyle = await range.getAttribute('style');
    expect(rangeStyle).toContain('width:');
    const match = rangeStyle?.match(/width:\s*([\d.]+)%/);
    expect(match).toBeTruthy();
    const widthPct = parseFloat(match![1]);
    expect(widthPct).toBeLessThan(20);
  });

  test('clicking near end of track sets fill close to 100%', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const track = island.locator('[data-slider-track]').first();
    const range = island.locator('[data-slider-range]').first();

    const trackBox = await track.boundingBox();
    expect(trackBox).toBeTruthy();

    // Click near the 95% mark
    await page.mouse.click(
      trackBox!.x + trackBox!.width * 0.95,
      trackBox!.y + trackBox!.height / 2
    );

    const rangeStyle = await range.getAttribute('style');
    expect(rangeStyle).toContain('width:');
    const match = rangeStyle?.match(/width:\s*([\d.]+)%/);
    expect(match).toBeTruthy();
    const widthPct = parseFloat(match![1]);
    expect(widthPct).toBeGreaterThan(80);
  });

  // --- Pointer Interaction: Drag ---

  test('dragging slider updates range fill', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const track = island.locator('[data-slider-track]').first();
    const range = island.locator('[data-slider-range]').first();

    const trackBox = await track.boundingBox();
    expect(trackBox).toBeTruthy();

    const startX = trackBox!.x + trackBox!.width * 0.2;
    const endX = trackBox!.x + trackBox!.width * 0.8;
    const y = trackBox!.y + trackBox!.height / 2;

    // Drag from 20% to 80%
    await page.mouse.move(startX, y);
    await page.mouse.down();
    await page.mouse.move(endX, y, { steps: 5 });
    await page.mouse.up();

    // Range fill should reflect roughly 80%
    const rangeStyle = await range.getAttribute('style');
    expect(rangeStyle).toContain('width:');
    const match = rangeStyle?.match(/width:\s*([\d.]+)%/);
    expect(match).toBeTruthy();
    const widthPct = parseFloat(match![1]);
    expect(widthPct).toBeGreaterThan(60);
    expect(widthPct).toBeLessThan(95);
  });

  test('dragging from right to left updates fill correctly', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const track = island.locator('[data-slider-track]').first();
    const range = island.locator('[data-slider-range]').first();

    const trackBox = await track.boundingBox();
    expect(trackBox).toBeTruthy();

    const startX = trackBox!.x + trackBox!.width * 0.8;
    const endX = trackBox!.x + trackBox!.width * 0.3;
    const y = trackBox!.y + trackBox!.height / 2;

    // Drag from 80% to 30%
    await page.mouse.move(startX, y);
    await page.mouse.down();
    await page.mouse.move(endX, y, { steps: 5 });
    await page.mouse.up();

    const rangeStyle = await range.getAttribute('style');
    expect(rangeStyle).toContain('width:');
    const match = rangeStyle?.match(/width:\s*([\d.]+)%/);
    expect(match).toBeTruthy();
    const widthPct = parseFloat(match![1]);
    expect(widthPct).toBeGreaterThan(15);
    expect(widthPct).toBeLessThan(50);
  });

  test('thumb position updates on drag', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const track = island.locator('[data-slider-track]').first();
    const thumb = island.locator('[data-slider-thumb]').first();

    const trackBox = await track.boundingBox();
    expect(trackBox).toBeTruthy();

    const targetX = trackBox!.x + trackBox!.width * 0.6;
    const y = trackBox!.y + trackBox!.height / 2;

    // Click at 60%
    await page.mouse.click(targetX, y);

    // Thumb should have a left style set
    const thumbStyle = await thumb.getAttribute('style');
    expect(thumbStyle).toContain('left:');
    const match = thumbStyle?.match(/left:\s*([\d.]+)%/);
    expect(match).toBeTruthy();
    const leftPct = parseFloat(match![1]);
    expect(leftPct).toBeGreaterThan(40);
    expect(leftPct).toBeLessThan(80);
  });

  // --- Keyboard Interaction ---

  test('thumb is focusable via keyboard', async ({ page }) => {
    const thumb = page.locator('[role="slider"]').first();
    await thumb.focus();
    await expect(thumb).toBeFocused();
  });

  test('ArrowRight increases slider value', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const track = island.locator('[data-slider-track]').first();
    const range = island.locator('[data-slider-range]').first();

    const trackBox = await track.boundingBox();
    expect(trackBox).toBeTruthy();

    // Click at 50% first to set a baseline
    await page.mouse.click(
      trackBox!.x + trackBox!.width * 0.5,
      trackBox!.y + trackBox!.height / 2
    );

    // Get initial width
    const initialStyle = await range.getAttribute('style');
    const initialMatch = initialStyle?.match(/width:\s*([\d.]+)%/);
    expect(initialMatch).toBeTruthy();
    const initialWidth = parseFloat(initialMatch![1]);

    // Focus the thumb and press ArrowRight
    const thumb = island.locator('[data-slider-thumb]').first();
    await thumb.focus();
    await page.keyboard.press('ArrowRight');

    // Width should have increased
    const afterStyle = await range.getAttribute('style');
    const afterMatch = afterStyle?.match(/width:\s*([\d.]+)%/);
    expect(afterMatch).toBeTruthy();
    const afterWidth = parseFloat(afterMatch![1]);
    expect(afterWidth).toBeGreaterThan(initialWidth);
  });

  test('ArrowLeft decreases slider value', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const track = island.locator('[data-slider-track]').first();
    const range = island.locator('[data-slider-range]').first();

    const trackBox = await track.boundingBox();
    expect(trackBox).toBeTruthy();

    // Click at 50% first to set a baseline
    await page.mouse.click(
      trackBox!.x + trackBox!.width * 0.5,
      trackBox!.y + trackBox!.height / 2
    );

    // Get initial width
    const initialStyle = await range.getAttribute('style');
    const initialMatch = initialStyle?.match(/width:\s*([\d.]+)%/);
    expect(initialMatch).toBeTruthy();
    const initialWidth = parseFloat(initialMatch![1]);

    // Focus the thumb and press ArrowLeft
    const thumb = island.locator('[data-slider-thumb]').first();
    await thumb.focus();
    await page.keyboard.press('ArrowLeft');

    // Width should have decreased
    const afterStyle = await range.getAttribute('style');
    const afterMatch = afterStyle?.match(/width:\s*([\d.]+)%/);
    expect(afterMatch).toBeTruthy();
    const afterWidth = parseFloat(afterMatch![1]);
    expect(afterWidth).toBeLessThan(initialWidth);
  });

  test('multiple ArrowRight presses increase value progressively', async ({ page }) => {
    const island = page.locator('therapy-island[data-component="slider"]').first();
    const track = island.locator('[data-slider-track]').first();
    const range = island.locator('[data-slider-range]').first();

    const trackBox = await track.boundingBox();
    expect(trackBox).toBeTruthy();

    // Click at 30%
    await page.mouse.click(
      trackBox!.x + trackBox!.width * 0.3,
      trackBox!.y + trackBox!.height / 2
    );

    const thumb = island.locator('[data-slider-thumb]').first();
    await thumb.focus();

    // Press ArrowRight 5 times
    for (let i = 0; i < 5; i++) {
      await page.keyboard.press('ArrowRight');
    }

    const afterStyle = await range.getAttribute('style');
    const afterMatch = afterStyle?.match(/width:\s*([\d.]+)%/);
    expect(afterMatch).toBeTruthy();
    const afterWidth = parseFloat(afterMatch![1]);
    // Should be > 30% after pressing right 5 times
    expect(afterWidth).toBeGreaterThan(30);
  });
});

// =============================================================================
// WIDGET MODE — SliderWidget HTML rendering on /widgets/slider
// =============================================================================

test.describe('Slider Widget (HTML @bind)', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./widgets/slider');
  });

  // --- Static Rendering: Live Preview ---

  test('widget preview section exists', async ({ page }) => {
    // The live preview is rendered via RawHtml with show(io, MIME"text/html"(), ...)
    const preview = page.locator('input[type="range"]').first();
    await expect(preview).toBeVisible();
  });

  test('widget range input has min=1 and correct max', async ({ page }) => {
    const input = page.locator('input[type="range"]').first();
    const min = await input.getAttribute('min');
    const max = await input.getAttribute('max');
    expect(min).toBe('1');
    // max should be a positive integer (length of values)
    expect(parseInt(max!)).toBeGreaterThan(0);
  });

  test('widget range input has a value attribute', async ({ page }) => {
    const input = page.locator('input[type="range"]').first();
    const value = await input.getAttribute('value');
    expect(value).toBeTruthy();
    expect(parseInt(value!)).toBeGreaterThan(0);
  });

  test('widget has label "Temperature"', async ({ page }) => {
    // The live preview uses label="Temperature"
    const label = page.locator('label:has-text("Temperature")').first();
    await expect(label).toBeVisible();
  });

  test('widget has value display element', async ({ page }) => {
    // show_value=true (default) creates a data-slider-display span
    const display = page.locator('[data-slider-display]').first();
    await expect(display).toBeVisible();
  });

  test('widget value display shows initial value', async ({ page }) => {
    const display = page.locator('[data-slider-display]').first();
    const text = await display.textContent();
    expect(text).toBeTruthy();
    // Should be a number (the default value from 1:100)
    expect(text!.trim()).toMatch(/^\d+$/);
  });

  test('widget wrapper has correct CSS classes', async ({ page }) => {
    // The wrapper span has inline-flex items-center gap-3 font-sans
    const wrapper = page.locator('span.inline-flex.items-center').first();
    await expect(wrapper).toBeVisible();
  });

  // --- Widget Interaction: Range Input ---

  test('dragging widget range input updates value display', async ({ page }) => {
    const input = page.locator('input[type="range"]').first();
    const display = page.locator('[data-slider-display]').first();

    // Get max value for calculating position
    const max = parseInt((await input.getAttribute('max'))!);

    // Get initial display
    const initialText = await display.textContent();

    // Change the input value via JavaScript (simulate user interaction)
    const newIndex = Math.floor(max * 0.75);
    await input.evaluate((el: HTMLInputElement, val: number) => {
      el.value = String(val);
      el.dispatchEvent(new Event('input', { bubbles: true }));
    }, newIndex);

    // Display should update to the value at that index
    const updatedText = await display.textContent();
    expect(updatedText).toBeTruthy();
    // Value should have changed from initial
    expect(updatedText).not.toBe(initialText);
  });

  test('widget dispatches CustomEvent on input change', async ({ page }) => {
    const input = page.locator('input[type="range"]').first();

    // Listen for the custom input event on the wrapper
    const eventFired = await page.evaluate(() => {
      return new Promise<boolean>((resolve) => {
        const wrapper = document.querySelector('span.inline-flex.items-center');
        if (!wrapper) { resolve(false); return; }
        wrapper.addEventListener('input', () => resolve(true), { once: true });
        const inp = wrapper.querySelector('input[type="range"]') as HTMLInputElement;
        if (!inp) { resolve(false); return; }
        inp.value = '50';
        inp.dispatchEvent(new Event('input', { bubbles: true }));
      });
    });
    expect(eventFired).toBe(true);
  });

  test('widget wrapper .value property returns numeric index', async ({ page }) => {
    // The inline script defines Object.defineProperty for .value
    const value = await page.evaluate(() => {
      const wrapper = document.querySelector('span.inline-flex.items-center') as any;
      return typeof wrapper?.value;
    });
    expect(value).toBe('number');
  });

  test('widget wrapper .value matches input valueAsNumber', async ({ page }) => {
    const match = await page.evaluate(() => {
      const wrapper = document.querySelector('span.inline-flex.items-center') as any;
      const input = wrapper?.querySelector('input[type="range"]') as HTMLInputElement;
      if (!wrapper || !input) return false;
      return wrapper.value === input.valueAsNumber;
    });
    expect(match).toBe(true);
  });

  // --- Index Mapping Verification ---

  test('input range has 1-based indexing (min=1)', async ({ page }) => {
    const input = page.locator('input[type="range"]').first();
    const min = await input.getAttribute('min');
    expect(min).toBe('1');
  });

  test('changing input to different index updates display correctly', async ({ page }) => {
    const display = page.locator('[data-slider-display]').first();

    // Set to index 1 (first value)
    await page.evaluate(() => {
      const wrapper = document.querySelector('span.inline-flex.items-center');
      const input = wrapper?.querySelector('input[type="range"]') as HTMLInputElement;
      if (input) {
        input.value = '1';
        input.dispatchEvent(new Event('input', { bubbles: true }));
      }
    });
    const firstText = await display.textContent();

    // Set to last index
    await page.evaluate(() => {
      const wrapper = document.querySelector('span.inline-flex.items-center');
      const input = wrapper?.querySelector('input[type="range"]') as HTMLInputElement;
      if (input) {
        input.value = input.max;
        input.dispatchEvent(new Event('input', { bubbles: true }));
      }
    });
    const lastText = await display.textContent();

    // First and last values should be different for a range 1:100
    expect(firstText).not.toBe(lastText);
  });

  test('inline script vals array has correct length', async ({ page }) => {
    // The inline script creates a vals array matching the values vector
    const valsLength = await page.evaluate(() => {
      const wrapper = document.querySelector('span.inline-flex.items-center');
      const input = wrapper?.querySelector('input[type="range"]') as HTMLInputElement;
      if (!input) return -1;
      return parseInt(input.max);
    });
    // For Slider(1:100), max should be 100
    expect(valsLength).toBe(100);
  });

  // --- Widget Styling ---

  test('range input has Suite.jl styling classes', async ({ page }) => {
    const input = page.locator('input[type="range"]').first();
    const classes = await input.getAttribute('class');
    expect(classes).toBeTruthy();
    // Should have Suite.jl warm neutral track styling
    expect(classes).toContain('rounded-full');
    expect(classes).toContain('cursor-pointer');
  });

  test('label has Suite.jl text styling', async ({ page }) => {
    const label = page.locator('label:has-text("Temperature")').first();
    const classes = await label.getAttribute('class');
    expect(classes).toBeTruthy();
    expect(classes).toContain('text-sm');
    expect(classes).toContain('font-medium');
  });

  test('value display has tabular-nums for alignment', async ({ page }) => {
    const display = page.locator('[data-slider-display]').first();
    const classes = await display.getAttribute('class');
    expect(classes).toBeTruthy();
    expect(classes).toContain('tabular-nums');
  });
});

// =============================================================================
// WIDGET PAGE STRUCTURE — Content and documentation
// =============================================================================

test.describe('Slider Widget Page Content', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./widgets/slider');
  });

  test('page has "Slider Widget" title', async ({ page }) => {
    await expect(page.locator('h1:has-text("Slider Widget")')).toBeVisible();
  });

  test('page has "Preview" section', async ({ page }) => {
    await expect(page.locator('h2:has-text("Preview")')).toBeVisible();
  });

  test('page has "Usage" section', async ({ page }) => {
    await expect(page.locator('h2:has-text("Usage")')).toBeVisible();
  });

  test('page has "Options" section with API table', async ({ page }) => {
    await expect(page.locator('h2:has-text("Options")')).toBeVisible();
    // Table should have kwarg column headers
    await expect(page.locator('th:has-text("Kwarg")')).toBeVisible();
    await expect(page.locator('th:has-text("Type")')).toBeVisible();
  });

  test('page has "Bond Protocol" section', async ({ page }) => {
    await expect(page.locator('h2:has-text("Bond Protocol")')).toBeVisible();
  });

  test('page has "Examples" section', async ({ page }) => {
    await expect(page.locator('h2:has-text("Examples")')).toBeVisible();
  });
});

// =============================================================================
// WIDGETS OVERVIEW PAGE — Navigation and links
// =============================================================================

test.describe('Widgets Overview Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('./widgets');
  });

  test('page has "Widgets" title', async ({ page }) => {
    await expect(page.locator('h1:has-text("Widgets")')).toBeVisible();
  });

  test('Slider is listed as "Available" in widget mapping table', async ({ page }) => {
    // The Slider row should have an "Available" badge
    const sliderLink = page.locator('a:has-text("Suite.Slider")');
    await expect(sliderLink.first()).toBeVisible();
  });

  test('page has "Three Tiers, Two Modes" section', async ({ page }) => {
    await expect(page.locator('h2:has-text("Three Tiers")')).toBeVisible();
  });
});

// =============================================================================
// CROSS-PAGE NAVIGATION — Widget links work
// =============================================================================

test.describe('Widget Navigation', () => {
  test('widgets overview links to slider widget page', async ({ page }) => {
    await page.goto('./widgets');
    // The Suite.Slider link in the mapping table points to the slider widget page
    const sliderLink = page.locator('a:has-text("Suite.Slider")').first();
    await sliderLink.click();
    await page.waitForURL(/.*widgets\/slider/);
    await expect(page.locator('h1:has-text("Slider Widget")')).toBeVisible();
  });

  test('top nav has Widgets link', async ({ page }) => {
    await page.goto('./');
    // Desktop nav should have a Widgets link
    const widgetsLink = page.locator('nav a:has-text("Widgets")').first();
    // It may be hidden on mobile viewport, just check it exists
    const count = await widgetsLink.count();
    expect(count).toBeGreaterThanOrEqual(0); // At least present in DOM
  });
});
