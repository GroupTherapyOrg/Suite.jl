/**
 * Suite.jl Runtime — DEPRECATED: All components now use @island (Wasm)
 *
 * This file will be deleted in SUITE-918.
 * All 30 interactive components have been converted to @island with BindModal modes 0-23.
 * The only remaining code is utility infrastructure (FocusGuards, ScrollLock, etc.)
 * that is no longer called by any component.
 *
 * Component removal history:
 *   SUITE-902: Toggle, Switch
 *   SUITE-903: ThemeToggle, Collapsible
 *   SUITE-904: Accordion
 *   SUITE-905: Tabs, ToggleGroup
 *   SUITE-906: Dialog, AlertDialog
 *   SUITE-907: Sheet, Drawer
 *   SUITE-908: Popover
 *   SUITE-909: Tooltip, HoverCard
 *   SUITE-910: DropdownMenu
 *   SUITE-911: ContextMenu, Menubar
 *   SUITE-912: NavigationMenu
 *   SUITE-913: Select, Command
 *   SUITE-914: Slider, Calendar, DatePicker
 *   SUITE-915: DataTable, Form
 *   SUITE-916: CodeBlock, TreeView
 *   SUITE-917: Carousel, Resizable, Toast, ThemeSwitcher
 */
;(function() {
    'use strict';

    // Singleton guard — prevent re-execution during SPA navigation
    if (window.Suite) return;

    const Suite = {
        version: '0.1.0',

        // Helper: get namespaced localStorage key based on data-base-path
        _themeKey(name) {
            const bp = document.documentElement.getAttribute('data-base-path') || '';
            return bp ? name + ':' + bp : name;
        },

        // --- All components removed (now @island) ---
        // No discover() needed — all behavior is in Therapy.jl Hydration.jl modal_state modes 0-23

        init() {
            // No-op: all components are now @island with BindModal
            // This file will be deleted in SUITE-918
        }
    };

    window.Suite = Suite;
    Suite.init();
})();
