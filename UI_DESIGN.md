# Blood Donor Connect — UI design

Eight screens, one shared layout, one shared stylesheet. Attendees build pages out of the classes listed here and do not write new CSS, so five people's pages look like one app.

See also: [PRD.md](PRD.md), [ATTENDEE_TASKS.md](ATTENDEE_TASKS.md), [DB_SCHEMA.md](DB_SCHEMA.md), [specs/](specs/README.md).

## Principles

- **One look.** Every page uses the shared layout and the component classes below. No inline styles, no per-page stylesheets.
- **Readable from the back of the room.** The demo is on a projector: large text, high contrast, one column.
- **Plain HTML first.** Server-rendered ERB, standard forms and links. No JavaScript is needed for any must-ship screen.
- **Never show a phone number on a list.** Phones appear only in a request's responses list, to its creator.

## Styling approach

Plain CSS in `app/assets/stylesheets/application.css`, written by a mentor before the day. No Tailwind, no Bootstrap.

Reason: attendees are reading ERB for the first time, and `class="card"` is easier to explain than fifteen utility classes. If the team prefers Tailwind, keep the same component names and define them with `@apply`.

## Design tokens

```css
:root {
  --color-primary: #b3261e;     /* blood red: nav bar, primary buttons */
  --color-primary-dark: #8c1d18;
  --color-text: #1f1f1f;
  --color-muted: #5f6368;
  --color-bg: #faf8f7;
  --color-surface: #ffffff;
  --color-border: #e0dcd9;
  --color-success-bg: #e6f4ea;
  --color-success-text: #1e6b34;
  --color-error-bg: #fce8e6;
  --color-error-text: #a50e0e;

  --font: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
  --text-base: 18px;
  --text-small: 15px;
  --text-h1: 32px;
  --text-h2: 22px;

  --space-1: 8px;
  --space-2: 16px;
  --space-3: 24px;
  --space-4: 40px;
  --radius: 8px;
  --page-width: 760px;
}
```

## Components

| Class | Use for | Notes |
| --- | --- | --- |
| `.container` | Page wrapper inside the layout | Max width `--page-width`, centred, 16px side padding |
| `.page-title` | The one `<h1>` on each page | |
| `.card` | One donor, one request, one response | White surface, border, `--radius`, 16px padding |
| `.card-list` | Wrapper around a list of cards | Vertical stack, 16px gap |
| `.btn` | Secondary button or link styled as a button | Border, white background |
| `.btn.btn-primary` | The one main action on a page | Red background, white text |
| `.form-field` | Wrapper for a label plus its input | Label above input, 16px below |
| `.form-errors` | Validation error box at the top of a form | Uses the error colours |
| `.filter-bar` | The dropdown and button above a list | One row, wraps on narrow screens |
| `.badge` | Blood group | Bold, red outline, always shows the text (A+, O-) |
| `.meta` | Secondary line of text in a card | `--color-muted`, `--text-small` |
| `.flash.flash-notice` | Success message under the nav | Uses the success colours |
| `.flash.flash-alert` | Error message under the nav | Uses the error colours |
| `.empty-state` | Message when a list has no rows | Centred, muted, with one link to the next action |

Open `/styleguide` in the running app to see every class rendered, with HTML you can copy.

## Shared layout

Built by a mentor in `app/views/layouts/application.html.erb`. Attendees do not edit it.

```
+------------------------------------------------------------------+
| Blood Donor Connect      Requests  Donors  Request blood         |
|                                          My profile   Log out    |
+------------------------------------------------------------------+
| [flash message, if any]                                          |
|                                                                  |
|   <page content inside .container>                               |
|                                                                  |
+------------------------------------------------------------------+
| Demo project built at Rails Girls. Not a real emergency service. |
+------------------------------------------------------------------+
```

Signed out, the nav shows only Log in and Sign up. "My profile" goes to the new-profile form if the user has no profile yet.

## Screens

| # | Screen | Path | View file | Owner |
| --- | --- | --- | --- | --- |
| 1 | Home | `/` | `pages/home.html.erb` | Mentor |
| 2 | Sign up, log in | `/registration/new`, `/session/new` | `registrations/new`, `sessions/new` | Mentor |
| 3 | New donor profile | `/donor_profile/new` | `donor_profiles/new.html.erb` | Module A |
| 4 | Edit donor profile | `/donor_profile/edit` | `donor_profiles/edit.html.erb` | Module A (cut first) |
| 5 | Donors list | `/donors` | `donors/index.html.erb` | Module B |
| 6 | Request blood | `/blood_requests/new` | `blood_requests/new.html.erb` | Module C |
| 7 | Request page | `/blood_requests/:id` | `blood_requests/show.html.erb` | Module C, with partials from D and E |
| 8 | Requests list | `/blood_requests` | `blood_requests/index.html.erb` | Module D |

The paths are a proposal. The mentor who writes `config/routes.rb` has the final say, and this table should be updated to match.

### 1. Home

```
  Blood Donor Connect
  Find blood donors near you, or ask for help.

  [ Request blood ]   [ Become a donor ]

  Demo project built at Rails Girls. Not a real emergency service.
```

Signed out, both buttons go to the log-in page.

### 2. Sign up and log in

```
  Sign up                              Log in

  Name      [______________]           Email     [______________]
  Email     [______________]           Password  [______________]
  Password  [______________]
                                       [ Log in ]
  [ Sign up ]                          New here? Sign up
  Already have an account? Log in
```

After sign-up, the user lands on the new donor profile form with a "Skip for now" link to the requests list.

### 3. New donor profile (Module A)

```
  Become a donor

  [form errors, if any]

  Blood group   [ Select  v ]
  City          [ Select  v ]
  Phone         [______________]
                Shown only to people whose request you respond to.

  [ Save profile ]
```

- Blood group and city are dropdowns from `BLOOD_GROUPS` and `CITIES`, with a blank first option.
- On success: go to the donors list with the flash "You are now listed as a donor."
- On error: show the form again with `.form-errors` and the values the user typed.

### 4. Edit donor profile (Module A, cut first)

Same form as screen 3, plus:

```
  [x] I am available to donate

  [ Update profile ]
```

### 5. Donors list (Module B)

```
  Donors

  Blood group [ All  v ]   City [ All  v ]   [ Filter ]

  +----------------------------------------------+
  | [O+]  Asha Kulkarni                          |
  |       Pune                                   |
  +----------------------------------------------+
  | [A-]  Meera Joshi                            |
  |       Nashik                                 |
  +----------------------------------------------+
```

- The filter is a GET form, so the chosen values appear in the URL and the dropdowns keep their selection.
- The city dropdown is the cut-first task. Without it, the filter bar has one dropdown.
- No phone number, no email.
- Empty state: "No donors match this filter." with a "Clear filter" link.

### 6. Request blood (Module C)

```
  Request blood

  [form errors, if any]

  Patient name    [______________]
  Blood group     [ Select  v ]
  Units needed    [ 1 ]
  Hospital        [______________]
  City            [ Select  v ]
  Needed by       [ dd / mm / yyyy ]
  Contact phone   [______________]
  Note (optional) [______________]
                  [______________]

  [ Post request ]
```

- Units needed is a number field with a minimum of 1. Needed by is a date field.
- On success: go to the request page with the flash "Request posted."

### 7. Request page (Module C, with D and E)

```
  [B+]  2 units needed for Ravi Patil
  Sahyadri Hospital, Pune
  Needed by 12 Oct 2026
  Note: Surgery scheduled for Monday morning.

  ------------------------------------------------
  [ I can help ]                          <- Module E
  ------------------------------------------------
  Responses (2)                           <- Module E, creator only
    Asha Kulkarni    98xxxxxx01
    Meera Joshi      98xxxxxx02
  ------------------------------------------------
  Matching donors (3)                     <- Module D, cut first
    Asha Kulkarni    Pune
    Neha Shah        Pune
```

What each viewer sees:

| Viewer | "I can help" button | Responses list | Matching donors |
| --- | --- | --- | --- |
| The request's creator | Hidden | Shown, with phones | Shown |
| A user who has not responded | Shown | Hidden | Shown |
| A user who has responded | Replaced by "You offered to help" | Hidden | Shown |

Module C leaves marked lines at the bottom of `show.html.erb`; Modules D and E each turn their own lines into a render of their partial (E has two: the button and the list).

Empty responses, for the creator: "No one has responded yet."

### 8. Requests list (Module D)

```
  Blood requests                         [ Request blood ]

  Blood group [ All  v ]   [ Filter ]

  +----------------------------------------------+
  | [B+]  2 units   Sahyadri Hospital, Pune      |
  |       Needed by 12 Oct 2026            View >|
  +----------------------------------------------+
  | [O-]  1 unit    Ruby Hall Clinic, Pune       |
  |       Needed by 14 Oct 2026            View >|
  +----------------------------------------------+
```

- Newest first. The whole card links to the request page.
- No patient name and no contact phone on this list.
- Empty state: "No requests match this filter." with a "Clear filter" link.

## Forms

- Every input has a visible `<label>`. Placeholders are not labels.
- Use Rails form helpers (`form_with`, `form.select`, `form.number_field`, `form.date_field`) so labels and inputs are linked.
- One primary button per form, at the bottom left, with a verb that says what happens ("Post request", not "Submit").
- Errors appear in one `.form-errors` box at the top, as a list of the model's full messages.

## Accessibility

- Text contrast is at least 4.5:1. White on `--color-primary` and `--color-text` on `--color-bg` both pass.
- Blood group is always written as text inside the badge. Colour alone never carries meaning.
- Every page has exactly one `<h1>`, and it matches the nav link that leads there.
- Every button and link is reachable with the Tab key and shows a visible focus outline.

## Out of scope for the UI

Icons, images, dark mode, animations, a mobile-specific layout, and pagination. The single-column layout already works on a phone.
