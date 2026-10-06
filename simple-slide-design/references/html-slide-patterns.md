# HTML slide patterns

Use these patterns for fixed-ratio HTML presentation decks. Adapt the values when the source deck already has a coherent system.

## Canvas and spacing

Use a fixed 16:9 design canvas and scale it to the viewport rather than reflowing every slide.

```css
:root {
  --black: #0b0b0c;
  --ink: #161719;
  --muted: #555c63;
  --quiet: #858c93;
  --divider: #d9dde1;
  --surface: #f1f3f4;
  --white: #fcfcfc;
  --deck-scale: 1;
}

.deck {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 1920px;
  height: 1080px;
  overflow: hidden;
  transform: translate(-50%, -50%) scale(var(--deck-scale));
  transform-origin: center;
}

.slide {
  position: absolute;
  inset: 0;
  padding: 62px 96px 32px;
  overflow: hidden;
}
```

Reserve the top for a one-line title, the bottom for a quiet footer, and let the body use the remaining area. For mobile portrait mode, keep the 16:9 slide intact and provide an explicit control that opens or rotates it into landscape presentation mode.

## Numeric rows

Keep the number and its unit in the same inline group. Give parallel measures the same numeric size.

```html
<div class="type-row">
  <span class="type-name">초급</span>
  <span class="type-stat"><strong>84</strong><small>차수</small></span>
  <span class="type-stat"><strong>1,353</strong><small>명</small></span>
</div>
```

```css
.type-stat {
  display: flex;
  align-items: baseline;
  gap: 7px;
  white-space: nowrap;
}

.type-stat strong {
  font-size: 37px;
  font-weight: 820;
  font-variant-numeric: tabular-nums;
}

.type-stat small {
  color: var(--muted);
  font-size: 17px;
}
```

## Reference timelines

Place a reference timeline after the main content and explain its purpose in a small caption. Keep the entire block visually subordinate.

```html
<section class="reference-timeline">
  <p class="reference-caption"><b>참고 사례</b> 기술 변화 속도를 보여주는 사례입니다.</p>
  <div class="timeline-items">
    <div class="signal"><time>9월 초</time><b>Example A</b><small>설명</small></div>
    <div class="signal"><time>3주 뒤</time><b>Example B</b><small>설명</small></div>
  </div>
</section>
```

Align the dot and line centers explicitly. With a 20 px dot and a 2 px line, the following coordinates share a 10 px center:

```css
.timeline-items { position: relative; }
.timeline-items::before { top: 9px; height: 2px; }
.signal::before { top: 0; width: 20px; height: 20px; }
```

If the dot has a border, keep global `box-sizing: border-box` so the rendered diameter remains 20 px.

## Interaction requirements

Unless the user asks for different controls, support:

- `F` for fullscreen;
- left and right arrows and Page Up/Page Down;
- Home and End;
- left/right click navigation without hijacking buttons or links;
- horizontal touch swipe;
- a visible mobile fullscreen button with a CSS rotation fallback when orientation lock is unavailable;
- hash-based direct access when useful;
- keyboard focus styles and `prefers-reduced-motion`.

Keep desktop controls invisible at rest and reveal them on hover or keyboard focus so they do not compete with the slide.

## Visual and functional QA

Render screenshots rather than trusting source inspection alone.

1. Check every slide at 1920 x 1080.
2. Check representative slides at 390 x 844 and 844 x 390.
3. Confirm that titles remain on one line when required.
4. Check `scrollWidth <= clientWidth` and `scrollHeight <= clientHeight` for the active slide and its major content regions.
5. Inspect for clipping, collisions, undersized body text, unintended empty boxes, and visible control chrome.
6. Verify the JavaScript parses and test fullscreen, arrows, click, swipe, Home, and End.
7. Re-render every slide affected by the final CSS change.
