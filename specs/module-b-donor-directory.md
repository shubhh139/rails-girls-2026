# Module B: Donor directory — tech spec

Oct 10, 2026 · Vishwajeetsingh Desurkar

You build `/donors`, a read-only page that lists available donors (name, blood group, city, never phone) and narrows the list with a blood group filter and, if time allows, a city filter.

See also: [../ATTENDEE_TASKS.md](../ATTENDEE_TASKS.md) for the task list, [../MVC_GUIDE.md](../MVC_GUIDE.md) for how models, views and controllers fit together, [../DB_SCHEMA.md](../DB_SCHEMA.md) for the tables, and [../UI_DESIGN.md](../UI_DESIGN.md) for the page design and the CSS classes you may use.

## What you are building

A signed-in user who needs blood (or wants to see who is out there) clicks **Donors** in the nav bar and sees a list of people who have filled in a donor profile.

This is [screen 5 in UI_DESIGN.md](../UI_DESIGN.md#5-donors-list-module-b):

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

- **One screen:** `app/views/donors/index.html.erb`, served by `DonorsController#index`.
- **Each card:** a blood group badge, the donor's name, and the city on a second line. Never the phone number, never the email.
- **Filters:** pick a blood group (and a city, in B3), click Filter, and the list shrinks to matching donors. The choice stays selected after the page reloads. Without B3 the filter bar has only the blood group dropdown.
- **Empty state:** if nothing matches, the page says "No donors match this filter." with a "Clear filter" link.
- **Styling:** the mentors' layout already gives you the nav bar, the flash message and the `.container` that sets the page width. Your page uses only the component classes from [UI_DESIGN.md](../UI_DESIGN.md#components) (`page-title`, `filter-bar`, `card-list`, `card`, `badge`, `meta`, `empty-state`, `btn`). No Tailwind classes, no inline styles, no new CSS.

In the demo journey you are **step 2**: Module A's donor has just created a profile, and you show that the same person now appears in the list when you filter by that blood group.

## Done when

- [ ] B1: `/donors` lists every available donor as a card with a blood group badge, the name and the city.
- [ ] B1: no phone number appears anywhere on the page (check with the browser's "View source" and search for a phone you know).
- [ ] B2: choosing O+ and clicking Filter shows only O+ donors; choosing "All" shows everyone.
- [ ] B2: after filtering, the dropdown still shows the group you picked, and the URL looks like `/donors?blood_group=O%2B`.
- [ ] B2: when nothing matches, you see "No donors match this filter." and a "Clear filter" link instead of a blank page.
- [ ] B3 (cut first): the city dropdown works on its own and together with blood group (O+ and Pune shows only O+ donors in Pune).
- [ ] The page matches [screen 5 of UI_DESIGN.md](../UI_DESIGN.md#5-donors-list-module-b): one `<h1 class="page-title">Donors</h1>`, a `filter-bar` with visible labels, a `card-list` of cards each with a `badge`, and the `empty-state` box. No Tailwind classes or inline styles.
- [ ] B4: you have explained the query and the view to a mentor, and the mentor signed off.

## Concepts you will use

| Concept | What it is in one line | Where you use it in this module |
| --- | --- | --- |
| Controller action | A method that handles one URL | `DonorsController#index` |
| Instance variable | An `@name` set in the controller and read in the view | `@donors` |
| Active Record query | Ruby methods that Rails turns into SQL | `DonorProfile.where(...)`, `.order(...)` |
| Association | A link between two models | `donor.user.name` uses `DonorProfile belongs_to :user` |
| `includes` (eager loading) | Load related rows in one extra query instead of one per row | `DonorProfile.includes(:user)` |
| Lazy, chainable relations | A query is only built, not run, until the view needs the rows | adding `.where` only when a filter is chosen |
| `params` and query strings | The `?key=value` part of a URL arrives in `params` | `params[:blood_group]`, `params[:city]` |
| GET form | A form that puts its fields in the URL instead of saving anything | the filter form |
| ERB loop and `if` | `<% %>` runs Ruby, `<%= %>` prints it | looping over `@donors`, the empty state |
| Component classes | Ready-made CSS class names from [UI_DESIGN.md](../UI_DESIGN.md#components) | `card`, `badge`, `filter-bar`, `empty-state` |

Basics of each layer are in [MVC_GUIDE.md: The Controller](../MVC_GUIDE.md#the-controller) and [The View](../MVC_GUIDE.md#the-view). The five that matter most here:

**A controller does not need a model with the same name.** There is no `Donor` model and no `donors` table. A "donor" is simply a `DonorProfile` row plus the `User` it belongs to. The URL `/donors` is named after what the user sees (a list of donors), and the controller is named after the URL. The controller can ask any model for data; it happens to ask `DonorProfile`. Rails naming conventions link controller to views (`DonorsController#index` renders `app/views/donors/index.html.erb`), not controller to model.

**Relations are lazy and chainable.** `DonorProfile.where(available: true)` does not hit the database. It returns an `ActiveRecord::Relation`, a description of a query. Every `.where` or `.order` you add returns a new, bigger description. The SQL runs only when something needs the rows, which is the `.each` in your view. That is why you can write `@donors = @donors.where(...) if ...` one line at a time and still get one single SQL query.

**`includes` and the N+1 problem.** Your view prints `donor.user.name` for every row. Without `includes`, Rails runs 1 query for the profiles and then 1 more query per row to fetch each user: 15 donors means 16 queries (the "N+1" problem). With `DonorProfile.includes(:user)`, Rails runs 2 queries in total: one for the profiles and one for all their users at once. You can see the difference in the `bin/dev` server output (see B1).

**Query strings and GET forms.** A filter does not change any data; it only asks for a different view of the same list. So the form uses `GET`, and its fields go into the URL: `/donors?blood_group=O%2B&city=Pune`. Rails puts each one in `params`. Because the filter lives in the URL, you can bookmark it, share it, refresh it and press Back, and nothing is ever saved to the database. `+` has a special meaning in URLs (it means a space), so the browser encodes `O+` as `O%2B`, and Rails decodes it back to `"O+"`.

**Why no strong parameters here.** `params.expect(...)` protects you when you pass a whole hash of form fields into `new` or `update` (mass assignment). Here you only read single values and pass them to `where`, which safely quotes them, so plain `params[:blood_group]` is fine. A weird value like `?blood_group=XYZ` simply matches no rows.

## Data you work with

You only **read** data. You never create, update or delete a row.

**`donor_profiles`** (owned by Module A, see [DB_SCHEMA.md](../DB_SCHEMA.md#donor_profiles-modules-a-and-b))

| Column | Type | You use it? | Rules |
| --- | --- | --- | --- |
| `user_id` | integer | yes, through `donor.user` | NOT NULL, unique index (DB): one profile per user |
| `blood_group` | string | shown, filtered | NOT NULL (DB); must be in `BLOOD_GROUPS` (model, Module A) |
| `city` | string | shown, filtered (B3) | NOT NULL (DB); must be in `CITIES` (model, Module A) |
| `phone` | string | **never** | NOT NULL (DB); never shown on list pages |
| `available` | boolean | filtered | NOT NULL, default `true` (DB); toggled in Module A's edit page |

**`users`** (built by mentors)

| Column | Type | You use it? | Rules |
| --- | --- | --- | --- |
| `name` | string | shown | required by a model validation, not the DB |
| `email_address` | string | **never** on this page | unique (DB) |

The index on `(blood_group, city)` exists so your filters stay fast. The database only checks "not empty"; it does **not** check that `blood_group` is one of the 8 values. Module A's model validations do that, which is why your dropdown values always match what is stored.

**Decision: show only available donors.** The page exists to find someone who can donate now. A donor who switched "available" off in Module A's edit page has said "do not ask me right now", so listing them wastes the requester's time and ignores the donor's choice. If A3 is cut, every profile keeps the default `true` and everyone shows up, so nothing breaks.

## URLs and routes

Written by mentors in `config/routes.rb` (`resources :donors, only: [ :index ]`). You never edit that file.

| Verb | Path | Controller#action | Path helper | What it does |
| --- | --- | --- | --- | --- |
| GET | `/donors` | `donors#index` | `donors_path` | Lists all available donors |
| GET | `/donors?blood_group=O%2B` | `donors#index` | `donors_path(blood_group: "O+")` | Same action, filtered by blood group |
| GET | `/donors?blood_group=O%2B&city=Pune` | `donors#index` | `donors_path(blood_group: "O+", city: "Pune")` | Same action, both filters (B3) |

All three are the **same route**. The query string is not part of the route; it only fills `params`. Login is required automatically by the `Authentication` concern in `ApplicationController`.

## Files you own

| File | What goes in it |
| --- | --- |
| `app/controllers/donors_controller.rb` | the `index` action (mentors created it empty) |
| `app/views/donors/index.html.erb` | the page: heading, filter form, card list, empty state (create it if it is missing) |

**Do not touch:** `config/routes.rb`, `app/models/donor_profile.rb` and `app/views/donor_profiles/` (Module A), `app/models/user.rb` and `app/views/layouts/application.html.erb` (mentors; the nav link to `donors_path`, the flash and the page container are theirs), `app/assets/stylesheets/application.css` (mentors; you only use its classes), `db/` (no migrations after 0:20). If you need something there, ask its owner.

## Build steps

Work on branch `module-b-donor-directory`. Run the app with `bin/dev` and open <http://localhost:3000/donors>.

### Test data first (until seeds are merged)

```ruby
# bin/rails console
asha  = User.create!(name: "Asha Patil",     email_address: "asha@example.com",  password: "password123")
rahul = User.create!(name: "Rahul Deshmukh", email_address: "rahul@example.com", password: "password123")
meera = User.create!(name: "Meera Joshi",    email_address: "meera@example.com", password: "password123")

asha.create_donor_profile!(blood_group: "O+", city: "Pune",   phone: "9000000001")
rahul.create_donor_profile!(blood_group: "O+", city: "Mumbai", phone: "9000000002")
meera.create_donor_profile!(blood_group: "A-", city: "Pune",   phone: "9000000003", available: false)

DonorProfile.count   # => 3
```

`create_donor_profile!` comes from `has_one :donor_profile` on `User`: it builds the profile with `user_id` already set. Run this once; running it again fails because the emails are taken, which is fine. Meera is unavailable on purpose, so you can check that the list hides that profile.

### B1. Donors list

**Goal:** `/donors` shows a card with blood group, name and city for every available donor. No phone.

```ruby
# app/controllers/donors_controller.rb
class DonorsController < ApplicationController
  def index
    @donors = DonorProfile.includes(:user).where(available: true).order(created_at: :desc)
  end
end
```

```erb
<%# app/views/donors/index.html.erb %>
<h1 class="page-title">Donors</h1>

<% if @donors.present? %>
  <div class="card-list">
    <% @donors.each do |donor| %>
      <div class="card">
        <span class="badge"><%= donor.blood_group %></span>
        <%= donor.user.name %>
        <p class="meta"><%= donor.city %></p>
      </div>
    <% end %>
  </div>
<% else %>
  <div class="empty-state">
    <p>No donors match this filter.</p>
    <%= link_to "Clear filter", donors_path %>
  </div>
<% end %>
```

**What this does**

- `DonorProfile.includes(:user)`: start from the profiles table and load each profile's user in one extra query.
- `.where(available: true)`: only donors who said they can donate.
- `.order(created_at: :desc)`: newest donors first, so a profile created in the demo appears at the top.
- `@donors`: the `@` makes it visible to the view. No query has run yet.
- `@donors.present?` / `.each`: the query runs here, once; `.each` reuses the loaded rows. Each `donor` is one `DonorProfile` object.
- `donor.user.name`: `belongs_to :user` (written by the model generator at 0:00) gives you `donor.user`.
- `page-title`, `card-list`, `card`, `badge`, `meta`: class names from [UI_DESIGN.md](../UI_DESIGN.md#components). The mentors' stylesheet already styles them, so you write no CSS. The badge always shows the blood group as text (A+, O-), never just a colour.
- No wrapper `div` and no flash message: the layout already puts your page inside `.container` and prints the flash.
- The `else` branch is the empty state: the message plus a "Clear filter" link back to `/donors` with no filter. There is deliberately no `donor.phone` anywhere.

**Check it works**

1. Open `/donors`: Asha and Rahul appear as cards with an O+ badge, Meera does not. The page looks like screen 5 in UI_DESIGN.md.
2. Look at the `bin/dev` output. With `includes` you should see two queries:
   ```
   DonorProfile Load (0.2ms)  SELECT "donor_profiles".* FROM "donor_profiles" WHERE "donor_profiles"."available" = ? ORDER BY ...
   User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?)
   ```
   Temporarily remove `.includes(:user)` and reload: you will see one `User Load ... WHERE "users"."id" = ? LIMIT ?` line **per donor**. That is N+1. Put `includes` back.
3. View source (Cmd+Option+U or Ctrl+U), search for `9000000001`: no result.

**AI prompt**

> I am a Rails 8 beginner. In `app/controllers/donors_controller.rb`, the `index` action should set `@donors` to all `DonorProfile` rows where `available` is true, newest first, using `includes(:user)`. There is no Donor model. In `app/views/donors/index.html.erb`, add `<h1 class="page-title">Donors</h1>`, then a `<div class="card-list">` with one `<div class="card">` per donor: `<span class="badge">` with `donor.blood_group`, then `donor.user.name`, then `<p class="meta">` with `donor.city`. When the list is empty, show `<div class="empty-state">` with "No donors match this filter." and a "Clear filter" link to `donors_path`. Use only the component classes from UI_DESIGN.md (page-title, filter-bar, card-list, card, badge, meta, empty-state, btn); no Tailwind, no inline styles. Do not add a wrapper div or a flash message; the layout has them. Never show the phone or email. Explain each line and what `includes` prevents.

### B2. Blood group filter

**Goal:** a labelled dropdown in a filter bar above the list. Picking O+ shows only O+ donors; "All" shows everyone.

```ruby
# app/controllers/donors_controller.rb
class DonorsController < ApplicationController
  def index
    @donors = DonorProfile.includes(:user).where(available: true).order(created_at: :desc)
    @donors = @donors.where(blood_group: params[:blood_group]) if params[:blood_group].present?
  end
end
```

Add the form at the top of the view, under the `<h1>`:

```erb
<%# app/views/donors/index.html.erb (top of the page) %>
<%= form_with url: donors_path, method: :get, class: "filter-bar" do |f| %>
  <%= f.label :blood_group, "Blood group" %>
  <%= f.select :blood_group, BLOOD_GROUPS, include_blank: "All", selected: params[:blood_group] %>
  <%= f.submit "Filter", name: nil, class: "btn" %>
<% end %>
```

**What this does**

- Controller line 2: if the URL has a non-empty `blood_group`, narrow the existing relation. `present?` is false for `nil` (no filter in the URL) and for `""` ("All" was chosen), so in both cases the full list stays.
- Still one SQL query: the second `where` just adds `AND blood_group = 'O+'`.
- `form_with url: donors_path, method: :get`: no model here, so you give the URL yourself. `GET` means the fields go into the query string and nothing is saved.
- `class: "filter-bar"`: the shared class from UI_DESIGN.md that lays out the label, dropdown and button in one row (wrapping on narrow screens).
- `f.label :blood_group, "Blood group"`: a visible label linked to the dropdown, so screen readers and clicking the label both work. UI_DESIGN.md requires a visible label on every input.
- `f.select :blood_group, BLOOD_GROUPS, ...`: a `<select name="blood_group">` with the 8 groups from the mentors' constant, so values always match the stored ones.
- `include_blank: "All"`: an empty first option that means "no filter".
- `selected: params[:blood_group]`: after reload, the dropdown shows what you picked instead of jumping back to "All".
- `name: nil` on the submit button: stops `&commit=Filter` from being added to the URL. Optional, just tidier.
- `class: "btn"`: the shared secondary button style. Filter is not the page's main action, so it is not `btn-primary`.

**Check it works**

1. Choose O+, click Filter. The URL is `/donors?blood_group=O%2B`; only Asha and Rahul show; the dropdown still says O+.
2. Choose A+, click Filter: "No donors match this filter." with a "Clear filter" link.
3. Choose "All": everyone available is back.
4. In the server log, the `DonorProfile Load` line now includes `"blood_group" = ?` with `"O+"` in the values.
5. Console check of the same query: `DonorProfile.where(available: true, blood_group: "O+").count  # => 2`

**AI prompt**

> In my Rails 8 `DonorsController#index`, add a blood group filter: if `params[:blood_group]` is present, chain `.where(blood_group: params[:blood_group])` onto `@donors`. In `app/views/donors/index.html.erb`, add a GET form under the h1 with `form_with url: donors_path, method: :get, class: "filter-bar"`, a visible `f.label :blood_group, "Blood group"`, `f.select :blood_group, BLOOD_GROUPS, include_blank: "All", selected: params[:blood_group]` and `f.submit "Filter", name: nil, class: "btn"`. Use only the component classes from UI_DESIGN.md (page-title, filter-bar, card-list, card, badge, meta, empty-state, btn); no Tailwind, no inline styles. Do not add gems or new routes. Explain why the form uses GET and why `O+` shows as `O%2B` in the URL.

### B3. City filter (cut first if behind)

**Skip this at the 1:30 checkpoint if you have not started it.** B1 and B2 are the must-ship part.

**Goal:** a second labelled dropdown for city in the same filter bar, working alone or together with blood group.

```ruby
# app/controllers/donors_controller.rb
class DonorsController < ApplicationController
  def index
    @donors = DonorProfile.includes(:user).where(available: true).order(created_at: :desc)
    @donors = @donors.where(blood_group: params[:blood_group]) if params[:blood_group].present?
    @donors = @donors.where(city: params[:city]) if params[:city].present?
  end
end
```

```erb
<%# app/views/donors/index.html.erb (top of the page) %>
<%= form_with url: donors_path, method: :get, class: "filter-bar" do |f| %>
  <%= f.label :blood_group, "Blood group" %>
  <%= f.select :blood_group, BLOOD_GROUPS, include_blank: "All", selected: params[:blood_group] %>
  <%= f.label :city, "City" %>
  <%= f.select :city, CITIES, include_blank: "All", selected: params[:city] %>
  <%= f.submit "Filter", name: nil, class: "btn" %>
<% end %>
```

**What this does**

- Each filter is its own line that may or may not add a `where`. Both chosen means both are added, and SQL gets `blood_group = ? AND city = ?`. This works only because relations are lazy and chainable.
- The order of the two `where` lines does not matter; the result is the same query.
- `f.label :city, "City"`: the second visible label, as in screen 5 of UI_DESIGN.md.
- The "Clear filter" link in the empty state (from B1) is a plain link to `/donors` with no query string, so both filters reset. You can also pick "All" in both dropdowns.

**Check it works**

| URL | Expected |
| --- | --- |
| `/donors?city=Pune` | Asha only (Meera is in Pune but unavailable) |
| `/donors?blood_group=O%2B&city=Mumbai` | Rahul only |
| `/donors?blood_group=O%2B&city=Nagpur` | "No donors match this filter." with a "Clear filter" link |
| Click "Clear filter" | everyone available, both dropdowns back to "All" |

**AI prompt**

> Add a city filter to my Rails 8 `DonorsController#index` that works together with the existing blood group filter, using `params[:city]` and another chained `.where`. In the view, add `f.label :city, "City"` and `f.select :city, CITIES, include_blank: "All", selected: params[:city]` to the existing `filter-bar` GET form, before the Filter button. Use only the component classes from UI_DESIGN.md (page-title, filter-bar, card-list, card, badge, meta, empty-state, btn); no Tailwind, no inline styles. Explain how chaining two `where` calls becomes one SQL query.

## Privacy and edge cases

| Situation | What could go wrong | How the code handles it |
| --- | --- | --- |
| Phone on the list | Anyone signed in could harvest donor phones | The view never calls `donor.phone`; `includes(:user)` only loads users, and the view prints only `name` |
| Email on the list | Same as phone | Never printed |
| Signed-out visitor opens `/donors` | Public list of donors | `Authentication` concern redirects to login |
| Donor set "available" off | Requester calls someone who said no | `.where(available: true)` hides them |
| No donors at all, or no match | Blank, confusing page | `if @donors.present?` shows the `empty-state` box: "No donors match this filter." and a "Clear filter" link |
| Someone types `?blood_group=O+` by hand | `+` is read as a space, so the value is `"O "` and nothing matches | Use the dropdown; the browser sends `O%2B`. The empty state shows, nothing breaks |
| Odd value like `?blood_group=XYZ` or SQL in the URL | Error or SQL injection | `where(blood_group: ...)` quotes the value safely; result is just empty |
| A user with no `name` | Card with only a badge | Mentors' `User` validation requires name |

## Testing checklist

1. Log out, open `/donors`: you are sent to the login page.
2. Log in, open `/donors`: available donors are listed as cards with a blood group badge, name and city.
3. View source, search for a known phone number and an email: no results.
4. Filter O+: only O+ rows, dropdown keeps O+, URL has `blood_group=O%2B`.
5. Filter a group nobody has: "No donors match this filter." and a "Clear filter" link that brings the full list back.
6. Choose "All": full list again.
7. (B3) City only, then both together, then "Clear filter": results as in the B3 table.
8. Refresh after filtering, then press Back: the filter survives, no "resubmit form?" warning (it is a GET).
9. The page matches screen 5 of [UI_DESIGN.md](../UI_DESIGN.md#5-donors-list-module-b): one `<h1 class="page-title">Donors</h1>`, a `filter-bar` with visible "Blood group" (and "City") labels and a Filter button, cards with a blood group `badge` and the city in `meta`, and the `empty-state` box when nothing matches. View source shows no Tailwind classes and no `style=` attributes.
10. After seeds are merged (`bin/rails db:seed`): about 15 donors across groups and cities appear, and filtering still works.

> Needs test setup by a mentor: this app was created without the test framework (`config/application.rb` has `rails/test_unit/railtie` commented out and there is no `test/` folder). Skip this if a mentor has not set it up.

Optional Minitest test. `sign_in_as(user)` comes from the Rails 8.1 authentication generator's test helper (`test/test_helpers/session_test_helper.rb`):

```ruby
# test/controllers/donors_controller_test.rb
require "test_helper"

class DonorsControllerTest < ActionDispatch::IntegrationTest
  test "filters by blood group and hides phone" do
    user = User.create!(name: "Asha", email_address: "asha@test.com", password: "password123")
    user.create_donor_profile!(blood_group: "O+", city: "Pune", phone: "9000000001")
    sign_in_as(user)

    get donors_path(blood_group: "A+")
    assert_select ".card", count: 0
    assert_select ".empty-state", text: /No donors match this filter/

    get donors_path(blood_group: "O+")
    assert_select ".card", text: /Asha/
    assert_select ".card .badge", text: "O+"
    assert_no_match "9000000001", response.body
  end
end
```

Run it with `bin/rails test test/controllers/donors_controller_test.rb`. If fixtures clash, ask a mentor; the manual checklist is what counts today.

If every test fails with "uninitialized constant Donor" or "Missing model class Donor", Module E's `class_name: "User"` is not merged yet; ask a mentor.

## Working with other modules

**You depend on**

- **Mentors (W1, P2, P3, P4):** the `donor_profiles` table, `DonorProfile belongs_to :user` (added by the model generator at 0:00), `User has_one :donor_profile`, the route, the empty controller, the nav link and the `BLOOD_GROUPS` / `CITIES` constants. All on main before you start.
- **Module A (Attendee 1):** real donors come from the Module A form, and its validations guarantee blood group and city values match your dropdowns. You do **not** need that branch merged to build; your console data is enough.
- **Seeds (P5, Mentor 2):** about 15 donors for the demo. Ask that a couple of them have `available: false`, so the hidden-donor rule is visible.

**Who depends on you**

- **The demo, step 2:** "find that donor in the donors list by blood group".
- **Module D (Attendee 4):** the matching-donors partial runs a very similar query (same blood group and city, name and city only). Tell Attendee 4 that you hide unavailable donors so both lists agree.

**Coordination and merge order**

- You share no files with anyone, so your pull request should merge cleanly. Open it as soon as B1 and B2 work, even before 1:30; you can add B3 in a second small PR.
- Merge order at 1:30 - 2:10 does not depend on you, but the demo needs A and B both on main. After the merge, pull main, run `bin/rails db:seed`, then sign up a new user, create a profile (A) and find them on `/donors` (B).

## Common mistakes

| Symptom | Cause | Fix |
| --- | --- | --- |
| `uninitialized constant DonorsController::Donor` | You (or the AI) wrote `Donor.all` | There is no Donor model; use `DonorProfile` |
| `undefined method 'name' for an instance of DonorProfile` | You wrote `donor.name` | Use `donor.user.name` |
| Page lists everyone even after picking O+ | Forgot `@donors = ` on the filter line, so the result was thrown away | Reassign: `@donors = @donors.where(...)` |
| "All" shows nothing | Used `if params[:blood_group]` instead of `.present?`; `""` is truthy in Ruby | Use `.present?` |
| Dropdown jumps back to "All" after filtering | Missing `selected: params[:blood_group]` | Add it |
| `No route matches [POST] "/donors"` | Form missing `method: :get`, so it posts | Add `method: :get` |
| Many `User Load` lines in the log | No `includes(:user)` (N+1) | Add `.includes(:user)` |
| Text missing from the page | `<% %>` instead of `<%= %>` | Use `<%= %>` to print |
| Page looks unstyled or different from other pages | Tailwind classes, inline `style=`, or a typo in a class name | Use only the classes from [UI_DESIGN.md](../UI_DESIGN.md#components), spelled exactly |
| Two headings, or the flash shows twice | Added a second `<h1>`, or printed `notice` yourself although the layout already does | One `<h1 class="page-title">` only; the layout prints the flash |
| `NameError: uninitialized constant BLOOD_GROUPS` | Constants file not on your branch | `git pull` main and restart `bin/dev` |
| Typed `?blood_group=O+` and got nothing | `+` means a space in URLs | Use the dropdown, or type `O%2B` |

## Explain it (B4)

Questions a mentor will ask, and what a good answer includes:

| Question | Key points |
| --- | --- |
| There is no Donor model. Where do the donors come from? | `DonorProfile` rows; the controller is named after the URL, not the model; name comes from the associated `User` |
| Walk me through what happens when I open `/donors?blood_group=O%2B`. | Router → `DonorsController#index`; `params[:blood_group]` is `"O+"`; relation built and narrowed; view loops and prints |
| Why `includes(:user)`? | Avoids N+1: 2 queries instead of 1 + one per donor; show the log |
| How many SQL queries does the filter run? | Two: one for profiles (with all `where`s combined) plus one for users; relations are lazy until `@donors.present?` loads them, and `.each` reuses the rows |
| Why is the form GET and not POST? | It only reads data; the filter lives in the URL, so it can be bookmarked, refreshed and shared |
| Why don't you use `params.expect` here? | Nothing is mass-assigned or saved; single values go into `where`, which quotes them safely |
| How do you make sure phone numbers stay private? | The view never prints `phone`; checked with View source |
| Why hide unavailable donors? | The list is for donors who can donate now; respects the donor's choice |

Your 5-line explanation, following the template in [MVC_GUIDE.md: Explaining your module](../MVC_GUIDE.md#explaining-your-module-at-the-demo):

1. "When you open `/donors`, the router sends it to `DonorsController#index`."
2. "The action asks the model for available donor profiles with their users using `DonorProfile.includes(:user).where(available: true)`, and adds `.where(blood_group: ...)` and `.where(city: ...)` only when those filters are in the URL."
3. "The model makes sure every profile has a blood group from `BLOOD_GROUPS` and a city from `CITIES` (Module A's validations), so the dropdown values always match."
4. "The view `donors/index.html.erb` shows each donor as a card with a blood group badge, name and city, using the shared classes from UI_DESIGN.md, and does not show phone numbers or emails."
5. "If nothing matches, like O+ in Nagpur, the page says 'No donors match this filter.' with a 'Clear filter' link instead of a blank list."

## Out of scope

Say no if your AI tool suggests any of these:

- A `Donor` model, a `donors` table or any migration.
- Gems such as Ransack, Kaminari, Pagy or Pundit.
- Pagination, sorting, a table layout, or a free-text search box.
- Tailwind or Bootstrap classes, inline styles, icons, or a new stylesheet: use the classes in [UI_DESIGN.md](../UI_DESIGN.md#components).
- Live filtering with Stimulus or Turbo Frames (the plain GET form is enough).
- Showing phone, email or a "contact donor" button on this page.
- A donor detail page (`/donors/:id`): the route does not exist.
- Blood compatibility rules (O- can give to everyone): see [PRD.md](../PRD.md#scope).
- Editing `config/routes.rb`, the layout, or another module's files.
