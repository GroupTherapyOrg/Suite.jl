# Theme class safelist — scanned by Tailwind to ensure all theme variants compile
# DO NOT use these strings directly — they exist only for Tailwind scanning
#
# Each non-default theme uses Tailwind built-in color scales that must appear
# in source files for Tailwind v4 tree-shaking to include them.
#
# NOTE: :islands theme uses CSS custom properties (like :default), NOT string
# substitution for colors. Its accent/accent-secondary/warm tokens are already
# compiled via component source files. Only its structural tokens (rounded-xl,
# rounded-lg, shadow-md) need safelisting — and they're already present below.

const _THEME_SAFELIST = """
bg-blue-50 bg-blue-100 bg-blue-200 bg-blue-300 bg-blue-400 bg-blue-500 bg-blue-600 bg-blue-700 bg-blue-800 bg-blue-900 bg-blue-950
text-blue-300 text-blue-400 text-blue-500 text-blue-600 text-blue-700 text-blue-800
border-blue-200 border-blue-700 ring-blue-500
hover:bg-blue-100 hover:bg-blue-700 hover:bg-blue-800 hover:bg-blue-900
dark:bg-blue-800 dark:bg-blue-900 dark:bg-blue-950
dark:text-blue-300 dark:text-blue-400 dark:text-blue-500
dark:border-blue-700
focus-visible:ring-blue-500 focus-visible:ring-blue-600
divide-blue-200 dark:divide-blue-700

bg-rose-50 bg-rose-100 bg-rose-200 bg-rose-500 bg-rose-600 bg-rose-700
text-rose-400 text-rose-500 text-rose-600 text-rose-700 text-rose-800
border-rose-200 border-rose-700
hover:bg-rose-700
dark:text-rose-400

bg-zinc-50 bg-zinc-100 bg-zinc-200 bg-zinc-300 bg-zinc-400 bg-zinc-500 bg-zinc-600 bg-zinc-700 bg-zinc-800 bg-zinc-900 bg-zinc-950
text-zinc-300 text-zinc-400 text-zinc-500 text-zinc-600 text-zinc-700 text-zinc-800
border-zinc-200 border-zinc-700 ring-zinc-500
hover:bg-zinc-100 hover:bg-zinc-700 hover:bg-zinc-800 hover:bg-zinc-900
dark:bg-zinc-800 dark:bg-zinc-900 dark:bg-zinc-950
dark:text-zinc-300 dark:text-zinc-400 dark:text-zinc-500
dark:border-zinc-700
focus-visible:ring-zinc-500 focus-visible:ring-zinc-600
divide-zinc-200 dark:divide-zinc-700

bg-red-50 bg-red-100 bg-red-200 bg-red-500 bg-red-600 bg-red-700
text-red-400 text-red-500 text-red-600 text-red-700 text-red-800
border-red-200 border-red-700
hover:bg-red-700
dark:text-red-400

bg-slate-50 bg-slate-100 bg-slate-200 bg-slate-300 bg-slate-400 bg-slate-500 bg-slate-600 bg-slate-700 bg-slate-800 bg-slate-900 bg-slate-950
text-slate-300 text-slate-400 text-slate-500 text-slate-600 text-slate-700 text-slate-800
border-slate-200 border-slate-700
hover:bg-slate-100 hover:bg-slate-200 hover:bg-slate-800 hover:bg-slate-900
dark:bg-slate-800 dark:bg-slate-900 dark:bg-slate-950
dark:text-slate-300 dark:text-slate-400 dark:text-slate-500
dark:border-slate-700
dark:hover:bg-slate-800 dark:hover:bg-slate-900
divide-slate-200 dark:divide-slate-700
ring-offset-slate-50 dark:ring-offset-slate-950

bg-emerald-50 bg-emerald-100 bg-emerald-200 bg-emerald-300 bg-emerald-400 bg-emerald-500 bg-emerald-600 bg-emerald-700 bg-emerald-800 bg-emerald-900 bg-emerald-950
text-emerald-300 text-emerald-400 text-emerald-500 text-emerald-600 text-emerald-700 text-emerald-800
border-emerald-200 border-emerald-700 ring-emerald-500
hover:bg-emerald-100 hover:bg-emerald-700 hover:bg-emerald-800 hover:bg-emerald-900
dark:bg-emerald-800 dark:bg-emerald-900 dark:bg-emerald-950
dark:text-emerald-300 dark:text-emerald-400 dark:text-emerald-500
dark:border-emerald-700
focus-visible:ring-emerald-500 focus-visible:ring-emerald-600
divide-emerald-200 dark:divide-emerald-700

bg-amber-50 bg-amber-100 bg-amber-200 bg-amber-500 bg-amber-600 bg-amber-700
text-amber-400 text-amber-500 text-amber-600 text-amber-700 text-amber-800
border-amber-200 border-amber-700
hover:bg-amber-700
dark:text-amber-400

bg-stone-50 bg-stone-100 bg-stone-200 bg-stone-300 bg-stone-400 bg-stone-500 bg-stone-600 bg-stone-700 bg-stone-800 bg-stone-900 bg-stone-950
text-stone-300 text-stone-400 text-stone-500 text-stone-600 text-stone-700 text-stone-800
border-stone-200 border-stone-700
hover:bg-stone-100 hover:bg-stone-200 hover:bg-stone-800 hover:bg-stone-900
dark:bg-stone-800 dark:bg-stone-900 dark:bg-stone-950
dark:text-stone-300 dark:text-stone-400 dark:text-stone-500
dark:border-stone-700
dark:hover:bg-stone-800 dark:hover:bg-stone-900
divide-stone-200 dark:divide-stone-700
ring-offset-stone-50 dark:ring-offset-stone-950

rounded-none rounded-lg rounded-xl rounded-2xl rounded-full
shadow-none shadow-md shadow-lg
"""
