# Suite.jl utilities
#
# Equivalent to shadcn/ui's cn() utility (clsx + tailwind-merge).
# For now, simple class concatenation. Can add tailwind-merge logic later.

export cn

"""
    cn(classes...) -> String

Combine CSS class strings, filtering out empty/nothing values.
Equivalent to shadcn/ui's `cn()` utility.

# Example
```julia
cn("px-4 py-2", is_active && "bg-accent-600", nothing, "text-white")
# => "px-4 py-2 bg-accent-600 text-white"
```
"""
function cn(classes...)
    parts = String[]
    for c in classes
        if c isa AbstractString && !isempty(c)
            push!(parts, strip(c))
        elseif c === true
            # skip bare `true` from short-circuit
        end
    end
    join(parts, " ")
end
