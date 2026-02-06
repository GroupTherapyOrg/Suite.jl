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
end
