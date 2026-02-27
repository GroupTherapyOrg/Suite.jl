/**
 * Suite.jl Runtime — Behavioral JS for complex UI components
 *
 * This module handles DOM behaviors that cannot be expressed in pure Wasm:
 * - Focus trapping (Dialog, AlertDialog, Sheet)
 * - Dismiss layers (click-outside, Escape key)
 * - Floating positioning (Popover, Tooltip, DropdownMenu, Select)
 * - Roving focus (RadioGroup)
 * - Presence animations (mount/unmount transitions)
 * - Collection management (ordered item lists)
 *
 * Architecture:
 *   - Auto-discovers components via data-suite-* attributes
 *   - Each behavior is a standalone module (no cross-dependencies)
 *   - Re-scans on SPA navigation (listens for therapy:router:loaded)
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

        // Helper: get namespaced localStorage key based on data-base-path
        _themeKey(name) {
            const bp = document.documentElement.getAttribute('data-base-path') || '';
            return bp ? name + ':' + bp : name;
        },

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
                    // Check excludeElements — e.g., menubar triggers shouldn't dismiss
                    if (options.excludeElements) {
                        const excluded = typeof options.excludeElements === 'function'
                            ? options.excludeElements() : options.excludeElements;
                        if (excluded && excluded.some(el => el && el.contains(e.target))) return;
                    }
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

        // --- Collapsible: REMOVED (converted to @island in SUITE-903) ----------

        // --- Accordion: REMOVED (converted to @island in SUITE-904) ----------------

        // --- Tabs: REMOVED (converted to @island in SUITE-905) ----------------------

        // --- Toggle Group: REMOVED (converted to @island in SUITE-905) -------------

        // --- Theme Toggle: REMOVED (converted to @island in SUITE-903) ---------

        // --- Theme Switcher -------------------------------------------------------
        ThemeSwitcher: {
            /**
             * Initialize theme switcher dropdowns.
             * Discovers elements with data-suite-theme-switcher attribute.
             * Sets data-theme on <html> and persists to localStorage('suite-active-theme').
             */
            init() {
                const roots = document.querySelectorAll('[data-suite-theme-switcher]');
                roots.forEach(root => {
                    if (root._suiteThemeSwitcher) return;
                    root._suiteThemeSwitcher = true;

                    const trigger = root.querySelector('[data-suite-theme-switcher-trigger]');
                    const content = root.querySelector('[data-suite-theme-switcher-content]');
                    if (!trigger || !content) return;

                    // Show active theme check mark on init
                    this._updateChecks(root);

                    // Toggle dropdown
                    trigger.addEventListener('click', (e) => {
                        e.stopPropagation();
                        const isOpen = !content.classList.contains('hidden');
                        if (isOpen) {
                            this._close(trigger, content);
                        } else {
                            this._open(trigger, content);
                            // Update checks when opening
                            this._updateChecks(root);
                        }
                    });

                    // Theme option clicks
                    const options = root.querySelectorAll('[data-suite-theme-option]');
                    options.forEach(option => {
                        option.addEventListener('click', () => {
                            const theme = option.getAttribute('data-suite-theme-option');
                            this._applyTheme(theme);
                            this._updateChecks(root);
                            this._close(trigger, content);
                        });
                    });

                    // Click outside to close
                    document.addEventListener('pointerdown', (e) => {
                        if (!root.contains(e.target) && !content.classList.contains('hidden')) {
                            this._close(trigger, content);
                        }
                    });

                    // Escape to close
                    document.addEventListener('keydown', (e) => {
                        if (e.key === 'Escape' && !content.classList.contains('hidden')) {
                            this._close(trigger, content);
                            trigger.focus();
                        }
                    });
                });

                // Also update checks on all switchers (in case theme changed externally)
                roots.forEach(root => this._updateChecks(root));
            },

            _open(trigger, content) {
                content.classList.remove('hidden');
                trigger.setAttribute('aria-expanded', 'true');
            },

            _close(trigger, content) {
                content.classList.add('hidden');
                trigger.setAttribute('aria-expanded', 'false');
            },

            _applyTheme(theme) {
                const html = document.documentElement;
                if (theme === 'default') {
                    html.removeAttribute('data-theme');
                } else {
                    html.setAttribute('data-theme', theme);
                }
                try {
                    localStorage.setItem(Suite._themeKey('suite-active-theme'), theme);
                } catch (e) {}
            },

            _updateChecks(root) {
                const current = document.documentElement.getAttribute('data-theme') || 'default';
                const checks = root.querySelectorAll('[data-suite-theme-check]');
                checks.forEach(check => {
                    const key = check.getAttribute('data-suite-theme-check');
                    if (key === current) {
                        check.classList.remove('hidden');
                    } else {
                        check.classList.add('hidden');
                    }
                });
            },
        },

        // Dialog: removed (now @island — SUITE-906)
        // AlertDialog: removed (now @island — SUITE-906)

        // Sheet: removed (now @island — SUITE-907)
        // Drawer: removed (now @island — SUITE-907)

        // Popover: removed (now @island — SUITE-908)

        // Tooltip: removed (now @island — SUITE-909)

        // HoverCard: removed (now @island — SUITE-909)

        // Menu (shared base): removed (now inline in modal_state — SUITE-911)
        // DropdownMenu: removed (now @island with BindModal mode=6 — SUITE-910)
        // ContextMenu: removed (now @island with BindModal mode=7 — SUITE-911)
        _MENU_REMOVED: true,
        // Select: removed (now @island with BindModal mode=10 — SUITE-913)

        // Command: removed (now @island with BindModal mode=11 — SUITE-913)
        // CommandDialog: removed (now @island with BindModal mode=12 — SUITE-913)

        // Menubar: removed (now @island with BindModal mode=8 — SUITE-911)

        // NavigationMenu: removed (now @island with BindModal mode=9 — SUITE-912)

        // =====================================================================
        // Toast — Sonner-style notification system
        // =====================================================================
        Toast: {
            _container: null,
            _toasts: [],
            _counter: 0,
            _defaults: {
                duration: 4000,
                position: 'bottom-right',
                visibleToasts: 3,
                gap: 14,
                swipeThreshold: 45
            },

            init() {
                // Find or create toaster container
                const el = document.querySelector('[data-suite-toaster]');
                if (el && !el._suiteToastInit) {
                    el._suiteToastInit = true;
                    this._container = el;
                    // Read config from data attributes
                    if (el.dataset.position) this._defaults.position = el.dataset.position;
                    if (el.dataset.duration) this._defaults.duration = parseInt(el.dataset.duration, 10);
                    if (el.dataset.visibleToasts) this._defaults.visibleToasts = parseInt(el.dataset.visibleToasts, 10);
                }
            },

            _ensureContainer() {
                if (this._container) return;
                // Auto-create container if not found in DOM
                const c = document.createElement('section');
                c.setAttribute('aria-label', 'Notifications');
                c.setAttribute('data-suite-toaster', '');
                c.setAttribute('tabindex', '-1');
                document.body.appendChild(c);
                this._container = c;
                c._suiteToastInit = true;
            },

            _getPositionClasses(pos) {
                const map = {
                    'top-left':      { y: 'top',    x: 'left',   style: 'top: var(--offset-y, 24px); left: var(--offset-x, 24px);' },
                    'top-center':    { y: 'top',    x: 'center', style: 'top: var(--offset-y, 24px); left: 50%; transform: translateX(-50%);' },
                    'top-right':     { y: 'top',    x: 'right',  style: 'top: var(--offset-y, 24px); right: var(--offset-x, 24px);' },
                    'bottom-left':   { y: 'bottom', x: 'left',   style: 'bottom: var(--offset-y, 24px); left: var(--offset-x, 24px);' },
                    'bottom-center': { y: 'bottom', x: 'center', style: 'bottom: var(--offset-y, 24px); left: 50%; transform: translateX(-50%);' },
                    'bottom-right':  { y: 'bottom', x: 'right',  style: 'bottom: var(--offset-y, 24px); right: var(--offset-x, 24px);' }
                };
                return map[pos] || map['bottom-right'];
            },

            _iconSvg(type) {
                const icons = {
                    success: '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>',
                    error: '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>',
                    warning: '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>',
                    info: '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>'
                };
                return icons[type] || '';
            },

            _typeColors(type) {
                const colors = {
                    default: '',
                    success: 'border-green-200 dark:border-green-800 bg-green-50 dark:bg-green-950 text-green-800 dark:text-green-200',
                    error: 'border-red-200 dark:border-red-800 bg-red-50 dark:bg-red-950 text-red-800 dark:text-red-200',
                    warning: 'border-amber-200 dark:border-amber-800 bg-amber-50 dark:bg-amber-950 text-amber-800 dark:text-amber-200',
                    info: 'border-blue-200 dark:border-blue-800 bg-blue-50 dark:bg-blue-950 text-blue-800 dark:text-blue-200'
                };
                return colors[type] || colors['default'];
            },

            _createToastEl(toast) {
                const li = document.createElement('li');
                li.setAttribute('role', 'status');
                li.setAttribute('aria-live', toast.type === 'error' ? 'assertive' : 'polite');
                li.setAttribute('aria-atomic', 'true');
                li.setAttribute('data-suite-toast', toast.id);
                li.setAttribute('data-type', toast.type);
                li.setAttribute('data-mounted', 'false');
                li.setAttribute('data-dismissed', 'false');
                li.setAttribute('tabindex', '0');

                const typeColors = this._typeColors(toast.type);
                const baseClasses = 'pointer-events-auto relative flex items-start gap-3 w-[356px] max-w-[calc(100vw-48px)] rounded-md border p-4 shadow-lg transition-all duration-300';
                const defaultColors = 'border-warm-200 dark:border-warm-700 bg-warm-50 dark:bg-warm-900 text-warm-800 dark:text-warm-300';
                li.className = baseClasses + ' ' + (typeColors || defaultColors);

                // Icon
                const icon = this._iconSvg(toast.type);
                let iconHtml = '';
                if (icon) {
                    const iconColorMap = {
                        success: 'text-green-600 dark:text-green-400',
                        error: 'text-red-600 dark:text-red-400',
                        warning: 'text-amber-600 dark:text-amber-400',
                        info: 'text-blue-600 dark:text-blue-400'
                    };
                    iconHtml = '<div class="flex-shrink-0 ' + (iconColorMap[toast.type] || '') + '">' + icon + '</div>';
                }

                // Content
                let contentHtml = '<div class="flex-1 min-w-0">';
                if (toast.title) {
                    contentHtml += '<div class="text-sm font-semibold">' + this._escapeHtml(toast.title) + '</div>';
                }
                if (toast.description) {
                    contentHtml += '<div class="text-sm opacity-80 mt-0.5">' + this._escapeHtml(toast.description) + '</div>';
                }
                contentHtml += '</div>';

                // Close button
                let closeHtml = '';
                if (toast.dismissible !== false) {
                    closeHtml = '<button type="button" aria-label="Dismiss" class="flex-shrink-0 rounded-md p-0.5 opacity-50 hover:opacity-100 transition-opacity cursor-pointer focus:outline-none focus-visible:ring-2 focus-visible:ring-accent-600">' +
                        '<svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>' +
                        '</button>';
                }

                // Action button
                let actionHtml = '';
                if (toast.action) {
                    actionHtml = '<button type="button" data-suite-toast-action class="flex-shrink-0 text-sm font-medium px-3 py-1 rounded-md bg-accent-600 text-white hover:bg-accent-700 transition-colors cursor-pointer">' +
                        this._escapeHtml(toast.action.label) + '</button>';
                }

                li.innerHTML = iconHtml + contentHtml + actionHtml + closeHtml;

                // Wire close button
                const closeBtn = li.querySelector('button[aria-label="Dismiss"]');
                if (closeBtn) {
                    closeBtn.addEventListener('click', () => this.dismiss(toast.id));
                }

                // Wire action button
                const actionBtn = li.querySelector('[data-suite-toast-action]');
                if (actionBtn && toast.action && toast.action.onClick) {
                    actionBtn.addEventListener('click', (e) => {
                        toast.action.onClick(e);
                        this.dismiss(toast.id);
                    });
                }

                // Swipe to dismiss
                this._setupSwipe(li, toast);

                return li;
            },

            _escapeHtml(str) {
                const div = document.createElement('div');
                div.textContent = str;
                return div.innerHTML;
            },

            _setupSwipe(el, toast) {
                if (toast.dismissible === false) return;

                let startX = 0, startY = 0, startTime = 0, swiping = false;

                el.addEventListener('pointerdown', (e) => {
                    if (e.button !== 0) return;
                    startX = e.clientX;
                    startY = e.clientY;
                    startTime = Date.now();
                    swiping = true;
                    el.setPointerCapture(e.pointerId);
                    el.style.transition = 'none';
                    el.setAttribute('data-swiping', 'true');
                });

                el.addEventListener('pointermove', (e) => {
                    if (!swiping) return;
                    const dx = e.clientX - startX;
                    // Only allow right swipe (positive direction)
                    if (dx > 0) {
                        el.style.transform = 'translateX(' + dx + 'px)';
                        el.style.opacity = Math.max(0, 1 - dx / 150);
                    }
                });

                el.addEventListener('pointerup', (e) => {
                    if (!swiping) return;
                    swiping = false;
                    el.removeAttribute('data-swiping');
                    el.style.transition = '';

                    const dx = e.clientX - startX;
                    const timeTaken = Date.now() - startTime;
                    const velocity = Math.abs(dx) / timeTaken;

                    if (dx >= this._defaults.swipeThreshold || velocity > 0.11) {
                        // Swipe out
                        el.style.transition = 'transform 200ms ease-out, opacity 200ms ease-out';
                        el.style.transform = 'translateX(100%)';
                        el.style.opacity = '0';
                        setTimeout(() => this.dismiss(toast.id), 200);
                    } else {
                        // Snap back
                        el.style.transform = '';
                        el.style.opacity = '';
                    }
                });
            },

            _updatePositions() {
                const visible = this._toasts.filter(t => !t.dismissed);
                const gap = this._defaults.gap;

                visible.forEach((toast, index) => {
                    const el = toast.el;
                    if (!el) return;

                    const isVisible = index < this._defaults.visibleToasts;
                    el.style.zIndex = String(visible.length - index);

                    if (isVisible) {
                        el.style.opacity = '';
                        el.style.pointerEvents = '';
                        // Stack offset: each toast offsets by its predecessors' heights + gap
                        let offset = 0;
                        for (let i = 0; i < index; i++) {
                            offset += (visible[i].height || 0) + gap;
                        }
                        const pos = this._getPositionClasses(this._defaults.position);
                        const dir = pos.y === 'bottom' ? -1 : 1;
                        el.style.transform = 'translateY(' + (dir * offset) + 'px)';
                    } else {
                        // Hidden behind stack
                        el.style.opacity = '0';
                        el.style.pointerEvents = 'none';
                        el.style.transform = 'translateY(0) scale(0.95)';
                    }
                });
            },

            _startTimer(toast) {
                if (toast.duration === Infinity) return;
                const dur = toast.duration || this._defaults.duration;
                toast._remaining = dur;
                toast._timerStart = Date.now();
                toast._timer = setTimeout(() => this.dismiss(toast.id), dur);
            },

            _pauseTimer(toast) {
                if (toast._timer) {
                    clearTimeout(toast._timer);
                    toast._remaining -= (Date.now() - toast._timerStart);
                }
            },

            _resumeTimer(toast) {
                if (toast._remaining > 0 && toast.duration !== Infinity) {
                    toast._timerStart = Date.now();
                    toast._timer = setTimeout(() => this.dismiss(toast.id), toast._remaining);
                }
            },

            /**
             * Show a toast notification.
             * @param {string} title - Toast title
             * @param {Object} opts - Options: type, description, duration, action, dismissible
             * @returns {number} Toast ID
             */
            show(title, opts = {}) {
                this._ensureContainer();

                const id = ++this._counter;
                const toast = {
                    id,
                    title,
                    description: opts.description || '',
                    type: opts.type || 'default',
                    duration: opts.duration,
                    dismissible: opts.dismissible,
                    action: opts.action,
                    dismissed: false,
                    el: null,
                    height: 0,
                    _timer: null,
                    _remaining: 0,
                    _timerStart: 0
                };

                // Create DOM element
                toast.el = this._createToastEl(toast);

                // Find or create the list container for this position
                let list = this._container.querySelector('ol[data-suite-toast-list]');
                if (!list) {
                    list = document.createElement('ol');
                    list.setAttribute('data-suite-toast-list', '');
                    const pos = this._getPositionClasses(this._defaults.position);
                    list.style.cssText = 'position: fixed; ' + pos.style + ' z-index: 999999; list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; pointer-events: none;';
                    this._container.appendChild(list);
                }

                // Prepend (newest on top for bottom, append for top)
                const posInfo = this._getPositionClasses(this._defaults.position);
                if (posInfo.y === 'bottom') {
                    list.prepend(toast.el);
                } else {
                    list.appendChild(toast.el);
                }

                // Add to tracking array (newest first)
                this._toasts.unshift(toast);

                // Measure height after render
                requestAnimationFrame(() => {
                    toast.height = toast.el.getBoundingClientRect().height;
                    toast.el.setAttribute('data-mounted', 'true');
                    this._updatePositions();
                });

                // Pause timer on hover
                toast.el.addEventListener('mouseenter', () => this._pauseTimer(toast));
                toast.el.addEventListener('mouseleave', () => this._resumeTimer(toast));

                // Start auto-dismiss timer
                this._startTimer(toast);

                return id;
            },

            dismiss(id) {
                const idx = this._toasts.findIndex(t => t.id === id);
                if (idx === -1) return;

                const toast = this._toasts[idx];
                if (toast.dismissed) return;
                toast.dismissed = true;

                if (toast._timer) clearTimeout(toast._timer);

                // Animate out
                if (toast.el) {
                    toast.el.setAttribute('data-dismissed', 'true');
                    toast.el.style.transition = 'transform 300ms ease-out, opacity 300ms ease-out';
                    toast.el.style.opacity = '0';
                    toast.el.style.transform = 'translateX(100%)';
                    setTimeout(() => {
                        if (toast.el && toast.el.parentNode) {
                            toast.el.parentNode.removeChild(toast.el);
                        }
                        this._toasts = this._toasts.filter(t => t.id !== id);
                        this._updatePositions();
                    }, 300);
                }

                this._updatePositions();
            },

            dismissAll() {
                [...this._toasts].forEach(t => this.dismiss(t.id));
            },

            // Convenience methods
            success(title, opts = {}) { return this.show(title, { ...opts, type: 'success' }); },
            error(title, opts = {})   { return this.show(title, { ...opts, type: 'error' }); },
            warning(title, opts = {}) { return this.show(title, { ...opts, type: 'warning' }); },
            info(title, opts = {})    { return this.show(title, { ...opts, type: 'info' }); }
        },


        // --- Slider: removed (now @island with BindModal mode=13 — SUITE-914) ---

        // --- Calendar + DatePicker: removed (now @island with BindModal mode=14/15 — SUITE-914) ---


        // --- Form: removed (now @island with BindModal mode=17 — SUITE-915) ---

        // --- DataTable: removed (now @island with BindModal mode=16 — SUITE-915) ---

        // --- SyntaxHighlight (Julia code highlighting) ----------------------------
        SyntaxHighlight: {
            _highlighted: new Set(),

            // Julia keyword list
            _keywords: new Set([
                'function', 'end', 'if', 'else', 'elseif', 'for', 'while', 'return',
                'begin', 'let', 'do', 'try', 'catch', 'finally', 'struct', 'mutable',
                'abstract', 'primitive', 'type', 'module', 'baremodule', 'using',
                'import', 'export', 'const', 'local', 'global', 'macro', 'quote',
                'where', 'in', 'isa', 'break', 'continue', 'new',
            ]),

            // Special values
            _specials: new Set(['true', 'false', 'nothing', 'missing', 'Inf', 'NaN', 'pi']),

            highlight(codeEl) {
                if (this._highlighted.has(codeEl)) return;
                this._highlighted.add(codeEl);

                const text = codeEl.textContent || '';
                if (!text.trim()) return;

                const tokens = this._tokenize(text);
                codeEl.innerHTML = tokens.map(t => this._render(t)).join('');
            },

            _tokenize(text) {
                const tokens = [];
                let i = 0;
                while (i < text.length) {
                    // Triple-quoted string
                    if (text.startsWith('"""', i)) {
                        const end = text.indexOf('"""', i + 3);
                        const j = end === -1 ? text.length : end + 3;
                        tokens.push({ type: 'string', value: text.slice(i, j) });
                        i = j;
                    }
                    // Single-line comment
                    else if (text[i] === '#') {
                        const nl = text.indexOf('\n', i);
                        const j = nl === -1 ? text.length : nl;
                        tokens.push({ type: 'comment', value: text.slice(i, j) });
                        i = j;
                    }
                    // Double-quoted string (with escape handling)
                    else if (text[i] === '"') {
                        let j = i + 1;
                        while (j < text.length && text[j] !== '"') {
                            if (text[j] === '\\') j++; // skip escaped char
                            j++;
                        }
                        j = Math.min(j + 1, text.length);
                        tokens.push({ type: 'string', value: text.slice(i, j) });
                        i = j;
                    }
                    // Single-quoted char
                    else if (text[i] === "'" && (i === 0 || /[\s(,=\[{;]/.test(text[i-1]))) {
                        let j = i + 1;
                        while (j < text.length && text[j] !== "'") {
                            if (text[j] === '\\') j++;
                            j++;
                        }
                        j = Math.min(j + 1, text.length);
                        tokens.push({ type: 'string', value: text.slice(i, j) });
                        i = j;
                    }
                    // Symbol :word
                    else if (text[i] === ':' && i + 1 < text.length && /[a-zA-Z_]/.test(text[i+1]) && (i === 0 || /[\s(,=\[{;]/.test(text[i-1]))) {
                        let j = i + 1;
                        while (j < text.length && /[a-zA-Z0-9_!]/.test(text[j])) j++;
                        tokens.push({ type: 'symbol', value: text.slice(i, j) });
                        i = j;
                    }
                    // Number
                    else if (/[0-9]/.test(text[i]) && (i === 0 || /[\s(,=\[{;+\-*\/<>!^%&|~]/.test(text[i-1]))) {
                        let j = i;
                        if (text[j] === '0' && j + 1 < text.length && (text[j+1] === 'x' || text[j+1] === 'o' || text[j+1] === 'b')) {
                            j += 2;
                            while (j < text.length && /[0-9a-fA-F_]/.test(text[j])) j++;
                        } else {
                            while (j < text.length && /[0-9._eE+\-]/.test(text[j])) j++;
                        }
                        tokens.push({ type: 'number', value: text.slice(i, j) });
                        i = j;
                    }
                    // Word (keyword, identifier, type, function call)
                    else if (/[a-zA-Z_@]/.test(text[i])) {
                        let j = i;
                        if (text[i] === '@') j++; // macro
                        while (j < text.length && /[a-zA-Z0-9_!]/.test(text[j])) j++;

                        const word = text.slice(i, j);

                        // Look ahead for function call: word(
                        if (j < text.length && text[j] === '(') {
                            tokens.push({ type: 'funcall', value: word });
                        } else if (text[i] === '@') {
                            tokens.push({ type: 'macro', value: word });
                        } else if (this._keywords.has(word)) {
                            tokens.push({ type: 'keyword', value: word });
                        } else if (this._specials.has(word)) {
                            tokens.push({ type: 'special', value: word });
                        } else if (/^[A-Z]/.test(word) && word.length > 1) {
                            tokens.push({ type: 'type', value: word });
                        } else {
                            tokens.push({ type: 'plain', value: word });
                        }
                        i = j;
                    }
                    // Operators
                    else if (/[=!<>+\-*\/\\%^&|~]/.test(text[i])) {
                        let j = i + 1;
                        // Multi-char operators: ==, !=, <=, >=, |>, ->, =>, ::, ...
                        while (j < text.length && /[=!<>|>&:]/.test(text[j]) && j - i < 3) j++;
                        tokens.push({ type: 'operator', value: text.slice(i, j) });
                        i = j;
                    }
                    // :: type annotation
                    else if (text[i] === ':' && i + 1 < text.length && text[i+1] === ':') {
                        tokens.push({ type: 'operator', value: '::' });
                        i += 2;
                    }
                    // Everything else (whitespace, punctuation)
                    else {
                        tokens.push({ type: 'plain', value: text[i] });
                        i++;
                    }
                }
                return tokens;
            },

            _render(token) {
                const esc = token.value
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;');

                if (token.type === 'plain') return esc;
                return `<span class="suite-hl-${token.type}">${esc}</span>`;
            },
        },

        // --- CodeBlock (copy-to-clipboard + syntax highlighting) -----------------
        CodeBlock: {
            _initialized: new Set(),

            init() {
                document.querySelectorAll('[data-suite-codeblock]').forEach(block => {
                    if (this._initialized.has(block)) return;
                    this._initialized.add(block);

                    // Copy button
                    const copyBtn = block.querySelector('[data-suite-codeblock-copy]');
                    if (copyBtn) {
                        copyBtn.addEventListener('click', () => {
                            const code = block.querySelector('code');
                            if (!code) return;

                            const text = code.textContent || '';
                            navigator.clipboard.writeText(text).then(() => {
                                const original = copyBtn.innerHTML;
                                copyBtn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
                                setTimeout(() => { copyBtn.innerHTML = original; }, 2000);
                            });
                        });
                    }

                    // Syntax highlighting
                    const lang = block.getAttribute('data-suite-codeblock-lang');
                    if (lang === 'julia' || lang === 'jl') {
                        const code = block.querySelector('code');
                        if (code) Suite.SyntaxHighlight.highlight(code);
                    }
                });
            },
        },

        // --- TreeView (expand/collapse + keyboard nav) ----------------------------
        TreeView: {
            _initialized: new Set(),

            init() {
                document.querySelectorAll('[data-suite-treeview]').forEach(tree => {
                    if (this._initialized.has(tree)) return;
                    this._initialized.add(tree);
                    this._setup(tree);
                });
            },

            _setup(tree) {
                // Click handler for items
                tree.addEventListener('click', (e) => {
                    const row = e.target.closest('[data-suite-treeview-item] > div');
                    if (!row) return;
                    const item = row.parentElement;
                    if (item.hasAttribute('data-disabled')) return;

                    const isFolder = item.hasAttribute('data-suite-treeview-folder');
                    if (isFolder) {
                        this._toggle(item);
                    }
                    this._select(tree, item);
                });

                // Keyboard navigation
                tree.addEventListener('keydown', (e) => {
                    const item = e.target.closest('[data-suite-treeview-item]');
                    if (!item) return;

                    const visible = this._getVisibleItems(tree);
                    const idx = visible.indexOf(item);
                    if (idx === -1) return;

                    switch (e.key) {
                        case 'ArrowDown': {
                            e.preventDefault();
                            if (idx < visible.length - 1) {
                                this._focus(visible[idx + 1]);
                            }
                            break;
                        }
                        case 'ArrowUp': {
                            e.preventDefault();
                            if (idx > 0) {
                                this._focus(visible[idx - 1]);
                            }
                            break;
                        }
                        case 'ArrowRight': {
                            e.preventDefault();
                            if (item.hasAttribute('data-suite-treeview-folder')) {
                                if (item.getAttribute('data-suite-treeview-expanded') !== 'true') {
                                    this._expand(item);
                                } else {
                                    // Move to first child
                                    const children = item.querySelector('[data-suite-treeview-children]');
                                    if (children) {
                                        const first = children.querySelector('[data-suite-treeview-item]');
                                        if (first) this._focus(first);
                                    }
                                }
                            }
                            break;
                        }
                        case 'ArrowLeft': {
                            e.preventDefault();
                            if (item.hasAttribute('data-suite-treeview-folder') &&
                                item.getAttribute('data-suite-treeview-expanded') === 'true') {
                                this._collapse(item);
                            } else {
                                // Move to parent
                                const parentGroup = item.closest('[data-suite-treeview-children]');
                                if (parentGroup) {
                                    const parentItem = parentGroup.closest('[data-suite-treeview-item]');
                                    if (parentItem) this._focus(parentItem);
                                }
                            }
                            break;
                        }
                        case 'Enter':
                        case ' ': {
                            e.preventDefault();
                            if (item.hasAttribute('data-suite-treeview-folder')) {
                                this._toggle(item);
                            }
                            this._select(tree, item);
                            break;
                        }
                        case 'Home': {
                            e.preventDefault();
                            if (visible.length > 0) this._focus(visible[0]);
                            break;
                        }
                        case 'End': {
                            e.preventDefault();
                            if (visible.length > 0) this._focus(visible[visible.length - 1]);
                            break;
                        }
                    }
                });
            },

            _getVisibleItems(tree) {
                const items = [];
                const walk = (parent) => {
                    const lis = parent.children;
                    for (const li of lis) {
                        if (li.tagName !== 'LI' || !li.hasAttribute('data-suite-treeview-item')) continue;
                        items.push(li);
                        // Only traverse children if expanded
                        if (li.getAttribute('data-suite-treeview-expanded') === 'true') {
                            const group = li.querySelector(':scope > [data-suite-treeview-children]');
                            if (group) walk(group);
                        }
                    }
                };
                walk(tree);
                return items;
            },

            _toggle(item) {
                if (item.getAttribute('data-suite-treeview-expanded') === 'true') {
                    this._collapse(item);
                } else {
                    this._expand(item);
                }
            },

            _expand(item) {
                item.setAttribute('data-suite-treeview-expanded', 'true');
                item.setAttribute('aria-expanded', 'true');
                const children = item.querySelector(':scope > [data-suite-treeview-children]');
                if (children) children.classList.remove('hidden');
                const chevron = item.querySelector(':scope > div [data-suite-treeview-chevron]');
                if (chevron) chevron.classList.add('rotate-90');
            },

            _collapse(item) {
                item.setAttribute('data-suite-treeview-expanded', 'false');
                item.setAttribute('aria-expanded', 'false');
                const children = item.querySelector(':scope > [data-suite-treeview-children]');
                if (children) children.classList.add('hidden');
                const chevron = item.querySelector(':scope > div [data-suite-treeview-chevron]');
                if (chevron) chevron.classList.remove('rotate-90');
            },

            _select(tree, item) {
                // Deselect all
                tree.querySelectorAll('[data-suite-treeview-selected="true"]').forEach(el => {
                    el.setAttribute('data-suite-treeview-selected', 'false');
                    el.setAttribute('aria-selected', 'false');
                    const row = el.querySelector(':scope > div');
                    if (row) {
                        row.classList.remove('bg-warm-100', 'dark:bg-warm-800', 'text-accent-700', 'dark:text-accent-400');
                        row.classList.add('text-warm-700', 'dark:text-warm-300');
                    }
                });
                // Select clicked item
                item.setAttribute('data-suite-treeview-selected', 'true');
                item.setAttribute('aria-selected', 'true');
                const row = item.querySelector(':scope > div');
                if (row) {
                    row.classList.add('bg-warm-100', 'dark:bg-warm-800', 'text-accent-700', 'dark:text-accent-400');
                    row.classList.remove('text-warm-700', 'dark:text-warm-300');
                }
                this._focus(item);
            },

            _focus(item) {
                // Set tabindex
                const tree = item.closest('[data-suite-treeview]');
                if (tree) {
                    tree.querySelectorAll('[data-suite-treeview-item] > div[tabindex="0"]').forEach(el => {
                        el.setAttribute('tabindex', '-1');
                    });
                }
                const row = item.querySelector(':scope > div');
                if (row) {
                    row.setAttribute('tabindex', '0');
                    row.focus();
                }
            },
        },

        // --- Resizable (drag-to-resize panels) ------------------------------------
        Resizable: {
            _initialized: new Set(),
            _cursorSheet: null,

            init() {
                document.querySelectorAll('[data-suite-resizable-group]').forEach(group => {
                    if (this._initialized.has(group)) return;
                    this._initialized.add(group);
                    this._setup(group);
                });
            },

            _setup(group) {
                const direction = group.getAttribute('data-suite-resizable-direction') || 'horizontal';
                const handles = Array.from(group.querySelectorAll(':scope > [data-suite-resizable-handle]'));
                const panels = Array.from(group.querySelectorAll(':scope > [data-suite-resizable-panel]'));

                // Set correct direction data attribute on handles + aria-orientation
                handles.forEach(handle => {
                    handle.setAttribute('data-suite-resizable-direction', direction);
                    // ARIA: separator orientation is inverse of group direction
                    handle.setAttribute('aria-orientation', direction === 'horizontal' ? 'vertical' : 'horizontal');
                });

                // Auto-distribute sizes for panels with default_size=0
                const explicitTotal = panels.reduce((sum, p) => {
                    const s = parseInt(p.getAttribute('data-suite-resizable-default-size') || '0', 10);
                    return sum + s;
                }, 0);
                const unsized = panels.filter(p => parseInt(p.getAttribute('data-suite-resizable-default-size') || '0', 10) === 0);
                if (unsized.length > 0) {
                    const each = (100 - explicitTotal) / unsized.length;
                    unsized.forEach(p => {
                        p.style.flexGrow = each;
                        p.setAttribute('data-suite-resizable-default-size', String(Math.round(each)));
                    });
                }

                // Get current sizes as percentages
                const getSizes = () => {
                    const total = panels.reduce((s, p) => s + parseFloat(p.style.flexGrow || 1), 0);
                    return panels.map(p => (parseFloat(p.style.flexGrow || 1) / total) * 100);
                };

                // Set sizes from percentage array
                const setSizes = (sizes) => {
                    panels.forEach((p, i) => {
                        p.style.flexGrow = sizes[i];
                    });
                    // Update ARIA on handles
                    handles.forEach((h, i) => {
                        if (panels[i]) {
                            h.setAttribute('aria-valuenow', Math.round(getSizes()[i]));
                        }
                    });
                };

                // Resize by delta percentage on a handle
                const resize = (handleIdx, deltaPct) => {
                    const sizes = getSizes();
                    const beforeIdx = handleIdx;
                    const afterIdx = handleIdx + 1;
                    if (beforeIdx >= panels.length || afterIdx >= panels.length) return;

                    const beforeMin = parseInt(panels[beforeIdx].getAttribute('data-suite-resizable-min-size') || '10', 10);
                    const beforeMax = parseInt(panels[beforeIdx].getAttribute('data-suite-resizable-max-size') || '100', 10);
                    const afterMin = parseInt(panels[afterIdx].getAttribute('data-suite-resizable-min-size') || '10', 10);
                    const afterMax = parseInt(panels[afterIdx].getAttribute('data-suite-resizable-max-size') || '100', 10);

                    let newBefore = sizes[beforeIdx] + deltaPct;
                    let newAfter = sizes[afterIdx] - deltaPct;

                    // Clamp
                    if (newBefore < beforeMin) { newAfter += (newBefore - beforeMin); newBefore = beforeMin; }
                    if (newBefore > beforeMax) { newAfter += (newBefore - beforeMax); newBefore = beforeMax; }
                    if (newAfter < afterMin) { newBefore += (newAfter - afterMin); newAfter = afterMin; }
                    if (newAfter > afterMax) { newBefore += (newAfter - afterMax); newAfter = afterMax; }

                    // Final clamp
                    newBefore = Math.max(beforeMin, Math.min(beforeMax, newBefore));
                    newAfter = Math.max(afterMin, Math.min(afterMax, newAfter));

                    sizes[beforeIdx] = newBefore;
                    sizes[afterIdx] = newAfter;
                    setSizes(sizes);
                };

                // Pointer drag
                handles.forEach((handle, hIdx) => {
                    let dragging = false;
                    let startPos = 0;
                    let groupSize = 0;

                    const onPointerDown = (e) => {
                        e.preventDefault();
                        dragging = true;
                        handle.setAttribute('data-suite-resizable-handle', 'active');
                        startPos = direction === 'horizontal' ? e.clientX : e.clientY;
                        const rect = group.getBoundingClientRect();
                        groupSize = direction === 'horizontal' ? rect.width : rect.height;
                        handle.setPointerCapture(e.pointerId);

                        // Set cursor globally
                        const cursor = direction === 'horizontal' ? 'col-resize' : 'row-resize';
                        if (!this._cursorSheet) {
                            this._cursorSheet = new CSSStyleSheet();
                            document.adoptedStyleSheets = [...document.adoptedStyleSheets, this._cursorSheet];
                        }
                        this._cursorSheet.replaceSync(`*, *:hover { cursor: ${cursor} !important; }`);

                        // Disable pointer events on panels (iframes etc)
                        panels.forEach(p => p.style.pointerEvents = 'none');
                    };

                    const onPointerMove = (e) => {
                        if (!dragging) return;
                        const currentPos = direction === 'horizontal' ? e.clientX : e.clientY;
                        const deltaPx = currentPos - startPos;
                        const deltaPct = (deltaPx / groupSize) * 100;
                        startPos = currentPos;
                        resize(hIdx, deltaPct);
                    };

                    const onPointerUp = (e) => {
                        if (!dragging) return;
                        dragging = false;
                        handle.setAttribute('data-suite-resizable-handle', 'inactive');
                        handle.releasePointerCapture(e.pointerId);

                        // Remove cursor override
                        if (this._cursorSheet) {
                            document.adoptedStyleSheets = document.adoptedStyleSheets.filter(s => s !== this._cursorSheet);
                            this._cursorSheet = null;
                        }

                        // Restore pointer events
                        panels.forEach(p => p.style.pointerEvents = '');
                    };

                    handle.addEventListener('pointerdown', onPointerDown);
                    handle.addEventListener('pointermove', onPointerMove);
                    handle.addEventListener('pointerup', onPointerUp);
                    handle.addEventListener('pointercancel', onPointerUp);

                    // Hover state
                    handle.addEventListener('pointerenter', () => {
                        if (!dragging) handle.setAttribute('data-suite-resizable-handle', 'hover');
                    });
                    handle.addEventListener('pointerleave', () => {
                        if (!dragging) handle.setAttribute('data-suite-resizable-handle', 'inactive');
                    });

                    // Keyboard
                    handle.addEventListener('keydown', (e) => {
                        const step = 5; // 5% per keystroke
                        const rect = group.getBoundingClientRect();
                        const gs = direction === 'horizontal' ? rect.width : rect.height;

                        if (direction === 'horizontal') {
                            if (e.key === 'ArrowLeft') { e.preventDefault(); resize(hIdx, -step); }
                            if (e.key === 'ArrowRight') { e.preventDefault(); resize(hIdx, step); }
                        } else {
                            if (e.key === 'ArrowUp') { e.preventDefault(); resize(hIdx, -step); }
                            if (e.key === 'ArrowDown') { e.preventDefault(); resize(hIdx, step); }
                        }
                        if (e.key === 'Home') { e.preventDefault(); resize(hIdx, -100); }
                        if (e.key === 'End') { e.preventDefault(); resize(hIdx, 100); }
                    });
                });

                // Initial ARIA
                handles.forEach((h, i) => {
                    const sizes = getSizes();
                    if (panels[i]) {
                        h.setAttribute('aria-valuenow', Math.round(sizes[i]));
                        h.setAttribute('aria-valuemin', panels[i].getAttribute('data-suite-resizable-min-size') || '10');
                        h.setAttribute('aria-valuemax', panels[i].getAttribute('data-suite-resizable-max-size') || '100');
                    }
                });
            },
        },

        // --- Carousel (scroll-snap navigation + autoplay) --------------------------
        Carousel: {
            _initialized: new Set(),

            init() {
                document.querySelectorAll('[data-suite-carousel]').forEach(root => {
                    if (this._initialized.has(root)) return;
                    this._initialized.add(root);
                    this._setup(root);
                });
            },

            _setup(root) {
                const orientation = root.getAttribute('data-suite-carousel-orientation') || 'horizontal';
                const loop = root.getAttribute('data-suite-carousel-loop') === 'true';
                const autoplay = root.getAttribute('data-suite-carousel-autoplay') === 'true';
                const interval = parseInt(root.getAttribute('data-suite-carousel-autoplay-interval') || '4000', 10);

                const content = root.querySelector('[data-suite-carousel-content]');
                const prevBtn = root.querySelector('[data-suite-carousel-prev]');
                const nextBtn = root.querySelector('[data-suite-carousel-next]');
                if (!content) return;

                const getItems = () => Array.from(content.querySelectorAll('[data-suite-carousel-item]'));

                const scrollToIdx = (idx) => {
                    const items = getItems();
                    if (items.length === 0) return;
                    const target = items[Math.max(0, Math.min(idx, items.length - 1))];
                    target.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'start' });
                };

                const getCurrentIdx = () => {
                    const items = getItems();
                    if (items.length === 0) return 0;
                    const viewport = root.querySelector('[data-suite-carousel-viewport]');
                    if (!viewport) return 0;
                    const rect = viewport.getBoundingClientRect();
                    const center = orientation === 'horizontal'
                        ? rect.left + rect.width / 2
                        : rect.top + rect.height / 2;
                    let closest = 0;
                    let minDist = Infinity;
                    items.forEach((item, i) => {
                        const ir = item.getBoundingClientRect();
                        const ic = orientation === 'horizontal'
                            ? ir.left + ir.width / 2
                            : ir.top + ir.height / 2;
                        const d = Math.abs(ic - center);
                        if (d < minDist) { minDist = d; closest = i; }
                    });
                    return closest;
                };

                const updateButtons = () => {
                    const items = getItems();
                    const idx = getCurrentIdx();
                    if (prevBtn) {
                        prevBtn.disabled = !loop && idx === 0;
                    }
                    if (nextBtn) {
                        nextBtn.disabled = !loop && idx >= items.length - 1;
                    }
                };

                const goPrev = () => {
                    const items = getItems();
                    const idx = getCurrentIdx();
                    if (idx > 0) {
                        scrollToIdx(idx - 1);
                    } else if (loop && items.length > 0) {
                        scrollToIdx(items.length - 1);
                    }
                };

                const goNext = () => {
                    const items = getItems();
                    const idx = getCurrentIdx();
                    if (idx < items.length - 1) {
                        scrollToIdx(idx + 1);
                    } else if (loop && items.length > 0) {
                        scrollToIdx(0);
                    }
                };

                if (prevBtn) prevBtn.addEventListener('click', () => { goPrev(); setTimeout(updateButtons, 350); });
                if (nextBtn) nextBtn.addEventListener('click', () => { goNext(); setTimeout(updateButtons, 350); });

                // Scroll listener to update button states
                content.addEventListener('scrollend', updateButtons);
                content.addEventListener('scroll', () => { clearTimeout(content._scrollTimer); content._scrollTimer = setTimeout(updateButtons, 150); });

                // Keyboard navigation
                root.addEventListener('keydown', (e) => {
                    if (orientation === 'horizontal') {
                        if (e.key === 'ArrowLeft') { e.preventDefault(); goPrev(); setTimeout(updateButtons, 350); }
                        if (e.key === 'ArrowRight') { e.preventDefault(); goNext(); setTimeout(updateButtons, 350); }
                    } else {
                        if (e.key === 'ArrowUp') { e.preventDefault(); goPrev(); setTimeout(updateButtons, 350); }
                        if (e.key === 'ArrowDown') { e.preventDefault(); goNext(); setTimeout(updateButtons, 350); }
                    }
                });

                // Autoplay
                if (autoplay && interval > 0) {
                    let timer = setInterval(() => { goNext(); setTimeout(updateButtons, 350); }, interval);
                    // Pause on hover
                    root.addEventListener('mouseenter', () => clearInterval(timer));
                    root.addEventListener('mouseleave', () => {
                        timer = setInterval(() => { goNext(); setTimeout(updateButtons, 350); }, interval);
                    });
                }

                // Initial button state
                requestAnimationFrame(updateButtons);
            },
        },

        // --- Auto-Discovery -------------------------------------------------------
        discover() {
            // Scan for data-suite-* attributes and initialize behaviors
            // ThemeToggle: removed (now @island)
            this.ThemeSwitcher.init();
            // Collapsible: removed (now @island)
            // Accordion: removed (now @island)
            // Tabs: removed (now @island)
            // ToggleGroup: removed (now @island)
            // Dialog: removed (now @island)
            // AlertDialog: removed (now @island)
            // Sheet: removed (now @island)
            // Drawer: removed (now @island)
            // Popover: removed (now @island)

            // Tooltip: removed (now @island)
            // HoverCard: removed (now @island)
            // DropdownMenu: removed (now @island)
            // ContextMenu: removed (now @island)
            // Menubar: removed (now @island)
            // NavigationMenu: removed (now @island)
            // Select: removed (now @island with BindModal mode=10 — SUITE-913)
            // Command: removed (now @island with BindModal mode=11/12 — SUITE-913)
            this.Toast.init();
            // Slider: removed (now @island with BindModal mode=13 — SUITE-914)
            // Calendar: removed (now @island with BindModal mode=14/15 — SUITE-914)
            // DataTable: removed (now @island with BindModal mode=16 — SUITE-915)
            // Form: removed (now @island with BindModal mode=17 — SUITE-915)
            this.CodeBlock.init();
            this.TreeView.init();
            this.Carousel.init();
            this.Resizable.init();
        },

        // --- Init -----------------------------------------------------------------
        init() {
            this.discover();

            // Re-discover on SPA navigation
            // Therapy.jl's client router fires 'therapy:router:loaded' after each navigation
            window.addEventListener('therapy:router:loaded', () => {
                requestAnimationFrame(() => this.discover());
            });
        }
    };

    window.Suite = Suite;

    // Convenience: Suite.toast("Hello") shorthand for Suite.Toast.show()
    // Also: Suite.toast.success(), Suite.toast.error(), etc.
    window.Suite.toast = function(title, opts) { return Suite.Toast.show(title, opts); };
    window.Suite.toast.success = function(title, opts) { return Suite.Toast.success(title, opts); };
    window.Suite.toast.error = function(title, opts) { return Suite.Toast.error(title, opts); };
    window.Suite.toast.warning = function(title, opts) { return Suite.Toast.warning(title, opts); };
    window.Suite.toast.info = function(title, opts) { return Suite.Toast.info(title, opts); };
    window.Suite.toast.dismiss = function(id) { return Suite.Toast.dismiss(id); };
    window.Suite.toast.dismissAll = function() { return Suite.Toast.dismissAll(); };

    Suite.init();
})();
