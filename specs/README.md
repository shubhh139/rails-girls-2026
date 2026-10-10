# Blood Donor Connect — module tech specs

Oct 10, 2026 · Vishwajeetsingh Desurkar

One tech spec per module: what you build, the Rails concepts behind it, the code you should end up with, and how to check and explain it.

See also: [MVC_GUIDE.md](../MVC_GUIDE.md) (read first), [ATTENDEE_TASKS.md](../ATTENDEE_TASKS.md), [DB_SCHEMA.md](../DB_SCHEMA.md), [UI_DESIGN.md](../UI_DESIGN.md) (screens and CSS classes), [PRD.md](../PRD.md).

## The specs

| Module | Owner | Spec | Builds |
| --- | --- | --- | --- |
| A. Donor profile | Attendee 1 | [module-a-donor-profile.md](module-a-donor-profile.md) | DonorProfile validations, new and edit profile forms |
| B. Donor directory | Attendee 2 | [module-b-donor-directory.md](module-b-donor-directory.md) | Donors list with blood group and city filters |
| C. Blood requests | Attendee 3 | [module-c-blood-requests.md](module-c-blood-requests.md) | BloodRequest model, request form, request page |
| D. Requests list | Attendee 4 | [module-d-requests-list.md](module-d-requests-list.md) | Requests list with filter, matching donors |
| E. Responses | Attendee 5 | [module-e-responses.md](module-e-responses.md) | Response model, "I can help" button, responses list |

Every spec has the same sections, so you can find things quickly in your own spec and in a teammate's:

1. What you are building
2. Done when
3. Concepts you will use
4. Data you work with
5. URLs and routes
6. Files you own
7. Build steps
8. Privacy and edge cases
9. Testing checklist
10. Working with other modules
11. Common mistakes
12. Explain it
13. Out of scope

## Shared conventions

All five specs depend on these. Mentors set them up before the day. If something here does not match the code on `main`, the code is right; tell a mentor so this file gets fixed.

### Routes

Written by mentors in `config/routes.rb`, under the home, style guide, login (`resource :session, only: [ :new, :create, :destroy ]`) and sign-up (`resource :registration, only: [ :new, :create ]`) routes. Nobody edits this file during the build.

```ruby
# config/routes.rb
resource  :donor_profile, only: [ :new, :create, :edit, :update ]   # Module A
resources :donors, only: [ :index ]                                   # Module B
resources :blood_requests, only: [ :index, :show, :new, :create ] do  # Modules C and D
  resources :responses, only: [ :create ]                             # Module E
end
```

| Verb | Path | Controller#action | Module |
| --- | --- | --- | --- |
| GET | `/donor_profile/new` | `donor_profiles#new` | A |
| POST | `/donor_profile` | `donor_profiles#create` | A |
| GET | `/donor_profile/edit` | `donor_profiles#edit` | A |
| PATCH | `/donor_profile` | `donor_profiles#update` | A |
| GET | `/donors` | `donors#index` | B |
| GET | `/blood_requests/new` | `blood_requests#new` | C |
| POST | `/blood_requests` | `blood_requests#create` | C |
| GET | `/blood_requests/:id` | `blood_requests#show` | C |
| GET | `/blood_requests` | `blood_requests#index` | D |
| POST | `/blood_requests/:blood_request_id/responses` | `responses#create` | E |

### Shared code

| What | Where | Used by |
| --- | --- | --- |
| `Current.user`, the logged-in user; `signed_in?` in views | The app's login: `ApplicationController` (user id in the session cookie), `app/models/current.rb` | All |
| Login required on every page (signed-out visitors go to `/session/new`) | `ApplicationController` (`require_login`; opt out with `allow_unauthenticated_access`) | All |
| `BLOOD_GROUPS = %w[A+ A- B+ B- AB+ AB- O+ O-].freeze` | `config/initializers/constants.rb` | A, B, C, D |
| `CITIES = %w[Pune Mumbai Nashik Nagpur Kolhapur].freeze` | `config/initializers/constants.rb` | A, B, C, D |
| Layout: nav, flash (`.flash.flash-notice`, `.flash.flash-alert`), `.container`, demo footer | `app/views/layouts/application.html.erb`, added by a mentor | All |
| Component classes (`page-title`, `card`, `card-list`, `btn`, `btn-primary`, `form-field`, `form-errors`, `filter-bar`, `badge`, `meta`, `empty-state`) | `app/assets/stylesheets/application.css`, added by a mentor; listed in [UI_DESIGN.md](../UI_DESIGN.md#components) | All |
| `User` associations (`has_one :donor_profile`, `has_many :blood_requests`, `has_many :responses, foreign_key: :donor_id`) | `app/models/user.rb`, added by a mentor | All |

### Coding conventions

- Strong parameters use Rails 8 `params.expect(...)`.
- A failed save re-renders the form with `status: :unprocessable_entity`; a successful save redirects with a `notice:`.
- Partials get their data through locals (`render "responses/list", blood_request: @blood_request`), not instance variables.
- Phone numbers appear in exactly one place: a request's responses list, seen only by the request's creator. The requester's `contact_phone` is stored but not displayed in this PoC.
- Views use only the component classes from [UI_DESIGN.md](../UI_DESIGN.md#components). No Tailwind utility classes, no inline styles, no new CSS. One `<h1 class="page-title">` per page; partials use `<h2>`.
- Forms: errors in one `.form-errors` box at the top, each label and input in a `.form-field`, one `btn btn-primary` submit with a verb ("Post request", not "Submit").
- Generated `belongs_to` lines stay: `rails g model ... user:references` already writes `belongs_to :user`, and `donor:references` writes `belongs_to :donor`, which Module E completes with `class_name: "User"`.
- Partials on the request page (D and E) may run one short query on their `blood_request` local, because the page's controller action belongs to Module C. Prefer a named model method, and do not let an AI move these queries into `show`.

### The request page is shared

`app/views/blood_requests/show.html.erb` belongs to Module C, but Modules D and E add their sections to it. Module C leaves a marked spot at the bottom:

```erb
<%# ===== Modules D and E: add your render lines below. Do not edit above this line. ===== %>
<%# Module E: render "responses/button", blood_request: @blood_request %>
<%# Module E: render "responses/list", blood_request: @blood_request %>
<%# Module D: render "blood_requests/matching_donors", blood_request: @blood_request %>
<%# ===== end of shared spot ===== %>
```

The order follows screen 7 in UI_DESIGN.md: the "I can help" button, then the responses list, then matching donors.

Modules D and E build their partials on their own branches. Each module turns only its own commented lines into real `render` calls, once Module C's page is on `main` (and, for D, once `DonorProfile.matching` is on `main` too). Module C never uncomments another module's line: if that partial is not merged yet, the request page crashes. If D3 is cut, its line stays commented.

## Shared files and merge order

| File | Shared by | Rule |
| --- | --- | --- |
| `app/controllers/blood_requests_controller.rb` | C (`new`, `create`, `show`), D (`index`) | Edit only your own methods. Git merges changes to different methods cleanly. |
| `app/views/blood_requests/show.html.erb` | C owns it; D adds one line, E adds two | Uncomment only your own lines in the marked spot, after C merges. |
| `app/models/blood_request.rb` | C owns it; E needs `has_many :responses` | C adds the line; E checks it is there. |
| `app/models/donor_profile.rb` | A owns it; D3 adds `self.matching` with a mentor | Separate small commit after A merges; A does not edit or remove it. |
| `app/models/user.rb` | Mentor only | Ask a mentor. |

Suggested merge order at 1:30: **C first** (others build on the request page), then **A**, **B**, **D**, and **E** last.

## Mentor checklist before the day

All done on `main`; see the [README](../README.md#what-mentors-have-set-up) for what each piece is and where it lives.

| # | What | Task | Status |
| --- | --- | --- | --- |
| 1 | Login without the generator: `has_secure_password`, session-cookie login at `/session/new`, log out, sign-up at `/registration/new` (collects name, logs in, opens the donor profile form) | P2 | Done |
| 2 | `validates :name, presence: true` and the `User` associations | P2 / W1 | Done |
| 3 | Tailwind removed; shared stylesheet with tokens and every component class | P3 | Done |
| 4 | Layout: nav (signed-in and signed-out links, "My profile" target, Log out button), flash, `.container`, demo footer | P3 | Done |
| 5 | Home page (screen 1), styled log-in and sign-up pages (screen 2), `/styleguide` | P3 | Done |
| 6 | Routes from this file; controllers with empty actions; placeholder views | P3 | Done |
| 7 | `BLOOD_GROUPS` and `CITIES` in `config/initializers/constants.rb` | P4 | Done |
| 8 | Tables and migrations (walk through them at 0:00 instead of creating them live) | W1 | Done |
| 9 | Seeds: named users with password "password", 2 unavailable donors, matching donor/request pairs, future dates, made-up phones | P5 | Done |

There is no test suite: Minitest is not enabled, and the specs check everything by hand (console and browser).
