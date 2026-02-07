# Form — Suite.jl component docs page
#
# Showcases Form with validation, error messages, and accessibility.


function FormPage()
    ComponentsLayout(
        # Header
        PageHeader("Form", "A form component with per-field validation, error messages, and ARIA accessibility."),

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
        UsageBlock("""using Suite

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
)"""),

        # Component Structure
        Div(:class => "mt-12 space-y-6",
            SectionH2("Component Structure"),
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
            SectionH2("Validation Modes"),
            Div(:class => "overflow-x-auto",
                Main.Table(:class => "w-full text-sm",
                    Main.TableHeader(
                        Main.TableRow(:class => "border-b border-warm-200 dark:border-warm-700",
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Mode"),
                            Main.TableHead(:class => "py-3 px-4 text-left text-warm-800 dark:text-warm-300 font-semibold", "Description")
                        )
                    ),
                    Main.TableBody(
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-300", "\"submit\""),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Validate all fields on form submit (default)")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-300", "\"change\""),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Validate each field as the user types")
                        ),
                        Main.TableRow(:class => "border-b border-warm-200/50 dark:border-warm-700/50",
                            Main.TableCell(:class => "py-3 px-4 font-mono text-xs text-warm-800 dark:text-warm-300", "\"blur\""),
                            Main.TableCell(:class => "py-3 px-4 text-warm-600 dark:text-warm-400", "Validate each field when it loses focus")
                        ),
                    )
                )
            )
        ),

        # API Reference
        Div(:class => "mt-12 space-y-6",
            SectionH2("API Reference"),

            SectionH3("Form"),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("action", "String", "\"\"", "Form action URL"),
                        ApiRow("method", "String", "\"post\"", "Form method"),
                        ApiRow("validate_on", "String", "\"submit\"", "Validation mode: submit, change, or blur"),
                        ApiRow("class", "String", "\"\"", "Additional CSS classes"),
                        ApiRow("theme", "Symbol", ":default", "Theme name"),
                    )
                )
            ),

            SectionH3("FormField"),
            Div(:class => "overflow-x-auto",
                Main.Table(
                    Main.TableHeader(ApiHead()),
                    Main.TableBody(
                        ApiRow("name", "String", "required", "Field name"),
                        ApiRow("required", "Bool", "false", "Whether the field is required"),
                        ApiRow("required_message", "String", "\"This field is required\"", "Custom required error message"),
                        ApiRow("min_length", "Int", "0", "Minimum length (0 = no minimum)"),
                        ApiRow("min_length_message", "String", "\"\"", "Custom min length error message"),
                        ApiRow("max_length", "Int", "0", "Maximum length (0 = no maximum)"),
                        ApiRow("max_length_message", "String", "\"\"", "Custom max length error message"),
                        ApiRow("pattern", "String", "\"\"", "Regex pattern for validation"),
                        ApiRow("pattern_message", "String", "\"\"", "Custom pattern error message"),
                        ApiRow("min", "String", "\"\"", "Minimum value (for number inputs)"),
                        ApiRow("max", "String", "\"\"", "Maximum value (for number inputs)"),
                        ApiRow("custom_message", "String", "\"\"", "Default error message"),
                    )
                )
            ),
        )
    )
end

FormPage
