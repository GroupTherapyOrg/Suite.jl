/**
 * Suite.jl Runtime — Behavioral JS for complex UI components
 *
 * This module handles DOM behaviors that cannot be expressed in pure Wasm:
 * - Focus trapping (Dialog, AlertDialog, Sheet)
 * - Dismiss layers (click-outside, Escape key)
 * - Floating positioning (Popover, Tooltip, DropdownMenu, Select)
 * - Roving focus (Menubar, NavigationMenu, RadioGroup)
 * - Presence animations (mount/unmount transitions)
 * - Collection management (ordered item lists)
 *
 * Architecture:
 *   - Auto-discovers components via data-suite-* attributes
 *   - Each behavior is a standalone module (no cross-dependencies)
 *   - Re-scans on SPA navigation (listens for therapy:navigate)
 *   - Zero external dependencies (no Floating UI, no Radix)
 *
 * Verified against:
 *   - Radix UI primitives (behavioral parity)
 *   - WAI-ARIA patterns (accessibility compliance)
 *   - Zag.js state machines (logic reference)
 */
;(function() {
    'use strict';

    // Singleton guard — prevent re-execution during SPA navigation
    if (window.Suite) return;

    const Suite = {
        version: '0.1.0',

        // --- Focus Trap -----------------------------------------------------------
        FocusTrap: {
            /**
             * Trap focus within a container element.
             * @param {HTMLElement} container - The element to trap focus within
             * @returns {Function} cleanup - Call to release the trap
             */
            activate(container) {
                const focusable = container.querySelectorAll(
                    'a[href], button:not([disabled]), textarea:not([disabled]), ' +
                    'input:not([disabled]), select:not([disabled]), [tabindex]:not([tabindex="-1"])'
                );
                if (focusable.length === 0) return () => {};

                const first = focusable[0];
                const last = focusable[focusable.length - 1];
                const previouslyFocused = document.activeElement;

                function handleKeyDown(e) {
                    if (e.key !== 'Tab') return;
                    if (e.shiftKey) {
                        if (document.activeElement === first) {
                            e.preventDefault();
                            last.focus();
                        }
                    } else {
                        if (document.activeElement === last) {
                            e.preventDefault();
                            first.focus();
                        }
                    }
                }

                container.addEventListener('keydown', handleKeyDown);
                first.focus();

                return function cleanup() {
                    container.removeEventListener('keydown', handleKeyDown);
                    if (previouslyFocused && previouslyFocused.focus) {
                        previouslyFocused.focus();
                    }
                };
            }
        },

        // --- Dismiss Layer --------------------------------------------------------
        DismissLayer: {
            /**
             * Dismiss on click-outside or Escape key.
             * @param {HTMLElement} container - The dismissable element
             * @param {Function} onDismiss - Called when dismissed
             * @returns {Function} cleanup
             */
            activate(container, onDismiss) {
                function handleClickOutside(e) {
                    if (!container.contains(e.target)) {
                        onDismiss();
                    }
                }
                function handleEscape(e) {
                    if (e.key === 'Escape') {
                        onDismiss();
                    }
                }

                // Delay to avoid immediate dismiss from the opening click
                requestAnimationFrame(() => {
                    document.addEventListener('pointerdown', handleClickOutside);
                    document.addEventListener('keydown', handleEscape);
                });

                return function cleanup() {
                    document.removeEventListener('pointerdown', handleClickOutside);
                    document.removeEventListener('keydown', handleEscape);
                };
            }
        },

        // --- Floating Positioning -------------------------------------------------
        Floating: {
            /**
             * Position a floating element relative to a reference element.
             * Minimal implementation — covers top/bottom/left/right with flip.
             * @param {HTMLElement} reference - The anchor element
             * @param {HTMLElement} floating - The floating element to position
             * @param {Object} options - { placement: 'bottom', offset: 8 }
             * @returns {Function} cleanup
             */
            position(reference, floating, options = {}) {
                const placement = options.placement || 'bottom';
                const offset = options.offset || 8;

                function update() {
                    const refRect = reference.getBoundingClientRect();
                    const floatRect = floating.getBoundingClientRect();
                    const viewport = {
                        width: window.innerWidth,
                        height: window.innerHeight
                    };

                    let top, left;

                    switch (placement) {
                        case 'top':
                            top = refRect.top - floatRect.height - offset;
                            left = refRect.left + (refRect.width - floatRect.width) / 2;
                            // Flip to bottom if no space
                            if (top < 0) top = refRect.bottom + offset;
                            break;
                        case 'bottom':
                            top = refRect.bottom + offset;
                            left = refRect.left + (refRect.width - floatRect.width) / 2;
                            // Flip to top if no space
                            if (top + floatRect.height > viewport.height) {
                                top = refRect.top - floatRect.height - offset;
                            }
                            break;
                        case 'left':
                            top = refRect.top + (refRect.height - floatRect.height) / 2;
                            left = refRect.left - floatRect.width - offset;
                            if (left < 0) left = refRect.right + offset;
                            break;
                        case 'right':
                            top = refRect.top + (refRect.height - floatRect.height) / 2;
                            left = refRect.right + offset;
                            if (left + floatRect.width > viewport.width) {
                                left = refRect.left - floatRect.width - offset;
                            }
                            break;
                    }

                    // Clamp to viewport
                    left = Math.max(4, Math.min(left, viewport.width - floatRect.width - 4));
                    top = Math.max(4, Math.min(top, viewport.height - floatRect.height - 4));

                    floating.style.position = 'fixed';
                    floating.style.top = top + 'px';
                    floating.style.left = left + 'px';
                }

                update();

                // Reposition on scroll/resize
                window.addEventListener('scroll', update, true);
                window.addEventListener('resize', update);

                return function cleanup() {
                    window.removeEventListener('scroll', update, true);
                    window.removeEventListener('resize', update);
                };
            }
        },

        // --- Roving Focus ---------------------------------------------------------
        RovingFocus: {
            /**
             * Arrow key navigation within a group of focusable items.
             * @param {HTMLElement} container - The group container
             * @param {string} selector - CSS selector for focusable items
             * @param {Object} options - { orientation: 'horizontal' | 'vertical', loop: true }
             * @returns {Function} cleanup
             */
            activate(container, selector, options = {}) {
                const orientation = options.orientation || 'horizontal';
                const loop = options.loop !== false;
                const nextKey = orientation === 'horizontal' ? 'ArrowRight' : 'ArrowDown';
                const prevKey = orientation === 'horizontal' ? 'ArrowLeft' : 'ArrowUp';

                function handleKeyDown(e) {
                    const items = Array.from(container.querySelectorAll(selector));
                    const current = items.indexOf(document.activeElement);
                    if (current === -1) return;

                    let next;
                    if (e.key === nextKey) {
                        next = current + 1;
                        if (next >= items.length) next = loop ? 0 : current;
                    } else if (e.key === prevKey) {
                        next = current - 1;
                        if (next < 0) next = loop ? items.length - 1 : current;
                    } else if (e.key === 'Home') {
                        next = 0;
                    } else if (e.key === 'End') {
                        next = items.length - 1;
                    } else {
                        return;
                    }

                    e.preventDefault();
                    items[next].focus();
                }

                container.addEventListener('keydown', handleKeyDown);
                return function cleanup() {
                    container.removeEventListener('keydown', handleKeyDown);
                };
            }
        },

        // --- Presence Animation ---------------------------------------------------
        Presence: {
            /**
             * Mount/unmount with CSS transitions.
             * @param {HTMLElement} element - Element to animate
             * @param {boolean} present - Whether element should be visible
             * @param {Object} options - { enterClass, exitClass, duration }
             */
            toggle(element, present, options = {}) {
                const enterClass = options.enterClass || 'suite-enter';
                const exitClass = options.exitClass || 'suite-exit';

                if (present) {
                    element.style.display = '';
                    element.classList.remove(exitClass);
                    // Force reflow
                    element.offsetHeight;
                    element.classList.add(enterClass);
                } else {
                    element.classList.remove(enterClass);
                    element.classList.add(exitClass);
                    // Remove after animation
                    element.addEventListener('animationend', function handler() {
                        element.style.display = 'none';
                        element.classList.remove(exitClass);
                        element.removeEventListener('animationend', handler);
                    }, { once: true });
                    // Fallback if no animation defined
                    const duration = options.duration || 200;
                    setTimeout(() => {
                        if (element.classList.contains(exitClass)) {
                            element.style.display = 'none';
                            element.classList.remove(exitClass);
                        }
                    }, duration + 50);
                }
            }
        },

        // --- Collapsible ----------------------------------------------------------
        Collapsible: {
            /**
             * Initialize collapsible components.
             * Discovers [data-suite-collapsible] roots and wires trigger→content toggle.
             */
            init() {
                const roots = document.querySelectorAll('[data-suite-collapsible]');
                roots.forEach(root => {
                    if (root._suiteCollapsible) return;
                    root._suiteCollapsible = true;

                    const trigger = root.querySelector('[data-suite-collapsible-trigger]');
                    const content = root.querySelector('[data-suite-collapsible-content]');
                    if (!trigger || !content) return;

                    trigger.addEventListener('click', () => {
                        if (root.hasAttribute('data-disabled')) return;
                        const isOpen = root.getAttribute('data-state') === 'open';
                        const newState = isOpen ? 'closed' : 'open';
                        root.setAttribute('data-state', newState);
                        trigger.setAttribute('data-state', newState);
                        trigger.setAttribute('aria-expanded', String(!isOpen));
                        content.setAttribute('data-state', newState);
                        content.hidden = isOpen;
                    });
                });
            }
        },

        // --- Accordion ------------------------------------------------------------
        Accordion: {
            /**
             * Initialize accordion components.
             * Discovers [data-suite-accordion] roots. Handles single/multiple mode,
             * collapsible flag, and keyboard navigation between triggers.
             */
            init() {
                const roots = document.querySelectorAll('[data-suite-accordion]');
                roots.forEach(root => {
                    if (root._suiteAccordion) return;
                    root._suiteAccordion = true;

                    const type = root.getAttribute('data-suite-accordion') || 'single';
                    const collapsible = root.hasAttribute('data-collapsible');
                    const orientation = root.getAttribute('data-orientation') || 'vertical';

                    function getItems() {
                        return Array.from(root.querySelectorAll('[data-suite-accordion-item]'));
                    }

                    function getTriggers() {
                        return Array.from(root.querySelectorAll('[data-suite-accordion-trigger]'))
                            .filter(t => !t.disabled && !t.closest('[data-suite-accordion-item]').hasAttribute('data-disabled'));
                    }

                    function toggleItem(item, open) {
                        const state = open ? 'open' : 'closed';
                        item.setAttribute('data-state', state);
                        const trigger = item.querySelector('[data-suite-accordion-trigger]');
                        const content = item.querySelector('[data-suite-accordion-content]');
                        if (trigger) {
                            trigger.setAttribute('data-state', state);
                            trigger.setAttribute('aria-expanded', String(open));
                            if (type === 'single' && open && !collapsible) {
                                trigger.setAttribute('aria-disabled', 'true');
                            } else {
                                trigger.removeAttribute('aria-disabled');
                            }
                        }
                        if (content) {
                            content.setAttribute('data-state', state);
                            content.hidden = !open;
                        }
                    }

                    // Trigger click handlers
                    root.addEventListener('click', (e) => {
                        const trigger = e.target.closest('[data-suite-accordion-trigger]');
                        if (!trigger || trigger.disabled) return;
                        const item = trigger.closest('[data-suite-accordion-item]');
                        if (!item || item.hasAttribute('data-disabled')) return;

                        const isOpen = item.getAttribute('data-state') === 'open';

                        if (type === 'single') {
                            if (isOpen) {
                                if (collapsible) toggleItem(item, false);
                                // If not collapsible, do nothing (can't close last open)
                            } else {
                                // Close all others, open this one
                                getItems().forEach(i => toggleItem(i, false));
                                toggleItem(item, true);
                            }
                        } else {
                            // Multiple mode — always toggle
                            toggleItem(item, !isOpen);
                        }
                    });

                    // Keyboard navigation between triggers
                    root.addEventListener('keydown', (e) => {
                        const trigger = e.target.closest('[data-suite-accordion-trigger]');
                        if (!trigger) return;

                        const triggers = getTriggers();
                        const idx = triggers.indexOf(trigger);
                        if (idx === -1) return;

                        const isVert = orientation === 'vertical';
                        const nextKey = isVert ? 'ArrowDown' : 'ArrowRight';
                        const prevKey = isVert ? 'ArrowUp' : 'ArrowLeft';
                        let target;

                        if (e.key === nextKey) {
                            target = triggers[(idx + 1) % triggers.length];
                        } else if (e.key === prevKey) {
                            target = triggers[(idx - 1 + triggers.length) % triggers.length];
                        } else if (e.key === 'Home') {
                            target = triggers[0];
                        } else if (e.key === 'End') {
                            target = triggers[triggers.length - 1];
                        }

                        if (target) {
                            e.preventDefault();
                            target.focus();
                        }
                    });
                });
            }
        },

        // --- Tabs -----------------------------------------------------------------
        Tabs: {
            /**
             * Initialize tabs components.
             * Discovers [data-suite-tabs] roots. Handles tab selection,
             * roving tabindex on TabsList, and keyboard navigation.
             */
            init() {
                const roots = document.querySelectorAll('[data-suite-tabs]');
                roots.forEach(root => {
                    if (root._suiteTabs) return;
                    root._suiteTabs = true;

                    const orientation = root.getAttribute('data-orientation') || 'horizontal';
                    const activation = root.getAttribute('data-activation') || 'automatic';
                    const list = root.querySelector('[data-suite-tabslist]');
                    if (!list) return;

                    const loop = !list.hasAttribute('data-no-loop');

                    function getTriggers() {
                        return Array.from(list.querySelectorAll('[data-suite-tabs-trigger]'))
                            .filter(t => !t.disabled && !t.hasAttribute('data-disabled'));
                    }

                    function selectTab(value) {
                        // Update triggers
                        const triggers = Array.from(list.querySelectorAll('[data-suite-tabs-trigger]'));
                        triggers.forEach(t => {
                            const isActive = t.getAttribute('data-suite-tabs-trigger') === value;
                            t.setAttribute('data-state', isActive ? 'active' : 'inactive');
                            t.setAttribute('aria-selected', String(isActive));
                            t.setAttribute('tabindex', isActive ? '0' : '-1');
                        });
                        // Update content panels
                        const panels = Array.from(root.querySelectorAll('[data-suite-tabs-content]'));
                        panels.forEach(p => {
                            const isActive = p.getAttribute('data-suite-tabs-content') === value;
                            p.setAttribute('data-state', isActive ? 'active' : 'inactive');
                            p.hidden = !isActive;
                        });
                    }

                    // Click handler
                    list.addEventListener('click', (e) => {
                        const trigger = e.target.closest('[data-suite-tabs-trigger]');
                        if (!trigger || trigger.disabled || trigger.hasAttribute('data-disabled')) return;
                        selectTab(trigger.getAttribute('data-suite-tabs-trigger'));
                    });

                    // Keyboard handler — roving focus
                    list.addEventListener('keydown', (e) => {
                        // Suppress arrow nav when modifier keys are pressed
                        if (e.metaKey || e.ctrlKey || e.altKey || e.shiftKey) return;

                        const trigger = e.target.closest('[data-suite-tabs-trigger]');
                        if (!trigger) return;

                        const triggers = getTriggers();
                        const idx = triggers.indexOf(trigger);
                        if (idx === -1) return;

                        const isHoriz = orientation === 'horizontal';
                        const nextKey = isHoriz ? 'ArrowRight' : 'ArrowDown';
                        const prevKey = isHoriz ? 'ArrowLeft' : 'ArrowUp';
                        let target;

                        if (e.key === nextKey) {
                            const next = idx + 1;
                            target = next < triggers.length ? triggers[next] : (loop ? triggers[0] : null);
                        } else if (e.key === prevKey) {
                            const prev = idx - 1;
                            target = prev >= 0 ? triggers[prev] : (loop ? triggers[triggers.length - 1] : null);
                        } else if (e.key === 'Home') {
                            target = triggers[0];
                        } else if (e.key === 'End') {
                            target = triggers[triggers.length - 1];
                        } else if (e.key === 'Enter' || e.key === ' ') {
                            e.preventDefault();
                            selectTab(trigger.getAttribute('data-suite-tabs-trigger'));
                            return;
                        }

                        if (target) {
                            e.preventDefault();
                            target.focus();
                            if (activation === 'automatic') {
                                selectTab(target.getAttribute('data-suite-tabs-trigger'));
                            }
                        }
                    });
                });
            }
        },

        // --- Toggle ---------------------------------------------------------------
        Toggle: {
            /**
             * Initialize standalone toggle buttons.
             * Discovers [data-suite-toggle] elements and wires click→state toggle.
             */
            init() {
                const toggles = document.querySelectorAll('[data-suite-toggle]');
                toggles.forEach(btn => {
                    if (btn._suiteToggle) return;
                    btn._suiteToggle = true;

                    btn.addEventListener('click', () => {
                        if (btn.disabled || btn.hasAttribute('data-disabled')) return;
                        const isOn = btn.getAttribute('data-state') === 'on';
                        const newState = isOn ? 'off' : 'on';
                        btn.setAttribute('data-state', newState);
                        btn.setAttribute('aria-pressed', String(!isOn));
                    });
                });
            }
        },

        // --- Toggle Group ---------------------------------------------------------
        ToggleGroup: {
            /**
             * Initialize toggle groups.
             * Discovers [data-suite-toggle-group] roots. Handles single/multiple selection,
             * ARIA role differences (radio vs pressed), and optional roving focus.
             */
            init() {
                const roots = document.querySelectorAll('[data-suite-toggle-group]');
                roots.forEach(root => {
                    if (root._suiteToggleGroup) return;
                    root._suiteToggleGroup = true;

                    const type = root.getAttribute('data-suite-toggle-group') || 'single';
                    const orientation = root.getAttribute('data-orientation') || 'horizontal';
                    const isDisabled = root.hasAttribute('data-disabled');

                    function getItems() {
                        return Array.from(root.querySelectorAll('[data-suite-toggle-group-item]'))
                            .filter(i => !i.disabled && !i.hasAttribute('data-disabled'));
                    }

                    function updateAria(item, isOn) {
                        item.setAttribute('data-state', isOn ? 'on' : 'off');
                        if (type === 'single') {
                            item.setAttribute('role', 'radio');
                            item.setAttribute('aria-checked', String(isOn));
                            item.removeAttribute('aria-pressed');
                        } else {
                            item.setAttribute('aria-pressed', String(isOn));
                            item.removeAttribute('role');
                            item.removeAttribute('aria-checked');
                        }
                    }

                    // Apply default values
                    const defaultVal = root.getAttribute('data-default-value');
                    if (defaultVal) {
                        const defaults = defaultVal.split(',');
                        root.querySelectorAll('[data-suite-toggle-group-item]').forEach(item => {
                            const val = item.getAttribute('data-suite-toggle-group-item');
                            const isOn = defaults.includes(val);
                            updateAria(item, isOn);
                        });
                    } else {
                        // Initialize ARIA for all items
                        root.querySelectorAll('[data-suite-toggle-group-item]').forEach(item => {
                            updateAria(item, item.getAttribute('data-state') === 'on');
                        });
                    }

                    // Click handler — event delegation
                    root.addEventListener('click', (e) => {
                        if (isDisabled) return;
                        const item = e.target.closest('[data-suite-toggle-group-item]');
                        if (!item || item.disabled || item.hasAttribute('data-disabled')) return;

                        const isOn = item.getAttribute('data-state') === 'on';

                        if (type === 'single') {
                            // Deselect all, select this (or deselect if already on)
                            getItems().forEach(i => updateAria(i, false));
                            if (!isOn) updateAria(item, true);
                        } else {
                            // Multiple — just toggle this item
                            updateAria(item, !isOn);
                        }
                    });

                    // Keyboard — roving focus between items
                    root.addEventListener('keydown', (e) => {
                        if (isDisabled) return;
                        const item = e.target.closest('[data-suite-toggle-group-item]');
                        if (!item) return;

                        const items = getItems();
                        const idx = items.indexOf(item);
                        if (idx === -1) return;

                        const isHoriz = orientation === 'horizontal';
                        const nextKey = isHoriz ? 'ArrowRight' : 'ArrowDown';
                        const prevKey = isHoriz ? 'ArrowLeft' : 'ArrowUp';
                        let target;

                        if (e.key === nextKey) {
                            target = items[(idx + 1) % items.length];
                        } else if (e.key === prevKey) {
                            target = items[(idx - 1 + items.length) % items.length];
                        } else if (e.key === 'Home') {
                            target = items[0];
                        } else if (e.key === 'End') {
                            target = items[items.length - 1];
                        }

                        if (target) {
                            e.preventDefault();
                            target.focus();
                        }
                    });
                });
            }
        },

        // --- Switch ---------------------------------------------------------------
        Switch: {
            /**
             * Initialize switch components.
             * Discovers [data-suite-switch] buttons and wires click→state toggle.
             * Thumb animation handled purely via CSS data-[state] selectors.
             */
            init() {
                const switches = document.querySelectorAll('[data-suite-switch]');
                switches.forEach(btn => {
                    if (btn._suiteSwitch) return;
                    btn._suiteSwitch = true;

                    btn.addEventListener('click', () => {
                        if (btn.disabled || btn.hasAttribute('data-disabled')) return;
                        const isChecked = btn.getAttribute('data-state') === 'checked';
                        const newState = isChecked ? 'unchecked' : 'checked';
                        btn.setAttribute('data-state', newState);
                        btn.setAttribute('aria-checked', String(!isChecked));
                        // Update thumb data-state
                        const thumb = btn.querySelector('span');
                        if (thumb) thumb.setAttribute('data-state', newState);
                    });
                });
            }
        },

        // --- Theme Toggle ---------------------------------------------------------
        ThemeToggle: {
            /**
             * Initialize theme toggle buttons.
             * Discovers elements with data-suite-theme-toggle attribute.
             * Toggles `dark` class on <html> and persists to localStorage.
             */
            init() {
                const toggles = document.querySelectorAll('[data-suite-theme-toggle]');
                toggles.forEach(toggle => {
                    if (toggle._suiteThemeToggle) return; // Already initialized
                    toggle._suiteThemeToggle = true;
                    toggle.addEventListener('click', () => {
                        const isDark = document.documentElement.classList.toggle('dark');
                        try {
                            localStorage.setItem('therapy-theme', isDark ? 'dark' : 'light');
                        } catch (e) {}
                    });
                });
            }
        },

        // --- Auto-Discovery -------------------------------------------------------
        discover() {
            // Scan for data-suite-* attributes and initialize behaviors
            this.ThemeToggle.init();
            this.Collapsible.init();
            this.Accordion.init();
            this.Tabs.init();
            this.Toggle.init();
            this.ToggleGroup.init();
            this.Switch.init();
        },

        // --- Init -----------------------------------------------------------------
        init() {
            this.discover();

            // Re-discover on SPA navigation
            window.addEventListener('therapy:navigate', () => {
                requestAnimationFrame(() => this.discover());
            });
        }
    };

    window.Suite = Suite;
    Suite.init();
})();
