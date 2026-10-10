# Module D: Requests list — tech spec

Oct 10, 2026 · Vishwajeetsingh Desurkar

You build the list of blood requests that donors open first, a blood group filter on top of it, and (with a mentor) a "matching donors" box on each request page.

See also: [ATTENDEE_TASKS.md](../ATTENDEE_TASKS.md) for your task list, [MVC_GUIDE.md](../MVC_GUIDE.md) for how models, views and controllers fit together, [DB_SCHEMA.md](../DB_SCHEMA.md) for the tables, and [UI_DESIGN.md](../UI_DESIGN.md) for the screens and the component classes your views use.

## What you are building

A signed-in user who wants to help opens **Requests** in the nav bar and lands on `/blood_requests`. They see every blood request, newest first, as a list of cards. Each card shows the blood group, units needed, hospital, city and needed-by date, and clicking anywhere on the card opens that request's page (built by Module C). The patient's name and the contact phone are never on this list.

This is [screen 8, Requests list](../UI_DESIGN.md#8-requests-list-module-d) in UI_DESIGN.md:

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

Choosing B+ in the dropdown and clicking **Filter** reloads the page as `/blood_requests?blood_group=B%2B` and shows only B+ requests. If nothing matches, the page shows "No requests match this filter." with a "Clear filter" link.

On a request page (`/blood_requests/5`), your **Matching donors** box lists available donors with the same blood group and city as the request: name and city only, never a phone number. It is the last part of [screen 7, Request page](../UI_DESIGN.md#7-request-page-module-c-with-d-and-e), below Module E's button and responses list:

```
  ------------------------------------------------
  Matching donors (3)                     <- Module D, cut first
    Asha Kulkarni    Pune
    Neha Shah        Pune
```

You only write page content. The mentor-built layout already wraps every page in `.container` and provides the nav bar, footer and flash message, so your views do not add a wrapper `div` for width and do not print the flash. You use only the component classes listed in UI_DESIGN.md (`page-title`, `card`, `card-list`, `btn`, `btn btn-primary`, `filter-bar`, `badge`, `meta`, `empty-state`, and so on): no Tailwind classes, no inline styles, no new CSS.

In the demo journey you are step 4: "As the donor, find the request in the list." Module C's request is created in step 3, and the donor clicks it on your page before pressing Module E's "I can help" button in step 5.

## Done when

- [ ] `/blood_requests` lists all requests, newest first (D1)
- [ ] Each card shows blood group, units, hospital, city and needed-by date, and no patient name or phone number (D1)
- [ ] Clicking a card opens that request's page (D1)
- [ ] With no requests, the page says so instead of showing a blank space (D1)
- [ ] Choosing B+ shows only B+ requests; choosing "All" shows everything again (D2)
- [ ] The dropdown remembers the chosen group after the page reloads (D2)
- [ ] The page matches [screen 8](../UI_DESIGN.md#8-requests-list-module-d): one `<h1 class="page-title">`, a "Request blood" primary button, the filter bar, cards with a blood group badge, and only UI_DESIGN.md component classes (no Tailwind, no inline styles) (D1, D2)
- [ ] *(Cut first)* The request page lists available donors with the same blood group and city, name and city only, without the requester themselves, at the bottom of screen 7 (D3)
- [ ] You have explained your query and view to a mentor (D4)

## Concepts you will use

| Concept | What it is in one line | Where you use it |
| --- | --- | --- |
| Controller action | A method that handles one URL | `BloodRequestsController#index` |
| Instance variable | A `@variable` the controller sets and the view reads | `@blood_requests` |
| ActiveRecord query | Ruby methods that Rails turns into SQL | `.order`, `.where`, `.where.not`, `.includes` |
| Relation (lazy query) | A query that is built up step by step and runs only when you use the results | the filter in D2 |
| `params` | Everything the browser sent, including `?blood_group=B%2B` | the filter in D2 |
| ERB loop | `<% ... each do %>` repeats HTML for each row | `index.html.erb` |
| `link_to` with a block | A link whose content is a chunk of HTML instead of a short text | each request card |
| Component classes | Shared CSS class names from UI_DESIGN.md (`card`, `badge`, `filter-bar`...) | every tag you style |
| Path helper | A method that builds a URL from a route | `blood_request_path(blood_request)`, `blood_requests_path`, `new_blood_request_path` |
| GET form | A form that puts its fields in the URL instead of saving anything | the filter dropdown |
| Partial with locals | A reusable view piece that gets its data passed in | `_matching_donors.html.erb` |
| Class method on a model | A named, reusable query that lives in the model | `DonorProfile.matching(blood_request)` |

**ActiveRecord reads columns from the database.** A model file can be almost empty (`class BloodRequest < ApplicationRecord; end`) and `BloodRequest.order(created_at: :desc)` still works. When Rails first loads the class, it asks the database which columns the `blood_requests` table has and creates `hospital`, `city`, `needed_by` and so on for you. Module C adds rules (validations, `belongs_to`) to that file, but you can start before she merges, because the table already exists from the 0:20 migration. See [The Model](../MVC_GUIDE.md#the-model).

**Relations are lazy and chainable.** `BloodRequest.order(created_at: :desc)` does not run any SQL. It returns an `ActiveRecord::Relation`: a description of a query. Calling `.where(...)` on it returns a new relation with one more condition. The SQL runs only when the view uses the results (`.present?` or `.each`). That is why the filter can be an optional extra line: you add the `where` only when a group was chosen, and Rails still sends one single query.

**A GET form changes the URL, not the database.** The filter form uses `method: :get`, so submitting it just opens `/blood_requests?blood_group=B%2B`. The `index` action reads that value from `params[:blood_group]`. Nothing is saved, the URL can be bookmarked, and the back button works. This is the same pattern as Module B's donors filter (see [Your module, in MVC terms](../MVC_GUIDE.md#your-module-in-mvc-terms)).

**Partials receive data through locals.** Your `_matching_donors` partial is rendered inside Module C's page. Instead of reading her `@blood_request`, it receives `blood_request:` as a local, so it works no matter what the surrounding page calls its variables. See [Partials](../MVC_GUIDE.md#partials).

**Queries belong in the model, not the view.** "Available donors with the same blood group and city, not the requester" is a rule about data, so it reads best as a named model method, `DonorProfile.matching(blood_request)`. The view then just asks for it by name.

**Styling is shared, not written.** A mentor wrote one stylesheet with a small set of component classes. You build your page by putting those class names on your tags: `class="card"` for a box, `class="badge"` for the blood group, and so on. You do not write CSS, Tailwind classes or `style="..."` attributes. That way all five modules look like one app. See [Components](../UI_DESIGN.md#components).

## Data you work with

You only **read** data. You never create or change rows in the app (only in the console, for testing).

**`blood_requests`** (D1, D2; model owned by Module C)

| Column | Type | You use it for | Rules |
| --- | --- | --- | --- |
| id | integer | the link to the request page | primary key |
| user_id | integer | D3: leave the requester out of matching donors | not null (DB), `belongs_to :user` (model) |
| blood_group | string | display, filter, D3 match | not null (DB); must be in `BLOOD_GROUPS` (model) |
| units_needed | integer | display | not null, default 1 (DB); at least 1 (model) |
| hospital | string | display | not null (DB); presence (model) |
| city | string | display, D3 match | not null (DB); must be in `CITIES` (model) |
| needed_by | date | display | not null (DB); presence (model) |
| created_at | datetime | sorting newest first | set by Rails |
| contact_phone | string | **never shown on your page** | private |
| patient_name, note | string, text | not shown on the list | |

**`donor_profiles`** (D3 only; model owned by Module A)

| Column | Type | You use it for |
| --- | --- | --- |
| user_id | integer | the donor's name (via `profile.user.name`) and leaving out the requester |
| blood_group | string | must equal the request's blood group |
| city | string | must equal the request's city; shown |
| available | boolean | only `true` donors are listed (not null, default true in the DB) |
| phone | string | **never shown on your page** |

The database enforces "not null" and defaults. The *allowed values* (blood groups, cities) are enforced only by the model validations, as [DB_SCHEMA.md](../DB_SCHEMA.md#allowed-values) explains. That is why the filter dropdown uses `BLOOD_GROUPS`: the values in the dropdown are exactly the values stored.

## URLs and routes

The mentors wrote these routes. You do not edit `config/routes.rb`.

| Verb | Path | Controller#action | Path helper | What it does |
| --- | --- | --- | --- | --- |
| GET | `/blood_requests` | `blood_requests#index` | `blood_requests_path` | Your list, all requests |
| GET | `/blood_requests?blood_group=B%2B` | `blood_requests#index` | `blood_requests_path(blood_group: "B+")` | Your list, filtered |
| GET | `/blood_requests/:id` | `blood_requests#show` (Module C) | `blood_request_path(blood_request)` | Where each row links; your partial appears here |

## Files you own

| File | What you put in it |
| --- | --- |
| `app/controllers/blood_requests_controller.rb` | **only the `index` method** |
| `app/views/blood_requests/index.html.erb` | the page title and "Request blood" button, the filter bar, the list of cards and the empty state |
| `app/views/blood_requests/_matching_donors.html.erb` | the matching donors box (D3) |
| `test/integration/requests_list_test.rb` | optional test (see Testing checklist) |

**Do not touch:** `config/routes.rb`, `db/` (no migrations after 0:20), the `new`, `create` and `show` methods or the `private` section of `blood_requests_controller.rb`, `app/models/blood_request.rb`, `new.html.erb`, `_form.html.erb`, `show.html.erb` (Module C), and `app/models/donor_profile.rb` (Module A, except the one D3 method added together with a mentor).

**Sharing one controller file with Module C.** Git merges by comparing blocks of changed lines. If you only add lines between `def index` and its `end`, and Module C only adds lines inside `show`, `new`, `create` and the `private` section, your changes sit in different parts of the file, separated by lines neither of you changed. Git combines them automatically. A conflict happens only when you both change the same or neighbouring lines. So: do not reformat the file, do not reorder methods, do not add a `before_action` at the top, and do not "tidy up" Module C's empty methods even if your AI suggests it.

## Build steps

### D1. Requests list (Keep)

**Goal:** `/blood_requests` shows every request, newest first, as cards that each link to the request's page (screen 8, without the filter bar yet).

```ruby
# app/controllers/blood_requests_controller.rb  (only the index method)
def index
  @blood_requests = BloodRequest.order(created_at: :desc)
end
```

```erb
<%# app/views/blood_requests/index.html.erb %>
<h1 class="page-title">Blood requests</h1>
<%= link_to "Request blood", new_blood_request_path, class: "btn btn-primary" %>

<% if @blood_requests.present? %>
  <div class="card-list">
    <% @blood_requests.each do |blood_request| %>
      <%= link_to blood_request_path(blood_request), class: "card" do %>
        <span class="badge"><%= blood_request.blood_group %></span>
        <%= pluralize(blood_request.units_needed, "unit") %>
        <%= blood_request.hospital %>, <%= blood_request.city %>
        <p class="meta">Needed by <%= blood_request.needed_by.strftime("%d %b %Y") %></p>
        View ›
      <% end %>
    <% end %>
  </div>
<% else %>
  <div class="empty-state">
    <p>No blood requests yet.</p>
    <%= link_to "Request blood", new_blood_request_path %>
  </div>
<% end %>
```

**What this does**

- `BloodRequest.order(created_at: :desc)`: "all requests, sorted by creation time, biggest (newest) first". It returns a relation; no SQL has run yet.
- `@blood_requests = ...`: the `@` makes it visible to `index.html.erb`. Rails renders that file automatically because the action is called `index`.
- `<h1 class="page-title">Blood requests</h1>`: the one `<h1>` on the page. Its text matches the screen 8 wireframe. The layout already puts your page inside `.container` under the nav bar, so you start straight with the title.
- `link_to "Request blood", new_blood_request_path, class: "btn btn-primary"`: the page's one main action, styled as the red button. It opens Module C's form.
- `if @blood_requests.present?` / `else`: the empty state. Without it, an empty database shows only a heading, which looks broken. `.present?` loads the rows once, and `.each` reuses them, so the page runs one query. The `empty-state` class centres the message and its one link to the next action.
- `<div class="card-list">`: stacks the cards with a gap between them.
- `each do |blood_request|`: repeats the card once per row. We name the block variable `blood_request`, not `request`, because `request` is already a built-in Rails method in views (the current HTTP request). Shadowing it causes confusing bugs.
- `link_to path, class: "card" do ... end`: **`link_to` with a block.** Normally you write `link_to "text", path`. When the link should wrap more than a short text, you leave out the text and put everything between `do` and `end` instead; Rails wraps it all in one `<a href="/blood_requests/5" class="card">`. So the whole card is one clickable link. `blood_request_path(blood_request)` builds `/blood_requests/5`.
- `<span class="badge">`: shows the blood group as text inside a red outlined badge. The text is always there, so colour never carries the meaning on its own.
- `pluralize(2, "unit")` prints "2 units"; `pluralize(1, "unit")` prints "1 unit".
- `<p class="meta">`: the muted, smaller second line of the card. `strftime("%d %b %Y")` turns the date into "12 Oct 2026". `needed_by` is a `Date`, so you can format it.
- "View ›" tells people the card is clickable.
- `contact_phone` and `patient_name` are deliberately left out.

**Check it works**

The mentor's generator already added `belongs_to :user`, so `user:` works; if a mentor removed it, use `user_id: u.id`.

```ruby
# bin/rails console
u = User.first
BloodRequest.create!(user: u, patient_name: "Test One", blood_group: "B+", units_needed: 2,
  hospital: "Ruby Hall Clinic", city: "Pune", needed_by: Date.today + 2, contact_phone: "9000000001")
BloodRequest.create!(user: u, patient_name: "Test Two", blood_group: "O-", units_needed: 1,
  hospital: "KEM Hospital", city: "Mumbai", needed_by: Date.today + 4, contact_phone: "9000000002")
BloodRequest.order(created_at: :desc).map(&:hospital)  # => ["KEM Hospital", "Ruby Hall Clinic"]
```

Then run `bin/dev`, log in and open `http://localhost:3000/blood_requests`. Expected: the "Blood requests" title, a red "Request blood" button, and two cards, KEM Hospital on top, with no patient names or phone numbers. Clicking a card opens `/blood_requests/<id>` (blank or "missing template" until Module C's `show` is merged; the URL in the address bar is what you check).

**Suggested AI prompt**

> I'm working in a Rails 8.1 app. In `app/controllers/blood_requests_controller.rb`, fill in ONLY the empty `index` action so it loads all BloodRequest records newest first into `@blood_requests`. Then write `app/views/blood_requests/index.html.erb` with `<h1 class="page-title">Blood requests</h1>` and a "Request blood" link to `new_blood_request_path` with `class: "btn btn-primary"`. Below it, a `<div class="card-list">` where each request is one `link_to blood_request_path(blood_request), class: "card" do ... end` block containing the blood_group in `<span class="badge">`, units_needed with `pluralize`, "hospital, city", a `<p class="meta">` with "Needed by" and needed_by formatted like "12 Oct 2026", and "View ›". Do not show contact_phone or patient_name. Add an empty state in `<div class="empty-state">`. Use `blood_request` as the loop variable. Use only the component classes from UI_DESIGN.md (`page-title`, `card`, `card-list`, `btn`, `btn btn-primary`, `form-field`, `form-errors`, `filter-bar`, `badge`, `meta`, `empty-state`); no Tailwind, no inline styles. The layout already provides the container, nav and flash, so do not add a wrapper div or print the flash. Explain each line, including how `link_to` with a block works.

### D2. Blood group filter (Keep)

**Goal:** a dropdown above the list; choosing B+ shows only B+ requests.

```ruby
# app/controllers/blood_requests_controller.rb  (only the index method)
def index
  @blood_requests = BloodRequest.order(created_at: :desc)
  @blood_requests = @blood_requests.where(blood_group: params[:blood_group]) if params[:blood_group].present?
end
```

```erb
<%# app/views/blood_requests/index.html.erb  (add between the "Request blood" button and the list) %>
<%= form_with url: blood_requests_path, method: :get, class: "filter-bar" do |f| %>
  <%= f.label :blood_group, "Blood group" %>
  <%= f.select :blood_group, BLOOD_GROUPS, include_blank: "All", selected: params[:blood_group] %>
  <%= f.submit "Filter", name: nil, class: "btn" %>
<% end %>
```

And change the empty state so it makes sense when a filter is on:

```erb
<% else %>
  <% if params[:blood_group].present? %>
    <div class="empty-state">
      <p>No requests match this filter.</p>
      <%= link_to "Clear filter", blood_requests_path %>
    </div>
  <% else %>
    <div class="empty-state">
      <p>No blood requests yet.</p>
      <%= link_to "Request blood", new_blood_request_path %>
    </div>
  <% end %>
<% end %>
```

**What this does**

- Line 1 of `index` builds the base query. Line 2 adds `WHERE blood_group = 'B+'` only if a group was chosen. `.present?` is false for `nil` (no filter in the URL) and for `""` ("All" sends an empty value), so both show everything.
- Because relations are lazy, the two lines still produce one SQL query. Try `@blood_requests.to_sql` in the console to see it.
- `form_with url: blood_requests_path, method: :get`: a form not tied to a model. Submitting it opens `/blood_requests?blood_group=B%2B`. Because it is `GET`, it needs no strong parameters and saves nothing. `class: "filter-bar"` puts the label, dropdown and button in one row (it wraps on a phone).
- `f.label :blood_group, "Blood group"`: a visible label linked to the dropdown, so clicking the words focuses the dropdown and screen readers announce it. UI_DESIGN.md requires a label on every input.
- `f.select :blood_group, BLOOD_GROUPS`: the dropdown sends a field called `blood_group`, which arrives as `params[:blood_group]`. Using `BLOOD_GROUPS` guarantees the values match what is stored. `include_blank: "All"` adds an "All" option with an empty value at the top.
- `selected: params[:blood_group]`: after the reload, the dropdown still shows the chosen group.
- `class: "btn"` on the submit button gives it the secondary button look; the red `btn-primary` is kept for "Request blood", the page's one main action. `name: nil` stops Rails adding `&commit=Filter` to the URL. Optional, but the URL stays clean.
- "Clear filter" links to `blood_requests_path` with no `?blood_group=`, so it shows everything again.
- `%2B` is how a `+` is written inside a URL. A bare `+` in a URL means a space, so `?blood_group=B+` would arrive as `"B "` and match nothing. The form encodes it for you; if you type a URL by hand, write `B%2B`.

**Check it works**

```ruby
# bin/rails console
BloodRequest.order(created_at: :desc).where(blood_group: "B+").to_sql
# => SELECT "blood_requests".* FROM "blood_requests" WHERE "blood_requests"."blood_group" = 'B+' ORDER BY ...
BloodRequest.where(blood_group: "B+").count  # => 1 with the test data above
```

In the browser: choose B+, click Filter. Expected: URL ends in `?blood_group=B%2B`, only the Ruby Hall card shows, dropdown still says B+. Choose "All": both cards return. Choose AB-: "No requests match this filter." with a "Clear filter" link. The page now looks like screen 8.

**Suggested AI prompt**

> In my Rails 8.1 `BloodRequestsController#index` (only that method), add an optional blood group filter: if `params[:blood_group]` is present, add `.where(blood_group: ...)` to `@blood_requests`, keeping newest first. In `index.html.erb`, add a GET filter form using `form_with url: blood_requests_path, method: :get, class: "filter-bar"` with a visible label "Blood group", a select of the `BLOOD_GROUPS` constant with `include_blank: "All"` and `selected: params[:blood_group]`, and a "Filter" submit with `class: "btn"`. When a filter matches nothing, show `<div class="empty-state">` with "No requests match this filter." and a "Clear filter" link to `blood_requests_path`. Use only the component classes from UI_DESIGN.md (`page-title`, `card`, `card-list`, `btn`, `btn btn-primary`, `form-field`, `form-errors`, `filter-bar`, `badge`, `meta`, `empty-state`); no Tailwind, no inline styles. No gems like Ransack. Explain why relations can be chained and why `+` becomes `%2B`.

### D3. Matching donors (with a mentor, cut first if behind)

**Goal:** on a request page, list available donors with the same blood group and city, name and city only, without the requester.

Do this only after D1 and D2 work, and only with a mentor. If it has not started by the 1:30 checkpoint, drop it.

**Step 1: the query, as a model method.** The query is a rule about donor data, so it belongs on `DonorProfile`. That file is Module A's (`app/models/donor_profile.rb`), so after Module A merges, a mentor adds this one method with you as a separate small commit and tells Module A's owner (this avoids conflicts):

```ruby
# app/models/donor_profile.rb  (one method added with a mentor; the rest is Module A's)
def self.matching(blood_request)
  includes(:user)
    .where(blood_group: blood_request.blood_group, city: blood_request.city, available: true)
    .where.not(user_id: blood_request.user_id)
end
```

- `def self.matching`: a class method, called as `DonorProfile.matching(some_request)`. It returns a relation, so it is still lazy.
- `includes(:user)`: loads all the donors' users in one extra query, instead of one query per donor when the view calls `profile.user.name` (the "N+1" problem). It needs Module A's `belongs_to :user`.
- `where(... available: true)`: exact match on blood group and city, and only donors who said they can donate.
- `where.not(user_id: blood_request.user_id)`: the person who posted the request should not appear as their own donor.

**Fallback for the day:** if Module A's file is busy or not merged, put the same query directly at the top of the partial (`<% donors = DonorProfile.includes(:user).where(...).where.not(...) %>`) and move it into the model afterwards. It works; it is just in the wrong layer, and you should say so when you explain it.

**Step 2: the partial.**

```erb
<%# app/views/blood_requests/_matching_donors.html.erb %>
<% donors = DonorProfile.matching(blood_request) %>

<section>
  <h2>Matching donors (<%= donors.size %>)</h2>

  <% if donors.present? %>
    <div class="card-list">
      <% donors.each do |profile| %>
        <div class="card">
          <%= profile.user.name %>
          <p class="meta"><%= profile.city %></p>
        </div>
      <% end %>
    </div>
  <% else %>
    <div class="empty-state">
      <p>No matching donors yet.</p>
    </div>
  <% end %>
</section>
```

- `blood_request` (no `@`) is the local passed in by `render`. The partial never reads `@blood_request`.
- `<h2>`, not `<h1>`: Module C's page already has the one `<h1 class="page-title">`. A section inside a partial uses `<h2>`.
- `donors.size` prints the count in the heading, like "Matching donors (3)" on screen 7. On a relation that is not loaded yet, `.size` runs a quick `COUNT` query.
- Each donor is a `card` inside a `card-list`, with the name on the first line and the city as the muted `meta` line. No `link_to` here: the donor cards are not clickable.
- The empty state uses the shared `empty-state` class. It has no link, because there is no next action for the viewer here.
- The partial calls a named model method, not a raw `where`, so the view only decides *how to show* donors, not *which* ones.
- Only `profile.user.name` and `profile.city` are printed. `profile.phone` is never used here.

Why not set `@matching_donors` in the controller? That would mean editing Module C's `show` method, which causes merge conflicts. A model method called from a self-contained partial keeps the files separate.

**Step 3: render it on the request page.** In Module C's `show.html.erb`, in the marked spot at the bottom, your line is waiting, commented out. The order matches screen 7: Module E's "I can help" button first, then E's responses list, then your matching donors **last**:

```erb
<%# ===== Modules D and E: add your render lines below. Do not edit above this line. ===== %>
<%# Module E: render "responses/button", blood_request: @blood_request %>
<%# Module E: render "responses/list", blood_request: @blood_request %>
<%# Module D: render "blood_requests/matching_donors", blood_request: @blood_request %>
<%# ===== end of shared spot ===== %>
```

To switch yours on, change only the `Module D` line to:

```erb
<%= render "blood_requests/matching_donors", blood_request: @blood_request %>
```

Only you uncomment your line, after both Module C's page and `DonorProfile.matching` are on main. Do not move it above Module E's lines, and do not touch their lines. If D3 is cut, leave the line commented.

**Check it works**

```ruby
# bin/rails console (needs Module A's belongs_to :user and Module C's request)
r = BloodRequest.last                                   # say B+ in Pune
DonorProfile.matching(r).map { |p| [p.user.name, p.blood_group, p.city] }
# => only B+ donors in Pune with available: true, not r's own user
```

In the browser: open a B+ Pune request from seed data. Expected: at the bottom of the page, below Module E's parts, "Matching donors (N)" with one card per B+ Pune donor, names and cities, no phones. Edit a donor to unavailable (Module A3) and reload: that donor disappears.

**Suggested AI prompt**

> In Rails 8.1, I need a class method `DonorProfile.matching(blood_request)` that returns donor profiles with the same blood_group and city as the request, `available: true`, excluding the request's own `user_id`, with `includes(:user)`. Then write a partial `app/views/blood_requests/_matching_donors.html.erb` that receives a local `blood_request`, calls that method, shows `<h2>Matching donors (<%= donors.size %>)</h2>`, and lists each donor as a `<div class="card">` inside a `<div class="card-list">` with `user.name` and `<p class="meta">` for `city` only, never phone, with an empty state in `<div class="empty-state">`. Use only the component classes from UI_DESIGN.md (`page-title`, `card`, `card-list`, `btn`, `btn btn-primary`, `form-field`, `form-errors`, `filter-bar`, `badge`, `meta`, `empty-state`); no Tailwind, no inline styles. Exact matches only, no blood compatibility rules. Explain why the query is in the model and what `includes` does.

## Privacy and edge cases

| Situation | What happens / how the code handles it |
| --- | --- |
| Phone numbers | Neither view prints `contact_phone` or `phone`. Check by searching the page source for a known test number. |
| Patient name | The list never prints `patient_name`; only the request page (Module C) shows it. |
| Not logged in | `ApplicationController`'s `Authentication` concern redirects to login. You add nothing. |
| No requests at all | Empty state: "No blood requests yet." with a "Request blood" link. |
| Filter matches nothing | Empty state: "No requests match this filter." with a "Clear filter" link. |
| "All" chosen | `params[:blood_group]` is `""`; `.present?` is false, so no filter. |
| Someone types `?blood_group=XYZ` | `where` simply finds nothing; values are passed safely as SQL parameters, never pasted into SQL. |
| Requester views their own request | `where.not(user_id: ...)` hides them from matching donors. |
| Donor set to unavailable | `available: true` hides them. |
| Donor without a name | `name` is required by a model validation on User, so it should not happen; seeds always set it. |
| Past needed-by dates | Still listed. There is no "closed" status today (out of scope). |

## Testing checklist

1. Log out, open `/blood_requests` → redirected to login.
2. Log in, open `/blood_requests` with no data → "No blood requests yet."
3. Create two requests in the console (B+ then O-) → both listed, O- on top.
4. Each card shows the group in a badge, units, hospital, city, "Needed by" date and "View ›"; page source has no phone number and no patient name.
5. Click anywhere on a card → URL becomes `/blood_requests/<that id>`.
6. Filter B+ → only B+; URL has `blood_group=B%2B`; dropdown still says B+.
7. Filter "All" → everything back. Filter AB- → "No requests match this filter." with "Clear filter"; clicking it shows everything again.
8. Compare the page with [screen 8](../UI_DESIGN.md#8-requests-list-module-d): "Blood requests" title with the red "Request blood" button, the "Blood group" filter bar, then the cards. View the page source: exactly one `<h1>`, and no Tailwind classes or `style=` attributes in your markup.
9. After merging with seeds: open a request page → "Matching donors (N)" appears last, below Module E's button and list, and shows only same group and city, names and cities only (D3).
10. Open a request you posted yourself while having a matching donor profile → you are not in your own list (D3).

Optional Minitest test. Uses `sign_in_as` from the Rails 8.1 authentication generator's test helper.

> Needs test setup by a mentor: this app was created without the test framework (`config/application.rb` has `rails/test_unit/railtie` commented out and there is no `test/` folder). Skip this if a mentor has not set it up.

```ruby
# test/integration/requests_list_test.rb
require "test_helper"

class RequestsListTest < ActionDispatch::IntegrationTest
  setup do
    user = users(:one)
    sign_in_as(user)
    BloodRequest.create!(user: user, patient_name: "A", blood_group: "B+", units_needed: 2, hospital: "Bplus Hospital",
                         city: "Pune", needed_by: Date.tomorrow, contact_phone: "9000000001")
    BloodRequest.create!(user: user, patient_name: "B", blood_group: "O-", units_needed: 1, hospital: "Ominus Hospital",
                         city: "Pune", needed_by: Date.tomorrow, contact_phone: "9000000002")
  end

  test "filter shows only the chosen blood group and no phones" do
    get blood_requests_path(blood_group: "B+")
    assert_response :success
    assert_includes response.body, "Bplus Hospital"
    assert_not_includes response.body, "Ominus Hospital"
    assert_not_includes response.body, "9000000001"
  end
end
```

Run it with `bin/rails test test/integration/requests_list_test.rb`.

If every test fails with "uninitialized constant Donor" or "Missing model class Donor", Module E's `class_name: "User"` is not merged yet; ask a mentor.

## Working with other modules

| Who | Relationship | Coordination |
| --- | --- | --- |
| Mentors | Routes, login, layout (`.container`, nav, footer, flash), shared stylesheet with the UI_DESIGN.md component classes, nav link, `BLOOD_GROUPS`, empty `index` action | Already done before 0:20 |
| Module C (Attendee 3) | Owns the `BloodRequest` model and `show` page; shares your controller file | You edit only `index`. Only you uncomment your D3 `render` line, once her page and `DonorProfile.matching` are on main (she must not, or the page crashes with `NoMethodError`). Your row links need her `show` to look right. |
| Module A (Attendee 1) | Owns `DonorProfile` | D3 needs her `belongs_to :user`; the `matching` method goes in her `app/models/donor_profile.rb` with a mentor, as its own small commit after she merges |
| Module B (Attendee 2) | Same filter pattern on `/donors` | Compare your filter with hers; both use `filter-bar`, `card-list` and `card`, so they should look alike |
| Module E (Attendee 5) | Renders their partials in the same spot on the request page | Order matches screen 7: E's button, E's list, then your matching donors last. Your partial and theirs are separate files and each of you changes only your own line, so no conflict |
| Mentor seeds (P5) | 6 requests, 15 donors | Use them for the final check of D3 |

**Merge order:** Module C's model and `show` first, then Module A, then you (D1/D2 can merge any time since they only touch `index` and `index.html.erb`), then D3 once A and C are on main. Pull main after every merge announcement.

## Common mistakes

| Symptom | Cause | Fix |
| --- | --- | --- |
| Oldest request on top | `order(:created_at)` without `:desc` | `order(created_at: :desc)` |
| `undefined method 'each' for nil` | `@blood_requests` misspelled, or set in the wrong action | Check the name in both controller and view |
| Filter shows nothing for B+ | URL typed as `?blood_group=B+` (the `+` became a space) | Use the form, or write `%2B` |
| "All" shows nothing | Used `if params[:blood_group]` instead of `.present?` (`""` is truthy) | Use `.present?` |
| Filter resets to "All" after reload | Missing `selected: params[:blood_group]` | Add it to `f.select` |
| Only part of a card is clickable, or cards look unstyled | `class: "card"` put on an inner tag instead of on `link_to`, or the cards are not inside `<div class="card-list">` | Put `class: "card"` on the `link_to ... do` and wrap the loop in `card-list` |
| AI added Tailwind classes or `style="..."` | The prompt did not mention UI_DESIGN.md | Replace them with the component classes; there is no Tailwind in this app |
| Merge conflict in the controller | You edited outside `index` (reformatted, added a `before_action`) | Keep changes inside `index`; ask a mentor to resolve |
| `unknown attribute 'user'` in console | A mentor removed the generated `belongs_to :user` from `BloodRequest` | Use `user_id: User.first.id` |
| Date prints as `2026-10-12` | No formatting | `.strftime("%d %b %Y")` |
| Page shows nothing where the list should be | `<% %>` instead of `<%= %>` on `link_to` | Use `<%=` for anything that prints |
| `undefined local variable blood_request` in partial | `render` called without `blood_request:` | `render "blood_requests/matching_donors", blood_request: @blood_request` |

## Explain it (D4)

Questions a mentor will ask, and what a good answer covers:

| Question | Key points |
| --- | --- |
| What happens when someone opens `/blood_requests?blood_group=B%2B`? | Router → `BloodRequestsController#index`; `params[:blood_group]` is `"B+"`; the query adds a `where`; view loops and prints rows |
| Why can you write the `where` on a second line? | Relations are lazy; each call adds to the query; SQL runs once, when the view uses it |
| Why does the form use GET? | It reads data, saves nothing; the filter ends up in the URL so it can be bookmarked and the dropdown can stay selected |
| How did you make sure no phone is shown? | The view prints only chosen columns; never `contact_phone` or `phone` |
| How is the whole card one link? | `link_to path, class: "card" do ... end` wraps everything inside the block in one `<a>` tag |
| How did you avoid conflicts with Module C? | Edited only `index`; git merges separate blocks of lines automatically |
| *(D3)* Why is the query in the model? Why `includes`? | It is a data rule with a name; the view only displays. `includes` avoids one query per donor |
| Why is an O- donor not listed for an A+ request? | Exact match only; compatibility rules are out of scope |

Your five lines, following the [template](../MVC_GUIDE.md#explaining-your-module-at-the-demo):

1. "When you open `/blood_requests`, the router sends it to `BloodRequestsController#index`."
2. "The action asks the model for all requests with `BloodRequest.order(created_at: :desc)`, and adds `.where(blood_group: params[:blood_group])` if a group was chosen in the dropdown."
3. "The model makes sure every request has a valid blood group and city (Module C's validations), so the filter values always match what is stored."
4. "The view `index.html.erb` shows each request as a card with blood group, units, hospital, city and needed-by date; the whole card links to the request page, and it does not show the patient's name or contact phone."
5. "If nothing matches, like filtering for AB-, the page says 'No requests match this filter.' and offers a 'Clear filter' link."

## Out of scope

Say no even if your AI tool suggests these:

- Blood compatibility matching (O- donors for everyone, AB+ receiving from all)
- A city filter, search box, pagination or sorting options on the requests list
- Hiding past or "fulfilled" requests, or any status column (no new migrations)
- Editing, closing or deleting requests
- Showing phone numbers, patient names or contact buttons on the list or matching donors box
- Turbo Frames or Stimulus for live filtering; a plain GET form is enough
- Writing CSS, Tailwind classes or inline styles; use only the component classes from UI_DESIGN.md
- Gems like Ransack, Kaminari or Pagy
- Editing `config/routes.rb`, `show.html.erb` (beyond uncommenting your one `render` line) or Module C's actions
