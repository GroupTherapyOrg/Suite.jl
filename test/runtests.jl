using Test

@testset "Suite.jl" begin
    @testset "cn() class utility" begin
        include("../src/utils.jl")

        @test cn("px-4", "py-2") == "px-4 py-2"
        @test cn("px-4", "", "py-2") == "px-4 py-2"
        @test cn("px-4", nothing, "py-2") == "px-4 py-2"
        @test cn("px-4", false, "py-2") == "px-4 py-2"
        @test cn("px-4", true && "bg-blue-500") == "px-4 bg-blue-500"
        @test cn("px-4", false && "bg-blue-500") == "px-4"
        @test cn() == ""
        @test cn("  px-4  ", "py-2") == "px-4 py-2"
    end

    @testset "ComponentMeta & Registry" begin
        include("../src/registry.jl")

        meta = ComponentMeta(
            :TestComp,
            "TestComp.jl",
            :styling,
            "Test component",
            Symbol[],
            Symbol[],
            [:SuiteTestComp],
        )
        @test meta.name == :TestComp
        @test meta.tier == :styling
        @test isempty(meta.suite_deps)

        register_component!(meta)
        @test haskey(COMPONENT_REGISTRY, :TestComp)
        @test COMPONENT_REGISTRY[:TestComp].file == "TestComp.jl"

        # Dependency resolution
        meta2 = ComponentMeta(
            :DepComp,
            "DepComp.jl",
            :js_runtime,
            "Component with deps",
            [:TestComp],
            [:FocusTrap],
            [:SuiteDepComp],
        )
        register_component!(meta2)

        deps = resolve_deps([:DepComp])
        @test deps == [:TestComp, :DepComp]

        deps2 = resolve_deps([:TestComp])
        @test deps2 == [:TestComp]

        # Clean up
        delete!(COMPONENT_REGISTRY, :TestComp)
        delete!(COMPONENT_REGISTRY, :DepComp)
    end

    @testset "SuiteButton" begin
        using Therapy
        using Suite

        @testset "Default variant and size" begin
            html = Therapy.render_to_string(SuiteButton("Click me"))
            @test occursin("<button", html)
            @test occursin("Click me", html)
            @test occursin("bg-accent-600", html)
            @test occursin("text-white", html)
            @test occursin("h-10", html)
            @test occursin("px-4", html)
        end

        @testset "All variants" begin
            for variant in ["default", "destructive", "outline", "secondary", "ghost", "link"]
                html = Therapy.render_to_string(SuiteButton(variant=variant, "Test"))
                @test occursin("<button", html)
                @test occursin("Test", html)
            end

            html_outline = Therapy.render_to_string(SuiteButton(variant="outline", "X"))
            @test occursin("border", html_outline)
            @test occursin("bg-warm-50", html_outline)

            html_destructive = Therapy.render_to_string(SuiteButton(variant="destructive", "X"))
            @test occursin("bg-accent-secondary-600", html_destructive)

            html_ghost = Therapy.render_to_string(SuiteButton(variant="ghost", "X"))
            @test occursin("hover:bg-warm-100", html_ghost)

            html_link = Therapy.render_to_string(SuiteButton(variant="link", "X"))
            @test occursin("underline-offset-4", html_link)
            @test occursin("text-accent-600", html_link)

            html_secondary = Therapy.render_to_string(SuiteButton(variant="secondary", "X"))
            @test occursin("bg-warm-100", html_secondary)
        end

        @testset "All sizes" begin
            html_sm = Therapy.render_to_string(SuiteButton(size="sm", "S"))
            @test occursin("h-9", html_sm)
            @test occursin("px-3", html_sm)

            html_lg = Therapy.render_to_string(SuiteButton(size="lg", "L"))
            @test occursin("h-11", html_lg)
            @test occursin("px-8", html_lg)

            html_icon = Therapy.render_to_string(SuiteButton(size="icon", "✕"))
            @test occursin("h-10", html_icon)
            @test occursin("w-10", html_icon)
        end

        @testset "Custom class merging" begin
            html = Therapy.render_to_string(SuiteButton(class="my-custom-class", "X"))
            @test occursin("my-custom-class", html)
            @test occursin("bg-accent-600", html)
        end

        @testset "Accessibility" begin
            html = Therapy.render_to_string(SuiteButton("Click"))
            @test occursin("focus-visible:ring-2", html)
            @test occursin("disabled:opacity-50", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(SuiteButton(variant="outline", "X"))
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:bg-warm-950", html)
            @test occursin("dark:text-warm-300", html)
        end

        @testset "Pass-through kwargs" begin
            html = Therapy.render_to_string(SuiteButton(:id => "my-btn", "X"))
            @test occursin("id=\"my-btn\"", html)
        end

        @testset "Registry registration" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Button)
            meta = Suite.COMPONENT_REGISTRY[:Button]
            @test meta.tier == :styling
            @test meta.file == "Button.jl"
            @test :SuiteButton in meta.exports
            @test isempty(meta.suite_deps)
        end

        @testset "Suite.list() and Suite.info()" begin
            # Capture stdout via sprint-style pattern (Julia 1.12 compatible)
            output = let pipe = Pipe()
                redirect_stdout(pipe) do
                    Suite.list()
                end
                close(pipe.in)
                read(pipe.out, String)
            end
            @test occursin("Button", output)

            output2 = let pipe = Pipe()
                redirect_stdout(pipe) do
                    Suite.info(:Button)
                end
                close(pipe.in)
                read(pipe.out, String)
            end
            @test occursin("Button", output2)
            @test occursin("styling", output2)
        end
    end

    @testset "SuiteBadge" begin
        @testset "Default variant" begin
            html = Therapy.render_to_string(SuiteBadge("New"))
            @test occursin("<span", html)
            @test occursin("New", html)
            @test occursin("bg-accent-600", html)
            @test occursin("text-white", html)
            @test occursin("rounded-full", html)
            @test occursin("text-xs", html)
        end

        @testset "All variants" begin
            for variant in ["default", "secondary", "destructive", "outline"]
                html = Therapy.render_to_string(SuiteBadge(variant=variant, "Tag"))
                @test occursin("<span", html)
                @test occursin("Tag", html)
            end

            html_secondary = Therapy.render_to_string(SuiteBadge(variant="secondary", "X"))
            @test occursin("bg-warm-100", html_secondary)

            html_destructive = Therapy.render_to_string(SuiteBadge(variant="destructive", "X"))
            @test occursin("text-accent-secondary-600", html_destructive)

            html_outline = Therapy.render_to_string(SuiteBadge(variant="outline", "X"))
            @test occursin("border-warm-200", html_outline)
        end

        @testset "Custom class and kwargs" begin
            html = Therapy.render_to_string(SuiteBadge(class="ml-2", "X"))
            @test occursin("ml-2", html)
            @test occursin("bg-accent-600", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(SuiteBadge(variant="secondary", "X"))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-300", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Badge)
            @test Suite.COMPONENT_REGISTRY[:Badge].tier == :styling
        end
    end

    @testset "SuiteAlert" begin
        @testset "Default variant" begin
            html = Therapy.render_to_string(SuiteAlert(
                SuiteAlertTitle("Title"),
                SuiteAlertDescription("Description"),
            ))
            @test occursin("role=\"alert\"", html)
            @test occursin("Title", html)
            @test occursin("Description", html)
            @test occursin("bg-warm-100", html)
            @test occursin("rounded-lg", html)
            @test occursin("border", html)
        end

        @testset "Destructive variant" begin
            html = Therapy.render_to_string(SuiteAlert(variant="destructive",
                SuiteAlertTitle("Error"),
            ))
            @test occursin("role=\"alert\"", html)
            @test occursin("text-accent-secondary-600", html)
            @test occursin("Error", html)
        end

        @testset "AlertTitle classes" begin
            html = Therapy.render_to_string(SuiteAlertTitle("Heads up"))
            @test occursin("font-medium", html)
            @test occursin("Heads up", html)
        end

        @testset "AlertDescription classes" begin
            html = Therapy.render_to_string(SuiteAlertDescription("Details here"))
            @test occursin("text-warm-600", html)
            @test occursin("Details here", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteAlert(class="my-alert", SuiteAlertTitle("X")))
            @test occursin("my-alert", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(SuiteAlert(SuiteAlertTitle("X")))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:border-warm-700", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Alert)
            @test :SuiteAlert in Suite.COMPONENT_REGISTRY[:Alert].exports
            @test :SuiteAlertTitle in Suite.COMPONENT_REGISTRY[:Alert].exports
            @test :SuiteAlertDescription in Suite.COMPONENT_REGISTRY[:Alert].exports
        end
    end

    @testset "SuiteCard" begin
        @testset "Basic card structure" begin
            html = Therapy.render_to_string(SuiteCard(
                SuiteCardHeader(
                    SuiteCardTitle("Title"),
                    SuiteCardDescription("Desc"),
                ),
                SuiteCardContent("Body"),
                SuiteCardFooter("Footer"),
            ))
            @test occursin("rounded-xl", html)
            @test occursin("shadow-sm", html)
            @test occursin("bg-warm-100", html)
            @test occursin("Title", html)
            @test occursin("Desc", html)
            @test occursin("Body", html)
            @test occursin("Footer", html)
        end

        @testset "CardHeader classes" begin
            html = Therapy.render_to_string(SuiteCardHeader(SuiteCardTitle("X")))
            @test occursin("px-6", html)
            @test occursin("flex", html)
        end

        @testset "CardTitle classes" begin
            html = Therapy.render_to_string(SuiteCardTitle("Big Title"))
            @test occursin("font-semibold", html)
            @test occursin("Big Title", html)
        end

        @testset "CardDescription classes" begin
            html = Therapy.render_to_string(SuiteCardDescription("Some desc"))
            @test occursin("text-warm-600", html)
            @test occursin("Some desc", html)
        end

        @testset "CardContent classes" begin
            html = Therapy.render_to_string(SuiteCardContent("Content"))
            @test occursin("px-6", html)
            @test occursin("Content", html)
        end

        @testset "CardFooter classes" begin
            html = Therapy.render_to_string(SuiteCardFooter("Actions"))
            @test occursin("flex", html)
            @test occursin("items-center", html)
            @test occursin("Actions", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteCard(class="w-[350px]", SuiteCardContent("X")))
            @test occursin("w-[350px]", html)
            @test occursin("rounded-xl", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(SuiteCard(SuiteCardContent("X")))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:text-warm-300", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Card)
            meta = Suite.COMPONENT_REGISTRY[:Card]
            @test :SuiteCard in meta.exports
            @test :SuiteCardHeader in meta.exports
            @test :SuiteCardTitle in meta.exports
            @test :SuiteCardContent in meta.exports
            @test :SuiteCardFooter in meta.exports
        end
    end

    @testset "SuiteSeparator" begin
        @testset "Horizontal (default)" begin
            html = Therapy.render_to_string(SuiteSeparator())
            @test occursin("h-px", html)
            @test occursin("w-full", html)
            @test occursin("bg-warm-200", html)
            @test occursin("role=\"none\"", html)
        end

        @testset "Vertical" begin
            html = Therapy.render_to_string(SuiteSeparator(orientation="vertical"))
            @test occursin("h-full", html)
            @test occursin("w-px", html)
        end

        @testset "Non-decorative" begin
            html = Therapy.render_to_string(SuiteSeparator(decorative=false))
            @test occursin("role=\"separator\"", html)
            @test occursin("aria-orientation=\"horizontal\"", html)
        end

        @testset "Non-decorative vertical" begin
            html = Therapy.render_to_string(SuiteSeparator(decorative=false, orientation="vertical"))
            @test occursin("role=\"separator\"", html)
            @test occursin("aria-orientation=\"vertical\"", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteSeparator(class="my-4"))
            @test occursin("my-4", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(SuiteSeparator())
            @test occursin("dark:bg-warm-700", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Separator)
            @test Suite.COMPONENT_REGISTRY[:Separator].tier == :styling
        end
    end

    @testset "SuiteSkeleton" begin
        @testset "Default" begin
            html = Therapy.render_to_string(SuiteSkeleton())
            @test occursin("animate-pulse", html)
            @test occursin("rounded-md", html)
            @test occursin("bg-warm-200", html)
        end

        @testset "Custom dimensions" begin
            html = Therapy.render_to_string(SuiteSkeleton(class="h-4 w-[250px]"))
            @test occursin("h-4", html)
            @test occursin("w-[250px]", html)
            @test occursin("animate-pulse", html)
        end

        @testset "Circle skeleton" begin
            html = Therapy.render_to_string(SuiteSkeleton(class="h-12 w-12 rounded-full"))
            @test occursin("rounded-full", html)
            @test occursin("animate-pulse", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(SuiteSkeleton())
            @test occursin("dark:bg-warm-800", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Skeleton)
            @test Suite.COMPONENT_REGISTRY[:Skeleton].tier == :styling
        end
    end

    @testset "SuiteInput" begin
        @testset "Default" begin
            html = Therapy.render_to_string(SuiteInput(placeholder="Email"))
            @test occursin("<input", html)
            @test occursin("type=\"text\"", html)
            @test occursin("placeholder=\"Email\"", html)
            @test occursin("rounded-md", html)
            @test occursin("border-warm-200", html)
            @test occursin("h-9", html)
        end

        @testset "Type prop" begin
            html = Therapy.render_to_string(SuiteInput(type="password"))
            @test occursin("type=\"password\"", html)
        end

        @testset "Focus styles" begin
            html = Therapy.render_to_string(SuiteInput())
            @test occursin("focus-visible:border-accent-600", html)
            @test occursin("focus-visible:ring-2", html)
        end

        @testset "Disabled styles" begin
            html = Therapy.render_to_string(SuiteInput())
            @test occursin("disabled:opacity-50", html)
            @test occursin("disabled:cursor-not-allowed", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(SuiteInput())
            @test occursin("dark:border-warm-700", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteInput(class="w-[300px]"))
            @test occursin("w-[300px]", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Input)
            @test Suite.COMPONENT_REGISTRY[:Input].tier == :styling
        end
    end

    @testset "SuiteLabel" begin
        @testset "Default" begin
            html = Therapy.render_to_string(SuiteLabel("Email"))
            @test occursin("<label", html)
            @test occursin("Email", html)
            @test occursin("text-sm", html)
            @test occursin("font-medium", html)
            @test occursin("select-none", html)
        end

        @testset "For attribute" begin
            html = Therapy.render_to_string(SuiteLabel("Name", :for => "name-input"))
            @test occursin("for=\"name-input\"", html)
        end

        @testset "Peer disabled" begin
            html = Therapy.render_to_string(SuiteLabel("X"))
            @test occursin("peer-disabled:cursor-not-allowed", html)
            @test occursin("peer-disabled:opacity-50", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteLabel(class="mb-2", "X"))
            @test occursin("mb-2", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Label)
            @test Suite.COMPONENT_REGISTRY[:Label].tier == :styling
        end
    end

    @testset "SuiteTextarea" begin
        @testset "Default" begin
            html = Therapy.render_to_string(SuiteTextarea(placeholder="Message"))
            @test occursin("<textarea", html)
            @test occursin("placeholder=\"Message\"", html)
            @test occursin("rounded-md", html)
            @test occursin("border-warm-200", html)
            @test occursin("min-h-16", html)
        end

        @testset "Focus styles" begin
            html = Therapy.render_to_string(SuiteTextarea())
            @test occursin("focus-visible:border-accent-600", html)
            @test occursin("focus-visible:ring-2", html)
        end

        @testset "Disabled styles" begin
            html = Therapy.render_to_string(SuiteTextarea())
            @test occursin("disabled:opacity-50", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(SuiteTextarea())
            @test occursin("dark:border-warm-700", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteTextarea(class="h-32"))
            @test occursin("h-32", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Textarea)
            @test Suite.COMPONENT_REGISTRY[:Textarea].tier == :styling
        end
    end

    @testset "SuiteAvatar" begin
        @testset "Default size" begin
            html = Therapy.render_to_string(SuiteAvatar(
                SuiteAvatarFallback("JD"),
            ))
            @test occursin("<span", html)
            @test occursin("rounded-full", html)
            @test occursin("size-8", html)
            @test occursin("JD", html)
        end

        @testset "All sizes" begin
            html_sm = Therapy.render_to_string(SuiteAvatar(size="sm", SuiteAvatarFallback("X")))
            @test occursin("size-6", html_sm)

            html_lg = Therapy.render_to_string(SuiteAvatar(size="lg", SuiteAvatarFallback("X")))
            @test occursin("size-10", html_lg)
        end

        @testset "AvatarImage" begin
            html = Therapy.render_to_string(SuiteAvatarImage(src="/avatar.jpg", alt="User"))
            @test occursin("<img", html)
            @test occursin("src=\"/avatar.jpg\"", html)
            @test occursin("alt=\"User\"", html)
            @test occursin("aspect-square", html)
        end

        @testset "AvatarFallback" begin
            html = Therapy.render_to_string(SuiteAvatarFallback("AB"))
            @test occursin("AB", html)
            @test occursin("bg-warm-100", html)
            @test occursin("items-center", html)
            @test occursin("justify-center", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(SuiteAvatarFallback("X"))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-500", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteAvatar(class="border-2", SuiteAvatarFallback("X")))
            @test occursin("border-2", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Avatar)
            meta = Suite.COMPONENT_REGISTRY[:Avatar]
            @test :SuiteAvatar in meta.exports
            @test :SuiteAvatarImage in meta.exports
            @test :SuiteAvatarFallback in meta.exports
        end
    end

    @testset "SuiteAspectRatio" begin
        @testset "Default 16/9" begin
            html = Therapy.render_to_string(SuiteAspectRatio(Div("Content")))
            @test occursin("aspect-ratio:", html)
            @test occursin("relative", html)
            @test occursin("overflow-hidden", html)
            @test occursin("Content", html)
        end

        @testset "Custom ratio" begin
            html = Therapy.render_to_string(SuiteAspectRatio(ratio=1, Div("Square")))
            @test occursin("aspect-ratio: 1", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteAspectRatio(class="rounded-lg", Div("X")))
            @test occursin("rounded-lg", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :AspectRatio)
            @test Suite.COMPONENT_REGISTRY[:AspectRatio].tier == :styling
        end
    end

    @testset "SuiteProgress" begin
        @testset "Default (0%)" begin
            html = Therapy.render_to_string(SuiteProgress())
            @test occursin("role=\"progressbar\"", html)
            @test occursin("aria-valuenow=\"0\"", html)
            @test occursin("aria-valuemin=\"0\"", html)
            @test occursin("aria-valuemax=\"100\"", html)
            @test occursin("rounded-full", html)
            @test occursin("h-2", html)
            @test occursin("translateX(-100%)", html)
        end

        @testset "Partial progress" begin
            html = Therapy.render_to_string(SuiteProgress(value=60))
            @test occursin("aria-valuenow=\"60\"", html)
            @test occursin("translateX(-40%)", html)
        end

        @testset "Full progress" begin
            html = Therapy.render_to_string(SuiteProgress(value=100))
            @test occursin("aria-valuenow=\"100\"", html)
            @test occursin("translateX(-0%)", html)
        end

        @testset "Clamped values" begin
            html_neg = Therapy.render_to_string(SuiteProgress(value=-10))
            @test occursin("aria-valuenow=\"0\"", html_neg)

            html_over = Therapy.render_to_string(SuiteProgress(value=150))
            @test occursin("aria-valuenow=\"100\"", html_over)
        end

        @testset "Indicator colors" begin
            html = Therapy.render_to_string(SuiteProgress(value=50))
            @test occursin("bg-accent-600", html)
            @test occursin("transition-all", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteProgress(value=50, class="w-[60%]"))
            @test occursin("w-[60%]", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Progress)
            @test Suite.COMPONENT_REGISTRY[:Progress].tier == :styling
        end
    end

    @testset "SuiteTable" begin
        @testset "Basic table structure" begin
            html = Therapy.render_to_string(SuiteTable(
                SuiteTableHeader(
                    SuiteTableRow(
                        SuiteTableHead("Name"),
                        SuiteTableHead("Email"),
                    ),
                ),
                SuiteTableBody(
                    SuiteTableRow(
                        SuiteTableCell("Alice"),
                        SuiteTableCell("alice@ex.com"),
                    ),
                ),
            ))
            @test occursin("<table", html)
            @test occursin("overflow-x-auto", html)
            @test occursin("Name", html)
            @test occursin("Alice", html)
            @test occursin("alice@ex.com", html)
        end

        @testset "TableHeader" begin
            html = Therapy.render_to_string(SuiteTableHeader(SuiteTableRow(SuiteTableHead("X"))))
            @test occursin("<thead", html)
            @test occursin("border-b", html)
        end

        @testset "TableHead" begin
            html = Therapy.render_to_string(SuiteTableHead("Col"))
            @test occursin("<th", html)
            @test occursin("h-10", html)
            @test occursin("font-medium", html)
            @test occursin("text-warm-600", html)
        end

        @testset "TableRow" begin
            html = Therapy.render_to_string(SuiteTableRow(SuiteTableCell("X")))
            @test occursin("<tr", html)
            @test occursin("hover:bg-warm-100/50", html)
            @test occursin("transition-colors", html)
        end

        @testset "TableCell" begin
            html = Therapy.render_to_string(SuiteTableCell("Data"))
            @test occursin("<td", html)
            @test occursin("p-2", html)
            @test occursin("Data", html)
        end

        @testset "TableFooter" begin
            html = Therapy.render_to_string(SuiteTableFooter(SuiteTableRow(SuiteTableCell("Total"))))
            @test occursin("<tfoot", html)
            @test occursin("font-medium", html)
            @test occursin("border-t", html)
        end

        @testset "TableCaption" begin
            html = Therapy.render_to_string(SuiteTableCaption("A list of items"))
            @test occursin("<caption", html)
            @test occursin("text-warm-600", html)
            @test occursin("A list of items", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(SuiteTableRow(SuiteTableCell("X")))
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:hover:bg-warm-900/50", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Table)
            meta = Suite.COMPONENT_REGISTRY[:Table]
            @test :SuiteTable in meta.exports
            @test :SuiteTableHead in meta.exports
            @test :SuiteTableCell in meta.exports
            @test :SuiteTableCaption in meta.exports
        end
    end

    @testset "SuiteScrollArea" begin
        @testset "Default" begin
            html = Therapy.render_to_string(SuiteScrollArea(Div("Content")))
            @test occursin("overflow-auto", html)
            @test occursin("relative", html)
            @test occursin("Content", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteScrollArea(class="h-[200px] w-[350px]", Div("X")))
            @test occursin("h-[200px]", html)
            @test occursin("w-[350px]", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :ScrollArea)
        end
    end

    @testset "SuiteBreadcrumb" begin
        @testset "Full breadcrumb" begin
            html = Therapy.render_to_string(SuiteBreadcrumb(
                SuiteBreadcrumbList(
                    SuiteBreadcrumbItem(SuiteBreadcrumbLink("Home", href="/")),
                    SuiteBreadcrumbSeparator(),
                    SuiteBreadcrumbItem(SuiteBreadcrumbPage("Current")),
                ),
            ))
            @test occursin("<nav", html)
            @test occursin("aria-label=\"breadcrumb\"", html)
            @test occursin("Home", html)
            @test occursin("Current", html)
        end

        @testset "BreadcrumbList" begin
            html = Therapy.render_to_string(SuiteBreadcrumbList(SuiteBreadcrumbItem("X")))
            @test occursin("<ol", html)
            @test occursin("text-warm-600", html)
            @test occursin("text-sm", html)
        end

        @testset "BreadcrumbLink" begin
            html = Therapy.render_to_string(SuiteBreadcrumbLink("Docs", href="/docs"))
            @test occursin("<a", html)
            @test occursin("href=\"/docs\"", html)
            @test occursin("transition-colors", html)
        end

        @testset "BreadcrumbPage" begin
            html = Therapy.render_to_string(SuiteBreadcrumbPage("Current"))
            @test occursin("aria-current=\"page\"", html)
            @test occursin("aria-disabled=\"true\"", html)
            @test occursin("role=\"link\"", html)
            @test occursin("font-normal", html)
        end

        @testset "BreadcrumbSeparator" begin
            html = Therapy.render_to_string(SuiteBreadcrumbSeparator())
            @test occursin("role=\"presentation\"", html)
            @test occursin("aria-hidden=\"true\"", html)
        end

        @testset "BreadcrumbEllipsis" begin
            html = Therapy.render_to_string(SuiteBreadcrumbEllipsis())
            @test occursin("aria-hidden=\"true\"", html)
            @test occursin("...", html)
            @test occursin("sr-only", html)
            @test occursin("More", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Breadcrumb)
            meta = Suite.COMPONENT_REGISTRY[:Breadcrumb]
            @test :SuiteBreadcrumb in meta.exports
            @test :SuiteBreadcrumbPage in meta.exports
        end
    end

    @testset "SuitePagination" begin
        @testset "Full pagination" begin
            html = Therapy.render_to_string(SuitePagination(
                SuitePaginationContent(
                    SuitePaginationItem(SuitePaginationPrevious()),
                    SuitePaginationItem(SuitePaginationLink("1", is_active=true)),
                    SuitePaginationItem(SuitePaginationLink("2")),
                    SuitePaginationItem(SuitePaginationEllipsis()),
                    SuitePaginationItem(SuitePaginationNext()),
                ),
            ))
            @test occursin("<nav", html)
            @test occursin("role=\"navigation\"", html)
            @test occursin("aria-label=\"pagination\"", html)
            @test occursin("Previous", html)
            @test occursin("Next", html)
        end

        @testset "Active link" begin
            html = Therapy.render_to_string(SuitePaginationLink("1", is_active=true))
            @test occursin("aria-current=\"page\"", html)
            @test occursin("border", html)
        end

        @testset "Inactive link" begin
            html = Therapy.render_to_string(SuitePaginationLink("2"))
            @test occursin("<a", html)
            @test occursin("hover:bg-warm-100", html)
        end

        @testset "Previous" begin
            html = Therapy.render_to_string(SuitePaginationPrevious(href="/page/1"))
            @test occursin("aria-label=\"Go to previous page\"", html)
            @test occursin("href=\"/page/1\"", html)
        end

        @testset "Next" begin
            html = Therapy.render_to_string(SuitePaginationNext(href="/page/3"))
            @test occursin("aria-label=\"Go to next page\"", html)
            @test occursin("href=\"/page/3\"", html)
        end

        @testset "Ellipsis" begin
            html = Therapy.render_to_string(SuitePaginationEllipsis())
            @test occursin("aria-hidden=\"true\"", html)
            @test occursin("sr-only", html)
            @test occursin("More pages", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Pagination)
            meta = Suite.COMPONENT_REGISTRY[:Pagination]
            @test :SuitePagination in meta.exports
            @test :SuitePaginationLink in meta.exports
        end
    end

    @testset "SuiteTypography" begin
        @testset "H1" begin
            html = Therapy.render_to_string(SuiteH1("Title"))
            @test occursin("<h1", html)
            @test occursin("text-4xl", html)
            @test occursin("font-extrabold", html)
            @test occursin("Title", html)
        end

        @testset "H2" begin
            html = Therapy.render_to_string(SuiteH2("Section"))
            @test occursin("<h2", html)
            @test occursin("text-3xl", html)
            @test occursin("border-b", html)
            @test occursin("Section", html)
        end

        @testset "H3" begin
            html = Therapy.render_to_string(SuiteH3("Sub"))
            @test occursin("<h3", html)
            @test occursin("text-2xl", html)
        end

        @testset "H4" begin
            html = Therapy.render_to_string(SuiteH4("Minor"))
            @test occursin("<h4", html)
            @test occursin("text-xl", html)
        end

        @testset "P" begin
            html = Therapy.render_to_string(SuiteP("Paragraph"))
            @test occursin("<p", html)
            @test occursin("leading-7", html)
        end

        @testset "Blockquote" begin
            html = Therapy.render_to_string(SuiteBlockquote("Quote"))
            @test occursin("<blockquote", html)
            @test occursin("border-l-2", html)
            @test occursin("italic", html)
        end

        @testset "InlineCode" begin
            html = Therapy.render_to_string(SuiteInlineCode("npm install"))
            @test occursin("<code", html)
            @test occursin("font-mono", html)
            @test occursin("bg-warm-100", html)
        end

        @testset "Lead" begin
            html = Therapy.render_to_string(SuiteLead("Intro text"))
            @test occursin("text-xl", html)
            @test occursin("text-warm-600", html)
        end

        @testset "Large" begin
            html = Therapy.render_to_string(SuiteLarge("Big"))
            @test occursin("text-lg", html)
            @test occursin("font-semibold", html)
        end

        @testset "Small" begin
            html = Therapy.render_to_string(SuiteSmall("Tiny"))
            @test occursin("text-sm", html)
            @test occursin("font-medium", html)
        end

        @testset "Muted" begin
            html = Therapy.render_to_string(SuiteMuted("Secondary"))
            @test occursin("text-warm-600", html)
            @test occursin("text-sm", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(SuiteBlockquote("X"))
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:text-warm-500", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteH1(class="text-center", "X"))
            @test occursin("text-center", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Typography)
            meta = Suite.COMPONENT_REGISTRY[:Typography]
            @test :SuiteH1 in meta.exports
            @test :SuiteBlockquote in meta.exports
            @test :SuiteInlineCode in meta.exports
        end
    end

    @testset "SuiteThemeToggle" begin
        @testset "Default" begin
            html = Therapy.render_to_string(SuiteThemeToggle())
            @test occursin("<button", html)
            @test occursin("data-suite-theme-toggle", html)
            @test occursin("aria-label=\"Toggle dark mode\"", html)
            @test occursin("type=\"button\"", html)
        end

        @testset "Sun and moon icons" begin
            html = Therapy.render_to_string(SuiteThemeToggle())
            @test occursin("<svg", html)
            # Sun icon (dark mode visible)
            @test occursin("hidden dark:block", html)
            # Moon icon (light mode visible)
            @test occursin("block dark:hidden", html)
        end

        @testset "Hover styles" begin
            html = Therapy.render_to_string(SuiteThemeToggle())
            @test occursin("hover:bg-warm-200", html)
            @test occursin("dark:hover:bg-warm-800", html)
            @test occursin("cursor-pointer", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteThemeToggle(class="ml-4"))
            @test occursin("ml-4", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :ThemeToggle)
            meta = Suite.COMPONENT_REGISTRY[:ThemeToggle]
            @test meta.tier == :js_runtime
            @test :SuiteThemeToggle in meta.exports
            @test :ThemeToggle in meta.js_modules
        end
    end

    @testset "suite_theme_script" begin
        html = Therapy.render_to_string(suite_theme_script())
        @test occursin("<script", html)
        @test occursin("therapy-theme", html)
        @test occursin("prefers-color-scheme", html)
        @test occursin("classList.add", html)
    end

    @testset "suite_script" begin
        html = Therapy.render_to_string(suite_script())
        @test occursin("<script", html)
        @test occursin("Suite", html)
        @test occursin("ThemeToggle", html)
        @test occursin("data-suite-theme-toggle", html)
        # Verify new modules are in suite.js
        @test occursin("Collapsible", html)
        @test occursin("Accordion", html)
        @test occursin("Tabs", html)
    end

    # ==========================================================================
    # Phase 2: Interactive Components
    # ==========================================================================

    @testset "SuiteCollapsible" begin
        @testset "Default (closed)" begin
            html = Therapy.render_to_string(SuiteCollapsible(
                SuiteCollapsibleTrigger("Toggle"),
                SuiteCollapsibleContent(Div("Content")),
            ))
            @test occursin("data-suite-collapsible", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("Toggle", html)
            @test occursin("Content", html)
        end

        @testset "Open by default" begin
            html = Therapy.render_to_string(SuiteCollapsible(open=true,
                SuiteCollapsibleTrigger("Close"),
                SuiteCollapsibleContent(Div("Visible")),
            ))
            @test occursin("data-state=\"open\"", html)
        end

        @testset "Disabled" begin
            html = Therapy.render_to_string(SuiteCollapsible(disabled=true,
                SuiteCollapsibleTrigger("Disabled"),
                SuiteCollapsibleContent(Div("Hidden")),
            ))
            @test occursin("data-disabled", html)
        end

        @testset "Trigger structure" begin
            html = Therapy.render_to_string(SuiteCollapsibleTrigger("Click me"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
            @test occursin("data-suite-collapsible-trigger", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("Click me", html)
        end

        @testset "Trigger accessibility" begin
            html = Therapy.render_to_string(SuiteCollapsibleTrigger("X"))
            @test occursin("focus-visible:ring-2", html)
            @test occursin("disabled:opacity-50", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(SuiteCollapsibleContent(Div("Inner")))
            @test occursin("data-suite-collapsible-content", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("hidden", html)
            @test occursin("overflow-hidden", html)
            @test occursin("Inner", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteCollapsible(class="w-[350px]",
                SuiteCollapsibleTrigger("X"),
                SuiteCollapsibleContent(Div("X")),
            ))
            @test occursin("w-[350px]", html)

            html2 = Therapy.render_to_string(SuiteCollapsibleTrigger(class="font-bold", "X"))
            @test occursin("font-bold", html2)

            html3 = Therapy.render_to_string(SuiteCollapsibleContent(class="p-4", Div("X")))
            @test occursin("p-4", html3)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Collapsible)
            meta = Suite.COMPONENT_REGISTRY[:Collapsible]
            @test meta.tier == :js_runtime
            @test :SuiteCollapsible in meta.exports
            @test :SuiteCollapsibleTrigger in meta.exports
            @test :SuiteCollapsibleContent in meta.exports
            @test :Collapsible in meta.js_modules
        end
    end

    @testset "SuiteAccordion" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(SuiteAccordion(
                SuiteAccordionItem(value="item-1",
                    SuiteAccordionTrigger("Section 1"),
                    SuiteAccordionContent(Div("Content 1")),
                ),
                SuiteAccordionItem(value="item-2",
                    SuiteAccordionTrigger("Section 2"),
                    SuiteAccordionContent(Div("Content 2")),
                ),
            ))
            @test occursin("data-suite-accordion=\"single\"", html)
            @test occursin("data-orientation=\"vertical\"", html)
            @test occursin("Section 1", html)
            @test occursin("Section 2", html)
            @test occursin("Content 1", html)
            @test occursin("Content 2", html)
        end

        @testset "Multiple type" begin
            html = Therapy.render_to_string(SuiteAccordion(type="multiple",
                SuiteAccordionItem(value="a",
                    SuiteAccordionTrigger("A"),
                    SuiteAccordionContent(Div("AA")),
                ),
            ))
            @test occursin("data-suite-accordion=\"multiple\"", html)
        end

        @testset "Collapsible flag" begin
            html = Therapy.render_to_string(SuiteAccordion(collapsible=true,
                SuiteAccordionItem(value="x",
                    SuiteAccordionTrigger("X"),
                    SuiteAccordionContent(Div("XX")),
                ),
            ))
            @test occursin("data-collapsible", html)
        end

        @testset "Default value" begin
            html = Therapy.render_to_string(SuiteAccordion(default_value="item-1",
                SuiteAccordionItem(value="item-1",
                    SuiteAccordionTrigger("Open"),
                    SuiteAccordionContent(Div("Visible")),
                ),
            ))
            @test occursin("data-default-value=\"item-1\"", html)
        end

        @testset "Disabled accordion" begin
            html = Therapy.render_to_string(SuiteAccordion(disabled=true,
                SuiteAccordionItem(value="x",
                    SuiteAccordionTrigger("X"),
                    SuiteAccordionContent(Div("X")),
                ),
            ))
            @test occursin("data-disabled", html)
        end

        @testset "Disabled item" begin
            html = Therapy.render_to_string(SuiteAccordionItem(value="x", disabled=true,
                SuiteAccordionTrigger("Disabled"),
                SuiteAccordionContent(Div("Hidden")),
            ))
            @test occursin("data-disabled", html)
            @test occursin("data-suite-accordion-item=\"x\"", html)
        end

        @testset "AccordionItem structure" begin
            html = Therapy.render_to_string(SuiteAccordionItem(value="test",
                SuiteAccordionTrigger("Title"),
                SuiteAccordionContent(Div("Body")),
            ))
            @test occursin("data-suite-accordion-item=\"test\"", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "AccordionTrigger structure" begin
            html = Therapy.render_to_string(SuiteAccordionTrigger("Click"))
            @test occursin("<h3", html)
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
            @test occursin("data-suite-accordion-trigger", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("Click", html)
            # Chevron icon
            @test occursin("<svg", html)
            @test occursin("rotate-180", html)
        end

        @testset "AccordionContent structure" begin
            html = Therapy.render_to_string(SuiteAccordionContent(Div("Inner")))
            @test occursin("data-suite-accordion-content", html)
            @test occursin("role=\"region\"", html)
            @test occursin("hidden", html)
            @test occursin("overflow-hidden", html)
            @test occursin("Inner", html)
        end

        @testset "Styling" begin
            html = Therapy.render_to_string(SuiteAccordion(
                SuiteAccordionItem(value="x",
                    SuiteAccordionTrigger("X"),
                    SuiteAccordionContent(Div("X")),
                ),
            ))
            @test occursin("divide-y", html)
            @test occursin("divide-warm-200", html)
            @test occursin("dark:divide-warm-700", html)
        end

        @testset "Trigger hover" begin
            html = Therapy.render_to_string(SuiteAccordionTrigger("X"))
            @test occursin("hover:underline", html)
            @test occursin("font-medium", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteAccordion(class="w-full",
                SuiteAccordionItem(value="x",
                    SuiteAccordionTrigger("X"),
                    SuiteAccordionContent(Div("X")),
                ),
            ))
            @test occursin("w-full", html)
        end

        @testset "Horizontal orientation" begin
            html = Therapy.render_to_string(SuiteAccordion(orientation="horizontal",
                SuiteAccordionItem(value="x",
                    SuiteAccordionTrigger("X"),
                    SuiteAccordionContent(Div("X")),
                ),
            ))
            @test occursin("data-orientation=\"horizontal\"", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(SuiteAccordionTrigger("X"))
            @test occursin("dark:text-warm-500", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Accordion)
            meta = Suite.COMPONENT_REGISTRY[:Accordion]
            @test meta.tier == :js_runtime
            @test :SuiteAccordion in meta.exports
            @test :SuiteAccordionItem in meta.exports
            @test :SuiteAccordionTrigger in meta.exports
            @test :SuiteAccordionContent in meta.exports
            @test :Accordion in meta.js_modules
        end
    end

    @testset "SuiteTabs" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(SuiteTabs(default_value="tab1",
                SuiteTabsList(
                    SuiteTabsTrigger("Account", value="tab1"),
                    SuiteTabsTrigger("Password", value="tab2"),
                ),
                SuiteTabsContent(value="tab1", Div("Account settings")),
                SuiteTabsContent(value="tab2", Div("Password settings")),
            ))
            @test occursin("data-suite-tabs", html)
            @test occursin("data-default-value=\"tab1\"", html)
            @test occursin("Account", html)
            @test occursin("Password", html)
            @test occursin("Account settings", html)
            @test occursin("Password settings", html)
        end

        @testset "TabsList structure" begin
            html = Therapy.render_to_string(SuiteTabsList(
                SuiteTabsTrigger("Tab 1", value="t1"),
            ))
            @test occursin("role=\"tablist\"", html)
            @test occursin("data-suite-tabslist", html)
            @test occursin("aria-orientation=\"horizontal\"", html)
        end

        @testset "TabsList styling" begin
            html = Therapy.render_to_string(SuiteTabsList(
                SuiteTabsTrigger("X", value="x"),
            ))
            @test occursin("rounded-lg", html)
            @test occursin("bg-warm-100", html)
            @test occursin("dark:bg-warm-900", html)
            @test occursin("inline-flex", html)
        end

        @testset "TabsTrigger structure" begin
            html = Therapy.render_to_string(SuiteTabsTrigger("My Tab", value="my-tab"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
            @test occursin("role=\"tab\"", html)
            @test occursin("data-suite-tabs-trigger=\"my-tab\"", html)
            @test occursin("aria-selected=\"false\"", html)
            @test occursin("tabindex=\"-1\"", html)
            @test occursin("My Tab", html)
        end

        @testset "TabsTrigger styling" begin
            html = Therapy.render_to_string(SuiteTabsTrigger("X", value="x"))
            @test occursin("rounded-md", html)
            @test occursin("text-sm", html)
            @test occursin("font-medium", html)
            @test occursin("focus-visible:ring-2", html)
            # Active state classes
            @test occursin("data-[state=active]:bg-warm-50", html)
            @test occursin("data-[state=active]:shadow", html)
        end

        @testset "Disabled trigger" begin
            html = Therapy.render_to_string(SuiteTabsTrigger("X", value="x", disabled=true))
            @test occursin("disabled", html)
            @test occursin("data-disabled", html)
        end

        @testset "TabsContent structure" begin
            html = Therapy.render_to_string(SuiteTabsContent(value="panel1", Div("Content")))
            @test occursin("role=\"tabpanel\"", html)
            @test occursin("data-suite-tabs-content=\"panel1\"", html)
            @test occursin("tabindex=\"0\"", html)
            @test occursin("hidden", html)
            @test occursin("Content", html)
        end

        @testset "TabsContent styling" begin
            html = Therapy.render_to_string(SuiteTabsContent(value="x", Div("X")))
            @test occursin("mt-2", html)
            @test occursin("focus-visible:ring-2", html)
            @test occursin("focus-visible:ring-accent-600", html)
        end

        @testset "Orientation" begin
            html = Therapy.render_to_string(SuiteTabs(default_value="x", orientation="vertical",
                SuiteTabsList(SuiteTabsTrigger("X", value="x")),
                SuiteTabsContent(value="x", Div("X")),
            ))
            @test occursin("data-orientation=\"vertical\"", html)
        end

        @testset "Activation mode" begin
            html = Therapy.render_to_string(SuiteTabs(default_value="x", activation="manual",
                SuiteTabsList(SuiteTabsTrigger("X", value="x")),
                SuiteTabsContent(value="x", Div("X")),
            ))
            @test occursin("data-activation=\"manual\"", html)
        end

        @testset "No loop" begin
            html = Therapy.render_to_string(SuiteTabsList(loop=false,
                SuiteTabsTrigger("X", value="x"),
            ))
            @test occursin("data-no-loop", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteTabs(default_value="x", class="w-[400px]",
                SuiteTabsList(class="grid-cols-2",
                    SuiteTabsTrigger("X", value="x", class="data-[state=active]:font-bold"),
                ),
                SuiteTabsContent(value="x", class="p-4", Div("X")),
            ))
            @test occursin("w-[400px]", html)
            @test occursin("grid-cols-2", html)
            @test occursin("data-[state=active]:font-bold", html)
            @test occursin("p-4", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(SuiteTabsList(
                SuiteTabsTrigger("X", value="x"),
            ))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-500", html)

            html2 = Therapy.render_to_string(SuiteTabsTrigger("X", value="x"))
            @test occursin("dark:data-[state=active]:bg-warm-950", html2)
            @test occursin("dark:data-[state=active]:text-warm-300", html2)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Tabs)
            meta = Suite.COMPONENT_REGISTRY[:Tabs]
            @test meta.tier == :js_runtime
            @test :SuiteTabs in meta.exports
            @test :SuiteTabsList in meta.exports
            @test :SuiteTabsTrigger in meta.exports
            @test :SuiteTabsContent in meta.exports
            @test :Tabs in meta.js_modules
        end
    end
end
