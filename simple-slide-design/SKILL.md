---
name: simple-slide-design
description: Create or redesign presentation slides in a restrained, monochrome, typography-first style with clear executive-level hierarchy. Use for simple, polished, highly readable decks and for removing colorful, card-heavy, visually noisy slide designs.
---

# Simple Slide Design

Create slides that reveal the argument immediately. Use typography, alignment, spacing, and a few quiet surfaces instead of decorative color, borders, shadows, or repeated cards.

Apply the visual system to the user's content. Do not borrow the wording, data, or story from a reference image unless the user explicitly asks for that content.

## Establish the hierarchy first

Classify every element before styling it:

1. Slide title: where the audience is in the story.
2. Takeaway: the single sentence they should remember.
3. Core evidence or decision: the content that proves or implements the takeaway.
4. Supporting explanation: useful after the main point is understood.
5. Reference material or footnote: context that must remain visibly subordinate.

Make the order visible through size and placement. Never allow explanatory text, labels, icons, or decoration to compete with the takeaway.

Preserve the supplied meaning and data unless rewriting is requested. Shorten only redundant wording that blocks comprehension.

## Use a restrained visual system

- Use black, white, and neutral gray by default. Add at most one brand color only when the brief requires it.
- Prefer a white content canvas and a black title slide.
- Use one Korean-capable sans-serif family throughout, such as Pretendard, SUIT, or Noto Sans KR.
- Use font weight and size for emphasis. Do not highlight isolated words with arbitrary colors.
- Avoid shadows, glossy effects, decorative gradients, and outlined cards.
- Use a maximum of one large light-gray surface per slide when it clarifies the main grouping. A comparison may justify two surfaces.
- Separate content with whitespace or a 1 px neutral divider. Do not draw a border around every item.
- Use rounded corners only on a meaningful large surface, not as a universal component style.

For a 1920 x 1080 canvas, start from this scale and adjust only to prevent collisions:

- Cover title: 60-72 px
- Slide title: 50-58 px; keep it on one line when feasible
- Takeaway: 36-42 px
- Major comparison or decision text: 30-40 px
- Section heading: 25-34 px
- Body: 18-22 px
- Supporting evidence: 14-16 px
- Footnote: 13-15 px
- KPI number: 72-92 px

## Make numbers self-explanatory

- Display parallel measures with equal visual weight. If both session count and headcount matter, make both numbers large.
- Place each unit immediately after its number in smaller type: `84 차수`, `1,353 명`.
- Do not separate a number from its unit with unrelated punctuation or a distant column.
- Use tabular numerals when supported and align repeated values consistently.
- Keep qualifiers such as `예정 포함` small and close to the corresponding label.

## Keep supporting evidence subordinate

- Place news examples, citations, model-release timelines, and similar proof near the bottom or side of the slide.
- Label them plainly, for example `참고 사례`, and add one short sentence explaining why they are shown.
- Render reference material smaller and lighter than the main argument.
- Do not center supporting evidence in the dominant visual position.
- For timelines, align the geometric center of every dot with the center of the connecting line. Treat dates and captions as one grouped object beneath each dot.

## Choose one layout idea per slide

Select the structure that matches the slide's job:

- Cover: centered typography on black; one faint contextual watermark at most.
- Metrics: large numbers in an open row, separated by whitespace or thin vertical rules.
- Cause and transition: current state, transition condition, and target state in one horizontal flow.
- Problem and solution: an open problem flow beside one restrained solution surface.
- Comparison: oversized contrasting phrases, followed by one shared solution area.
- Roadmap: borderless editorial columns with thin vertical separators and one shared foundation strip.
- Discussion: two large questions separated by one vertical rule; cards are usually unnecessary.

Vary the layout by purpose while keeping the palette, type scale, and spacing consistent. Do not repeat the same card grid on every slide.

Use numbered circles only for an actual sequence, a fixed set of issues, or discussion questions. Avoid decorative numbering.

## Review with restraint

Before finishing, remove anything that does not improve comprehension:

- extra colors;
- enclosing borders;
- repeated badges and labels;
- oversized arrows or icons;
- unexplained reference material;
- empty boxes created only to fill space;
- supporting text that is larger or darker than the core message.

Check that the main point is understandable within three seconds and that the eye moves in the intended order.

## HTML slide decks

When the deliverable is HTML, read [references/html-slide-patterns.md](references/html-slide-patterns.md). Apply its geometry, interaction, and rendering checks only to HTML presentations.
