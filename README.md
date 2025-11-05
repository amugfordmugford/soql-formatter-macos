# SOQL Formatter for macOS

A lightweight macOS app that helps Salesforce users format long SOQL queries quickly and cleanly.  
Ideal for admins, developers, and analysts who work with large lists of IDs or email addresses.

## Features

- Automatically formats long SOQL `IN` clauses (e.g. email, ID lists)
- Simple native macOS interface built with Swift and SwiftUI
- Clipboard integration for fast copy/paste between Salesforce and your local tools
- Offline use — no Salesforce connection required

## Example

**Input**
```
SELECT Id, Email FROM Contact WHERE Email IN ('a@x.com','b@y.com','c@z.com')
```

**Formatted Output**
```
SELECT Id, Email
FROM Contact
WHERE Email IN (
  'a@x.com',
  'b@y.com',
  'c@z.com'
)
```

## Build Instructions

1. Clone this repository:
   ```bash
   git clone https://github.com/amugfordmugford/soql-formatter-macos.git
   cd soql-formatter-macos
   ```

2. Open the project in Xcode:
   ```bash
   open SOQLFormatter.xcodeproj
   ```

3. Select your target (My Mac) and click **Run** or **Build**.

## Requirements

- macOS 14 or later  
- Xcode 15 or later  
- Swift 5.9+

## Roadmap

- Customizable indentation and line breaks  
- Format validation for complex SOQL  
- Syntax highlighting  
- Command-line companion tool

## License

MIT License

## Author

**Andrew Mugford**  
Certified Salesforce Administrator  
GitHub: [@amugfordmugford](https://github.com/amugfordmugford)

