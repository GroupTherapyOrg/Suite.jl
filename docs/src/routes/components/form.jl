# Form — Suite.jl component docs page
#
# Showcases Form with validation, error messages, and accessibility.


function FormApiRow(name, type, default, description)
    Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
        Td(:class => "py-3 px-4 text-accent-600 dark:text-accent-400 font-mono text-xs", name),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", type),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400 font-mono text-xs", default),
        Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", description)
    )
end

function FormPage()
    ComponentsLayout(
        # Header
        Div(:class => "py-8 border-b border-warm-200 dark:border-warm-700 mb-10",
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-3",
                "Form"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A form component with per-field validation, error messages, and ARIA accessibility."
            )
        ),

        # Basic Form
        ComponentPreview(title="Basic Form", description="A simple contact form with required fields.",
            Main.Form(action="/api/contact",
                Main.FormField(name="name",
                    Main.FormItem(
                        Main.FormLabel("Name"),
                        Main.FormControl(
                            Main.Input(type="text", placeholder="Enter your name"),
                        ),
                        Main.FormDescription("Your full name."),
                        Main.FormMessage(),
                    ),
                    required=true,
                ),
                Main.FormField(name="email",
                    Main.FormItem(
                        Main.FormLabel("Email"),
                        Main.FormControl(
                            Main.Input(type="email", placeholder="Enter your email"),
                        ),
                        Main.FormDescription("We'll never share your email."),
                        Main.FormMessage(),
                    ),
                    required=true,
                    pattern="[^@]+@[^@]+",
                    pattern_message="Please enter a valid email address",
                ),
                Main.Button(type="submit", "Submit"),
            )
        ),

        # With Validation Rules
        ComponentPreview(title="With Validation Rules", description="Form fields with min/max length and pattern validation.",
            Main.Form(action="/api/register",
                Main.FormField(name="username",
                    Main.FormItem(
                        Main.FormLabel("Username"),
                        Main.FormControl(
                            Main.Input(type="text", placeholder="Choose a username"),
                        ),
                        Main.FormDescription("Must be 3-20 characters, letters and numbers only."),
                        Main.FormMessage(),
                    ),
                    required=true,
                    min_length=3,
                    max_length=20,
                    pattern="^[a-zA-Z0-9]+\$",
                    pattern_message="Only letters and numbers allowed",
                ),
                Main.FormField(name="bio",
                    Main.FormItem(
                        Main.FormLabel("Bio"),
                        Main.FormControl(
                            Main.Textarea(placeholder="Tell us about yourself...", rows="4"),
                        ),
                        Main.FormDescription("Maximum 500 characters."),
                        Main.FormMessage(),
                    ),
                    max_length=500,
                ),
                Main.Button(type="submit", "Register"),
            )
        ),

        # Live Validation
        ComponentPreview(title="Live Validation (onChange)", description="Validates fields as you type.",
            Main.Form(action="/api/feedback", validate_on="change",
                Main.FormField(name="rating",
                    Main.FormItem(
                        Main.FormLabel("Rating"),
                        Main.FormControl(
                            Main.Input(type="number", placeholder="1-5"),
                        ),
                        Main.FormDescription("Enter a number between 1 and 5."),
                        Main.FormMessage(),
                    ),
                    required=true,
                    min="1",
                    max="5",
                    custom_message="Rating must be between 1 and 5",
                ),
                Main.FormField(name="comment",
                    Main.FormItem(
                        Main.FormLabel("Comment"),
                        Main.FormControl(
                            Main.Textarea(placeholder="Your feedback...", rows="3"),
                        ),
                        Main.FormMessage(),
                    ),
                    required=true,
                    min_length=10,
                    min_length_message="Please provide at least 10 characters of feedback",
                ),
                Main.Button(type="submit", "Send Feedback"),
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Usage"
            ),
            Main.CodeBlock(language="julia", """using Suite

Form(action="/api/submit",
    FormField(name="email",
        FormItem(
            FormLabel("Email"),
            FormControl(
                Input(type="email", placeholder="Enter your email"),
            ),
            FormDescription("We'll never share your email."),
            FormMessage(),
        ),
        required=true,
        pattern="[^@]+@[^@]+",
        pattern_message="Please enter a valid email address",
    ),
    Button(type="submit", "Submit"),
)""")
        ),

        # Component Structure
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Component Structure"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 mb-4",
                "Form fields follow a consistent nesting pattern for accessibility and validation:"
            ),
            Main.CodeBlock(language="julia", """Form(...)               # Form container
    FormField(name=...,     # Field with validation rules
        FormItem(            # Layout wrapper
            FormLabel(...),      # Accessible label
            FormControl(         # Control wrapper (display:contents)
                Input(...),      #   Your actual input/textarea/select
            ),
            FormDescription(...), # Helper text
            FormMessage(),        # Error message (hidden until invalid)
        ),
    )""")
        ),

        # Validation Modes
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "Validation Modes"
            ),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Mode"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Tbody(
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-300", "\"submit\""),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Validate all fields on form submit (default)")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-300", "\"change\""),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Validate each field as the user types")
                        ),
                        Tr(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Td(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-300", "\"blur\""),
                            Td(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Validate each field when it loses focus")
                        ),
                    )
                )
            )
        ),

        # API Reference — Form
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-300 mb-4",
                "API Reference"
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "Form"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Tbody(
                        FormApiRow("action", "String", "\"\"", "Form action URL"),
                        FormApiRow("method", "String", "\"post\"", "Form method"),
                        FormApiRow("validate_on", "String", "\"submit\"", "Validation mode: submit, change, or blur"),
                        FormApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        FormApiRow("theme", "Symbol", ":default", "Theme name"),
                    )
                )
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "FormField"),
            Div(:class => "overflow-x-auto",
                Table(:class => "w-full text-sm",
                    Thead(
                        Tr(:class => "border-b border-warm-200 dark:border-warm-700",
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Prop"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Type"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Default"),
                            Th(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Tbody(
                        FormApiRow("name", "String", "required", "Field name"),
                        FormApiRow("required", "Bool", "false", "Whether the field is required"),
                        FormApiRow("required_message", "String", "\"This field is required\"", "Custom required error message"),
                        FormApiRow("min_length", "Int", "0", "Minimum length (0 = no minimum)"),
                        FormApiRow("min_length_message", "String", "\"\"", "Custom min length error message"),
                        FormApiRow("max_length", "Int", "0", "Maximum length (0 = no maximum)"),
                        FormApiRow("max_length_message", "String", "\"\"", "Custom max length error message"),
                        FormApiRow("pattern", "String", "\"\"", "Regex pattern for validation"),
                        FormApiRow("pattern_message", "String", "\"\"", "Custom pattern error message"),
                        FormApiRow("min", "String", "\"\"", "Minimum value (for number inputs)"),
                        FormApiRow("max", "String", "\"\"", "Maximum value (for number inputs)"),
                        FormApiRow("custom_message", "String", "\"\"", "Default error message"),
                    )
                )
            ),
        )
    )
end

FormPage
