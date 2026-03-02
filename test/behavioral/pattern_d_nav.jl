# Pattern D — Nav Menus: NavigationMenu, Menubar
# Reference: Thaw Nav, Menu (thaw-behavioral-specs.md)
# Signal: single Int32 + event delegation + ShowDescendants

@testset "Pattern D — Nav Menus" begin

    # =========================================================================
    # NavigationMenu
    # Thaw ref: Nav — click/hover triggers open content panels
    # =========================================================================
    @testset "NavigationMenu" begin
        @testset "SSR structure" begin
            html = render(NavigationMenu(
                NavigationMenuList(
                    NavigationMenuItem(
                        NavigationMenuTrigger("Getting Started"),
                        NavigationMenuContent(
                            NavigationMenuLink("Introduction", href="/docs/"),
                        ),
                    ),
                    NavigationMenuItem(
                        NavigationMenuLink("Documentation", href="/docs/"),
                    ),
                ),
            ))
            @test occursin("Getting Started", html)
            @test occursin("Introduction", html)
            @test occursin("Documentation", html)
            @test occursin("data-nav-menu", html)
            @test occursin("data-nav-menu-list", html)
            @test occursin("data-nav-menu-item", html)
            @test occursin("data-nav-menu-trigger", html)
            @test occursin("data-nav-menu-content", html)
            @test occursin("data-nav-menu-link", html)
        end

        @testset "ARIA" begin
            html = render(NavigationMenu(
                NavigationMenuList(
                    NavigationMenuItem(
                        NavigationMenuTrigger("Products"),
                        NavigationMenuContent(
                            NavigationMenuLink("Widget", href="/widget/"),
                        ),
                    ),
                ),
            ))
            @test occursin("aria-expanded", html)
            @test occursin("aria-haspopup", html)
        end

        @testset "Data state" begin
            html = render(NavigationMenu(
                NavigationMenuList(
                    NavigationMenuItem(
                        NavigationMenuTrigger("Products"),
                        NavigationMenuContent(
                            NavigationMenuLink("Widget", href="/widget/"),
                        ),
                    ),
                ),
            ))
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Trigger is a button" begin
            html = render(NavigationMenuTrigger("Products"))
            @test occursin("<button", html)
            @test occursin("type=\"button\"", html)
        end

        @testset "List structure" begin
            html = render(NavigationMenu(
                NavigationMenuList(
                    NavigationMenuItem(
                        NavigationMenuLink("A", href="/a/"),
                    ),
                ),
            ))
            @test occursin("<ul", html)
            @test occursin("<li", html)
        end

        @testset "Island wrapping" begin
            html = render(NavigationMenu(
                NavigationMenuList(
                    NavigationMenuItem(
                        NavigationMenuTrigger("P"),
                        NavigationMenuContent(
                            NavigationMenuLink("W", href="/w/"),
                        ),
                    ),
                ),
            ))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("NavigationMenu")
            @test has_handler("NavigationMenu")
        end
    end

    # =========================================================================
    # Menubar
    # Thaw ref: Menu — menu role, menubar role, click triggers
    # =========================================================================
    @testset "Menubar" begin
        @testset "SSR structure" begin
            html = render(Menubar(
                MenubarMenu(value="file",
                    MenubarTrigger("File"),
                    MenubarContent(
                        MenubarItem("New Tab"),
                        MenubarItem("New Window"),
                        MenubarSeparator(),
                        MenubarItem("Exit"),
                    ),
                ),
            ))
            @test occursin("File", html)
            @test occursin("New Tab", html)
            @test occursin("New Window", html)
            @test occursin("Exit", html)
        end

        @testset "ARIA — menubar role" begin
            html = render(Menubar(
                MenubarMenu(value="file",
                    MenubarTrigger("File"),
                    MenubarContent(
                        MenubarItem("New Tab"),
                    ),
                ),
            ))
            @test occursin("role=\"menubar\"", html)
            @test occursin("role=\"menu\"", html)
            @test occursin("role=\"menuitem\"", html)
            @test occursin("aria-expanded", html)
            @test occursin("aria-haspopup", html)
        end

        @testset "Data state" begin
            html = render(Menubar(
                MenubarMenu(value="file",
                    MenubarTrigger("File"),
                    MenubarContent(MenubarItem("New")),
                ),
            ))
            @test occursin("data-state=\"closed\"", html)
        end

        @testset "Menubar markers" begin
            html = render(Menubar(
                MenubarMenu(value="file",
                    MenubarTrigger("File"),
                    MenubarContent(MenubarItem("New")),
                ),
            ))
            @test occursin("data-menubar", html)
            @test occursin("data-menubar-trigger", html)
            @test occursin("data-menubar-content", html)
        end

        @testset "Checkbox items" begin
            html = render(Menubar(
                MenubarMenu(value="view",
                    MenubarTrigger("View"),
                    MenubarContent(
                        MenubarCheckboxItem("Status Bar", checked=true),
                    ),
                ),
            ))
            @test occursin("role=\"menuitemcheckbox\"", html)
            @test occursin("aria-checked", html)
        end

        @testset "Island wrapping" begin
            html = render(Menubar(
                MenubarMenu(value="file",
                    MenubarTrigger("File"),
                    MenubarContent(MenubarItem("New")),
                ),
            ))
            @test occursin("therapy-island", html)
        end

        @testset "Wasm structure" begin
            @test wasm_valid("Menubar")
            @test has_handler("Menubar")
        end
    end
end
