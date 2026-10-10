# Module D: Requests list — tech spec

Oct 10, 2026 · Vishwajeetsingh Desurkar

You build the list of blood requests that donors open first, a blood group filter on top of it, and (with a mentor) a "matching donors" box on each request page.

See also: [ATTENDEE_TASKS.md](../ATTENDEE_TASKS.md) for your task list, [MVC_GUIDE.md](../MVC_GUIDE.md) for how models, views and controllers fit together, and [DB_SCHEMA.md](../DB_SCHEMA.md) for the tables.

## What you are building

A signed-in user who wants to help opens **Requests** in the nav bar and lands on `/blood_requests`. They see every blood request, newest first. Each row shows the blood group, units needed, hospital, city and needed-by date, and clicking the row opens that request's page (built by Module C).

```
Open requests                       [ All groups ▾ ] [Filter]
──────────────────────────────────────────────────────────────
B+  · 2 units · Ruby Hall Clinic, Pune      · needed by 12 Oct 2026
O-  · 1 unit  · KEM Hospital, Mumbai        · needed by 14 Oct 2026
AB+ · 3 units · Civil Hospital, Nashik      · needed by 15 Oct 2026
```

Choosing B+ in the dropdown and clicking **Filter** reloads the page as `/blood_requests?blood_group=B%2B` and shows only B+ requests.

On a request page (`/blood_requests/5`), your **Matching donors** box lists available donors with the same blood group and city as the request: name and city only, never a phone number.

In the demo journey you are step 4: "As the donor, find the request in the list." Module C's request is created in step 3, and the donor clicks it on your page before pressing Module E's "I can help" button in step 5.

## Done when

- [ ] `/blood_requests` lists all requests, newest first (D1)
- [ ] Each row shows blood group, units, hospital, city and needed-by date, and no phone number (D1)
- [ ] Clicking a row opens that request's page (D1)
- [ ] With no requests, the page says so instead of showing a blank space (D1)
- [ ] Choosing B+ shows only B+ requests; choosing "All groups" shows everything again (D2)
- [ ] The dropdown remembers the chosen group after the page reloads (D2)
- [ ] *(Cut first)* The request page lists available donors with the same blood group and city, name and city only, without the requester themselves (D3)
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
| Path helper | A method that builds a URL from a route | `blood_request_path(blood_request)`, `blood_requests_path` |
| GET form | A form that puts its fields in the URL instead of saving anything | the filter dropdown |
| Partial with locals | A reusable view piece that gets its data passed in | `_matching_donors.html.erb` |
| Class method on a model | A named, reusable query that lives in the model | `DonorProfile.matching(blood_request)` |

**ActiveRecord reads columns from the database.** A model file can be almost empty (`class BloodRequest < ApplicationRecord; end`) and `BloodRequest.order(created_at: :desc)` still works. When Rails first loads the class, it asks the database which columns the `blood_requests` table has and creates `hospital`, `city`, `needed_by` and so on for you. Module C adds rules (validations, `belongs_to`) to that file, but you can start before she merges, because the table already exists from the 0:20 migration. See [The Model](../MVC_GUIDE.md#the-model).

**Relations are lazy and chainable.** `BloodRequest.order(created_at: :desc)` does not run any SQL. It returns an `ActiveRecord::Relation`: a description of a query. Calling `.where(...)` on it returns a new relation with one more condition. The SQL runs only when the view uses the results (`.present?` or `.each`). That is why the filter can be an optional extra line: you add the `where` only when a group was chosen, and Rails still sends one single query.

**A GET form changes the URL, not the database.** The filter form uses `method: :get`, so submitting it just opens `/blood_requests?blood_group=B%2B`. The `index` action reads that value from `params[:blood_group]`. Nothing is saved, the URL can be bookmarked, and the back button works. This is the same pattern as Module B's donors filter (see [Your module, in MVC terms](../MVC_GUIDE.md#your-module-in-mvc-terms)).

**Partials receive data through locals.** Your `_matching_donors` partial is rendered inside Module C's page. Instead of reading her `@blood_request`, it receives `blood_request:` as a local, so it works no matter what the surrounding page calls its variables. See [Partials](../MVC_GUIDE.md#partials).

**Queries belong in the model, not the view.** "Available donors with the same blood group and city, not the requester" is a rule about data, so it reads best as a named model method, `DonorProfile.matching(blood_request)`. The view then just asks for it by name.

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
| `app/views/blood_requests/index.html.erb` | the list, filter form and empty state |
| `app/views/blood_requests/_matching_donors.html.erb` | the matching donors box (D3) |
| `test/integration/requests_list_test.rb` | optional test (see Testing checklist) |

**Do not touch:** `config/routes.rb`, `db/` (no migrations after 0:20), the `new`, `create` and `show` methods or the `private` section of `blood_requests_controller.rb`, `app/models/blood_request.rb`, `new.html.erb`, `_form.html.erb`, `show.html.erb` (Module C), and `app/models/donor_profile.rb` (Module A, except the one D3 method added together with a mentor).

**Sharing one controller file with Module C.** Git merges by comparing blocks of changed lines. If you only add lines between `def index` and its `end`, and Module C only adds lines inside `show`, `new`, `create` and the `private` section, your changes sit in different parts of the file, separated by lines neither of you changed. Git combines them automatically. A conflict happens only when you both change the same or neighbouring lines. So: do not reformat the file, do not reorder methods, do not add a `before_action` at the top, and do not "tidy up" Module C's empty methods even if your AI suggests it.

## Build steps

### D1. Requests list (Keep)

**Goal:** `/blood_requests` shows every request, newest first, each row linking to its page.

```ruby
# app/controllers/blood_requests_controller.rb  (only the index method)
def index
  @blood_requests = BloodRequest.order(created_at: :desc)
end
```

```erb
<%# app/views/blood_requests/index.html.erb %>
<h1 class="text-2xl font-bold mb-4">Open requests</h1>

<% if @blood_requests.present? %>
  <ul class="space-y-2">
    <% @blood_requests.each do |blood_request| %>
      <li>
        <%= link_to blood_request_path(blood_request), class: "block p-3 border rounded hover:bg-gray-50" do %>
          <strong><%= blood_request.blood_group %></strong>
          · <%= pluralize(blood_request.units_needed, "unit") %>
          · <%= blood_request.hospital %>, <%= blood_request.city %>
          · needed by <%= blood_request.needed_by.strftime("%d %b %Y") %>
        <% end %>
      </li>
    <% end %>
  </ul>
<% else %>
  <p>No blood requests yet.</p>
<% end %>
```

**What this does**

- `BloodRequest.order(created_at: :desc)`: "all requests, sorted by creation time, biggest (newest) first". It returns a relation; no SQL has run yet.
- `@blood_requests = ...`: the `@` makes it visible to `index.html.erb`. Rails renders that file automatically because the action is called `index`.
- `if @blood_requests.present?` / `else`: the empty state. Without it, an empty database shows only a heading, which looks broken. `.present?` loads the rows once, and `.each` reuses them, so the page runs one query.
- `each do |blood_request|`: repeats the `<li>` once per row. We name the block variable `blood_request`, not `request`, because `request` is already a built-in Rails method in views (the current HTTP request). Shadowing it causes confusing bugs.
- `link_to path do ... end`: makes the whole row one clickable link. `blood_request_path(blood_request)` builds `/blood_requests/5`.
- `pluralize(2, "unit")` prints "2 units"; `pluralize(1, "unit")` prints "1 unit".
- `strftime("%d %b %Y")` turns the date into "12 Oct 2026". `needed_by` is a `Date`, so you can format it. `contact_phone` and `patient_name` are deliberately left out.

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

Then run `bin/dev`, log in and open `http://localhost:3000/blood_requests`. Expected: two rows, KEM Hospital on top, no phone numbers. Clicking a row opens `/blood_requests/<id>` (blank or "missing template" until Module C's `show` is merged; the URL in the address bar is what you check).

**Suggested AI prompt**

> I'm working in a Rails 8.1 app. In `app/controllers/blood_requests_controller.rb`, fill in ONLY the empty `index` action so it loads all BloodRequest records newest first into `@blood_requests`. Then write `app/views/blood_requests/index.html.erb` that lists each request's blood_group, units_needed, hospital, city and needed_by (formatted like "12 Oct 2026"), with each row linking to `blood_request_path`. Do not show contact_phone or patient_name. Add an empty state. Use `blood_request` as the loop variable. Explain each line.

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
<%# app/views/blood_requests/index.html.erb  (add above the list) %>
<%= form_with url: blood_requests_path, method: :get, class: "flex gap-2 mb-4" do |f| %>
  <%= f.select :blood_group, BLOOD_GROUPS, include_blank: "All groups", selected: params[:blood_group] %>
  <%= f.submit "Filter", name: nil %>
<% end %>
```

And change the empty-state message so it makes sense when a filter is on:

```erb
<% else %>
  <% if params[:blood_group].present? %>
    <p>No <%= params[:blood_group] %> requests right now. <%= link_to "Show all", blood_requests_path %></p>
  <% else %>
    <p>No blood requests yet.</p>
  <% end %>
<% end %>
```

**What this does**

- Line 1 of `index` builds the base query. Line 2 adds `WHERE blood_group = 'B+'` only if a group was chosen. `.present?` is false for `nil` (no filter in the URL) and for `""` ("All groups" sends an empty value), so both show everything.
- Because relations are lazy, the two lines still produce one SQL query. Try `@blood_requests.to_sql` in the console to see it.
- `form_with url: blood_requests_path, method: :get`: a form not tied to a model. Submitting it opens `/blood_requests?blood_group=B%2B`. Because it is `GET`, it needs no strong parameters and saves nothing.
- `f.select :blood_group, BLOOD_GROUPS`: the dropdown sends a field called `blood_group`, which arrives as `params[:blood_group]`. Using `BLOOD_GROUPS` guarantees the values match what is stored.
- `selected: params[:blood_group]`: after the reload, the dropdown still shows the chosen group.
- `name: nil` on the submit button stops Rails adding `&commit=Filter` to the URL. Optional, but the URL stays clean.
- `%2B` is how a `+` is written inside a URL. A bare `+` in a URL means a space, so `?blood_group=B+` would arrive as `"B "` and match nothing. The form encodes it for you; if you type a URL by hand, write `B%2B`.

**Check it works**

```ruby
# bin/rails console
BloodRequest.order(created_at: :desc).where(blood_group: "B+").to_sql
# => SELECT "blood_requests".* FROM "blood_requests" WHERE "blood_requests"."blood_group" = 'B+' ORDER BY ...
BloodRequest.where(blood_group: "B+").count  # => 1 with the test data above
```

In the browser: choose B+, click Filter. Expected: URL ends in `?blood_group=B%2B`, only the Ruby Hall row shows, dropdown still says B+. Choose "All groups": both rows return. Choose AB-: "No AB- requests right now" with a "Show all" link.

**Suggested AI prompt**

> In my Rails 8.1 `BloodRequestsController#index` (only that method), add an optional blood group filter: if `params[:blood_group]` is present, add `.where(blood_group: ...)` to `@blood_requests`, keeping newest first. In `index.html.erb`, add a GET filter form using `form_with url: blood_requests_path, method: :get` with a select of the `BLOOD_GROUPS` constant, "All groups" as the blank option, and the current choice selected. No gems like Ransack. Explain why relations can be chained and why `+` becomes `%2B`.

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

<section class="mt-6">
  <h2 class="text-xl font-semibold">Matching donors</h2>
  <p class="text-sm text-gray-600">Available <%= blood_request.blood_group %> donors in <%= blood_request.city %></p>

  <% if donors.present? %>
    <ul>
      <% donors.each do |profile| %>
        <li><%= profile.user.name %> · <%= profile.city %></li>
      <% end %>
    </ul>
  <% else %>
    <p>No matching donors yet.</p>
  <% end %>
</section>
```

- `blood_request` (no `@`) is the local passed in by `render`. The partial never reads `@blood_request`.
- The partial calls a named model method, not a raw `where`, so the view only decides *how to show* donors, not *which* ones.
- Only `profile.user.name` and `profile.city` are printed. `profile.phone` is never used here.

Why not set `@matching_donors` in the controller? That would mean editing Module C's `show` method, which causes merge conflicts. A model method called from a self-contained partial keeps the files separate.

**Step 3: render it on the request page.** In Module C's `show.html.erb`, in the marked spot at the bottom, your line is waiting, commented out:

```erb
<%= render "blood_requests/matching_donors", blood_request: @blood_request %>
```

Only you uncomment your line, after both Module C's page and `DonorProfile.matching` are on main. If D3 is cut, leave the line commented.

**Check it works**

```ruby
# bin/rails console (needs Module A's belongs_to :user and Module C's request)
r = BloodRequest.last                                   # say B+ in Pune
DonorProfile.matching(r).map { |p| [p.user.name, p.blood_group, p.city] }
# => only B+ donors in Pune with available: true, not r's own user
```

In the browser: open a B+ Pune request from seed data. Expected: only B+ Pune donors, names and cities, no phones. Edit a donor to unavailable (Module A3) and reload: that donor disappears.

**Suggested AI prompt**

> In Rails 8.1, I need a class method `DonorProfile.matching(blood_request)` that returns donor profiles with the same blood_group and city as the request, `available: true`, excluding the request's own `user_id`, with `includes(:user)`. Then write a partial `app/views/blood_requests/_matching_donors.html.erb` that receives a local `blood_request`, calls that method, and lists each donor's `user.name` and `city` only, never phone, with an empty state. Exact matches only, no blood compatibility rules. Explain why the query is in the model and what `includes` does.

## Privacy and edge cases

| Situation | What happens / how the code handles it |
| --- | --- |
| Phone numbers | Neither view prints `contact_phone` or `phone`. Check by searching the page source for a known test number. |
| Not logged in | `ApplicationController`'s `Authentication` concern redirects to login. You add nothing. |
| No requests at all | Empty state: "No blood requests yet." |
| Filter matches nothing | "No B- requests right now" plus a "Show all" link. |
| "All groups" chosen | `params[:blood_group]` is `""`; `.present?` is false, so no filter. |
| Someone types `?blood_group=XYZ` | `where` simply finds nothing; values are passed safely as SQL parameters, never pasted into SQL. |
| Requester views their own request | `where.not(user_id: ...)` hides them from matching donors. |
| Donor set to unavailable | `available: true` hides them. |
| Donor without a name | `name` is required by a model validation on User, so it should not happen; seeds always set it. |
| Past needed-by dates | Still listed. There is no "closed" status today (out of scope). |

## Testing checklist

1. Log out, open `/blood_requests` → redirected to login.
2. Log in, open `/blood_requests` with no data → "No blood requests yet."
3. Create two requests in the console (B+ then O-) → both listed, O- on top.
4. Each row shows group, units, hospital, city, date; page source has no phone number.
5. Click a row → URL becomes `/blood_requests/<that id>`.
6. Filter B+ → only B+; URL has `blood_group=B%2B`; dropdown still says B+.
7. Filter "All groups" → everything back. Filter AB- → empty-state message with "Show all".
8. After merging with seeds: open a request page → matching donors section shows only same group and city, names and cities only (D3).
9. Open a request you posted yourself while having a matching donor profile → you are not in your own list (D3).

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
| Mentors | Routes, login, layout, nav link, `BLOOD_GROUPS`, empty `index` action | Already done before 0:20 |
| Module C (Attendee 3) | Owns the `BloodRequest` model and `show` page; shares your controller file | You edit only `index`. Only you uncomment your D3 `render` line, once her page and `DonorProfile.matching` are on main (she must not, or the page crashes with `NoMethodError`). Your row links need her `show` to look right. |
| Module A (Attendee 1) | Owns `DonorProfile` | D3 needs her `belongs_to :user`; the `matching` method goes in her `app/models/donor_profile.rb` with a mentor, as its own small commit after she merges |
| Module B (Attendee 2) | Same filter pattern on `/donors` | Compare your filter with hers; they should look alike |
| Module E (Attendee 5) | Renders their partials in the same spot on the request page | Your partial and theirs are separate files, so no conflict |
| Mentor seeds (P5) | 6 requests, 15 donors | Use them for the final check of D3 |

**Merge order:** Module C's model and `show` first, then Module A, then you (D1/D2 can merge any time since they only touch `index` and `index.html.erb`), then D3 once A and C are on main. Pull main after every merge announcement.

## Common mistakes

| Symptom | Cause | Fix |
| --- | --- | --- |
| Oldest request on top | `order(:created_at)` without `:desc` | `order(created_at: :desc)` |
| `undefined method 'each' for nil` | `@blood_requests` misspelled, or set in the wrong action | Check the name in both controller and view |
| Filter shows nothing for B+ | URL typed as `?blood_group=B+` (the `+` became a space) | Use the form, or write `%2B` |
| "All groups" shows nothing | Used `if params[:blood_group]` instead of `.present?` (`""` is truthy) | Use `.present?` |
| Filter resets to "All groups" after reload | Missing `selected: params[:blood_group]` | Add it to `f.select` |
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
| How did you avoid conflicts with Module C? | Edited only `index`; git merges separate blocks of lines automatically |
| *(D3)* Why is the query in the model? Why `includes`? | It is a data rule with a name; the view only displays. `includes` avoids one query per donor |
| Why is an O- donor not listed for an A+ request? | Exact match only; compatibility rules are out of scope |

Your five lines, following the [template](../MVC_GUIDE.md#explaining-your-module-at-the-demo):

1. "When you open `/blood_requests`, the router sends it to `BloodRequestsController#index`."
2. "The action asks the model for all requests with `BloodRequest.order(created_at: :desc)`, and adds `.where(blood_group: params[:blood_group])` if a group was chosen in the dropdown."
3. "The model makes sure every request has a valid blood group and city (Module C's validations), so the filter values always match what is stored."
4. "The view `index.html.erb` shows blood group, units, hospital, city and needed-by date, each linking to the request page, and does not show the patient's name or contact phone."
5. "If nothing matches, like filtering for AB-, the page says there are no AB- requests and offers a 'Show all' link."

## Out of scope

Say no even if your AI tool suggests these:

- Blood compatibility matching (O- donors for everyone, AB+ receiving from all)
- A city filter, search box, pagination or sorting options on the requests list
- Hiding past or "fulfilled" requests, or any status column (no new migrations)
- Editing, closing or deleting requests
- Showing phone numbers, patient names or contact buttons on the list or matching donors box
- Turbo Frames or Stimulus for live filtering; a plain GET form is enough
- Gems like Ransack, Kaminari or Pagy
- Editing `config/routes.rb`, `show.html.erb` (beyond uncommenting your one `render` line) or Module C's actions
