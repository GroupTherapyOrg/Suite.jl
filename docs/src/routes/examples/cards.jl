# Cards Example — Various card compositions
#
# Demonstrates how Suite.jl Card components compose with other components
# for common UI patterns: profile, notification, payment, settings.

function CardsExample()
    Div(:class => "max-w-4xl mx-auto py-8",
        # Header
        Div(:class => "mb-10",
            H1(:class => "text-3xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-2", "Cards"),
            P(:class => "text-warm-600 dark:text-warm-400", "Card compositions for common UI patterns.")
        ),

        Div(:class => "grid md:grid-cols-2 gap-6",

            # Profile card
            Main.Card(
                Main.CardHeader(
                    Div(:class => "flex items-center gap-4",
                        Main.Avatar(size="lg",
                            Main.AvatarFallback("JD")
                        ),
                        Div(
                            Main.CardTitle("Julia Developer"),
                            Main.CardDescription("Full-stack Julia engineer")
                        )
                    )
                ),
                Main.CardContent(
                    P(:class => "text-sm text-warm-600 dark:text-warm-400 mb-4",
                        "Building modern web applications with Therapy.jl and Suite.jl. Passionate about reactive programming and the Julia ecosystem."
                    ),
                    Div(:class => "flex gap-4 text-sm",
                        Span(:class => "text-warm-800 dark:text-warm-200",
                            Strong("142"), " ", Span(:class => "text-warm-500 dark:text-warm-500", "Packages")
                        ),
                        Span(:class => "text-warm-800 dark:text-warm-200",
                            Strong("2.8k"), " ", Span(:class => "text-warm-500 dark:text-warm-500", "Stars")
                        ),
                        Span(:class => "text-warm-800 dark:text-warm-200",
                            Strong("1.2k"), " ", Span(:class => "text-warm-500 dark:text-warm-500", "Followers")
                        )
                    )
                ),
                Main.CardFooter(
                    Main.Button(variant="outline", size="sm", "Follow"),
                    Main.Button(variant="ghost", size="sm", "Message")
                )
            ),

            # Notification card
            Main.Card(
                Main.CardHeader(
                    Main.CardTitle("Notifications"),
                    Main.CardDescription("You have 3 unread messages.")
                ),
                Main.CardContent(
                    Div(:class => "space-y-4",
                        _NotificationItem("Your package was published", "Suite.jl v0.2.0 is now on the General registry.", "1 hour ago", true),
                        _NotificationItem("New star on your repo", "TherapeuticJulia/Suite.jl received a star.", "2 hours ago", true),
                        _NotificationItem("CI passed", "All 2172 tests passed on main.", "3 hours ago", false),
                        _NotificationItem("New issue opened", "#42: Add Checkbox component", "5 hours ago", true)
                    )
                ),
                Main.CardFooter(
                    Main.Button(variant="outline", class="w-full", "Mark all as read")
                )
            ),

            # Payment card
            Main.Card(
                Main.CardHeader(
                    Main.CardTitle("Payment Method"),
                    Main.CardDescription("Add a payment method to your account.")
                ),
                Main.CardContent(
                    Div(:class => "grid gap-4",
                        # Card type selection (radio-like)
                        Div(:class => "grid grid-cols-3 gap-3",
                            _PaymentOption("Card", true),
                            _PaymentOption("PayPal", false),
                            _PaymentOption("Apple", false)
                        ),
                        Div(:class => "grid gap-2",
                            Main.Label("Name on card"),
                            Main.Input(placeholder="Julia Developer")
                        ),
                        Div(:class => "grid gap-2",
                            Main.Label("Card number"),
                            Main.Input(placeholder="4242 4242 4242 4242")
                        ),
                        Div(:class => "grid grid-cols-2 gap-4",
                            Div(:class => "grid gap-2",
                                Main.Label("Expires"),
                                Main.Input(placeholder="MM/YY")
                            ),
                            Div(:class => "grid gap-2",
                                Main.Label("CVC"),
                                Main.Input(placeholder="123")
                            )
                        )
                    )
                ),
                Main.CardFooter(
                    Main.Button(class="w-full", "Continue")
                )
            ),

            # Settings card
            Main.Card(
                Main.CardHeader(
                    Main.CardTitle("Settings"),
                    Main.CardDescription("Manage your application preferences.")
                ),
                Main.CardContent(
                    Div(:class => "space-y-4",
                        _SettingsRow("Email notifications", "Receive emails about account activity.", true),
                        Main.Separator(),
                        _SettingsRow("Marketing emails", "Receive emails about new features.", false),
                        Main.Separator(),
                        _SettingsRow("Push notifications", "Receive push notifications on your device.", true),
                        Main.Separator(),
                        _SettingsRow("Dark mode", "Use dark theme across the application.", true)
                    )
                ),
                Main.CardFooter(class="flex justify-end gap-2",
                    Main.Button(variant="outline", "Cancel"),
                    Main.Button("Save changes")
                )
            )
        )
    )
end

function _NotificationItem(title, description, time, unread)
    dot_class = unread ? "bg-accent-600 dark:bg-accent-400" : "bg-warm-300 dark:bg-warm-700"
    Div(:class => "flex items-start gap-3",
        Div(:class => "w-2 h-2 rounded-full $(dot_class) mt-1.5 shrink-0"),
        Div(:class => "flex-1 min-w-0",
            P(:class => "text-sm font-medium text-warm-800 dark:text-warm-200", title),
            P(:class => "text-xs text-warm-500 dark:text-warm-500 mt-0.5", description),
            P(:class => "text-xs text-warm-400 dark:text-warm-600 mt-1", time)
        )
    )
end

function _PaymentOption(label, selected)
    base = "flex items-center justify-center rounded-md border p-3 text-sm font-medium cursor-pointer transition-colors"
    cls = if selected
        "$(base) border-accent-600 dark:border-accent-400 text-accent-600 dark:text-accent-400 bg-accent-50 dark:bg-accent-950"
    else
        "$(base) border-warm-200 dark:border-warm-700 text-warm-600 dark:text-warm-400 hover:bg-warm-100 dark:hover:bg-warm-900"
    end
    Div(:class => cls, label)
end

function _SettingsRow(title, description, enabled)
    Div(:class => "flex items-center justify-between",
        Div(
            P(:class => "text-sm font-medium text-warm-800 dark:text-warm-200", title),
            P(:class => "text-xs text-warm-500 dark:text-warm-500", description)
        ),
        Main.Switch(checked=enabled)
    )
end

CardsExample
