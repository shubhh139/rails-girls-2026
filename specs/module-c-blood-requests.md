# Module C: Blood requests — tech spec

Oct 10, 2026 · Vishwajeetsingh Desurkar

You build the `BloodRequest` model rules, the "Request blood" form and the page that shows one request, so a signed-in user can ask for blood and land on a page that others can open.

See also: [../ATTENDEE_TASKS.md](../ATTENDEE_TASKS.md) for your task list, [../MVC_GUIDE.md](../MVC_GUIDE.md) for MVC basics (it uses your module as its main example), [../DB_SCHEMA.md](../DB_SCHEMA.md) for the table, and [../UI_DESIGN.md](../UI_DESIGN.md) for how your pages look and which CSS classes to use.

## What you are building

From the user's point of view:

1. A signed-in user clicks **Request blood** in the nav bar and gets a form (`/blood_requests/new`).
2. They fill in patient name, blood group (dropdown), units needed, hospital, city (dropdown), needed-by date, contact phone and an optional note, then click **Post request**.
3. If something is missing, the same form comes back with the typed values kept and a list of errors at the top.
4. If everything is fine, they land on the request page (`/blood_requests/7`) with a "Request posted." message and the request details.

The request page is the centre of the app. Donors reach it from Module D's list, Module E adds the "I can help" button and the responses list to it, and Module D shows matching donors under those.

Your two pages are screens 6 and 7 in [UI_DESIGN.md](../UI_DESIGN.md#screens). Build them to match these wireframes, using only the component classes listed there (`page-title`, `card`, `card-list`, `btn`, `btn btn-primary`, `form-field`, `form-errors`, `filter-bar`, `badge`, `meta`, `empty-state`). No Tailwind, no inline styles, no new CSS. The mentor's layout already provides the `.container` width, the nav, the footer and the flash message, so your pages start straight with their `<h1>`.

[Screen 6. Request blood](../UI_DESIGN.md#6-request-blood-module-c) (`new.html.erb`):

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

[Screen 7. Request page](../UI_DESIGN.md#7-request-page-module-c-with-d-and-e) (`show.html.erb`; you build the top part and leave the spot for E and D):

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

Notice what is not on screen 7: the requester's contact phone. UI_DESIGN's rule is "Phones appear only in a request's responses list, to its creator." See the C3 decision below.

In the demo journey you own **step 3**: "As a second user, post a blood request." Steps 4 and 5 happen on the page you build.

## Done when

- [ ] **C1.** `BloodRequest.new.valid?` returns `false` in the console, and `errors.full_messages` lists every required field. A request with `units_needed: 0` is rejected.
- [ ] **C2.** A signed-in user can fill the form and save a request, and the saved request's `user` is that logged-in user.
- [ ] **C2.** Submitting with units left blank shows an error on the form, and the other typed values are still there.
- [ ] **C2.** The form page matches screen 6 of UI_DESIGN.md: one `<h1 class="page-title">` "Request blood", fields in the screen's order, each in a `form-field`, errors in one `form-errors` box, and one `btn btn-primary` "Post request" button.
- [ ] **C3.** After saving, the browser lands on `/blood_requests/:id` showing the request details and the "Request posted." notice.
- [ ] **C3.** The request page matches the top of screen 7: blood group `badge`, units and patient name in the `page-title`, hospital and city in a `meta` line, the needed-by date, and the note only if there is one.
- [ ] **C3.** The requester's `contact_phone` does not appear anywhere on the request page.
- [ ] **C3.** The bottom of `show.html.erb` has a clearly marked spot for Modules E and D, in screen 7's order.
- [ ] **C2, C3.** Your views use only UI_DESIGN.md component classes: no Tailwind classes, no inline styles, no wrapper `div` for width.
- [ ] **C4.** You have explained your model, controller and views to a mentor.

## Concepts you will use

| Concept | What it is in one line | Where you use it |
| --- | --- | --- |
| Association | A link between two models that gives you methods like `request.user` | `belongs_to :user`, `has_many :responses` in C1 |
| Validation | A rule checked before a row is saved | C1, shown as errors on the form in C2 |
| Strong parameters | The list of form fields the controller lets into the model | `blood_request_params` in C2 |
| `form_with model:` | A form helper that picks the URL, verb and field names from the model | `_form.html.erb` in C2 |
| Render vs redirect | Re-build a page in this response, or tell the browser to go to another URL | `create` in C2 |
| HTTP status 422 | "Unprocessable": tells Turbo the form failed and the HTML should be shown | `create` in C2 |
| `find` and 404 | Look up one row by id; a missing id becomes a "Not found" page | `show` in C3 |
| Flash | A one-time message that survives exactly one redirect | `notice:` in C2, printed by the layout on the C3 page |
| Partial with locals | A reusable view piece that receives its data as named arguments | `_form`, and the spot for D and E in C3 |

**Validations live in the model, not the form.** The dropdowns in your form make wrong values unlikely, but anyone can send a crafted request to `POST /blood_requests`. The model is the one place every save goes through (the form, the console, the seeds), so the rules go there. `save` returns `false` when a rule fails and fills `errors`, which your form displays.

**Building through the association.** `Current.user.blood_requests.new(...)` is the same as `BloodRequest.new(..., user_id: Current.user.id)`, but shorter and safe: `user_id` is never in the strong params, so nobody can post a request as someone else. This works because of `has_many :blood_requests` on `User` (a mentor adds it) and `belongs_to :user` on your model.

**Render vs redirect, and why 422.** On success you `redirect_to`: the browser makes a fresh `GET /blood_requests/7`, so refreshing does not post the form twice. On failure you `render :new` so the object, its typed values and its `errors` are still in memory. Rails 8 uses Turbo, which submits forms with JavaScript. Turbo expects a form submission to either redirect or come back with an error status. If you render the form with the normal 200 status, Turbo ignores the HTML and nothing happens: the errors never show (the browser console says "Form responses must redirect to another location"). `status: :unprocessable_entity` (422) tells Turbo "this failed, show the HTML I sent".

**How `redirect_to @blood_request` becomes `/blood_requests/7`.** When you pass a model object instead of a URL, Rails asks it for its model name (`BloodRequest`), turns that into a route helper name (`blood_request_url`), and calls it with the object. The helper calls `@blood_request.to_param`, which returns the id, so you get `/blood_requests/7`. This is called a *polymorphic URL*. The same trick lets `link_to "Open", request` work in Module D's list, and lets `form_with model:` pick `POST /blood_requests` for a new record.

**Flash.** `redirect_to ..., notice: "Request posted."` stores the message in the session for the next request only. The page you redirect to reads it with `notice` and it disappears after that.

## Data you work with

Table `blood_requests` (created by a mentor at 0:00; see [DB_SCHEMA.md](../DB_SCHEMA.md#blood_requests-modules-c-and-d)). You write every column through the form, except `user_id` (set from `Current.user`) and the timestamps.

| Column | Type | DB: null allowed? | DB default | Model rule (yours, C1) |
| --- | --- | --- | --- | --- |
| user_id | integer | no (foreign key) | | `belongs_to :user` makes it required |
| patient_name | string | no | | presence |
| blood_group | string | no | | inclusion in `BLOOD_GROUPS` |
| units_needed | integer | no | 1 | integer, at least 1 |
| hospital | string | no | | presence |
| city | string | no | | inclusion in `CITIES` |
| needed_by | date | no | | presence (optional extra: not in the past) |
| contact_phone | string | no | | presence |
| note | text | yes | | none, it is optional |

**DB vs model.** The database refuses `NULL` (`null: false`) but would happily store an empty string `""`, `"Z+"`, `"Delhi"` or `units_needed = 0`. It also fails loudly with an exception, not a friendly message. The model validations catch all of these first and give readable errors. Think of the database as the last safety net and the model as the real gatekeeper.

Because of the DB default, `BloodRequest.new.units_needed` is already `1`, so the form starts with 1 in that box.

## URLs and routes

Written by mentors in `config/routes.rb`. You only read them (`bin/rails routes -g blood_request`).

| Verb | Path | Controller#action | Path helper | What it does |
| --- | --- | --- | --- | --- |
| GET | `/blood_requests/new` | `blood_requests#new` | `new_blood_request_path` | Shows the empty form |
| POST | `/blood_requests` | `blood_requests#create` | `blood_requests_path` | Saves the form; redirects or re-renders |
| GET | `/blood_requests/:id` | `blood_requests#show` | `blood_request_path(request)` | Shows one request |

`GET /blood_requests` (`index`) is Module D's. `POST /blood_requests/:blood_request_id/responses` is Module E's; their button is rendered on your page.

## Files you own

| File | What you put there |
| --- | --- |
| `app/models/blood_request.rb` | Associations and validations (C1) |
| `app/controllers/blood_requests_controller.rb` | **Only** `new`, `create`, `show` and the private `blood_request_params` (C2, C3) |
| `app/views/blood_requests/new.html.erb` | Page heading plus `render "form"` (C2) |
| `app/views/blood_requests/_form.html.erb` | The form itself (C2) |
| `app/views/blood_requests/show.html.erb` | The request page and the marked spot (C3) |

**Do not touch:** `config/routes.rb`, `db/` (no migrations), `app/models/user.rb`, the layout, the `index` method and `index.html.erb` / `_matching_donors.html.erb` (Module D), anything in `app/views/responses/` or `app/models/response.rb` (Module E).

The controller file is shared with Module D. Edit only the bodies of your methods and add `blood_request_params` at the bottom. Do not reorder, reformat or "tidy" the file, and do not let the AI rewrite the whole file. Small, separate edits merge cleanly; a rewritten file causes a merge conflict.

## Build steps

### C1. BloodRequest model rules

**Goal:** an invalid request is rejected in the console.

The model generator already wrote `belongs_to :user` for you. Add the rest:

```ruby
# app/models/blood_request.rb
class BloodRequest < ApplicationRecord
  belongs_to :user
  has_many :responses, dependent: :destroy

  validates :patient_name, :hospital, :contact_phone, :needed_by, presence: true
  validates :blood_group, inclusion: { in: BLOOD_GROUPS }
  validates :city, inclusion: { in: CITIES }
  validates :units_needed, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
end
```

**What this does:**

- `belongs_to :user` (keep the generated line) gives you `request.user`, and since Rails 5 it also means "a request without a user is invalid".
- `has_many :responses, dependent: :destroy` gives you `request.responses` for Module E, and deletes a request's responses if the request is deleted. The `Response` class was created by the mentor's generator at 0:00 (it already has `belongs_to :blood_request` and `belongs_to :donor`), so this line works on your branch now. Even if a model is missing, a `has_many` only fails when you actually call `request.responses`, not when the file loads.
- `presence: true` rejects `nil` and blank strings.
- `inclusion` only allows the 8 groups and 5 cities. A blank value is not in the list either, so you do not need `presence` on these two.
- `numericality` rejects blanks, text, `1.5` and anything below 1.

**Optional extra (only if C2 and C3 are done):** reject dates in the past. Tell the mentor writing seeds (P5), since seeds with old dates would then fail.

```ruby
# app/models/blood_request.rb (inside the class)
  validate :needed_by_not_in_the_past

  private

  def needed_by_not_in_the_past
    if needed_by.present? && needed_by < Date.current
      errors.add(:needed_by, "can't be in the past")
    end
  end
```

**Check it works:**

```ruby
# bin/rails console
r = BloodRequest.new
r.valid?                 # => false
r.errors.full_messages   # => ["User must exist", "Patient name can't be blank", ..., "Blood group is not included in the list", ...]

r = User.first.blood_requests.new(patient_name: "Test Patient", blood_group: "O+", units_needed: 0,
      hospital: "City Hospital", city: "Pune", needed_by: Date.tomorrow, contact_phone: "9000000001")
r.valid?                 # => false, "Units needed must be greater than or equal to 1"
r.units_needed = 2
r.save                   # => true
r.user                   # => the first user
```

**AI prompt:** "In the Rails 8.1 model `app/models/blood_request.rb` (columns: user_id, patient_name, blood_group, units_needed integer, hospital, city, needed_by date, contact_phone, note text), add `has_many :responses, dependent: :destroy` and validations: every field except note is required, blood_group must be in the constant `BLOOD_GROUPS`, city in `CITIES`, units_needed an integer of at least 1. Keep the existing `belongs_to :user`. Explain each line."

### C2. Request form

**Goal:** the form saves a request owned by the logged-in user, and a bad form comes back with errors.

```ruby
# app/controllers/blood_requests_controller.rb (only your parts shown)
  def new
    @blood_request = BloodRequest.new
  end

  def create
    @blood_request = Current.user.blood_requests.new(blood_request_params)

    if @blood_request.save
      redirect_to @blood_request, notice: "Request posted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def blood_request_params
    params.expect(blood_request: [ :patient_name, :blood_group, :units_needed, :hospital,
                                   :city, :needed_by, :contact_phone, :note ])
  end
```

**What this does:**

- `new` builds an empty, unsaved request so the form has an object to describe.
- `create` builds a request for `Current.user` from the allowed fields only, then tries to `save` (which runs your C1 validations).
- Success: `redirect_to @blood_request` sends the browser to `/blood_requests/:id` (see Concepts) with a flash notice.
- Failure: `render :new` shows `new.html.erb` again using the same `@blood_request`, which still holds the typed values and `errors`. The 422 status makes Turbo display it.
- `params.expect(blood_request: [...])` requires a `blood_request` hash in the submitted data and keeps only the listed keys. `user_id` is deliberately not listed. If the hash is missing, Rails raises `ParameterMissing`: a 400 Bad Request in production, a red error page in development.

```erb
<%# app/views/blood_requests/new.html.erb %>
<h1 class="page-title">Request blood</h1>
<%= render "form", blood_request: @blood_request %>
```

```erb
<%# app/views/blood_requests/_form.html.erb %>
<%= form_with model: blood_request do |f| %>
  <% if blood_request.errors.any? %>
    <div class="form-errors">
      <ul>
        <% blood_request.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-field">
    <%= f.label :patient_name %>
    <%= f.text_field :patient_name %>
  </div>

  <div class="form-field">
    <%= f.label :blood_group %>
    <%= f.select :blood_group, BLOOD_GROUPS, include_blank: "Choose…" %>
  </div>

  <div class="form-field">
    <%= f.label :units_needed %>
    <%= f.number_field :units_needed, min: 1 %>
  </div>

  <div class="form-field">
    <%= f.label :hospital %>
    <%= f.text_field :hospital %>
  </div>

  <div class="form-field">
    <%= f.label :city %>
    <%= f.select :city, CITIES, include_blank: "Choose…" %>
  </div>

  <div class="form-field">
    <%= f.label :needed_by %>
    <%= f.date_field :needed_by %>
  </div>

  <div class="form-field">
    <%= f.label :contact_phone %>
    <%= f.telephone_field :contact_phone %>
  </div>

  <div class="form-field">
    <%= f.label :note, "Note (optional)" %>
    <%= f.text_area :note, rows: 3 %>
  </div>

  <%= f.submit "Post request", class: "btn btn-primary" %>
<% end %>
```

**What this does:**

- `new.html.erb` has the page's one `<h1 class="page-title">`, which matches the "Request blood" nav link (an accessibility rule in UI_DESIGN.md). There is no wrapper `div`: the layout already puts every page inside `.container`.
- `new.html.erb` passes the object into the partial as a local (`blood_request:`), following the team rule "partials get data through locals". (MVC_GUIDE's short example uses `@blood_request` inside the partial; the local version is what we use.)
- `form_with model: blood_request` sees a new record, so it posts to `/blood_requests`, and names every field `blood_request[...]`. That name is why `params.expect(blood_request: ...)` finds them.
- The `form-errors` box only appears when `save` failed, because only then does `errors` contain anything. It holds one list of the model's full messages, at the top of the form.
- Each label and its input sit together in a `<div class="form-field">`, which puts the label above the input with space below. `f.label` and the `f.` input helpers share the same field name, so clicking the label focuses the input (and screen readers read them together). Placeholders are not labels; every field has a visible one.
- The fields are in screen 6's order. `f.label :note, "Note (optional)"` changes the label text; the others use the column name ("Patient name", "Needed by").
- `f.select ... BLOOD_GROUPS` makes the 8 groups a dropdown, so blood group is never typed freely (a PRD rule). `include_blank` puts a blank "Choose…" option first and forces a real choice.
- `number_field`, `date_field` and `telephone_field` give the browser the right keyboard and a date picker. They are hints only; the model still checks.
- `class: "btn btn-primary"` makes "Post request" the one red main action on the page. These are the only classes in the form: the shared stylesheet already styles labels, inputs and selects inside `.form-field`.

**Check it works:** start `bin/dev`, log in, open `/blood_requests/new`.

- Compare the page with screen 6 of UI_DESIGN.md: same heading, same field order, red "Post request" button.
- Clear the units box and submit: the form comes back with "Units needed is not a number" in the error box at the top and your other values still filled.
- Fill everything and submit: you land on `/blood_requests/<id>`. (Until C3 is done this shows a missing-template error; that still proves the save worked.)
- In the console: `BloodRequest.last.user` is the user you logged in as.

**AI prompt:** "Rails 8.1 app with Hotwire. In `BloodRequestsController`, fill in only the `new` and `create` actions and add a private `blood_request_params` using `params.expect`, permitting patient_name, blood_group, units_needed, hospital, city, needed_by, contact_phone, note. Build the request with `Current.user.blood_requests.new`. On failure use `render :new, status: :unprocessable_entity`. Do not touch the `index` action. Then write `new.html.erb` that renders a `_form` partial with a local `blood_request:`, and the `_form` using `form_with`. Use only the component classes from UI_DESIGN.md (`page-title`, `form-field`, `form-errors`, `btn btn-primary`); no Tailwind, no inline styles, and no wrapper div (the layout provides the container and flash). `new.html.erb` has one `<h1 class="page-title">Request blood</h1>`. The form starts with a `<div class="form-errors">` holding a `<ul>` of `full_messages`, only when there are errors. Then each label plus input in its own `<div class="form-field">`, in this order: patient name, blood group (`f.select` with `BLOOD_GROUPS`, blank first), units needed (`number_field`, min 1), hospital, city (`f.select` with `CITIES`, blank first), needed by (`date_field`), contact phone (`telephone_field`), note (label "Note (optional)", `text_area`). End with `f.submit "Post request", class: "btn btn-primary"`. Explain why 422 is needed with Turbo."

### C3. Request page

**Goal:** after saving, the user lands on a page that matches the top of screen 7 (every detail except the contact phone), with a marked spot for E and D.

```ruby
# app/controllers/blood_requests_controller.rb
  def show
    @blood_request = BloodRequest.find(params[:id])
  end
```

```erb
<%# app/views/blood_requests/show.html.erb %>
<h1 class="page-title"><span class="badge"><%= @blood_request.blood_group %></span> <%= pluralize(@blood_request.units_needed, "unit") %> needed for <%= @blood_request.patient_name %></h1>

<p class="meta"><%= @blood_request.hospital %>, <%= @blood_request.city %></p>
<p>Needed by <%= @blood_request.needed_by.strftime("%d %b %Y") %></p>

<% if @blood_request.note.present? %>
  <p>Note: <%= @blood_request.note %></p>
<% end %>

<%# ===== Modules D and E: add your render lines below. Do not edit above this line. ===== %>
<%# Module E: render "responses/button", blood_request: @blood_request %>
<%# Module E: render "responses/list", blood_request: @blood_request %>
<%# Module D: render "blood_requests/matching_donors", blood_request: @blood_request %>
<%# ===== end of shared spot ===== %>
```

**What this does:**

- `params[:id]` is the `7` in `/blood_requests/7`. `find` returns that row, or raises `ActiveRecord::RecordNotFound` if there is none. Rails turns that into a 404 "Not found" page (in development you see a red error page saying so).
- `<%= %>` prints each value; the `<% if %>` hides the note line when there is no note.
- The page has exactly one `<h1 class="page-title">`, as on screen 7: "[B+] 2 units needed for Ravi Patil". The blood group sits inside a `<span class="badge">`, so it is always written as text, never shown by colour alone.
- `pluralize(@blood_request.units_needed, "unit")` is a Rails helper that prints the number and the right word: "1 unit", "2 units".
- `<p class="meta">` is the muted secondary line with the hospital and city, like "Sahyadri Hospital, Pune".
- `strftime("%d %b %Y")` formats the date from a pattern: `%d` is the two-digit day, `%b` the short month name, `%Y` the four-digit year. So `2026-10-12` prints as "12 Oct 2026", matching screen 7.
- There is no `notice` code and no wrapper `div` here. The layout puts the page inside `.container` and prints the "Request posted." flash from `create`.
- The marked spot holds commented-out lines in screen 7's order: E's "I can help" button, then E's responses list, then D's matching donors. D and E each turn their own line into `<%= render ... %>` after your page is on main. Each line is separate, so their edits do not conflict with each other.

**Decision on `contact_phone`:** the requester's contact phone is collected by the form and stored in the table, but it is not displayed anywhere in this PoC, including this page. UI_DESIGN.md's rule is "Phones appear only in a request's responses list, to its creator." Instead, donors click Module E's "I can help" button, and the requester (the only person who sees the responses list) contacts them using the phones shown there. So there is no `contact_phone` line in `show.html.erb`, and the only phone numbers on this page come from E's creator-only responses list.

**Check it works:** post a request through the form. You should land on its page with the "Request posted." message (printed by the layout), and the page should look like the top of screen 7: badge, units and patient name in the heading, hospital and city, needed-by date, note. No phone number anywhere. Refresh: the notice is gone, the details stay. Open `/blood_requests/99999`: you get the "Not found" error, not a broken page with `nil` errors.

**AI prompt:** "Rails 8.1. Fill in the `show` action of `BloodRequestsController` with `BloodRequest.find(params[:id])`. Write `app/views/blood_requests/show.html.erb`. Use only the component classes from UI_DESIGN.md (`page-title`, `badge`, `meta`); no Tailwind, no inline styles, and no wrapper div or flash code (the layout provides them). Start with one `<h1 class="page-title">` containing the blood group in a `<span class="badge">`, then `pluralize(units_needed, "unit")` needed for the patient name. Then a `<p class="meta">` with hospital and city, a paragraph 'Needed by' with `needed_by.strftime("%d %b %Y")`, and the note only if present, as 'Note: ...'. Do not show contact_phone or the requester's name. End with a marked comment block where other modules will add `render` lines, in this order: `responses/button`, `responses/list`, `blood_requests/matching_donors`, each with a local `blood_request:`. Explain each ERB tag."

## Privacy and edge cases

| Situation | What happens | Handled by |
| --- | --- | --- |
| Someone adds `user_id=1` to the form data | Ignored: not in strong params; owner comes from `Current.user` | `blood_request_params`, `create` |
| Signed-out visitor opens `/blood_requests/new` | Sent to the login page | `Authentication` concern (mentors) |
| Blood group typed as "Z+" via a crafted request | Rejected with an error | `inclusion` validation |
| Units blank, 0, -2 or 1.5 | Rejected with an error | `numericality` validation |
| Id that does not exist | 404 Not found | `find` |
| Refreshing after posting | Just reloads the page; no duplicate request | Redirect after `create` |
| Note contains `<script>` | Shown as plain text, not run | ERB `<%= %>` escapes HTML automatically |
| Requester's contact phone | Collected and stored, but not shown on the request page or any list | Your C3 decision; `show.html.erb` has no `contact_phone` line |
| A donor wants to help | Clicks "I can help"; the requester sees the donor's phone in the responses list | Module E (creator-only list) |

Use only made-up names and phone numbers, for example `9000000001`.

## Testing checklist

1. Log in, click **Request blood**. Expected: the page matches screen 6 of UI_DESIGN.md: heading "Request blood", fields in the screen's order with visible labels, units shows 1, dropdowns say "Choose…", one red "Post request" button.
2. Submit the empty form. Expected: same page, a `form-errors` box at the top listing the errors. (The address bar still shows `/blood_requests/new`: Turbo swaps the page content without changing the URL.)
3. Fill everything except units (clear it). Expected: "Units needed is not a number"; other values kept.
4. Fill everything correctly. Expected: `/blood_requests/<id>` with "Request posted." and the request details.
5. Check the request page against the top of screen 7: blood group badge, "2 units needed for ..." heading, hospital and city line, "Needed by 12 Oct 2026" style date, note only if you typed one. Expected: no phone number anywhere on the page.
6. Refresh. Expected: notice gone, no second request created (`BloodRequest.count` unchanged).
7. Log out, log in as a different user, open the same URL. Expected: page still shows the same details, and still no phone number.
8. Open `/blood_requests/99999`. Expected: Not found.

> Needs test setup by a mentor: this app was created without the test framework (`config/application.rb` has `rails/test_unit/railtie` commented out and there is no `test/` folder). Skip this if a mentor has not set it up.

Optional model test (run with `bin/rails test test/models/blood_request_test.rb`):

```ruby
# test/models/blood_request_test.rb
require "test_helper"

class BloodRequestTest < ActiveSupport::TestCase
  test "units needed must be at least 1" do
    request = BloodRequest.new(units_needed: 0)
    assert_not request.valid?
    assert_includes request.errors[:units_needed], "must be greater than or equal to 1"
  end
end
```

If every test fails with "uninitialized constant Donor" or "Missing model class Donor", Module E's `class_name: "User"` is not merged yet; ask a mentor.

## Working with other modules

| Who | Relationship | What to agree on |
| --- | --- | --- |
| Mentors | You depend on them | Login and `Current.user`, routes, empty controller actions, `BLOOD_GROUPS`/`CITIES`, the table, and `has_many :blood_requests` on `User` |
| Module D | Shares your controller; links to your page; renders `_matching_donors` on it | D edits only `index`, you only `new`/`create`/`show`. D's list must not show `contact_phone` |
| Module E | Needs your `has_many :responses`; renders `responses/_button` and `_list` on your page | Locals are named `blood_request:`; E edits only the commented line in the marked spot |
| P5 seeds | Seeds create requests | If you add the "not in the past" rule, tell the seeds mentor |

**Merge order:** your module should merge early, ideally first among D and E, because both add lines to your `show.html.erb`. Open your pull request as soon as C2 and C3 work. After it is on main, D and E pull main and add their render lines. Until then, D tests with requests made in the console, and E tests partials in the console.

## Common mistakes

| Symptom | Cause | Fix |
| --- | --- | --- |
| Errors never show; nothing happens (browser console: "Form responses must redirect to another location") | `render :new` without the 422 status | Add `status: :unprocessable_entity` |
| You see `:unprocessable_content` in newer docs or AI output | Rack renamed the 422 symbol | Same 422; Rails 8.1 accepts both silently. We use `:unprocessable_entity` (team convention). |
| "User must exist" on a filled form | Built with `BloodRequest.new(...)` instead of through `Current.user` | Use `Current.user.blood_requests.new(...)` |
| A field saves as empty | Field missing from `blood_request_params` | Add it to the `params.expect` list |
| `ParameterMissing` (red error page in development; 400 Bad Request in production) | Form fields not named `blood_request[...]` | Use `form_with model:` and `f.` helpers |
| `undefined local variable or method 'blood_request'` in `_form` | Partial rendered without the local | `render "form", blood_request: @blood_request` |
| `undefined method 'strftime' for nil` on show | A request without `needed_by` (made outside validations) | Make sure C1 validations are in; fix the bad row |
| `uninitialized constant BLOOD_GROUPS` | Constants initializer missing on your branch | Pull main; restart `bin/dev` after initializer changes |
| Merge conflict in the controller | Whole file rewritten by the AI | Only edit your method bodies; ask a mentor to resolve |
| Notice shows twice | Your view prints `notice` and the layout does too | Remove the `notice` block from `show.html.erb`; the layout handles it |

## Explain it (C4)

Questions a mentor will ask, and what a good answer covers:

| Question | Key points |
| --- | --- |
| Why are the rules in the model, not the form? | Every save goes through the model; the form can be bypassed; one place for rules |
| How does the request know who posted it? | `Current.user.blood_requests.new` sets `user_id`; it is not in strong params, so it cannot be faked |
| What does `blood_request_params` protect against? | Extra fields like `user_id` sneaking in (mass assignment) |
| Why redirect on success but render on failure? | Redirect avoids double posting; render keeps the typed values and errors in memory |
| Why the 422? | Turbo only shows HTML from a failed form submission if the status says it failed |
| How does `redirect_to @blood_request` know the URL? | Polymorphic URL: model name → `blood_request_url` → `to_param` → `/blood_requests/7` |
| What happens for an id that does not exist? | `find` raises `RecordNotFound`, Rails shows 404 |
| Why is `contact_phone` not shown on the request page? | UI rule: phones appear only in a request's responses list, to its creator. It is stored but not displayed; donors click "I can help" and the requester calls them using E's list |

Your 5-line explanation (template from [MVC_GUIDE.md](../MVC_GUIDE.md#explaining-your-module-at-the-demo)):

1. "When you open **`/blood_requests/new`**, the router sends it to **`BloodRequestsController#new`**, which gives the form an empty request; submitting goes to **`create`**."
2. "`create` builds the request **for the logged-in user** with `Current.user.blood_requests.new(blood_request_params)` and calls `save`."
3. "The model makes sure **every field except note is filled, blood group and city come from the fixed lists, and units is a whole number of at least 1**."
4. "The view **`show.html.erb`** shows **the blood group, units, patient, hospital, city, date and note, but not the contact phone**, because **phones appear only in the responses list, to the request's creator**."
5. "If something is wrong, like **units left blank**, **`save` returns false and the form comes back with the errors and my typed values, using a 422 status so Turbo shows it**."

## Out of scope

Say no if the AI suggests any of these:

- Edit, close or delete actions for requests, or an `edit.html.erb` (PRD: out of scope).
- Changing `config/routes.rb`, adding migrations or columns (for example a `status` column).
- Blood group compatibility matching (O- gives to all), notifications, maps.
- Gems such as Devise, Pundit, Simple Form or a date-picker library.
- Moving flash display into the layout yourself (it is a mentor's file).
- Showing `contact_phone` on the request page, or adding reveal rules for it; phones appear only in Module E's creator-only responses list.
- Tailwind classes, inline styles, new CSS or a wrapper `div` for width; use only the UI_DESIGN.md component classes.
- The responses list, "I can help" button or matching donors query: those are E's and D's; you only leave the spot.
