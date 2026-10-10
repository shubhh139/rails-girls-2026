# Blood Donor Connect — module tech specs

Oct 10, 2026 · Vishwajeetsingh Desurkar

One tech spec per module: what you build, the Rails concepts behind it, the code you should end up with, and how to check and explain it.

See also: [MVC_GUIDE.md](../MVC_GUIDE.md) (read first), [ATTENDEE_TASKS.md](../ATTENDEE_TASKS.md), [DB_SCHEMA.md](../DB_SCHEMA.md), [PRD.md](../PRD.md).

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

Written by mentors in `config/routes.rb`, under the routes the authentication generator added (`resource :session`, `resources :passwords`) and the sign-up route (`resources :users, only: [ :new, :create ]`). Nobody edits this file during the build.

```ruby
# config/routes.rb
root "home#index"
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
| Flash messages (`notice` and `alert`) shown on every page | `app/views/layouts/application.html.erb`, added by a mentor | All |
| `User` associations (`has_one :donor_profile`, `has_many :blood_requests`, `has_many :responses, foreign_key: :donor_id`) | `app/models/user.rb`, added by a mentor | All |

### Coding conventions

- Strong parameters use Rails 8 `params.expect(...)`.
- A failed save re-renders the form with `status: :unprocessable_entity`; a successful save redirects with a `notice:`.
- Partials get their data through locals (`render "responses/list", blood_request: @blood_request`), not instance variables.
- Phone numbers never appear on list pages. A donor's phone appears only in a request's responses list, seen only by the request's creator. The requester's own `contact_phone` appears on the request page (login required), never on lists.
- Generated `belongs_to` lines stay: `rails g model ... user:references` already writes `belongs_to :user`, and `donor:references` writes `belongs_to :donor`, which Module E completes with `class_name: "User"`.
- Partials on the request page (D and E) may run one short query on their `blood_request` local, because the page's controller action belongs to Module C. Prefer a named model method, and do not let an AI move these queries into `show`.

### The request page is shared

`app/views/blood_requests/show.html.erb` belongs to Module C, but Modules D and E add their sections to it. Module C leaves a marked spot at the bottom:

```erb
<%# ===== Modules D and E: add your render lines below. Do not edit above this line. ===== %>
<%# Module D: render "blood_requests/matching_donors", blood_request: @blood_request %>
<%# Module E: render "responses/button", blood_request: @blood_request %>
<%# Module E: render "responses/list", blood_request: @blood_request %>
<%# ===== end of shared spot ===== %>
```

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

The specs rely on all of these. TASKS.md P2–P5 and W1 cover them.

| # | What | Where | Task |
| --- | --- | --- | --- |
| 1 | Authentication generator, plus a sign-up page that collects `name`: `UsersController` `new`/`create` with `allow_unauthenticated_access` and `start_new_session_for`, its view, and `resources :users, only: [ :new, :create ]` | `app/controllers/users_controller.rb`, `app/views/users/` | P2 |
| 2 | `validates :name, presence: true` on User | `app/models/user.rb` | P2 |
| 3 | Layout prints `notice` and `alert`; remove the flash blocks the auth generator puts in `sessions/new.html.erb` and the passwords views, so messages do not show twice; remove `flex` from the generated `<main class="container mx-auto mt-28 px-5 flex">`, or pages A, B and D sit side by side in one row | `app/views/layouts/application.html.erb` | P3 |
| 4 | Nav links: Become a donor (`new_donor_profile_path`), Donors, Requests, Request blood, Log out | Layout | P3 |
| 5 | `HomeController#index` and `app/views/home/index.html.erb` for `root "home#index"`; routes from this file; and empty actions: `donor_profiles` (new, create, edit, update), `donors#index`, `blood_requests` (index, show, new, create), `responses#create` | `config/routes.rb`, `app/controllers/` | P3 |
| 6 | `BLOOD_GROUPS` and `CITIES` | `config/initializers/constants.rb` | P4 |
| 7 | Tailwind is the CSS choice (already in the Gemfile) | | P1 |
| 8 | `User` associations, right after the tables exist; announce "pull main" | `app/models/user.rb` | W1 |
| 9 | Optional: enable Minitest **before** running the authentication generator (uncomment `rails/test_unit/railtie` in `config/application.rb`, add `test/test_helper.rb`), so the generator also creates `test/fixtures/users.yml` and the `sign_in_as` helper, and fix the fixtures generated at W1. The specs' test examples are optional and skipped without this. | `test/` | P1 / W1 |
| 10 | Seeds: every user has a name; made-up phones; a couple of `available: false` donors; donor/request pairs with the same blood group and city, so D3 shows matches; future `needed_by` dates | `db/seeds.rb` | P5 |
