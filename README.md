# GetUK Support — osTicket branding kit

Branding for a stock **osTicket v1.18.4** install: client portal, staff control
panel, logo and landing page copy.

Built and rendered against a real osTicket 1.18.4 install on PHP 8.3 / MySQL 8
before delivery — every screenshot in `screenshots/` is the actual thing running,
not a mockup.

## Palette

Taken from getuk.support rather than invented:

| | hex | used for |
|---|---|---|
| Red | `#e31837` | primary actions, active tab, accents |
| Navy | `#07072f` | header bar, headings |
| Cream | `#f4f1eb` | page background, table headers |
| Line | `#e4e1da` | borders |
| Ink | `#111111` | body copy |

## What's in here

```
css/getuk.css          client portal (assets/default/css/)
css/getuk-scp.css      staff control panel (scp/css/)
content/landing-page.html   landing page copy
content/getuk-logo.png      logo, 698x231 png with transparency
apply-branding.sh      installs the above into an osTicket tree
```

## Install

```bash
./apply-branding.sh /path/to/osticket/upload
```

Then two things in the admin UI, which the script deliberately does **not** do
because doing them there means they survive upgrades:

1. **Logo** — Admin Panel → Settings → Pages → upload `content/getuk-logo.png`,
   then tick it for *both* Landing Page Logo and Staff Panel Logo.
2. **Landing page** — Admin Panel → Manage → Pages → Landing, paste
   `content/landing-page.html` via the editor's source view.

## Design notes

Both stylesheets are **additive**. They only override; nothing is deleted from
osTicket's own CSS, and deleting these two files returns the install to stock.

A few decisions worth knowing about:

- **The staff panel is deliberately barely touched.** It's a dense working tool,
  so only the chrome is re-coloured — header, tabs, links, buttons. Every table,
  form and dialog keeps its stock layout. Restyling the agent queue makes it
  prettier and slower to use.
- **One primary action per screen.** Stock osTicket ships a blue *Open a New
  Ticket* next to a green *Check Ticket Status*, which gives equal weight to two
  different things. Primary is now red, secondary is a quiet outline.
- **Reset and Cancel are not red.** In stock they inherit the submit styling, so
  "Cancel" looked exactly as inviting as "Create Ticket".
- **Sortable column headers stay navy.** An earlier pass made every link red and
  turned the ticket queue into a wall of red text.
- **The osTicket credit in the footer stays.** osTicket is GPL and the
  attribution is part of the licence — it's just toned down.

## Mobile

The client portal is checked at 390px. osTicket's stock CSS puts a fixed pixel
width on the landing column, which pushes copy off-screen on a phone; the
stylesheet makes it fluid and reorders the header so the logo sits above the
sign-in line rather than under it. Verified `document.scrollWidth == innerWidth`,
i.e. no horizontal scroll.

## After an osTicket upgrade

Re-run `apply-branding.sh`. An upgrade replaces the two header templates and
drops the `<link>` lines; the stylesheets themselves are untouched. The script
is idempotent, so re-running it when nothing is missing does nothing.
