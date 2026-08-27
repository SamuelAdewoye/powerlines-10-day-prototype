# Powerlines Mobile Delivery Strategy

## Decision

Deliver the current 10-day prototype as an **installable, mobile-first progressive web app (PWA)**. This preserves the existing local-first writing model, supports direct installation from a mobile browser, and allows the user to validate the experience before a separate App Store or Play Store build is commissioned.

## Why this route fits the prototype

The 10-day Powerlines practice already uses browser-local persistence and a responsive single-column reading experience. A PWA makes that experience available from a home-screen icon without requiring an account, a cloud backend, or platform-specific distribution at this stage. The service worker caches the app shell and the brand mark; reflections and Power Move commitments remain private in local storage.

## Native escalation path

If native distribution, push notifications, App Store packaging, or encrypted device storage are required after prototype validation, migrate the same content model and interaction order into a dedicated Expo application. Preserve the same daily flow, dashboard, streak calculation, and strict visual system.

## Mobile acceptance criteria

- Installable from supported iOS and Android browsers as a standalone home-screen experience.
- Usable at 375px width with comfortable writing fields and touch targets.
- Capable of reopening the app shell without a network connection after the first visit.
- Keeps reflections, Power Moves, completion timestamps, and streak evidence in the device browser.
