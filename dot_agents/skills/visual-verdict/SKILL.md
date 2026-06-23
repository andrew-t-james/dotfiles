---
name: visual-verdict
description: Structured visual QA verdict for screenshot-to-reference comparisons
---

# Visual Verdict

Use this skill to compare a generated UI screenshot against one or more reference images and produce a strict, actionable visual QA verdict.

## Inputs

- `reference_images`: one or more image paths.
- `generated_screenshot`: the current implementation screenshot.
- Optional `category_hint`: dashboard, landing page, editor, game, mobile app, etc.

## Procedure

1. Compare layout, hierarchy, spacing, typography, colors, assets, and responsive framing.
2. Separate visual mismatches from functional assumptions.
3. Give concrete edits tied to observable differences.
4. If the score is below the pass threshold, use the verdict to drive the next edit iteration.

## Output Contract

Return JSON only:

```json
{
  "score": 0,
  "verdict": "revise",
  "category_match": false,
  "differences": ["..."],
  "suggestions": ["..."],
  "reasoning": "short explanation"
}
```

## Scoring

- `90-100`: pass; only minor polish remains.
- `75-89`: revise; recognizable but important details differ.
- `50-74`: fail; major layout or style mismatches.
- `<50`: fail; wrong category, broken render, or unusable comparison.

Use pixel diffs as a secondary debugging aid when available, but the final verdict should name human-visible issues and concrete fixes.
