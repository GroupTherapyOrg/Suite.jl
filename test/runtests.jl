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

    # ===== Toggle, ToggleGroup, Switch (SUITE-0401) =====

    @testset "SuiteToggle" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(SuiteToggle("Bold"))
            @test occursin("data-suite-toggle", html)
            @test occursin("data-state=\"off\"", html)
            @test occursin("aria-pressed=\"false\"", html)
            @test occursin("<button", html)
            @test occursin("Bold", html)
        end

        @testset "Pressed state" begin
            html = Therapy.render_to_string(SuiteToggle("B", pressed=true))
            @test occursin("data-state=\"on\"", html)
            @test occursin("aria-pressed=\"true\"", html)
        end

        @testset "Variants" begin
            default_html = Therapy.render_to_string(SuiteToggle("X"))
            @test occursin("bg-transparent", default_html)

            outline_html = Therapy.render_to_string(SuiteToggle("X", variant="outline"))
            @test occursin("border", outline_html)
            @test occursin("shadow-sm", outline_html)
        end

        @testset "Sizes" begin
            sm = Therapy.render_to_string(SuiteToggle("X", size="sm"))
            @test occursin("h-8", sm)
            @test occursin("min-w-8", sm)

            lg = Therapy.render_to_string(SuiteToggle("X", size="lg"))
            @test occursin("h-10", lg)
            @test occursin("min-w-10", lg)
        end

        @testset "Disabled" begin
            html = Therapy.render_to_string(SuiteToggle("X", disabled=true))
            @test occursin("disabled", html)
            @test occursin("data-disabled", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteToggle("X", class="my-toggle"))
            @test occursin("my-toggle", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(SuiteToggle("X"))
            @test occursin("dark:hover:bg-warm-900", html)
            @test occursin("dark:data-[state=on]:bg-warm-900", html) || occursin("dark:data-[state=on]", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Toggle)
            meta = Suite.COMPONENT_REGISTRY[:Toggle]
            @test meta.tier == :js_runtime
            @test :SuiteToggle in meta.exports
            @test :Toggle in meta.js_modules
        end
    end

    @testset "SuiteToggleGroup" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(SuiteToggleGroup(
                SuiteToggleGroupItem(value="a", "A"),
                SuiteToggleGroupItem(value="b", "B"),
            ))
            @test occursin("data-suite-toggle-group=\"single\"", html)
            @test occursin("data-orientation=\"horizontal\"", html)
            @test occursin("role=\"group\"", html)
            @test occursin("A", html)
            @test occursin("B", html)
        end

        @testset "Multiple type" begin
            html = Therapy.render_to_string(SuiteToggleGroup(type="multiple",
                SuiteToggleGroupItem(value="x", "X"),
            ))
            @test occursin("data-suite-toggle-group=\"multiple\"", html)
        end

        @testset "Default value - single" begin
            html = Therapy.render_to_string(SuiteToggleGroup(default_value="center",
                SuiteToggleGroupItem(value="left", "L"),
                SuiteToggleGroupItem(value="center", "C"),
                SuiteToggleGroupItem(value="right", "R"),
            ))
            @test occursin("data-default-value=\"center\"", html)
        end

        @testset "Default value - multiple" begin
            html = Therapy.render_to_string(SuiteToggleGroup(type="multiple", default_value=["bold", "italic"],
                SuiteToggleGroupItem(value="bold", "B"),
                SuiteToggleGroupItem(value="italic", "I"),
            ))
            @test occursin("data-default-value=\"bold,italic\"", html)
        end

        @testset "Vertical orientation" begin
            html = Therapy.render_to_string(SuiteToggleGroup(orientation="vertical",
                SuiteToggleGroupItem(value="a", "A"),
            ))
            @test occursin("data-orientation=\"vertical\"", html)
        end

        @testset "Variants and sizes" begin
            html = Therapy.render_to_string(SuiteToggleGroup(variant="outline", size="lg",
                SuiteToggleGroupItem(value="a", "A"),
            ))
            @test occursin("data-variant=\"outline\"", html)
            @test occursin("data-size=\"lg\"", html)
        end

        @testset "Disabled group" begin
            html = Therapy.render_to_string(SuiteToggleGroup(disabled=true,
                SuiteToggleGroupItem(value="x", "X"),
            ))
            @test occursin("data-disabled", html)
        end

        @testset "Item structure" begin
            html = Therapy.render_to_string(SuiteToggleGroupItem(value="bold", "B"))
            @test occursin("data-suite-toggle-group-item=\"bold\"", html)
            @test occursin("data-state=\"off\"", html)
            @test occursin("<button", html)
            @test occursin("B", html)
        end

        @testset "Item variants" begin
            outline = Therapy.render_to_string(SuiteToggleGroupItem(value="x", "X", variant="outline"))
            @test occursin("border", outline)
            @test occursin("shadow-sm", outline)
        end

        @testset "Item sizes" begin
            sm = Therapy.render_to_string(SuiteToggleGroupItem(value="x", "X", size="sm"))
            @test occursin("h-8", sm)

            lg = Therapy.render_to_string(SuiteToggleGroupItem(value="x", "X", size="lg"))
            @test occursin("h-10", lg)
        end

        @testset "Item disabled" begin
            html = Therapy.render_to_string(SuiteToggleGroupItem(value="x", "X", disabled=true))
            @test occursin("disabled", html)
            @test occursin("data-disabled", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteToggleGroup(class="my-group",
                SuiteToggleGroupItem(value="a", "A", class="my-item"),
            ))
            @test occursin("my-group", html)
            @test occursin("my-item", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :ToggleGroup)
            meta = Suite.COMPONENT_REGISTRY[:ToggleGroup]
            @test meta.tier == :js_runtime
            @test :SuiteToggleGroup in meta.exports
            @test :SuiteToggleGroupItem in meta.exports
            @test :ToggleGroup in meta.js_modules
        end
    end

    @testset "SuiteSwitch" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(SuiteSwitch())
            @test occursin("role=\"switch\"", html)
            @test occursin("data-suite-switch", html)
            @test occursin("data-state=\"unchecked\"", html)
            @test occursin("aria-checked=\"false\"", html)
            @test occursin("<button", html)
            # Thumb span
            @test occursin("<span", html)
        end

        @testset "Checked state" begin
            html = Therapy.render_to_string(SuiteSwitch(checked=true))
            @test occursin("data-state=\"checked\"", html)
            @test occursin("aria-checked=\"true\"", html)
        end

        @testset "Sizes" begin
            default_html = Therapy.render_to_string(SuiteSwitch())
            @test occursin("h-5", default_html)
            @test occursin("w-9", default_html)
            @test occursin("size-4", default_html)

            sm_html = Therapy.render_to_string(SuiteSwitch(size="sm"))
            @test occursin("h-3.5", sm_html)
            @test occursin("w-6", sm_html)
            @test occursin("size-3", sm_html)
        end

        @testset "Disabled" begin
            html = Therapy.render_to_string(SuiteSwitch(disabled=true))
            @test occursin("disabled", html)
            @test occursin("data-disabled", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteSwitch(class="my-switch"))
            @test occursin("my-switch", html)
        end

        @testset "Thumb data-state matches" begin
            unchecked = Therapy.render_to_string(SuiteSwitch())
            # Both track and thumb should have unchecked state
            @test count("data-state=\"unchecked\"", unchecked) >= 2

            checked = Therapy.render_to_string(SuiteSwitch(checked=true))
            @test count("data-state=\"checked\"", checked) >= 2
        end

        @testset "CSS transition classes" begin
            html = Therapy.render_to_string(SuiteSwitch())
            @test occursin("transition-transform", html)
            @test occursin("translate-x", html) || occursin("translate-x-0", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(SuiteSwitch())
            @test occursin("dark:bg-warm-950", html)
            @test occursin("dark:data-[state=unchecked]:bg-warm-700", html) || occursin("dark:bg-warm-700", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Switch)
            meta = Suite.COMPONENT_REGISTRY[:Switch]
            @test meta.tier == :js_runtime
            @test :SuiteSwitch in meta.exports
            @test :Switch in meta.js_modules
        end
    end

    @testset "SuiteDialog" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(SuiteDialog(
                SuiteDialogTrigger("Open"),
                SuiteDialogContent(
                    SuiteDialogHeader(
                        SuiteDialogTitle("Title"),
                        SuiteDialogDescription("Description")
                    ),
                    SuiteDialogFooter(
                        SuiteDialogClose("Cancel"),
                        "Save"
                    )
                )
            ))
            @test occursin("data-suite-dialog", html)
            @test occursin("Title", html)
            @test occursin("Description", html)
            @test occursin("Cancel", html)
            @test occursin("Save", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(SuiteDialog(
                SuiteDialogTrigger("Open"),
                SuiteDialogContent(SuiteDialogTitle("T"))
            ))
            @test occursin("data-suite-dialog-trigger", html)
            @test occursin("aria-haspopup=\"dialog\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("Open", html)
        end

        @testset "Trigger is a button" begin
            html = Therapy.render_to_string(SuiteDialogTrigger("Click"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
            @test occursin("Click", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(SuiteDialogContent(
                SuiteDialogTitle("Title")
            ))
            # Overlay
            @test occursin("data-suite-dialog-overlay", html)
            @test occursin("bg-warm-950/80", html)
            # Content panel
            @test occursin("data-suite-dialog-content", html)
            @test occursin("role=\"dialog\"", html)
            @test occursin("aria-modal=\"true\"", html)
            # Default close button
            @test occursin("data-suite-dialog-close", html)
            @test occursin("aria-label=\"Close\"", html)
        end

        @testset "Content CSS classes" begin
            html = Therapy.render_to_string(SuiteDialogContent(
                SuiteDialogTitle("T")
            ))
            @test occursin("fixed", html)
            @test occursin("z-50", html)
            @test occursin("rounded-lg", html)
            @test occursin("shadow-lg", html)
            @test occursin("sm:max-w-lg", html)
            @test occursin("bg-warm-50", html)
            @test occursin("dark:bg-warm-950", html)
        end

        @testset "Animation classes" begin
            html = Therapy.render_to_string(SuiteDialogContent(
                SuiteDialogTitle("T")
            ))
            @test occursin("data-[state=open]:animate-in", html)
            @test occursin("data-[state=closed]:animate-out", html)
            @test occursin("data-[state=open]:fade-in-0", html)
            @test occursin("data-[state=closed]:fade-out-0", html)
        end

        @testset "Header" begin
            html = Therapy.render_to_string(SuiteDialogHeader(
                SuiteDialogTitle("T"),
                SuiteDialogDescription("D")
            ))
            @test occursin("flex flex-col", html)
            @test occursin("text-center sm:text-left", html)
        end

        @testset "Footer" begin
            html = Therapy.render_to_string(SuiteDialogFooter("Save"))
            @test occursin("flex-col-reverse", html)
            @test occursin("sm:flex-row sm:justify-end", html)
        end

        @testset "Title renders as h2" begin
            html = Therapy.render_to_string(SuiteDialogTitle("My Title"))
            @test occursin("<h2", html)
            @test occursin("text-lg", html)
            @test occursin("font-semibold", html)
            @test occursin("My Title", html)
        end

        @testset "Description" begin
            html = Therapy.render_to_string(SuiteDialogDescription("My Desc"))
            @test occursin("<p", html)
            @test occursin("text-sm", html)
            @test occursin("text-warm-600", html)
            @test occursin("My Desc", html)
        end

        @testset "Close wrapper" begin
            html = Therapy.render_to_string(SuiteDialogClose("Cancel"))
            @test occursin("data-suite-dialog-close", html)
            @test occursin("display:contents", html)
            @test occursin("Cancel", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteDialog(class="my-dialog",
                SuiteDialogTrigger("X"),
                SuiteDialogContent(SuiteDialogTitle("T"))
            ))
            @test occursin("my-dialog", html)

            html2 = Therapy.render_to_string(SuiteDialogContent(class="max-w-2xl",
                SuiteDialogTitle("T")
            ))
            @test occursin("max-w-2xl", html2)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Dialog)
            meta = Suite.COMPONENT_REGISTRY[:Dialog]
            @test meta.tier == :js_runtime
            @test :SuiteDialog in meta.exports
            @test :SuiteDialogTrigger in meta.exports
            @test :SuiteDialogContent in meta.exports
            @test :SuiteDialogClose in meta.exports
            @test :Dialog in meta.js_modules
            @test :FocusTrap in meta.js_modules
            @test :DismissLayer in meta.js_modules
            @test :ScrollLock in meta.js_modules
        end
    end

    @testset "SuiteAlertDialog" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(SuiteAlertDialog(
                SuiteAlertDialogTrigger("Delete"),
                SuiteAlertDialogContent(
                    SuiteAlertDialogHeader(
                        SuiteAlertDialogTitle("Are you sure?"),
                        SuiteAlertDialogDescription("This cannot be undone.")
                    ),
                    SuiteAlertDialogFooter(
                        SuiteAlertDialogCancel("Cancel"),
                        SuiteAlertDialogAction("Delete")
                    )
                )
            ))
            @test occursin("data-suite-alert-dialog", html)
            @test occursin("Are you sure?", html)
            @test occursin("This cannot be undone.", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(SuiteAlertDialog(
                SuiteAlertDialogTrigger("Delete"),
                SuiteAlertDialogContent(SuiteAlertDialogTitle("T"))
            ))
            @test occursin("data-suite-alert-dialog-trigger", html)
            @test occursin("aria-haspopup=\"dialog\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger is a button" begin
            html = Therapy.render_to_string(SuiteAlertDialogTrigger("Click"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
        end

        @testset "Content uses alertdialog role" begin
            html = Therapy.render_to_string(SuiteAlertDialogContent(
                SuiteAlertDialogTitle("T")
            ))
            @test occursin("role=\"alertdialog\"", html)
            @test occursin("aria-modal=\"true\"", html)
            # No default close button (unlike Dialog)
            @test !occursin("aria-label=\"Close\"", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(SuiteAlertDialogContent(
                SuiteAlertDialogTitle("T")
            ))
            @test occursin("data-suite-alert-dialog-overlay", html)
            @test occursin("data-suite-alert-dialog-content", html)
            @test occursin("bg-warm-950/80", html)
            @test occursin("fixed", html)
            @test occursin("z-50", html)
        end

        @testset "Header" begin
            html = Therapy.render_to_string(SuiteAlertDialogHeader(
                SuiteAlertDialogTitle("T"),
                SuiteAlertDialogDescription("D")
            ))
            @test occursin("flex flex-col", html)
            @test occursin("text-center sm:text-left", html)
        end

        @testset "Footer" begin
            html = Therapy.render_to_string(SuiteAlertDialogFooter("X"))
            @test occursin("flex-col-reverse", html)
            @test occursin("sm:flex-row sm:justify-end", html)
        end

        @testset "Title renders as h2" begin
            html = Therapy.render_to_string(SuiteAlertDialogTitle("Alert Title"))
            @test occursin("<h2", html)
            @test occursin("text-lg", html)
            @test occursin("font-semibold", html)
            @test occursin("Alert Title", html)
        end

        @testset "Description" begin
            html = Therapy.render_to_string(SuiteAlertDialogDescription("Alert Desc"))
            @test occursin("<p", html)
            @test occursin("text-sm", html)
            @test occursin("text-warm-600", html)
            @test occursin("Alert Desc", html)
        end

        @testset "Action wrapper" begin
            html = Therapy.render_to_string(SuiteAlertDialogAction("Confirm"))
            @test occursin("data-suite-alert-dialog-action", html)
            @test occursin("display:contents", html)
            @test occursin("Confirm", html)
        end

        @testset "Cancel wrapper" begin
            html = Therapy.render_to_string(SuiteAlertDialogCancel("Cancel"))
            @test occursin("data-suite-alert-dialog-cancel", html)
            @test occursin("display:contents", html)
            @test occursin("Cancel", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteAlertDialog(class="danger",
                SuiteAlertDialogTrigger("X"),
                SuiteAlertDialogContent(SuiteAlertDialogTitle("T"))
            ))
            @test occursin("danger", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :AlertDialog)
            meta = Suite.COMPONENT_REGISTRY[:AlertDialog]
            @test meta.tier == :js_runtime
            @test :SuiteAlertDialog in meta.exports
            @test :SuiteAlertDialogTrigger in meta.exports
            @test :SuiteAlertDialogContent in meta.exports
            @test :SuiteAlertDialogAction in meta.exports
            @test :SuiteAlertDialogCancel in meta.exports
            @test :AlertDialog in meta.js_modules
            @test :FocusTrap in meta.js_modules
        end
    end

    @testset "SuiteSheet" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(SuiteSheet(
                SuiteSheetTrigger("Open"),
                SuiteSheetContent(side="right",
                    SuiteSheetHeader(
                        SuiteSheetTitle("Title"),
                        SuiteSheetDescription("Description")
                    ),
                    SuiteSheetFooter(
                        SuiteSheetClose("Cancel"),
                        "Save"
                    )
                )
            ))
            @test occursin("data-suite-sheet", html)
            @test occursin("Title", html)
            @test occursin("Description", html)
            @test occursin("Cancel", html)
            @test occursin("Save", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(SuiteSheet(
                SuiteSheetTrigger("Open"),
                SuiteSheetContent(SuiteSheetTitle("T"))
            ))
            @test occursin("data-suite-sheet-trigger", html)
            @test occursin("aria-haspopup=\"dialog\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger is a button" begin
            html = Therapy.render_to_string(SuiteSheetTrigger("Click"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
        end

        @testset "Content — right side (default)" begin
            html = Therapy.render_to_string(SuiteSheetContent(
                SuiteSheetTitle("T")
            ))
            @test occursin("data-suite-sheet-content", html)
            @test occursin("role=\"dialog\"", html)
            @test occursin("aria-modal=\"true\"", html)
            @test occursin("inset-y-0", html)
            @test occursin("right-0", html)
            @test occursin("slide-in-from-right", html)
            @test occursin("slide-out-to-right", html)
            @test occursin("sm:max-w-sm", html)
            @test occursin("border-l", html)
        end

        @testset "Content — left side" begin
            html = Therapy.render_to_string(SuiteSheetContent(side="left",
                SuiteSheetTitle("T")
            ))
            @test occursin("left-0", html)
            @test occursin("slide-in-from-left", html)
            @test occursin("slide-out-to-left", html)
            @test occursin("border-r", html)
        end

        @testset "Content — top side" begin
            html = Therapy.render_to_string(SuiteSheetContent(side="top",
                SuiteSheetTitle("T")
            ))
            @test occursin("inset-x-0", html)
            @test occursin("top-0", html)
            @test occursin("slide-in-from-top", html)
            @test occursin("slide-out-to-top", html)
            @test occursin("border-b", html)
        end

        @testset "Content — bottom side" begin
            html = Therapy.render_to_string(SuiteSheetContent(side="bottom",
                SuiteSheetTitle("T")
            ))
            @test occursin("inset-x-0", html)
            @test occursin("bottom-0", html)
            @test occursin("slide-in-from-bottom", html)
            @test occursin("slide-out-to-bottom", html)
            @test occursin("border-t", html)
        end

        @testset "Overlay" begin
            html = Therapy.render_to_string(SuiteSheetContent(
                SuiteSheetTitle("T")
            ))
            @test occursin("data-suite-sheet-overlay", html)
            @test occursin("bg-warm-950/80", html)
        end

        @testset "Default close button" begin
            html = Therapy.render_to_string(SuiteSheetContent(
                SuiteSheetTitle("T")
            ))
            @test occursin("data-suite-sheet-close", html)
            @test occursin("aria-label=\"Close\"", html)
        end

        @testset "Animation classes" begin
            html = Therapy.render_to_string(SuiteSheetContent(
                SuiteSheetTitle("T")
            ))
            @test occursin("data-[state=open]:animate-in", html)
            @test occursin("data-[state=closed]:animate-out", html)
            @test occursin("data-[state=closed]:duration-300", html)
            @test occursin("data-[state=open]:duration-500", html)
        end

        @testset "Header" begin
            html = Therapy.render_to_string(SuiteSheetHeader(
                SuiteSheetTitle("T"),
                SuiteSheetDescription("D")
            ))
            @test occursin("flex flex-col", html)
        end

        @testset "Footer" begin
            html = Therapy.render_to_string(SuiteSheetFooter("Save"))
            @test occursin("flex-col-reverse", html)
            @test occursin("sm:flex-row sm:justify-end", html)
        end

        @testset "Title" begin
            html = Therapy.render_to_string(SuiteSheetTitle("My Title"))
            @test occursin("<h2", html)
            @test occursin("font-semibold", html)
            @test occursin("My Title", html)
        end

        @testset "Description" begin
            html = Therapy.render_to_string(SuiteSheetDescription("My Desc"))
            @test occursin("<p", html)
            @test occursin("text-warm-600", html)
            @test occursin("My Desc", html)
        end

        @testset "Close wrapper" begin
            html = Therapy.render_to_string(SuiteSheetClose("Cancel"))
            @test occursin("data-suite-sheet-close", html)
            @test occursin("display:contents", html)
            @test occursin("Cancel", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteSheet(class="w-full",
                SuiteSheetTrigger("X"),
                SuiteSheetContent(SuiteSheetTitle("T"))
            ))
            @test occursin("w-full", html)

            html2 = Therapy.render_to_string(SuiteSheetContent(class="max-w-xl",
                SuiteSheetTitle("T")
            ))
            @test occursin("max-w-xl", html2)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Sheet)
            meta = Suite.COMPONENT_REGISTRY[:Sheet]
            @test meta.tier == :js_runtime
            @test :SuiteSheet in meta.exports
            @test :SuiteSheetTrigger in meta.exports
            @test :SuiteSheetContent in meta.exports
            @test :SuiteSheetClose in meta.exports
            @test :Sheet in meta.js_modules
            @test :FocusTrap in meta.js_modules
            @test :DismissLayer in meta.js_modules
            @test :ScrollLock in meta.js_modules
        end
    end

    @testset "SuiteDrawer" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(SuiteDrawer(
                SuiteDrawerTrigger("Open"),
                SuiteDrawerContent(
                    SuiteDrawerHandle(),
                    SuiteDrawerHeader(
                        SuiteDrawerTitle("Goal"),
                        SuiteDrawerDescription("Set your goal.")
                    ),
                    SuiteDrawerFooter(
                        SuiteDrawerClose("Cancel"),
                        "Submit"
                    )
                )
            ))
            @test occursin("data-suite-drawer", html)
            @test occursin("Goal", html)
            @test occursin("Set your goal.", html)
            @test occursin("Cancel", html)
            @test occursin("Submit", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(SuiteDrawer(
                SuiteDrawerTrigger("Open"),
                SuiteDrawerContent(SuiteDrawerTitle("T"))
            ))
            @test occursin("data-suite-drawer-trigger", html)
            @test occursin("aria-haspopup=\"dialog\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger is a button" begin
            html = Therapy.render_to_string(SuiteDrawerTrigger("Click"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
        end

        @testset "Content — bottom (default)" begin
            html = Therapy.render_to_string(SuiteDrawerContent(
                SuiteDrawerTitle("T")
            ))
            @test occursin("data-suite-drawer-content", html)
            @test occursin("data-suite-drawer-direction=\"bottom\"", html)
            @test occursin("role=\"dialog\"", html)
            @test occursin("aria-modal=\"true\"", html)
            @test occursin("inset-x-0", html)
            @test occursin("bottom-0", html)
            @test occursin("rounded-t-[10px]", html)
            @test occursin("touch-action:none", html)
        end

        @testset "Content — top" begin
            html = Therapy.render_to_string(SuiteDrawerContent(direction="top",
                SuiteDrawerTitle("T")
            ))
            @test occursin("data-suite-drawer-direction=\"top\"", html)
            @test occursin("top-0", html)
            @test occursin("rounded-b-[10px]", html)
        end

        @testset "Content — left" begin
            html = Therapy.render_to_string(SuiteDrawerContent(direction="left",
                SuiteDrawerTitle("T")
            ))
            @test occursin("data-suite-drawer-direction=\"left\"", html)
            @test occursin("left-0", html)
            @test occursin("rounded-r-[10px]", html)
        end

        @testset "Content — right" begin
            html = Therapy.render_to_string(SuiteDrawerContent(direction="right",
                SuiteDrawerTitle("T")
            ))
            @test occursin("data-suite-drawer-direction=\"right\"", html)
            @test occursin("right-0", html)
            @test occursin("rounded-l-[10px]", html)
        end

        @testset "Handle" begin
            html = Therapy.render_to_string(SuiteDrawerHandle())
            @test occursin("h-2", html)
            @test occursin("w-[100px]", html)
            @test occursin("rounded-full", html)
            @test occursin("bg-warm-200", html)
        end

        @testset "Overlay" begin
            html = Therapy.render_to_string(SuiteDrawerContent(
                SuiteDrawerTitle("T")
            ))
            @test occursin("data-suite-drawer-overlay", html)
            @test occursin("bg-warm-950/80", html)
        end

        @testset "Header" begin
            html = Therapy.render_to_string(SuiteDrawerHeader(
                SuiteDrawerTitle("T")
            ))
            @test occursin("flex flex-col", html)
            @test occursin("p-4", html)
        end

        @testset "Footer" begin
            html = Therapy.render_to_string(SuiteDrawerFooter("X"))
            @test occursin("flex flex-col", html)
            @test occursin("p-4", html)
        end

        @testset "Title" begin
            html = Therapy.render_to_string(SuiteDrawerTitle("My Title"))
            @test occursin("<h2", html)
            @test occursin("font-semibold", html)
            @test occursin("My Title", html)
        end

        @testset "Description" begin
            html = Therapy.render_to_string(SuiteDrawerDescription("My Desc"))
            @test occursin("<p", html)
            @test occursin("text-warm-600", html)
            @test occursin("My Desc", html)
        end

        @testset "Close wrapper" begin
            html = Therapy.render_to_string(SuiteDrawerClose("Cancel"))
            @test occursin("data-suite-drawer-close", html)
            @test occursin("display:contents", html)
            @test occursin("Cancel", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteDrawer(class="my-drawer",
                SuiteDrawerTrigger("X"),
                SuiteDrawerContent(SuiteDrawerTitle("T"))
            ))
            @test occursin("my-drawer", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Drawer)
            meta = Suite.COMPONENT_REGISTRY[:Drawer]
            @test meta.tier == :js_runtime
            @test :SuiteDrawer in meta.exports
            @test :SuiteDrawerTrigger in meta.exports
            @test :SuiteDrawerContent in meta.exports
            @test :SuiteDrawerClose in meta.exports
            @test :SuiteDrawerHandle in meta.exports
            @test :Drawer in meta.js_modules
            @test :FocusTrap in meta.js_modules
        end
    end

    @testset "SuitePopover" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(SuitePopover(
                SuitePopoverTrigger("Open"),
                SuitePopoverContent(
                    P("Popover content here")
                )
            ))
            @test occursin("data-suite-popover", html)
            @test occursin("Popover content here", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(SuitePopover(
                SuitePopoverTrigger("Open"),
                SuitePopoverContent(P("Content"))
            ))
            @test occursin("data-suite-popover-trigger", html)
            @test occursin("aria-haspopup=\"dialog\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger is a button" begin
            html = Therapy.render_to_string(SuitePopoverTrigger("Click"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(SuitePopoverContent(P("Hello")))
            @test occursin("data-suite-popover-content", html)
            @test occursin("role=\"dialog\"", html)
            @test occursin("aria-modal=\"true\"", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("display:none", html)
        end

        @testset "Content positioning attributes" begin
            html = Therapy.render_to_string(SuitePopoverContent(
                side="top", side_offset=8, align="start",
                P("Content")
            ))
            @test occursin("data-suite-popover-side=\"top\"", html)
            @test occursin("data-suite-popover-side-offset=\"8\"", html)
            @test occursin("data-suite-popover-align=\"start\"", html)
        end

        @testset "Content default positioning" begin
            html = Therapy.render_to_string(SuitePopoverContent(P("Content")))
            @test occursin("data-suite-popover-side=\"bottom\"", html)
            @test occursin("data-suite-popover-side-offset=\"0\"", html)
            @test occursin("data-suite-popover-align=\"center\"", html)
        end

        @testset "Content CSS classes" begin
            html = Therapy.render_to_string(SuitePopoverContent(P("Content")))
            @test occursin("bg-warm-50", html)
            @test occursin("dark:bg-warm-900", html)
            @test occursin("w-72", html)
            @test occursin("rounded-md", html)
            @test occursin("border", html)
            @test occursin("p-4", html)
            @test occursin("shadow-md", html)
        end

        @testset "Content animation classes" begin
            html = Therapy.render_to_string(SuitePopoverContent(P("Content")))
            @test occursin("data-[state=open]:animate-in", html)
            @test occursin("data-[state=closed]:animate-out", html)
            @test occursin("data-[state=closed]:fade-out-0", html)
            @test occursin("data-[state=open]:fade-in-0", html)
            @test occursin("data-[state=closed]:zoom-out-95", html)
            @test occursin("data-[state=open]:zoom-in-95", html)
            @test occursin("data-[side=bottom]:slide-in-from-top-2", html)
            @test occursin("data-[side=top]:slide-in-from-bottom-2", html)
        end

        @testset "Close wrapper" begin
            html = Therapy.render_to_string(SuitePopoverClose("Close"))
            @test occursin("data-suite-popover-close", html)
            @test occursin("display:contents", html)
            @test occursin("Close", html)
        end

        @testset "Anchor" begin
            html = Therapy.render_to_string(SuitePopoverAnchor(Span("Anchor")))
            @test occursin("data-suite-popover-anchor", html)
            @test occursin("Anchor", html)
        end

        @testset "Root uses display:contents" begin
            html = Therapy.render_to_string(SuitePopover(
                SuitePopoverTrigger("X"),
                SuitePopoverContent(P("Y"))
            ))
            @test occursin("display:contents", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuitePopoverContent(class="max-w-lg",
                P("Content")
            ))
            @test occursin("max-w-lg", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Popover)
            meta = Suite.COMPONENT_REGISTRY[:Popover]
            @test meta.tier == :js_runtime
            @test :SuitePopover in meta.exports
            @test :SuitePopoverTrigger in meta.exports
            @test :SuitePopoverContent in meta.exports
            @test :SuitePopoverClose in meta.exports
            @test :Popover in meta.js_modules
            @test :Floating in meta.js_modules
            @test :FocusTrap in meta.js_modules
            @test :DismissLayer in meta.js_modules
        end
    end

    @testset "SuiteTooltip" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(SuiteTooltipProvider(
                SuiteTooltip(
                    SuiteTooltipTrigger("Hover me"),
                    SuiteTooltipContent(P("Tooltip text"))
                )
            ))
            @test occursin("data-suite-tooltip-provider", html)
            @test occursin("data-suite-tooltip", html)
            @test occursin("Tooltip text", html)
        end

        @testset "Provider attributes" begin
            html = Therapy.render_to_string(SuiteTooltipProvider(
                delay_duration=500, skip_delay_duration=200,
                Span("Children")
            ))
            @test occursin("data-suite-tooltip-delay=\"500\"", html)
            @test occursin("data-suite-tooltip-skip-delay=\"200\"", html)
        end

        @testset "Provider default attributes" begin
            html = Therapy.render_to_string(SuiteTooltipProvider(Span("X")))
            @test occursin("data-suite-tooltip-delay=\"700\"", html)
            @test occursin("data-suite-tooltip-skip-delay=\"300\"", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(SuiteTooltip(
                SuiteTooltipTrigger("Hover"),
                SuiteTooltipContent(P("Tip"))
            ))
            @test occursin("data-suite-tooltip-trigger", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger is a button" begin
            html = Therapy.render_to_string(SuiteTooltipTrigger("Click"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(SuiteTooltipContent(P("Tip")))
            @test occursin("data-suite-tooltip-content", html)
            @test occursin("role=\"tooltip\"", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("display:none", html)
        end

        @testset "Content positioning attributes" begin
            html = Therapy.render_to_string(SuiteTooltipContent(
                side="bottom", side_offset=8, align="end",
                P("Tip")
            ))
            @test occursin("data-suite-tooltip-side=\"bottom\"", html)
            @test occursin("data-suite-tooltip-side-offset=\"8\"", html)
            @test occursin("data-suite-tooltip-align=\"end\"", html)
        end

        @testset "Content default positioning" begin
            html = Therapy.render_to_string(SuiteTooltipContent(P("Tip")))
            @test occursin("data-suite-tooltip-side=\"top\"", html)
            @test occursin("data-suite-tooltip-side-offset=\"4\"", html)
            @test occursin("data-suite-tooltip-align=\"center\"", html)
        end

        @testset "Content CSS — inverted colors" begin
            html = Therapy.render_to_string(SuiteTooltipContent(P("Tip")))
            @test occursin("bg-warm-800", html)
            @test occursin("dark:bg-warm-300", html)
            @test occursin("text-warm-50", html)
            @test occursin("dark:text-warm-950", html)
        end

        @testset "Content CSS — layout" begin
            html = Therapy.render_to_string(SuiteTooltipContent(P("Tip")))
            @test occursin("px-3", html)
            @test occursin("py-1.5", html)
            @test occursin("rounded-md", html)
            @test occursin("text-xs", html)
            @test occursin("text-balance", html)
        end

        @testset "Content animation classes" begin
            html = Therapy.render_to_string(SuiteTooltipContent(P("Tip")))
            @test occursin("animate-in", html)
            @test occursin("fade-in-0", html)
            @test occursin("zoom-in-95", html)
            @test occursin("data-[state=closed]:animate-out", html)
            @test occursin("data-[state=closed]:fade-out-0", html)
            @test occursin("data-[side=bottom]:slide-in-from-top-2", html)
            @test occursin("data-[side=top]:slide-in-from-bottom-2", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteTooltipContent(class="max-w-xs",
                P("Tip")
            ))
            @test occursin("max-w-xs", html)
        end

        @testset "Provider uses display:contents" begin
            html = Therapy.render_to_string(SuiteTooltipProvider(Span("X")))
            @test occursin("display:contents", html)
        end

        @testset "Root uses display:contents" begin
            html = Therapy.render_to_string(SuiteTooltip(
                SuiteTooltipTrigger("X"),
                SuiteTooltipContent(P("Y"))
            ))
            @test occursin("display:contents", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Tooltip)
            meta = Suite.COMPONENT_REGISTRY[:Tooltip]
            @test meta.tier == :js_runtime
            @test :SuiteTooltipProvider in meta.exports
            @test :SuiteTooltip in meta.exports
            @test :SuiteTooltipTrigger in meta.exports
            @test :SuiteTooltipContent in meta.exports
            @test :Tooltip in meta.js_modules
            @test :Floating in meta.js_modules
            @test :DismissLayer in meta.js_modules
        end
    end

    @testset "SuiteHoverCard" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(SuiteHoverCard(
                SuiteHoverCardTrigger(A(:href => "#", "@user")),
                SuiteHoverCardContent(
                    P("User bio here")
                )
            ))
            @test occursin("data-suite-hover-card", html)
            @test occursin("User bio here", html)
            @test occursin("@user", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(SuiteHoverCard(
                SuiteHoverCardTrigger(Span("Hover")),
                SuiteHoverCardContent(P("Card"))
            ))
            @test occursin("data-suite-hover-card-trigger", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger uses span wrapper" begin
            html = Therapy.render_to_string(SuiteHoverCardTrigger(Span("Link")))
            @test occursin("<span", html)
            @test occursin("Link", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(SuiteHoverCardContent(P("Card")))
            @test occursin("data-suite-hover-card-content", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("display:none", html)
        end

        @testset "Content positioning attributes" begin
            html = Therapy.render_to_string(SuiteHoverCardContent(
                side="top", side_offset=8, align="start",
                P("Card")
            ))
            @test occursin("data-suite-hover-card-side=\"top\"", html)
            @test occursin("data-suite-hover-card-side-offset=\"8\"", html)
            @test occursin("data-suite-hover-card-align=\"start\"", html)
        end

        @testset "Content default positioning" begin
            html = Therapy.render_to_string(SuiteHoverCardContent(P("Card")))
            @test occursin("data-suite-hover-card-side=\"bottom\"", html)
            @test occursin("data-suite-hover-card-side-offset=\"4\"", html)
            @test occursin("data-suite-hover-card-align=\"center\"", html)
        end

        @testset "Content CSS classes" begin
            html = Therapy.render_to_string(SuiteHoverCardContent(P("Card")))
            @test occursin("bg-warm-50", html)
            @test occursin("dark:bg-warm-900", html)
            @test occursin("w-64", html)
            @test occursin("rounded-md", html)
            @test occursin("border", html)
            @test occursin("p-4", html)
            @test occursin("shadow-md", html)
        end

        @testset "Content animation classes" begin
            html = Therapy.render_to_string(SuiteHoverCardContent(P("Card")))
            @test occursin("data-[state=open]:animate-in", html)
            @test occursin("data-[state=closed]:animate-out", html)
            @test occursin("data-[state=closed]:fade-out-0", html)
            @test occursin("data-[state=open]:fade-in-0", html)
            @test occursin("data-[state=closed]:zoom-out-95", html)
            @test occursin("data-[state=open]:zoom-in-95", html)
            @test occursin("data-[side=bottom]:slide-in-from-top-2", html)
            @test occursin("data-[side=top]:slide-in-from-bottom-2", html)
        end

        @testset "Delay attributes" begin
            html = Therapy.render_to_string(SuiteHoverCard(
                open_delay=500, close_delay=200,
                SuiteHoverCardTrigger(Span("X")),
                SuiteHoverCardContent(P("Y"))
            ))
            @test occursin("data-suite-hover-card-open-delay=\"500\"", html)
            @test occursin("data-suite-hover-card-close-delay=\"200\"", html)
        end

        @testset "Default delay attributes" begin
            html = Therapy.render_to_string(SuiteHoverCard(
                SuiteHoverCardTrigger(Span("X")),
                SuiteHoverCardContent(P("Y"))
            ))
            @test occursin("data-suite-hover-card-open-delay=\"700\"", html)
            @test occursin("data-suite-hover-card-close-delay=\"300\"", html)
        end

        @testset "Root uses display:contents" begin
            html = Therapy.render_to_string(SuiteHoverCard(
                SuiteHoverCardTrigger(Span("X")),
                SuiteHoverCardContent(P("Y"))
            ))
            @test occursin("display:contents", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteHoverCardContent(class="max-w-md",
                P("Card")
            ))
            @test occursin("max-w-md", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :HoverCard)
            meta = Suite.COMPONENT_REGISTRY[:HoverCard]
            @test meta.tier == :js_runtime
            @test :SuiteHoverCard in meta.exports
            @test :SuiteHoverCardTrigger in meta.exports
            @test :SuiteHoverCardContent in meta.exports
            @test :HoverCard in meta.js_modules
            @test :Floating in meta.js_modules
            @test :DismissLayer in meta.js_modules
        end
    end

    # ==================== DropdownMenu ==========================================
    @testset "SuiteDropdownMenu" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(SuiteDropdownMenu(
                SuiteDropdownMenuTrigger(Span("Open")),
                SuiteDropdownMenuContent(
                    SuiteDropdownMenuItem("Profile"),
                    SuiteDropdownMenuItem("Settings"),
                )
            ))
            @test occursin("data-suite-dropdown-menu=", html)
            @test occursin("data-suite-dropdown-menu-trigger=", html)
            @test occursin("data-suite-dropdown-menu-content", html)
            @test occursin("role=\"menu\"", html)
            @test occursin("aria-haspopup=\"menu\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("Profile", html)
            @test occursin("Settings", html)
        end

        @testset "MenuItem" begin
            html = Therapy.render_to_string(SuiteDropdownMenuItem("Profile"))
            @test occursin("data-suite-menu-item", html)
            @test occursin("role=\"menuitem\"", html)
            @test occursin("tabindex=\"-1\"", html)
            @test occursin("Profile", html)
            @test occursin("cursor-default", html)
            @test occursin("data-[highlighted]", html)
        end

        @testset "MenuItem with shortcut" begin
            html = Therapy.render_to_string(SuiteDropdownMenuItem("Profile", shortcut="⇧⌘P"))
            @test occursin("Profile", html)
            @test occursin("⇧⌘P", html)
            @test occursin("data-suite-menu-shortcut", html)
            @test occursin("tracking-widest", html)
        end

        @testset "MenuItem disabled" begin
            html = Therapy.render_to_string(SuiteDropdownMenuItem("Disabled", disabled=true))
            @test occursin("data-disabled", html)
            @test occursin("data-[disabled]", html)
        end

        @testset "MenuItem with text_value" begin
            html = Therapy.render_to_string(SuiteDropdownMenuItem("🎵 Music", text_value="Music"))
            @test occursin("data-text-value=\"Music\"", html)
        end

        @testset "CheckboxItem unchecked" begin
            html = Therapy.render_to_string(SuiteDropdownMenuCheckboxItem("Show toolbar"))
            @test occursin("data-suite-menu-checkbox-item", html)
            @test occursin("role=\"menuitemcheckbox\"", html)
            @test occursin("aria-checked=\"false\"", html)
            @test occursin("data-state=\"unchecked\"", html)
            @test occursin("display:none", html)  # indicator hidden
            @test occursin("pl-8", html)  # left padding for indicator
        end

        @testset "CheckboxItem checked" begin
            html = Therapy.render_to_string(SuiteDropdownMenuCheckboxItem("Show toolbar", checked=true))
            @test occursin("aria-checked=\"true\"", html)
            @test occursin("data-state=\"checked\"", html)
            @test occursin("data-suite-menu-item-indicator", html)
            # Check SVG should be visible
            @test occursin("M20 6L9 17l-5-5", html)
        end

        @testset "RadioGroup and RadioItem" begin
            html = Therapy.render_to_string(SuiteDropdownMenuRadioGroup(value="center",
                SuiteDropdownMenuRadioItem(value="top", "Top"),
                SuiteDropdownMenuRadioItem(value="center", checked=true, "Center"),
                SuiteDropdownMenuRadioItem(value="bottom", "Bottom"),
            ))
            @test occursin("data-suite-menu-radio-group", html)
            @test occursin("role=\"group\"", html)
            @test occursin("role=\"menuitemradio\"", html)
            # Checked item
            @test occursin("data-state=\"checked\"", html)
            @test occursin("aria-checked=\"true\"", html)
            # Unchecked items
            @test occursin("data-state=\"unchecked\"", html)
        end

        @testset "Label" begin
            html = Therapy.render_to_string(SuiteDropdownMenuLabel("My Account"))
            @test occursin("My Account", html)
            @test occursin("font-medium", html)
            @test occursin("text-sm", html)
        end

        @testset "Label with inset" begin
            html = Therapy.render_to_string(SuiteDropdownMenuLabel("My Account", inset=true))
            @test occursin("pl-8", html)
        end

        @testset "Separator" begin
            html = Therapy.render_to_string(SuiteDropdownMenuSeparator())
            @test occursin("role=\"separator\"", html)
            @test occursin("data-suite-menu-separator", html)
            @test occursin("h-px", html)
            @test occursin("bg-warm-200", html)
        end

        @testset "Shortcut standalone" begin
            html = Therapy.render_to_string(SuiteDropdownMenuShortcut("⌘S"))
            @test occursin("⌘S", html)
            @test occursin("tracking-widest", html)
            @test occursin("data-suite-menu-shortcut", html)
        end

        @testset "Group" begin
            html = Therapy.render_to_string(SuiteDropdownMenuGroup(
                SuiteDropdownMenuItem("A"),
                SuiteDropdownMenuItem("B"),
            ))
            @test occursin("role=\"group\"", html)
        end

        @testset "SubMenu structure" begin
            html = Therapy.render_to_string(SuiteDropdownMenuSub(
                SuiteDropdownMenuSubTrigger("More Tools"),
                SuiteDropdownMenuSubContent(
                    SuiteDropdownMenuItem("Sub Item 1"),
                    SuiteDropdownMenuItem("Sub Item 2"),
                )
            ))
            @test occursin("data-suite-menu-sub", html)
            @test occursin("data-suite-menu-sub-trigger", html)
            @test occursin("aria-haspopup=\"menu\"", html)
            @test occursin("data-suite-menu-sub-content", html)
            @test occursin("Sub Item 1", html)
            # Chevron icon in sub-trigger
            @test occursin("M6 12L10 8L6 4", html)
        end

        @testset "SubTrigger inset" begin
            html = Therapy.render_to_string(SuiteDropdownMenuSubTrigger("More", inset=true))
            @test occursin("pl-8", html)
        end

        @testset "SubTrigger disabled" begin
            html = Therapy.render_to_string(SuiteDropdownMenuSubTrigger("More", disabled=true))
            @test occursin("data-disabled", html)
        end

        @testset "Content styling" begin
            html = Therapy.render_to_string(SuiteDropdownMenuContent(
                SuiteDropdownMenuItem("A")
            ))
            @test occursin("rounded-md", html)
            @test occursin("shadow-md", html)
            @test occursin("bg-warm-50", html)
            @test occursin("dark:bg-warm-900", html)
            @test occursin("border-warm-200", html)
            @test occursin("animate-in", html)
            @test occursin("animate-out", html)
            @test occursin("slide-in-from-top-2", html)
        end

        @testset "Content custom class" begin
            html = Therapy.render_to_string(SuiteDropdownMenuContent(class="w-56",
                SuiteDropdownMenuItem("A")
            ))
            @test occursin("w-56", html)
        end

        @testset "Content custom side/align" begin
            html = Therapy.render_to_string(SuiteDropdownMenuContent(side="top", align="end", side_offset=8,
                SuiteDropdownMenuItem("A")
            ))
            @test occursin("data-side-preference=\"top\"", html)
            @test occursin("data-align-preference=\"end\"", html)
            @test occursin("data-side-offset=\"8\"", html)
        end

        @testset "SubContent styling" begin
            html = Therapy.render_to_string(SuiteDropdownMenuSubContent(
                SuiteDropdownMenuItem("A")
            ))
            @test occursin("shadow-lg", html)  # SubContent uses shadow-lg
            @test occursin("data-suite-menu-sub-content", html)
            @test occursin("role=\"menu\"", html)
        end

        @testset "ItemIndicator" begin
            html = Therapy.render_to_string(SuiteDropdownMenuItemIndicator(Span("✓")))
            @test occursin("data-suite-menu-item-indicator", html)
            @test occursin("✓", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(SuiteDropdownMenuContent(
                SuiteDropdownMenuItem("A"),
                SuiteDropdownMenuSeparator(),
            ))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-300", html)
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:bg-warm-700", html)  # separator dark
        end

        @testset "Full composition" begin
            html = Therapy.render_to_string(SuiteDropdownMenu(
                SuiteDropdownMenuTrigger(Span("Menu")),
                SuiteDropdownMenuContent(
                    SuiteDropdownMenuLabel("Account"),
                    SuiteDropdownMenuSeparator(),
                    SuiteDropdownMenuGroup(
                        SuiteDropdownMenuItem("Profile", shortcut="⇧⌘P"),
                        SuiteDropdownMenuItem("Settings", shortcut="⌘S"),
                    ),
                    SuiteDropdownMenuSeparator(),
                    SuiteDropdownMenuCheckboxItem("Status Bar", checked=true),
                    SuiteDropdownMenuSeparator(),
                    SuiteDropdownMenuRadioGroup(value="center",
                        SuiteDropdownMenuRadioItem(value="top", "Top"),
                        SuiteDropdownMenuRadioItem(value="center", checked=true, "Center"),
                    ),
                    SuiteDropdownMenuSeparator(),
                    SuiteDropdownMenuSub(
                        SuiteDropdownMenuSubTrigger("More"),
                        SuiteDropdownMenuSubContent(
                            SuiteDropdownMenuItem("Sub A"),
                        )
                    ),
                    SuiteDropdownMenuSeparator(),
                    SuiteDropdownMenuItem("Log out", shortcut="⇧⌘Q"),
                )
            ))
            @test occursin("data-suite-dropdown-menu=", html)
            @test occursin("Account", html)
            @test occursin("Profile", html)
            @test occursin("Status Bar", html)
            @test occursin("Sub A", html)
            @test occursin("Log out", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :DropdownMenu)
            meta = Suite.COMPONENT_REGISTRY[:DropdownMenu]
            @test meta.tier == :js_runtime
            @test :SuiteDropdownMenu in meta.exports
            @test :SuiteDropdownMenuTrigger in meta.exports
            @test :SuiteDropdownMenuContent in meta.exports
            @test :SuiteDropdownMenuItem in meta.exports
            @test :SuiteDropdownMenuCheckboxItem in meta.exports
            @test :SuiteDropdownMenuRadioGroup in meta.exports
            @test :SuiteDropdownMenuRadioItem in meta.exports
            @test :SuiteDropdownMenuSeparator in meta.exports
            @test :SuiteDropdownMenuLabel in meta.exports
            @test :SuiteDropdownMenuShortcut in meta.exports
            @test :SuiteDropdownMenuSub in meta.exports
            @test :SuiteDropdownMenuSubTrigger in meta.exports
            @test :SuiteDropdownMenuSubContent in meta.exports
            @test :SuiteDropdownMenuItemIndicator in meta.exports
            @test :SuiteDropdownMenuGroup in meta.exports
            @test :Menu in meta.js_modules
            @test :DropdownMenu in meta.js_modules
            @test :Floating in meta.js_modules
            @test :DismissLayer in meta.js_modules
        end
    end

    # ==================== ContextMenu ===========================================
    @testset "SuiteContextMenu" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(SuiteContextMenu(
                SuiteContextMenuTrigger(Div("Right click here")),
                SuiteContextMenuContent(
                    SuiteContextMenuItem("Cut"),
                    SuiteContextMenuItem("Copy"),
                    SuiteContextMenuItem("Paste"),
                )
            ))
            @test occursin("data-suite-context-menu=", html)
            @test occursin("data-suite-context-menu-trigger=", html)
            @test occursin("data-suite-context-menu-content", html)
            @test occursin("role=\"menu\"", html)
            @test occursin("Cut", html)
            @test occursin("Copy", html)
            @test occursin("Paste", html)
        end

        @testset "Trigger renders as span" begin
            html = Therapy.render_to_string(SuiteContextMenuTrigger(Div("Area")))
            @test occursin("<span", html)
            @test occursin("Area", html)
        end

        @testset "MenuItem" begin
            html = Therapy.render_to_string(SuiteContextMenuItem("Cut"))
            @test occursin("data-suite-menu-item", html)
            @test occursin("role=\"menuitem\"", html)
            @test occursin("Cut", html)
        end

        @testset "MenuItem with shortcut" begin
            html = Therapy.render_to_string(SuiteContextMenuItem("Cut", shortcut="⌘X"))
            @test occursin("⌘X", html)
            @test occursin("data-suite-menu-shortcut", html)
        end

        @testset "MenuItem disabled" begin
            html = Therapy.render_to_string(SuiteContextMenuItem("Disabled", disabled=true))
            @test occursin("data-disabled", html)
        end

        @testset "CheckboxItem" begin
            html = Therapy.render_to_string(SuiteContextMenuCheckboxItem("Show Grid", checked=true))
            @test occursin("data-suite-menu-checkbox-item", html)
            @test occursin("role=\"menuitemcheckbox\"", html)
            @test occursin("aria-checked=\"true\"", html)
            @test occursin("data-state=\"checked\"", html)
        end

        @testset "RadioGroup and RadioItem" begin
            html = Therapy.render_to_string(SuiteContextMenuRadioGroup(value="light",
                SuiteContextMenuRadioItem(value="light", checked=true, "Light"),
                SuiteContextMenuRadioItem(value="dark", "Dark"),
            ))
            @test occursin("data-suite-menu-radio-group", html)
            @test occursin("role=\"menuitemradio\"", html)
            @test occursin("aria-checked=\"true\"", html)
        end

        @testset "Label" begin
            html = Therapy.render_to_string(SuiteContextMenuLabel("Actions"))
            @test occursin("Actions", html)
            @test occursin("font-medium", html)
        end

        @testset "Label with stronger text" begin
            html = Therapy.render_to_string(SuiteContextMenuLabel("Actions"))
            @test occursin("text-warm-800", html)
        end

        @testset "Separator" begin
            html = Therapy.render_to_string(SuiteContextMenuSeparator())
            @test occursin("role=\"separator\"", html)
            @test occursin("h-px", html)
        end

        @testset "SubMenu structure" begin
            html = Therapy.render_to_string(SuiteContextMenuSub(
                SuiteContextMenuSubTrigger("Share"),
                SuiteContextMenuSubContent(
                    SuiteContextMenuItem("Email"),
                    SuiteContextMenuItem("Link"),
                )
            ))
            @test occursin("data-suite-menu-sub", html)
            @test occursin("data-suite-menu-sub-trigger", html)
            @test occursin("data-suite-menu-sub-content", html)
            @test occursin("Email", html)
            @test occursin("Link", html)
        end

        @testset "Content styling" begin
            html = Therapy.render_to_string(SuiteContextMenuContent(
                SuiteContextMenuItem("A")
            ))
            @test occursin("rounded-md", html)
            @test occursin("shadow-md", html)
            @test occursin("bg-warm-50", html)
            @test occursin("dark:bg-warm-900", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteContextMenuContent(class="w-64",
                SuiteContextMenuItem("A")
            ))
            @test occursin("w-64", html)
        end

        @testset "Full composition" begin
            html = Therapy.render_to_string(SuiteContextMenu(
                SuiteContextMenuTrigger(
                    Div(:class => "h-[150px] w-[300px]", "Right click here")
                ),
                SuiteContextMenuContent(
                    SuiteContextMenuLabel("Edit"),
                    SuiteContextMenuSeparator(),
                    SuiteContextMenuItem("Cut", shortcut="⌘X"),
                    SuiteContextMenuItem("Copy", shortcut="⌘C"),
                    SuiteContextMenuItem("Paste", shortcut="⌘V"),
                    SuiteContextMenuSeparator(),
                    SuiteContextMenuCheckboxItem("Show Grid", checked=true),
                    SuiteContextMenuSeparator(),
                    SuiteContextMenuSub(
                        SuiteContextMenuSubTrigger("Share"),
                        SuiteContextMenuSubContent(
                            SuiteContextMenuItem("Email"),
                        )
                    ),
                )
            ))
            @test occursin("data-suite-context-menu=", html)
            @test occursin("Edit", html)
            @test occursin("Cut", html)
            @test occursin("Show Grid", html)
            @test occursin("Email", html)
        end

        @testset "Shortcut standalone" begin
            html = Therapy.render_to_string(SuiteContextMenuShortcut("⌘Z"))
            @test occursin("⌘Z", html)
            @test occursin("data-suite-menu-shortcut", html)
        end

        @testset "ItemIndicator" begin
            html = Therapy.render_to_string(SuiteContextMenuItemIndicator(Span("•")))
            @test occursin("data-suite-menu-item-indicator", html)
        end

        @testset "Group" begin
            html = Therapy.render_to_string(SuiteContextMenuGroup(
                SuiteContextMenuItem("A"),
            ))
            @test occursin("role=\"group\"", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(SuiteContextMenuContent(
                SuiteContextMenuItem("A"),
            ))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-300", html)
            @test occursin("dark:border-warm-700", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :ContextMenu)
            meta = Suite.COMPONENT_REGISTRY[:ContextMenu]
            @test meta.tier == :js_runtime
            @test :SuiteContextMenu in meta.exports
            @test :SuiteContextMenuTrigger in meta.exports
            @test :SuiteContextMenuContent in meta.exports
            @test :SuiteContextMenuItem in meta.exports
            @test :SuiteContextMenuCheckboxItem in meta.exports
            @test :SuiteContextMenuRadioGroup in meta.exports
            @test :SuiteContextMenuRadioItem in meta.exports
            @test :SuiteContextMenuSeparator in meta.exports
            @test :SuiteContextMenuLabel in meta.exports
            @test :SuiteContextMenuSub in meta.exports
            @test :SuiteContextMenuSubTrigger in meta.exports
            @test :SuiteContextMenuSubContent in meta.exports
            @test :Menu in meta.js_modules
            @test :ContextMenu in meta.js_modules
            @test :Floating in meta.js_modules
            @test :DismissLayer in meta.js_modules
        end
    end

    # ==================== Select ===============================================
    @testset "SuiteSelect" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(SuiteSelect(
                SuiteSelectTrigger(SuiteSelectValue(placeholder="Pick a fruit...")),
                SuiteSelectContent(
                    SuiteSelectItem("Apple", value="apple"),
                    SuiteSelectItem("Banana", value="banana"),
                )
            ))
            @test occursin("data-suite-select=", html)
            @test occursin("data-suite-select-trigger=", html)
            @test occursin("data-suite-select-content", html)
            @test occursin("role=\"combobox\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("aria-autocomplete=\"none\"", html)
            @test occursin("Apple", html)
            @test occursin("Banana", html)
            @test occursin("Pick a fruit...", html)
        end

        @testset "Select with initial value" begin
            html = Therapy.render_to_string(SuiteSelect(default_value="banana",
                SuiteSelectTrigger(SuiteSelectValue(placeholder="Pick...")),
                SuiteSelectContent(
                    SuiteSelectItem("Apple", value="apple"),
                    SuiteSelectItem("Banana", value="banana"),
                )
            ))
            @test occursin("data-suite-select-value=\"banana\"", html)
        end

        @testset "Select disabled" begin
            html = Therapy.render_to_string(SuiteSelect(disabled=true,
                SuiteSelectTrigger(SuiteSelectValue(placeholder="Pick...")),
                SuiteSelectContent(
                    SuiteSelectItem("A", value="a"),
                )
            ))
            @test occursin("data-disabled", html)
        end

        @testset "Select required" begin
            html = Therapy.render_to_string(SuiteSelect(required=true,
                SuiteSelectTrigger(SuiteSelectValue(placeholder="Pick...")),
                SuiteSelectContent(
                    SuiteSelectItem("A", value="a"),
                )
            ))
            @test occursin("data-required", html)
        end

        @testset "SelectTrigger styling" begin
            html = Therapy.render_to_string(SuiteSelectTrigger(SuiteSelectValue(placeholder="Pick...")))
            @test occursin("border-warm-200", html)
            @test occursin("dark:border-warm-700", html)
            @test occursin("h-9", html)
            @test occursin("rounded-md", html)
            @test occursin("shadow-xs", html)
            @test occursin("focus-visible:ring-", html)
            # Chevron icon
            @test occursin("opacity-50", html)
        end

        @testset "SelectTrigger custom class" begin
            html = Therapy.render_to_string(SuiteSelectTrigger(class="w-[200px]",
                SuiteSelectValue(placeholder="Pick...")))
            @test occursin("w-[200px]", html)
        end

        @testset "SelectValue placeholder" begin
            html = Therapy.render_to_string(SuiteSelectValue(placeholder="Choose..."))
            @test occursin("data-suite-select-display", html)
            @test occursin("data-placeholder", html)
            @test occursin("Choose...", html)
        end

        @testset "SelectContent styling" begin
            html = Therapy.render_to_string(SuiteSelectContent(
                SuiteSelectItem("A", value="a")
            ))
            @test occursin("role=\"listbox\"", html)
            @test occursin("bg-warm-50", html)
            @test occursin("dark:bg-warm-900", html)
            @test occursin("rounded-md", html)
            @test occursin("border-warm-200", html)
            @test occursin("shadow-md", html)
            @test occursin("animate-in", html)
            @test occursin("animate-out", html)
            @test occursin("slide-in-from-top-2", html)
            @test occursin("min-w-[8rem]", html)
            @test occursin("translate-y-1", html)
        end

        @testset "SelectContent custom side/align" begin
            html = Therapy.render_to_string(SuiteSelectContent(side="top", align="end", side_offset=8,
                SuiteSelectItem("A", value="a")
            ))
            @test occursin("data-suite-select-side=\"top\"", html)
            @test occursin("data-suite-select-align=\"end\"", html)
            @test occursin("data-suite-select-side-offset=\"8\"", html)
        end

        @testset "SelectContent custom class" begin
            html = Therapy.render_to_string(SuiteSelectContent(class="w-[300px]",
                SuiteSelectItem("A", value="a")
            ))
            @test occursin("w-[300px]", html)
        end

        @testset "SelectItem basic" begin
            html = Therapy.render_to_string(SuiteSelectItem("Apple", value="apple"))
            @test occursin("data-suite-select-item", html)
            @test occursin("data-suite-select-item-value=\"apple\"", html)
            @test occursin("role=\"option\"", html)
            @test occursin("aria-selected=\"false\"", html)
            @test occursin("data-state=\"unchecked\"", html)
            @test occursin("Apple", html)
            @test occursin("rounded-sm", html)
            @test occursin("pr-8", html)
            @test occursin("pl-2", html)
            # Check indicator hidden by default
            @test occursin("data-suite-select-item-indicator", html)
        end

        @testset "SelectItem disabled" begin
            html = Therapy.render_to_string(SuiteSelectItem("Apple", value="apple", disabled=true))
            @test occursin("data-disabled", html)
            @test occursin("aria-disabled=\"true\"", html)
            @test occursin("data-[disabled]", html)
        end

        @testset "SelectItem with text_value" begin
            html = Therapy.render_to_string(SuiteSelectItem("🍎 Apple", value="apple", text_value="Apple"))
            @test occursin("data-suite-select-item-text=\"Apple\"", html)
        end

        @testset "SelectItem custom class" begin
            html = Therapy.render_to_string(SuiteSelectItem("A", value="a", class="font-bold"))
            @test occursin("font-bold", html)
        end

        @testset "SelectGroup" begin
            html = Therapy.render_to_string(SuiteSelectGroup(
                SuiteSelectLabel("Fruits"),
                SuiteSelectItem("Apple", value="apple"),
            ))
            @test occursin("role=\"group\"", html)
            @test occursin("data-suite-select-group", html)
            @test occursin("Fruits", html)
            @test occursin("Apple", html)
        end

        @testset "SelectLabel" begin
            html = Therapy.render_to_string(SuiteSelectLabel("Category"))
            @test occursin("data-suite-select-label", html)
            @test occursin("role=\"presentation\"", html)
            @test occursin("font-semibold", html)
            @test occursin("Category", html)
        end

        @testset "SelectSeparator" begin
            html = Therapy.render_to_string(SuiteSelectSeparator())
            @test occursin("data-suite-select-separator", html)
            @test occursin("role=\"separator\"", html)
            @test occursin("h-px", html)
            @test occursin("bg-warm-200", html)
        end

        @testset "SelectScrollUpButton" begin
            html = Therapy.render_to_string(SuiteSelectScrollUpButton())
            @test occursin("data-suite-select-scroll-up", html)
            @test occursin("aria-hidden=\"true\"", html)
            # Default chevron up icon
            @test occursin("m18 15-6-6-6 6", html)
        end

        @testset "SelectScrollDownButton" begin
            html = Therapy.render_to_string(SuiteSelectScrollDownButton())
            @test occursin("data-suite-select-scroll-down", html)
            @test occursin("aria-hidden=\"true\"", html)
            # Default chevron down icon
            @test occursin("m6 9 6 6 6-6", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(SuiteSelectContent(
                SuiteSelectItem("A", value="a"),
                SuiteSelectSeparator(),
            ))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-300", html)
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:bg-warm-700", html)
        end

        @testset "Full composition" begin
            html = Therapy.render_to_string(SuiteSelect(
                SuiteSelectTrigger(SuiteSelectValue(placeholder="Select a fruit...")),
                SuiteSelectContent(
                    SuiteSelectGroup(
                        SuiteSelectLabel("Fruits"),
                        SuiteSelectItem("Apple", value="apple"),
                        SuiteSelectItem("Banana", value="banana"),
                        SuiteSelectItem("Orange", value="orange"),
                    ),
                    SuiteSelectSeparator(),
                    SuiteSelectGroup(
                        SuiteSelectLabel("Vegetables"),
                        SuiteSelectItem("Carrot", value="carrot"),
                        SuiteSelectItem("Broccoli", value="broccoli"),
                    ),
                )
            ))
            @test occursin("data-suite-select=", html)
            @test occursin("Select a fruit...", html)
            @test occursin("Fruits", html)
            @test occursin("Apple", html)
            @test occursin("Banana", html)
            @test occursin("Vegetables", html)
            @test occursin("Carrot", html)
            @test occursin("Broccoli", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Select)
            meta = Suite.COMPONENT_REGISTRY[:Select]
            @test meta.tier == :js_runtime
            @test :SuiteSelect in meta.exports
            @test :SuiteSelectTrigger in meta.exports
            @test :SuiteSelectValue in meta.exports
            @test :SuiteSelectContent in meta.exports
            @test :SuiteSelectItem in meta.exports
            @test :SuiteSelectGroup in meta.exports
            @test :SuiteSelectLabel in meta.exports
            @test :SuiteSelectSeparator in meta.exports
            @test :Select in meta.js_modules
            @test :Floating in meta.js_modules
        end
    end

    # ==================== Command ==============================================
    @testset "SuiteCommand" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(SuiteCommand(
                SuiteCommandInput(placeholder="Type a command..."),
                SuiteCommandList(
                    SuiteCommandEmpty("No results found."),
                    SuiteCommandGroup(heading="Suggestions",
                        SuiteCommandItem("Calendar", value="calendar"),
                        SuiteCommandItem("Search", value="search"),
                    ),
                )
            ))
            @test occursin("data-suite-command=", html)
            @test occursin("data-suite-command-input", html)
            @test occursin("data-suite-command-list", html)
            @test occursin("role=\"listbox\"", html)
            @test occursin("Type a command...", html)
            @test occursin("Calendar", html)
            @test occursin("Search", html)
        end

        @testset "Command root styling" begin
            html = Therapy.render_to_string(SuiteCommand(
                SuiteCommandInput(placeholder="Search..."),
                SuiteCommandList(
                    SuiteCommandItem("Test", value="test"),
                )
            ))
            @test occursin("bg-warm-50", html)
            @test occursin("dark:bg-warm-900", html)
            @test occursin("rounded-md", html)
            @test occursin("overflow-hidden", html)
        end

        @testset "Command filter attribute" begin
            html = Therapy.render_to_string(SuiteCommand(should_filter=false,
                SuiteCommandInput(placeholder="Search..."),
                SuiteCommandList(
                    SuiteCommandItem("Test", value="test"),
                )
            ))
            @test occursin("data-suite-command-filter=\"false\"", html)
        end

        @testset "Command loop attribute" begin
            html = Therapy.render_to_string(SuiteCommand(loop=false,
                SuiteCommandInput(placeholder="Search..."),
                SuiteCommandList(
                    SuiteCommandItem("Test", value="test"),
                )
            ))
            @test occursin("data-suite-command-loop=\"false\"", html)
        end

        @testset "Command custom class" begin
            html = Therapy.render_to_string(SuiteCommand(class="max-w-lg",
                SuiteCommandInput(placeholder="Search..."),
                SuiteCommandList(
                    SuiteCommandItem("Test", value="test"),
                )
            ))
            @test occursin("max-w-lg", html)
        end

        @testset "CommandInput" begin
            html = Therapy.render_to_string(SuiteCommandInput(placeholder="Search..."))
            @test occursin("data-suite-command-input", html)
            @test occursin("placeholder=\"Search...\"", html)
            @test occursin("autocomplete=\"off\"", html)
            @test occursin("spellcheck=\"false\"", html)
            @test occursin("border-b", html)
            # Search icon
            @test occursin("circle cx=\"11\" cy=\"11\"", html)
        end

        @testset "CommandInput custom class" begin
            html = Therapy.render_to_string(SuiteCommandInput(placeholder="Search...", class="font-bold"))
            @test occursin("font-bold", html)
        end

        @testset "CommandList" begin
            html = Therapy.render_to_string(SuiteCommandList(
                SuiteCommandItem("A", value="a"),
            ))
            @test occursin("data-suite-command-list", html)
            @test occursin("role=\"listbox\"", html)
            @test occursin("aria-label=\"Suggestions\"", html)
            @test occursin("max-h-[300px]", html)
            @test occursin("overflow-y-auto", html)
        end

        @testset "CommandEmpty" begin
            html = Therapy.render_to_string(SuiteCommandEmpty("No results found."))
            @test occursin("data-suite-command-empty", html)
            @test occursin("role=\"presentation\"", html)
            @test occursin("No results found.", html)
            @test occursin("text-center", html)
            @test occursin("display:none", html)  # hidden by default
        end

        @testset "CommandGroup" begin
            html = Therapy.render_to_string(SuiteCommandGroup(heading="Suggestions",
                SuiteCommandItem("Calendar", value="calendar"),
            ))
            @test occursin("data-suite-command-group", html)
            @test occursin("role=\"group\"", html)
            @test occursin("aria-labelledby=", html)
            @test occursin("Suggestions", html)
            @test occursin("data-suite-command-group-heading", html)
            @test occursin("font-medium", html)
            @test occursin("text-xs", html)
        end

        @testset "CommandGroup without heading" begin
            html = Therapy.render_to_string(SuiteCommandGroup(
                SuiteCommandItem("A", value="a"),
            ))
            @test occursin("data-suite-command-group", html)
            @test occursin("role=\"group\"", html)
            @test !occursin("aria-labelledby", html)
        end

        @testset "CommandItem basic" begin
            html = Therapy.render_to_string(SuiteCommandItem("Calendar", value="calendar"))
            @test occursin("data-suite-command-item", html)
            @test occursin("data-suite-command-item-value=\"calendar\"", html)
            @test occursin("role=\"option\"", html)
            @test occursin("aria-selected=\"false\"", html)
            @test occursin("Calendar", html)
            @test occursin("rounded-sm", html)
            @test occursin("cursor-default", html)
            @test occursin("data-[selected=true]:bg-warm-100", html)
        end

        @testset "CommandItem disabled" begin
            html = Therapy.render_to_string(SuiteCommandItem("Disabled", value="disabled", disabled=true))
            @test occursin("data-disabled=\"true\"", html)
            @test occursin("data-[disabled=true]:pointer-events-none", html)
            @test occursin("data-[disabled=true]:opacity-50", html)
        end

        @testset "CommandItem with keywords" begin
            html = Therapy.render_to_string(SuiteCommandItem("Settings", value="settings",
                keywords=["preferences", "config"]))
            @test occursin("data-suite-command-item-keywords=\"preferences,config\"", html)
        end

        @testset "CommandItem custom class" begin
            html = Therapy.render_to_string(SuiteCommandItem("A", value="a", class="font-bold"))
            @test occursin("font-bold", html)
        end

        @testset "CommandSeparator" begin
            html = Therapy.render_to_string(SuiteCommandSeparator())
            @test occursin("data-suite-command-separator", html)
            @test occursin("role=\"separator\"", html)
            @test occursin("h-px", html)
            @test occursin("bg-warm-200", html)
        end

        @testset "CommandShortcut" begin
            html = Therapy.render_to_string(SuiteCommandShortcut("⌘K"))
            @test occursin("data-suite-command-shortcut", html)
            @test occursin("⌘K", html)
            @test occursin("tracking-widest", html)
            @test occursin("text-xs", html)
            @test occursin("ml-auto", html)
        end

        @testset "CommandDialog" begin
            html = Therapy.render_to_string(SuiteCommandDialog(
                SuiteCommandInput(placeholder="Type a command..."),
                SuiteCommandList(
                    SuiteCommandItem("Test", value="test"),
                )
            ))
            @test occursin("data-suite-command-dialog=", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("display:none", html)
            @test occursin("data-suite-command-dialog-overlay", html)
            @test occursin("data-suite-command-dialog-content", html)
            @test occursin("data-suite-command=", html)
            # Should contain the Command inside
            @test occursin("Type a command...", html)
            @test occursin("Test", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(SuiteCommand(
                SuiteCommandInput(placeholder="Search..."),
                SuiteCommandList(
                    SuiteCommandGroup(heading="Test",
                        SuiteCommandItem("A", value="a"),
                    ),
                    SuiteCommandSeparator(),
                )
            ))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-300", html)
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:bg-warm-700", html)
        end

        @testset "Full composition" begin
            html = Therapy.render_to_string(SuiteCommand(
                SuiteCommandInput(placeholder="Type a command or search..."),
                SuiteCommandList(
                    SuiteCommandEmpty("No results found."),
                    SuiteCommandGroup(heading="Suggestions",
                        SuiteCommandItem("Calendar", value="calendar"),
                        SuiteCommandItem(
                            Span("Search Emoji"),
                            SuiteCommandShortcut("⌘E"),
                            value="emoji"),
                        SuiteCommandItem("Calculator", value="calculator"),
                    ),
                    SuiteCommandSeparator(),
                    SuiteCommandGroup(heading="Settings",
                        SuiteCommandItem("Profile", value="profile"),
                        SuiteCommandItem("Billing", value="billing",
                            keywords=["payment", "subscription"]),
                        SuiteCommandItem("Settings", value="settings",
                            keywords=["preferences", "config"]),
                    ),
                )
            ))
            @test occursin("data-suite-command=", html)
            @test occursin("Type a command or search...", html)
            @test occursin("No results found.", html)
            @test occursin("Suggestions", html)
            @test occursin("Calendar", html)
            @test occursin("Search Emoji", html)
            @test occursin("⌘E", html)
            @test occursin("Settings", html)
            @test occursin("payment,subscription", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Command)
            meta = Suite.COMPONENT_REGISTRY[:Command]
            @test meta.tier == :js_runtime
            @test :SuiteCommand in meta.exports
            @test :SuiteCommandInput in meta.exports
            @test :SuiteCommandList in meta.exports
            @test :SuiteCommandEmpty in meta.exports
            @test :SuiteCommandGroup in meta.exports
            @test :SuiteCommandItem in meta.exports
            @test :SuiteCommandSeparator in meta.exports
            @test :SuiteCommandShortcut in meta.exports
            @test :SuiteCommandDialog in meta.exports
            @test :Command in meta.js_modules
        end
    end

    # =====================================================================
    # Theme System Tests
    # =====================================================================
    @testset "Themes" begin
        using Therapy
        using Suite

        @testset "SuiteTheme struct and registry" begin
            @test haskey(Suite.SUITE_THEMES, :default)
            @test haskey(Suite.SUITE_THEMES, :ocean)
            @test haskey(Suite.SUITE_THEMES, :minimal)
            @test haskey(Suite.SUITE_THEMES, :nature)
            @test length(Suite.SUITE_THEMES) == 4

            default = Suite.SUITE_THEMES[:default]
            @test default.name === :default
            @test default.accent == "accent"
            @test default.accent_secondary == "accent-secondary"
            @test default.neutral == "warm"
            @test default.radius == "rounded-md"
            @test default.shadow == "shadow-sm"

            ocean = Suite.SUITE_THEMES[:ocean]
            @test ocean.accent == "blue"
            @test ocean.accent_secondary == "rose"
            @test ocean.neutral == "warm"
            @test ocean.radius == "rounded-lg"
            @test ocean.shadow == "shadow-md"

            minimal = Suite.SUITE_THEMES[:minimal]
            @test minimal.accent == "zinc"
            @test minimal.accent_secondary == "red"
            @test minimal.neutral == "slate"
            @test minimal.radius == "rounded-none"
            @test minimal.shadow == "shadow-none"

            nature = Suite.SUITE_THEMES[:nature]
            @test nature.accent == "emerald"
            @test nature.accent_secondary == "amber"
            @test nature.neutral == "stone"
            @test nature.radius == "rounded-xl"
        end

        @testset "get_theme" begin
            @test Suite.get_theme(:default).name === :default
            @test Suite.get_theme(:ocean).name === :ocean
            @test Suite.get_theme(:nonexistent).name === :default  # fallback
        end

        @testset "resolve_theme without overrides" begin
            t = Suite.resolve_theme(:ocean)
            @test t.name === :ocean
            @test t.accent == "blue"
        end

        @testset "resolve_theme with overrides" begin
            t = Suite.resolve_theme(:ocean; accent="indigo")
            @test t.accent == "indigo"
            @test t.neutral == "warm"  # unchanged

            t2 = Suite.resolve_theme(:minimal; neutral="gray", radius="rounded-sm")
            @test t2.neutral == "gray"
            @test t2.radius == "rounded-sm"
            @test t2.accent == "zinc"  # unchanged
        end

        @testset "apply_theme identity for default" begin
            input = "bg-accent-600 text-warm-800 rounded-md shadow-sm"
            @test Suite.apply_theme(input, Suite.get_theme(:default)) == input
        end

        @testset "apply_theme ocean substitutions" begin
            t = Suite.get_theme(:ocean)
            @test Suite.apply_theme("bg-accent-600", t) == "bg-blue-600"
            @test Suite.apply_theme("text-accent-400", t) == "text-blue-400"
            @test Suite.apply_theme("bg-accent-secondary-600", t) == "bg-rose-600"
            # warm stays warm for ocean
            @test Suite.apply_theme("bg-warm-100", t) == "bg-warm-100"
            # radius
            @test Suite.apply_theme("rounded-md", t) == "rounded-lg"
            @test Suite.apply_theme("rounded-sm", t) == "rounded-md"
            # shadow
            @test Suite.apply_theme("shadow-sm", t) == "shadow-md"
        end

        @testset "apply_theme minimal substitutions" begin
            t = Suite.get_theme(:minimal)
            @test Suite.apply_theme("bg-accent-600", t) == "bg-zinc-600"
            @test Suite.apply_theme("bg-accent-secondary-600", t) == "bg-red-600"
            @test Suite.apply_theme("bg-warm-100", t) == "bg-slate-100"
            @test Suite.apply_theme("text-warm-600", t) == "text-slate-600"
            @test Suite.apply_theme("rounded-md", t) == "rounded-none"
            @test Suite.apply_theme("shadow-sm", t) == "shadow-none"
        end

        @testset "apply_theme nature substitutions" begin
            t = Suite.get_theme(:nature)
            @test Suite.apply_theme("bg-accent-600", t) == "bg-emerald-600"
            @test Suite.apply_theme("bg-accent-secondary-600", t) == "bg-amber-600"
            @test Suite.apply_theme("bg-warm-100", t) == "bg-stone-100"
            @test Suite.apply_theme("rounded-md", t) == "rounded-xl"
            @test Suite.apply_theme("rounded-sm", t) == "rounded-lg"
        end

        @testset "apply_theme ordering: accent-secondary before accent" begin
            t = Suite.get_theme(:ocean)
            input = "bg-accent-secondary-600 border-accent-600"
            result = Suite.apply_theme(input, t)
            @test result == "bg-rose-600 border-blue-600"
            @test !occursin("accent-", result)
        end

        @testset "apply_theme complex class string" begin
            t = Suite.get_theme(:minimal)
            input = "bg-accent-600 text-white hover:bg-accent-700 border border-warm-200 dark:border-warm-700 rounded-md shadow-sm"
            result = Suite.apply_theme(input, t)
            @test occursin("bg-zinc-600", result)
            @test occursin("hover:bg-zinc-700", result)
            @test occursin("border-slate-200", result)
            @test occursin("dark:border-slate-700", result)
            @test occursin("rounded-none", result)
            @test occursin("shadow-none", result)
            @test !occursin("accent-", result)
            @test !occursin("warm-", result)
        end

        @testset "SuiteButton with theme" begin
            @testset "Default theme unchanged" begin
                default_html = Therapy.render_to_string(SuiteButton("Click"))
                themed_html = Therapy.render_to_string(SuiteButton("Click", theme=:default))
                @test default_html == themed_html
            end

            @testset "Ocean theme" begin
                html = Therapy.render_to_string(SuiteButton("Click", theme=:ocean))
                @test occursin("bg-blue-600", html)
                @test !occursin("bg-accent-600", html)
                @test occursin("rounded-lg", html)
            end

            @testset "Minimal theme" begin
                html = Therapy.render_to_string(SuiteButton("Click", theme=:minimal))
                @test occursin("bg-zinc-600", html)
                @test occursin("rounded-none", html)
                @test !occursin("shadow-sm", html)
            end

            @testset "Nature theme" begin
                html = Therapy.render_to_string(SuiteButton("Click", theme=:nature))
                @test occursin("bg-emerald-600", html)
                @test occursin("rounded-xl", html)
            end

            @testset "Destructive variant with theme" begin
                html = Therapy.render_to_string(SuiteButton("Del", variant="destructive", theme=:ocean))
                @test occursin("bg-rose-600", html)
                @test !occursin("accent-secondary", html)
            end
        end

        @testset "SuiteCard with theme" begin
            html = Therapy.render_to_string(SuiteCard(theme=:minimal, "Content"))
            @test occursin("border-slate-200", html)
            @test !occursin("warm-", html)
            @test occursin("shadow-none", html)
        end

        @testset "SuiteBadge with theme" begin
            html = Therapy.render_to_string(SuiteBadge("New", theme=:ocean))
            @test occursin("bg-blue-600", html)
            @test !occursin("bg-accent-600", html)
        end

        @testset "SuiteInput with theme" begin
            html = Therapy.render_to_string(SuiteInput(theme=:minimal))
            @test occursin("border-slate-200", html)
            @test occursin("ring-zinc-600", html)
        end

        @testset "SuiteProgress with theme" begin
            html = Therapy.render_to_string(SuiteProgress(value=50, theme=:ocean))
            @test occursin("bg-blue-600", html)
            @test !occursin("accent-600", html)
        end

        @testset "SuiteSeparator with theme" begin
            html = Therapy.render_to_string(SuiteSeparator(theme=:minimal))
            @test occursin("bg-slate-200", html)
            @test !occursin("warm-", html)
        end

        @testset "SuiteAlert with theme" begin
            html = Therapy.render_to_string(SuiteAlert(variant="destructive", theme=:ocean, "Error"))
            @test occursin("rose-600", html)
            @test !occursin("accent-secondary-", html)
        end

        @testset "Extraction with theme" begin
            mktempdir() do dir
                Suite.extract(:Button, dir, theme=:ocean, overwrite=true)
                content = read(joinpath(dir, "Button.jl"), String)
                @test occursin("blue-600", content)
                @test !occursin("accent-600", content)
                @test occursin("rose-600", content) || occursin("rose-700", content)
            end

            mktempdir() do dir
                Suite.extract(:Button, dir, theme=:minimal, overwrite=true)
                content = read(joinpath(dir, "Button.jl"), String)
                @test occursin("zinc-600", content)
                @test occursin("slate-", content)
                @test occursin("rounded-none", content)
            end

            # Default extraction unchanged
            mktempdir() do dir
                Suite.extract(:Button, dir, theme=:default, overwrite=true)
                content = read(joinpath(dir, "Button.jl"), String)
                @test occursin("accent-600", content)
                @test occursin("warm-", content)
            end
        end

        @testset "apply_theme_to_source" begin
            source = """
            "bg-accent-600 text-white hover:bg-accent-700"
            "border-warm-200 dark:border-warm-700"
            """
            t = Suite.get_theme(:ocean)
            result = Suite.apply_theme_to_source(source, t)
            @test occursin("bg-blue-600", result)
            @test occursin("hover:bg-blue-700", result)
            # warm stays for ocean
            @test occursin("border-warm-200", result)
        end
    end

    @testset "SuiteMenubar" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(SuiteMenubar(
                SuiteMenubarMenu(
                    SuiteMenubarTrigger("File"),
                    SuiteMenubarContent(
                        SuiteMenubarItem("New Tab"),
                        SuiteMenubarItem("New Window"),
                    )
                ),
                SuiteMenubarMenu(
                    SuiteMenubarTrigger("Edit"),
                    SuiteMenubarContent(
                        SuiteMenubarItem("Undo"),
                        SuiteMenubarItem("Redo"),
                    )
                ),
            ))
            @test occursin("data-suite-menubar", html)
            @test occursin("role=\"menubar\"", html)
            @test occursin("data-suite-menubar-trigger=", html)
            @test occursin("data-suite-menubar-content", html)
            @test occursin("aria-haspopup=\"menu\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("File", html)
            @test occursin("Edit", html)
            @test occursin("New Tab", html)
            @test occursin("Undo", html)
        end

        @testset "Menubar styling" begin
            html = Therapy.render_to_string(SuiteMenubar(
                SuiteMenubarMenu(SuiteMenubarTrigger("File"), SuiteMenubarContent(SuiteMenubarItem("A")))
            ))
            @test occursin("flex", html)
            @test occursin("h-9", html)
            @test occursin("rounded-md", html)
            @test occursin("bg-warm-50", html)
            @test occursin("dark:bg-warm-950", html)
            @test occursin("border-warm-200", html)
            @test occursin("shadow-xs", html)
        end

        @testset "Trigger is a button" begin
            html = Therapy.render_to_string(SuiteMenubarTrigger("File"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
            @test occursin("role=\"menuitem\"", html)
        end

        @testset "Trigger styling" begin
            html = Therapy.render_to_string(SuiteMenubarTrigger("File"))
            @test occursin("text-sm", html)
            @test occursin("font-medium", html)
            @test occursin("rounded-sm", html)
            @test occursin("px-2", html)
            @test occursin("data-[state=open]:bg-warm-100", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(SuiteMenubarContent(
                SuiteMenubarItem("A")
            ))
            @test occursin("data-suite-menubar-content", html)
            @test occursin("role=\"menu\"", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("display:none", html)
            @test occursin("min-w-[12rem]", html)
            @test occursin("rounded-md", html)
            @test occursin("shadow-md", html)
            @test occursin("bg-warm-50", html)
            @test occursin("animate-in", html)
        end

        @testset "MenuItem" begin
            html = Therapy.render_to_string(SuiteMenubarItem("Profile"))
            @test occursin("data-suite-menu-item", html)
            @test occursin("role=\"menuitem\"", html)
            @test occursin("Profile", html)
        end

        @testset "MenuItem with shortcut" begin
            html = Therapy.render_to_string(SuiteMenubarItem("New Tab", shortcut="⌘T"))
            @test occursin("New Tab", html)
            @test occursin("⌘T", html)
            @test occursin("data-suite-menu-shortcut", html)
        end

        @testset "MenuItem disabled" begin
            html = Therapy.render_to_string(SuiteMenubarItem("Disabled", disabled=true))
            @test occursin("data-disabled", html)
        end

        @testset "CheckboxItem" begin
            html = Therapy.render_to_string(SuiteMenubarCheckboxItem("Toolbar", checked=true))
            @test occursin("data-suite-menu-checkbox-item", html)
            @test occursin("role=\"menuitemcheckbox\"", html)
            @test occursin("aria-checked=\"true\"", html)
            @test occursin("data-state=\"checked\"", html)
        end

        @testset "RadioGroup and RadioItem" begin
            html = Therapy.render_to_string(SuiteMenubarRadioGroup(value="a",
                SuiteMenubarRadioItem(value="a", checked=true, "Alpha"),
                SuiteMenubarRadioItem(value="b", "Beta"),
            ))
            @test occursin("data-suite-menu-radio-group", html)
            @test occursin("role=\"menuitemradio\"", html)
            @test occursin("data-state=\"checked\"", html)
            @test occursin("data-state=\"unchecked\"", html)
        end

        @testset "Label" begin
            html = Therapy.render_to_string(SuiteMenubarLabel("Section"))
            @test occursin("Section", html)
            @test occursin("font-medium", html)
        end

        @testset "Separator" begin
            html = Therapy.render_to_string(SuiteMenubarSeparator())
            @test occursin("role=\"separator\"", html)
            @test occursin("h-px", html)
            @test occursin("bg-warm-200", html)
        end

        @testset "SubMenu structure" begin
            html = Therapy.render_to_string(SuiteMenubarSub(
                SuiteMenubarSubTrigger("More"),
                SuiteMenubarSubContent(
                    SuiteMenubarItem("Sub Item"),
                )
            ))
            @test occursin("data-suite-menu-sub", html)
            @test occursin("data-suite-menu-sub-trigger", html)
            @test occursin("data-suite-menu-sub-content", html)
            @test occursin("Sub Item", html)
            # Chevron icon
            @test occursin("M6 12L10 8L6 4", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteMenubar(class="my-bar",
                SuiteMenubarMenu(SuiteMenubarTrigger("X"), SuiteMenubarContent(SuiteMenubarItem("A")))
            ))
            @test occursin("my-bar", html)
        end

        @testset "Loop attribute" begin
            html = Therapy.render_to_string(SuiteMenubar(loop=false,
                SuiteMenubarMenu(SuiteMenubarTrigger("X"), SuiteMenubarContent(SuiteMenubarItem("A")))
            ))
            @test occursin("data-loop=\"false\"", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Menubar)
            meta = Suite.COMPONENT_REGISTRY[:Menubar]
            @test meta.tier == :js_runtime
            @test :SuiteMenubar in meta.exports
            @test :SuiteMenubarTrigger in meta.exports
            @test :SuiteMenubarContent in meta.exports
            @test :SuiteMenubarItem in meta.exports
            @test :Menu in meta.js_modules
            @test :Menubar in meta.js_modules
        end
    end

    @testset "SuiteNavigationMenu" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(SuiteNavigationMenu(
                SuiteNavigationMenuList(
                    SuiteNavigationMenuItem(
                        SuiteNavigationMenuTrigger("Getting Started"),
                        SuiteNavigationMenuContent(
                            SuiteNavigationMenuLink("Introduction", href="/docs/"),
                        )
                    ),
                    SuiteNavigationMenuItem(
                        SuiteNavigationMenuLink("Documentation", href="/docs/")
                    ),
                ),
                SuiteNavigationMenuViewport(),
            ))
            @test occursin("data-suite-nav-menu=", html)
            @test occursin("data-suite-nav-menu-list", html)
            @test occursin("data-suite-nav-menu-item", html)
            @test occursin("data-suite-nav-menu-trigger", html)
            @test occursin("data-suite-nav-menu-content", html)
            @test occursin("data-suite-nav-menu-link", html)
            @test occursin("data-suite-nav-menu-viewport", html)
            @test occursin("Getting Started", html)
            @test occursin("Introduction", html)
            @test occursin("Documentation", html)
        end

        @testset "Root styling" begin
            html = Therapy.render_to_string(SuiteNavigationMenu(
                SuiteNavigationMenuList(
                    SuiteNavigationMenuItem(SuiteNavigationMenuLink("A", href="/a/"))
                )
            ))
            @test occursin("relative", html)
            @test occursin("flex", html)
            @test occursin("items-center", html)
        end

        @testset "List is a UL" begin
            html = Therapy.render_to_string(SuiteNavigationMenuList(
                SuiteNavigationMenuItem(SuiteNavigationMenuLink("A", href="/a/"))
            ))
            @test occursin("<ul", html)
            @test occursin("list-none", html)
        end

        @testset "Item is a LI" begin
            html = Therapy.render_to_string(SuiteNavigationMenuItem(
                SuiteNavigationMenuLink("A", href="/a/")
            ))
            @test occursin("<li", html)
            @test occursin("data-suite-nav-menu-item", html)
        end

        @testset "Trigger is a button with chevron" begin
            html = Therapy.render_to_string(SuiteNavigationMenuTrigger("Products"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
            @test occursin("data-suite-nav-menu-trigger", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("Products", html)
            # Chevron SVG
            @test occursin("group-data-[state=open]:rotate-180", html)
        end

        @testset "Trigger styling" begin
            html = Therapy.render_to_string(SuiteNavigationMenuTrigger("Products"))
            @test occursin("h-9", html)
            @test occursin("rounded-md", html)
            @test occursin("text-sm", html)
            @test occursin("font-medium", html)
            @test occursin("bg-warm-50", html)
            @test occursin("hover:bg-warm-100", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(SuiteNavigationMenuContent(
                SuiteNavigationMenuLink("A", href="/a/")
            ))
            @test occursin("data-suite-nav-menu-content", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("display:none", html)
            @test occursin("md:absolute", html)
            # Motion animation classes
            @test occursin("data-[motion^=from-]:animate-in", html)
            @test occursin("data-[motion^=to-]:animate-out", html)
        end

        @testset "Link rendering" begin
            html = Therapy.render_to_string(SuiteNavigationMenuLink("Install", href="/install/"))
            @test occursin("<a", html)
            @test occursin("href=\"/install/\"", html)
            @test occursin("data-suite-nav-menu-link", html)
            @test occursin("Install", html)
            @test occursin("rounded-sm", html)
        end

        @testset "Link with description" begin
            html = Therapy.render_to_string(SuiteNavigationMenuLink("Install", href="/install/", description="How to install Suite.jl"))
            @test occursin("Install", html)
            @test occursin("How to install Suite.jl", html)
            @test occursin("line-clamp-2", html)
        end

        @testset "Link active state" begin
            html = Therapy.render_to_string(SuiteNavigationMenuLink("Home", href="/", active=true))
            @test occursin("data-active=\"true\"", html)
        end

        @testset "Viewport" begin
            html = Therapy.render_to_string(SuiteNavigationMenuViewport())
            @test occursin("data-suite-nav-menu-viewport", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("display:none", html)
            @test occursin("rounded-md", html)
            @test occursin("shadow", html)
            @test occursin("bg-warm-50", html)
            @test occursin("border-warm-200", html)
        end

        @testset "Indicator" begin
            html = Therapy.render_to_string(SuiteNavigationMenuIndicator())
            @test occursin("data-suite-nav-menu-indicator", html)
            @test occursin("data-state=\"hidden\"", html)
            @test occursin("rotate-45", html)  # arrow
        end

        @testset "Delay attributes" begin
            html = Therapy.render_to_string(SuiteNavigationMenu(
                delay_duration=300,
                skip_delay_duration=500,
                SuiteNavigationMenuList(
                    SuiteNavigationMenuItem(SuiteNavigationMenuLink("A", href="/a/"))
                )
            ))
            @test occursin("data-delay-duration=\"300\"", html)
            @test occursin("data-skip-delay-duration=\"500\"", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteNavigationMenu(class="my-nav",
                SuiteNavigationMenuList(
                    SuiteNavigationMenuItem(SuiteNavigationMenuLink("A", href="/a/"))
                )
            ))
            @test occursin("my-nav", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :NavigationMenu)
            meta = Suite.COMPONENT_REGISTRY[:NavigationMenu]
            @test meta.tier == :js_runtime
            @test :SuiteNavigationMenu in meta.exports
            @test :SuiteNavigationMenuList in meta.exports
            @test :SuiteNavigationMenuTrigger in meta.exports
            @test :SuiteNavigationMenuContent in meta.exports
            @test :SuiteNavigationMenuLink in meta.exports
            @test :SuiteNavigationMenuViewport in meta.exports
            @test :NavigationMenu in meta.js_modules
        end
    end

    # ===================================================================
    # Toast (Sonner-style notification system)
    # ===================================================================
    @testset "SuiteToaster" begin
        @testset "Default rendering" begin
            html = Therapy.render_to_string(SuiteToaster())
            @test occursin("data-suite-toaster", html)
            @test occursin("aria-label=\"Notifications\"", html)
            @test occursin("tabindex=\"-1\"", html)
            @test occursin("<section", html)
        end

        @testset "Default position" begin
            html = Therapy.render_to_string(SuiteToaster())
            @test occursin("data-position=\"bottom-right\"", html)
        end

        @testset "Custom position" begin
            html = Therapy.render_to_string(SuiteToaster(position="top-center"))
            @test occursin("data-position=\"top-center\"", html)
        end

        @testset "All positions" begin
            for pos in ["top-left", "top-center", "top-right", "bottom-left", "bottom-center", "bottom-right"]
                html = Therapy.render_to_string(SuiteToaster(position=pos))
                @test occursin("data-position=\"$pos\"", html)
            end
        end

        @testset "Custom duration" begin
            html = Therapy.render_to_string(SuiteToaster(duration=8000))
            @test occursin("data-duration=\"8000\"", html)
        end

        @testset "Default duration" begin
            html = Therapy.render_to_string(SuiteToaster())
            @test occursin("data-duration=\"4000\"", html)
        end

        @testset "Custom visible toasts" begin
            html = Therapy.render_to_string(SuiteToaster(visible_toasts=5))
            @test occursin("data-visible-toasts=\"5\"", html)
        end

        @testset "Default visible toasts" begin
            html = Therapy.render_to_string(SuiteToaster())
            @test occursin("data-visible-toasts=\"3\"", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(SuiteToaster(class="my-custom"))
            @test occursin("my-custom", html)
        end

        @testset "Theme support" begin
            html_default = Therapy.render_to_string(SuiteToaster())
            html_ocean = Therapy.render_to_string(SuiteToaster(theme=:ocean))
            # Both should render the container
            @test occursin("data-suite-toaster", html_default)
            @test occursin("data-suite-toaster", html_ocean)
        end

        @testset "Exported from Suite" begin
            @test isdefined(Suite, :SuiteToaster)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Toast)
            meta = Suite.COMPONENT_REGISTRY[:Toast]
            @test meta.tier == :js_runtime
            @test :SuiteToaster in meta.exports
            @test :Toast in meta.js_modules
        end

        @testset "JS runtime includes Toast module" begin
            js = Suite.suite_js_source()
            @test occursin("Toast:", js)
            @test occursin("Suite.toast", js)
            @test occursin("data-suite-toaster", js)
            @test occursin("Suite.Toast.show", js)
            @test occursin("Suite.Toast.success", js)
            @test occursin("Suite.Toast.error", js)
            @test occursin("Suite.Toast.warning", js)
            @test occursin("Suite.Toast.info", js)
            @test occursin("Suite.Toast.dismiss", js)
            @test occursin("Suite.Toast.dismissAll", js)
        end

        @testset "JS toast variants have icons" begin
            js = Suite.suite_js_source()
            # Success icon (checkmark)
            @test occursin("success:", js)
            # Error icon (X circle)
            @test occursin("error:", js)
            # Warning icon (triangle)
            @test occursin("warning:", js)
            # Info icon (info circle)
            @test occursin("info:", js)
        end

        @testset "JS swipe-to-dismiss" begin
            js = Suite.suite_js_source()
            @test occursin("_setupSwipe", js)
            @test occursin("pointerdown", js)
            @test occursin("pointermove", js)
            @test occursin("pointerup", js)
            @test occursin("swipeThreshold", js)
        end

        @testset "JS auto-dismiss timer" begin
            js = Suite.suite_js_source()
            @test occursin("_startTimer", js)
            @test occursin("_pauseTimer", js)
            @test occursin("_resumeTimer", js)
            @test occursin("duration: 4000", js)
        end

        @testset "JS stacking" begin
            js = Suite.suite_js_source()
            @test occursin("_updatePositions", js)
            @test occursin("visibleToasts", js)
            @test occursin("gap: 14", js)
        end

        @testset "ARIA attributes" begin
            js = Suite.suite_js_source()
            @test occursin("role", js)
            @test occursin("aria-live", js)
            @test occursin("aria-atomic", js)
        end
    end

    @testset "SuiteCalendar" begin
        using Therapy
        using Suite
        using Dates

        @testset "Default rendering" begin
            html = Therapy.render_to_string(SuiteCalendar())
            @test occursin("data-suite-calendar", html)
            @test occursin("role=\"grid\"", html)
            @test occursin("data-suite-calendar-mode=\"single\"", html)
            @test occursin("p-3", html)
        end

        @testset "Month/year navigation buttons" begin
            html = Therapy.render_to_string(SuiteCalendar(month=2, year=2026))
            @test occursin("data-suite-calendar-month=\"2\"", html)
            @test occursin("data-suite-calendar-year=\"2026\"", html)
            @test occursin("data-suite-calendar-prev", html)
            @test occursin("data-suite-calendar-next", html)
            @test occursin("Go to previous month", html)
            @test occursin("Go to next month", html)
        end

        @testset "Caption displays month and year" begin
            html = Therapy.render_to_string(SuiteCalendar(month=6, year=2026))
            @test occursin("June 2026", html)
            @test occursin("aria-live=\"polite\"", html)
        end

        @testset "Weekday headers" begin
            html = Therapy.render_to_string(SuiteCalendar(month=2, year=2026))
            @test occursin("Mo", html)
            @test occursin("Tu", html)
            @test occursin("We", html)
            @test occursin("Th", html)
            @test occursin("Fr", html)
            @test occursin("Sa", html)
            @test occursin("Su", html)
            @test occursin("aria-hidden=\"true\"", html)
        end

        @testset "Day buttons rendered" begin
            html = Therapy.render_to_string(SuiteCalendar(month=2, year=2026))
            # February 2026 has 28 days
            @test occursin("data-suite-calendar-day-btn=\"2026-02-01\"", html)
            @test occursin("data-suite-calendar-day-btn=\"2026-02-28\"", html)
            @test occursin("data-suite-calendar-day=\"2026-02-01\"", html)
        end

        @testset "Day button ARIA label" begin
            html = Therapy.render_to_string(SuiteCalendar(month=2, year=2026))
            # Feb 1, 2026 is a Sunday
            @test occursin("Sun, Feb 1, 2026", html) || occursin("2026-02-01", html)
        end

        @testset "Today highlighting" begin
            today = Dates.today()
            html = Therapy.render_to_string(SuiteCalendar(month=Dates.month(today), year=Dates.year(today)))
            @test occursin("data-today=\"true\"", html)
            @test occursin("bg-warm-100", html)
        end

        @testset "Outside days" begin
            # show_outside_days=true (default)
            html_show = Therapy.render_to_string(SuiteCalendar(month=2, year=2026, show_outside_days=true))
            @test occursin("data-outside=\"true\"", html_show)
            @test occursin("opacity-50", html_show)

            # show_outside_days=false
            html_hide = Therapy.render_to_string(SuiteCalendar(month=2, year=2026, show_outside_days=false))
            # Outside days should be empty cells (no button)
            # The non-outside cells should still have buttons
            @test occursin("data-suite-calendar-day-btn=\"2026-02-01\"", html_hide)
        end

        @testset "Selection modes" begin
            for mode in ["single", "multiple", "range"]
                html = Therapy.render_to_string(SuiteCalendar(mode=mode))
                @test occursin("data-suite-calendar-mode=\"$mode\"", html)
            end

            # range and multiple have aria-multiselectable
            html_range = Therapy.render_to_string(SuiteCalendar(mode="range"))
            @test occursin("aria-multiselectable=\"true\"", html_range)

            html_multi = Therapy.render_to_string(SuiteCalendar(mode="multiple"))
            @test occursin("aria-multiselectable=\"true\"", html_multi)

            # single should NOT have aria-multiselectable
            html_single = Therapy.render_to_string(SuiteCalendar(mode="single"))
            @test !occursin("aria-multiselectable", html_single)
        end

        @testset "Pre-selected date" begin
            html = Therapy.render_to_string(SuiteCalendar(selected="2026-02-14", month=2, year=2026))
            @test occursin("data-suite-calendar-selected=\"2026-02-14\"", html)
        end

        @testset "Disabled dates" begin
            html = Therapy.render_to_string(SuiteCalendar(disabled_dates="2026-02-14,2026-02-15", month=2, year=2026))
            @test occursin("data-suite-calendar-disabled=\"2026-02-14,2026-02-15\"", html)
        end

        @testset "Number of months" begin
            html = Therapy.render_to_string(SuiteCalendar(number_of_months=2, month=1, year=2026))
            @test occursin("data-suite-calendar-months-count=\"2\"", html)
            @test occursin("January 2026", html)
            @test occursin("February 2026", html)
        end

        @testset "Custom class merging" begin
            html = Therapy.render_to_string(SuiteCalendar(class="my-custom"))
            @test occursin("my-custom", html)
            @test occursin("p-3", html)
        end

        @testset "Keyboard accessibility" begin
            html = Therapy.render_to_string(SuiteCalendar(month=2, year=2026))
            # Roving tabindex - all buttons start with tabindex=-1
            @test occursin("tabindex=\"-1\"", html)
            # Focus ring classes
            @test occursin("focus-visible:ring-2", html)
            @test occursin("focus-visible:ring-accent-600", html)
        end

        @testset "Grid structure" begin
            html = Therapy.render_to_string(SuiteCalendar(month=2, year=2026))
            # Semantic table structure
            @test occursin("<table", html)
            @test occursin("<thead", html)
            @test occursin("<tbody", html)
            @test occursin("<tr", html)
            @test occursin("<th", html)
            @test occursin("<td", html)
            @test occursin("scope=\"col\"", html)
            @test occursin("role=\"gridcell\"", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(SuiteCalendar(month=2, year=2026))
            @test occursin("dark:hover:bg-warm-900", html)
            @test occursin("dark:text-warm-300", html)
        end

        @testset "Nav button styling" begin
            html = Therapy.render_to_string(SuiteCalendar(month=2, year=2026))
            @test occursin("border-warm-200", html)
            @test occursin("hover:bg-warm-100", html)
        end

        @testset "Registry registration" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Calendar)
            meta = Suite.COMPONENT_REGISTRY[:Calendar]
            @test meta.tier == :js_runtime
            @test meta.file == "Calendar.jl"
            @test :SuiteCalendar in meta.exports
            @test :SuiteDatePicker in meta.exports
        end

        @testset "Theme support" begin
            html_default = Therapy.render_to_string(SuiteCalendar(month=2, year=2026))
            html_ocean = Therapy.render_to_string(SuiteCalendar(month=2, year=2026, theme=:ocean))

            @test occursin("accent-600", html_default)
            # Ocean theme should substitute accent colors
            @test occursin("blue-600", html_ocean)
        end

        @testset "Fixed weeks" begin
            html = Therapy.render_to_string(SuiteCalendar(month=2, year=2026, fixed_weeks=true))
            @test occursin("data-suite-calendar-fixed-weeks=\"true\"", html)
        end

        @testset "JS module in suite.js" begin
            js = Suite.suite_js_source()
            @test occursin("Calendar:", js)
            @test occursin("data-suite-calendar", js)
            @test occursin("_handleKeyDown", js)
            @test occursin("ArrowLeft", js)
            @test occursin("ArrowRight", js)
            @test occursin("ArrowUp", js)
            @test occursin("ArrowDown", js)
            @test occursin("PageUp", js)
            @test occursin("PageDown", js)
            @test occursin("Home", js)
            @test occursin("End", js)
        end
    end

    @testset "SuiteDatePicker" begin
        using Therapy
        using Suite
        using Dates

        @testset "Default rendering" begin
            html = Therapy.render_to_string(SuiteDatePicker())
            @test occursin("data-suite-datepicker", html)
            @test occursin("data-suite-datepicker-trigger", html)
            @test occursin("data-suite-datepicker-content", html)
            @test occursin("data-suite-datepicker-value", html)
        end

        @testset "Trigger button" begin
            html = Therapy.render_to_string(SuiteDatePicker())
            @test occursin("Pick a date", html)
            @test occursin("aria-haspopup=\"dialog\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("w-[280px]", html)
            # Calendar icon SVG
            @test occursin("<svg", html)
        end

        @testset "Placeholder text" begin
            html = Therapy.render_to_string(SuiteDatePicker(placeholder="Select a date"))
            @test occursin("Select a date", html)
        end

        @testset "Pre-selected date display" begin
            html = Therapy.render_to_string(SuiteDatePicker(selected="2026-02-14", month=2, year=2026))
            @test occursin("data-suite-datepicker-selected=\"2026-02-14\"", html)
            # Should show formatted date, not placeholder
            @test !occursin("Pick a date", html)
        end

        @testset "Contains Calendar component" begin
            html = Therapy.render_to_string(SuiteDatePicker(month=2, year=2026))
            @test occursin("data-suite-calendar", html)
            @test occursin("role=\"grid\"", html)
            @test occursin("February 2026", html)
        end

        @testset "Content hidden by default" begin
            html = Therapy.render_to_string(SuiteDatePicker())
            @test occursin("display:none", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Dialog role on content" begin
            html = Therapy.render_to_string(SuiteDatePicker())
            @test occursin("role=\"dialog\"", html)
            @test occursin("aria-modal=\"true\"", html)
        end

        @testset "Selection mode passthrough" begin
            html = Therapy.render_to_string(SuiteDatePicker(mode="range", number_of_months=2, month=1, year=2026))
            @test occursin("data-suite-datepicker-mode=\"range\"", html)
            @test occursin("data-suite-calendar-mode=\"range\"", html)
            @test occursin("January 2026", html)
            @test occursin("February 2026", html)
        end

        @testset "Custom class on trigger" begin
            html = Therapy.render_to_string(SuiteDatePicker(class="my-picker"))
            @test occursin("my-picker", html)
        end

        @testset "Theme support" begin
            html_default = Therapy.render_to_string(SuiteDatePicker(month=2, year=2026))
            html_ocean = Therapy.render_to_string(SuiteDatePicker(month=2, year=2026, theme=:ocean))
            @test occursin("accent-600", html_default)
            @test occursin("blue-600", html_ocean)
        end

        @testset "Outline trigger styling" begin
            html = Therapy.render_to_string(SuiteDatePicker())
            @test occursin("border", html)
            @test occursin("border-warm-200", html)
            @test occursin("dark:border-warm-700", html)
            @test occursin("bg-warm-50", html)
        end

        @testset "JS datepicker module in suite.js" begin
            js = Suite.suite_js_source()
            @test occursin("_setupDatePicker", js)
            @test occursin("_openDatePicker", js)
            @test occursin("_closeDatePicker", js)
            @test occursin("_updateDatePickerDisplay", js)
            @test occursin("suite:calendar:select", js)
        end

        @testset "Display format helpers" begin
            # Single date
            display = Suite._format_display_date("2026-02-14", "single")
            @test occursin("Feb", display) || occursin("February", display)
            @test occursin("14", display)
            @test occursin("2026", display)

            # Range
            display_range = Suite._format_display_date("2026-02-10,2026-02-20", "range")
            @test occursin("Feb", display_range)
            @test occursin("10", display_range)
            @test occursin("20", display_range)

            # Multiple
            display_multi = Suite._format_display_date("2026-02-10,2026-02-20,2026-02-25", "multiple")
            @test occursin("3 dates selected", display_multi)

            # Empty
            display_empty = Suite._format_display_date("", "single")
            @test display_empty == ""
        end
    end

    @testset "SuiteDataTable" begin
        using Therapy
        using Suite

        # Sample data for tests
        test_data = [
            (name="Alice", email="alice@example.com", status="Active", amount=250.00),
            (name="Bob", email="bob@example.com", status="Inactive", amount=150.00),
            (name="Charlie", email="charlie@example.com", status="Active", amount=350.00),
            (name="Diana", email="diana@example.com", status="Active", amount=450.00),
            (name="Eve", email="eve@example.com", status="Inactive", amount=50.00),
        ]

        test_columns = [
            SuiteDataTableColumn("name", "Name"),
            SuiteDataTableColumn("email", "Email"),
            SuiteDataTableColumn("status", "Status"),
            SuiteDataTableColumn("amount", "Amount", align="right"),
        ]

        @testset "SuiteDataTableColumn struct" begin
            col = SuiteDataTableColumn("name", "Name")
            @test col.key == "name"
            @test col.header == "Name"
            @test col.sortable == true
            @test col.hideable == true
            @test col.cell === nothing
            @test col.align == "left"

            col2 = SuiteDataTableColumn("amount", "Amount", sortable=false, hideable=false, align="right")
            @test col2.sortable == false
            @test col2.hideable == false
            @test col2.align == "right"

            col3 = SuiteDataTableColumn("status" => "Status")
            @test col3.key == "status"
            @test col3.header == "Status"
        end

        @testset "Default rendering" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns))
            @test occursin("data-suite-datatable", html)
            @test occursin("<table", html)
            @test occursin("<thead", html)
            @test occursin("<tbody", html)
            @test occursin("Alice", html)
            @test occursin("alice@example.com", html)
            @test occursin("250.0", html)
        end

        @testset "Data store (JSON)" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns))
            @test occursin("data-suite-datatable-store", html)
            @test occursin("data-suite-datatable-columns", html)
            @test occursin("application/json", html)
            # All data should be in JSON store
            @test occursin("\"name\":\"Alice\"", html)
            @test occursin("\"name\":\"Eve\"", html)
        end

        @testset "Column headers" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns))
            @test occursin(">Name", html)
            @test occursin(">Email", html)
            @test occursin(">Status", html)
            @test occursin(">Amount", html)
        end

        @testset "Sort buttons on sortable columns" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, sortable=true))
            @test occursin("data-suite-datatable-sort", html)
            @test occursin("<svg", html)  # sort icon SVG

            # Non-sortable column
            cols_no_sort = [
                SuiteDataTableColumn("name", "Name", sortable=false),
                SuiteDataTableColumn("email", "Email"),
            ]
            html2 = Therapy.render_to_string(SuiteDataTable(test_data, cols_no_sort))
            # Email should still have sort button
            @test occursin("data-suite-datatable-sort", html2)
        end

        @testset "Sortable=false disables all sorting" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, sortable=false))
            # No sort buttons should be present — check for sort button SVG icon
            @test !occursin("data-suite-datatable-sort=\"", html)
        end

        @testset "Filter input" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, filterable=true))
            @test occursin("data-suite-datatable-filter", html)
            @test occursin("Filter...", html)

            html2 = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, filterable=true, filter_placeholder="Search..."))
            @test occursin("Search...", html2)

            html3 = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, filterable=false))
            @test !occursin("placeholder=\"Filter...\"", html3)
        end

        @testset "Pagination" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, paginated=true, page_size=2))
            @test occursin("data-suite-datatable-pagination", html)
            @test occursin("data-suite-datatable-prev", html)
            @test occursin("data-suite-datatable-next", html)
            @test occursin("Page 1 of 3", html)
            @test occursin("5 row(s) total", html)
            # Only first 2 rows rendered in body
            @test occursin("Alice", html)
            @test occursin("Bob", html)

            # No pagination
            html2 = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, paginated=false))
            @test !occursin("data-suite-datatable-pagination", html2)
            # All rows rendered
            @test occursin("Alice", html2)
            @test occursin("Eve", html2)
        end

        @testset "Row selection" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, selectable=true))
            @test occursin("data-suite-datatable-select-all", html)
            @test occursin("data-suite-datatable-select-row", html)
            @test occursin("Select all rows", html)
            @test occursin("Select row", html)
            @test occursin("row(s) selected", html)

            html2 = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, selectable=false))
            @test !occursin("data-suite-datatable-select-all", html2)
            @test !occursin("data-suite-datatable-select-row", html2)
        end

        @testset "Column visibility" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, column_visibility=true))
            @test occursin("data-suite-datatable-col-vis", html)
            @test occursin("data-suite-datatable-col-vis-trigger", html)
            @test occursin("data-suite-datatable-col-vis-content", html)
            @test occursin("Columns", html)
            @test occursin("data-suite-datatable-col-toggle", html)

            html2 = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, column_visibility=false))
            @test !occursin("data-suite-datatable-col-vis", html2)
        end

        @testset "Column alignment" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns))
            @test occursin("text-right", html)  # Amount column
            @test occursin("text-left", html)   # Name/Email/Status
        end

        @testset "Custom cell renderer" begin
            custom_cols = [
                SuiteDataTableColumn("name", "Name"),
                SuiteDataTableColumn("amount", "Amount",
                    cell=(val, row) -> Span(:class => "font-bold", "\$$(val)")),
            ]
            html = Therapy.render_to_string(SuiteDataTable(test_data, custom_cols))
            @test occursin("font-bold", html)
            @test occursin("\$250.0", html)
        end

        @testset "Empty data" begin
            html = Therapy.render_to_string(SuiteDataTable(NamedTuple[], test_columns))
            @test occursin("No results.", html)
        end

        @testset "Caption" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, caption="Test data"))
            @test occursin("<caption", html)
            @test occursin("Test data", html)
        end

        @testset "Theme support" begin
            html_default = Therapy.render_to_string(SuiteDataTable(test_data, test_columns))
            @test occursin("warm-", html_default)

            html_ocean = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, theme=:ocean))
            @test occursin("blue-", html_ocean) || occursin("warm-", html_ocean)
        end

        @testset "Dict data" begin
            dict_data = [
                Dict("name" => "Frank", "email" => "frank@example.com"),
                Dict("name" => "Grace", "email" => "grace@example.com"),
            ]
            dict_cols = [
                SuiteDataTableColumn("name", "Name"),
                SuiteDataTableColumn("email", "Email"),
            ]
            html = Therapy.render_to_string(SuiteDataTable(dict_data, dict_cols))
            @test occursin("Frank", html)
            @test occursin("grace@example.com", html)
        end

        @testset "Data serialization" begin
            json = Suite._dt_serialize_data(test_data, test_columns)
            @test occursin("\"name\":\"Alice\"", json)
            @test occursin("\"amount\":250.0", json)
            @test startswith(json, "[")
            @test endswith(json, "]")

            col_json = Suite._dt_serialize_columns(test_columns)
            @test occursin("\"key\":\"name\"", col_json)
            @test occursin("\"header\":\"Name\"", col_json)
            @test occursin("\"sortable\":true", col_json)
            @test occursin("\"align\":\"right\"", col_json)
        end

        @testset "JSON value escaping" begin
            @test Suite._dt_json_value("hello") == "\"hello\""
            @test Suite._dt_json_value(42) == "42"
            @test Suite._dt_json_value(3.14) == "3.14"
            @test Suite._dt_json_value(nothing) == "null"
            @test Suite._dt_json_value("has \"quotes\"") == "\"has \\\"quotes\\\"\""
            @test Suite._dt_json_value("back\\slash") == "\"back\\\\slash\""
        end

        @testset "Data access patterns" begin
            # NamedTuple access
            nt = (name="Test", value=42)
            @test Suite._dt_get_value(nt, "name") == "Test"
            @test Suite._dt_get_value(nt, "value") == 42

            # Dict access (String keys)
            d = Dict("name" => "Test2", "value" => 99)
            @test Suite._dt_get_value(d, "name") == "Test2"
            @test Suite._dt_get_value(d, "value") == 99

            # Dict access (Symbol keys)
            d2 = Dict(:name => "Test3")
            @test Suite._dt_get_value(d2, "name") == "Test3"

            # Missing key
            @test Suite._dt_get_value(nt, "missing") == ""
        end

        @testset "Page size config" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, page_size=3))
            @test occursin("data-suite-datatable-page-size=\"3\"", html)
            @test occursin("Page 1 of 2", html)

            html2 = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, page_size=10))
            @test occursin("Page 1 of 1", html2)
        end

        @testset "Non-hideable columns excluded from visibility toggle" begin
            cols = [
                SuiteDataTableColumn("name", "Name", hideable=false),
                SuiteDataTableColumn("email", "Email", hideable=true),
            ]
            html = Therapy.render_to_string(SuiteDataTable(test_data, cols, column_visibility=true))
            # Only Email should have a toggle checkbox
            @test occursin("data-suite-datatable-col-check=\"email\"", html)
            @test !occursin("data-suite-datatable-col-check=\"name\"", html)
        end

        @testset "Table structure" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns))
            @test occursin("overflow-x-auto", html)
            @test occursin("rounded-md", html)
            @test occursin("border", html)
            @test occursin("caption-bottom", html)
        end

        @testset "Row hover + selection styling" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns, selectable=true))
            @test occursin("hover:bg-warm-100/50", html)
            @test occursin("data-[state=selected]", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :DataTable)
            meta = Suite.COMPONENT_REGISTRY[:DataTable]
            @test meta.tier == :js_runtime
            @test :SuiteDataTable in meta.exports
            @test :SuiteDataTableColumn in meta.exports
            @test :Table in meta.suite_deps
        end

        @testset "Filter columns attribute" begin
            html = Therapy.render_to_string(SuiteDataTable(test_data, test_columns,
                filterable=true, filter_columns=["name", "email"]))
            @test occursin("data-suite-datatable-filter-columns=\"name,email\"", html)
        end

        @testset "Large dataset pagination" begin
            large_data = [(name="Person $i", email="p$i@test.com", status=i % 2 == 0 ? "Active" : "Inactive", amount=Float64(i * 10)) for i in 1:100]
            html = Therapy.render_to_string(SuiteDataTable(large_data, test_columns, page_size=10))
            @test occursin("Page 1 of 10", html)
            @test occursin("100 row(s) total", html)
        end
    end
end
