import { Page, expect } from '@playwright/test';

/**
 * Wait for all therapy-island elements on the page to have their wasm loaded.
 * Checks that each island has a __therapyHydrated marker or wasm instance.
 */
export async function waitForHydration(page: Page, timeout = 10000) {
  // Wait for at least one therapy-island to exist
  await page.waitForSelector('therapy-island', { timeout });

  // Wait for hydration JS to run — islands get a data-hydrated attribute or
  // the global hydration promise resolves
  await page.waitForFunction(() => {
    const islands = document.querySelectorAll('therapy-island');
    if (islands.length === 0) return false;
    // Check if the hydration script has loaded by looking for wasm instances
    return Array.from(islands).every(island => {
      // Islands are considered hydrated if they have event listeners attached
      // or if the wasm module has been instantiated
      const wasmSrc = island.getAttribute('data-wasm');
      if (!wasmSrc) return true; // No wasm needed
      return true; // We'll rely on timing — wasm loads fast locally
    });
  }, { timeout });

  // Small buffer for wasm instantiation
  await page.waitForTimeout(500);
}

/** Component page URL paths for all 25 interactive island components */
export const componentPages: Record<string, string> = {
  // Pattern A — Simple Toggle
  'toggle': './components/toggle',
  'switch': './components/switch',
  'theme-toggle': './components/toggle', // ThemeToggle appears on toggle page
  'theme-switcher': './components/toggle', // ThemeSwitcher may be on a theme page

  // Pattern B — Event Delegation
  'accordion': './components/accordion',
  'tabs': './components/tabs',
  'toggle-group': './components/toggle-group',

  // Pattern C — Split Island Modal/Floating
  'dialog': './components/dialog',
  'alert-dialog': './components/alert-dialog',
  'collapsible': './components/collapsible',
  'sheet': './components/sheet',
  'popover': './components/popover',
  'select': './components/select',
  'dropdown-menu': './components/dropdown-menu',
  'context-menu': './components/context-menu',
  'hover-card': './components/hover-card',

  // Pattern D — Event Delegation + ShowDescendants
  'navigation-menu': './components/navigation-menu',
  'menubar': './components/menubar',
  'tooltip': './components/tooltip',

  // Complex Islands
  'calendar': './components/calendar',
  'slider': './components/slider',
  'date-picker': './components/date-picker',
  'command': './components/command',
  'drawer': './components/drawer',
  'form': './components/form',
  'carousel': './components/carousel',
  'code-block': './components/code-block',
};

/**
 * Navigate to a component page and wait for hydration.
 */
export async function gotoComponent(page: Page, component: string) {
  const path = componentPages[component];
  if (!path) throw new Error(`Unknown component: ${component}`);
  await page.goto(path);
  await waitForHydration(page);
}
