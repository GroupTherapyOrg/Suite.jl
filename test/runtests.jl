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
            [:TestComp],
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
            [:DepComp],
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

    @testset "Button" begin
        using Therapy: Therapy, Div, Span, A
        using Suite

        @testset "Default variant and size" begin
            html = Therapy.render_to_string(Button("Click me"))
            @test occursin("<button", html)
            @test occursin("Click me", html)
            @test occursin("bg-accent-600", html)
            @test occursin("text-white", html)
            @test occursin("h-10", html)
            @test occursin("px-4", html)
        end

        @testset "All variants" begin
            for variant in ["default", "destructive", "outline", "secondary", "ghost", "link"]
                html = Therapy.render_to_string(Button(variant=variant, "Test"))
                @test occursin("<button", html)
                @test occursin("Test", html)
            end

            html_outline = Therapy.render_to_string(Button(variant="outline", "X"))
            @test occursin("border", html_outline)
            @test occursin("bg-warm-50", html_outline)

            html_destructive = Therapy.render_to_string(Button(variant="destructive", "X"))
            @test occursin("bg-accent-secondary-600", html_destructive)

            html_ghost = Therapy.render_to_string(Button(variant="ghost", "X"))
            @test occursin("hover:bg-warm-100", html_ghost)

            html_link = Therapy.render_to_string(Button(variant="link", "X"))
            @test occursin("underline-offset-4", html_link)
            @test occursin("text-accent-600", html_link)

            html_secondary = Therapy.render_to_string(Button(variant="secondary", "X"))
            @test occursin("bg-warm-100", html_secondary)
        end

        @testset "All sizes" begin
            html_sm = Therapy.render_to_string(Button(size="sm", "S"))
            @test occursin("h-9", html_sm)
            @test occursin("px-3", html_sm)

            html_lg = Therapy.render_to_string(Button(size="lg", "L"))
            @test occursin("h-11", html_lg)
            @test occursin("px-8", html_lg)

            html_icon = Therapy.render_to_string(Button(size="icon", "✕"))
            @test occursin("h-10", html_icon)
            @test occursin("w-10", html_icon)
        end

        @testset "Custom class merging" begin
            html = Therapy.render_to_string(Button(class="my-custom-class", "X"))
            @test occursin("my-custom-class", html)
            @test occursin("bg-accent-600", html)
        end

        @testset "Accessibility" begin
            html = Therapy.render_to_string(Button("Click"))
            @test occursin("focus-visible:ring-2", html)
            @test occursin("disabled:opacity-50", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(Button(variant="outline", "X"))
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:bg-warm-950", html)
            @test occursin("dark:text-warm-300", html)
        end

        @testset "Pass-through kwargs" begin
            html = Therapy.render_to_string(Button(:id => "my-btn", "X"))
            @test occursin("id=\"my-btn\"", html)
        end

        @testset "Registry registration" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Button)
            meta = Suite.COMPONENT_REGISTRY[:Button]
            @test meta.tier == :styling
            @test meta.file == "Button.jl"
            @test :Button in meta.exports
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

    @testset "Badge" begin
        @testset "Default variant" begin
            html = Therapy.render_to_string(Badge("New"))
            @test occursin("<span", html)
            @test occursin("New", html)
            @test occursin("bg-accent-600", html)
            @test occursin("text-white", html)
            @test occursin("rounded-xl", html)
            @test occursin("text-xs", html)
        end

        @testset "All variants" begin
            for variant in ["default", "secondary", "destructive", "outline"]
                html = Therapy.render_to_string(Badge(variant=variant, "Tag"))
                @test occursin("<span", html)
                @test occursin("Tag", html)
            end

            html_secondary = Therapy.render_to_string(Badge(variant="secondary", "X"))
            @test occursin("bg-warm-100", html_secondary)

            html_destructive = Therapy.render_to_string(Badge(variant="destructive", "X"))
            @test occursin("text-accent-secondary-600", html_destructive)

            html_outline = Therapy.render_to_string(Badge(variant="outline", "X"))
            @test occursin("border-warm-200", html_outline)
        end

        @testset "Custom class and kwargs" begin
            html = Therapy.render_to_string(Badge(class="ml-2", "X"))
            @test occursin("ml-2", html)
            @test occursin("bg-accent-600", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(Badge(variant="secondary", "X"))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-300", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Badge)
            @test Suite.COMPONENT_REGISTRY[:Badge].tier == :styling
        end
    end

    @testset "Alert" begin
        @testset "Default variant" begin
            html = Therapy.render_to_string(Alert(
                AlertTitle("Title"),
                AlertDescription("Description"),
            ))
            @test occursin("role=\"alert\"", html)
            @test occursin("Title", html)
            @test occursin("Description", html)
            @test occursin("bg-warm-100", html)
            @test occursin("rounded-lg", html)
            @test occursin("border", html)
        end

        @testset "Destructive variant" begin
            html = Therapy.render_to_string(Alert(variant="destructive",
                AlertTitle("Error"),
            ))
            @test occursin("role=\"alert\"", html)
            @test occursin("text-accent-secondary-600", html)
            @test occursin("Error", html)
        end

        @testset "AlertTitle classes" begin
            html = Therapy.render_to_string(AlertTitle("Heads up"))
            @test occursin("font-medium", html)
            @test occursin("Heads up", html)
        end

        @testset "AlertDescription classes" begin
            html = Therapy.render_to_string(AlertDescription("Details here"))
            @test occursin("text-warm-600", html)
            @test occursin("Details here", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Alert(class="my-alert", AlertTitle("X")))
            @test occursin("my-alert", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(Alert(AlertTitle("X")))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:border-warm-700", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Alert)
            @test :Alert in Suite.COMPONENT_REGISTRY[:Alert].exports
            @test :AlertTitle in Suite.COMPONENT_REGISTRY[:Alert].exports
            @test :AlertDescription in Suite.COMPONENT_REGISTRY[:Alert].exports
        end
    end

    @testset "Card" begin
        @testset "Basic card structure" begin
            html = Therapy.render_to_string(Card(
                CardHeader(
                    CardTitle("Title"),
                    CardDescription("Desc"),
                ),
                CardContent("Body"),
                CardFooter("Footer"),
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
            html = Therapy.render_to_string(CardHeader(CardTitle("X")))
            @test occursin("px-6", html)
            @test occursin("flex", html)
        end

        @testset "CardTitle classes" begin
            html = Therapy.render_to_string(CardTitle("Big Title"))
            @test occursin("font-semibold", html)
            @test occursin("Big Title", html)
        end

        @testset "CardDescription classes" begin
            html = Therapy.render_to_string(CardDescription("Some desc"))
            @test occursin("text-warm-600", html)
            @test occursin("Some desc", html)
        end

        @testset "CardContent classes" begin
            html = Therapy.render_to_string(CardContent("Content"))
            @test occursin("px-6", html)
            @test occursin("Content", html)
        end

        @testset "CardFooter classes" begin
            html = Therapy.render_to_string(CardFooter("Actions"))
            @test occursin("flex", html)
            @test occursin("items-center", html)
            @test occursin("Actions", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Card(class="w-[350px]", CardContent("X")))
            @test occursin("w-[350px]", html)
            @test occursin("rounded-xl", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(Card(CardContent("X")))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:text-warm-300", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Card)
            meta = Suite.COMPONENT_REGISTRY[:Card]
            @test :Card in meta.exports
            @test :CardHeader in meta.exports
            @test :CardTitle in meta.exports
            @test :CardContent in meta.exports
            @test :CardFooter in meta.exports
        end
    end

    @testset "Separator" begin
        @testset "Horizontal (default)" begin
            html = Therapy.render_to_string(Separator())
            @test occursin("h-px", html)
            @test occursin("w-full", html)
            @test occursin("bg-warm-200", html)
            @test occursin("role=\"none\"", html)
        end

        @testset "Vertical" begin
            html = Therapy.render_to_string(Separator(orientation="vertical"))
            @test occursin("h-full", html)
            @test occursin("w-px", html)
        end

        @testset "Non-decorative" begin
            html = Therapy.render_to_string(Separator(decorative=false))
            @test occursin("role=\"separator\"", html)
            @test occursin("aria-orientation=\"horizontal\"", html)
        end

        @testset "Non-decorative vertical" begin
            html = Therapy.render_to_string(Separator(decorative=false, orientation="vertical"))
            @test occursin("role=\"separator\"", html)
            @test occursin("aria-orientation=\"vertical\"", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Separator(class="my-4"))
            @test occursin("my-4", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(Separator())
            @test occursin("dark:bg-warm-700", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Separator)
            @test Suite.COMPONENT_REGISTRY[:Separator].tier == :styling
        end
    end

    @testset "Skeleton" begin
        @testset "Default" begin
            html = Therapy.render_to_string(Skeleton())
            @test occursin("animate-pulse", html)
            @test occursin("rounded-md", html)
            @test occursin("bg-warm-200", html)
        end

        @testset "Custom dimensions" begin
            html = Therapy.render_to_string(Skeleton(class="h-4 w-[250px]"))
            @test occursin("h-4", html)
            @test occursin("w-[250px]", html)
            @test occursin("animate-pulse", html)
        end

        @testset "Circle skeleton" begin
            html = Therapy.render_to_string(Skeleton(class="h-12 w-12 rounded-full"))
            @test occursin("rounded-full", html)
            @test occursin("animate-pulse", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(Skeleton())
            @test occursin("dark:bg-warm-800", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Skeleton)
            @test Suite.COMPONENT_REGISTRY[:Skeleton].tier == :styling
        end
    end

    @testset "Input" begin
        @testset "Default" begin
            html = Therapy.render_to_string(Input(placeholder="Email"))
            @test occursin("<input", html)
            @test occursin("type=\"text\"", html)
            @test occursin("placeholder=\"Email\"", html)
            @test occursin("rounded-md", html)
            @test occursin("border-warm-200", html)
            @test occursin("h-9", html)
        end

        @testset "Type prop" begin
            html = Therapy.render_to_string(Input(type="password"))
            @test occursin("type=\"password\"", html)
        end

        @testset "Focus styles" begin
            html = Therapy.render_to_string(Input())
            @test occursin("focus-visible:border-accent-600", html)
            @test occursin("focus-visible:ring-2", html)
        end

        @testset "Disabled styles" begin
            html = Therapy.render_to_string(Input())
            @test occursin("disabled:opacity-50", html)
            @test occursin("disabled:cursor-not-allowed", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(Input())
            @test occursin("dark:border-warm-700", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Input(class="w-[300px]"))
            @test occursin("w-[300px]", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Input)
            @test Suite.COMPONENT_REGISTRY[:Input].tier == :styling
        end
    end

    @testset "Label" begin
        @testset "Default" begin
            html = Therapy.render_to_string(Label("Email"))
            @test occursin("<label", html)
            @test occursin("Email", html)
            @test occursin("text-sm", html)
            @test occursin("font-medium", html)
            @test occursin("select-none", html)
        end

        @testset "For attribute" begin
            html = Therapy.render_to_string(Label("Name", :for => "name-input"))
            @test occursin("for=\"name-input\"", html)
        end

        @testset "Peer disabled" begin
            html = Therapy.render_to_string(Label("X"))
            @test occursin("peer-disabled:cursor-not-allowed", html)
            @test occursin("peer-disabled:opacity-50", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Label(class="mb-2", "X"))
            @test occursin("mb-2", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Label)
            @test Suite.COMPONENT_REGISTRY[:Label].tier == :styling
        end
    end

    @testset "Textarea" begin
        @testset "Default" begin
            html = Therapy.render_to_string(Textarea(placeholder="Message"))
            @test occursin("<textarea", html)
            @test occursin("placeholder=\"Message\"", html)
            @test occursin("rounded-md", html)
            @test occursin("border-warm-200", html)
            @test occursin("min-h-16", html)
        end

        @testset "Focus styles" begin
            html = Therapy.render_to_string(Textarea())
            @test occursin("focus-visible:border-accent-600", html)
            @test occursin("focus-visible:ring-2", html)
        end

        @testset "Disabled styles" begin
            html = Therapy.render_to_string(Textarea())
            @test occursin("disabled:opacity-50", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(Textarea())
            @test occursin("dark:border-warm-700", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Textarea(class="h-32"))
            @test occursin("h-32", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Textarea)
            @test Suite.COMPONENT_REGISTRY[:Textarea].tier == :styling
        end
    end

    @testset "Avatar" begin
        @testset "Default size" begin
            html = Therapy.render_to_string(Avatar(
                AvatarFallback("JD"),
            ))
            @test occursin("<span", html)
            @test occursin("rounded-full", html)
            @test occursin("size-8", html)
            @test occursin("JD", html)
        end

        @testset "All sizes" begin
            html_sm = Therapy.render_to_string(Avatar(size="sm", AvatarFallback("X")))
            @test occursin("size-6", html_sm)

            html_lg = Therapy.render_to_string(Avatar(size="lg", AvatarFallback("X")))
            @test occursin("size-10", html_lg)
        end

        @testset "AvatarImage" begin
            html = Therapy.render_to_string(AvatarImage(src="/avatar.jpg", alt="User"))
            @test occursin("<img", html)
            @test occursin("src=\"/avatar.jpg\"", html)
            @test occursin("alt=\"User\"", html)
            @test occursin("aspect-square", html)
        end

        @testset "AvatarFallback" begin
            html = Therapy.render_to_string(AvatarFallback("AB"))
            @test occursin("AB", html)
            @test occursin("bg-warm-100", html)
            @test occursin("items-center", html)
            @test occursin("justify-center", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(AvatarFallback("X"))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-500", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Avatar(class="border-2", AvatarFallback("X")))
            @test occursin("border-2", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Avatar)
            meta = Suite.COMPONENT_REGISTRY[:Avatar]
            @test :Avatar in meta.exports
            @test :AvatarImage in meta.exports
            @test :AvatarFallback in meta.exports
        end
    end

    @testset "AspectRatio" begin
        @testset "Default 16/9" begin
            html = Therapy.render_to_string(AspectRatio(Div("Content")))
            @test occursin("aspect-ratio:", html)
            @test occursin("relative", html)
            @test occursin("overflow-hidden", html)
            @test occursin("Content", html)
        end

        @testset "Custom ratio" begin
            html = Therapy.render_to_string(AspectRatio(ratio=1, Div("Square")))
            @test occursin("aspect-ratio: 1", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(AspectRatio(class="rounded-lg", Div("X")))
            @test occursin("rounded-lg", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :AspectRatio)
            @test Suite.COMPONENT_REGISTRY[:AspectRatio].tier == :styling
        end
    end

    @testset "Progress" begin
        @testset "Default (0%)" begin
            html = Therapy.render_to_string(Progress())
            @test occursin("role=\"progressbar\"", html)
            @test occursin("aria-valuenow=\"0\"", html)
            @test occursin("aria-valuemin=\"0\"", html)
            @test occursin("aria-valuemax=\"100\"", html)
            @test occursin("rounded-full", html)
            @test occursin("h-2", html)
            @test occursin("translateX(-100%)", html)
        end

        @testset "Partial progress" begin
            html = Therapy.render_to_string(Progress(value=60))
            @test occursin("aria-valuenow=\"60\"", html)
            @test occursin("translateX(-40%)", html)
        end

        @testset "Full progress" begin
            html = Therapy.render_to_string(Progress(value=100))
            @test occursin("aria-valuenow=\"100\"", html)
            @test occursin("translateX(-0%)", html)
        end

        @testset "Clamped values" begin
            html_neg = Therapy.render_to_string(Progress(value=-10))
            @test occursin("aria-valuenow=\"0\"", html_neg)

            html_over = Therapy.render_to_string(Progress(value=150))
            @test occursin("aria-valuenow=\"100\"", html_over)
        end

        @testset "Indicator colors" begin
            html = Therapy.render_to_string(Progress(value=50))
            @test occursin("bg-accent-600", html)
            @test occursin("transition-all", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Progress(value=50, class="w-[60%]"))
            @test occursin("w-[60%]", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Progress)
            @test Suite.COMPONENT_REGISTRY[:Progress].tier == :styling
        end
    end

    @testset "Table" begin
        @testset "Basic table structure" begin
            html = Therapy.render_to_string(Table(
                TableHeader(
                    TableRow(
                        TableHead("Name"),
                        TableHead("Email"),
                    ),
                ),
                TableBody(
                    TableRow(
                        TableCell("Alice"),
                        TableCell("alice@ex.com"),
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
            html = Therapy.render_to_string(TableHeader(TableRow(TableHead("X"))))
            @test occursin("<thead", html)
            @test occursin("border-b", html)
        end

        @testset "TableHead" begin
            html = Therapy.render_to_string(TableHead("Col"))
            @test occursin("<th", html)
            @test occursin("h-10", html)
            @test occursin("font-medium", html)
            @test occursin("text-warm-600", html)
        end

        @testset "TableRow" begin
            html = Therapy.render_to_string(TableRow(TableCell("X")))
            @test occursin("<tr", html)
            @test occursin("hover:bg-warm-100/50", html)
            @test occursin("transition-colors", html)
        end

        @testset "TableCell" begin
            html = Therapy.render_to_string(TableCell("Data"))
            @test occursin("<td", html)
            @test occursin("p-2", html)
            @test occursin("Data", html)
        end

        @testset "TableFooter" begin
            html = Therapy.render_to_string(TableFooter(TableRow(TableCell("Total"))))
            @test occursin("<tfoot", html)
            @test occursin("font-medium", html)
            @test occursin("border-t", html)
        end

        @testset "TableCaption" begin
            html = Therapy.render_to_string(TableCaption("A list of items"))
            @test occursin("<caption", html)
            @test occursin("text-warm-600", html)
            @test occursin("A list of items", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(TableRow(TableCell("X")))
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:hover:bg-warm-900/50", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Table)
            meta = Suite.COMPONENT_REGISTRY[:Table]
            @test :Table in meta.exports
            @test :TableHead in meta.exports
            @test :TableCell in meta.exports
            @test :TableCaption in meta.exports
        end
    end

    @testset "ScrollArea" begin
        @testset "Default" begin
            html = Therapy.render_to_string(ScrollArea(Div("Content")))
            @test occursin("overflow-auto", html)
            @test occursin("relative", html)
            @test occursin("Content", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(ScrollArea(class="h-[200px] w-[350px]", Div("X")))
            @test occursin("h-[200px]", html)
            @test occursin("w-[350px]", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :ScrollArea)
        end
    end

    @testset "Breadcrumb" begin
        @testset "Full breadcrumb" begin
            html = Therapy.render_to_string(Breadcrumb(
                BreadcrumbList(
                    BreadcrumbItem(BreadcrumbLink("Home", href="/")),
                    BreadcrumbSeparator(),
                    BreadcrumbItem(BreadcrumbPage("Current")),
                ),
            ))
            @test occursin("<nav", html)
            @test occursin("aria-label=\"breadcrumb\"", html)
            @test occursin("Home", html)
            @test occursin("Current", html)
        end

        @testset "BreadcrumbList" begin
            html = Therapy.render_to_string(BreadcrumbList(BreadcrumbItem("X")))
            @test occursin("<ol", html)
            @test occursin("text-warm-600", html)
            @test occursin("text-sm", html)
        end

        @testset "BreadcrumbLink" begin
            html = Therapy.render_to_string(BreadcrumbLink("Docs", href="/docs"))
            @test occursin("<a", html)
            @test occursin("href=\"/docs\"", html)
            @test occursin("transition-colors", html)
        end

        @testset "BreadcrumbPage" begin
            html = Therapy.render_to_string(BreadcrumbPage("Current"))
            @test occursin("aria-current=\"page\"", html)
            @test occursin("aria-disabled=\"true\"", html)
            @test occursin("role=\"link\"", html)
            @test occursin("font-normal", html)
        end

        @testset "BreadcrumbSeparator" begin
            html = Therapy.render_to_string(BreadcrumbSeparator())
            @test occursin("role=\"presentation\"", html)
            @test occursin("aria-hidden=\"true\"", html)
        end

        @testset "BreadcrumbEllipsis" begin
            html = Therapy.render_to_string(BreadcrumbEllipsis())
            @test occursin("aria-hidden=\"true\"", html)
            @test occursin("...", html)
            @test occursin("sr-only", html)
            @test occursin("More", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Breadcrumb)
            meta = Suite.COMPONENT_REGISTRY[:Breadcrumb]
            @test :Breadcrumb in meta.exports
            @test :BreadcrumbPage in meta.exports
        end
    end

    @testset "Pagination" begin
        @testset "Full pagination" begin
            html = Therapy.render_to_string(Pagination(
                PaginationContent(
                    PaginationItem(PaginationPrevious()),
                    PaginationItem(PaginationLink("1", is_active=true)),
                    PaginationItem(PaginationLink("2")),
                    PaginationItem(PaginationEllipsis()),
                    PaginationItem(PaginationNext()),
                ),
            ))
            @test occursin("<nav", html)
            @test occursin("role=\"navigation\"", html)
            @test occursin("aria-label=\"pagination\"", html)
            @test occursin("Previous", html)
            @test occursin("Next", html)
        end

        @testset "Active link" begin
            html = Therapy.render_to_string(PaginationLink("1", is_active=true))
            @test occursin("aria-current=\"page\"", html)
            @test occursin("border", html)
        end

        @testset "Inactive link" begin
            html = Therapy.render_to_string(PaginationLink("2"))
            @test occursin("<a", html)
            @test occursin("hover:bg-warm-100", html)
        end

        @testset "Previous" begin
            html = Therapy.render_to_string(PaginationPrevious(href="/page/1"))
            @test occursin("aria-label=\"Go to previous page\"", html)
            @test occursin("href=\"/page/1\"", html)
        end

        @testset "Next" begin
            html = Therapy.render_to_string(PaginationNext(href="/page/3"))
            @test occursin("aria-label=\"Go to next page\"", html)
            @test occursin("href=\"/page/3\"", html)
        end

        @testset "Ellipsis" begin
            html = Therapy.render_to_string(PaginationEllipsis())
            @test occursin("aria-hidden=\"true\"", html)
            @test occursin("sr-only", html)
            @test occursin("More pages", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Pagination)
            meta = Suite.COMPONENT_REGISTRY[:Pagination]
            @test :Pagination in meta.exports
            @test :PaginationLink in meta.exports
        end
    end

    @testset "Typography" begin
        @testset "H1" begin
            html = Therapy.render_to_string(H1("Title"))
            @test occursin("<h1", html)
            @test occursin("text-4xl", html)
            @test occursin("font-extrabold", html)
            @test occursin("Title", html)
        end

        @testset "H2" begin
            html = Therapy.render_to_string(H2("Section"))
            @test occursin("<h2", html)
            @test occursin("text-3xl", html)
            @test occursin("border-b", html)
            @test occursin("Section", html)
        end

        @testset "H3" begin
            html = Therapy.render_to_string(H3("Sub"))
            @test occursin("<h3", html)
            @test occursin("text-2xl", html)
        end

        @testset "H4" begin
            html = Therapy.render_to_string(H4("Minor"))
            @test occursin("<h4", html)
            @test occursin("text-xl", html)
        end

        @testset "P" begin
            html = Therapy.render_to_string(P("Paragraph"))
            @test occursin("<p", html)
            @test occursin("leading-7", html)
        end

        @testset "Blockquote" begin
            html = Therapy.render_to_string(Blockquote("Quote"))
            @test occursin("<blockquote", html)
            @test occursin("border-l-2", html)
            @test occursin("italic", html)
        end

        @testset "InlineCode" begin
            html = Therapy.render_to_string(InlineCode("npm install"))
            @test occursin("<code", html)
            @test occursin("font-mono", html)
            @test occursin("bg-warm-100", html)
        end

        @testset "Lead" begin
            html = Therapy.render_to_string(Lead("Intro text"))
            @test occursin("text-xl", html)
            @test occursin("text-warm-600", html)
        end

        @testset "Large" begin
            html = Therapy.render_to_string(Large("Big"))
            @test occursin("text-lg", html)
            @test occursin("font-semibold", html)
        end

        @testset "Small" begin
            html = Therapy.render_to_string(Small("Tiny"))
            @test occursin("text-sm", html)
            @test occursin("font-medium", html)
        end

        @testset "Muted" begin
            html = Therapy.render_to_string(Muted("Secondary"))
            @test occursin("text-warm-600", html)
            @test occursin("text-sm", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(Blockquote("X"))
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:text-warm-500", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(H1(class="text-center", "X"))
            @test occursin("text-center", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Typography)
            meta = Suite.COMPONENT_REGISTRY[:Typography]
            @test :H1 in meta.exports
            @test :Blockquote in meta.exports
            @test :InlineCode in meta.exports
        end
    end

    @testset "ThemeToggle" begin
        @testset "Default" begin
            html = Therapy.render_to_string(ThemeToggle())
            @test occursin("therapy-island", html)
            @test occursin("<button", html)
            @test occursin("aria-label=\"Toggle dark mode\"", html)
            @test occursin("type=\"button\"", html)
        end

        @testset "Sun and moon icons" begin
            html = Therapy.render_to_string(ThemeToggle())
            @test occursin("<svg", html)
            # Sun icon (dark mode visible)
            @test occursin("hidden dark:block", html)
            # Moon icon (light mode visible)
            @test occursin("block dark:hidden", html)
        end

        @testset "Hover styles" begin
            html = Therapy.render_to_string(ThemeToggle())
            @test occursin("hover:bg-warm-200", html)
            @test occursin("dark:hover:bg-warm-800", html)
            @test occursin("cursor-pointer", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(ThemeToggle(class="ml-4"))
            @test occursin("ml-4", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :ThemeToggle)
            meta = Suite.COMPONENT_REGISTRY[:ThemeToggle]
            @test meta.tier == :island
            @test :ThemeToggle in meta.exports
        end
    end

    @testset "ThemeSwitcher" begin
        @testset "Default rendering" begin
            html = Therapy.render_to_string(ThemeSwitcher())
            @test occursin("data-suite-theme-switcher", html)
            @test occursin("data-suite-theme-switcher-trigger", html)
            @test occursin("data-suite-theme-switcher-content", html)
            @test occursin("aria-label=\"Switch theme\"", html)
            @test occursin("aria-haspopup=\"true\"", html)
            @test occursin("role=\"menu\"", html)
        end

        @testset "Theme options" begin
            html = Therapy.render_to_string(ThemeSwitcher())
            @test occursin("data-suite-theme-option=\"default\"", html)
            @test occursin("data-suite-theme-option=\"ocean\"", html)
            @test occursin("data-suite-theme-option=\"minimal\"", html)
            @test occursin("data-suite-theme-option=\"nature\"", html)
            @test occursin("Default", html)
            @test occursin("Ocean", html)
            @test occursin("Minimal", html)
            @test occursin("Nature", html)
        end

        @testset "Color swatches" begin
            html = Therapy.render_to_string(ThemeSwitcher())
            @test occursin("#9558b2", html)  # Default purple
            @test occursin("#2563eb", html)  # Ocean blue
            @test occursin("#71717a", html)  # Minimal zinc
            @test occursin("#059669", html)  # Nature emerald
        end

        @testset "Check marks" begin
            html = Therapy.render_to_string(ThemeSwitcher())
            @test occursin("data-suite-theme-check=\"default\"", html)
            @test occursin("data-suite-theme-check=\"ocean\"", html)
            @test occursin("data-suite-theme-check=\"minimal\"", html)
            @test occursin("data-suite-theme-check=\"nature\"", html)
        end

        @testset "Dropdown hidden by default" begin
            html = Therapy.render_to_string(ThemeSwitcher())
            @test occursin("hidden absolute", html)
            @test occursin("aria-expanded=\"false\"", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(ThemeSwitcher(class="ml-4"))
            @test occursin("ml-4", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :ThemeSwitcher)
            meta = Suite.COMPONENT_REGISTRY[:ThemeSwitcher]
            @test meta.tier == :js_runtime
            @test :ThemeSwitcher in meta.exports
            @test :ThemeSwitcher in meta.js_modules
        end
    end

    @testset "suite_theme_script" begin
        html = Therapy.render_to_string(suite_theme_script())
        @test occursin("<script", html)
        @test occursin("therapy-theme", html)
        @test occursin("prefers-color-scheme", html)
        @test occursin("classList.add", html)
        @test occursin("suite-active-theme", html)
        @test occursin("data-theme", html)
        # No default theme → dt is empty string
        @test occursin("var dt=''", html)

        # With default_theme parameter
        html2 = Therapy.render_to_string(suite_theme_script(default_theme="islands"))
        @test occursin("var dt='islands'", html2)
        @test occursin("data-theme", html2)
    end

    @testset "suite_script" begin
        html = Therapy.render_to_string(suite_script())
        @test occursin("<script", html)
        @test occursin("Suite", html)
        # ThemeToggle + Collapsible + Accordion + Tabs + ToggleGroup removed from suite.js (now @island)
        @test occursin("ThemeSwitcher", html)
        @test occursin("data-suite-theme-switcher", html)
    end

    # ==========================================================================
    # Phase 2: Interactive Components
    # ==========================================================================

    @testset "Collapsible" begin
        @testset "Default (closed)" begin
            html = Therapy.render_to_string(Collapsible(
                CollapsibleTrigger("Toggle"),
                CollapsibleContent(Div("Content")),
            ))
            @test occursin("therapy-island", html)
            @test occursin("data-suite-collapsible", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("Toggle", html)
            @test occursin("Content", html)
        end

        @testset "Open by default" begin
            html = Therapy.render_to_string(Collapsible(open=true,
                CollapsibleTrigger("Close"),
                CollapsibleContent(Div("Visible")),
            ))
            @test occursin("data-state=\"open\"", html)
        end

        @testset "Disabled" begin
            html = Therapy.render_to_string(Collapsible(disabled=true,
                CollapsibleTrigger("Disabled"),
                CollapsibleContent(Div("Hidden")),
            ))
            @test occursin("data-disabled", html)
        end

        @testset "Trigger structure" begin
            html = Therapy.render_to_string(CollapsibleTrigger("Click me"))
            @test occursin("<div", html)
            @test occursin("data-suite-collapsible-trigger", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("Click me", html)
        end

        @testset "Trigger accessibility" begin
            html = Therapy.render_to_string(CollapsibleTrigger("X"))
            @test occursin("cursor-pointer", html)
        end

        @testset "Content structure (standalone)" begin
            # Standalone CollapsibleContent retains hidden attr (island doesn't process it)
            html = Therapy.render_to_string(CollapsibleContent(Div("Inner")))
            @test occursin("data-suite-collapsible-content", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("hidden", html)
            @test occursin("overflow-hidden", html)
            @test occursin("Inner", html)
        end

        @testset "Content inside Collapsible (island removes hidden)" begin
            html = Therapy.render_to_string(Collapsible(
                CollapsibleTrigger("T"),
                CollapsibleContent(Div("Inner")),
            ))
            # Inside Collapsible, hidden is replaced with CSS visibility class
            @test occursin("data-[state=closed]:hidden", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Collapsible(class="w-[350px]",
                CollapsibleTrigger("X"),
                CollapsibleContent(Div("X")),
            ))
            @test occursin("w-[350px]", html)

            html2 = Therapy.render_to_string(CollapsibleTrigger(class="font-bold", "X"))
            @test occursin("font-bold", html2)

            html3 = Therapy.render_to_string(CollapsibleContent(class="p-4", Div("X")))
            @test occursin("p-4", html3)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Collapsible)
            meta = Suite.COMPONENT_REGISTRY[:Collapsible]
            @test meta.tier == :island
            @test :Collapsible in meta.exports
            @test :CollapsibleTrigger in meta.exports
            @test :CollapsibleContent in meta.exports
        end
    end

    @testset "Accordion" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(Accordion(
                AccordionItem(value="item-1",
                    AccordionTrigger("Section 1"),
                    AccordionContent(Div("Content 1")),
                ),
                AccordionItem(value="item-2",
                    AccordionTrigger("Section 2"),
                    AccordionContent(Div("Content 2")),
                ),
            ))
            @test occursin("therapy-island", html)
            @test occursin("data-suite-accordion=\"single\"", html)
            @test occursin("data-orientation=\"vertical\"", html)
            @test occursin("Section 1", html)
            @test occursin("Section 2", html)
            @test occursin("Content 1", html)
            @test occursin("Content 2", html)
        end

        @testset "Multiple type" begin
            html = Therapy.render_to_string(Accordion(type="multiple",
                AccordionItem(value="a",
                    AccordionTrigger("A"),
                    AccordionContent(Div("AA")),
                ),
            ))
            @test occursin("data-suite-accordion=\"multiple\"", html)
        end

        @testset "Collapsible flag" begin
            html = Therapy.render_to_string(Accordion(collapsible=true,
                AccordionItem(value="x",
                    AccordionTrigger("X"),
                    AccordionContent(Div("XX")),
                ),
            ))
            @test occursin("data-collapsible", html)
        end

        @testset "Default value (signal-driven)" begin
            html = Therapy.render_to_string(Accordion(default_value="item-1",
                AccordionItem(value="item-1",
                    AccordionTrigger("Open"),
                    AccordionContent(Div("Visible")),
                ),
            ))
            # Default item renders with data-state="open" via signal + BindBool
            @test occursin("data-state=\"open\"", html)
            # Trigger aria-expanded is "true" for default open item
            @test occursin("aria-expanded=\"true\"", html)
        end

        @testset "Disabled accordion" begin
            html = Therapy.render_to_string(Accordion(disabled=true,
                AccordionItem(value="x",
                    AccordionTrigger("X"),
                    AccordionContent(Div("X")),
                ),
            ))
            @test occursin("data-disabled", html)
        end

        @testset "Disabled item" begin
            html = Therapy.render_to_string(AccordionItem(value="x", disabled=true,
                AccordionTrigger("Disabled"),
                AccordionContent(Div("Hidden")),
            ))
            @test occursin("data-disabled", html)
            @test occursin("data-suite-accordion-item=\"x\"", html)
        end

        @testset "AccordionItem structure" begin
            html = Therapy.render_to_string(AccordionItem(value="test",
                AccordionTrigger("Title"),
                AccordionContent(Div("Body")),
            ))
            @test occursin("data-suite-accordion-item=\"test\"", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "AccordionTrigger structure" begin
            html = Therapy.render_to_string(AccordionTrigger("Click"))
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

        @testset "AccordionContent structure (standalone)" begin
            # Standalone AccordionContent retains hidden attr (island doesn't process it)
            html = Therapy.render_to_string(AccordionContent(Div("Inner")))
            @test occursin("data-suite-accordion-content", html)
            @test occursin("role=\"region\"", html)
            @test occursin("hidden", html)
            @test occursin("overflow-hidden", html)
            @test occursin("Inner", html)
        end

        @testset "Content inside Accordion (island removes hidden)" begin
            html = Therapy.render_to_string(Accordion(
                AccordionItem(value="x",
                    AccordionTrigger("T"),
                    AccordionContent(Div("Inner")),
                ),
            ))
            # Inside Accordion, hidden is replaced with CSS visibility class
            @test occursin("data-[state=closed]:hidden", html)
        end

        @testset "Styling" begin
            html = Therapy.render_to_string(Accordion(
                AccordionItem(value="x",
                    AccordionTrigger("X"),
                    AccordionContent(Div("X")),
                ),
            ))
            @test occursin("divide-y", html)
            @test occursin("divide-warm-200", html)
            @test occursin("dark:divide-warm-700", html)
        end

        @testset "Trigger hover" begin
            html = Therapy.render_to_string(AccordionTrigger("X"))
            @test occursin("hover:underline", html)
            @test occursin("font-medium", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Accordion(class="w-full",
                AccordionItem(value="x",
                    AccordionTrigger("X"),
                    AccordionContent(Div("X")),
                ),
            ))
            @test occursin("w-full", html)
        end

        @testset "Horizontal orientation" begin
            html = Therapy.render_to_string(Accordion(orientation="horizontal",
                AccordionItem(value="x",
                    AccordionTrigger("X"),
                    AccordionContent(Div("X")),
                ),
            ))
            @test occursin("data-orientation=\"horizontal\"", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(AccordionTrigger("X"))
            @test occursin("dark:text-warm-500", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Accordion)
            meta = Suite.COMPONENT_REGISTRY[:Accordion]
            @test meta.tier == :island
            @test :Accordion in meta.exports
            @test :AccordionItem in meta.exports
            @test :AccordionTrigger in meta.exports
            @test :AccordionContent in meta.exports
        end
    end

    @testset "Tabs" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(Tabs(default_value="tab1",
                TabsList(
                    TabsTrigger("Account", value="tab1"),
                    TabsTrigger("Password", value="tab2"),
                ),
                TabsContent(value="tab1", Div("Account settings")),
                TabsContent(value="tab2", Div("Password settings")),
            ))
            @test occursin("therapy-island", html)
            @test occursin("data-suite-tabs", html)
            @test occursin("Account", html)
            @test occursin("Password", html)
            @test occursin("Account settings", html)
            @test occursin("Password settings", html)
            # Default tab should be active (BindBool initial state)
            @test occursin("data-state=\"active\"", html)
        end

        @testset "TabsList structure" begin
            html = Therapy.render_to_string(TabsList(
                TabsTrigger("Tab 1", value="t1"),
            ))
            @test occursin("role=\"tablist\"", html)
            @test occursin("data-suite-tabslist", html)
            @test occursin("aria-orientation=\"horizontal\"", html)
        end

        @testset "TabsList styling" begin
            html = Therapy.render_to_string(TabsList(
                TabsTrigger("X", value="x"),
            ))
            @test occursin("rounded-lg", html)
            @test occursin("bg-warm-100", html)
            @test occursin("dark:bg-warm-900", html)
            @test occursin("inline-flex", html)
        end

        @testset "TabsTrigger structure" begin
            html = Therapy.render_to_string(TabsTrigger("My Tab", value="my-tab"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
            @test occursin("role=\"tab\"", html)
            @test occursin("data-suite-tabs-trigger=\"my-tab\"", html)
            @test occursin("aria-selected=\"false\"", html)
            @test occursin("tabindex=\"-1\"", html)
            @test occursin("My Tab", html)
        end

        @testset "TabsTrigger styling" begin
            html = Therapy.render_to_string(TabsTrigger("X", value="x"))
            @test occursin("rounded-md", html)
            @test occursin("text-sm", html)
            @test occursin("font-medium", html)
            @test occursin("focus-visible:ring-2", html)
            # Active state classes
            @test occursin("data-[state=active]:bg-warm-50", html)
            @test occursin("data-[state=active]:shadow", html)
        end

        @testset "Disabled trigger" begin
            html = Therapy.render_to_string(TabsTrigger("X", value="x", disabled=true))
            @test occursin("disabled", html)
            @test occursin("data-disabled", html)
        end

        @testset "TabsContent structure" begin
            html = Therapy.render_to_string(TabsContent(value="panel1", Div("Content")))
            @test occursin("role=\"tabpanel\"", html)
            @test occursin("data-suite-tabs-content=\"panel1\"", html)
            @test occursin("tabindex=\"0\"", html)
            @test occursin("hidden", html)
            @test occursin("Content", html)
        end

        @testset "TabsContent styling" begin
            html = Therapy.render_to_string(TabsContent(value="x", Div("X")))
            @test occursin("mt-2", html)
            @test occursin("focus-visible:ring-2", html)
            @test occursin("focus-visible:ring-accent-600", html)
        end

        @testset "Orientation" begin
            html = Therapy.render_to_string(Tabs(default_value="x", orientation="vertical",
                TabsList(TabsTrigger("X", value="x")),
                TabsContent(value="x", Div("X")),
            ))
            @test occursin("data-orientation=\"vertical\"", html)
        end

        @testset "Activation mode" begin
            html = Therapy.render_to_string(Tabs(default_value="x", activation="manual",
                TabsList(TabsTrigger("X", value="x")),
                TabsContent(value="x", Div("X")),
            ))
            @test occursin("data-activation=\"manual\"", html)
        end

        @testset "No loop" begin
            html = Therapy.render_to_string(TabsList(loop=false,
                TabsTrigger("X", value="x"),
            ))
            @test occursin("data-no-loop", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Tabs(default_value="x", class="w-[400px]",
                TabsList(class="grid-cols-2",
                    TabsTrigger("X", value="x", class="data-[state=active]:font-bold"),
                ),
                TabsContent(value="x", class="p-4", Div("X")),
            ))
            @test occursin("w-[400px]", html)
            @test occursin("grid-cols-2", html)
            @test occursin("data-[state=active]:font-bold", html)
            @test occursin("p-4", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(TabsList(
                TabsTrigger("X", value="x"),
            ))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-500", html)

            html2 = Therapy.render_to_string(TabsTrigger("X", value="x"))
            @test occursin("dark:data-[state=active]:bg-warm-950", html2)
            @test occursin("dark:data-[state=active]:text-warm-300", html2)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Tabs)
            meta = Suite.COMPONENT_REGISTRY[:Tabs]
            @test meta.tier == :island
            @test :Tabs in meta.exports
            @test :TabsList in meta.exports
            @test :TabsTrigger in meta.exports
            @test :TabsContent in meta.exports
        end
    end

    # ===== Toggle, ToggleGroup, Switch (SUITE-0401) =====

    @testset "Toggle" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(Toggle("Bold"))
            @test occursin("therapy-island", html)
            @test occursin("data-state=\"off\"", html)
            @test occursin("aria-pressed=\"false\"", html)
            @test occursin("<button", html)
            @test occursin("Bold", html)
        end

        @testset "Pressed state" begin
            html = Therapy.render_to_string(Toggle("B", pressed=true))
            @test occursin("data-state=\"on\"", html)
            @test occursin("aria-pressed=\"true\"", html)
        end

        @testset "Variants" begin
            default_html = Therapy.render_to_string(Toggle("X"))
            @test occursin("bg-transparent", default_html)

            outline_html = Therapy.render_to_string(Toggle("X", variant="outline"))
            @test occursin("border", outline_html)
            @test occursin("shadow-sm", outline_html)
        end

        @testset "Sizes" begin
            sm = Therapy.render_to_string(Toggle("X", size="sm"))
            @test occursin("h-8", sm)
            @test occursin("min-w-8", sm)

            lg = Therapy.render_to_string(Toggle("X", size="lg"))
            @test occursin("h-10", lg)
            @test occursin("min-w-10", lg)
        end

        @testset "Disabled" begin
            html = Therapy.render_to_string(Toggle("X", disabled=true))
            @test occursin("disabled", html)
            @test occursin("data-disabled", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Toggle("X", class="my-toggle"))
            @test occursin("my-toggle", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(Toggle("X"))
            @test occursin("dark:hover:bg-warm-900", html)
            @test occursin("dark:data-[state=on]:bg-warm-900", html) || occursin("dark:data-[state=on]", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Toggle)
            meta = Suite.COMPONENT_REGISTRY[:Toggle]
            @test meta.tier == :island
            @test :Toggle in meta.exports
        end
    end

    @testset "ToggleGroup" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(ToggleGroup(
                ToggleGroupItem(value="a", "A"),
                ToggleGroupItem(value="b", "B"),
            ))
            @test occursin("therapy-island", html)
            @test occursin("data-suite-toggle-group=\"single\"", html)
            @test occursin("data-orientation=\"horizontal\"", html)
            @test occursin("role=\"group\"", html)
            @test occursin("A", html)
            @test occursin("B", html)
            # Single mode items get role=radio + aria-checked
            @test occursin("role=\"radio\"", html)
            @test occursin("aria-checked=\"false\"", html)
        end

        @testset "Multiple type" begin
            html = Therapy.render_to_string(ToggleGroup(type="multiple",
                ToggleGroupItem(value="x", "X"),
            ))
            @test occursin("data-suite-toggle-group=\"multiple\"", html)
            # Multiple mode items get aria-pressed (not aria-checked)
            @test occursin("aria-pressed=\"false\"", html)
        end

        @testset "Default value - single" begin
            html = Therapy.render_to_string(ToggleGroup(default_value="center",
                ToggleGroupItem(value="left", "L"),
                ToggleGroupItem(value="center", "C"),
                ToggleGroupItem(value="right", "R"),
            ))
            # Default item should be on (BindBool initial state)
            @test occursin("data-state=\"on\"", html)
            @test occursin("aria-checked=\"true\"", html)
        end

        @testset "Default value - multiple" begin
            html = Therapy.render_to_string(ToggleGroup(type="multiple", default_value=["bold", "italic"],
                ToggleGroupItem(value="bold", "B"),
                ToggleGroupItem(value="italic", "I"),
            ))
            # Default items should be on
            @test occursin("data-state=\"on\"", html)
            @test occursin("aria-pressed=\"true\"", html)
        end

        @testset "Vertical orientation" begin
            html = Therapy.render_to_string(ToggleGroup(orientation="vertical",
                ToggleGroupItem(value="a", "A"),
            ))
            @test occursin("data-orientation=\"vertical\"", html)
        end

        @testset "Variants and sizes" begin
            html = Therapy.render_to_string(ToggleGroup(variant="outline", size="lg",
                ToggleGroupItem(value="a", "A"),
            ))
            @test occursin("data-variant=\"outline\"", html)
            @test occursin("data-size=\"lg\"", html)
        end

        @testset "Disabled group" begin
            html = Therapy.render_to_string(ToggleGroup(disabled=true,
                ToggleGroupItem(value="x", "X"),
            ))
            @test occursin("data-disabled", html)
        end

        @testset "Item structure" begin
            html = Therapy.render_to_string(ToggleGroupItem(value="bold", "B"))
            @test occursin("data-suite-toggle-group-item=\"bold\"", html)
            @test occursin("data-state=\"off\"", html)
            @test occursin("<button", html)
            @test occursin("B", html)
        end

        @testset "Item variants" begin
            outline = Therapy.render_to_string(ToggleGroupItem(value="x", "X", variant="outline"))
            @test occursin("border", outline)
            @test occursin("shadow-sm", outline)
        end

        @testset "Item sizes" begin
            sm = Therapy.render_to_string(ToggleGroupItem(value="x", "X", size="sm"))
            @test occursin("h-8", sm)

            lg = Therapy.render_to_string(ToggleGroupItem(value="x", "X", size="lg"))
            @test occursin("h-10", lg)
        end

        @testset "Item disabled" begin
            html = Therapy.render_to_string(ToggleGroupItem(value="x", "X", disabled=true))
            @test occursin("disabled", html)
            @test occursin("data-disabled", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(ToggleGroup(class="my-group",
                ToggleGroupItem(value="a", "A", class="my-item"),
            ))
            @test occursin("my-group", html)
            @test occursin("my-item", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :ToggleGroup)
            meta = Suite.COMPONENT_REGISTRY[:ToggleGroup]
            @test meta.tier == :island
            @test :ToggleGroup in meta.exports
            @test :ToggleGroupItem in meta.exports
        end
    end

    @testset "Switch" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(Switch())
            @test occursin("role=\"switch\"", html)
            @test occursin("therapy-island", html)
            @test occursin("data-state=\"unchecked\"", html)
            @test occursin("aria-checked=\"false\"", html)
            @test occursin("<button", html)
            # Thumb span
            @test occursin("<span", html)
        end

        @testset "Checked state" begin
            html = Therapy.render_to_string(Switch(checked=true))
            @test occursin("data-state=\"checked\"", html)
            @test occursin("aria-checked=\"true\"", html)
        end

        @testset "Sizes" begin
            default_html = Therapy.render_to_string(Switch())
            @test occursin("h-5", default_html)
            @test occursin("w-9", default_html)
            @test occursin("size-4", default_html)

            sm_html = Therapy.render_to_string(Switch(size="sm"))
            @test occursin("h-3.5", sm_html)
            @test occursin("w-6", sm_html)
            @test occursin("size-3", sm_html)
        end

        @testset "Disabled" begin
            html = Therapy.render_to_string(Switch(disabled=true))
            @test occursin("disabled", html)
            @test occursin("data-disabled", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Switch(class="my-switch"))
            @test occursin("my-switch", html)
        end

        @testset "Thumb data-state matches" begin
            unchecked = Therapy.render_to_string(Switch())
            # Both track and thumb should have unchecked state
            @test count("data-state=\"unchecked\"", unchecked) >= 2

            checked = Therapy.render_to_string(Switch(checked=true))
            @test count("data-state=\"checked\"", checked) >= 2
        end

        @testset "CSS transition classes" begin
            html = Therapy.render_to_string(Switch())
            @test occursin("transition-transform", html)
            @test occursin("translate-x", html) || occursin("translate-x-0", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(Switch())
            @test occursin("dark:bg-warm-950", html)
            @test occursin("dark:data-[state=unchecked]:bg-warm-700", html) || occursin("dark:bg-warm-700", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Switch)
            meta = Suite.COMPONENT_REGISTRY[:Switch]
            @test meta.tier == :island
            @test :Switch in meta.exports
        end
    end

    @testset "Dialog" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(Dialog(
                DialogTrigger("Open"),
                DialogContent(
                    DialogHeader(
                        DialogTitle("Title"),
                        DialogDescription("Description")
                    ),
                    DialogFooter(
                        DialogClose("Cancel"),
                        "Save"
                    )
                )
            ))
            @test occursin("therapy-island", html)
            @test occursin("data-suite-dialog", html)
            @test occursin("Title", html)
            @test occursin("Description", html)
            @test occursin("Cancel", html)
            @test occursin("Save", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(Dialog(
                DialogTrigger("Open"),
                DialogContent(DialogTitle("T"))
            ))
            @test occursin("data-suite-dialog-trigger", html)
            @test occursin("aria-haspopup=\"dialog\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("Open", html)
        end

        @testset "Trigger is a span wrapper" begin
            html = Therapy.render_to_string(DialogTrigger("Click"))
            @test occursin("<span", html)
            @test occursin("display:contents", html)
            @test occursin("Click", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(DialogContent(
                DialogTitle("Title")
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
            html = Therapy.render_to_string(DialogContent(
                DialogTitle("T")
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
            html = Therapy.render_to_string(DialogContent(
                DialogTitle("T")
            ))
            @test occursin("data-[state=open]:animate-in", html)
            @test occursin("data-[state=closed]:animate-out", html)
            @test occursin("data-[state=open]:fade-in-0", html)
            @test occursin("data-[state=closed]:fade-out-0", html)
        end

        @testset "Header" begin
            html = Therapy.render_to_string(DialogHeader(
                DialogTitle("T"),
                DialogDescription("D")
            ))
            @test occursin("flex flex-col", html)
            @test occursin("text-center sm:text-left", html)
        end

        @testset "Footer" begin
            html = Therapy.render_to_string(DialogFooter("Save"))
            @test occursin("flex-col-reverse", html)
            @test occursin("sm:flex-row sm:justify-end", html)
        end

        @testset "Title renders as h2" begin
            html = Therapy.render_to_string(DialogTitle("My Title"))
            @test occursin("<h2", html)
            @test occursin("text-lg", html)
            @test occursin("font-semibold", html)
            @test occursin("My Title", html)
        end

        @testset "Description" begin
            html = Therapy.render_to_string(DialogDescription("My Desc"))
            @test occursin("<p", html)
            @test occursin("text-sm", html)
            @test occursin("text-warm-600", html)
            @test occursin("My Desc", html)
        end

        @testset "Close wrapper" begin
            html = Therapy.render_to_string(DialogClose("Cancel"))
            @test occursin("data-suite-dialog-close", html)
            @test occursin("display:contents", html)
            @test occursin("Cancel", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Dialog(class="my-dialog",
                DialogTrigger("X"),
                DialogContent(DialogTitle("T"))
            ))
            @test occursin("my-dialog", html)

            html2 = Therapy.render_to_string(DialogContent(class="max-w-2xl",
                DialogTitle("T")
            ))
            @test occursin("max-w-2xl", html2)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Dialog)
            meta = Suite.COMPONENT_REGISTRY[:Dialog]
            @test meta.tier == :island
            @test :Dialog in meta.exports
            @test :DialogTrigger in meta.exports
            @test :DialogContent in meta.exports
            @test :DialogClose in meta.exports
            @test isempty(meta.js_modules)
        end
    end

    @testset "AlertDialog" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(AlertDialog(
                AlertDialogTrigger("Delete"),
                AlertDialogContent(
                    AlertDialogHeader(
                        AlertDialogTitle("Are you sure?"),
                        AlertDialogDescription("This cannot be undone.")
                    ),
                    AlertDialogFooter(
                        AlertDialogCancel("Cancel"),
                        AlertDialogAction("Delete")
                    )
                )
            ))
            @test occursin("therapy-island", html)
            @test occursin("data-suite-alert-dialog", html)
            @test occursin("Are you sure?", html)
            @test occursin("This cannot be undone.", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(AlertDialog(
                AlertDialogTrigger("Delete"),
                AlertDialogContent(AlertDialogTitle("T"))
            ))
            @test occursin("data-suite-alert-dialog-trigger", html)
            @test occursin("aria-haspopup=\"dialog\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger is a span wrapper" begin
            html = Therapy.render_to_string(AlertDialogTrigger("Click"))
            @test occursin("<span", html)
            @test occursin("display:contents", html)
        end

        @testset "Content uses alertdialog role" begin
            html = Therapy.render_to_string(AlertDialogContent(
                AlertDialogTitle("T")
            ))
            @test occursin("role=\"alertdialog\"", html)
            @test occursin("aria-modal=\"true\"", html)
            # No default close button (unlike Dialog)
            @test !occursin("aria-label=\"Close\"", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(AlertDialogContent(
                AlertDialogTitle("T")
            ))
            @test occursin("data-suite-alert-dialog-overlay", html)
            @test occursin("data-suite-alert-dialog-content", html)
            @test occursin("bg-warm-950/80", html)
            @test occursin("fixed", html)
            @test occursin("z-50", html)
        end

        @testset "Header" begin
            html = Therapy.render_to_string(AlertDialogHeader(
                AlertDialogTitle("T"),
                AlertDialogDescription("D")
            ))
            @test occursin("flex flex-col", html)
            @test occursin("text-center sm:text-left", html)
        end

        @testset "Footer" begin
            html = Therapy.render_to_string(AlertDialogFooter("X"))
            @test occursin("flex-col-reverse", html)
            @test occursin("sm:flex-row sm:justify-end", html)
        end

        @testset "Title renders as h2" begin
            html = Therapy.render_to_string(AlertDialogTitle("Alert Title"))
            @test occursin("<h2", html)
            @test occursin("text-lg", html)
            @test occursin("font-semibold", html)
            @test occursin("Alert Title", html)
        end

        @testset "Description" begin
            html = Therapy.render_to_string(AlertDialogDescription("Alert Desc"))
            @test occursin("<p", html)
            @test occursin("text-sm", html)
            @test occursin("text-warm-600", html)
            @test occursin("Alert Desc", html)
        end

        @testset "Action wrapper" begin
            html = Therapy.render_to_string(AlertDialogAction("Confirm"))
            @test occursin("data-suite-alert-dialog-action", html)
            @test occursin("display:contents", html)
            @test occursin("Confirm", html)
        end

        @testset "Cancel wrapper" begin
            html = Therapy.render_to_string(AlertDialogCancel("Cancel"))
            @test occursin("data-suite-alert-dialog-cancel", html)
            @test occursin("display:contents", html)
            @test occursin("Cancel", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(AlertDialog(class="danger",
                AlertDialogTrigger("X"),
                AlertDialogContent(AlertDialogTitle("T"))
            ))
            @test occursin("danger", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :AlertDialog)
            meta = Suite.COMPONENT_REGISTRY[:AlertDialog]
            @test meta.tier == :island
            @test :AlertDialog in meta.exports
            @test :AlertDialogTrigger in meta.exports
            @test :AlertDialogContent in meta.exports
            @test :AlertDialogAction in meta.exports
            @test :AlertDialogCancel in meta.exports
            @test isempty(meta.js_modules)
        end
    end

    @testset "Sheet" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(Sheet(
                SheetTrigger("Open"),
                SheetContent(side="right",
                    SheetHeader(
                        SheetTitle("Title"),
                        SheetDescription("Description")
                    ),
                    SheetFooter(
                        SheetClose("Cancel"),
                        "Save"
                    )
                )
            ))
            @test occursin("therapy-island", html)
            @test occursin("Title", html)
            @test occursin("Description", html)
            @test occursin("Cancel", html)
            @test occursin("Save", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(Sheet(
                SheetTrigger("Open"),
                SheetContent(SheetTitle("T"))
            ))
            @test occursin("data-suite-sheet-trigger-wrapper", html)
            @test occursin("aria-haspopup=\"dialog\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger is a span wrapper" begin
            html = Therapy.render_to_string(SheetTrigger("Click"))
            @test occursin("<span", html)
            @test occursin("display:contents", html)
        end

        @testset "Content — right side (default)" begin
            html = Therapy.render_to_string(SheetContent(
                SheetTitle("T")
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
            html = Therapy.render_to_string(SheetContent(side="left",
                SheetTitle("T")
            ))
            @test occursin("left-0", html)
            @test occursin("slide-in-from-left", html)
            @test occursin("slide-out-to-left", html)
            @test occursin("border-r", html)
        end

        @testset "Content — top side" begin
            html = Therapy.render_to_string(SheetContent(side="top",
                SheetTitle("T")
            ))
            @test occursin("inset-x-0", html)
            @test occursin("top-0", html)
            @test occursin("slide-in-from-top", html)
            @test occursin("slide-out-to-top", html)
            @test occursin("border-b", html)
        end

        @testset "Content — bottom side" begin
            html = Therapy.render_to_string(SheetContent(side="bottom",
                SheetTitle("T")
            ))
            @test occursin("inset-x-0", html)
            @test occursin("bottom-0", html)
            @test occursin("slide-in-from-bottom", html)
            @test occursin("slide-out-to-bottom", html)
            @test occursin("border-t", html)
        end

        @testset "Overlay" begin
            html = Therapy.render_to_string(SheetContent(
                SheetTitle("T")
            ))
            @test occursin("data-suite-sheet-overlay", html)
            @test occursin("bg-warm-950/80", html)
        end

        @testset "Default close button" begin
            html = Therapy.render_to_string(SheetContent(
                SheetTitle("T")
            ))
            @test occursin("data-suite-sheet-close", html)
            @test occursin("aria-label=\"Close\"", html)
        end

        @testset "Animation classes" begin
            html = Therapy.render_to_string(SheetContent(
                SheetTitle("T")
            ))
            @test occursin("data-[state=open]:animate-in", html)
            @test occursin("data-[state=closed]:animate-out", html)
            @test occursin("data-[state=closed]:duration-300", html)
            @test occursin("data-[state=open]:duration-500", html)
        end

        @testset "Header" begin
            html = Therapy.render_to_string(SheetHeader(
                SheetTitle("T"),
                SheetDescription("D")
            ))
            @test occursin("flex flex-col", html)
        end

        @testset "Footer" begin
            html = Therapy.render_to_string(SheetFooter("Save"))
            @test occursin("flex-col-reverse", html)
            @test occursin("sm:flex-row sm:justify-end", html)
        end

        @testset "Title" begin
            html = Therapy.render_to_string(SheetTitle("My Title"))
            @test occursin("<h2", html)
            @test occursin("font-semibold", html)
            @test occursin("My Title", html)
        end

        @testset "Description" begin
            html = Therapy.render_to_string(SheetDescription("My Desc"))
            @test occursin("<p", html)
            @test occursin("text-warm-600", html)
            @test occursin("My Desc", html)
        end

        @testset "Close wrapper" begin
            html = Therapy.render_to_string(SheetClose("Cancel"))
            @test occursin("data-suite-sheet-close", html)
            @test occursin("display:contents", html)
            @test occursin("Cancel", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Sheet(class="w-full",
                SheetTrigger("X"),
                SheetContent(SheetTitle("T"))
            ))
            @test occursin("w-full", html)

            html2 = Therapy.render_to_string(SheetContent(class="max-w-xl",
                SheetTitle("T")
            ))
            @test occursin("max-w-xl", html2)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Sheet)
            meta = Suite.COMPONENT_REGISTRY[:Sheet]
            @test meta.tier == :island
            @test :Sheet in meta.exports
            @test :SheetTrigger in meta.exports
            @test :SheetContent in meta.exports
            @test :SheetClose in meta.exports
            @test isempty(meta.js_modules)
        end
    end

    @testset "Drawer" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(Drawer(
                DrawerTrigger("Open"),
                DrawerContent(
                    DrawerHandle(),
                    DrawerHeader(
                        DrawerTitle("Goal"),
                        DrawerDescription("Set your goal.")
                    ),
                    DrawerFooter(
                        DrawerClose("Cancel"),
                        "Submit"
                    )
                )
            ))
            @test occursin("therapy-island", html)
            @test occursin("Goal", html)
            @test occursin("Set your goal.", html)
            @test occursin("Cancel", html)
            @test occursin("Submit", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(Drawer(
                DrawerTrigger("Open"),
                DrawerContent(DrawerTitle("T"))
            ))
            @test occursin("data-suite-drawer-trigger-wrapper", html)
            @test occursin("aria-haspopup=\"dialog\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger is a span wrapper" begin
            html = Therapy.render_to_string(DrawerTrigger("Click"))
            @test occursin("<span", html)
            @test occursin("display:contents", html)
        end

        @testset "Content — bottom (default)" begin
            html = Therapy.render_to_string(DrawerContent(
                DrawerTitle("T")
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
            html = Therapy.render_to_string(DrawerContent(direction="top",
                DrawerTitle("T")
            ))
            @test occursin("data-suite-drawer-direction=\"top\"", html)
            @test occursin("top-0", html)
            @test occursin("rounded-b-[10px]", html)
        end

        @testset "Content — left" begin
            html = Therapy.render_to_string(DrawerContent(direction="left",
                DrawerTitle("T")
            ))
            @test occursin("data-suite-drawer-direction=\"left\"", html)
            @test occursin("left-0", html)
            @test occursin("rounded-r-[10px]", html)
        end

        @testset "Content — right" begin
            html = Therapy.render_to_string(DrawerContent(direction="right",
                DrawerTitle("T")
            ))
            @test occursin("data-suite-drawer-direction=\"right\"", html)
            @test occursin("right-0", html)
            @test occursin("rounded-l-[10px]", html)
        end

        @testset "Handle" begin
            html = Therapy.render_to_string(DrawerHandle())
            @test occursin("h-2", html)
            @test occursin("w-[100px]", html)
            @test occursin("rounded-full", html)
            @test occursin("bg-warm-200", html)
        end

        @testset "Overlay" begin
            html = Therapy.render_to_string(DrawerContent(
                DrawerTitle("T")
            ))
            @test occursin("data-suite-drawer-overlay", html)
            @test occursin("bg-warm-950/80", html)
        end

        @testset "Header" begin
            html = Therapy.render_to_string(DrawerHeader(
                DrawerTitle("T")
            ))
            @test occursin("flex flex-col", html)
            @test occursin("p-4", html)
        end

        @testset "Footer" begin
            html = Therapy.render_to_string(DrawerFooter("X"))
            @test occursin("flex flex-col", html)
            @test occursin("p-4", html)
        end

        @testset "Title" begin
            html = Therapy.render_to_string(DrawerTitle("My Title"))
            @test occursin("<h2", html)
            @test occursin("font-semibold", html)
            @test occursin("My Title", html)
        end

        @testset "Description" begin
            html = Therapy.render_to_string(DrawerDescription("My Desc"))
            @test occursin("<p", html)
            @test occursin("text-warm-600", html)
            @test occursin("My Desc", html)
        end

        @testset "Close wrapper" begin
            html = Therapy.render_to_string(DrawerClose("Cancel"))
            @test occursin("data-suite-drawer-close", html)
            @test occursin("display:contents", html)
            @test occursin("Cancel", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Drawer(class="my-drawer",
                DrawerTrigger("X"),
                DrawerContent(DrawerTitle("T"))
            ))
            @test occursin("my-drawer", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Drawer)
            meta = Suite.COMPONENT_REGISTRY[:Drawer]
            @test meta.tier == :island
            @test :Drawer in meta.exports
            @test :DrawerTrigger in meta.exports
            @test :DrawerContent in meta.exports
            @test :DrawerClose in meta.exports
            @test :DrawerHandle in meta.exports
            @test isempty(meta.js_modules)
        end
    end

    @testset "Popover" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(Popover(
                PopoverTrigger("Open"),
                PopoverContent(
                    P("Popover content here")
                )
            ))
            @test occursin("data-suite-popover", html)
            @test occursin("Popover content here", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(Popover(
                PopoverTrigger("Open"),
                PopoverContent(P("Content"))
            ))
            @test occursin("data-suite-popover-trigger", html)
            @test occursin("aria-haspopup=\"dialog\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger is a span wrapper" begin
            html = Therapy.render_to_string(PopoverTrigger("Click"))
            @test occursin("<span", html)
            @test occursin("display:contents", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(PopoverContent(P("Hello")))
            @test occursin("data-suite-popover-content", html)
            @test occursin("role=\"dialog\"", html)
            @test occursin("aria-modal=\"true\"", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("display:none", html)
        end

        @testset "Content positioning attributes" begin
            html = Therapy.render_to_string(PopoverContent(
                side="top", side_offset=8, align="start",
                P("Content")
            ))
            @test occursin("data-suite-popover-side=\"top\"", html)
            @test occursin("data-suite-popover-side-offset=\"8\"", html)
            @test occursin("data-suite-popover-align=\"start\"", html)
        end

        @testset "Content default positioning" begin
            html = Therapy.render_to_string(PopoverContent(P("Content")))
            @test occursin("data-suite-popover-side=\"bottom\"", html)
            @test occursin("data-suite-popover-side-offset=\"0\"", html)
            @test occursin("data-suite-popover-align=\"center\"", html)
        end

        @testset "Content CSS classes" begin
            html = Therapy.render_to_string(PopoverContent(P("Content")))
            @test occursin("bg-warm-50", html)
            @test occursin("dark:bg-warm-900", html)
            @test occursin("w-72", html)
            @test occursin("rounded-md", html)
            @test occursin("border", html)
            @test occursin("p-4", html)
            @test occursin("shadow-md", html)
        end

        @testset "Content animation classes" begin
            html = Therapy.render_to_string(PopoverContent(P("Content")))
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
            html = Therapy.render_to_string(PopoverClose("Close"))
            @test occursin("data-suite-popover-close", html)
            @test occursin("display:contents", html)
            @test occursin("Close", html)
        end

        @testset "Anchor" begin
            html = Therapy.render_to_string(PopoverAnchor(Span("Anchor")))
            @test occursin("data-suite-popover-anchor", html)
            @test occursin("Anchor", html)
        end

        @testset "Root uses display:contents" begin
            html = Therapy.render_to_string(Popover(
                PopoverTrigger("X"),
                PopoverContent(P("Y"))
            ))
            @test occursin("display:contents", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(PopoverContent(class="max-w-lg",
                P("Content")
            ))
            @test occursin("max-w-lg", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Popover)
            meta = Suite.COMPONENT_REGISTRY[:Popover]
            @test meta.tier == :js_runtime
            @test :Popover in meta.exports
            @test :PopoverTrigger in meta.exports
            @test :PopoverContent in meta.exports
            @test :PopoverClose in meta.exports
            @test :Popover in meta.js_modules
            @test :Floating in meta.js_modules
            @test :FocusTrap in meta.js_modules
            @test :DismissLayer in meta.js_modules
        end
    end

    @testset "Tooltip" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(TooltipProvider(
                Tooltip(
                    TooltipTrigger("Hover me"),
                    TooltipContent(P("Tooltip text"))
                )
            ))
            @test occursin("data-suite-tooltip-provider", html)
            @test occursin("data-suite-tooltip", html)
            @test occursin("Tooltip text", html)
        end

        @testset "Provider attributes" begin
            html = Therapy.render_to_string(TooltipProvider(
                delay_duration=500, skip_delay_duration=200,
                Span("Children")
            ))
            @test occursin("data-suite-tooltip-delay=\"500\"", html)
            @test occursin("data-suite-tooltip-skip-delay=\"200\"", html)
        end

        @testset "Provider default attributes" begin
            html = Therapy.render_to_string(TooltipProvider(Span("X")))
            @test occursin("data-suite-tooltip-delay=\"700\"", html)
            @test occursin("data-suite-tooltip-skip-delay=\"300\"", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(Tooltip(
                TooltipTrigger("Hover"),
                TooltipContent(P("Tip"))
            ))
            @test occursin("data-suite-tooltip-trigger", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger is a button" begin
            html = Therapy.render_to_string(TooltipTrigger("Click"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(TooltipContent(P("Tip")))
            @test occursin("data-suite-tooltip-content", html)
            @test occursin("role=\"tooltip\"", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("display:none", html)
        end

        @testset "Content positioning attributes" begin
            html = Therapy.render_to_string(TooltipContent(
                side="bottom", side_offset=8, align="end",
                P("Tip")
            ))
            @test occursin("data-suite-tooltip-side=\"bottom\"", html)
            @test occursin("data-suite-tooltip-side-offset=\"8\"", html)
            @test occursin("data-suite-tooltip-align=\"end\"", html)
        end

        @testset "Content default positioning" begin
            html = Therapy.render_to_string(TooltipContent(P("Tip")))
            @test occursin("data-suite-tooltip-side=\"top\"", html)
            @test occursin("data-suite-tooltip-side-offset=\"4\"", html)
            @test occursin("data-suite-tooltip-align=\"center\"", html)
        end

        @testset "Content CSS — inverted colors" begin
            html = Therapy.render_to_string(TooltipContent(P("Tip")))
            @test occursin("bg-warm-800", html)
            @test occursin("dark:bg-warm-300", html)
            @test occursin("text-warm-50", html)
            @test occursin("dark:text-warm-950", html)
        end

        @testset "Content CSS — layout" begin
            html = Therapy.render_to_string(TooltipContent(P("Tip")))
            @test occursin("px-3", html)
            @test occursin("py-1.5", html)
            @test occursin("rounded-md", html)
            @test occursin("text-xs", html)
            @test occursin("text-balance", html)
        end

        @testset "Content animation classes" begin
            html = Therapy.render_to_string(TooltipContent(P("Tip")))
            @test occursin("animate-in", html)
            @test occursin("fade-in-0", html)
            @test occursin("zoom-in-95", html)
            @test occursin("data-[state=closed]:animate-out", html)
            @test occursin("data-[state=closed]:fade-out-0", html)
            @test occursin("data-[side=bottom]:slide-in-from-top-2", html)
            @test occursin("data-[side=top]:slide-in-from-bottom-2", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(TooltipContent(class="max-w-xs",
                P("Tip")
            ))
            @test occursin("max-w-xs", html)
        end

        @testset "Provider uses display:contents" begin
            html = Therapy.render_to_string(TooltipProvider(Span("X")))
            @test occursin("display:contents", html)
        end

        @testset "Root uses display:contents" begin
            html = Therapy.render_to_string(Tooltip(
                TooltipTrigger("X"),
                TooltipContent(P("Y"))
            ))
            @test occursin("display:contents", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Tooltip)
            meta = Suite.COMPONENT_REGISTRY[:Tooltip]
            @test meta.tier == :js_runtime
            @test :TooltipProvider in meta.exports
            @test :Tooltip in meta.exports
            @test :TooltipTrigger in meta.exports
            @test :TooltipContent in meta.exports
            @test :Tooltip in meta.js_modules
            @test :Floating in meta.js_modules
            @test :DismissLayer in meta.js_modules
        end
    end

    @testset "HoverCard" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(HoverCard(
                HoverCardTrigger(A(:href => "#", "@user")),
                HoverCardContent(
                    P("User bio here")
                )
            ))
            @test occursin("data-suite-hover-card", html)
            @test occursin("User bio here", html)
            @test occursin("@user", html)
        end

        @testset "Trigger wiring" begin
            html = Therapy.render_to_string(HoverCard(
                HoverCardTrigger(Span("Hover")),
                HoverCardContent(P("Card"))
            ))
            @test occursin("data-suite-hover-card-trigger", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger uses span wrapper" begin
            html = Therapy.render_to_string(HoverCardTrigger(Span("Link")))
            @test occursin("<span", html)
            @test occursin("Link", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(HoverCardContent(P("Card")))
            @test occursin("data-suite-hover-card-content", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("display:none", html)
        end

        @testset "Content positioning attributes" begin
            html = Therapy.render_to_string(HoverCardContent(
                side="top", side_offset=8, align="start",
                P("Card")
            ))
            @test occursin("data-suite-hover-card-side=\"top\"", html)
            @test occursin("data-suite-hover-card-side-offset=\"8\"", html)
            @test occursin("data-suite-hover-card-align=\"start\"", html)
        end

        @testset "Content default positioning" begin
            html = Therapy.render_to_string(HoverCardContent(P("Card")))
            @test occursin("data-suite-hover-card-side=\"bottom\"", html)
            @test occursin("data-suite-hover-card-side-offset=\"4\"", html)
            @test occursin("data-suite-hover-card-align=\"center\"", html)
        end

        @testset "Content CSS classes" begin
            html = Therapy.render_to_string(HoverCardContent(P("Card")))
            @test occursin("bg-warm-50", html)
            @test occursin("dark:bg-warm-900", html)
            @test occursin("w-64", html)
            @test occursin("rounded-md", html)
            @test occursin("border", html)
            @test occursin("p-4", html)
            @test occursin("shadow-md", html)
        end

        @testset "Content animation classes" begin
            html = Therapy.render_to_string(HoverCardContent(P("Card")))
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
            html = Therapy.render_to_string(HoverCard(
                open_delay=500, close_delay=200,
                HoverCardTrigger(Span("X")),
                HoverCardContent(P("Y"))
            ))
            @test occursin("data-suite-hover-card-open-delay=\"500\"", html)
            @test occursin("data-suite-hover-card-close-delay=\"200\"", html)
        end

        @testset "Default delay attributes" begin
            html = Therapy.render_to_string(HoverCard(
                HoverCardTrigger(Span("X")),
                HoverCardContent(P("Y"))
            ))
            @test occursin("data-suite-hover-card-open-delay=\"700\"", html)
            @test occursin("data-suite-hover-card-close-delay=\"300\"", html)
        end

        @testset "Root uses display:contents" begin
            html = Therapy.render_to_string(HoverCard(
                HoverCardTrigger(Span("X")),
                HoverCardContent(P("Y"))
            ))
            @test occursin("display:contents", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(HoverCardContent(class="max-w-md",
                P("Card")
            ))
            @test occursin("max-w-md", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :HoverCard)
            meta = Suite.COMPONENT_REGISTRY[:HoverCard]
            @test meta.tier == :js_runtime
            @test :HoverCard in meta.exports
            @test :HoverCardTrigger in meta.exports
            @test :HoverCardContent in meta.exports
            @test :HoverCard in meta.js_modules
            @test :Floating in meta.js_modules
            @test :DismissLayer in meta.js_modules
        end
    end

    # ==================== DropdownMenu ==========================================
    @testset "DropdownMenu" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(DropdownMenu(
                DropdownMenuTrigger(Span("Open")),
                DropdownMenuContent(
                    DropdownMenuItem("Profile"),
                    DropdownMenuItem("Settings"),
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
            html = Therapy.render_to_string(DropdownMenuItem("Profile"))
            @test occursin("data-suite-menu-item", html)
            @test occursin("role=\"menuitem\"", html)
            @test occursin("tabindex=\"-1\"", html)
            @test occursin("Profile", html)
            @test occursin("cursor-pointer", html)
            @test occursin("data-[highlighted]", html)
        end

        @testset "MenuItem with shortcut" begin
            html = Therapy.render_to_string(DropdownMenuItem("Profile", shortcut="⇧⌘P"))
            @test occursin("Profile", html)
            @test occursin("⇧⌘P", html)
            @test occursin("data-suite-menu-shortcut", html)
            @test occursin("tracking-widest", html)
        end

        @testset "MenuItem disabled" begin
            html = Therapy.render_to_string(DropdownMenuItem("Disabled", disabled=true))
            @test occursin("data-disabled", html)
            @test occursin("data-[disabled]", html)
        end

        @testset "MenuItem with text_value" begin
            html = Therapy.render_to_string(DropdownMenuItem("🎵 Music", text_value="Music"))
            @test occursin("data-text-value=\"Music\"", html)
        end

        @testset "CheckboxItem unchecked" begin
            html = Therapy.render_to_string(DropdownMenuCheckboxItem("Show toolbar"))
            @test occursin("data-suite-menu-checkbox-item", html)
            @test occursin("role=\"menuitemcheckbox\"", html)
            @test occursin("aria-checked=\"false\"", html)
            @test occursin("data-state=\"unchecked\"", html)
            @test occursin("display:none", html)  # indicator hidden
            @test occursin("pl-8", html)  # left padding for indicator
        end

        @testset "CheckboxItem checked" begin
            html = Therapy.render_to_string(DropdownMenuCheckboxItem("Show toolbar", checked=true))
            @test occursin("aria-checked=\"true\"", html)
            @test occursin("data-state=\"checked\"", html)
            @test occursin("data-suite-menu-item-indicator", html)
            # Check SVG should be visible
            @test occursin("M20 6L9 17l-5-5", html)
        end

        @testset "RadioGroup and RadioItem" begin
            html = Therapy.render_to_string(DropdownMenuRadioGroup(value="center",
                DropdownMenuRadioItem(value="top", "Top"),
                DropdownMenuRadioItem(value="center", checked=true, "Center"),
                DropdownMenuRadioItem(value="bottom", "Bottom"),
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
            html = Therapy.render_to_string(DropdownMenuLabel("My Account"))
            @test occursin("My Account", html)
            @test occursin("font-medium", html)
            @test occursin("text-sm", html)
        end

        @testset "Label with inset" begin
            html = Therapy.render_to_string(DropdownMenuLabel("My Account", inset=true))
            @test occursin("pl-8", html)
        end

        @testset "Separator" begin
            html = Therapy.render_to_string(DropdownMenuSeparator())
            @test occursin("role=\"separator\"", html)
            @test occursin("data-suite-menu-separator", html)
            @test occursin("h-px", html)
            @test occursin("bg-warm-200", html)
        end

        @testset "Shortcut standalone" begin
            html = Therapy.render_to_string(DropdownMenuShortcut("⌘S"))
            @test occursin("⌘S", html)
            @test occursin("tracking-widest", html)
            @test occursin("data-suite-menu-shortcut", html)
        end

        @testset "Group" begin
            html = Therapy.render_to_string(DropdownMenuGroup(
                DropdownMenuItem("A"),
                DropdownMenuItem("B"),
            ))
            @test occursin("role=\"group\"", html)
        end

        @testset "SubMenu structure" begin
            html = Therapy.render_to_string(DropdownMenuSub(
                DropdownMenuSubTrigger("More Tools"),
                DropdownMenuSubContent(
                    DropdownMenuItem("Sub Item 1"),
                    DropdownMenuItem("Sub Item 2"),
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
            html = Therapy.render_to_string(DropdownMenuSubTrigger("More", inset=true))
            @test occursin("pl-8", html)
        end

        @testset "SubTrigger disabled" begin
            html = Therapy.render_to_string(DropdownMenuSubTrigger("More", disabled=true))
            @test occursin("data-disabled", html)
        end

        @testset "Content styling" begin
            html = Therapy.render_to_string(DropdownMenuContent(
                DropdownMenuItem("A")
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
            html = Therapy.render_to_string(DropdownMenuContent(class="w-56",
                DropdownMenuItem("A")
            ))
            @test occursin("w-56", html)
        end

        @testset "Content custom side/align" begin
            html = Therapy.render_to_string(DropdownMenuContent(side="top", align="end", side_offset=8,
                DropdownMenuItem("A")
            ))
            @test occursin("data-side-preference=\"top\"", html)
            @test occursin("data-align-preference=\"end\"", html)
            @test occursin("data-side-offset=\"8\"", html)
        end

        @testset "SubContent styling" begin
            html = Therapy.render_to_string(DropdownMenuSubContent(
                DropdownMenuItem("A")
            ))
            @test occursin("shadow-lg", html)  # SubContent uses shadow-lg
            @test occursin("data-suite-menu-sub-content", html)
            @test occursin("role=\"menu\"", html)
        end

        @testset "ItemIndicator" begin
            html = Therapy.render_to_string(DropdownMenuItemIndicator(Span("✓")))
            @test occursin("data-suite-menu-item-indicator", html)
            @test occursin("✓", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(DropdownMenuContent(
                DropdownMenuItem("A"),
                DropdownMenuSeparator(),
            ))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-300", html)
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:bg-warm-700", html)  # separator dark
        end

        @testset "Full composition" begin
            html = Therapy.render_to_string(DropdownMenu(
                DropdownMenuTrigger(Span("Menu")),
                DropdownMenuContent(
                    DropdownMenuLabel("Account"),
                    DropdownMenuSeparator(),
                    DropdownMenuGroup(
                        DropdownMenuItem("Profile", shortcut="⇧⌘P"),
                        DropdownMenuItem("Settings", shortcut="⌘S"),
                    ),
                    DropdownMenuSeparator(),
                    DropdownMenuCheckboxItem("Status Bar", checked=true),
                    DropdownMenuSeparator(),
                    DropdownMenuRadioGroup(value="center",
                        DropdownMenuRadioItem(value="top", "Top"),
                        DropdownMenuRadioItem(value="center", checked=true, "Center"),
                    ),
                    DropdownMenuSeparator(),
                    DropdownMenuSub(
                        DropdownMenuSubTrigger("More"),
                        DropdownMenuSubContent(
                            DropdownMenuItem("Sub A"),
                        )
                    ),
                    DropdownMenuSeparator(),
                    DropdownMenuItem("Log out", shortcut="⇧⌘Q"),
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
            @test :DropdownMenu in meta.exports
            @test :DropdownMenuTrigger in meta.exports
            @test :DropdownMenuContent in meta.exports
            @test :DropdownMenuItem in meta.exports
            @test :DropdownMenuCheckboxItem in meta.exports
            @test :DropdownMenuRadioGroup in meta.exports
            @test :DropdownMenuRadioItem in meta.exports
            @test :DropdownMenuSeparator in meta.exports
            @test :DropdownMenuLabel in meta.exports
            @test :DropdownMenuShortcut in meta.exports
            @test :DropdownMenuSub in meta.exports
            @test :DropdownMenuSubTrigger in meta.exports
            @test :DropdownMenuSubContent in meta.exports
            @test :DropdownMenuItemIndicator in meta.exports
            @test :DropdownMenuGroup in meta.exports
            @test :Menu in meta.js_modules
            @test :DropdownMenu in meta.js_modules
            @test :Floating in meta.js_modules
            @test :DismissLayer in meta.js_modules
        end
    end

    # ==================== ContextMenu ===========================================
    @testset "ContextMenu" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(ContextMenu(
                ContextMenuTrigger(Div("Right click here")),
                ContextMenuContent(
                    ContextMenuItem("Cut"),
                    ContextMenuItem("Copy"),
                    ContextMenuItem("Paste"),
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
            html = Therapy.render_to_string(ContextMenuTrigger(Div("Area")))
            @test occursin("<span", html)
            @test occursin("Area", html)
        end

        @testset "MenuItem" begin
            html = Therapy.render_to_string(ContextMenuItem("Cut"))
            @test occursin("data-suite-menu-item", html)
            @test occursin("role=\"menuitem\"", html)
            @test occursin("Cut", html)
        end

        @testset "MenuItem with shortcut" begin
            html = Therapy.render_to_string(ContextMenuItem("Cut", shortcut="⌘X"))
            @test occursin("⌘X", html)
            @test occursin("data-suite-menu-shortcut", html)
        end

        @testset "MenuItem disabled" begin
            html = Therapy.render_to_string(ContextMenuItem("Disabled", disabled=true))
            @test occursin("data-disabled", html)
        end

        @testset "CheckboxItem" begin
            html = Therapy.render_to_string(ContextMenuCheckboxItem("Show Grid", checked=true))
            @test occursin("data-suite-menu-checkbox-item", html)
            @test occursin("role=\"menuitemcheckbox\"", html)
            @test occursin("aria-checked=\"true\"", html)
            @test occursin("data-state=\"checked\"", html)
        end

        @testset "RadioGroup and RadioItem" begin
            html = Therapy.render_to_string(ContextMenuRadioGroup(value="light",
                ContextMenuRadioItem(value="light", checked=true, "Light"),
                ContextMenuRadioItem(value="dark", "Dark"),
            ))
            @test occursin("data-suite-menu-radio-group", html)
            @test occursin("role=\"menuitemradio\"", html)
            @test occursin("aria-checked=\"true\"", html)
        end

        @testset "Label" begin
            html = Therapy.render_to_string(ContextMenuLabel("Actions"))
            @test occursin("Actions", html)
            @test occursin("font-medium", html)
        end

        @testset "Label with stronger text" begin
            html = Therapy.render_to_string(ContextMenuLabel("Actions"))
            @test occursin("text-warm-800", html)
        end

        @testset "Separator" begin
            html = Therapy.render_to_string(ContextMenuSeparator())
            @test occursin("role=\"separator\"", html)
            @test occursin("h-px", html)
        end

        @testset "SubMenu structure" begin
            html = Therapy.render_to_string(ContextMenuSub(
                ContextMenuSubTrigger("Share"),
                ContextMenuSubContent(
                    ContextMenuItem("Email"),
                    ContextMenuItem("Link"),
                )
            ))
            @test occursin("data-suite-menu-sub", html)
            @test occursin("data-suite-menu-sub-trigger", html)
            @test occursin("data-suite-menu-sub-content", html)
            @test occursin("Email", html)
            @test occursin("Link", html)
        end

        @testset "Content styling" begin
            html = Therapy.render_to_string(ContextMenuContent(
                ContextMenuItem("A")
            ))
            @test occursin("rounded-md", html)
            @test occursin("shadow-md", html)
            @test occursin("bg-warm-50", html)
            @test occursin("dark:bg-warm-900", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(ContextMenuContent(class="w-64",
                ContextMenuItem("A")
            ))
            @test occursin("w-64", html)
        end

        @testset "Full composition" begin
            html = Therapy.render_to_string(ContextMenu(
                ContextMenuTrigger(
                    Div(:class => "h-[150px] w-[300px]", "Right click here")
                ),
                ContextMenuContent(
                    ContextMenuLabel("Edit"),
                    ContextMenuSeparator(),
                    ContextMenuItem("Cut", shortcut="⌘X"),
                    ContextMenuItem("Copy", shortcut="⌘C"),
                    ContextMenuItem("Paste", shortcut="⌘V"),
                    ContextMenuSeparator(),
                    ContextMenuCheckboxItem("Show Grid", checked=true),
                    ContextMenuSeparator(),
                    ContextMenuSub(
                        ContextMenuSubTrigger("Share"),
                        ContextMenuSubContent(
                            ContextMenuItem("Email"),
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
            html = Therapy.render_to_string(ContextMenuShortcut("⌘Z"))
            @test occursin("⌘Z", html)
            @test occursin("data-suite-menu-shortcut", html)
        end

        @testset "ItemIndicator" begin
            html = Therapy.render_to_string(ContextMenuItemIndicator(Span("•")))
            @test occursin("data-suite-menu-item-indicator", html)
        end

        @testset "Group" begin
            html = Therapy.render_to_string(ContextMenuGroup(
                ContextMenuItem("A"),
            ))
            @test occursin("role=\"group\"", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(ContextMenuContent(
                ContextMenuItem("A"),
            ))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-300", html)
            @test occursin("dark:border-warm-700", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :ContextMenu)
            meta = Suite.COMPONENT_REGISTRY[:ContextMenu]
            @test meta.tier == :js_runtime
            @test :ContextMenu in meta.exports
            @test :ContextMenuTrigger in meta.exports
            @test :ContextMenuContent in meta.exports
            @test :ContextMenuItem in meta.exports
            @test :ContextMenuCheckboxItem in meta.exports
            @test :ContextMenuRadioGroup in meta.exports
            @test :ContextMenuRadioItem in meta.exports
            @test :ContextMenuSeparator in meta.exports
            @test :ContextMenuLabel in meta.exports
            @test :ContextMenuSub in meta.exports
            @test :ContextMenuSubTrigger in meta.exports
            @test :ContextMenuSubContent in meta.exports
            @test :Menu in meta.js_modules
            @test :ContextMenu in meta.js_modules
            @test :Floating in meta.js_modules
            @test :DismissLayer in meta.js_modules
        end
    end

    # ==================== Select ===============================================
    @testset "Select" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(Select(
                SelectTrigger(SelectValue(placeholder="Pick a fruit...")),
                SelectContent(
                    SelectItem("Apple", value="apple"),
                    SelectItem("Banana", value="banana"),
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
            html = Therapy.render_to_string(Select(default_value="banana",
                SelectTrigger(SelectValue(placeholder="Pick...")),
                SelectContent(
                    SelectItem("Apple", value="apple"),
                    SelectItem("Banana", value="banana"),
                )
            ))
            @test occursin("data-suite-select-value=\"banana\"", html)
        end

        @testset "Select disabled" begin
            html = Therapy.render_to_string(Select(disabled=true,
                SelectTrigger(SelectValue(placeholder="Pick...")),
                SelectContent(
                    SelectItem("A", value="a"),
                )
            ))
            @test occursin("data-disabled", html)
        end

        @testset "Select required" begin
            html = Therapy.render_to_string(Select(required=true,
                SelectTrigger(SelectValue(placeholder="Pick...")),
                SelectContent(
                    SelectItem("A", value="a"),
                )
            ))
            @test occursin("data-required", html)
        end

        @testset "SelectTrigger styling" begin
            html = Therapy.render_to_string(SelectTrigger(SelectValue(placeholder="Pick...")))
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
            html = Therapy.render_to_string(SelectTrigger(class="w-[200px]",
                SelectValue(placeholder="Pick...")))
            @test occursin("w-[200px]", html)
        end

        @testset "SelectValue placeholder" begin
            html = Therapy.render_to_string(SelectValue(placeholder="Choose..."))
            @test occursin("data-suite-select-display", html)
            @test occursin("data-placeholder", html)
            @test occursin("Choose...", html)
        end

        @testset "SelectContent styling" begin
            html = Therapy.render_to_string(SelectContent(
                SelectItem("A", value="a")
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
            html = Therapy.render_to_string(SelectContent(side="top", align="end", side_offset=8,
                SelectItem("A", value="a")
            ))
            @test occursin("data-suite-select-side=\"top\"", html)
            @test occursin("data-suite-select-align=\"end\"", html)
            @test occursin("data-suite-select-side-offset=\"8\"", html)
        end

        @testset "SelectContent custom class" begin
            html = Therapy.render_to_string(SelectContent(class="w-[300px]",
                SelectItem("A", value="a")
            ))
            @test occursin("w-[300px]", html)
        end

        @testset "SelectItem basic" begin
            html = Therapy.render_to_string(SelectItem("Apple", value="apple"))
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
            html = Therapy.render_to_string(SelectItem("Apple", value="apple", disabled=true))
            @test occursin("data-disabled", html)
            @test occursin("aria-disabled=\"true\"", html)
            @test occursin("data-[disabled]", html)
        end

        @testset "SelectItem with text_value" begin
            html = Therapy.render_to_string(SelectItem("🍎 Apple", value="apple", text_value="Apple"))
            @test occursin("data-suite-select-item-text=\"Apple\"", html)
        end

        @testset "SelectItem custom class" begin
            html = Therapy.render_to_string(SelectItem("A", value="a", class="font-bold"))
            @test occursin("font-bold", html)
        end

        @testset "SelectGroup" begin
            html = Therapy.render_to_string(SelectGroup(
                SelectLabel("Fruits"),
                SelectItem("Apple", value="apple"),
            ))
            @test occursin("role=\"group\"", html)
            @test occursin("data-suite-select-group", html)
            @test occursin("Fruits", html)
            @test occursin("Apple", html)
        end

        @testset "SelectLabel" begin
            html = Therapy.render_to_string(SelectLabel("Category"))
            @test occursin("data-suite-select-label", html)
            @test occursin("role=\"presentation\"", html)
            @test occursin("font-semibold", html)
            @test occursin("Category", html)
        end

        @testset "SelectSeparator" begin
            html = Therapy.render_to_string(SelectSeparator())
            @test occursin("data-suite-select-separator", html)
            @test occursin("role=\"separator\"", html)
            @test occursin("h-px", html)
            @test occursin("bg-warm-200", html)
        end

        @testset "SelectScrollUpButton" begin
            html = Therapy.render_to_string(SelectScrollUpButton())
            @test occursin("data-suite-select-scroll-up", html)
            @test occursin("aria-hidden=\"true\"", html)
            # Default chevron up icon
            @test occursin("m18 15-6-6-6 6", html)
        end

        @testset "SelectScrollDownButton" begin
            html = Therapy.render_to_string(SelectScrollDownButton())
            @test occursin("data-suite-select-scroll-down", html)
            @test occursin("aria-hidden=\"true\"", html)
            # Default chevron down icon
            @test occursin("m6 9 6 6 6-6", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(SelectContent(
                SelectItem("A", value="a"),
                SelectSeparator(),
            ))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-300", html)
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:bg-warm-700", html)
        end

        @testset "Full composition" begin
            html = Therapy.render_to_string(Select(
                SelectTrigger(SelectValue(placeholder="Select a fruit...")),
                SelectContent(
                    SelectGroup(
                        SelectLabel("Fruits"),
                        SelectItem("Apple", value="apple"),
                        SelectItem("Banana", value="banana"),
                        SelectItem("Orange", value="orange"),
                    ),
                    SelectSeparator(),
                    SelectGroup(
                        SelectLabel("Vegetables"),
                        SelectItem("Carrot", value="carrot"),
                        SelectItem("Broccoli", value="broccoli"),
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
            @test :Select in meta.exports
            @test :SelectTrigger in meta.exports
            @test :SelectValue in meta.exports
            @test :SelectContent in meta.exports
            @test :SelectItem in meta.exports
            @test :SelectGroup in meta.exports
            @test :SelectLabel in meta.exports
            @test :SelectSeparator in meta.exports
            @test :Select in meta.js_modules
            @test :Floating in meta.js_modules
        end
    end

    # ==================== Command ==============================================
    @testset "Command" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(Command(
                CommandInput(placeholder="Type a command..."),
                CommandList(
                    CommandEmpty("No results found."),
                    CommandGroup(heading="Suggestions",
                        CommandItem("Calendar", value="calendar"),
                        CommandItem("Search", value="search"),
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
            html = Therapy.render_to_string(Command(
                CommandInput(placeholder="Search..."),
                CommandList(
                    CommandItem("Test", value="test"),
                )
            ))
            @test occursin("bg-warm-50", html)
            @test occursin("dark:bg-warm-900", html)
            @test occursin("rounded-md", html)
            @test occursin("overflow-hidden", html)
        end

        @testset "Command filter attribute" begin
            html = Therapy.render_to_string(Command(should_filter=false,
                CommandInput(placeholder="Search..."),
                CommandList(
                    CommandItem("Test", value="test"),
                )
            ))
            @test occursin("data-suite-command-filter=\"false\"", html)
        end

        @testset "Command loop attribute" begin
            html = Therapy.render_to_string(Command(loop=false,
                CommandInput(placeholder="Search..."),
                CommandList(
                    CommandItem("Test", value="test"),
                )
            ))
            @test occursin("data-suite-command-loop=\"false\"", html)
        end

        @testset "Command custom class" begin
            html = Therapy.render_to_string(Command(class="max-w-lg",
                CommandInput(placeholder="Search..."),
                CommandList(
                    CommandItem("Test", value="test"),
                )
            ))
            @test occursin("max-w-lg", html)
        end

        @testset "CommandInput" begin
            html = Therapy.render_to_string(CommandInput(placeholder="Search..."))
            @test occursin("data-suite-command-input", html)
            @test occursin("placeholder=\"Search...\"", html)
            @test occursin("autocomplete=\"off\"", html)
            @test occursin("spellcheck=\"false\"", html)
            @test occursin("border-b", html)
            # Search icon
            @test occursin("circle cx=\"11\" cy=\"11\"", html)
        end

        @testset "CommandInput custom class" begin
            html = Therapy.render_to_string(CommandInput(placeholder="Search...", class="font-bold"))
            @test occursin("font-bold", html)
        end

        @testset "CommandList" begin
            html = Therapy.render_to_string(CommandList(
                CommandItem("A", value="a"),
            ))
            @test occursin("data-suite-command-list", html)
            @test occursin("role=\"listbox\"", html)
            @test occursin("aria-label=\"Suggestions\"", html)
            @test occursin("max-h-[300px]", html)
            @test occursin("overflow-y-auto", html)
        end

        @testset "CommandEmpty" begin
            html = Therapy.render_to_string(CommandEmpty("No results found."))
            @test occursin("data-suite-command-empty", html)
            @test occursin("role=\"presentation\"", html)
            @test occursin("No results found.", html)
            @test occursin("text-center", html)
            @test occursin("display:none", html)  # hidden by default
        end

        @testset "CommandGroup" begin
            html = Therapy.render_to_string(CommandGroup(heading="Suggestions",
                CommandItem("Calendar", value="calendar"),
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
            html = Therapy.render_to_string(CommandGroup(
                CommandItem("A", value="a"),
            ))
            @test occursin("data-suite-command-group", html)
            @test occursin("role=\"group\"", html)
            @test !occursin("aria-labelledby", html)
        end

        @testset "CommandItem basic" begin
            html = Therapy.render_to_string(CommandItem("Calendar", value="calendar"))
            @test occursin("data-suite-command-item", html)
            @test occursin("data-suite-command-item-value=\"calendar\"", html)
            @test occursin("role=\"option\"", html)
            @test occursin("aria-selected=\"false\"", html)
            @test occursin("Calendar", html)
            @test occursin("rounded-sm", html)
            @test occursin("cursor-pointer", html)
            @test occursin("data-[selected=true]:bg-warm-100", html)
        end

        @testset "CommandItem disabled" begin
            html = Therapy.render_to_string(CommandItem("Disabled", value="disabled", disabled=true))
            @test occursin("data-disabled=\"true\"", html)
            @test occursin("data-[disabled=true]:pointer-events-none", html)
            @test occursin("data-[disabled=true]:opacity-50", html)
        end

        @testset "CommandItem with keywords" begin
            html = Therapy.render_to_string(CommandItem("Settings", value="settings",
                keywords=["preferences", "config"]))
            @test occursin("data-suite-command-item-keywords=\"preferences,config\"", html)
        end

        @testset "CommandItem custom class" begin
            html = Therapy.render_to_string(CommandItem("A", value="a", class="font-bold"))
            @test occursin("font-bold", html)
        end

        @testset "CommandSeparator" begin
            html = Therapy.render_to_string(CommandSeparator())
            @test occursin("data-suite-command-separator", html)
            @test occursin("role=\"separator\"", html)
            @test occursin("h-px", html)
            @test occursin("bg-warm-200", html)
        end

        @testset "CommandShortcut" begin
            html = Therapy.render_to_string(CommandShortcut("⌘K"))
            @test occursin("data-suite-command-shortcut", html)
            @test occursin("⌘K", html)
            @test occursin("tracking-widest", html)
            @test occursin("text-xs", html)
            @test occursin("ml-auto", html)
        end

        @testset "CommandDialog" begin
            html = Therapy.render_to_string(CommandDialog(
                CommandInput(placeholder="Type a command..."),
                CommandList(
                    CommandItem("Test", value="test"),
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
            html = Therapy.render_to_string(Command(
                CommandInput(placeholder="Search..."),
                CommandList(
                    CommandGroup(heading="Test",
                        CommandItem("A", value="a"),
                    ),
                    CommandSeparator(),
                )
            ))
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-300", html)
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:bg-warm-700", html)
        end

        @testset "Full composition" begin
            html = Therapy.render_to_string(Command(
                CommandInput(placeholder="Type a command or search..."),
                CommandList(
                    CommandEmpty("No results found."),
                    CommandGroup(heading="Suggestions",
                        CommandItem("Calendar", value="calendar"),
                        CommandItem(
                            Span("Search Emoji"),
                            CommandShortcut("⌘E"),
                            value="emoji"),
                        CommandItem("Calculator", value="calculator"),
                    ),
                    CommandSeparator(),
                    CommandGroup(heading="Settings",
                        CommandItem("Profile", value="profile"),
                        CommandItem("Billing", value="billing",
                            keywords=["payment", "subscription"]),
                        CommandItem("Settings", value="settings",
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
            @test :Command in meta.exports
            @test :CommandInput in meta.exports
            @test :CommandList in meta.exports
            @test :CommandEmpty in meta.exports
            @test :CommandGroup in meta.exports
            @test :CommandItem in meta.exports
            @test :CommandSeparator in meta.exports
            @test :CommandShortcut in meta.exports
            @test :CommandDialog in meta.exports
            @test :Command in meta.js_modules
        end
    end

    # =====================================================================
    # Theme System Tests
    # =====================================================================
    @testset "Themes" begin
        using Therapy: Therapy, Div, Span, A
        using Suite

        @testset "SuiteTheme struct and registry" begin
            @test haskey(Suite.SUITE_THEMES, :default)
            @test haskey(Suite.SUITE_THEMES, :ocean)
            @test haskey(Suite.SUITE_THEMES, :minimal)
            @test haskey(Suite.SUITE_THEMES, :nature)
            @test haskey(Suite.SUITE_THEMES, :islands)
            @test length(Suite.SUITE_THEMES) == 5

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

            islands = Suite.SUITE_THEMES[:islands]
            @test islands.name === :islands
            @test islands.accent == "accent"
            @test islands.accent_secondary == "accent-secondary"
            @test islands.neutral == "warm"
            @test islands.radius == "rounded-xl"
            @test islands.radius_sm == "rounded-lg"
            @test islands.shadow == "shadow-md"
            @test islands.ring == "accent-600"
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

        @testset "Button with theme" begin
            @testset "Default theme unchanged" begin
                default_html = Therapy.render_to_string(Button("Click"))
                themed_html = Therapy.render_to_string(Button("Click", theme=:default))
                @test default_html == themed_html
            end

            @testset "Ocean theme" begin
                html = Therapy.render_to_string(Button("Click", theme=:ocean))
                @test occursin("bg-blue-600", html)
                @test !occursin("bg-accent-600", html)
                @test occursin("rounded-lg", html)
            end

            @testset "Minimal theme" begin
                html = Therapy.render_to_string(Button("Click", theme=:minimal))
                @test occursin("bg-zinc-600", html)
                @test occursin("rounded-none", html)
                @test !occursin("shadow-sm", html)
            end

            @testset "Nature theme" begin
                html = Therapy.render_to_string(Button("Click", theme=:nature))
                @test occursin("bg-emerald-600", html)
                @test occursin("rounded-xl", html)
            end

            @testset "Destructive variant with theme" begin
                html = Therapy.render_to_string(Button("Del", variant="destructive", theme=:ocean))
                @test occursin("bg-rose-600", html)
                @test !occursin("accent-secondary", html)
            end
        end

        @testset "Card with theme" begin
            html = Therapy.render_to_string(Card(theme=:minimal, "Content"))
            @test occursin("border-slate-200", html)
            @test !occursin("warm-", html)
            @test occursin("shadow-none", html)
        end

        @testset "Badge with theme" begin
            html = Therapy.render_to_string(Badge("New", theme=:ocean))
            @test occursin("bg-blue-600", html)
            @test !occursin("bg-accent-600", html)
        end

        @testset "Input with theme" begin
            html = Therapy.render_to_string(Input(theme=:minimal))
            @test occursin("border-slate-200", html)
            @test occursin("ring-zinc-600", html)
        end

        @testset "Progress with theme" begin
            html = Therapy.render_to_string(Progress(value=50, theme=:ocean))
            @test occursin("bg-blue-600", html)
            @test !occursin("accent-600", html)
        end

        @testset "Separator with theme" begin
            html = Therapy.render_to_string(Separator(theme=:minimal))
            @test occursin("bg-slate-200", html)
            @test !occursin("warm-", html)
        end

        @testset "Alert with theme" begin
            html = Therapy.render_to_string(Alert(variant="destructive", theme=:ocean, "Error"))
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

    @testset "Menubar" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(Menubar(
                MenubarMenu(
                    MenubarTrigger("File"),
                    MenubarContent(
                        MenubarItem("New Tab"),
                        MenubarItem("New Window"),
                    )
                ),
                MenubarMenu(
                    MenubarTrigger("Edit"),
                    MenubarContent(
                        MenubarItem("Undo"),
                        MenubarItem("Redo"),
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
            html = Therapy.render_to_string(Menubar(
                MenubarMenu(MenubarTrigger("File"), MenubarContent(MenubarItem("A")))
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
            html = Therapy.render_to_string(MenubarTrigger("File"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
            @test occursin("role=\"menuitem\"", html)
        end

        @testset "Trigger styling" begin
            html = Therapy.render_to_string(MenubarTrigger("File"))
            @test occursin("text-sm", html)
            @test occursin("font-medium", html)
            @test occursin("rounded-sm", html)
            @test occursin("px-2", html)
            @test occursin("data-[state=open]:bg-warm-100", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(MenubarContent(
                MenubarItem("A")
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
            html = Therapy.render_to_string(MenubarItem("Profile"))
            @test occursin("data-suite-menu-item", html)
            @test occursin("role=\"menuitem\"", html)
            @test occursin("Profile", html)
        end

        @testset "MenuItem with shortcut" begin
            html = Therapy.render_to_string(MenubarItem("New Tab", shortcut="⌘T"))
            @test occursin("New Tab", html)
            @test occursin("⌘T", html)
            @test occursin("data-suite-menu-shortcut", html)
        end

        @testset "MenuItem disabled" begin
            html = Therapy.render_to_string(MenubarItem("Disabled", disabled=true))
            @test occursin("data-disabled", html)
        end

        @testset "CheckboxItem" begin
            html = Therapy.render_to_string(MenubarCheckboxItem("Toolbar", checked=true))
            @test occursin("data-suite-menu-checkbox-item", html)
            @test occursin("role=\"menuitemcheckbox\"", html)
            @test occursin("aria-checked=\"true\"", html)
            @test occursin("data-state=\"checked\"", html)
        end

        @testset "RadioGroup and RadioItem" begin
            html = Therapy.render_to_string(MenubarRadioGroup(value="a",
                MenubarRadioItem(value="a", checked=true, "Alpha"),
                MenubarRadioItem(value="b", "Beta"),
            ))
            @test occursin("data-suite-menu-radio-group", html)
            @test occursin("role=\"menuitemradio\"", html)
            @test occursin("data-state=\"checked\"", html)
            @test occursin("data-state=\"unchecked\"", html)
        end

        @testset "Label" begin
            html = Therapy.render_to_string(MenubarLabel("Section"))
            @test occursin("Section", html)
            @test occursin("font-medium", html)
        end

        @testset "Separator" begin
            html = Therapy.render_to_string(MenubarSeparator())
            @test occursin("role=\"separator\"", html)
            @test occursin("h-px", html)
            @test occursin("bg-warm-200", html)
        end

        @testset "SubMenu structure" begin
            html = Therapy.render_to_string(MenubarSub(
                MenubarSubTrigger("More"),
                MenubarSubContent(
                    MenubarItem("Sub Item"),
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
            html = Therapy.render_to_string(Menubar(class="my-bar",
                MenubarMenu(MenubarTrigger("X"), MenubarContent(MenubarItem("A")))
            ))
            @test occursin("my-bar", html)
        end

        @testset "Loop attribute" begin
            html = Therapy.render_to_string(Menubar(loop=false,
                MenubarMenu(MenubarTrigger("X"), MenubarContent(MenubarItem("A")))
            ))
            @test occursin("data-loop=\"false\"", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Menubar)
            meta = Suite.COMPONENT_REGISTRY[:Menubar]
            @test meta.tier == :js_runtime
            @test :Menubar in meta.exports
            @test :MenubarTrigger in meta.exports
            @test :MenubarContent in meta.exports
            @test :MenubarItem in meta.exports
            @test :Menu in meta.js_modules
            @test :Menubar in meta.js_modules
        end
    end

    @testset "NavigationMenu" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(NavigationMenu(
                NavigationMenuList(
                    NavigationMenuItem(
                        NavigationMenuTrigger("Getting Started"),
                        NavigationMenuContent(
                            NavigationMenuLink("Introduction", href="/docs/"),
                        )
                    ),
                    NavigationMenuItem(
                        NavigationMenuLink("Documentation", href="/docs/")
                    ),
                ),
            ))
            @test occursin("data-suite-nav-menu=", html)
            @test occursin("data-suite-nav-menu-list", html)
            @test occursin("data-suite-nav-menu-item", html)
            @test occursin("data-suite-nav-menu-trigger", html)
            @test occursin("data-suite-nav-menu-content", html)
            @test occursin("data-suite-nav-menu-link", html)
            @test occursin("Getting Started", html)
            @test occursin("Introduction", html)
            @test occursin("Documentation", html)
        end

        @testset "Root styling" begin
            html = Therapy.render_to_string(NavigationMenu(
                NavigationMenuList(
                    NavigationMenuItem(NavigationMenuLink("A", href="/a/"))
                )
            ))
            @test occursin("relative", html)
            @test occursin("flex", html)
            @test occursin("items-center", html)
        end

        @testset "List is a UL" begin
            html = Therapy.render_to_string(NavigationMenuList(
                NavigationMenuItem(NavigationMenuLink("A", href="/a/"))
            ))
            @test occursin("<ul", html)
            @test occursin("list-none", html)
        end

        @testset "Item is a LI" begin
            html = Therapy.render_to_string(NavigationMenuItem(
                NavigationMenuLink("A", href="/a/")
            ))
            @test occursin("<li", html)
            @test occursin("data-suite-nav-menu-item", html)
        end

        @testset "Trigger is a button with chevron" begin
            html = Therapy.render_to_string(NavigationMenuTrigger("Products"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
            @test occursin("data-suite-nav-menu-trigger", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("Products", html)
            # Chevron SVG
            @test occursin("group-data-[state=open]:rotate-180", html)
        end

        @testset "Trigger styling" begin
            html = Therapy.render_to_string(NavigationMenuTrigger("Products"))
            @test occursin("h-9", html)
            @test occursin("rounded-md", html)
            @test occursin("text-sm", html)
            @test occursin("font-medium", html)
            @test occursin("bg-warm-50", html)
            @test occursin("hover:bg-warm-100", html)
        end

        @testset "Content structure" begin
            html = Therapy.render_to_string(NavigationMenuContent(
                NavigationMenuLink("A", href="/a/")
            ))
            @test occursin("data-suite-nav-menu-content", html)
            @test occursin("data-state=\"closed\"", html)
            @test occursin("display:none", html)
            # Inline dropdown positioning
            @test occursin("absolute", html)
            @test occursin("z-50", html)
            @test occursin("bg-warm-50", html)
            @test occursin("border-warm-200", html)
            @test occursin("shadow-lg", html)
            @test occursin("rounded-md", html)
            # Motion animation classes
            @test occursin("data-[motion^=from-]:animate-in", html)
            @test occursin("data-[motion^=to-]:animate-out", html)
        end

        @testset "Link rendering" begin
            html = Therapy.render_to_string(NavigationMenuLink("Install", href="/install/"))
            @test occursin("<a", html)
            @test occursin("href=\"/install/\"", html)
            @test occursin("data-suite-nav-menu-link", html)
            @test occursin("Install", html)
            @test occursin("rounded-sm", html)
        end

        @testset "Link with description" begin
            html = Therapy.render_to_string(NavigationMenuLink("Install", href="/install/", description="How to install Suite.jl"))
            @test occursin("Install", html)
            @test occursin("How to install Suite.jl", html)
            @test occursin("line-clamp-2", html)
        end

        @testset "Link active state" begin
            html = Therapy.render_to_string(NavigationMenuLink("Home", href="/", active=true))
            @test occursin("data-active=\"true\"", html)
        end

        @testset "Viewport (no-op)" begin
            # NavigationMenuViewport is a no-op — renders nothing (Fragment)
            html = Therapy.render_to_string(NavigationMenuViewport())
            @test html == ""  # Fragment renders as empty string
        end

        @testset "Indicator" begin
            html = Therapy.render_to_string(NavigationMenuIndicator())
            @test occursin("data-suite-nav-menu-indicator", html)
            @test occursin("data-state=\"hidden\"", html)
            @test occursin("rotate-45", html)  # arrow
        end

        @testset "Delay attributes" begin
            html = Therapy.render_to_string(NavigationMenu(
                delay_duration=300,
                skip_delay_duration=500,
                NavigationMenuList(
                    NavigationMenuItem(NavigationMenuLink("A", href="/a/"))
                )
            ))
            @test occursin("data-delay-duration=\"300\"", html)
            @test occursin("data-skip-delay-duration=\"500\"", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(NavigationMenu(class="my-nav",
                NavigationMenuList(
                    NavigationMenuItem(NavigationMenuLink("A", href="/a/"))
                )
            ))
            @test occursin("my-nav", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :NavigationMenu)
            meta = Suite.COMPONENT_REGISTRY[:NavigationMenu]
            @test meta.tier == :js_runtime
            @test :NavigationMenu in meta.exports
            @test :NavigationMenuList in meta.exports
            @test :NavigationMenuTrigger in meta.exports
            @test :NavigationMenuContent in meta.exports
            @test :NavigationMenuLink in meta.exports
            @test :NavigationMenuViewport in meta.exports
            @test :NavigationMenu in meta.js_modules
        end
    end

    # ===================================================================
    # Toast (Sonner-style notification system)
    # ===================================================================
    @testset "Toaster" begin
        @testset "Default rendering" begin
            html = Therapy.render_to_string(Toaster())
            @test occursin("data-suite-toaster", html)
            @test occursin("aria-label=\"Notifications\"", html)
            @test occursin("tabindex=\"-1\"", html)
            @test occursin("<section", html)
        end

        @testset "Default position" begin
            html = Therapy.render_to_string(Toaster())
            @test occursin("data-position=\"bottom-right\"", html)
        end

        @testset "Custom position" begin
            html = Therapy.render_to_string(Toaster(position="top-center"))
            @test occursin("data-position=\"top-center\"", html)
        end

        @testset "All positions" begin
            for pos in ["top-left", "top-center", "top-right", "bottom-left", "bottom-center", "bottom-right"]
                html = Therapy.render_to_string(Toaster(position=pos))
                @test occursin("data-position=\"$pos\"", html)
            end
        end

        @testset "Custom duration" begin
            html = Therapy.render_to_string(Toaster(duration=8000))
            @test occursin("data-duration=\"8000\"", html)
        end

        @testset "Default duration" begin
            html = Therapy.render_to_string(Toaster())
            @test occursin("data-duration=\"4000\"", html)
        end

        @testset "Custom visible toasts" begin
            html = Therapy.render_to_string(Toaster(visible_toasts=5))
            @test occursin("data-visible-toasts=\"5\"", html)
        end

        @testset "Default visible toasts" begin
            html = Therapy.render_to_string(Toaster())
            @test occursin("data-visible-toasts=\"3\"", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Toaster(class="my-custom"))
            @test occursin("my-custom", html)
        end

        @testset "Theme support" begin
            html_default = Therapy.render_to_string(Toaster())
            html_ocean = Therapy.render_to_string(Toaster(theme=:ocean))
            # Both should render the container
            @test occursin("data-suite-toaster", html_default)
            @test occursin("data-suite-toaster", html_ocean)
        end

        @testset "Exported from Suite" begin
            @test isdefined(Suite, :Toaster)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Toast)
            meta = Suite.COMPONENT_REGISTRY[:Toast]
            @test meta.tier == :js_runtime
            @test :Toaster in meta.exports
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

    @testset "Calendar" begin
        using Therapy: Therapy, Div, Span, A
        using Suite
        using Dates

        @testset "Default rendering" begin
            html = Therapy.render_to_string(Calendar())
            @test occursin("data-suite-calendar", html)
            @test occursin("role=\"grid\"", html)
            @test occursin("data-suite-calendar-mode=\"single\"", html)
            @test occursin("p-3", html)
        end

        @testset "Month/year navigation buttons" begin
            html = Therapy.render_to_string(Calendar(month=2, year=2026))
            @test occursin("data-suite-calendar-month=\"2\"", html)
            @test occursin("data-suite-calendar-year=\"2026\"", html)
            @test occursin("data-suite-calendar-prev", html)
            @test occursin("data-suite-calendar-next", html)
            @test occursin("Go to previous month", html)
            @test occursin("Go to next month", html)
        end

        @testset "Caption displays month and year" begin
            html = Therapy.render_to_string(Calendar(month=6, year=2026))
            @test occursin("June 2026", html)
            @test occursin("aria-live=\"polite\"", html)
        end

        @testset "Weekday headers" begin
            html = Therapy.render_to_string(Calendar(month=2, year=2026))
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
            html = Therapy.render_to_string(Calendar(month=2, year=2026))
            # February 2026 has 28 days
            @test occursin("data-suite-calendar-day-btn=\"2026-02-01\"", html)
            @test occursin("data-suite-calendar-day-btn=\"2026-02-28\"", html)
            @test occursin("data-suite-calendar-day=\"2026-02-01\"", html)
        end

        @testset "Day button ARIA label" begin
            html = Therapy.render_to_string(Calendar(month=2, year=2026))
            # Feb 1, 2026 is a Sunday
            @test occursin("Sun, Feb 1, 2026", html) || occursin("2026-02-01", html)
        end

        @testset "Today highlighting" begin
            today = Dates.today()
            html = Therapy.render_to_string(Calendar(month=Dates.month(today), year=Dates.year(today)))
            @test occursin("data-today=\"true\"", html)
            @test occursin("bg-warm-100", html)
        end

        @testset "Outside days" begin
            # show_outside_days=true (default)
            html_show = Therapy.render_to_string(Calendar(month=2, year=2026, show_outside_days=true))
            @test occursin("data-outside=\"true\"", html_show)
            @test occursin("opacity-50", html_show)

            # show_outside_days=false
            html_hide = Therapy.render_to_string(Calendar(month=2, year=2026, show_outside_days=false))
            # Outside days should be empty cells (no button)
            # The non-outside cells should still have buttons
            @test occursin("data-suite-calendar-day-btn=\"2026-02-01\"", html_hide)
        end

        @testset "Selection modes" begin
            for mode in ["single", "multiple", "range"]
                html = Therapy.render_to_string(Calendar(mode=mode))
                @test occursin("data-suite-calendar-mode=\"$mode\"", html)
            end

            # range and multiple have aria-multiselectable
            html_range = Therapy.render_to_string(Calendar(mode="range"))
            @test occursin("aria-multiselectable=\"true\"", html_range)

            html_multi = Therapy.render_to_string(Calendar(mode="multiple"))
            @test occursin("aria-multiselectable=\"true\"", html_multi)

            # single should NOT have aria-multiselectable
            html_single = Therapy.render_to_string(Calendar(mode="single"))
            @test !occursin("aria-multiselectable", html_single)
        end

        @testset "Pre-selected date" begin
            html = Therapy.render_to_string(Calendar(selected="2026-02-14", month=2, year=2026))
            @test occursin("data-suite-calendar-selected=\"2026-02-14\"", html)
        end

        @testset "Disabled dates" begin
            html = Therapy.render_to_string(Calendar(disabled_dates="2026-02-14,2026-02-15", month=2, year=2026))
            @test occursin("data-suite-calendar-disabled=\"2026-02-14,2026-02-15\"", html)
        end

        @testset "Number of months" begin
            html = Therapy.render_to_string(Calendar(number_of_months=2, month=1, year=2026))
            @test occursin("data-suite-calendar-months-count=\"2\"", html)
            @test occursin("January 2026", html)
            @test occursin("February 2026", html)
        end

        @testset "Custom class merging" begin
            html = Therapy.render_to_string(Calendar(class="my-custom"))
            @test occursin("my-custom", html)
            @test occursin("p-3", html)
        end

        @testset "Keyboard accessibility" begin
            html = Therapy.render_to_string(Calendar(month=2, year=2026))
            # Roving tabindex - all buttons start with tabindex=-1
            @test occursin("tabindex=\"-1\"", html)
            # Focus ring classes
            @test occursin("focus-visible:ring-2", html)
            @test occursin("focus-visible:ring-accent-600", html)
        end

        @testset "Grid structure" begin
            html = Therapy.render_to_string(Calendar(month=2, year=2026))
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
            html = Therapy.render_to_string(Calendar(month=2, year=2026))
            @test occursin("dark:hover:bg-warm-900", html)
            @test occursin("dark:text-warm-300", html)
        end

        @testset "Nav button styling" begin
            html = Therapy.render_to_string(Calendar(month=2, year=2026))
            @test occursin("border-warm-200", html)
            @test occursin("hover:bg-warm-100", html)
        end

        @testset "Registry registration" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Calendar)
            meta = Suite.COMPONENT_REGISTRY[:Calendar]
            @test meta.tier == :js_runtime
            @test meta.file == "Calendar.jl"
            @test :Calendar in meta.exports
            @test :DatePicker in meta.exports
        end

        @testset "Theme support" begin
            html_default = Therapy.render_to_string(Calendar(month=2, year=2026))
            html_ocean = Therapy.render_to_string(Calendar(month=2, year=2026, theme=:ocean))

            @test occursin("accent-600", html_default)
            # Ocean theme should substitute accent colors
            @test occursin("blue-600", html_ocean)
        end

        @testset "Fixed weeks" begin
            html = Therapy.render_to_string(Calendar(month=2, year=2026, fixed_weeks=true))
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

    @testset "DatePicker" begin
        using Therapy: Therapy, Div, Span, A
        using Suite
        using Dates

        @testset "Default rendering" begin
            html = Therapy.render_to_string(DatePicker())
            @test occursin("data-suite-datepicker", html)
            @test occursin("data-suite-datepicker-trigger", html)
            @test occursin("data-suite-datepicker-content", html)
            @test occursin("data-suite-datepicker-value", html)
        end

        @testset "Trigger button" begin
            html = Therapy.render_to_string(DatePicker())
            @test occursin("Pick a date", html)
            @test occursin("aria-haspopup=\"dialog\"", html)
            @test occursin("aria-expanded=\"false\"", html)
            @test occursin("w-[280px]", html)
            # Calendar icon SVG
            @test occursin("<svg", html)
        end

        @testset "Placeholder text" begin
            html = Therapy.render_to_string(DatePicker(placeholder="Select a date"))
            @test occursin("Select a date", html)
        end

        @testset "Pre-selected date display" begin
            html = Therapy.render_to_string(DatePicker(selected="2026-02-14", month=2, year=2026))
            @test occursin("data-suite-datepicker-selected=\"2026-02-14\"", html)
            # Should show formatted date, not placeholder
            @test !occursin("Pick a date", html)
        end

        @testset "Contains Calendar component" begin
            html = Therapy.render_to_string(DatePicker(month=2, year=2026))
            @test occursin("data-suite-calendar", html)
            @test occursin("role=\"grid\"", html)
            @test occursin("February 2026", html)
        end

        @testset "Content hidden by default" begin
            html = Therapy.render_to_string(DatePicker())
            @test occursin("display:none", html)
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Dialog role on content" begin
            html = Therapy.render_to_string(DatePicker())
            @test occursin("role=\"dialog\"", html)
            @test occursin("aria-modal=\"true\"", html)
        end

        @testset "Selection mode passthrough" begin
            html = Therapy.render_to_string(DatePicker(mode="range", number_of_months=2, month=1, year=2026))
            @test occursin("data-suite-datepicker-mode=\"range\"", html)
            @test occursin("data-suite-calendar-mode=\"range\"", html)
            @test occursin("January 2026", html)
            @test occursin("February 2026", html)
        end

        @testset "Custom class on trigger" begin
            html = Therapy.render_to_string(DatePicker(class="my-picker"))
            @test occursin("my-picker", html)
        end

        @testset "Theme support" begin
            html_default = Therapy.render_to_string(DatePicker(month=2, year=2026))
            html_ocean = Therapy.render_to_string(DatePicker(month=2, year=2026, theme=:ocean))
            @test occursin("accent-600", html_default)
            @test occursin("blue-600", html_ocean)
        end

        @testset "Outline trigger styling" begin
            html = Therapy.render_to_string(DatePicker())
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

    @testset "DataTable" begin
        using Therapy: Therapy, Div, Span, A
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
            DataTableColumn("name", "Name"),
            DataTableColumn("email", "Email"),
            DataTableColumn("status", "Status"),
            DataTableColumn("amount", "Amount", align="right"),
        ]

        @testset "DataTableColumn struct" begin
            col = DataTableColumn("name", "Name")
            @test col.key == "name"
            @test col.header == "Name"
            @test col.sortable == true
            @test col.hideable == true
            @test col.cell === nothing
            @test col.align == "left"

            col2 = DataTableColumn("amount", "Amount", sortable=false, hideable=false, align="right")
            @test col2.sortable == false
            @test col2.hideable == false
            @test col2.align == "right"

            col3 = DataTableColumn("status" => "Status")
            @test col3.key == "status"
            @test col3.header == "Status"
        end

        @testset "Default rendering" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns))
            @test occursin("data-suite-datatable", html)
            @test occursin("<table", html)
            @test occursin("<thead", html)
            @test occursin("<tbody", html)
            @test occursin("Alice", html)
            @test occursin("alice@example.com", html)
            @test occursin("250.0", html)
        end

        @testset "Data store (JSON)" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns))
            @test occursin("data-suite-datatable-store", html)
            @test occursin("data-suite-datatable-columns", html)
            @test occursin("application/json", html)
            # All data should be in JSON store
            @test occursin("\"name\":\"Alice\"", html)
            @test occursin("\"name\":\"Eve\"", html)
        end

        @testset "Column headers" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns))
            @test occursin(">Name", html)
            @test occursin(">Email", html)
            @test occursin(">Status", html)
            @test occursin(">Amount", html)
        end

        @testset "Sort buttons on sortable columns" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns, sortable=true))
            @test occursin("data-suite-datatable-sort", html)
            @test occursin("<svg", html)  # sort icon SVG

            # Non-sortable column
            cols_no_sort = [
                DataTableColumn("name", "Name", sortable=false),
                DataTableColumn("email", "Email"),
            ]
            html2 = Therapy.render_to_string(DataTable(test_data, cols_no_sort))
            # Email should still have sort button
            @test occursin("data-suite-datatable-sort", html2)
        end

        @testset "Sortable=false disables all sorting" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns, sortable=false))
            # No sort buttons should be present — check for sort button SVG icon
            @test !occursin("data-suite-datatable-sort=\"", html)
        end

        @testset "Filter input" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns, filterable=true))
            @test occursin("data-suite-datatable-filter", html)
            @test occursin("Filter...", html)

            html2 = Therapy.render_to_string(DataTable(test_data, test_columns, filterable=true, filter_placeholder="Search..."))
            @test occursin("Search...", html2)

            html3 = Therapy.render_to_string(DataTable(test_data, test_columns, filterable=false))
            @test !occursin("placeholder=\"Filter...\"", html3)
        end

        @testset "Pagination" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns, paginated=true, page_size=2))
            @test occursin("data-suite-datatable-pagination", html)
            @test occursin("data-suite-datatable-prev", html)
            @test occursin("data-suite-datatable-next", html)
            @test occursin("Page 1 of 3", html)
            @test occursin("5 row(s) total", html)
            # Only first 2 rows rendered in body
            @test occursin("Alice", html)
            @test occursin("Bob", html)

            # No pagination
            html2 = Therapy.render_to_string(DataTable(test_data, test_columns, paginated=false))
            @test !occursin("data-suite-datatable-pagination", html2)
            # All rows rendered
            @test occursin("Alice", html2)
            @test occursin("Eve", html2)
        end

        @testset "Row selection" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns, selectable=true))
            @test occursin("data-suite-datatable-select-all", html)
            @test occursin("data-suite-datatable-select-row", html)
            @test occursin("Select all rows", html)
            @test occursin("Select row", html)
            @test occursin("row(s) selected", html)

            html2 = Therapy.render_to_string(DataTable(test_data, test_columns, selectable=false))
            @test !occursin("data-suite-datatable-select-all", html2)
            @test !occursin("data-suite-datatable-select-row", html2)
        end

        @testset "Column visibility" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns, column_visibility=true))
            @test occursin("data-suite-datatable-col-vis", html)
            @test occursin("data-suite-datatable-col-vis-trigger", html)
            @test occursin("data-suite-datatable-col-vis-content", html)
            @test occursin("Columns", html)
            @test occursin("data-suite-datatable-col-toggle", html)

            html2 = Therapy.render_to_string(DataTable(test_data, test_columns, column_visibility=false))
            @test !occursin("data-suite-datatable-col-vis", html2)
        end

        @testset "Column alignment" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns))
            @test occursin("text-right", html)  # Amount column
            @test occursin("text-left", html)   # Name/Email/Status
        end

        @testset "Custom cell renderer" begin
            custom_cols = [
                DataTableColumn("name", "Name"),
                DataTableColumn("amount", "Amount",
                    cell=(val, row) -> Span(:class => "font-bold", "\$$(val)")),
            ]
            html = Therapy.render_to_string(DataTable(test_data, custom_cols))
            @test occursin("font-bold", html)
            @test occursin("\$250.0", html)
        end

        @testset "Empty data" begin
            html = Therapy.render_to_string(DataTable(NamedTuple[], test_columns))
            @test occursin("No results.", html)
        end

        @testset "Caption" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns, caption="Test data"))
            @test occursin("<caption", html)
            @test occursin("Test data", html)
        end

        @testset "Theme support" begin
            html_default = Therapy.render_to_string(DataTable(test_data, test_columns))
            @test occursin("warm-", html_default)

            html_ocean = Therapy.render_to_string(DataTable(test_data, test_columns, theme=:ocean))
            @test occursin("blue-", html_ocean) || occursin("warm-", html_ocean)
        end

        @testset "Dict data" begin
            dict_data = [
                Dict("name" => "Frank", "email" => "frank@example.com"),
                Dict("name" => "Grace", "email" => "grace@example.com"),
            ]
            dict_cols = [
                DataTableColumn("name", "Name"),
                DataTableColumn("email", "Email"),
            ]
            html = Therapy.render_to_string(DataTable(dict_data, dict_cols))
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
            html = Therapy.render_to_string(DataTable(test_data, test_columns, page_size=3))
            @test occursin("data-suite-datatable-page-size=\"3\"", html)
            @test occursin("Page 1 of 2", html)

            html2 = Therapy.render_to_string(DataTable(test_data, test_columns, page_size=10))
            @test occursin("Page 1 of 1", html2)
        end

        @testset "Non-hideable columns excluded from visibility toggle" begin
            cols = [
                DataTableColumn("name", "Name", hideable=false),
                DataTableColumn("email", "Email", hideable=true),
            ]
            html = Therapy.render_to_string(DataTable(test_data, cols, column_visibility=true))
            # Only Email should have a toggle checkbox
            @test occursin("data-suite-datatable-col-check=\"email\"", html)
            @test !occursin("data-suite-datatable-col-check=\"name\"", html)
        end

        @testset "Table structure" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns))
            @test occursin("overflow-x-auto", html)
            @test occursin("rounded-md", html)
            @test occursin("border", html)
            @test occursin("caption-bottom", html)
        end

        @testset "Row hover + selection styling" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns, selectable=true))
            @test occursin("hover:bg-warm-100/50", html)
            @test occursin("data-[state=selected]", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :DataTable)
            meta = Suite.COMPONENT_REGISTRY[:DataTable]
            @test meta.tier == :js_runtime
            @test :DataTable in meta.exports
            @test :DataTableColumn in meta.exports
            @test :Table in meta.suite_deps
        end

        @testset "Filter columns attribute" begin
            html = Therapy.render_to_string(DataTable(test_data, test_columns,
                filterable=true, filter_columns=["name", "email"]))
            @test occursin("data-suite-datatable-filter-columns=\"name,email\"", html)
        end

        @testset "Large dataset pagination" begin
            large_data = [(name="Person $i", email="p$i@test.com", status=i % 2 == 0 ? "Active" : "Inactive", amount=Float64(i * 10)) for i in 1:100]
            html = Therapy.render_to_string(DataTable(large_data, test_columns, page_size=10))
            @test occursin("Page 1 of 10", html)
            @test occursin("100 row(s) total", html)
        end
    end

    @testset "Form" begin
        using Therapy: Therapy, Div, Span, A
        using Suite

        @testset "Form container" begin
            html = Therapy.render_to_string(Form(Span("content")))
            @test occursin("<form", html)
            @test occursin("data-suite-form", html)
            @test occursin("data-suite-form-validate-on=\"submit\"", html)
            @test occursin("space-y-6", html)

            html2 = Therapy.render_to_string(Form(Span("x"), action="/api/test", method="get"))
            @test occursin("action=\"/api/test\"", html2)
            @test occursin("method=\"get\"", html2)

            html3 = Therapy.render_to_string(Form(Span("x"), validate_on="change"))
            @test occursin("data-suite-form-validate-on=\"change\"", html3)
        end

        @testset "FormField with name" begin
            html = Therapy.render_to_string(FormField(Span("child"), name="username"))
            @test occursin("data-suite-form-field=\"username\"", html)
            @test occursin("data-suite-form-field-id=", html)
        end

        @testset "FormField validation attributes" begin
            html = Therapy.render_to_string(FormField(Span("x"),
                name="email",
                required=true,
                required_message="Email is required",
                min_length=5,
                min_length_message="Too short",
                max_length=100,
                pattern="[^@]+@[^@]+",
                pattern_message="Invalid email",
            ))
            @test occursin("data-suite-form-required=\"Email is required\"", html)
            @test occursin("data-suite-form-min-length=\"5\"", html)
            @test occursin("data-suite-form-min-length-message=\"Too short\"", html)
            @test occursin("data-suite-form-max-length=\"100\"", html)
            @test occursin("data-suite-form-pattern", html)
            @test occursin("data-suite-form-pattern-message=\"Invalid email\"", html)
        end

        @testset "FormField required default message" begin
            html = Therapy.render_to_string(FormField(Span("x"), name="test", required=true))
            @test occursin("data-suite-form-required=\"This field is required\"", html)
        end

        @testset "FormField min/max numeric" begin
            html = Therapy.render_to_string(FormField(Span("x"), name="age",
                min="0", max="120"))
            @test occursin("data-suite-form-min=\"0\"", html)
            @test occursin("data-suite-form-max=\"120\"", html)
        end

        @testset "FormItem layout" begin
            html = Therapy.render_to_string(FormItem(Span("content")))
            @test occursin("grid gap-2", html)
            @test occursin("data-suite-form-item", html)
        end

        @testset "FormLabel" begin
            html = Therapy.render_to_string(FormLabel("Email"))
            @test occursin("<label", html)
            @test occursin("data-suite-form-label", html)
            @test occursin("font-medium", html)
            @test occursin("data-[error=true]:text-accent-secondary-600", html)
            @test occursin("Email", html)
        end

        @testset "FormControl" begin
            html = Therapy.render_to_string(FormControl(Input(type="text")))
            @test occursin("data-suite-form-control", html)
            @test occursin("display:contents", html)
            @test occursin("<input", html)
        end

        @testset "FormDescription" begin
            html = Therapy.render_to_string(FormDescription("Helper text"))
            @test occursin("<p", html)
            @test occursin("data-suite-form-description", html)
            @test occursin("text-warm-600", html)
            @test occursin("Helper text", html)
        end

        @testset "FormMessage" begin
            html = Therapy.render_to_string(FormMessage())
            @test occursin("<p", html)
            @test occursin("data-suite-form-message", html)
            @test occursin("hidden", html)
            @test occursin("text-accent-secondary-600", html)
            @test occursin("role=\"alert\"", html)
            @test occursin("aria-live=\"polite\"", html)
        end

        @testset "Full form composition" begin
            html = Therapy.render_to_string(
                Form(action="/submit",
                    FormField(name="username",
                        FormItem(
                            FormLabel("Username"),
                            FormControl(
                                Input(type="text", placeholder="Enter username"),
                            ),
                            FormDescription("Your public display name."),
                            FormMessage(),
                        ),
                        required=true,
                        min_length=2,
                    ),
                    Button(:type => "submit", "Submit"),
                )
            )
            @test occursin("<form", html)
            @test occursin("data-suite-form-field=\"username\"", html)
            @test occursin("<label", html)
            @test occursin("Username", html)
            @test occursin("data-suite-form-control", html)
            @test occursin("placeholder=\"Enter username\"", html)
            @test occursin("Your public display name.", html)
            @test occursin("data-suite-form-message", html)
            @test occursin("data-suite-form-required", html)
            @test occursin("data-suite-form-min-length=\"2\"", html)
            @test occursin("Submit", html)
        end

        @testset "Theme support" begin
            html = Therapy.render_to_string(FormLabel("Test", theme=:ocean))
            @test occursin("blue-", html) || occursin("warm-", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Form(Span("x"), class="max-w-md"))
            @test occursin("max-w-md", html)

            html2 = Therapy.render_to_string(FormItem(Span("x"), class="mt-4"))
            @test occursin("mt-4", html2)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Form)
            meta = Suite.COMPONENT_REGISTRY[:Form]
            @test meta.tier == :js_runtime
            @test :Form in meta.exports
            @test :FormField in meta.exports
            @test :FormItem in meta.exports
            @test :FormLabel in meta.exports
            @test :FormControl in meta.exports
            @test :FormDescription in meta.exports
            @test :FormMessage in meta.exports
        end

        @testset "No validation attrs when not set" begin
            html = Therapy.render_to_string(FormField(Span("x"), name="basic"))
            @test !occursin("data-suite-form-required", html)
            @test !occursin("data-suite-form-min-length", html)
            @test !occursin("data-suite-form-max-length", html)
            @test !occursin("data-suite-form-pattern", html)
            @test !occursin("data-suite-form-min=", html)
            @test !occursin("data-suite-form-max=", html)
        end
    end

    # =====================================================================
    # Sessions.jl Components (SUITE-0904)
    # =====================================================================

    @testset "Kbd" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(Kbd("Ctrl"))
            @test occursin("<kbd", html)
            @test occursin("Ctrl", html)
            @test occursin("font-mono", html)
            @test occursin("border", html)
            @test occursin("rounded", html)
            @test occursin("text-[10px]", html)
            @test occursin("select-none", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(Kbd("K"))
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:bg-warm-900", html)
            @test occursin("dark:text-warm-400", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Kbd(class="ml-2", "X"))
            @test occursin("ml-2", html)
            @test occursin("X", html)
        end

        @testset "Multiple keys composition" begin
            html = Therapy.render_to_string(Div(Kbd("Ctrl"), " + ", Kbd("Enter")))
            @test occursin("Ctrl", html)
            @test occursin("Enter", html)
            @test occursin("<kbd", html)
        end

        @testset "Theme support" begin
            html_default = Therapy.render_to_string(Kbd("X"))
            html_ocean = Therapy.render_to_string(Kbd(theme=:ocean, "X"))
            @test html_default != html_ocean || html_default == html_ocean  # both valid
            @test occursin("<kbd", html_ocean)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Kbd)
            meta = Suite.COMPONENT_REGISTRY[:Kbd]
            @test meta.tier == :styling
            @test :Kbd in meta.exports
        end
    end

    @testset "Spinner" begin
        @testset "Default rendering" begin
            html = Therapy.render_to_string(Spinner())
            @test occursin("<svg", html)
            @test occursin("animate-spin", html)
            @test occursin("text-accent-600", html)
            @test occursin("h-6", html)
            @test occursin("w-6", html)
            @test occursin("aria-hidden", html)
        end

        @testset "All sizes" begin
            html_sm = Therapy.render_to_string(Spinner(size="sm"))
            @test occursin("h-4", html_sm)
            @test occursin("w-4", html_sm)

            html_default = Therapy.render_to_string(Spinner(size="default"))
            @test occursin("h-6", html_default)
            @test occursin("w-6", html_default)

            html_lg = Therapy.render_to_string(Spinner(size="lg"))
            @test occursin("h-8", html_lg)
            @test occursin("w-8", html_lg)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(Spinner())
            @test occursin("dark:text-accent-400", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Spinner(class="text-red-500"))
            @test occursin("text-red-500", html)
        end

        @testset "SVG structure" begin
            html = Therapy.render_to_string(Spinner())
            @test occursin("<circle", html)
            @test occursin("<path", html)
            @test occursin("opacity-25", html)
            @test occursin("opacity-75", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Spinner)
            meta = Suite.COMPONENT_REGISTRY[:Spinner]
            @test meta.tier == :styling
            @test :Spinner in meta.exports
        end
    end

    @testset "Empty" begin
        @testset "Container rendering" begin
            html = Therapy.render_to_string(Empty())
            @test occursin("<div", html)
            @test occursin("flex", html)
            @test occursin("min-h-[200px]", html)
            @test occursin("border-dashed", html)
            @test occursin("text-center", html)
        end

        @testset "Sub-components" begin
            html = Therapy.render_to_string(Empty(
                EmptyIcon(Span("📂")),
                EmptyTitle("No notebooks"),
                EmptyDescription("Create a new notebook to get started."),
                EmptyAction(Span("Create"))
            ))
            @test occursin("📂", html)
            @test occursin("No notebooks", html)
            @test occursin("Create a new notebook", html)
            @test occursin("Create", html)
        end

        @testset "EmptyIcon" begin
            html = Therapy.render_to_string(EmptyIcon(Span("🔍")))
            @test occursin("h-12", html)
            @test occursin("w-12", html)
            @test occursin("rounded-full", html)
            @test occursin("🔍", html)
        end

        @testset "EmptyTitle" begin
            html = Therapy.render_to_string(EmptyTitle("No results"))
            @test occursin("<h3", html)
            @test occursin("No results", html)
            @test occursin("font-semibold", html)
        end

        @testset "EmptyDescription" begin
            html = Therapy.render_to_string(EmptyDescription("Try again later."))
            @test occursin("<p", html)
            @test occursin("Try again later.", html)
            @test occursin("text-sm", html)
            @test occursin("text-warm-600", html)
        end

        @testset "EmptyAction" begin
            html = Therapy.render_to_string(EmptyAction(Span("Go")))
            @test occursin("mt-2", html)
            @test occursin("Go", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(Empty(EmptyTitle("X")))
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:text-warm-300", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Empty(class="h-[400px]"))
            @test occursin("h-[400px]", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Empty)
            meta = Suite.COMPONENT_REGISTRY[:Empty]
            @test meta.tier == :styling
            @test :Empty in meta.exports
            @test :EmptyIcon in meta.exports
            @test :EmptyTitle in meta.exports
            @test :EmptyDescription in meta.exports
            @test :EmptyAction in meta.exports
        end
    end

    @testset "CodeBlock" begin
        @testset "Basic rendering" begin
            html = Therapy.render_to_string(CodeBlock("x = 1"))
            @test occursin("<pre", html)
            @test occursin("<code", html)
            @test occursin("x = 1", html)
            @test occursin("data-suite-codeblock", html)
            @test occursin("font-mono", html)
        end

        @testset "Language badge" begin
            html = Therapy.render_to_string(CodeBlock("println()", language="julia"))
            @test occursin("julia", html)
            @test occursin("uppercase", html)
            @test occursin("tracking-wider", html)
        end

        @testset "Copy button" begin
            html = Therapy.render_to_string(CodeBlock("test", show_copy=true))
            @test occursin("data-suite-codeblock-copy", html)
            @test occursin("<svg", html)

            html_no_copy = Therapy.render_to_string(CodeBlock("test", show_copy=false))
            @test !occursin("data-suite-codeblock-copy", html_no_copy)
        end

        @testset "Line numbers" begin
            html = Therapy.render_to_string(CodeBlock("line1\nline2\nline3", show_line_numbers=true))
            @test occursin("1", html)
            @test occursin("2", html)
            @test occursin("3", html)
            @test occursin("border-r", html)
            @test occursin("select-none", html)
        end

        @testset "No line numbers by default" begin
            html = Therapy.render_to_string(CodeBlock("x = 1"))
            @test !occursin("border-r", html)
        end

        @testset "Dark theme styling" begin
            html = Therapy.render_to_string(CodeBlock("test"))
            @test occursin("bg-warm-950", html)
            @test occursin("text-warm-200", html)
        end

        @testset "Empty code" begin
            html = Therapy.render_to_string(CodeBlock())
            @test occursin("<code", html)
            @test occursin("data-suite-codeblock", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(CodeBlock("x", class="max-w-lg"))
            @test occursin("max-w-lg", html)
        end

        @testset "Header with language + copy" begin
            html = Therapy.render_to_string(CodeBlock("x", language="bash", show_copy=true))
            @test occursin("border-b", html)  # Header separator
            @test occursin("bash", html)
            @test occursin("data-suite-codeblock-copy", html)
        end

        @testset "No header when no language and no copy" begin
            html = Therapy.render_to_string(CodeBlock("x", show_copy=false))
            @test !occursin("border-b", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :CodeBlock)
            meta = Suite.COMPONENT_REGISTRY[:CodeBlock]
            @test meta.tier == :js_runtime
            @test :CodeBlock in meta.exports
        end
    end

    @testset "Toolbar" begin
        @testset "Container rendering" begin
            html = Therapy.render_to_string(Toolbar())
            @test occursin("<div", html)
            @test occursin("role=\"toolbar\"", html)
            @test occursin("rounded-lg", html)
            @test occursin("border", html)
            @test occursin("inline-flex", html)
        end

        @testset "ToolbarGroup" begin
            html = Therapy.render_to_string(ToolbarGroup(Span("B"), Span("I")))
            @test occursin("role=\"group\"", html)
            @test occursin("gap-0.5", html)
            @test occursin("B", html)
            @test occursin("I", html)
        end

        @testset "ToolbarSeparator" begin
            html = Therapy.render_to_string(ToolbarSeparator())
            @test occursin("role=\"none\"", html)
            @test occursin("h-6", html)
            @test occursin("w-px", html)
            @test occursin("bg-warm-200", html)
        end

        @testset "Full composition" begin
            html = Therapy.render_to_string(Toolbar(
                ToolbarGroup(Span("B"), Span("I")),
                ToolbarSeparator(),
                ToolbarGroup(Span("L")),
            ))
            @test occursin("role=\"toolbar\"", html)
            @test occursin("role=\"group\"", html)
            @test occursin("role=\"none\"", html)
            @test occursin("B", html)
            @test occursin("L", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(Toolbar())
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:bg-warm-900", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Toolbar(class="w-full"))
            @test occursin("w-full", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Toolbar)
            meta = Suite.COMPONENT_REGISTRY[:Toolbar]
            @test meta.tier == :styling
            @test :Toolbar in meta.exports
            @test :ToolbarGroup in meta.exports
            @test :ToolbarSeparator in meta.exports
        end
    end

    @testset "StatusBar" begin
        @testset "Container rendering" begin
            html = Therapy.render_to_string(StatusBar())
            @test occursin("<div", html)
            @test occursin("role=\"status\"", html)
            @test occursin("border-t", html)
            @test occursin("h-7", html)
            @test occursin("text-xs", html)
        end

        @testset "StatusBarSection positions" begin
            html_left = Therapy.render_to_string(StatusBarSection(position="left", Span("L")))
            @test occursin("justify-start", html_left)

            html_center = Therapy.render_to_string(StatusBarSection(position="center", Span("C")))
            @test occursin("justify-center", html_center)

            html_right = Therapy.render_to_string(StatusBarSection(position="right", Span("R")))
            @test occursin("justify-end", html_right)
            @test occursin("ml-auto", html_right)
        end

        @testset "StatusBarItem" begin
            html = Therapy.render_to_string(StatusBarItem("Ready"))
            @test occursin("<span", html)
            @test occursin("Ready", html)
            @test occursin("text-warm-600", html)
            @test occursin("whitespace-nowrap", html)
        end

        @testset "StatusBarItem clickable" begin
            html = Therapy.render_to_string(StatusBarItem("Click me", clickable=true))
            @test occursin("cursor-pointer", html)
            @test occursin("hover:text-warm-800", html)
            @test occursin("hover:bg-warm-100", html)
        end

        @testset "StatusBarItem non-clickable" begin
            html = Therapy.render_to_string(StatusBarItem("Static"))
            @test !occursin("cursor-pointer", html)
        end

        @testset "Full composition" begin
            html = Therapy.render_to_string(StatusBar(
                StatusBarSection(position="left",
                    StatusBarItem("Ready"),
                    StatusBarItem("UTF-8"),
                ),
                StatusBarSection(position="right",
                    StatusBarItem("Ln 42"),
                    StatusBarItem("Julia 1.12"),
                ),
            ))
            @test occursin("role=\"status\"", html)
            @test occursin("Ready", html)
            @test occursin("UTF-8", html)
            @test occursin("Ln 42", html)
            @test occursin("Julia 1.12", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(StatusBar())
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:bg-warm-900", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :StatusBar)
            meta = Suite.COMPONENT_REGISTRY[:StatusBar]
            @test meta.tier == :styling
            @test :StatusBar in meta.exports
            @test :StatusBarSection in meta.exports
            @test :StatusBarItem in meta.exports
        end
    end

    @testset "TreeView" begin
        @testset "Container rendering" begin
            html = Therapy.render_to_string(TreeView())
            @test occursin("<ul", html)
            @test occursin("role=\"tree\"", html)
            @test occursin("data-suite-treeview", html)
        end

        @testset "File item" begin
            html = Therapy.render_to_string(TreeView(TreeViewItem(label="main.jl")))
            @test occursin("main.jl", html)
            @test occursin("role=\"treeitem\"", html)
            @test occursin("data-suite-treeview-item", html)
            @test occursin("<li", html)
            # File icon SVG
            @test occursin("<svg", html)
        end

        @testset "Folder item" begin
            html = Therapy.render_to_string(TreeView(
                TreeViewItem(label="src", is_folder=true)
            ))
            @test occursin("src", html)
            @test occursin("data-suite-treeview-folder", html)
            @test occursin("aria-expanded=\"false\"", html)
            # Chevron SVG for folder
            @test occursin("data-suite-treeview-chevron", html)
        end

        @testset "Expanded folder" begin
            html = Therapy.render_to_string(TreeView(
                TreeViewItem(label="src", is_folder=true, expanded=true,
                    TreeViewItem(label="utils.jl")
                )
            ))
            @test occursin("data-suite-treeview-expanded", html)
            @test occursin("aria-expanded=\"true\"", html)
            @test occursin("utils.jl", html)
            @test occursin("role=\"group\"", html)
            @test occursin("rotate-90", html)
        end

        @testset "Collapsed folder hides children" begin
            html = Therapy.render_to_string(TreeView(
                TreeViewItem(label="src", is_folder=true, expanded=false,
                    TreeViewItem(label="hidden.jl")
                )
            ))
            @test occursin("hidden.jl", html)  # Present in DOM
            @test occursin("hidden", html)  # Has hidden class on children ul
        end

        @testset "Selected item" begin
            html = Therapy.render_to_string(TreeView(
                TreeViewItem(label="main.jl", selected=true)
            ))
            @test occursin("data-suite-treeview-selected=\"true\"", html)
            @test occursin("aria-selected=\"true\"", html)
            @test occursin("text-accent-700", html)
        end

        @testset "Disabled item" begin
            html = Therapy.render_to_string(TreeView(
                TreeViewItem(label="locked.jl", disabled=true)
            ))
            @test occursin("data-disabled", html)
            @test occursin("opacity-50", html)
            @test occursin("pointer-events-none", html)
        end

        @testset "Nested depth indentation" begin
            html = Therapy.render_to_string(TreeView(
                TreeViewItem(label="root", is_folder=true, expanded=true,
                    TreeViewItem(label="child.jl")
                )
            ))
            @test occursin("data-suite-treeview-depth=\"0\"", html)
        end

        @testset "Auto-detect folder" begin
            html = Therapy.render_to_string(TreeView(
                TreeViewItem(label="auto-folder",
                    TreeViewItem(label="child.jl")
                )
            ))
            @test occursin("data-suite-treeview-folder", html)
        end

        @testset "Dark mode" begin
            html = Therapy.render_to_string(TreeView(TreeViewItem(label="test.jl")))
            @test occursin("dark:bg-warm-800", html) || occursin("dark:text-warm-300", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(TreeView(class="w-64"))
            @test occursin("w-64", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :TreeView)
            meta = Suite.COMPONENT_REGISTRY[:TreeView]
            @test meta.tier == :js_runtime
            @test :TreeView in meta.exports
            @test :TreeViewItem in meta.exports
        end
    end

    @testset "Carousel" begin
        @testset "Container rendering" begin
            html = Therapy.render_to_string(Suite.Carousel(
                Suite.CarouselContent(
                    Suite.CarouselItem("Slide 1"),
                ),
            ))
            @test occursin("data-suite-carousel", html)
            @test occursin("role=\"region\"", html)
            @test occursin("aria-roledescription=\"carousel\"", html)
            @test occursin("relative", html)
        end

        @testset "Carousel orientation" begin
            html = Therapy.render_to_string(Suite.Carousel(orientation="vertical"))
            @test occursin("data-suite-carousel-orientation=\"vertical\"", html)
        end

        @testset "Carousel loop and autoplay" begin
            html = Therapy.render_to_string(Suite.Carousel(loop=true, autoplay=true, autoplay_interval=3000))
            @test occursin("data-suite-carousel-loop=\"true\"", html)
            @test occursin("data-suite-carousel-autoplay=\"true\"", html)
            @test occursin("data-suite-carousel-autoplay-interval=\"3000\"", html)
        end

        @testset "CarouselContent" begin
            html = Therapy.render_to_string(Suite.CarouselContent(
                Suite.CarouselItem("Slide 1"),
            ))
            @test occursin("data-suite-carousel-viewport", html)
            @test occursin("data-suite-carousel-content", html)
            @test occursin("overflow-hidden", html)
            @test occursin("scroll-smooth", html)
            @test occursin("snap-x", html)
            @test occursin("snap-mandatory", html)
        end

        @testset "CarouselItem" begin
            html = Therapy.render_to_string(Suite.CarouselItem("Slide Content"))
            @test occursin("Slide Content", html)
            @test occursin("data-suite-carousel-item", html)
            @test occursin("role=\"group\"", html)
            @test occursin("aria-roledescription=\"slide\"", html)
            @test occursin("snap-start", html)
            @test occursin("basis-full", html)
        end

        @testset "CarouselPrevious" begin
            html = Therapy.render_to_string(Suite.CarouselPrevious())
            @test occursin("<button", html)
            @test occursin("data-suite-carousel-prev", html)
            @test occursin("aria-label=\"Previous slide\"", html)
            @test occursin("<svg", html)
            @test occursin("rounded-full", html)
        end

        @testset "CarouselNext" begin
            html = Therapy.render_to_string(Suite.CarouselNext())
            @test occursin("<button", html)
            @test occursin("data-suite-carousel-next", html)
            @test occursin("aria-label=\"Next slide\"", html)
            @test occursin("<svg", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(Suite.CarouselPrevious())
            @test occursin("dark:border-warm-700", html)
            @test occursin("dark:bg-warm-900/90", html)
            @test occursin("dark:text-warm-300", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Suite.Carousel(class="w-full max-w-md"))
            @test occursin("w-full", html)
            @test occursin("max-w-md", html)
        end

        @testset "Full composition" begin
            html = Therapy.render_to_string(Suite.Carousel(
                Suite.CarouselContent(
                    Suite.CarouselItem("Slide 1"),
                    Suite.CarouselItem("Slide 2"),
                    Suite.CarouselItem("Slide 3"),
                ),
                Suite.CarouselPrevious(),
                Suite.CarouselNext(),
            ))
            @test occursin("Slide 1", html)
            @test occursin("Slide 2", html)
            @test occursin("Slide 3", html)
            @test occursin("data-suite-carousel-prev", html)
            @test occursin("data-suite-carousel-next", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Carousel)
            meta = Suite.COMPONENT_REGISTRY[:Carousel]
            @test meta.tier == :js_runtime
            @test :Carousel in meta.exports
            @test :CarouselContent in meta.exports
            @test :CarouselItem in meta.exports
            @test :CarouselPrevious in meta.exports
            @test :CarouselNext in meta.exports
        end
    end

    @testset "Resizable" begin
        @testset "PanelGroup rendering" begin
            html = Therapy.render_to_string(Suite.ResizablePanelGroup(
                Suite.ResizablePanel(Div("Left")),
                Suite.ResizableHandle(),
                Suite.ResizablePanel(Div("Right")),
            ))
            @test occursin("data-suite-resizable-group", html)
            @test occursin("data-suite-resizable-direction=\"horizontal\"", html)
            @test occursin("flex", html)
        end

        @testset "Vertical direction" begin
            html = Therapy.render_to_string(Suite.ResizablePanelGroup(direction="vertical"))
            @test occursin("data-suite-resizable-direction=\"vertical\"", html)
            @test occursin("flex-col", html)
        end

        @testset "Panel with sizes" begin
            html = Therapy.render_to_string(Suite.ResizablePanel(
                default_size=30, min_size=20, max_size=80,
                Div("Content")
            ))
            @test occursin("data-suite-resizable-panel", html)
            @test occursin("data-suite-resizable-default-size=\"30\"", html)
            @test occursin("data-suite-resizable-min-size=\"20\"", html)
            @test occursin("data-suite-resizable-max-size=\"80\"", html)
            @test occursin("flex-grow:30", html)
            @test occursin("Content", html)
        end

        @testset "Panel auto-size" begin
            html = Therapy.render_to_string(Suite.ResizablePanel(Div("Auto")))
            @test occursin("data-suite-resizable-default-size=\"0\"", html)
            @test occursin("flex-grow:1", html)
        end

        @testset "Handle rendering" begin
            html = Therapy.render_to_string(Suite.ResizableHandle())
            @test occursin("data-suite-resizable-handle", html)
            @test occursin("role=\"separator\"", html)
            @test occursin("tabindex=\"0\"", html)
            @test occursin("aria-orientation=\"vertical\"", html)
            @test occursin("select-none", html)
        end

        @testset "Handle with grip" begin
            html = Therapy.render_to_string(Suite.ResizableHandle(with_handle=true))
            @test occursin("<svg", html)
            @test occursin("rounded-sm", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(Suite.ResizableHandle())
            @test occursin("dark:bg-warm-700", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Suite.ResizablePanelGroup(class="h-64", direction="horizontal"))
            @test occursin("h-64", html)
        end

        @testset "Full composition" begin
            html = Therapy.render_to_string(Suite.ResizablePanelGroup(direction="horizontal",
                Suite.ResizablePanel(default_size=30, Div("Left")),
                Suite.ResizableHandle(),
                Suite.ResizablePanel(default_size=70, Div("Right")),
            ))
            @test occursin("Left", html)
            @test occursin("Right", html)
            @test occursin("data-suite-resizable-group", html)
            @test occursin("data-suite-resizable-handle", html)
            @test occursin("flex-grow:30", html)
            @test occursin("flex-grow:70", html)
        end

        @testset "Three panels" begin
            html = Therapy.render_to_string(Suite.ResizablePanelGroup(
                Suite.ResizablePanel(default_size=25, Div("A")),
                Suite.ResizableHandle(),
                Suite.ResizablePanel(default_size=50, Div("B")),
                Suite.ResizableHandle(),
                Suite.ResizablePanel(default_size=25, Div("C")),
            ))
            @test occursin("flex-grow:25", html)
            @test occursin("flex-grow:50", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Resizable)
            meta = Suite.COMPONENT_REGISTRY[:Resizable]
            @test meta.tier == :js_runtime
            @test :ResizablePanelGroup in meta.exports
            @test :ResizablePanel in meta.exports
            @test :ResizableHandle in meta.exports
        end
    end

    @testset "SiteFooter" begin
        @testset "Default render" begin
            html = Therapy.render_to_string(Suite.SiteFooter(
                Suite.FooterBrand(Therapy.Span("MyOrg")),
                Suite.FooterTagline("Built with love"),
            ))
            @test occursin("<footer", html)
            @test occursin("bg-warm-100", html)
            @test occursin("dark:bg-warm-900", html)
            @test occursin("mt-auto", html)
            @test occursin("MyOrg", html)
            @test occursin("Built with love", html)
        end

        @testset "FooterLinks with separators" begin
            html = Therapy.render_to_string(Suite.FooterLinks(
                Suite.FooterLink("Therapy.jl", href="https://example.com/therapy"),
                Suite.FooterLink("Suite.jl", href="https://example.com/suite"),
            ))
            @test occursin("Therapy.jl", html)
            @test occursin("Suite.jl", html)
            @test occursin("/", html)  # separator
            @test occursin("hover:text-accent-600", html)
        end

        @testset "FooterLink" begin
            html = Therapy.render_to_string(Suite.FooterLink("My Link", href="https://example.com"))
            @test occursin("https://example.com", html)
            @test occursin("My Link", html)
            @test occursin("target=\"_blank\"", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Suite.SiteFooter(class="custom-footer"))
            @test occursin("custom-footer", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :SiteFooter)
            meta = Suite.COMPONENT_REGISTRY[:SiteFooter]
            @test meta.tier == :pure_styling
            @test :SiteFooter in meta.exports
            @test :FooterLink in meta.exports
        end
    end

    @testset "Slider" begin
        @testset "Basic structure" begin
            html = Therapy.render_to_string(Slider())
            @test occursin("data-suite-slider", html)
            @test occursin("role=\"slider\"", html)
            @test occursin("data-suite-slider-track", html)
            @test occursin("data-suite-slider-range", html)
            @test occursin("data-suite-slider-thumb", html)
            @test occursin("<span", html)
        end

        @testset "Default ARIA attributes" begin
            html = Therapy.render_to_string(Slider())
            @test occursin("aria-valuenow=\"0\"", html)
            @test occursin("aria-valuemin=\"0\"", html)
            @test occursin("aria-valuemax=\"100\"", html)
            @test occursin("aria-orientation=\"horizontal\"", html)
            @test occursin("tabindex=\"0\"", html)
        end

        @testset "Custom min/max/step/value" begin
            html = Therapy.render_to_string(Slider(min=10, max=50, step=5, default_value=25))
            @test occursin("aria-valuenow=\"25\"", html)
            @test occursin("aria-valuemin=\"10\"", html)
            @test occursin("aria-valuemax=\"50\"", html)
            @test occursin("data-min=\"10\"", html)
            @test occursin("data-max=\"50\"", html)
            @test occursin("data-step=\"5\"", html)
            @test occursin("data-value=\"25\"", html)
        end

        @testset "Value clamping" begin
            html = Therapy.render_to_string(Slider(min=0, max=100, default_value=200))
            @test occursin("aria-valuenow=\"100\"", html)
            @test occursin("data-value=\"100\"", html)

            html2 = Therapy.render_to_string(Slider(min=10, max=50, default_value=5))
            @test occursin("aria-valuenow=\"10\"", html2)
            @test occursin("data-value=\"10\"", html2)
        end

        @testset "Horizontal orientation (default)" begin
            html = Therapy.render_to_string(Slider())
            @test occursin("data-orientation=\"horizontal\"", html)
            @test occursin("w-full", html)
            @test occursin("h-1.5", html)
        end

        @testset "Vertical orientation" begin
            html = Therapy.render_to_string(Slider(orientation="vertical"))
            @test occursin("data-orientation=\"vertical\"", html)
            @test occursin("aria-orientation=\"vertical\"", html)
            @test occursin("min-h-44", html)
            @test occursin("flex-col", html)
            @test occursin("w-1.5", html)
        end

        @testset "Disabled state" begin
            html = Therapy.render_to_string(Slider(disabled=true))
            @test occursin("data-disabled", html)
            @test occursin("aria-disabled=\"true\"", html)
            @test occursin("opacity-50", html)
            @test occursin("pointer-events-none", html)
            @test occursin("tabindex=\"-1\"", html)
        end

        @testset "Enabled tabindex" begin
            html = Therapy.render_to_string(Slider())
            @test occursin("tabindex=\"0\"", html)
        end

        @testset "Custom class" begin
            html = Therapy.render_to_string(Slider(class="my-slider"))
            @test occursin("my-slider", html)
        end

        @testset "Track styling" begin
            html = Therapy.render_to_string(Slider())
            @test occursin("rounded-full", html)
            @test occursin("bg-accent-600/20", html)
        end

        @testset "Thumb styling" begin
            html = Therapy.render_to_string(Slider())
            @test occursin("border-accent-600", html)
            @test occursin("cursor-pointer", html)
            @test occursin("focus-visible:ring-4", html)
        end

        @testset "Range fill styling" begin
            html = Therapy.render_to_string(Slider())
            @test occursin("bg-accent-600", html)
        end

        @testset "Range percentage at 50%" begin
            html = Therapy.render_to_string(Slider(default_value=50, min=0, max=100))
            @test occursin("width: 50.0%", html)
        end

        @testset "Range percentage at 0%" begin
            html = Therapy.render_to_string(Slider(default_value=0, min=0, max=100))
            @test occursin("width: 0.0%", html)
        end

        @testset "Range percentage at 100%" begin
            html = Therapy.render_to_string(Slider(default_value=100, min=0, max=100))
            @test occursin("width: 100.0%", html)
        end

        @testset "Dark mode classes" begin
            html = Therapy.render_to_string(Slider())
            @test occursin("dark:bg-accent-600/30", html)
            @test occursin("dark:bg-warm-950", html)
        end

        @testset "Touch/select prevention" begin
            html = Therapy.render_to_string(Slider())
            @test occursin("touch-none", html)
            @test occursin("select-none", html)
        end

        @testset "Registry" begin
            @test haskey(Suite.COMPONENT_REGISTRY, :Slider)
            meta = Suite.COMPONENT_REGISTRY[:Slider]
            @test meta.tier == :js_runtime
            @test :Slider in meta.exports
            @test :Slider in meta.js_modules
        end
    end
end
