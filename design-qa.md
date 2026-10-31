# Dark portfolio layout QA

## CV content refresh — 2026-10-31

The user subsequently supplied `/Users/manoel/Developer/curriculum/cv.tex` as the content source. The initial mock and captures below predate that content refresh. The dark layout remains the selected design, while the former historical role and earlier-project copy are intentionally superseded by the CV: Erste Digital (2022–present), Vienna, updated job and education dates, public GitHub projects, skill levels, and languages. The Work navigation and primary action now target `#work` (professional experience), rather than `#projects`.

Inspected the refreshed introduction, current-role panel, experience, software skills, and languages in Chrome. The longer copy fits the existing desktop layout. New definition lists use the existing grid rhythm with one-column mobile rules. Production build, generated-site checks, and rendered-content checks pass. No CV files or personal photographs were copied into the public site. The previous mobile capture verifies the shared layout; a new mobile visual capture for the CV-specific copy has not been taken.

final result: passed

## Visual target and captures

- Source visual truth: `/Users/manoel/.codex/generated_images/01a19125-31b6-7d91-a6d2-55454e4c6ae3/exec-7454abc8-b2b9-4d39-8fd2-18f811f64413.png`.
- Selected direction: option 2, revised to remove all personal photography at the user's request.
- Implementation: `http://127.0.0.1:4000/`, desktop, dark theme, homepage at the top.
- Source pixels: 1435 × 1096; normalized to 1440 × 1100 (under 0.4% adjustment).
- Chrome device toolbar: responsive width 1440, requested height 1100, preview zoom 50%. Native screenshot output included a taller 1778 CSS-pixel capture area, at density 2 (2880 × 3556 pixels). Downsampled proportionally by 2 and compared the same top 1440 × 1100 content region. No browser chrome included. Layout does not depend on viewport height.
- Initial implementation screenshot: `/tmp/manoel-design-qa/desktop.png`.
- Final implementation screenshot: `/tmp/manoel-design-qa/desktop-final.png`.
- Full-view side-by-side evidence, reference left and implementation right: `/tmp/manoel-design-qa/comparison-final.png`.
- Focused writing/background comparison: `/tmp/manoel-design-qa/type-comparison-final.png`.
- Mobile capture: `/tmp/manoel-design-qa/mobile.png`, 390 × 1778 CSS pixels, downsampled from 780 × 3556. The full captured mobile content was inspected along with the article's mobile rendering in Chrome.

## Comparison history

1. Initial comparison found a P2 vertical-rhythm mismatch: the hero divider was approximately 26 pixels lower than the reference, pushing writing down. Reduced label/title/bio gaps and set an explicit button line height. The final capture brings the hero divider close to the reference's 550-pixel position.
2. Initial comparison found a P2 column-proportion mismatch: the background divider was about 26 pixels too far right. Changed the overview grid from 1.3:1 to 1.2:1, retaining the 52-pixel gutter and background inset.
3. Increased summary text from 16 to 18 pixels and constrained its reading measure. Recaptured the updated implementation and opened both the full and focused side-by-side comparisons. The remaining paragraph-wrap difference is minor font-metric polish, not a layout or readability blocker.

## Required fidelity surfaces

- Fonts and typography: locally hosted Inter variable font, system monospace labels, oversized tight headline with a mint period, readable secondary copy, and preserved heading hierarchy. The exact font of the generated mock is unspecified; Inter is a close match. Notes and articles use a narrower reading column and horizontally scrolling code blocks.
- Spacing and layout: horizontal masthead, large text-led hero, writing/background split, fine dividers, and numbered project rows follow the selected target. Mobile becomes one column without clipping navigation or content.
- Colors and tokens: navy `#0f151c`, off-white `#f5f5f2`, slate `#b2bcc9`, mint `#a0e7bf`, and restrained line color. Solid fills replace the mock's incidental generated texture. Text/background contrast is strong; focus outlines and underlines remain visible.
- Images and assets: no personal photographs appear in HTML, feeds, social metadata, or public output. Original photos remain in the source repository. Bootstrap Icons supplies the arrow; its license and the Inter license are included. No generated image is embedded as interface content.
- Copy and content: actual article title/date, existing project data, and historical experience are preserved. Full project descriptions and technologies remain available, rather than removing useful content to match the mock. No current job or location was invented.

## Functional and responsive verification

- Production Jekyll build and generated-site checks passed.
- All generated internal destinations and fragments pass the link checker.
- Keyboard Tab navigation reaches the primary action; Enter changes the URL to `/#projects` and jumps to the project section.
- Notes navigation opens `/posts.html`; the existing article URL renders with the new styling.
- Mobile homepage and article inspected in Chrome at width 390. Header, hero, overview stacking, projects, prose, and code blocks remain readable.
- Chrome Console reports `0 messages in console` after homepage/notes/article navigation. The site itself includes no JavaScript. Local font, CSS, icon, favicon, and page requests returned HTTP 200. A browser extension injected its own script; it is not part of the site.
- Google verification output remains the exact expected token.
- Original photo filenames and `og:image`/`twitter:image` references are absent from generated homepage/notes/feed output.

## Findings

No actionable P0/P1/P2 findings remain.

## Follow-up polish

- P3: Inter's exact glyph metrics and paragraph line breaks differ slightly from the generated target; hierarchy and comfortable reading width are preserved.
- P3: The existing favicon retains its earlier blue accent. This does not affect navigation or layout.

## Implementation checklist

- [x] Implement selected dark layout without personal imagery.
- [x] Preserve routes, content, metadata generation, and verification token.
- [x] Compare source and rendered desktop captures together, then inspect the focused text region.
- [x] Fix layout discrepancies and recapture.
- [x] Verify mobile rendering, navigation, keyboard action, console, and build checks.
- [x] Exclude this QA report and original personal photos from public output.
