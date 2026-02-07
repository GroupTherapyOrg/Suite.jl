# Forms Example — Login, signup, and settings forms
#
# Demonstrates Suite.jl form components composing together for common patterns.

function FormsExample()
    Div(:class => "max-w-4xl mx-auto py-8",
        # Header
        Div(:class => "mb-10",
            H1(:class => "text-3xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-2", "Forms"),
            P(:class => "text-warm-600 dark:text-warm-400", "Login, signup, and settings form compositions.")
        ),

        Div(:class => "grid md:grid-cols-2 gap-6",

            # Login form
            Main.Card(
                Main.CardHeader(class="text-center",
                    Main.CardTitle(class="text-2xl", "Welcome back"),
                    Main.CardDescription("Sign in to your account")
                ),
                Main.CardContent(
                    Div(:class => "grid gap-4",
                        Div(:class => "grid gap-2",
                            Main.Label("Email"),
                            Main.Input(type="email", placeholder="you@example.com")
                        ),
                        Div(:class => "grid gap-2",
                            Div(:class => "flex items-center justify-between",
                                Main.Label("Password"),
                                A(:href => "#", :class => "text-xs text-accent-600 dark:text-accent-400 hover:underline", "Forgot password?")
                            ),
                            Main.Input(type="password", placeholder="Enter your password")
                        ),
                        Main.Button(class="w-full", "Sign In")
                    )
                ),
                Main.CardFooter(class="justify-center",
                    P(:class => "text-sm text-warm-500 dark:text-warm-500",
                        "Don't have an account? ",
                        A(:href => "#", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Sign up")
                    )
                )
            ),

            # Signup form
            Main.Card(
                Main.CardHeader(class="text-center",
                    Main.CardTitle(class="text-2xl", "Create an account"),
                    Main.CardDescription("Enter your details to get started")
                ),
                Main.CardContent(
                    Div(:class => "grid gap-4",
                        Div(:class => "grid grid-cols-2 gap-4",
                            Div(:class => "grid gap-2",
                                Main.Label("First name"),
                                Main.Input(placeholder="Julia")
                            ),
                            Div(:class => "grid gap-2",
                                Main.Label("Last name"),
                                Main.Input(placeholder="Developer")
                            )
                        ),
                        Div(:class => "grid gap-2",
                            Main.Label("Email"),
                            Main.Input(type="email", placeholder="you@example.com")
                        ),
                        Div(:class => "grid gap-2",
                            Main.Label("Password"),
                            Main.Input(type="password", placeholder="Choose a strong password")
                        ),
                        Div(:class => "grid gap-2",
                            Main.Label("Confirm password"),
                            Main.Input(type="password", placeholder="Confirm your password")
                        ),
                        Main.Button(class="w-full", "Create Account")
                    )
                ),
                Main.CardFooter(class="justify-center",
                    P(:class => "text-sm text-warm-500 dark:text-warm-500",
                        "Already have an account? ",
                        A(:href => "#", :class => "text-accent-600 dark:text-accent-400 hover:underline", "Sign in")
                    )
                )
            ),

            # Profile settings form (spans full width)
            Div(:class => "md:col-span-2",
                Main.Card(
                    Main.CardHeader(
                        Main.CardTitle("Profile Settings"),
                        Main.CardDescription("Update your personal information and preferences.")
                    ),
                    Main.CardContent(
                        Div(:class => "grid gap-6",
                            # Personal info section
                            Div(:class => "grid gap-4",
                                SectionH3("Personal Information"),
                                Div(:class => "grid sm:grid-cols-2 gap-4",
                                    Div(:class => "grid gap-2",
                                        Main.Label("Display name"),
                                        Main.Input(placeholder="Julia Developer")
                                    ),
                                    Div(:class => "grid gap-2",
                                        Main.Label("Email"),
                                        Main.Input(type="email", placeholder="you@example.com")
                                    )
                                ),
                                Div(:class => "grid gap-2",
                                    Main.Label("Bio"),
                                    Main.Textarea(placeholder="Tell us about yourself...", class="min-h-24")
                                ),
                                Div(:class => "grid sm:grid-cols-2 gap-4",
                                    Div(:class => "grid gap-2",
                                        Main.Label("Website"),
                                        Main.Input(type="url", placeholder="https://yoursite.com")
                                    ),
                                    Div(:class => "grid gap-2",
                                        Main.Label("GitHub"),
                                        Main.Input(placeholder="@username")
                                    )
                                )
                            ),

                            Main.Separator(),

                            # Notification preferences
                            Div(:class => "grid gap-4",
                                SectionH3("Notifications"),
                                Div(:class => "space-y-4",
                                    _FormSettingsRow("Email digest", "Receive a weekly summary of activity.", true),
                                    _FormSettingsRow("Push notifications", "Get notified about important updates.", true),
                                    _FormSettingsRow("Marketing emails", "Hear about new features and tips.", false)
                                )
                            ),

                            Main.Separator(),

                            # Danger zone
                            Div(:class => "grid gap-4",
                                H3(:class => "text-lg font-medium text-red-600 dark:text-red-400", "Danger Zone"),
                                P(:class => "text-sm text-warm-600 dark:text-warm-400",
                                    "Once you delete your account, there is no going back. Please be certain."
                                ),
                                Main.Button(variant="destructive", size="sm", "Delete Account")
                            )
                        )
                    ),
                    Main.CardFooter(class="flex justify-end gap-2 border-t border-warm-200 dark:border-warm-700 pt-6",
                        Main.Button(variant="outline", "Cancel"),
                        Main.Button("Save Changes")
                    )
                )
            )
        )
    )
end

function _FormSettingsRow(title, description, enabled)
    Div(:class => "flex items-center justify-between",
        Div(
            P(:class => "text-sm font-medium text-warm-800 dark:text-warm-300", title),
            P(:class => "text-xs text-warm-500 dark:text-warm-500", description)
        ),
        Main.Switch(checked=enabled)
    )
end

FormsExample
