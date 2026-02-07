# Dashboard Example — stats cards, data table, and activity feed
#
# Demonstrates Suite.jl components composing into a full dashboard layout.

function DashboardExample()
    Div(:class => "max-w-6xl mx-auto py-8",
        # Header
        Div(:class => "flex items-center justify-between mb-8",
            Div(
                H1(:class => "text-3xl font-serif font-semibold text-warm-800 dark:text-warm-300", "Dashboard"),
                P(:class => "text-warm-600 dark:text-warm-400 mt-1", "Your application overview")
            ),
            Main.Button("Download Report")
        ),

        # Stats cards
        Div(:class => "grid sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8",
            _StatCard("Total Users", "2,847", "+12.5%", true),
            _StatCard("Revenue", "\$48,290", "+8.2%", true),
            _StatCard("Active Sessions", "342", "-3.1%", false),
            _StatCard("Bounce Rate", "24.3%", "-5.4%", true)
        ),

        # Main content grid
        Div(:class => "grid lg:grid-cols-3 gap-6",
            # Data table (2 cols wide)
            Div(:class => "lg:col-span-2",
                Main.Card(
                    Main.CardHeader(
                        Main.CardTitle("Recent Orders"),
                        Main.CardDescription("Your latest transactions")
                    ),
                    Main.CardContent(
                        Main.Table(
                            Main.TableHeader(
                                Main.TableRow(
                                    Main.TableHead("Order"),
                                    Main.TableHead("Customer"),
                                    Main.TableHead("Status"),
                                    Main.TableHead(class="text-right", "Amount")
                                )
                            ),
                            Main.TableBody(
                                _OrderRow("#3210", "Julia Roberts", "Completed", "\$250.00"),
                                _OrderRow("#3209", "Alan Turing", "Processing", "\$150.00"),
                                _OrderRow("#3208", "Ada Lovelace", "Completed", "\$350.00"),
                                _OrderRow("#3207", "Grace Hopper", "Pending", "\$450.00"),
                                _OrderRow("#3206", "Linus Torvalds", "Completed", "\$200.00")
                            )
                        )
                    )
                )
            ),

            # Activity feed (1 col)
            Main.Card(
                Main.CardHeader(
                    Main.CardTitle("Recent Activity"),
                    Main.CardDescription("What's happening in your app")
                ),
                Main.CardContent(
                    Div(:class => "space-y-4",
                        _ActivityItem("New user registered", "Julia Roberts joined the platform", "2 min ago"),
                        _ActivityItem("Order completed", "Order #3210 has been fulfilled", "15 min ago"),
                        _ActivityItem("Payment received", "\$250.00 from Julia Roberts", "15 min ago"),
                        _ActivityItem("New user registered", "Alan Turing joined the platform", "1 hr ago"),
                        _ActivityItem("Settings updated", "Email notifications enabled", "2 hr ago")
                    )
                )
            )
        )
    )
end

function _StatCard(title, value, change, positive)
    change_color = positive ? "text-green-600 dark:text-green-400" : "text-red-600 dark:text-red-400"
    change_icon = positive ? "↑" : "↓"

    Main.Card(
        Main.CardContent(class="pt-6",
            Div(:class => "flex items-center justify-between",
                P(:class => "text-sm font-medium text-warm-600 dark:text-warm-400", title),
                Span(:class => "text-xs $(change_color)", "$(change_icon) $(change)")
            ),
            P(:class => "text-2xl font-bold text-warm-800 dark:text-warm-300 mt-2", value)
        )
    )
end

function _OrderRow(order, customer, status, amount)
    status_variant = if status == "Completed"
        "default"
    elseif status == "Processing"
        "secondary"
    else
        "outline"
    end

    Main.TableRow(
        Main.TableCell(class="font-medium", order),
        Main.TableCell(customer),
        Main.TableCell(Main.Badge(variant=status_variant, status)),
        Main.TableCell(class="text-right font-medium", amount)
    )
end

function _ActivityItem(title, description, time)
    Div(:class => "flex items-start gap-3",
        Div(:class => "w-2 h-2 rounded-full bg-accent-600 dark:bg-accent-400 mt-2 shrink-0"),
        Div(
            P(:class => "text-sm font-medium text-warm-800 dark:text-warm-300", title),
            P(:class => "text-xs text-warm-500 dark:text-warm-500", description),
            P(:class => "text-xs text-warm-400 dark:text-warm-600 mt-1", time)
        )
    )
end

DashboardExample
