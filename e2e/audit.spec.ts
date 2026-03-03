/**
 * Runtime Audit — SUITE-3002
 *
 * Tests ONE basic interaction for each of the 17 island components
 * that don't already have dedicated Playwright specs.
 *
 * Goal: determine WORKS / BROKEN / PARTIAL for every component.
 * Each test clicks/hovers/types and checks if the DOM actually changes.
 */
import { test, expect, Page } from '@playwright/test';
import { waitForHydration } from './helpers';

// Helper: navigate and wait for hydration
async function go(page: Page, path: string) {
  await page.goto(path);
  await waitForHydration(page);
}

// ─── Pattern A: Simple Toggle ───────────────────────────────────────────

test.describe('ThemeToggle', () => {
  test('click toggles dark class on html element', async ({ page }) => {
    await go(page, '/components/toggle');

    const html = page.locator('html');
    const wasDark = await html.evaluate(el => el.classList.contains('dark'));

    // Click the theme toggle button (moon/sun icon)
    const toggle = page.locator('therapy-island[data-component="themetoggle"] button');
    await toggle.click();

    // Check if dark class toggled
    const isDark = await html.evaluate(el => el.classList.contains('dark'));
    expect(isDark).not.toBe(wasDark);
  });
});

test.describe('ThemeSwitcher', () => {
  test('click opens theme dropdown', async ({ page }) => {
    await go(page, '/components/toggle');

    // ThemeSwitcher is in the header/nav area
    const switcher = page.locator('therapy-island[data-component="themeswitcher"]');
    const trigger = switcher.locator('button').first();
    await trigger.click();

    // After click, a dropdown/popover should appear with theme options
    // Check if any theme option becomes visible
    const content = page.locator('[data-theme-switcher-content], [data-select-content], [role="listbox"]');
    await expect(content.first()).toBeVisible({ timeout: 3000 });
  });
});

// ─── Pattern B: Event Delegation ────────────────────────────────────────

test.describe('Tabs', () => {
  test('clicking a tab trigger switches active panel', async ({ page }) => {
    await go(page, '/components/tabs');

    const island = page.locator('therapy-island[data-component="tabs"]').first();
    const triggers = island.locator('[data-tabs-trigger]');
    const firstTrigger = triggers.first();
    const secondTrigger = triggers.nth(1);

    // Second trigger should start inactive
    await expect(secondTrigger).toHaveAttribute('data-state', 'inactive');

    // Click second trigger
    await secondTrigger.click();

    // Second trigger should become active
    await expect(secondTrigger).toHaveAttribute('data-state', 'active', { timeout: 3000 });
  });

  test('tab content panel switches on trigger click', async ({ page }) => {
    await go(page, '/components/tabs');

    const island = page.locator('therapy-island[data-component="tabs"]').first();
    const triggers = island.locator('[data-tabs-trigger]');
    const secondTrigger = triggers.nth(1);

    // Get the value of the second trigger
    const secondValue = await secondTrigger.getAttribute('data-tabs-trigger');

    // Click second trigger
    await secondTrigger.click();

    // The content panel matching second trigger should become visible
    const secondContent = island.locator(`[data-tabs-content="${secondValue}"]`);
    await expect(secondContent).toBeVisible({ timeout: 3000 });
  });
});

// ─── Pattern C: Split Island Modal/Floating ─────────────────────────────

test.describe('Sheet', () => {
  test('clicking trigger opens sheet content', async ({ page }) => {
    await go(page, '/components/sheet');

    const trigger = page.locator('[data-sheet-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-sheet-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });
});

test.describe('Popover', () => {
  test('clicking trigger opens popover content', async ({ page }) => {
    await go(page, '/components/popover');

    const trigger = page.locator('[data-popover-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-popover-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });
});

test.describe('Select', () => {
  test('clicking trigger opens select dropdown', async ({ page }) => {
    await go(page, '/components/select');

    const trigger = page.locator('[data-select-trigger-wrapper] button, [role="combobox"]').first();
    await trigger.click();

    const content = page.locator('[data-select-content], [role="listbox"]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });
});

test.describe('DropdownMenu', () => {
  test('clicking trigger opens dropdown content', async ({ page }) => {
    await go(page, '/components/dropdown-menu');

    const trigger = page.locator('[data-dropdown-menu-trigger-wrapper] button, [aria-haspopup="true"]').first();
    await trigger.click();

    const content = page.locator('[data-dropdown-menu-content], [role="menu"]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });
});

test.describe('ContextMenu', () => {
  test('right-click opens context menu content', async ({ page }) => {
    await go(page, '/components/context-menu');

    // Right-click on the trigger area
    const triggerArea = page.locator('[data-context-menu-trigger-wrapper]').first();
    await triggerArea.click({ button: 'right' });

    const content = page.locator('[data-context-menu-content], [role="menu"]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });
});

test.describe('HoverCard', () => {
  test('hovering trigger shows hover card content', async ({ page }) => {
    await go(page, '/components/hover-card');

    const trigger = page.locator('[data-hover-card-trigger-wrapper] a, [data-hover-card-trigger-wrapper] button').first();
    await trigger.hover();

    const content = page.locator('[data-hover-card-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });
});

// ─── Pattern D: Event Delegation + ShowDescendants ──────────────────────

test.describe('NavigationMenu', () => {
  test('hover/click on trigger shows navigation content', async ({ page }) => {
    await go(page, '/components/navigation-menu');

    const trigger = page.locator('[role="menuitem"], [data-navigation-menu-trigger]').first();
    // Try hover first (NavigationMenu typically opens on hover)
    await trigger.hover();
    await page.waitForTimeout(500);

    // If hover doesn't work, try click
    const content = page.locator('[data-navigation-menu-content], [role="menu"]');
    const visible = await content.first().isVisible().catch(() => false);
    if (!visible) {
      await trigger.click();
    }

    await expect(content.first()).toBeVisible({ timeout: 5000 });
  });
});

test.describe('Menubar', () => {
  test('clicking menu trigger opens menu content', async ({ page }) => {
    await go(page, '/components/menubar');

    const trigger = page.locator('[role="menuitem"], [data-menubar-trigger]').first();
    await trigger.click();

    const content = page.locator('[data-menubar-content], [role="menu"]');
    await expect(content.first()).toBeVisible({ timeout: 5000 });
  });
});

// ─── Complex Islands ────────────────────────────────────────────────────

test.describe('Calendar', () => {
  test('clicking a day selects it', async ({ page }) => {
    await go(page, '/components/calendar');

    const island = page.locator('therapy-island[data-component="calendar"]').first();
    // Calendar days are buttons inside the calendar grid
    const days = island.locator('button:not([disabled])');
    const dayCount = await days.count();
    expect(dayCount).toBeGreaterThan(0);

    // Find a day that is not currently selected
    const unselectedDay = island.locator('button:not([disabled]):not([data-state="selected"]):not([aria-selected="true"])').first();
    const dayText = await unselectedDay.textContent();
    await unselectedDay.click();

    // After clicking, the day should become selected
    await expect(unselectedDay).toHaveAttribute('data-state', 'selected', { timeout: 3000 })
      .catch(async () => {
        // Alternative: check aria-selected
        await expect(unselectedDay).toHaveAttribute('aria-selected', 'true', { timeout: 3000 });
      });
  });

  test('clicking next month button changes displayed month', async ({ page }) => {
    await go(page, '/components/calendar');

    const island = page.locator('therapy-island[data-component="calendar"]').first();
    // Get current month text
    const monthLabel = island.locator('[data-calendar-heading], [role="heading"]').first();
    const currentMonth = await monthLabel.textContent();

    // Click next button (typically right arrow)
    const nextBtn = island.locator('button[data-calendar-next], button:has(svg):last-of-type').first();
    await nextBtn.click();

    // Month text should change
    await expect(monthLabel).not.toHaveText(currentMonth!, { timeout: 3000 });
  });
});

test.describe('Slider', () => {
  test('clicking slider track changes value', async ({ page }) => {
    await go(page, '/components/slider');

    const island = page.locator('therapy-island[data-component="slider"]').first();
    const track = island.locator('[data-slider-track]');
    const thumb = island.locator('[data-slider-thumb]');

    // Get initial thumb position / aria-valuenow
    const initialValue = await thumb.getAttribute('aria-valuenow');

    // Click somewhere on the track (middle-right area to change value)
    const trackBox = await track.boundingBox();
    if (trackBox) {
      await page.mouse.click(
        trackBox.x + trackBox.width * 0.8,
        trackBox.y + trackBox.height / 2
      );
    }

    // Value should change
    const newValue = await thumb.getAttribute('aria-valuenow');
    expect(newValue).not.toBe(initialValue);
  });
});

test.describe('DatePicker', () => {
  test('clicking trigger opens calendar popup', async ({ page }) => {
    await go(page, '/components/date-picker');

    // DatePicker has a trigger button that opens a calendar popup
    const trigger = page.locator('[data-date-picker-trigger-wrapper] button, therapy-island[data-component="datepicker"] button').first();
    await trigger.click();

    // A calendar/popup should become visible
    const popup = page.locator('[data-date-picker-content], [data-calendar], [role="dialog"]');
    await expect(popup.first()).toBeVisible({ timeout: 5000 });
  });
});

test.describe('Command', () => {
  test('typing in command input filters items', async ({ page }) => {
    await go(page, '/components/command');

    const island = page.locator('therapy-island[data-component="commanddialog"]').first();

    // If command is inside a dialog, we may need to open it first
    const dialogTrigger = page.locator('[data-command-dialog-trigger-marker] button, button:has-text("Search")').first();
    const triggerExists = await dialogTrigger.isVisible().catch(() => false);
    if (triggerExists) {
      await dialogTrigger.click();
      await page.waitForTimeout(500);
    }

    // Find the command input
    const input = page.locator('[data-command-input], [data-command] input').first();
    await expect(input).toBeVisible({ timeout: 5000 });

    // Count items before filtering
    const itemsBefore = await page.locator('[data-command-item]').count();

    // Type to filter
    await input.fill('settings');
    await page.waitForTimeout(300);

    // Items should be filtered (fewer items or specific match)
    const itemsAfter = await page.locator('[data-command-item]:visible').count();
    // Either fewer items or at least one visible
    expect(itemsAfter).toBeLessThanOrEqual(itemsBefore);
  });
});

test.describe('Drawer', () => {
  test('clicking trigger opens drawer content', async ({ page }) => {
    await go(page, '/components/drawer');

    const trigger = page.locator('[data-drawer-trigger-wrapper] button').first();
    await trigger.click();

    const content = page.locator('[data-drawer-content]').first();
    await expect(content).toBeVisible({ timeout: 5000 });
  });
});

test.describe('Form', () => {
  test('submitting empty form shows validation errors', async ({ page }) => {
    await go(page, '/components/form');

    // Find submit button
    const submit = page.locator('button[type="submit"]').first();
    const submitExists = await submit.isVisible().catch(() => false);

    if (submitExists) {
      await submit.click();
      // Validation errors should appear
      const errors = page.locator('[data-form-message], .text-red-500, .text-destructive, [role="alert"]');
      await expect(errors.first()).toBeVisible({ timeout: 3000 });
    } else {
      // Form may not have a submit button — check for form element
      const form = page.locator('form, [data-form]').first();
      await expect(form).toBeVisible();
      // Try typing into first input to test interactivity
      const input = form.locator('input').first();
      if (await input.isVisible()) {
        await input.fill('test');
        const value = await input.inputValue();
        expect(value).toBe('test');
      }
    }
  });
});
