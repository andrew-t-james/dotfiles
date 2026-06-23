---
name: web-clone
description: URL-driven website cloning with visual and functional verification
---

# Web Clone

Use this skill when the user provides a URL and wants a working single-page clone of that page's visible layout and core interactions.

## Scope

Included:

- Single-page layout, typography, spacing, color, and component structure.
- Core visible interactions such as menus, toggles, tabs, modals, links, and forms.
- Responsive behavior for the main desktop and mobile breakpoints.

Excluded unless explicitly requested:

- Authentication, payment, backend API parity, private content, and personalized data.
- Multi-page crawling.
- Exact third-party widget behavior.
- Trademark or copyrighted reuse without permission.

## Procedure

1. Open the target URL with the available browser automation tool.
2. Capture the semantic structure, visible content, computed styles, and a baseline screenshot.
3. Identify page regions, design tokens, components, and interactions.
4. Build the clone using the current project's stack or the simplest local static stack when no project exists.
5. Serve or open the clone locally.
6. Capture a generated screenshot.
7. Run `visual-verdict` against the baseline screenshot.
8. Spot-check two or three core interactions.
9. Iterate until visual and functional checks pass or the remaining gaps are clearly reported.

## Verification

Use a composite verdict:

```json
{
  "visual": {
    "score": 0,
    "verdict": "revise",
    "differences": ["..."],
    "suggestions": ["..."]
  },
  "functional": {
    "tested": 0,
    "passed": 0,
    "failures": ["..."]
  },
  "structure": {
    "landmark_match": false,
    "missing": ["..."],
    "extra": ["..."]
  },
  "overall_verdict": "revise",
  "priority_fixes": ["..."]
}
```

Pass when visual score is at least 85, tested interactions pass, and major landmarks are present.
