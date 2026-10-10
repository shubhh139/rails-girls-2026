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

Written by mentors in `config/routes.rb`, under the routes the authentication generator added (`resource :session`, `resources :passwords`) and the sign-up route (`resource :registration, only: [ :new, :create ]`, so `/registration/new` as in UI_DESIGN.md). Nobody edits this file during the build.

```ruby
# config/routes.rb
root "pages#home"
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
| `Current.user`, the logged-in user | Rails 8 authentication generator | All |
| Login required on every page | `Authentication` concern in `ApplicationController` | All |
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

The specs rely on all of these. TASKS.md P1–P5 and W1 cover them.

### App setup

| # | What | Where | Task |
| --- | --- | --- | --- |
| 1 | Optional: enable Minitest **before** running the authentication generator (uncomment `rails/test_unit/railtie` in `config/application.rb`, add `test/test_helper.rb`), so the generator also creates `test/fixtures/users.yml` and the `sign_in_as` helper; fix the fixtures generated at W1. The specs' test examples are optional and skipped without this. | `test/` | P1 / W1 |
| 2 | Authentication generator, plus sign-up that collects `name`: `RegistrationsController` `new`/`create` with `allow_unauthenticated_access` and `start_new_session_for`, `resource :registration, only: [ :new, :create ]`; after sign-up, redirect to `new_donor_profile_path` (Module A's form has a "Skip for now" link) | `app/controllers/registrations_controller.rb` | P2 |
| 3 | `validates :name, presence: true` on User | `app/models/user.rb` | P2 |
| 4 | Routes from this file; empty actions for `donor_profiles` (new, create, edit, update), `donors#index`, `blood_requests` (index, show, new, create), `responses#create` | `config/routes.rb`, `app/controllers/` | P3 |
| 5 | `BLOOD_GROUPS` and `CITIES` | `config/initializers/constants.rb` | P4 |
| 6 | `User` associations, right after the tables exist; announce "pull main" | `app/models/user.rb` | W1 |
| 7 | Seeds: every user has a name; made-up phones; a couple of `available: false` donors; donor/request pairs with the same blood group and city, so D3 shows matches; future `needed_by` dates | `db/seeds.rb` | P5 |

### UI setup

Everything attendees need so their pages look like [UI_DESIGN.md](../UI_DESIGN.md) by only adding class names.

Status: U1, U2, U5 and U7 are done in the repo (Tailwind removed, `application.css`, home page, `/styleguide`). U3 is done except the login-dependent nav (see the TODO in `app/views/layouts/_nav.html.erb`). U4 and U6 wait for the authentication generator.

| # | What | Where | Task |
| --- | --- | --- | --- |
| U1 | Decide on Tailwind. UI_DESIGN.md uses plain CSS, but `rails new` installed `tailwindcss-rails` and its build is loaded on every page. Either remove it (the gem, the `css:` line in `Procfile.dev`, `app/assets/tailwind/`, `app/assets/builds/tailwind.css`) or keep it and define the same component classes with `@apply` in `app/assets/tailwind/application.css`. | `Gemfile`, `Procfile.dev`, `app/assets/` | P3 |
| U2 | Stylesheet: the design tokens on `:root`; base styles (`body` font, `--text-base` 18px, `--color-bg`, headings, links, a visible `:focus-visible` outline); every component class in the [Components](../UI_DESIGN.md#components) table; nav, flash and footer styles | `app/assets/stylesheets/application.css` | P3 |
| U3 | Layout: replace the generated `<main class="container mx-auto mt-28 px-5 flex">` with the [shared layout](../UI_DESIGN.md#shared-layout): red nav (Blood Donor Connect, Requests, Donors, Request blood, My profile, Log out; signed out only Log in and Sign up), flash as `<div class="flash flash-notice">` / `flash-alert`, `<main class="container">`, and the demo footer. "My profile" goes to `edit_donor_profile_path` if `Current.user.donor_profile` exists, otherwise `new_donor_profile_path`. | `app/views/layouts/application.html.erb` | P3 |
| U4 | Remove the flash blocks the auth generator put in `sessions/new.html.erb` and the passwords views, so messages do not show twice | `app/views/sessions/`, `app/views/passwords/` | P3 |
| U5 | Home page (screen 1): `PagesController#home` with `allow_unauthenticated_access`, title, tagline, "Request blood" and "Become a donor" buttons, demo disclaimer | `app/controllers/pages_controller.rb`, `app/views/pages/home.html.erb` | P3 |
| U6 | Sign up and log in pages (screen 2) restyled with `form-field`, `form-errors`, `btn btn-primary`, and links between the two | `app/views/registrations/new.html.erb`, `app/views/sessions/new.html.erb` | P2 / P3 |
| U7 | A style check page or a quick look at one of each component (card with a badge, filter bar, empty state, form with errors) so attendees can see what each class looks like | Projector at 0:00 | W1 |
