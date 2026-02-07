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

        // --- Focus Guards ---------------------------------------------------------
        FocusGuards: {
            _count: 0,
            install() {
                if (this._count === 0) {
                    const create = () => {
                        const s = document.createElement('span');
                        s.setAttribute('data-suite-focus-guard', '');
                        s.tabIndex = 0;
                        Object.assign(s.style, { outline: 'none', opacity: '0', position: 'fixed', pointerEvents: 'none' });
                        return s;
                    };
                    document.body.insertAdjacentElement('afterbegin', create());
                    document.body.insertAdjacentElement('beforeend', create());
                }
                this._count++;
            },
            uninstall() {
                this._count--;
                if (this._count === 0) {
                    document.querySelectorAll('[data-suite-focus-guard]').forEach(n => n.remove());
                }
            }
        },

        // --- Scroll Lock ----------------------------------------------------------
        ScrollLock: {
            _saved: null,
            _count: 0,
            lock() {
                if (this._count === 0) {
                    const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth;
                    this._saved = {
                        overflow: document.body.style.overflow,
                        paddingRight: document.body.style.paddingRight,
                    };
                    document.body.style.overflow = 'hidden';
                    if (scrollbarWidth > 0) {
                        document.body.style.paddingRight = scrollbarWidth + 'px';
                    }
                }
                this._count++;
            },
            unlock() {
                this._count--;
                if (this._count === 0 && this._saved) {
                    document.body.style.overflow = this._saved.overflow;
                    document.body.style.paddingRight = this._saved.paddingRight;
                    this._saved = null;
                }
            }
        },

        // --- Focus Trap -----------------------------------------------------------
        FocusTrap: {
            _scopes: [],
            _getTabbable(container) {
                const walker = document.createTreeWalker(container, NodeFilter.SHOW_ELEMENT, {
                    acceptNode(node) {
                        if (node.tagName === 'INPUT' && node.type === 'hidden') return NodeFilter.FILTER_SKIP;
                        if (node.disabled || node.hidden) return NodeFilter.FILTER_SKIP;
                        if (node.tabIndex >= 0) return NodeFilter.FILTER_ACCEPT;
                        return NodeFilter.FILTER_SKIP;
                    }
                });
                const result = [];
                while (walker.nextNode()) result.push(walker.currentNode);
                return result;
            },
            _isVisible(el, upTo) {
                if (getComputedStyle(el).visibility === 'hidden') return false;
                let node = el;
                while (node && node !== upTo) {
                    if (getComputedStyle(node).display === 'none') return false;
                    node = node.parentElement;
                }
                return true;
            },
            activate(container, options) {
                options = options || {};
                const previouslyFocused = document.activeElement;
                const scope = { container, paused: false };

                // Pause previous scope
                if (this._scopes.length > 0) this._scopes[this._scopes.length - 1].paused = true;
                this._scopes.push(scope);

                // Auto-focus: first tabbable non-link element, or container
                if (!options.skipAutoFocus) {
                    const tabbable = this._getTabbable(container);
                    const nonLinks = tabbable.filter(el => el.tagName !== 'A' && this._isVisible(el, container));
                    const target = options.initialFocus
                        ? (typeof options.initialFocus === 'function' ? options.initialFocus() : options.initialFocus)
                        : (nonLinks[0] || tabbable[0]);
                    if (target) target.focus({ preventScroll: true });
                    else container.focus({ preventScroll: true });
                }

                // Focusin handler — yank focus back if it escapes
                const onFocusIn = (e) => {
                    if (scope.paused) return;
                    if (container.contains(e.target)) {
                        scope._lastFocused = e.target;
                    } else if (scope._lastFocused) {
                        scope._lastFocused.focus({ preventScroll: true });
                    }
                };

                // Tab key handler — loop focus
                const onKeyDown = (e) => {
                    if (scope.paused) return;
                    if (e.key !== 'Tab' || e.altKey || e.ctrlKey || e.metaKey) return;
                    const tabbable = this._getTabbable(container).filter(el => this._isVisible(el, container));
                    if (tabbable.length === 0) { e.preventDefault(); return; }
                    const first = tabbable[0];
                    const last = tabbable[tabbable.length - 1];
                    if (!e.shiftKey && document.activeElement === last) {
                        e.preventDefault();
                        first.focus({ preventScroll: true });
                    } else if (e.shiftKey && document.activeElement === first) {
                        e.preventDefault();
                        last.focus({ preventScroll: true });
                    }
                };

                document.addEventListener('focusin', onFocusIn);
                container.addEventListener('keydown', onKeyDown);

                return () => {
                    document.removeEventListener('focusin', onFocusIn);
                    container.removeEventListener('keydown', onKeyDown);
                    // Remove scope and resume previous
                    this._scopes = this._scopes.filter(s => s !== scope);
                    if (this._scopes.length > 0) this._scopes[this._scopes.length - 1].paused = false;
                    // Return focus
                    setTimeout(() => {
                        if (previouslyFocused && previouslyFocused.focus) {
                            previouslyFocused.focus({ preventScroll: true });
                        }
                    }, 0);
                };
            }
        },

        // --- Dismiss Layer --------------------------------------------------------
        DismissLayer: {
            _layers: [],
            activate(container, options) {
                options = options || {};
                const onDismiss = options.onDismiss || options;
                const isFunc = typeof onDismiss === 'function';

                this._layers.push(container);

                // Body pointer-events management for modal overlays
                let savedPointerEvents;
                if (options.disableOutsidePointerEvents) {
                    savedPointerEvents = document.body.style.pointerEvents;
                    document.body.style.pointerEvents = 'none';
                    container.style.pointerEvents = 'auto';
                }

                // Escape handler — only top layer responds
                const onKeyDown = (e) => {
                    if (e.key !== 'Escape') return;
                    if (this._layers[this._layers.length - 1] !== container) return;
                    if (options.onEscapeKeyDown) {
                        options.onEscapeKeyDown(e);
                        if (e.defaultPrevented) return;
                    }
                    if (isFunc) onDismiss();
                    else if (options.onDismiss) options.onDismiss();
                };

                // Pointer down outside handler
                let isPointerInside = false;
                const onPointerDownCapture = () => { isPointerInside = true; };
                container.addEventListener('pointerdown', onPointerDownCapture, true);

                const onPointerDown = (e) => {
                    if (isPointerInside) { isPointerInside = false; return; }
                    if (container.contains(e.target)) return;
                    if (options.onPointerDownOutside) {
                        options.onPointerDownOutside(e);
                        if (e.defaultPrevented) return;
                    }
                    if (isFunc) onDismiss();
                    else if (options.onDismiss) options.onDismiss();
                    isPointerInside = false;
                };

                // Delayed registration to prevent the opening click from dismissing
                const timerId = setTimeout(() => {
                    document.addEventListener('pointerdown', onPointerDown);
                }, 0);

                document.addEventListener('keydown', onKeyDown);

                return () => {
                    clearTimeout(timerId);
                    document.removeEventListener('pointerdown', onPointerDown);
                    document.removeEventListener('keydown', onKeyDown);
                    container.removeEventListener('pointerdown', onPointerDownCapture, true);
                    this._layers = this._layers.filter(l => l !== container);
                    if (options.disableOutsidePointerEvents) {
                        if (this._layers.length === 0) {
                            document.body.style.pointerEvents = savedPointerEvents || '';
                        }
                    }
                };
            }
        },

        // --- Floating Positioning -------------------------------------------------
        Floating: {
            /**
             * Position a floating element relative to a reference element.
             * Supports side/align/sideOffset with flip and shift.
             * Sets data-side and data-align for CSS animation targeting.
             */
            position(reference, floating, options = {}) {
                const side = options.side || 'bottom';
                const align = options.align || 'center';
                const sideOffset = options.sideOffset || 0;
                const alignOffset = options.alignOffset || 0;
                const avoidCollisions = options.avoidCollisions !== false;

                function update() {
                    const ref = reference.getBoundingClientRect();
                    const flt = floating.getBoundingClientRect();
                    const vw = window.innerWidth;
                    const vh = window.innerHeight;
                    const pad = 4;

                    // Calculate align offset based on alignment
                    function alignPos(refStart, refSize, fltSize) {
                        if (align === 'start') return refStart + alignOffset;
                        if (align === 'end') return refStart + refSize - fltSize + alignOffset;
                        return refStart + (refSize - fltSize) / 2 + alignOffset;
                    }

                    let top, left, actualSide = side;

                    // Initial position
                    if (side === 'bottom') {
                        top = ref.bottom + sideOffset;
                        left = alignPos(ref.left, ref.width, flt.width);
                    } else if (side === 'top') {
                        top = ref.top - flt.height - sideOffset;
                        left = alignPos(ref.left, ref.width, flt.width);
                    } else if (side === 'right') {
                        left = ref.right + sideOffset;
                        top = alignPos(ref.top, ref.height, flt.height);
                    } else {
                        left = ref.left - flt.width - sideOffset;
                        top = alignPos(ref.top, ref.height, flt.height);
                    }

                    // Flip if collision
                    if (avoidCollisions) {
                        if (actualSide === 'bottom' && top + flt.height > vh - pad) {
                            const flipped = ref.top - flt.height - sideOffset;
                            if (flipped >= pad) { top = flipped; actualSide = 'top'; }
                        } else if (actualSide === 'top' && top < pad) {
                            const flipped = ref.bottom + sideOffset;
                            if (flipped + flt.height <= vh - pad) { top = flipped; actualSide = 'bottom'; }
                        } else if (actualSide === 'right' && left + flt.width > vw - pad) {
                            const flipped = ref.left - flt.width - sideOffset;
                            if (flipped >= pad) { left = flipped; actualSide = 'left'; }
                        } else if (actualSide === 'left' && left < pad) {
                            const flipped = ref.right + sideOffset;
                            if (flipped + flt.width <= vw - pad) { left = flipped; actualSide = 'right'; }
                        }

                        // Shift to keep within viewport
                        left = Math.max(pad, Math.min(left, vw - flt.width - pad));
                        top = Math.max(pad, Math.min(top, vh - flt.height - pad));
                    }

                    floating.style.position = 'fixed';
                    floating.style.top = top + 'px';
                    floating.style.left = left + 'px';
                    floating.setAttribute('data-side', actualSide);
                    floating.setAttribute('data-align', align);

                    // CSS custom properties
                    floating.style.setProperty('--radix-popper-anchor-width', ref.width + 'px');
                    floating.style.setProperty('--radix-popper-anchor-height', ref.height + 'px');
                    floating.style.setProperty('--radix-popper-available-width', (vw - pad * 2) + 'px');
                    floating.style.setProperty('--radix-popper-available-height', (vh - pad * 2) + 'px');
                }

                // Make visible for measurement, position, then show
                floating.style.visibility = 'hidden';
                floating.style.display = '';
                requestAnimationFrame(() => {
                    update();
                    floating.style.visibility = '';
                });

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

        // --- Dialog ---------------------------------------------------------------
        Dialog: {
            init() {
                const triggers = document.querySelectorAll('[data-suite-dialog-trigger]');
                triggers.forEach(trigger => {
                    if (trigger._suiteDialog) return;
                    trigger._suiteDialog = true;

                    const dialogId = trigger.getAttribute('data-suite-dialog-trigger');
                    const root = document.querySelector('[data-suite-dialog="' + dialogId + '"]');
                    if (!root) return;

                    const overlay = root.querySelector('[data-suite-dialog-overlay]');
                    const content = root.querySelector('[data-suite-dialog-content]');
                    if (!content) return;

                    let cleanupFocusTrap, cleanupDismiss;

                    function open() {
                        root.style.display = '';
                        if (overlay) {
                            overlay.setAttribute('data-state', 'open');
                            overlay.style.display = '';
                        }
                        content.setAttribute('data-state', 'open');
                        trigger.setAttribute('data-state', 'open');
                        trigger.setAttribute('aria-expanded', 'true');

                        Suite.ScrollLock.lock();
                        Suite.FocusGuards.install();

                        cleanupFocusTrap = Suite.FocusTrap.activate(content);
                        cleanupDismiss = Suite.DismissLayer.activate(content, {
                            disableOutsidePointerEvents: true,
                            onDismiss: close,
                        });
                    }

                    function close() {
                        if (cleanupDismiss) { cleanupDismiss(); cleanupDismiss = null; }
                        if (cleanupFocusTrap) { cleanupFocusTrap(); cleanupFocusTrap = null; }

                        if (overlay) overlay.setAttribute('data-state', 'closed');
                        content.setAttribute('data-state', 'closed');
                        trigger.setAttribute('data-state', 'closed');
                        trigger.setAttribute('aria-expanded', 'false');

                        Suite.ScrollLock.unlock();
                        Suite.FocusGuards.uninstall();

                        // Wait for close animation before hiding
                        const hide = () => {
                            root.style.display = 'none';
                            if (overlay) overlay.style.display = 'none';
                        };
                        content.addEventListener('animationend', hide, { once: true });
                        setTimeout(hide, 250); // fallback
                    }

                    trigger.addEventListener('click', () => {
                        const isOpen = content.getAttribute('data-state') === 'open';
                        if (isOpen) close(); else open();
                    });

                    // Close buttons inside dialog
                    root.querySelectorAll('[data-suite-dialog-close]').forEach(btn => {
                        btn.addEventListener('click', close);
                    });
                });
            }
        },

        // --- AlertDialog ----------------------------------------------------------
        AlertDialog: {
            init() {
                const triggers = document.querySelectorAll('[data-suite-alert-dialog-trigger]');
                triggers.forEach(trigger => {
                    if (trigger._suiteAlertDialog) return;
                    trigger._suiteAlertDialog = true;

                    const dialogId = trigger.getAttribute('data-suite-alert-dialog-trigger');
                    const root = document.querySelector('[data-suite-alert-dialog="' + dialogId + '"]');
                    if (!root) return;

                    const overlay = root.querySelector('[data-suite-alert-dialog-overlay]');
                    const content = root.querySelector('[data-suite-alert-dialog-content]');
                    if (!content) return;

                    let cleanupFocusTrap, cleanupDismiss;

                    function open() {
                        root.style.display = '';
                        if (overlay) {
                            overlay.setAttribute('data-state', 'open');
                            overlay.style.display = '';
                        }
                        content.setAttribute('data-state', 'open');
                        trigger.setAttribute('data-state', 'open');
                        trigger.setAttribute('aria-expanded', 'true');

                        Suite.ScrollLock.lock();
                        Suite.FocusGuards.install();

                        // Auto-focus Cancel button (not first tabbable)
                        const cancelBtn = content.querySelector('[data-suite-alert-dialog-cancel]');
                        cleanupFocusTrap = Suite.FocusTrap.activate(content, {
                            initialFocus: cancelBtn || undefined
                        });

                        // AlertDialog: Escape and click-outside do NOT dismiss
                        cleanupDismiss = Suite.DismissLayer.activate(content, {
                            disableOutsidePointerEvents: true,
                            onEscapeKeyDown: (e) => e.preventDefault(),
                            onPointerDownOutside: (e) => e.preventDefault(),
                            onDismiss: () => {}, // never auto-dismisses
                        });
                    }

                    function close() {
                        if (cleanupDismiss) { cleanupDismiss(); cleanupDismiss = null; }
                        if (cleanupFocusTrap) { cleanupFocusTrap(); cleanupFocusTrap = null; }

                        if (overlay) overlay.setAttribute('data-state', 'closed');
                        content.setAttribute('data-state', 'closed');
                        trigger.setAttribute('data-state', 'closed');
                        trigger.setAttribute('aria-expanded', 'false');

                        Suite.ScrollLock.unlock();
                        Suite.FocusGuards.uninstall();

                        const hide = () => {
                            root.style.display = 'none';
                            if (overlay) overlay.style.display = 'none';
                        };
                        content.addEventListener('animationend', hide, { once: true });
                        setTimeout(hide, 250);
                    }

                    trigger.addEventListener('click', () => {
                        const isOpen = content.getAttribute('data-state') === 'open';
                        if (isOpen) close(); else open();
                    });

                    // Action and Cancel both close
                    root.querySelectorAll('[data-suite-alert-dialog-action], [data-suite-alert-dialog-cancel]').forEach(btn => {
                        btn.addEventListener('click', close);
                    });
                });
            }
        },

        // --- Sheet ----------------------------------------------------------------
        Sheet: {
            init() {
                // Sheet reuses Dialog's exact JS behavior — FocusTrap, DismissLayer, ScrollLock.
                // The only difference is CSS (slide from edge vs center zoom).
                const triggers = document.querySelectorAll('[data-suite-sheet-trigger]');
                triggers.forEach(trigger => {
                    if (trigger._suiteSheet) return;
                    trigger._suiteSheet = true;

                    const sheetId = trigger.getAttribute('data-suite-sheet-trigger');
                    const root = document.querySelector('[data-suite-sheet="' + sheetId + '"]');
                    if (!root) return;

                    const overlay = root.querySelector('[data-suite-sheet-overlay]');
                    const content = root.querySelector('[data-suite-sheet-content]');
                    if (!content) return;

                    let cleanupFocusTrap, cleanupDismiss;

                    function open() {
                        root.style.display = '';
                        if (overlay) {
                            overlay.setAttribute('data-state', 'open');
                            overlay.style.display = '';
                        }
                        content.setAttribute('data-state', 'open');
                        trigger.setAttribute('data-state', 'open');
                        trigger.setAttribute('aria-expanded', 'true');

                        Suite.ScrollLock.lock();
                        Suite.FocusGuards.install();

                        cleanupFocusTrap = Suite.FocusTrap.activate(content);
                        cleanupDismiss = Suite.DismissLayer.activate(content, {
                            disableOutsidePointerEvents: true,
                            onDismiss: close,
                        });
                    }

                    function close() {
                        if (cleanupDismiss) { cleanupDismiss(); cleanupDismiss = null; }
                        if (cleanupFocusTrap) { cleanupFocusTrap(); cleanupFocusTrap = null; }

                        if (overlay) overlay.setAttribute('data-state', 'closed');
                        content.setAttribute('data-state', 'closed');
                        trigger.setAttribute('data-state', 'closed');
                        trigger.setAttribute('aria-expanded', 'false');

                        Suite.ScrollLock.unlock();
                        Suite.FocusGuards.uninstall();

                        const hide = () => {
                            root.style.display = 'none';
                            if (overlay) overlay.style.display = 'none';
                        };
                        content.addEventListener('animationend', hide, { once: true });
                        setTimeout(hide, 350); // longer fallback for slide animations (300-500ms)
                    }

                    trigger.addEventListener('click', () => {
                        const isOpen = content.getAttribute('data-state') === 'open';
                        if (isOpen) close(); else open();
                    });

                    // Close buttons inside sheet
                    root.querySelectorAll('[data-suite-sheet-close]').forEach(btn => {
                        btn.addEventListener('click', close);
                    });
                });
            }
        },

        // --- Drawer ---------------------------------------------------------------
        Drawer: {
            VELOCITY_THRESHOLD: 0.4,
            CLOSE_THRESHOLD: 0.25,

            init() {
                const triggers = document.querySelectorAll('[data-suite-drawer-trigger]');
                triggers.forEach(trigger => {
                    if (trigger._suiteDrawer) return;
                    trigger._suiteDrawer = true;

                    const drawerId = trigger.getAttribute('data-suite-drawer-trigger');
                    const root = document.querySelector('[data-suite-drawer="' + drawerId + '"]');
                    if (!root) return;

                    const overlay = root.querySelector('[data-suite-drawer-overlay]');
                    const content = root.querySelector('[data-suite-drawer-content]');
                    if (!content) return;

                    const direction = content.getAttribute('data-suite-drawer-direction') || 'bottom';
                    const isVertical = direction === 'bottom' || direction === 'top';

                    let cleanupFocusTrap, cleanupDismiss;
                    let isDragging = false;
                    let dragStart = 0;
                    let dragStartTime = 0;
                    let drawerSize = 0;

                    function open() {
                        root.style.display = '';
                        if (overlay) {
                            overlay.setAttribute('data-state', 'open');
                            overlay.style.display = '';
                        }
                        content.setAttribute('data-state', 'open');
                        content.style.transform = '';
                        content.style.transition = '';
                        trigger.setAttribute('data-state', 'open');
                        trigger.setAttribute('aria-expanded', 'true');

                        Suite.ScrollLock.lock();
                        Suite.FocusGuards.install();

                        cleanupFocusTrap = Suite.FocusTrap.activate(content);
                        cleanupDismiss = Suite.DismissLayer.activate(content, {
                            disableOutsidePointerEvents: true,
                            onDismiss: close,
                        });
                    }

                    function close() {
                        if (cleanupDismiss) { cleanupDismiss(); cleanupDismiss = null; }
                        if (cleanupFocusTrap) { cleanupFocusTrap(); cleanupFocusTrap = null; }

                        // Animate out in the correct direction
                        const rect = content.getBoundingClientRect();
                        let transform = '';
                        if (direction === 'bottom') transform = 'translateY(' + rect.height + 'px)';
                        else if (direction === 'top') transform = 'translateY(-' + rect.height + 'px)';
                        else if (direction === 'right') transform = 'translateX(' + rect.width + 'px)';
                        else if (direction === 'left') transform = 'translateX(-' + rect.width + 'px)';

                        content.style.transition = 'transform 0.5s cubic-bezier(0.32, 0.72, 0, 1)';
                        content.style.transform = transform;
                        if (overlay) {
                            overlay.setAttribute('data-state', 'closed');
                        }
                        trigger.setAttribute('data-state', 'closed');
                        trigger.setAttribute('aria-expanded', 'false');

                        Suite.ScrollLock.unlock();
                        Suite.FocusGuards.uninstall();

                        const hide = () => {
                            root.style.display = 'none';
                            if (overlay) overlay.style.display = 'none';
                            content.setAttribute('data-state', 'closed');
                            content.style.transform = '';
                            content.style.transition = '';
                        };
                        content.addEventListener('transitionend', hide, { once: true });
                        setTimeout(hide, 600);
                    }

                    // --- Drag-to-dismiss ---
                    content.addEventListener('pointerdown', (e) => {
                        // Don't drag on select elements or elements with data-vaul-no-drag
                        if (e.target.closest('select, [data-no-drag]')) return;
                        // Don't drag scrollable children that have scroll offset
                        const scrollable = e.target.closest('[style*="overflow"]');
                        if (scrollable && scrollable.scrollTop > 0) return;

                        isDragging = true;
                        dragStart = isVertical ? e.clientY : e.clientX;
                        dragStartTime = Date.now();
                        drawerSize = isVertical ? content.getBoundingClientRect().height : content.getBoundingClientRect().width;
                        content.style.transition = 'none';
                        content.setPointerCapture(e.pointerId);
                    });

                    content.addEventListener('pointermove', (e) => {
                        if (!isDragging) return;
                        const current = isVertical ? e.clientY : e.clientX;
                        let delta = current - dragStart;

                        // Flip direction for top/left
                        if (direction === 'top' || direction === 'left') delta = -delta;

                        if (delta < 0) {
                            // Dragging past open — logarithmic damping
                            const damped = -8 * (Math.log(Math.abs(delta) + 1) - 2);
                            if (isVertical) {
                                content.style.transform = direction === 'bottom'
                                    ? 'translateY(' + Math.max(damped, -20) + 'px)'
                                    : 'translateY(' + Math.min(-damped, 20) + 'px)';
                            } else {
                                content.style.transform = direction === 'right'
                                    ? 'translateX(' + Math.max(damped, -20) + 'px)'
                                    : 'translateX(' + Math.min(-damped, 20) + 'px)';
                            }
                        } else {
                            // Dragging toward dismiss — linear
                            if (isVertical) {
                                content.style.transform = direction === 'bottom'
                                    ? 'translateY(' + delta + 'px)'
                                    : 'translateY(-' + delta + 'px)';
                            } else {
                                content.style.transform = direction === 'right'
                                    ? 'translateX(' + delta + 'px)'
                                    : 'translateX(-' + delta + 'px)';
                            }

                            // Fade overlay proportionally
                            if (overlay) {
                                const pct = 1 - (delta / drawerSize);
                                overlay.style.opacity = Math.max(0, Math.min(1, pct));
                            }
                        }
                    });

                    content.addEventListener('pointerup', (e) => {
                        if (!isDragging) return;
                        isDragging = false;

                        const current = isVertical ? e.clientY : e.clientX;
                        let delta = current - dragStart;
                        if (direction === 'top' || direction === 'left') delta = -delta;

                        const elapsed = (Date.now() - dragStartTime) / 1000; // seconds
                        const velocity = Math.abs(delta) / elapsed / 1000; // px/ms

                        // Reset overlay opacity
                        if (overlay) overlay.style.opacity = '';

                        if (delta <= 0) {
                            // Dragged past open — spring back
                            content.style.transition = 'transform 0.5s cubic-bezier(0.32, 0.72, 0, 1)';
                            content.style.transform = '';
                            return;
                        }

                        const visibleSize = Math.min(drawerSize, isVertical ? window.innerHeight : window.innerWidth);

                        if (velocity > Suite.Drawer.VELOCITY_THRESHOLD || delta >= visibleSize * Suite.Drawer.CLOSE_THRESHOLD) {
                            close();
                        } else {
                            // Spring back
                            content.style.transition = 'transform 0.5s cubic-bezier(0.32, 0.72, 0, 1)';
                            content.style.transform = '';
                        }
                    });

                    trigger.addEventListener('click', () => {
                        const isOpen = content.getAttribute('data-state') === 'open';
                        if (isOpen) close(); else open();
                    });

                    // Close buttons
                    root.querySelectorAll('[data-suite-drawer-close]').forEach(btn => {
                        btn.addEventListener('click', close);
                    });
                });
            }
        },

        // --- Popover --------------------------------------------------------------
        Popover: {
            init() {
                const triggers = document.querySelectorAll('[data-suite-popover-trigger]');
                triggers.forEach(trigger => {
                    if (trigger._suitePopover) return;
                    trigger._suitePopover = true;

                    const popId = trigger.getAttribute('data-suite-popover-trigger');
                    const root = document.querySelector('[data-suite-popover="' + popId + '"]');
                    if (!root) return;

                    const content = root.querySelector('[data-suite-popover-content]');
                    if (!content) return;

                    const side = content.getAttribute('data-side-preference') || 'bottom';
                    const sideOffset = parseInt(content.getAttribute('data-side-offset') || '0', 10);
                    const align = content.getAttribute('data-align-preference') || 'center';

                    let cleanupFloat, cleanupDismiss, cleanupFocusTrap;

                    function open() {
                        root.style.display = '';
                        content.setAttribute('data-state', 'open');
                        trigger.setAttribute('data-state', 'open');
                        trigger.setAttribute('aria-expanded', 'true');

                        cleanupFloat = Suite.Floating.position(trigger, content, {
                            side: side, sideOffset: sideOffset, align: align
                        });

                        Suite.ScrollLock.lock();
                        Suite.FocusGuards.install();
                        cleanupFocusTrap = Suite.FocusTrap.activate(content);
                        cleanupDismiss = Suite.DismissLayer.activate(content, {
                            disableOutsidePointerEvents: true,
                            onDismiss: close,
                        });
                    }

                    function close() {
                        if (cleanupDismiss) { cleanupDismiss(); cleanupDismiss = null; }
                        if (cleanupFocusTrap) { cleanupFocusTrap(); cleanupFocusTrap = null; }
                        if (cleanupFloat) { cleanupFloat(); cleanupFloat = null; }

                        content.setAttribute('data-state', 'closed');
                        trigger.setAttribute('data-state', 'closed');
                        trigger.setAttribute('aria-expanded', 'false');

                        Suite.ScrollLock.unlock();
                        Suite.FocusGuards.uninstall();

                        const hide = () => { root.style.display = 'none'; };
                        content.addEventListener('animationend', hide, { once: true });
                        setTimeout(hide, 250);
                    }

                    trigger.addEventListener('click', () => {
                        const isOpen = content.getAttribute('data-state') === 'open';
                        if (isOpen) close(); else open();
                    });

                    root.querySelectorAll('[data-suite-popover-close]').forEach(btn => {
                        btn.addEventListener('click', close);
                    });
                });
            }
        },

        // --- Tooltip --------------------------------------------------------------
        Tooltip: {
            // Provider-level delay state (shared across all tooltips)
            _isOpenDelayed: true,
            _skipTimer: null,
            _DEFAULT_DELAY: 700,
            _SKIP_DELAY: 300,

            init() {
                const roots = document.querySelectorAll('[data-suite-tooltip]');
                roots.forEach(root => {
                    if (root._suiteTooltip) return;
                    root._suiteTooltip = true;

                    const trigger = root.querySelector('[data-suite-tooltip-trigger]');
                    const content = root.querySelector('[data-suite-tooltip-content]');
                    if (!trigger || !content) return;

                    const side = content.getAttribute('data-side-preference') || 'top';
                    const sideOffset = parseInt(content.getAttribute('data-side-offset') || '4', 10);
                    const align = content.getAttribute('data-align-preference') || 'center';
                    const delay = parseInt(root.getAttribute('data-delay') || String(Suite.Tooltip._DEFAULT_DELAY), 10);

                    let openTimer = null;
                    let cleanupFloat = null;
                    let isOpen = false;

                    function show() {
                        if (isOpen) return;
                        isOpen = true;

                        root.style.display = '';
                        content.setAttribute('data-state', 'instant-open');
                        trigger.setAttribute('data-state', 'open');

                        cleanupFloat = Suite.Floating.position(trigger, content, {
                            side: side, sideOffset: sideOffset, align: align
                        });

                        // Set describedby
                        const contentId = content.id || ('suite-tooltip-' + Math.random().toString(36).slice(2, 8));
                        content.id = contentId;
                        trigger.setAttribute('aria-describedby', contentId);

                        // Tooltip Provider: mark as not delayed for quick subsequent tooltips
                        Suite.Tooltip._isOpenDelayed = false;
                        clearTimeout(Suite.Tooltip._skipTimer);
                    }

                    function hide() {
                        if (!isOpen) return;
                        isOpen = false;
                        clearTimeout(openTimer);

                        content.setAttribute('data-state', 'closed');
                        trigger.setAttribute('data-state', 'closed');
                        trigger.removeAttribute('aria-describedby');

                        if (cleanupFloat) { cleanupFloat(); cleanupFloat = null; }

                        const doHide = () => { root.style.display = 'none'; };
                        content.addEventListener('animationend', doHide, { once: true });
                        setTimeout(doHide, 200);

                        // Provider: start skip delay timer
                        Suite.Tooltip._skipTimer = setTimeout(() => {
                            Suite.Tooltip._isOpenDelayed = true;
                        }, Suite.Tooltip._SKIP_DELAY);
                    }

                    // Hover handlers
                    trigger.addEventListener('pointerenter', (e) => {
                        if (e.pointerType === 'touch') return;
                        clearTimeout(openTimer);
                        if (Suite.Tooltip._isOpenDelayed) {
                            openTimer = setTimeout(show, delay);
                        } else {
                            show();
                        }
                    });

                    trigger.addEventListener('pointerleave', (e) => {
                        if (e.pointerType === 'touch') return;
                        clearTimeout(openTimer);
                        hide();
                    });

                    // Keep tooltip open when hovering content
                    content.addEventListener('pointerenter', () => { clearTimeout(openTimer); });
                    content.addEventListener('pointerleave', () => { hide(); });

                    // Focus handlers — instant open (no delay)
                    trigger.addEventListener('focus', (e) => {
                        // Don't open on focus from pointer (already handled by pointer)
                        if (e.sourceCapabilities) return; // pointer-originated focus
                        show();
                    });
                    trigger.addEventListener('blur', () => { hide(); });

                    // Escape dismisses
                    trigger.addEventListener('keydown', (e) => {
                        if (e.key === 'Escape' && isOpen) hide();
                    });

                    // Click closes
                    trigger.addEventListener('pointerdown', () => {
                        if (isOpen) hide();
                    });
                });
            }
        },

        // --- HoverCard ------------------------------------------------------------
        HoverCard: {
            init() {
                const roots = document.querySelectorAll('[data-suite-hover-card]');
                roots.forEach(root => {
                    if (root._suiteHoverCard) return;
                    root._suiteHoverCard = true;

                    const trigger = root.querySelector('[data-suite-hover-card-trigger]');
                    const content = root.querySelector('[data-suite-hover-card-content]');
                    if (!trigger || !content) return;

                    const side = content.getAttribute('data-side-preference') || 'bottom';
                    const sideOffset = parseInt(content.getAttribute('data-side-offset') || '4', 10);
                    const align = content.getAttribute('data-align-preference') || 'center';
                    const openDelay = parseInt(root.getAttribute('data-open-delay') || '700', 10);
                    const closeDelay = parseInt(root.getAttribute('data-close-delay') || '300', 10);

                    let openTimer = null;
                    let closeTimer = null;
                    let cleanupFloat = null;
                    let cleanupDismiss = null;
                    let isOpen = false;

                    function open() {
                        if (isOpen) return;
                        isOpen = true;

                        root.style.display = '';
                        content.setAttribute('data-state', 'open');
                        trigger.setAttribute('data-state', 'open');

                        cleanupFloat = Suite.Floating.position(trigger, content, {
                            side: side, sideOffset: sideOffset, align: align
                        });
                        cleanupDismiss = Suite.DismissLayer.activate(content, {
                            onDismiss: close,
                        });
                    }

                    function close() {
                        if (!isOpen) return;
                        isOpen = false;
                        clearTimeout(openTimer);
                        clearTimeout(closeTimer);

                        if (cleanupDismiss) { cleanupDismiss(); cleanupDismiss = null; }
                        if (cleanupFloat) { cleanupFloat(); cleanupFloat = null; }

                        content.setAttribute('data-state', 'closed');
                        trigger.setAttribute('data-state', 'closed');

                        const doHide = () => { root.style.display = 'none'; };
                        content.addEventListener('animationend', doHide, { once: true });
                        setTimeout(doHide, 250);
                    }

                    function startOpen() {
                        clearTimeout(closeTimer);
                        openTimer = setTimeout(open, openDelay);
                    }

                    function startClose() {
                        clearTimeout(openTimer);
                        closeTimer = setTimeout(close, closeDelay);
                    }

                    // Trigger hover
                    trigger.addEventListener('pointerenter', (e) => {
                        if (e.pointerType === 'touch') return;
                        startOpen();
                    });
                    trigger.addEventListener('pointerleave', (e) => {
                        if (e.pointerType === 'touch') return;
                        startClose();
                    });

                    // Content hover — keep open
                    content.addEventListener('pointerenter', () => { clearTimeout(closeTimer); });
                    content.addEventListener('pointerleave', () => { startClose(); });

                    // Focus
                    trigger.addEventListener('focus', () => { startOpen(); });
                    trigger.addEventListener('blur', () => { startClose(); });

                    // Touch prevention
                    trigger.addEventListener('touchstart', (e) => { e.preventDefault(); });
                });
            }
        },

        // --- Menu (shared base) ---------------------------------------------------
        Menu: {
            /**
             * Shared menu behavior for DropdownMenu, ContextMenu, Menubar.
             * Handles keyboard navigation, typeahead, item highlighting,
             * checkbox/radio items, sub-menus, and grace area.
             */

            /**
             * Activate menu behavior on a content element.
             * @param {HTMLElement} content - The menu content container (role=menu)
             * @param {Object} options - { onClose, isSubmenu }
             * @returns {Function} cleanup
             */
            activate(content, options = {}) {
                const onClose = options.onClose || (() => {});
                const isSubmenu = options.isSubmenu || false;

                // Typeahead state
                let searchBuffer = '';
                let searchTimer = null;

                function getItems() {
                    return Array.from(content.querySelectorAll(
                        '[data-suite-menu-item], [data-suite-menu-checkbox-item], [data-suite-menu-radio-item], [data-suite-menu-sub-trigger]'
                    )).filter(el => !el.hasAttribute('data-disabled') && !el.closest('[data-suite-menu-sub-content]'));
                }

                function focusItem(item) {
                    // Remove highlight from all
                    getItems().forEach(i => i.removeAttribute('data-highlighted'));
                    if (item) {
                        item.setAttribute('data-highlighted', '');
                        item.focus({ preventScroll: true });
                    }
                }

                function focusFirst() {
                    const items = getItems();
                    if (items.length > 0) focusItem(items[0]);
                }

                function focusLast() {
                    const items = getItems();
                    if (items.length > 0) focusItem(items[items.length - 1]);
                }

                // Typeahead search
                function getNextMatch(values, search, currentMatch) {
                    // Normalize repeated chars: 'aaa' → 'a'
                    const chars = search.split('');
                    const allSame = chars.every(c => c === chars[0]);
                    const normalized = allSame ? chars[0] : search;

                    let candidates = values;
                    if (currentMatch) {
                        const idx = values.indexOf(currentMatch);
                        if (idx >= 0) {
                            // Wrap array from current position + 1
                            candidates = [...values.slice(idx + 1), ...values.slice(0, idx + 1)];
                        }
                    }

                    if (normalized.length === 1) {
                        // Single char: exclude current match to cycle
                        return candidates.find(v =>
                            v.toLowerCase().startsWith(normalized.toLowerCase()) &&
                            v !== currentMatch
                        ) || candidates.find(v =>
                            v.toLowerCase().startsWith(normalized.toLowerCase())
                        );
                    }
                    return candidates.find(v =>
                        v.toLowerCase().startsWith(normalized.toLowerCase())
                    );
                }

                function handleTypeahead(key) {
                    searchBuffer += key;
                    clearTimeout(searchTimer);
                    searchTimer = setTimeout(() => { searchBuffer = ''; }, 1000);

                    const items = getItems();
                    const textValues = items.map(el =>
                        el.getAttribute('data-text-value') || el.textContent.trim()
                    );
                    const currentItem = content.querySelector('[data-highlighted]');
                    const currentText = currentItem
                        ? (currentItem.getAttribute('data-text-value') || currentItem.textContent.trim())
                        : undefined;
                    const match = getNextMatch(textValues, searchBuffer, currentText);
                    if (match) {
                        const idx = textValues.indexOf(match);
                        if (idx >= 0) focusItem(items[idx]);
                    }
                }

                function selectItem(item) {
                    if (!item || item.hasAttribute('data-disabled')) return;

                    // CheckboxItem toggle
                    if (item.hasAttribute('data-suite-menu-checkbox-item')) {
                        const checked = item.getAttribute('data-state') === 'checked';
                        const newState = checked ? 'unchecked' : 'checked';
                        item.setAttribute('data-state', newState);
                        item.setAttribute('aria-checked', String(!checked));
                        const indicator = item.querySelector('[data-suite-menu-item-indicator]');
                        if (indicator) indicator.style.display = checked ? 'none' : '';
                        return; // Don't close menu for checkbox
                    }

                    // RadioItem select
                    if (item.hasAttribute('data-suite-menu-radio-item')) {
                        const group = item.closest('[data-suite-menu-radio-group]');
                        if (group) {
                            group.querySelectorAll('[data-suite-menu-radio-item]').forEach(ri => {
                                ri.setAttribute('data-state', 'unchecked');
                                ri.setAttribute('aria-checked', 'false');
                                const ind = ri.querySelector('[data-suite-menu-item-indicator]');
                                if (ind) ind.style.display = 'none';
                            });
                        }
                        item.setAttribute('data-state', 'checked');
                        item.setAttribute('aria-checked', 'true');
                        const indicator = item.querySelector('[data-suite-menu-item-indicator]');
                        if (indicator) indicator.style.display = '';
                        return; // Don't close menu for radio
                    }

                    // SubTrigger — open sub-menu instead of selecting
                    if (item.hasAttribute('data-suite-menu-sub-trigger')) {
                        openSubmenu(item);
                        return;
                    }

                    // Regular item — close menu after selection
                    setTimeout(() => onClose(), 0);
                }

                function openSubmenu(subTrigger) {
                    const subContent = subTrigger.parentElement &&
                        subTrigger.parentElement.querySelector('[data-suite-menu-sub-content]');
                    if (!subContent) return;

                    subTrigger.setAttribute('data-state', 'open');
                    subContent.style.display = '';
                    subContent.setAttribute('data-state', 'open');

                    // Position sub-menu
                    Suite.Floating.position(subTrigger, subContent, {
                        side: 'right', sideOffset: -4, align: 'start'
                    });

                    // Activate sub-menu behavior
                    const subCleanup = Suite.Menu.activate(subContent, {
                        onClose: () => {
                            closeSubmenu(subTrigger, subContent);
                            subCleanup();
                        },
                        isSubmenu: true,
                    });

                    // Focus first item in sub-menu
                    requestAnimationFrame(() => {
                        const subItems = Array.from(subContent.querySelectorAll(
                            '[data-suite-menu-item], [data-suite-menu-checkbox-item], [data-suite-menu-radio-item]'
                        )).filter(el => !el.hasAttribute('data-disabled'));
                        if (subItems.length > 0) {
                            subItems[0].setAttribute('data-highlighted', '');
                            subItems[0].focus({ preventScroll: true });
                        }
                    });

                    // Store cleanup for later
                    subTrigger._subCleanup = subCleanup;
                    subTrigger._subContent = subContent;
                }

                function closeSubmenu(subTrigger, subContent) {
                    if (!subContent) return;
                    subTrigger.setAttribute('data-state', 'closed');
                    subContent.setAttribute('data-state', 'closed');
                    subContent.style.display = 'none';
                    // Remove highlights in sub-menu
                    subContent.querySelectorAll('[data-highlighted]').forEach(el => el.removeAttribute('data-highlighted'));
                    if (subTrigger._subCleanup) {
                        subTrigger._subCleanup();
                        subTrigger._subCleanup = null;
                    }
                }

                // Keyboard handler
                function onKeyDown(e) {
                    const items = getItems();
                    const currentItem = content.querySelector('[data-highlighted]');
                    const idx = currentItem ? items.indexOf(currentItem) : -1;

                    // Tab — prevent (menus never support Tab)
                    if (e.key === 'Tab') {
                        e.preventDefault();
                        return;
                    }

                    // Escape — close (handled by DismissLayer, but also close sub-menus)
                    if (e.key === 'Escape') {
                        if (isSubmenu) {
                            e.stopPropagation();
                            onClose();
                        }
                        return;
                    }

                    // Arrow navigation
                    if (e.key === 'ArrowDown') {
                        e.preventDefault();
                        const next = idx < items.length - 1 ? idx + 1 : 0;
                        focusItem(items[next]);
                        return;
                    }
                    if (e.key === 'ArrowUp') {
                        e.preventDefault();
                        const prev = idx > 0 ? idx - 1 : items.length - 1;
                        focusItem(items[prev]);
                        return;
                    }
                    if (e.key === 'Home' || e.key === 'PageUp') {
                        e.preventDefault();
                        focusFirst();
                        return;
                    }
                    if (e.key === 'End' || e.key === 'PageDown') {
                        e.preventDefault();
                        focusLast();
                        return;
                    }

                    // ArrowRight — open sub-menu
                    if (e.key === 'ArrowRight' && currentItem && currentItem.hasAttribute('data-suite-menu-sub-trigger')) {
                        e.preventDefault();
                        openSubmenu(currentItem);
                        return;
                    }

                    // ArrowLeft — close sub-menu (return to parent)
                    if (e.key === 'ArrowLeft' && isSubmenu) {
                        e.preventDefault();
                        onClose();
                        return;
                    }

                    // Enter/Space — select item
                    if (e.key === 'Enter' || (e.key === ' ' && searchBuffer === '')) {
                        e.preventDefault();
                        if (currentItem) selectItem(currentItem);
                        return;
                    }

                    // Typeahead — any printable character
                    if (e.key.length === 1 && !e.ctrlKey && !e.altKey && !e.metaKey) {
                        e.preventDefault();
                        handleTypeahead(e.key);
                    }
                }

                // Pointer handlers — highlight on hover
                function onPointerMove(e) {
                    if (e.pointerType === 'touch' || e.pointerType === 'pen') return;
                    const item = e.target.closest(
                        '[data-suite-menu-item], [data-suite-menu-checkbox-item], [data-suite-menu-radio-item], [data-suite-menu-sub-trigger]'
                    );
                    if (item && !item.hasAttribute('data-disabled') && content.contains(item) && !item.closest('[data-suite-menu-sub-content]')) {
                        focusItem(item);
                    }
                }

                function onPointerLeave(e) {
                    if (e.pointerType === 'touch' || e.pointerType === 'pen') return;
                    // Clear highlight, refocus content
                    getItems().forEach(i => i.removeAttribute('data-highlighted'));
                    content.focus({ preventScroll: true });
                }

                // Click handler — select on click
                function onClick(e) {
                    const item = e.target.closest(
                        '[data-suite-menu-item], [data-suite-menu-checkbox-item], [data-suite-menu-radio-item], [data-suite-menu-sub-trigger]'
                    );
                    if (item && content.contains(item) && !item.closest('[data-suite-menu-sub-content]')) {
                        selectItem(item);
                    }
                }

                content.addEventListener('keydown', onKeyDown);
                content.addEventListener('pointermove', onPointerMove);
                content.addEventListener('pointerleave', onPointerLeave);
                content.addEventListener('click', onClick);

                return function cleanup() {
                    content.removeEventListener('keydown', onKeyDown);
                    content.removeEventListener('pointermove', onPointerMove);
                    content.removeEventListener('pointerleave', onPointerLeave);
                    content.removeEventListener('click', onClick);
                    clearTimeout(searchTimer);
                    searchBuffer = '';
                    // Cleanup any open sub-menus
                    content.querySelectorAll('[data-suite-menu-sub-trigger]').forEach(st => {
                        if (st._subCleanup) { st._subCleanup(); st._subCleanup = null; }
                    });
                };
            }
        },

        // --- DropdownMenu ---------------------------------------------------------
        DropdownMenu: {
            init() {
                const roots = document.querySelectorAll('[data-suite-dropdown-menu]');
                roots.forEach(root => {
                    if (root._suiteDropdownMenu) return;
                    root._suiteDropdownMenu = true;

                    const trigger = root.querySelector('[data-suite-dropdown-menu-trigger]');
                    const content = root.querySelector('[data-suite-dropdown-menu-content]');
                    if (!trigger || !content) return;

                    const side = content.getAttribute('data-side-preference') || 'bottom';
                    const sideOffset = parseInt(content.getAttribute('data-side-offset') || '4', 10);
                    const align = content.getAttribute('data-align-preference') || 'start';

                    let cleanupFloat, cleanupDismiss, cleanupMenu;
                    let isOpen = false;
                    let wasKeyboardOpen = false;

                    // Track keyboard vs pointer globally
                    let isUsingKeyboard = false;
                    function onDocKeyDown() { isUsingKeyboard = true; }
                    function onDocPointer() { isUsingKeyboard = false; }
                    document.addEventListener('keydown', onDocKeyDown, true);
                    document.addEventListener('pointerdown', onDocPointer, true);

                    function open(focusFirst) {
                        if (isOpen) return;
                        isOpen = true;
                        wasKeyboardOpen = focusFirst;

                        root.style.display = '';
                        content.style.display = '';
                        content.setAttribute('data-state', 'open');
                        trigger.setAttribute('data-state', 'open');
                        trigger.setAttribute('aria-expanded', 'true');

                        cleanupFloat = Suite.Floating.position(trigger, content, {
                            side: side, sideOffset: sideOffset, align: align
                        });

                        Suite.ScrollLock.lock();
                        Suite.FocusGuards.install();

                        cleanupMenu = Suite.Menu.activate(content, {
                            onClose: close,
                        });

                        cleanupDismiss = Suite.DismissLayer.activate(content, {
                            disableOutsidePointerEvents: true,
                            onDismiss: close,
                        });

                        // Focus first item if keyboard-triggered
                        if (focusFirst) {
                            requestAnimationFrame(() => {
                                const items = Array.from(content.querySelectorAll(
                                    '[data-suite-menu-item], [data-suite-menu-checkbox-item], [data-suite-menu-radio-item], [data-suite-menu-sub-trigger]'
                                )).filter(el => !el.hasAttribute('data-disabled') && !el.closest('[data-suite-menu-sub-content]'));
                                if (items.length > 0) {
                                    items[0].setAttribute('data-highlighted', '');
                                    items[0].focus({ preventScroll: true });
                                }
                            });
                        }
                    }

                    function close() {
                        if (!isOpen) return;
                        isOpen = false;

                        if (cleanupMenu) { cleanupMenu(); cleanupMenu = null; }
                        if (cleanupDismiss) { cleanupDismiss(); cleanupDismiss = null; }
                        if (cleanupFloat) { cleanupFloat(); cleanupFloat = null; }

                        content.setAttribute('data-state', 'closed');
                        trigger.setAttribute('data-state', 'closed');
                        trigger.setAttribute('aria-expanded', 'false');

                        Suite.ScrollLock.unlock();
                        Suite.FocusGuards.uninstall();

                        // Remove highlights
                        content.querySelectorAll('[data-highlighted]').forEach(el => el.removeAttribute('data-highlighted'));

                        const hide = () => {
                            content.style.display = 'none';
                        };
                        content.addEventListener('animationend', hide, { once: true });
                        setTimeout(hide, 250);

                        // Return focus to trigger
                        trigger.focus({ preventScroll: true });
                    }

                    // Trigger click
                    trigger.addEventListener('pointerdown', (e) => {
                        if (e.button !== 0) return; // left click only
                        if (e.ctrlKey && navigator.platform.match(/Mac/)) return; // ctrl+click on Mac
                        e.preventDefault();
                        if (isOpen) close(); else open(false);
                    });

                    // Trigger keyboard
                    trigger.addEventListener('keydown', (e) => {
                        if (e.key === 'ArrowDown') {
                            e.preventDefault();
                            if (!isOpen) open(true);
                        } else if (e.key === 'Enter' || e.key === ' ') {
                            e.preventDefault();
                            if (isOpen) close(); else open(true);
                        }
                    });
                });
            }
        },

        // --- ContextMenu ----------------------------------------------------------
        ContextMenu: {
            init() {
                const roots = document.querySelectorAll('[data-suite-context-menu]');
                roots.forEach(root => {
                    if (root._suiteContextMenu) return;
                    root._suiteContextMenu = true;

                    const triggerEl = root.querySelector('[data-suite-context-menu-trigger]');
                    const content = root.querySelector('[data-suite-context-menu-content]');
                    if (!triggerEl || !content) return;

                    let cleanupFloat, cleanupDismiss, cleanupMenu;
                    let isOpen = false;
                    let longPressTimer = null;

                    function openAtPosition(x, y) {
                        if (isOpen) close();
                        isOpen = true;

                        root.style.display = '';
                        content.style.display = '';
                        content.setAttribute('data-state', 'open');

                        // Create virtual anchor at pointer position
                        const virtualAnchor = {
                            getBoundingClientRect() {
                                return { width: 0, height: 0, top: y, right: x, bottom: y, left: x, x: x, y: y };
                            }
                        };

                        cleanupFloat = Suite.Floating.position(virtualAnchor, content, {
                            side: 'right', sideOffset: 2, align: 'start'
                        });

                        Suite.ScrollLock.lock();
                        Suite.FocusGuards.install();

                        cleanupMenu = Suite.Menu.activate(content, { onClose: close });

                        cleanupDismiss = Suite.DismissLayer.activate(content, {
                            disableOutsidePointerEvents: true,
                            onDismiss: close,
                        });

                        // Focus first item
                        requestAnimationFrame(() => {
                            const items = Array.from(content.querySelectorAll(
                                '[data-suite-menu-item], [data-suite-menu-checkbox-item], [data-suite-menu-radio-item], [data-suite-menu-sub-trigger]'
                            )).filter(el => !el.hasAttribute('data-disabled') && !el.closest('[data-suite-menu-sub-content]'));
                            if (items.length > 0) {
                                items[0].setAttribute('data-highlighted', '');
                                items[0].focus({ preventScroll: true });
                            }
                        });
                    }

                    function close() {
                        if (!isOpen) return;
                        isOpen = false;

                        if (cleanupMenu) { cleanupMenu(); cleanupMenu = null; }
                        if (cleanupDismiss) { cleanupDismiss(); cleanupDismiss = null; }
                        if (cleanupFloat) { cleanupFloat(); cleanupFloat = null; }

                        content.setAttribute('data-state', 'closed');

                        Suite.ScrollLock.unlock();
                        Suite.FocusGuards.uninstall();

                        content.querySelectorAll('[data-highlighted]').forEach(el => el.removeAttribute('data-highlighted'));

                        const hide = () => { content.style.display = 'none'; };
                        content.addEventListener('animationend', hide, { once: true });
                        setTimeout(hide, 250);
                    }

                    // Right-click handler
                    triggerEl.addEventListener('contextmenu', (e) => {
                        if (triggerEl.hasAttribute('data-disabled')) return;
                        clearTimeout(longPressTimer);
                        e.preventDefault();
                        openAtPosition(e.clientX, e.clientY);
                    });

                    // Touch long-press (700ms)
                    triggerEl.addEventListener('pointerdown', (e) => {
                        if (e.pointerType === 'mouse') return;
                        clearTimeout(longPressTimer);
                        longPressTimer = setTimeout(() => {
                            openAtPosition(e.clientX, e.clientY);
                        }, 700);
                    });

                    triggerEl.addEventListener('pointermove', (e) => {
                        if (e.pointerType === 'mouse') return;
                        clearTimeout(longPressTimer);
                    });
                    triggerEl.addEventListener('pointerup', (e) => {
                        if (e.pointerType === 'mouse') return;
                        clearTimeout(longPressTimer);
                    });
                    triggerEl.addEventListener('pointercancel', () => {
                        clearTimeout(longPressTimer);
                    });

                    // iOS: prevent native context menu
                    triggerEl.style.webkitTouchCallout = 'none';
                });
            }
        },

        // --- Select ---------------------------------------------------------------
        Select: {
            _initialized: new WeakSet(),

            init() {
                document.querySelectorAll('[data-suite-select]').forEach(root => {
                    if (this._initialized.has(root)) return;
                    this._initialized.add(root);

                    const id = root.getAttribute('data-suite-select');
                    const trigger = root.querySelector(`[data-suite-select-trigger="${id}"]`) || root.querySelector('[data-suite-select-trigger]');
                    const content = root.querySelector('[data-suite-select-content]');
                    if (!trigger || !content) return;

                    let isOpen = false;
                    let cleanupFloat = null;
                    let cleanupDismiss = null;
                    let highlightedItem = null;
                    let typeaheadSearch = '';
                    let typeaheadTimer = null;

                    // Get initial value from root
                    let currentValue = root.getAttribute('data-suite-select-value') || '';

                    // Update display to show initial value
                    function updateDisplay() {
                        const displayEl = trigger.querySelector('[data-suite-select-display]');
                        if (!displayEl) return;
                        const items = content.querySelectorAll('[data-suite-select-item]');
                        let found = false;
                        items.forEach(item => {
                            const itemVal = item.getAttribute('data-suite-select-item-value') || '';
                            if (itemVal === currentValue && currentValue !== '') {
                                // Show item text
                                const textEl = item.querySelector('[data-suite-select-item-text-content]');
                                displayEl.textContent = textEl ? textEl.textContent : item.textContent.trim();
                                displayEl.removeAttribute('data-placeholder');
                                found = true;
                                // Show check indicator on this item
                                item.setAttribute('data-state', 'checked');
                                item.setAttribute('aria-selected', 'true');
                                const indicator = item.querySelector('[data-suite-select-item-indicator]');
                                if (indicator) indicator.style.display = '';
                            } else {
                                item.setAttribute('data-state', 'unchecked');
                                item.setAttribute('aria-selected', 'false');
                                const indicator = item.querySelector('[data-suite-select-item-indicator]');
                                if (indicator) indicator.style.display = 'none';
                            }
                        });
                        if (!found && currentValue === '') {
                            // Keep placeholder
                        }
                    }

                    function getItems() {
                        return Array.from(content.querySelectorAll('[data-suite-select-item]:not([data-disabled])'));
                    }

                    function highlightItem(item) {
                        if (highlightedItem) {
                            highlightedItem.removeAttribute('data-highlighted');
                            highlightedItem.classList.remove('bg-warm-100', 'dark:bg-warm-800');
                        }
                        highlightedItem = item;
                        if (item) {
                            item.setAttribute('data-highlighted', '');
                            item.focus();
                        }
                    }

                    function selectItem(item) {
                        if (!item) return;
                        currentValue = item.getAttribute('data-suite-select-item-value') || '';
                        root.setAttribute('data-suite-select-value', currentValue);
                        updateDisplay();
                        close();
                    }

                    function open() {
                        if (isOpen) return;
                        if (root.hasAttribute('data-disabled')) return;
                        isOpen = true;

                        content.style.display = '';
                        content.setAttribute('data-state', 'open');
                        trigger.setAttribute('aria-expanded', 'true');
                        trigger.setAttribute('data-state', 'open');

                        const side = content.getAttribute('data-suite-select-side') || 'bottom';
                        const sideOffset = parseInt(content.getAttribute('data-suite-select-side-offset') || '4', 10);
                        const align = content.getAttribute('data-suite-select-align') || 'start';

                        cleanupFloat = Suite.Floating.position(trigger, content, { side, sideOffset, align });
                        Suite.ScrollLock.lock();
                        Suite.FocusGuards.install();

                        // Focus the selected item or first item
                        requestAnimationFrame(() => {
                            const items = getItems();
                            const selected = items.find(i => i.getAttribute('data-state') === 'checked');
                            highlightItem(selected || items[0]);
                        });

                        cleanupDismiss = Suite.DismissLayer.push({
                            element: content,
                            onEscape: () => close(),
                            onPointerDownOutside: (e) => {
                                if (!trigger.contains(e.target)) close();
                            }
                        });
                    }

                    function close() {
                        if (!isOpen) return;
                        isOpen = false;

                        content.setAttribute('data-state', 'closed');
                        trigger.setAttribute('aria-expanded', 'false');
                        trigger.setAttribute('data-state', 'closed');

                        if (highlightedItem) {
                            highlightedItem.removeAttribute('data-highlighted');
                            highlightedItem = null;
                        }

                        if (cleanupDismiss) { cleanupDismiss(); cleanupDismiss = null; }
                        Suite.ScrollLock.unlock();
                        Suite.FocusGuards.uninstall();
                        if (cleanupFloat) { cleanupFloat(); cleanupFloat = null; }

                        const animDur = 200;
                        setTimeout(() => {
                            if (!isOpen) content.style.display = 'none';
                        }, animDur);

                        trigger.focus();
                    }

                    // Typeahead
                    function handleTypeahead(key) {
                        clearTimeout(typeaheadTimer);
                        typeaheadSearch += key.toLowerCase();

                        // Normalize repeated chars: 'aaa' → 'a'
                        const allSame = typeaheadSearch.split('').every(c => c === typeaheadSearch[0]);
                        const search = allSame ? typeaheadSearch[0] : typeaheadSearch;

                        const items = getItems();
                        const currentIdx = highlightedItem ? items.indexOf(highlightedItem) : -1;

                        // Search forward from current position (wrap)
                        let startIdx = search.length === 1 ? currentIdx + 1 : 0;
                        for (let i = 0; i < items.length; i++) {
                            const idx = (startIdx + i) % items.length;
                            const textEl = items[idx].querySelector('[data-suite-select-item-text-content]');
                            const text = (textEl ? textEl.textContent : items[idx].textContent).trim().toLowerCase();
                            if (text.startsWith(search)) {
                                highlightItem(items[idx]);
                                break;
                            }
                        }

                        typeaheadTimer = setTimeout(() => { typeaheadSearch = ''; }, 1000);
                    }

                    // Trigger events
                    trigger.addEventListener('pointerdown', (e) => {
                        if (e.button !== 0 || (e.ctrlKey && navigator.platform.includes('Mac'))) return;
                        e.preventDefault();
                        if (isOpen) close(); else open();
                    });

                    trigger.addEventListener('keydown', (e) => {
                        if (e.key.length === 1 && !e.ctrlKey && !e.metaKey && !e.altKey) {
                            if (typeaheadSearch.length > 0 && e.key === ' ') {
                                e.preventDefault();
                                handleTypeahead(' ');
                                return;
                            }
                            handleTypeahead(e.key);
                            return;
                        }
                        if (['ArrowDown', 'ArrowUp', 'Enter', ' '].includes(e.key)) {
                            e.preventDefault();
                            open();
                        }
                    });

                    // Content keyboard navigation
                    content.addEventListener('keydown', (e) => {
                        if (e.key === 'Tab') { e.preventDefault(); return; }

                        const items = getItems();
                        const currentIdx = highlightedItem ? items.indexOf(highlightedItem) : -1;

                        if (e.key === 'ArrowDown') {
                            e.preventDefault();
                            const next = currentIdx + 1 < items.length ? currentIdx + 1 : 0;
                            highlightItem(items[next]);
                        } else if (e.key === 'ArrowUp') {
                            e.preventDefault();
                            const prev = currentIdx - 1 >= 0 ? currentIdx - 1 : items.length - 1;
                            highlightItem(items[prev]);
                        } else if (e.key === 'Home') {
                            e.preventDefault();
                            highlightItem(items[0]);
                        } else if (e.key === 'End') {
                            e.preventDefault();
                            highlightItem(items[items.length - 1]);
                        } else if (e.key === 'Enter' || e.key === ' ') {
                            e.preventDefault();
                            if (highlightedItem) selectItem(highlightedItem);
                        } else if (e.key.length === 1 && !e.ctrlKey && !e.metaKey && !e.altKey) {
                            if (typeaheadSearch.length > 0 && e.key === ' ') {
                                e.preventDefault();
                                handleTypeahead(' ');
                                return;
                            }
                            handleTypeahead(e.key);
                        }
                    });

                    // Item click
                    content.addEventListener('pointerup', (e) => {
                        const item = e.target.closest('[data-suite-select-item]:not([data-disabled])');
                        if (item && content.contains(item)) {
                            selectItem(item);
                        }
                    });

                    // Item hover highlighting
                    content.addEventListener('pointermove', (e) => {
                        const item = e.target.closest('[data-suite-select-item]:not([data-disabled])');
                        if (item && content.contains(item)) {
                            highlightItem(item);
                        }
                    });

                    // Scroll buttons
                    const scrollUp = content.querySelector('[data-suite-select-scroll-up]');
                    const scrollDown = content.querySelector('[data-suite-select-scroll-down]');
                    let scrollInterval = null;

                    if (scrollUp) {
                        scrollUp.addEventListener('pointerdown', () => {
                            scrollInterval = setInterval(() => { content.scrollTop -= 32; }, 50);
                        });
                        scrollUp.addEventListener('pointerup', () => clearInterval(scrollInterval));
                        scrollUp.addEventListener('pointerleave', () => clearInterval(scrollInterval));
                    }
                    if (scrollDown) {
                        scrollDown.addEventListener('pointerdown', () => {
                            scrollInterval = setInterval(() => { content.scrollTop += 32; }, 50);
                        });
                        scrollDown.addEventListener('pointerup', () => clearInterval(scrollInterval));
                        scrollDown.addEventListener('pointerleave', () => clearInterval(scrollInterval));
                    }

                    // Initialize display
                    updateDisplay();
                });
            }
        },

        // --- Command (cmdk-style) -------------------------------------------------
        Command: {
            _initialized: new WeakSet(),

            /**
             * Fuzzy match scoring — ported from cmdk's command-score.ts
             * Returns 0-1 score. Higher = better match.
             */
            score(string, abbreviation) {
                if (!abbreviation || !string) return 0;
                if (abbreviation.length > string.length) return 0;
                if (abbreviation === string) return 1;

                const lowerString = string.toLowerCase();
                const lowerAbbreviation = abbreviation.toLowerCase();
                const memo = {};

                function inner(sIdx, aIdx) {
                    if (aIdx === abbreviation.length) {
                        return sIdx === string.length ? 1 : 0.99;
                    }
                    const key = sIdx + ',' + aIdx;
                    if (memo[key] !== undefined) return memo[key];

                    let highScore = 0;
                    const targetChar = lowerAbbreviation[aIdx];

                    for (let i = sIdx; i < string.length; i++) {
                        if (lowerString[i] !== targetChar) continue;

                        let score = inner(i + 1, aIdx + 1);
                        if (score <= 0) continue;

                        if (i === sIdx) {
                            score *= 1; // continue match
                        } else if (i > 0) {
                            const prev = string[i - 1];
                            if (prev === ' ' || prev === '-') {
                                score *= 0.9; // space/dash word jump
                            } else if ('\\/_+.#"@[({&'.includes(prev)) {
                                score *= 0.8; // separator word jump
                            } else {
                                score *= 0.17; // character jump
                            }
                        }

                        // Case mismatch penalty
                        if (string[i] !== abbreviation[aIdx]) {
                            score *= 0.9999;
                        }

                        if (score > highScore) highScore = score;
                    }

                    memo[key] = highScore;
                    return highScore;
                }

                return inner(0, 0);
            },

            init() {
                document.querySelectorAll('[data-suite-command]').forEach(root => {
                    if (this._initialized.has(root)) return;
                    this._initialized.add(root);

                    const shouldFilter = root.getAttribute('data-suite-command-filter') !== 'false';
                    const loop = root.getAttribute('data-suite-command-loop') !== 'false';
                    const input = root.querySelector('[data-suite-command-input]');
                    const list = root.querySelector('[data-suite-command-list]');
                    const emptyEl = root.querySelector('[data-suite-command-empty]');
                    let selectedItem = null;

                    function getItems() {
                        return Array.from(root.querySelectorAll('[data-suite-command-item]:not([data-disabled="true"])'));
                    }

                    function getVisibleItems() {
                        return getItems().filter(i => i.style.display !== 'none');
                    }

                    function highlightItem(item) {
                        if (selectedItem) {
                            selectedItem.setAttribute('data-selected', 'false');
                            selectedItem.setAttribute('aria-selected', 'false');
                        }
                        selectedItem = item;
                        if (item) {
                            item.setAttribute('data-selected', 'true');
                            item.setAttribute('aria-selected', 'true');
                            item.scrollIntoView({ block: 'nearest' });
                        }
                    }

                    function filterItems(search) {
                        if (!shouldFilter || !search) {
                            // Show all items and groups
                            root.querySelectorAll('[data-suite-command-item]').forEach(item => {
                                item.style.display = '';
                            });
                            root.querySelectorAll('[data-suite-command-group]').forEach(group => {
                                group.style.display = '';
                            });
                            if (emptyEl) emptyEl.style.display = 'none';

                            // Highlight first visible item
                            const items = getVisibleItems();
                            highlightItem(items[0] || null);
                            return;
                        }

                        const scores = [];
                        const items = root.querySelectorAll('[data-suite-command-item]');

                        items.forEach(item => {
                            const value = item.getAttribute('data-suite-command-item-value') || item.textContent.trim();
                            const keywords = item.getAttribute('data-suite-command-item-keywords') || '';
                            const searchText = keywords ? value + ' ' + keywords.replace(/,/g, ' ') : value;
                            const s = Suite.Command.score(searchText, search);

                            if (s > 0) {
                                item.style.display = '';
                                scores.push({ item, score: s });
                            } else {
                                item.style.display = 'none';
                            }
                        });

                        // Sort by score descending (higher = better match)
                        scores.sort((a, b) => b.score - a.score);

                        // Reorder DOM elements by score
                        if (list && scores.length > 0) {
                            // Group-aware: just let CSS handle order, don't reorder DOM
                        }

                        // Show/hide groups based on whether they have visible items
                        root.querySelectorAll('[data-suite-command-group]').forEach(group => {
                            const hasVisible = group.querySelector('[data-suite-command-item]:not([style*="display: none"])');
                            group.style.display = hasVisible ? '' : 'none';
                        });

                        // Show/hide empty state
                        const visibleItems = getVisibleItems();
                        if (emptyEl) {
                            emptyEl.style.display = visibleItems.length === 0 ? '' : 'none';
                        }

                        // Highlight first visible item
                        highlightItem(visibleItems[0] || null);
                    }

                    // Input filtering
                    if (input) {
                        input.addEventListener('input', (e) => {
                            filterItems(e.target.value);
                        });
                    }

                    // Keyboard navigation
                    root.addEventListener('keydown', (e) => {
                        // Suppress during IME composition
                        if (e.isComposing) return;

                        const items = getVisibleItems();
                        const currentIdx = selectedItem ? items.indexOf(selectedItem) : -1;

                        if (e.key === 'ArrowDown' || (e.ctrlKey && (e.key === 'n' || e.key === 'j'))) {
                            e.preventDefault();
                            let next = currentIdx + 1;
                            if (next >= items.length) next = loop ? 0 : items.length - 1;
                            highlightItem(items[next]);
                        } else if (e.key === 'ArrowUp' || (e.ctrlKey && (e.key === 'p' || e.key === 'k'))) {
                            e.preventDefault();
                            let prev = currentIdx - 1;
                            if (prev < 0) prev = loop ? items.length - 1 : 0;
                            highlightItem(items[prev]);
                        } else if (e.key === 'Home') {
                            e.preventDefault();
                            highlightItem(items[0]);
                        } else if (e.key === 'End') {
                            e.preventDefault();
                            highlightItem(items[items.length - 1]);
                        } else if (e.key === 'Enter') {
                            e.preventDefault();
                            if (selectedItem) {
                                selectedItem.click();
                            }
                        }
                    });

                    // Item click
                    root.addEventListener('click', (e) => {
                        const item = e.target.closest('[data-suite-command-item]:not([data-disabled="true"])');
                        if (item && root.contains(item)) {
                            highlightItem(item);
                        }
                    });

                    // Item hover highlighting
                    root.addEventListener('pointermove', (e) => {
                        const item = e.target.closest('[data-suite-command-item]:not([data-disabled="true"])');
                        if (item && root.contains(item)) {
                            highlightItem(item);
                        }
                    });

                    // Initial state
                    filterItems('');
                });

                // CommandDialog
                document.querySelectorAll('[data-suite-command-dialog]').forEach(dialog => {
                    if (this._initialized.has(dialog)) return;
                    this._initialized.add(dialog);

                    const id = dialog.getAttribute('data-suite-command-dialog');
                    const overlay = dialog.querySelector(`[data-suite-command-dialog-overlay="${id}"]`);

                    function openDialog() {
                        dialog.style.display = '';
                        dialog.setAttribute('data-state', 'open');
                        Suite.ScrollLock.lock();
                        Suite.FocusGuards.install();

                        const input = dialog.querySelector('[data-suite-command-input]');
                        if (input) requestAnimationFrame(() => input.focus());
                    }

                    function closeDialog() {
                        dialog.setAttribute('data-state', 'closed');
                        Suite.ScrollLock.unlock();
                        Suite.FocusGuards.uninstall();
                        setTimeout(() => {
                            if (dialog.getAttribute('data-state') === 'closed') {
                                dialog.style.display = 'none';
                            }
                        }, 200);
                    }

                    // Escape to close
                    dialog.addEventListener('keydown', (e) => {
                        if (e.key === 'Escape') {
                            e.preventDefault();
                            e.stopPropagation();
                            closeDialog();
                        }
                    });

                    // Click overlay to close
                    if (overlay) {
                        overlay.addEventListener('pointerdown', (e) => {
                            if (e.target === overlay) closeDialog();
                        });
                    }

                    // Store open/close functions for external triggering
                    dialog._suiteOpen = openDialog;
                    dialog._suiteClose = closeDialog;
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
            this.Dialog.init();
            this.AlertDialog.init();
            this.Sheet.init();
            this.Drawer.init();
            this.Popover.init();
            this.Tooltip.init();
            this.HoverCard.init();
            this.DropdownMenu.init();
            this.ContextMenu.init();
            this.Select.init();
            this.Command.init();
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
