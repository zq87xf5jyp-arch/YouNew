# Culture Screen Restructure Report

## Root Cause

The previous Culture & Attractions screen used broad expandable sections. Images appeared only after expansion, so users could move from city cards to a large unrelated image without a clear reading path. That made the screen feel structurally broken and heavy to scroll.

## Required Flow Implemented

The screen now follows:

Hero

Short introduction

Topic card

Explanation

Source

Next topic

## Fixes Applied

- Replaced separate expandable culture/attraction sections with a single ordered topic flow.
- Removed oversized expanded images from the middle of the scroll.
- Added compact thumbnails only where an article already has verified media.
- Added a consistent explanation block per topic.
- Added compact source buttons per topic.
- Added a "Next topic" cue to preserve context while scrolling.
- Ordered topics from daily culture to communication, cycling, water/canals, museums, markets, then city/place attractions.

## Files Changed

- `YouNew/Views/CultureAttractionsView.swift`

## Scroll Weight Improvements

- Removed expansion state from the screen.
- Removed large per-card image reveal.
- Lowered image target width for thumbnails.
- Reduced section spacing from large section jumps to a lighter topic rhythm.
- Kept the hero as the only large image surface.

## Verification

- Swift parse passed for the changed file.
- Source-level Swift typecheck passed.
- Static QA passed.
- Full Xcode build remains blocked by local `actool` / CoreSimulator runtime failure.

