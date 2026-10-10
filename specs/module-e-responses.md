# Module E: Responses — tech spec

Oct 10, 2026 · Vishwajeetsingh Desurkar

You build the step that connects donors and requesters: a donor clicks "I can help" on a blood request, and only the person who posted that request sees who responded, with name and phone.

See also: [ATTENDEE_TASKS.md](../ATTENDEE_TASKS.md#module-e-responses) for your task list, [MVC_GUIDE.md](../MVC_GUIDE.md) for how models, views and controllers fit together, and [DB_SCHEMA.md](../DB_SCHEMA.md#responses-module-e) for the `responses` table, [UI_DESIGN.md](../UI_DESIGN.md) for the page layout and the component classes your views use.

## What you are building

Two small sections on the request page (`/blood_requests/:id`, built by Module C), between Module C's request details and Module D's matching donors. This is [screen 7 in UI_DESIGN.md](../UI_DESIGN.md#7-request-page-module-c-with-d-and-e):

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

What each viewer sees (copied from UI_DESIGN.md; your two columns are the first two):

| Viewer | "I can help" button | Responses list | Matching donors |
| --- | --- | --- | --- |
| The request's creator | Hidden | Shown, with phones | Shown |
| A user who has not responded | Shown | Hidden | Shown |
| A user who has responded | Replaced by "You offered to help" | Hidden | Shown |

With no responses yet, the creator sees "No one has responded yet." in the responses section.

Your views use only the component classes from [UI_DESIGN.md](../UI_DESIGN.md#components): `btn btn-primary` for the button, `meta` for "You offered to help", `card-list` and `card` for the responses, `empty-state` for the empty list. No Tailwind, no inline styles, no new CSS. The flash message is printed by the mentor's layout (`.flash.flash-notice` / `.flash.flash-alert`), not by you.

Clicking the button saves a row in the `responses` table and brings the donor back to the same page with the flash message "Thank you! The requester can now see your contact."

This is step 5 of the demo journey in [ATTENDEE_TASKS.md](../ATTENDEE_TASKS.md#finish): the donor finds a request (Module D), clicks "I can help" (you), and the requester switches back and sees the donor's contact (you). Without your module the app has donors and requests that never meet.

You are three layers deep in this module: a **model** with rules (E1), a **controller** action plus a button **view** (E2), and a privacy-aware list **view** (E3).

## Done when

From [ATTENDEE_TASKS.md](../ATTENDEE_TASKS.md#module-e-responses) and [TASKS.md](../TASKS.md#e-responses):

- [ ] **E1.** In `bin/rails console` a response can be created; a duplicate (same donor, same request) is invalid; a response by the request's owner is invalid.
- [ ] **E2.** A donor can click "I can help" once and sees a confirmation. After that the button is gone, and a second POST is refused with a message.
- [ ] **E3.** With no responses, the owner sees "Responses (0)" and "No one has responded yet."
- [ ] Both partials are rendered on Module C's request page (after Module C merges), in the order of screen 7: button, then responses list, then Module D's matching donors.
- [ ] Each row of the "What each viewer sees" table holds:
  - [ ] **The request's creator:** no "I can help" button; the responses list is shown, with each responder's name and phone, as cards.
  - [ ] **A user who has not responded:** the red "I can help" button (`btn btn-primary`) is shown; no responses list, and no phone appears in that user's page source.
  - [ ] **A user who has responded:** the button is replaced by "You offered to help" (muted `meta` text); still no responses list and no phones in the page source.
- [ ] Your partials use only UI_DESIGN.md component classes: no Tailwind, no inline styles, no `<h1>` (the request page already has one).
- [ ] **E4.** You have explained the model and the "only the creator sees it" rule to a mentor, and the mentor signed off.

## Concepts you will use

| Concept | What it is in one line | Where you use it |
| --- | --- | --- |
| `belongs_to` with `class_name:` | An association whose name differs from the class it points to | `belongs_to :donor, class_name: "User"` in `Response` |
| `has_many` with `foreign_key:` | An association whose column is not the default `<model>_id` | `User has_many :responses, foreign_key: :donor_id` (mentor) |
| Uniqueness validation with `scope:` | "This value must be unique *within* rows sharing that other value" | One response per donor per request |
| Custom validation | Your own method that adds an error when a rule fails | `donor_is_not_requester` |
| Unique database index | The database itself refuses a duplicate row | `(blood_request_id, donor_id)` index, already created at 0:00 (mentor explains the race and `RecordNotUnique`; not needed for E4) |
| Nested routes | A URL that contains its parent's id | `POST /blood_requests/5/responses` gives `params[:blood_request_id]` |
| `before_action` | Run a method before an action | Load `@blood_request` in `ResponsesController` |
| `button_to` and CSRF token | A one-button form that sends POST with a security token | The "I can help" button |
| Redirect and flash | Send the browser to another URL with a one-time message | After saving (or failing to save) a response |
| Partials with locals | Reusable view pieces that get data passed in | `responses/_button`, `responses/_list` |
| Safe navigation `&.` | Call a method only if the object is not `nil` | `donor.donor_profile&.phone` |
| `includes` | Load related rows in a few queries instead of one per row (N+1) | `includes(donor: :donor_profile)` (mentor explains; not needed for E4) |
| Conditional rendering | `<% if %>` in a view decides what HTML exists at all | Owner-only responses list |
| `rescue_from` | Handle one kind of error for every action in a controller | Optional friendly message for the rare race (mentor explains; not needed for E4) |

### `class_name: "User"` and `foreign_key: :donor_id`

Rails guesses everything from names (see [naming conventions](../MVC_GUIDE.md#where-things-live-in-this-repo)). When you write `belongs_to :donor`, Rails guesses two things: the column is `donor_id` (correct) and the class is `Donor` (wrong, there is no `Donor` model). `class_name: "User"` fixes the second guess: "the donor is a User".

Why is the column `donor_id` and not `user_id`? A response involves **two** users: the donor who responds and the requester who owns the blood request. `user_id` would not say which one. `donor_id` names the role, and it gives readable code: `response.donor.name`. It points to `users`, not `donor_profiles`, because a donor is a person who logs in; the phone is reached through `response.donor.donor_profile.phone`.

The other side has the opposite problem. On `User`, `has_many :responses` makes Rails look for `responses.user_id`, which does not exist. `foreign_key: :donor_id` tells it which column to use. A mentor adds that line, since nobody owns `user.rb`.

### Two layers against duplicates

| Layer | Code | What it does | When it matters |
| --- | --- | --- | --- |
| Model validation | `validates :donor_id, uniqueness: { scope: :blood_request_id }` | Runs a `SELECT` before saving; if a row exists, `save` returns `false` with a friendly message | Almost always: the normal second click |
| Database index | `add_index :responses, [:blood_request_id, :donor_id], unique: true` (done at 0:00) | The database refuses the row and Rails raises `ActiveRecord::RecordNotUnique` | Two requests arriving at the same instant (double-click, two tabs): both pass the `SELECT` check, only the database can stop the second |

The validation gives a nice message; the index guarantees the rule. You need both. (The second layer, the race and `RecordNotUnique`: mentor explains; not needed for E4.)

### Nested routes and `params[:blood_request_id]`

Your route lives *inside* `blood_requests`, so the URL carries the request's id: `/blood_requests/5/responses`. Rails puts the `5` in `params[:blood_request_id]` (not `params[:id]`, which is reserved for the response's own id). That is how your controller knows *which* request the donor is helping, without any form fields.

### `button_to` and the CSRF token

A plain link (`link_to`) always sends `GET`, and `GET` must never change data: browsers prefetch links, and the back button repeats them. `button_to` instead builds a tiny form with one button that sends `POST`. That form also contains a hidden `authenticity_token` (CSRF token): a secret value Rails put in your page. Rails checks it on every `POST`, so another website cannot trick a logged-in donor's browser into "responding" without clicking your button.

### Privacy by not rendering

The responses list is wrapped in `<% if blood_request.user == Current.user %>`. For anyone else, the `if` is false and Rails never writes that HTML, so the phone numbers are not in the page at all, not hidden with CSS. This is enough here because your list is the **only** place responder data is shown: there is no responses index page, no JSON route. You can prove it with "View page source".

In fact, per [UI_DESIGN.md](../UI_DESIGN.md#principles) ("Never show a phone number on a list"), your creator-only list is the **only place any phone number appears in the whole app**. Module C's request page no longer shows the requester's `contact_phone`, and the donors and requests lists show no phones. So the owner check in your partial is the app's one privacy gate for phone numbers.

## Data you work with

**`responses`** (you write it):

| Column | Type | Null | Rule | Enforced by |
| --- | --- | --- | --- | --- |
| `id` | integer | no | primary key | DB |
| `blood_request_id` | integer | no | must point to an existing request | DB (`NOT NULL`, foreign key) and model (`belongs_to` requires it) |
| `donor_id` | integer | no | must point to an existing **user** | DB (`NOT NULL`, foreign key to `users`) and model (`belongs_to`) |
| `note` | text | yes | not used today | nothing |
| `created_at`, `updated_at` | datetime | no | set by Rails | Rails |

| Rule | Model | Database |
| --- | --- | --- |
| One response per donor per request | `validates :donor_id, uniqueness: ...` (friendly message) | unique index on `(blood_request_id, donor_id)` (safety net) |
| A donor cannot respond to their own request | `validate :donor_is_not_requester` | **not enforced**: model only |

**You read** (never write): `blood_requests.user_id` (who owns the request), `users.name` (responder's name), `donor_profiles.phone` (responder's phone, may be missing).

## URLs and routes

Mentors wrote these. You never edit `config/routes.rb`.

| Verb | Path | Controller#action | Path helper | What it does |
| --- | --- | --- | --- | --- |
| POST | `/blood_requests/:blood_request_id/responses` | `responses#create` | `blood_request_responses_path(blood_request)` | Saves a response for the logged-in user, then redirects |
| GET | `/blood_requests/:id` | `blood_requests#show` (Module C) | `blood_request_path(blood_request)` or just `blood_request` | The page your partials live on, and where you redirect to |

Check with `bin/rails routes -g responses`:

```
                 Prefix Verb URI Pattern                                         Controller#Action
blood_request_responses POST /blood_requests/:blood_request_id/responses(.:format) responses#create
```

## Files you own

| File | What goes in it |
| --- | --- |
| `app/models/response.rb` | Associations and validations (E1) |
| `app/controllers/responses_controller.rb` | `create` action (E2); mentors created it with an empty action |
| `app/views/responses/_button.html.erb` | "I can help" button or "You offered to help" (E2) |
| `app/views/responses/_list.html.erb` | Owner-only responses list (E3) |

Plus, after Module C merges: **two lines** in the marked spot of `app/views/blood_requests/show.html.erb`.

**Do not touch:** `config/routes.rb`, `app/models/user.rb` (mentor), `app/models/blood_request.rb` (Module C; ask for `has_many :responses` if missing), the rest of `show.html.erb`, `app/views/layouts/`, `db/migrate/`, `db/schema.rb`. No new migrations, no new gems.

Your branch: `module-e-responses`.

## Build steps

Suggested timing: E1 0:20 - 0:45, E2 0:45 - 1:10, E3 1:10 - 1:30.

### E1. Response model rules (with a mentor)

**Goal:** the model knows its two parents and refuses duplicates and self-responses.

The generator already wrote `belongs_to :blood_request` and `belongs_to :donor` in this file. Add `class_name: "User"` to the second line; until you do, `Response.new(...).valid?` raises that error (`Missing model class Donor for the Response#donor association`).

```ruby
# app/models/response.rb
class Response < ApplicationRecord
  belongs_to :blood_request
  belongs_to :donor, class_name: "User"

  validates :donor_id, uniqueness: { scope: :blood_request_id,
                                     message: "has already responded to this request" }
  validate :donor_is_not_requester

  private

  def donor_is_not_requester
    return if blood_request.nil? || donor_id.nil?

    if donor_id == blood_request.user_id
      errors.add(:base, "You cannot respond to your own request")
    end
  end
end
```

**What this does:**

- `belongs_to :blood_request` gives `response.blood_request` and makes it required ("Blood request must exist" if missing).
- `belongs_to :donor, class_name: "User"` gives `response.donor`, a `User`, read from the `donor_id` column. See [above](#class_name-user-and-foreign_key-donor_id).
- `validates :donor_id, uniqueness: { scope: :blood_request_id }` means "no other row may have this same `donor_id` **and** this same `blood_request_id`". The same donor may still respond to other requests. The error reads "Donor has already responded to this request".
- `validate` (singular, no `s`) runs your own method. `validates` (with `s`) is for built-in rules.
- `donor_is_not_requester` compares the donor with the request's owner. The `return if ... nil?` guard avoids a crash when a parent is missing (`belongs_to` already reports that). `errors.add(:base, ...)` adds a message not tied to one field, so the full message is exactly your text.
- `private` keeps the helper method out of the public interface.

Also check, with Module C's owner, that `app/models/blood_request.rb` has `has_many :responses, dependent: :destroy`, and with a mentor that `user.rb` has `has_many :responses, foreign_key: :donor_id, dependent: :destroy`.

**Check it works** (`bin/rails console`):

```ruby
asha  = User.create!(name: "Asha",  email_address: "asha@example.com",  password: "password123")
meera = User.create!(name: "Meera", email_address: "meera@example.com", password: "password123")
req = BloodRequest.create!(user: asha, patient_name: "Test Patient", blood_group: "O+",
                           units_needed: 2, hospital: "City Hospital", city: "Pune",
                           needed_by: Date.tomorrow, contact_phone: "9000000001")

r1 = Response.create(blood_request: req, donor: meera)
r1.persisted?                 # => true
r1.donor.name                 # => "Meera"   (class_name works)
meera.responses.count         # => 1         (foreign_key works)

r2 = Response.new(blood_request: req, donor: meera)
r2.valid?                     # => false
r2.errors.full_messages       # => ["Donor has already responded to this request"]

r3 = Response.new(blood_request: req, donor: asha)
r3.valid?                     # => false
r3.errors.full_messages       # => ["You cannot respond to your own request"]

blank = Response.new
blank.valid?                  # => false
blank.errors.full_messages    # => ["Blood request must exist", "Donor must exist"]

# The safety net: skip validations and let the database decide
Response.new(blood_request: req, donor: meera).save(validate: false)
# => raises ActiveRecord::RecordNotUnique
```

If `asha` already exists from an earlier try, use `User.find_by(email_address: "asha@example.com")` instead of `create!`.

**Suggested AI prompt:**

> I'm in a Rails 8.1 app. In the **model** `app/models/response.rb`, the `responses` table has `blood_request_id`, `donor_id` (a foreign key to `users`, not `donors`) and `note`. Add: `belongs_to :blood_request`, `belongs_to :donor` pointing to the User class, a uniqueness validation so a donor can respond to a request only once with the message "has already responded to this request", and a custom validation `donor_is_not_requester` that adds an error when the donor is the request's owner (`blood_request.user_id`). Do not add gems or migrations. Then explain each line, and explain why `class_name` is needed.

### E2. "I can help" button

**Goal:** a donor clicks one button, a response is saved, the donor is told it worked.

```ruby
# app/controllers/responses_controller.rb
class ResponsesController < ApplicationController
  before_action :set_blood_request

  def create
    @donor_response = @blood_request.responses.new(donor: Current.user)

    if @donor_response.save
      redirect_to @blood_request, notice: "Thank you! The requester can now see your contact."
    else
      redirect_to @blood_request, alert: @donor_response.errors.full_messages.to_sentence
    end
  end

  private

  def set_blood_request
    @blood_request = BloodRequest.find(params[:blood_request_id])
  end
end
```

```erb
<%# app/views/responses/_button.html.erb %>
<% if blood_request.user != Current.user %>
  <% if blood_request.responses.exists?(donor: Current.user) %>
    <p class="meta">You offered to help</p>
  <% else %>
    <%= button_to "I can help", blood_request_responses_path(blood_request), class: "btn btn-primary" %>
  <% end %>
<% end %>
```

**What this does:**

- `before_action :set_blood_request` runs `set_blood_request` before `create`. It reads the request id from the nested URL (`params[:blood_request_id]`) and loads the request. A wrong id raises `ActiveRecord::RecordNotFound` (a 404 page in production; in development you see Rails' error page).
- `@blood_request.responses.new(donor: Current.user)` builds a response with `blood_request_id` already filled in, and the donor set to whoever is logged in. Nothing comes from a form, so there is **no `params.expect`**: there are no user-typed fields, and the donor must never come from `params`, or anyone could respond as someone else.
- `@donor_response`, not `@response` or `response`: controllers already have a method called `response` (the HTTP response Rails sends back). A local variable named `response` hides it, and `@response` is used by Rails tests. A distinct name avoids both.
- `save` runs your E1 validations. On success: `redirect_to @blood_request` sends the browser to `/blood_requests/5` with a green `notice`.
- On failure, also a redirect, with an `alert` like "Donor has already responded to this request". **Why redirect and not `render`?** The usual "re-render the form" ([MVC_GUIDE](../MVC_GUIDE.md#the-controller)) does not fit: you have no form page of your own, the button lives on Module C's page, and rendering `blood_requests/show` from your controller would need everything that page needs. Redirecting reuses Module C's `show` as-is, refreshing the page does not POST again, and Turbo expects a redirect after a form submission.
- `to_sentence` joins messages into one readable sentence.
- In the partial, `blood_request` (no `@`) is the local passed in by `render`. The outer `if` hides everything from the owner (screen 7: "Hidden" for the creator). `exists?(donor: Current.user)` asks the database "is there already a response from this user?" with a cheap `SELECT 1`.
- `<p class="meta">You offered to help</p>` takes the button's place for a user who already responded. `meta` is UI_DESIGN.md's muted secondary-text class.
- `button_to` outputs a `<form method="post" action="/blood_requests/5/responses">` with a hidden `authenticity_token` and one `<button>`. POST is `button_to`'s default, so no `method:` is needed. `class: "btn btn-primary"` goes on the `<button>` and makes it the page's red main action, as defined in UI_DESIGN.md. Do not add other classes or a `style=`.
- No `<h1>` or `<h2>` here: the request page already has its `<h1>`, and a single button needs no heading.

The button is only convenience. The real protection is the model: even if someone sends the POST by hand, E1's validations refuse it.

**Check it works** (after Module C's page is on main and your two lines are added, see [Working with other modules](#working-with-other-modules)):

1. Log in as Meera, open Asha's request: you see the red "I can help" button.
2. Click it: same page, green flash "Thank you! The requester can now see your contact.", button replaced by the muted line "You offered to help".
3. In the console: `Response.last.donor.name  # => "Meera"`.
4. Log in as Asha, open her own request: no button.

The flash only shows if the layout prints `notice` and `alert` (as `.flash.flash-notice` and `.flash.flash-alert`). If your message does not appear, ask a mentor (the layout is theirs).

**Suggested AI prompt:**

> Rails 8.1 app. The route is `resources :blood_requests do resources :responses, only: [:create] end`. In the **controller** `app/controllers/responses_controller.rb`, write `create`: a `before_action` loads `@blood_request` from `params[:blood_request_id]`, then build `@donor_response = @blood_request.responses.new(donor: Current.user)`. On save, `redirect_to @blood_request` with notice "Thank you! The requester can now see your contact."; otherwise redirect to the same page with `alert:` set to the error messages joined by `to_sentence`. No strong params, because there are no form fields. Then write the **partial** `app/views/responses/_button.html.erb` using a local `blood_request` (not an instance variable): show nothing to the request's owner, `<p class="meta">You offered to help</p>` if `Current.user` already responded, otherwise a `button_to "I can help"` with `class: "btn btn-primary"` that POSTs to `blood_request_responses_path(blood_request)`. Use only the component classes from UI_DESIGN.md (`page-title`, `card`, `card-list`, `btn`, `btn btn-primary`, `form-field`, `form-errors`, `filter-bar`, `badge`, `meta`, `empty-state`); no Tailwind, no inline styles. No `<h1>` in the partial. Explain what HTML `button_to` produces and why it includes an authenticity token.

### E3. Responses list (with a mentor; mentor takes over if behind)

**Goal:** the requester, and only the requester, sees who can help and how to reach them.

```erb
<%# app/views/responses/_list.html.erb %>
<% if blood_request.user == Current.user %>
  <% responses = blood_request.responses.includes(donor: :donor_profile).order(:created_at).to_a %>

  <h2>Responses (<%= responses.size %>)</h2>

  <% if responses.any? %>
    <div class="card-list">
      <% responses.each do |donor_response| %>
        <div class="card">
          <p><%= donor_response.donor.name %></p>
          <p class="meta"><%= donor_response.donor.donor_profile&.phone || "No phone on profile" %></p>
        </div>
      <% end %>
    </div>
  <% else %>
    <div class="empty-state">
      <p>No one has responded yet.</p>
    </div>
  <% end %>
<% end %>
```

**What this does:**

- `<% if blood_request.user == Current.user %>`: two `=` signs compare. For anyone but the owner, nothing inside is sent to the browser.
- `includes(donor: :donor_profile)`: without it, Rails runs one query for the responses, then one for each donor, then one for each profile ("N+1 queries"). With it, a fixed handful of queries (responses, users, profiles), however many responders. `.to_a` loads the list once, so `size`, `any?` and the loop all reuse it without asking the database again.
- `order(:created_at)`: first responder first.
- `responses` (plural) is fine as a local name; only the singular `response` clashes with the controller's `response` method, which views can also see. That is why the block variable is `|donor_response|`, not `|response|`.
- `<h2>Responses (<%= responses.size %>)</h2>`: the section heading from screen 7, with the count. It is an `<h2>` because the request page already has its one `<h1>` (UI_DESIGN.md: one `<h1>` per page).
- `card-list` stacks the cards with a gap; each `card` is one response, as UI_DESIGN.md says ("one donor, one request, one response"). The name is on the first line, the phone on a muted `meta` line.
- `donor_profile&.phone`: a user can respond without having filled in a donor profile (Module A). Then `donor_profile` is `nil`, and `nil.phone` would crash the page. `&.` means "call `.phone` only if not `nil`, otherwise give `nil`", and `|| "No phone on profile"` shows a fallback.
- The `empty-state` box keeps the page from looking broken before anyone responds. UI_DESIGN.md's empty state usually has one link to the next action; here the creator's next action is simply to wait, so a message is enough.
- Only UI_DESIGN.md classes, no Tailwind, no `style=`. The page's look comes from the mentor's stylesheet.

A note on the [MVC_GUIDE rule](../MVC_GUIDE.md#the-view) "no queries in views": normally the controller prepares data. Here the page's controller action is Module C's `show`, and partials get data through locals, so a short query on the local `blood_request` is the agreed trade-off. Keep it to this one line.

**Check it works:**

1. As Asha, open her request after Meera responded: "Responses (1)" and a card with Meera's name and phone.
2. As Meera (or any third user) on the same page: no list. Right-click, View page source, search for Meera's phone number: not found.
3. A request with no responses, opened by its owner: "Responses (0)" and "No one has responded yet."

**Suggested AI prompt:**

> In the Rails **partial** `app/views/responses/_list.html.erb`, using a local `blood_request`, show the responses only when `blood_request.user == Current.user`. Start with `<h2>Responses (<%= responses.size %>)</h2>` (no `<h1>`; the page already has one), then a `<div class="card-list">` with one `<div class="card">` per response showing `donor.name` and, in a `<p class="meta">`, `donor.donor_profile&.phone` with "No phone on profile" as a fallback. When empty, show `<div class="empty-state"><p>No one has responded yet.</p></div>`. Load with `includes(donor: :donor_profile)`. Name the block variable `donor_response`. Use only the component classes from UI_DESIGN.md (`page-title`, `card`, `card-list`, `btn`, `btn btn-primary`, `form-field`, `form-errors`, `filter-bar`, `badge`, `meta`, `empty-state`); no Tailwind, no inline styles. Explain why the `if` keeps phone numbers out of the HTML, what `&.` does, and what `includes` prevents.

## Privacy and edge cases

| Situation | What happens | Handled by |
| --- | --- | --- |
| Donor clicks twice (second normal request) | Second save fails, redirect with "Donor has already responded to this request" | Uniqueness validation |
| Two requests at the same instant (double-click, two tabs) | Both pass the validation's `SELECT`, the database rejects the second | Unique index; raises `ActiveRecord::RecordNotUnique` (see below) |
| Owner sends the POST by hand (curl, dev tools) | Save fails: "You cannot respond to your own request" | `donor_is_not_requester`; the hidden button is only convenience |
| Someone tries to respond as another user | Impossible: the donor is always `Current.user`, never taken from `params` | Controller |
| Request id does not exist | `ActiveRecord::RecordNotFound`, 404 page | `BloodRequest.find` |
| Not logged in | Sent to the login page | The app's login check in `ApplicationController` (mentors) |
| Responder has no donor profile | Shows "No phone on profile" instead of crashing | `&.` and `||` |
| Non-owner looks for phones in the page | Not in the HTML at all | `if` around the list |
| Phones on list pages | Never: your data only appears on the request page, only for its owner | Your partial is the only place it is rendered |
| Phones anywhere else in the app | Never: per UI_DESIGN.md, your creator-only list is the only place any phone number appears (Module C no longer shows the requester's `contact_phone`) | Your owner check |

Optional, with a mentor, if time allows: turn the rare race into a friendly message instead of an error page.

```ruby
# app/controllers/responses_controller.rb (inside the class)
rescue_from ActiveRecord::RecordNotUnique do
  redirect_to @blood_request, alert: "You have already offered to help with this request."
end
```

## Testing checklist

Use two browsers, or one normal window and one private window, so two users are logged in at once. Log in as two seeded users, for example requester1@example.com in window A and donor1@example.com in window B (password "password" for both). Run `bin/rails db:seed` first if seeds are merged; otherwise create users in the console as in E1.

| # | Window | Step | Expected |
| --- | --- | --- | --- |
| 1 | A | Log in as the requester, post a request (Module C) | **Creator row:** request page shows, no "I can help", "Responses (0)" and "No one has responded yet." |
| 2 | B | Log in as a donor who has a profile, open the same request | **Not-responded row:** red "I can help" button, no responses list |
| 3 | B | View page source | No phone numbers anywhere |
| 4 | B | Click "I can help" | Same page, green notice "Thank you! The requester can now see your contact." |
| 5 | B | Look at the button's spot | **Responded row:** button replaced by the muted line "You offered to help", still no responses list |
| 6 | B | Refresh the page | No second response created; still "You offered to help" |
| 7 | A | Refresh the request page | **Creator row:** still no button; "Responses (1)" with one card: the donor's name and phone |
| 8 | A and B | Scroll down | Order matches screen 7: button (or "You offered to help"), then responses (creator only), then Module D's matching donors |
| 9 | A and B | View page source | No Tailwind classes, no `style=`, only one `<h1>` on the page |
| 10 | B | Open a different request | "I can help" is back (one response per request, not per donor) |
| 11 | Console | `Response.new(blood_request: BloodRequest.last, donor: BloodRequest.last.user).valid?` | `false` |
| 12 | Console | `Response.count` before and after step 6 | Unchanged |

## Working with other modules

**You depend on:**

| What | From | When |
| --- | --- | --- |
| `responses` table with the unique index | Mentor (W1) | 0:00 - 0:20 |
| `User has_many :responses, foreign_key: :donor_id` | Mentor | Before 0:20 |
| `BloodRequest has_many :responses` | Module C (C1) | Ask early; until it is on your branch, test with `Response.new(blood_request: ...)` as in E1, not `req.responses` |
| Request page with the marked spot | Module C (C3) | Merged first, around 1:30 |
| `donor_profile.phone` | Module A, via the mentor's `has_one :donor_profile` | Seeds or console data |
| Flash messages in the layout | Mentor (P3) | Before the day |
| Seed data | Mentor (P5) | After merging |

**Who depends on you:** the demo's last step, and the requester's whole reason to use the app.

**Before Module C merges:** build E1 and test it in the console; write both partials and the controller. You cannot click the button yet, and that is fine.

**After Module C merges:** pull main into your branch (`git pull origin main`), then in the marked spot of `app/views/blood_requests/show.html.erb` turn your two commented lines into real ones. Tell Module C's owner before you do.

Module C leaves this shared spot. Its order matches screen 7: your button first, then your list, then Module D's matching donors last.

```erb
<%# ===== Modules D and E: add your render lines below. Do not edit above this line. ===== %>
<%# Module E: render "responses/button", blood_request: @blood_request %>
<%# Module E: render "responses/list", blood_request: @blood_request %>
<%# Module D: render "blood_requests/matching_donors", blood_request: @blood_request %>
<%# ===== end of shared spot ===== %>
```

Change only your two `Module E` lines, in place, so they become:

```erb
<%= render "responses/button", blood_request: @blood_request %>
<%= render "responses/list",   blood_request: @blood_request %>
```

Leave Module D's line where it is (after yours), whether or not D has turned it on yet. Do not move lines around: keeping the order is what makes the page look like screen 7.

Note the leading `_` is dropped in `render`, and the folder is included because the partial lives in `responses/`, not `blood_requests/`.

**Merge order:** C, A, B, D, then **E last**, so your PR only adds lines on top of everyone's merged work.

## Common mistakes

| Symptom | Cause | Fix |
| --- | --- | --- |
| `Missing model class Donor for the Response#donor association` | `belongs_to :donor` without `class_name` | Add `class_name: "User"` |
| `no such column: responses.user_id` | `User has_many :responses` missing `foreign_key: :donor_id` | Ask a mentor to fix `user.rb` |
| `undefined method 'responses' for an instance of BloodRequest` | Module C's `has_many :responses` not on your branch | Ask Module C's owner; pull main |
| `No route matches [GET] "/blood_requests/5/responses"` | Used `link_to` instead of `button_to` | Use `button_to` (POST) |
| `ActionController::InvalidAuthenticityToken` | Hand-written `<form>` without the token | Use `button_to`, which adds it |
| Error page `ActiveRecord::RecordNotUnique` on a normal second click | Uniqueness validation missing or scope misspelled | Check E1 code; `scope: :blood_request_id` |
| Strange errors after naming a variable `response` | It hides the controller's `response` method | Rename to `@donor_response` / `donor_response` |
| Everyone sees the phone list | `=` instead of `==` in the `if` (assigns, always true), or the `if` is missing | `<% if blood_request.user == Current.user %>` |
| Owner still sees "I can help" | Comparing a user to an id (`blood_request.user_id == Current.user`) | Compare like with like: `user == Current.user` or `user_id == Current.user.id` |
| `undefined method 'phone' for nil` | Responder has no donor profile | `donor_profile&.phone || "No phone on profile"` |
| `undefined local variable or method 'blood_request'` | Rendered without the local, or `@blood_request` used inside the partial | `render "responses/list", blood_request: @blood_request`; use `blood_request` in the partial |
| `Missing partial responses/_button` | File named without `_`, or in the wrong folder | `app/views/responses/_button.html.erb` |
| Clicked, nothing visible changes, no message | Layout does not print `notice`/`alert` | Ask a mentor |
| Clicking does nothing; browser console shows 'Form responses must redirect to another location' | `render` used in `create` | Use `redirect_to` in both branches |

## Explain it (E4)

Questions a mentor will ask, and what a good answer covers:

1. **Why `class_name: "User"`?** Rails guesses the class from the association name, `donor` would mean `Donor`, which does not exist. Donors are users.
2. **Why is the column `donor_id` and not `user_id`?** A response involves two users (donor and requester); `donor_id` says which role. That is why `User` needs `foreign_key: :donor_id`.
3. **How do you stop a donor responding twice?** Uniqueness validation scoped to the request, so a second save fails with a friendly message.
4. **How do you stop the owner responding?** The button is hidden, but the real rule is the custom validation `donor_is_not_requester`, so a hand-made POST also fails.
5. **Why `button_to` and not `link_to`?** It changes data, so it must be POST; it includes the CSRF token.
6. **Where does the request id come from, and why no strong params?** From the nested URL, `params[:blood_request_id]`. No form fields; the donor is always `Current.user`, never from params.
7. **Why redirect on failure instead of render?** No form of your own; the button lives on Module C's page; refresh-safe; Turbo expects it.
8. **How is the phone kept private?** The list partial is wrapped in an owner check, so for other users the HTML is never generated. It is the only place any phone number appears in the app. Show it with View page source.
9. **What does `&.` do here?** Avoids crashing when a responder has no donor profile.

Your 5-line explanation, following the [MVC_GUIDE template](../MVC_GUIDE.md#explaining-your-module-at-the-demo):

1. "When you click 'I can help', the browser sends `POST /blood_requests/5/responses`, and the router sends it to `ResponsesController#create`."
2. "The action loads request 5 from `params[:blood_request_id]` and builds a response with `@blood_request.responses.new(donor: Current.user)`."
3. "The model makes sure a donor responds to a request only once and never to their own request; the database's unique index is a second safety net."
4. "The view `responses/_button` shows the button or 'You offered to help', and `responses/_list` shows each responder's name and phone, but only to the request's creator; other users' pages do not contain that HTML at all."
5. "If something is wrong, like a duplicate response, the save fails and you are redirected back to the request page with a message saying why."

## Out of scope

Do not build these, even if your AI tool suggests them:

- The `note` field on responses (the column exists; the button stays a single button)
- Withdrawing, editing or deleting a response
- Accepting or declining responders, or a response status
- Notifications of any kind (email, SMS, push)
- Live updates with Turbo Streams or Action Cable
- A responses index or show page, or JSON endpoints
- Showing response counts or responder names to anyone but the owner
- Requiring a donor profile before responding, or blood group compatibility checks
- Authorization gems (Pundit, CanCanCan) or any other new gem
- New routes or migrations (ask a mentor if you truly need one)
