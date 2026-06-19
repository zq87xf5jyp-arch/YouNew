# History Screen Redesign

Date: 2026-06-13

Status: IMPLEMENTED STATICALLY

Runtime screenshot verification: NOT PERFORMED

## Before

The History of the Netherlands screen behaved like an image dump:

- A large map image dominated the first viewport.
- A separate "Verified images" gallery interrupted the historical narrative.
- Some images consumed most of the visible screen.
- Users had to scroll through media before learning the story.
- The timeline and civic learning content were visually weaker than the images.

## After

The screen is now a guided educational journey:

- Header starts with context, not a full-width image.
- Main experience is a connected nine-period timeline.
- Every period follows the same rhythm: period, story, facts, figures, optional image, learn more.
- Images appear only inside the relevant period and only after the summary.
- Image height is capped at 190 pt normally and 220 pt for accessibility text sizes.
- The standalone image gallery was removed from the main screen.
- Image source metadata remains available in the Sources sheet.

## Layout Diagram

```text
History of the Netherlands
Short intro + 5 min / 9 periods

Timeline overview card
  - 9 periods
  - 3 facts each
  - images capped and story-led

Connected timeline
  Roman Era
    Story
    Key facts
    Key figures
    Learn more

  Middle Ages
    Story
    Key facts
    Key figures
    Learn more

  Burgundian Era
    Story
    Key facts
    Key figures
    Learn more

  Dutch Revolt
    Story
    Key facts
    Key figures
    Image: 1631 map
    Why this image is here
    Learn more

  Dutch Golden Age
    Story
    Key facts
    Key figures
    Image: Amsterdam city view
    Why this image is here
    Learn more

  Napoleonic Era
  Industrial Era
  World Wars

  Modern Netherlands
    Story
    Key facts
    Key figures
    Image: Afsluitdijk
    Why this image is here
    Learn more

Monarchy
Parliament / politics
Society
Glossary
Quiz
Sources
```

## Component Structure

Implemented in `YouNew/Views/NetherlandsHistoryView.swift`.

- `headerSection`
  - compact context header
  - no hero image
  - "5 min" and "9 periods" learning promise

- `guidedHistorySection`
  - replaces the old `timelineSection + historyMediaSection` flow
  - contains overview metrics and the connected timeline

- `HistoryJourneyPeriod`
  - title
  - date range
  - summary
  - three key facts
  - key figures
  - optional image
  - image reason
  - learn-more detail

- `HistoryJourneyPeriodCard`
  - connected left rail
  - story-first hierarchy
  - facts before image
  - optional teaching image capped to compact height
  - Learn More expansion

## Image Policy Applied

Visible images now answer "Why is this image here?"

- Dutch Revolt: 1631 map explains early modern provinces and political geography.
- Golden Age: Amsterdam city view explains urban growth, canals, trade, and city life.
- Modern Netherlands: Afsluitdijk explains water management, engineering, and national planning.

Removed from main flow:

- standalone verified-image gallery
- repeated Golden Age artwork stack
- oversized map-first header

## SwiftUI Implementation Plan

Done:

- Replace image-first header with compact context header.
- Replace gallery section with guided period cards.
- Cap period image height to 190-220 pt.
- Move images below summaries and facts.
- Keep source/attribution data available in the Sources sheet.
- Preserve existing monarchy, politics, society, glossary, and quiz sections after the history journey.

Next runtime check:

- Capture iPhone screenshot at top, middle, and bottom of History screen.
- Confirm no image exceeds 35% of visible viewport.
- Confirm users can understand the nine-period arc without opening sources.
- Confirm Learn More expansion does not create giant empty blocks.

## Pass Criteria

Pass condition: the screen behaves as an interactive timeline experience rather than a gallery.

Current static result: PASS

Runtime visual verification: PENDING
