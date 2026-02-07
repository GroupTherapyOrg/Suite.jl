# Form — Suite.jl component docs page
#
# Showcases SuiteForm with validation, error messages, and accessibility.

const FM_SuiteForm = Main.SuiteForm
const FM_SuiteFormField = Main.SuiteFormField
const FM_SuiteFormItem = Main.SuiteFormItem
const FM_SuiteFormLabel = Main.SuiteFormLabel
const FM_SuiteFormControl = Main.SuiteFormControl
const FM_SuiteFormDescription = Main.SuiteFormDescription
const FM_SuiteFormMessage = Main.SuiteFormMessage
const FM_SuiteInput = Main.SuiteInput
const FM_SuiteTextarea = Main.SuiteTextarea
const FM_SuiteButton = Main.SuiteButton

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
            H1(:class => "text-4xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-3",
                "Form"
            ),
            P(:class => "text-lg text-warm-600 dark:text-warm-300",
                "A form component with per-field validation, error messages, and ARIA accessibility."
            )
        ),

        # Basic Form
        ComponentPreview(title="Basic Form", description="A simple contact form with required fields.",
            FM_SuiteForm(action="/api/contact",
                FM_SuiteFormField(name="name",
                    FM_SuiteFormItem(
                        FM_SuiteFormLabel("Name"),
                        FM_SuiteFormControl(
                            FM_SuiteInput(type="text", placeholder="Enter your name"),
                        ),
                        FM_SuiteFormDescription("Your full name."),
                        FM_SuiteFormMessage(),
                    ),
                    required=true,
                ),
                FM_SuiteFormField(name="email",
                    FM_SuiteFormItem(
                        FM_SuiteFormLabel("Email"),
                        FM_SuiteFormControl(
                            FM_SuiteInput(type="email", placeholder="Enter your email"),
                        ),
                        FM_SuiteFormDescription("We'll never share your email."),
                        FM_SuiteFormMessage(),
                    ),
                    required=true,
                    pattern="[^@]+@[^@]+",
                    pattern_message="Please enter a valid email address",
                ),
                FM_SuiteButton(type="submit", "Submit"),
            )
        ),

        # With Validation Rules
        ComponentPreview(title="With Validation Rules", description="Form fields with min/max length and pattern validation.",
            FM_SuiteForm(action="/api/register",
                FM_SuiteFormField(name="username",
                    FM_SuiteFormItem(
                        FM_SuiteFormLabel("Username"),
                        FM_SuiteFormControl(
                            FM_SuiteInput(type="text", placeholder="Choose a username"),
                        ),
                        FM_SuiteFormDescription("Must be 3-20 characters, letters and numbers only."),
                        FM_SuiteFormMessage(),
                    ),
                    required=true,
                    min_length=3,
                    max_length=20,
                    pattern="^[a-zA-Z0-9]+\$",
                    pattern_message="Only letters and numbers allowed",
                ),
                FM_SuiteFormField(name="bio",
                    FM_SuiteFormItem(
                        FM_SuiteFormLabel("Bio"),
                        FM_SuiteFormControl(
                            FM_SuiteTextarea(placeholder="Tell us about yourself...", rows="4"),
                        ),
                        FM_SuiteFormDescription("Maximum 500 characters."),
                        FM_SuiteFormMessage(),
                    ),
                    max_length=500,
                ),
                FM_SuiteButton(type="submit", "Register"),
            )
        ),

        # Live Validation
        ComponentPreview(title="Live Validation (onChange)", description="Validates fields as you type.",
            FM_SuiteForm(action="/api/feedback", validate_on="change",
                FM_SuiteFormField(name="rating",
                    FM_SuiteFormItem(
                        FM_SuiteFormLabel("Rating"),
                        FM_SuiteFormControl(
                            FM_SuiteInput(type="number", placeholder="1-5"),
                        ),
                        FM_SuiteFormDescription("Enter a number between 1 and 5."),
                        FM_SuiteFormMessage(),
                    ),
                    required=true,
                    min="1",
                    max="5",
                    custom_message="Rating must be between 1 and 5",
                ),
                FM_SuiteFormField(name="comment",
                    FM_SuiteFormItem(
                        FM_SuiteFormLabel("Comment"),
                        FM_SuiteFormControl(
                            FM_SuiteTextarea(placeholder="Your feedback...", rows="3"),
                        ),
                        FM_SuiteFormMessage(),
                    ),
                    required=true,
                    min_length=10,
                    min_length_message="Please provide at least 10 characters of feedback",
                ),
                FM_SuiteButton(type="submit", "Send Feedback"),
            )
        ),

        # Usage
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Usage"
            ),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """using Suite

SuiteForm(action="/api/submit",
    SuiteFormField(name="email",
        SuiteFormItem(
            SuiteFormLabel("Email"),
            SuiteFormControl(
                SuiteInput(type="email", placeholder="Enter your email"),
            ),
            SuiteFormDescription("We'll never share your email."),
            SuiteFormMessage(),
        ),
        required=true,
        pattern="[^@]+@[^@]+",
        pattern_message="Please enter a valid email address",
    ),
    SuiteButton(type="submit", "Submit"),
)""")
                )
            )
        ),

        # Component Structure
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "Component Structure"
            ),
            P(:class => "text-warm-600 dark:text-warm-400 mb-4",
                "Form fields follow a consistent nesting pattern for accessibility and validation:"
            ),
            Div(:class => "bg-warm-800 dark:bg-warm-950 rounded-md border border-warm-700 p-6 overflow-x-auto",
                Pre(:class => "text-sm text-warm-50",
                    Code(:class => "language-julia", """SuiteForm(...)               # Form container
    SuiteFormField(name=...,     # Field with validation rules
        SuiteFormItem(            # Layout wrapper
            SuiteFormLabel(...),      # Accessible label
            SuiteFormControl(         # Control wrapper (display:contents)
                SuiteInput(...),      #   Your actual input/textarea/select
            ),
            SuiteFormDescription(...), # Helper text
            SuiteFormMessage(),        # Error message (hidden until invalid)
        ),
    )""")
                )
            )
        ),

        # Validation Modes
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
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

        # API Reference — SuiteForm
        Div(:class => "mt-12 space-y-6",
            H2(:class => "text-2xl font-serif font-semibold text-warm-800 dark:text-warm-50 mb-4",
                "API Reference"
            ),

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "SuiteForm"),
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

            H3(:class => "text-lg font-semibold text-warm-800 dark:text-warm-300 mt-6 mb-3", "SuiteFormField"),
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
