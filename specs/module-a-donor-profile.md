# Module A: Donor profile — tech spec

Oct 10, 2026 · Vishwajeetsingh Desurkar

You build the form where a signed-in user becomes a donor by saving a blood group, city and phone, plus an edit page to change them and switch "available to donate" on or off.

See also: [ATTENDEE_TASKS.md](../ATTENDEE_TASKS.md) · [MVC_GUIDE.md](../MVC_GUIDE.md) · [DB_SCHEMA.md](../DB_SCHEMA.md)

## What you are building

A signed-in user opens **Become a donor** (`/donor_profile/new`), picks a blood group and a city from dropdowns, types a phone number and clicks **Save**. The profile is saved for that user, and the app takes them to the donors list, where they now appear.

| Screen | URL | What it shows |
| --- | --- | --- |
| New profile | `/donor_profile/new` | Blood group dropdown, city dropdown, phone field, Save button, error messages |
| Edit profile (A3, cut first) | `/donor_profile/edit` | The same form, filled in, plus an "Available to donate" checkbox |

Each user has at most **one** donor profile. That is why the URL has no id: "the donor profile" always means *your own* profile.

In the demo journey you are **step 1**: "Sign up and create a donor profile". Step 2 (Module B) finds that donor in the donors list, so your redirect lands right there.

## Done when

- [ ] **A1.** In `bin/rails console`, a profile with a missing phone, a blood group not in `BLOOD_GROUPS` or a city not in `CITIES` is rejected (`valid?` is `false`).
- [ ] **A1.** A second profile for the same user is rejected.
- [ ] **A2.** A new user can sign up, fill the form and see the profile saved (a "saved" message, and the row exists in the console).
- [ ] **A2.** Submitting the form with the phone left empty shows an error and keeps the other choices.
- [ ] **A2.** Opening `/donor_profile/new` when you already have a profile sends you to the edit page.
- [ ] **A3 (cut first).** Unticking "Available to donate" on the edit page and saving changes `available` to `false` in the database.
- [ ] **A4.** You have walked a mentor through your model, controller and view.

## Concepts you will use

| Concept | What it is in one line | Where you use it here |
| --- | --- | --- |
| Validations | Rules a model checks before saving | `validates` lines in `donor_profile.rb` |
| `belongs_to` / `has_one` | Associations that link a profile to exactly one user | `DonorProfile belongs_to :user`; `User has_one :donor_profile` (mentor adds) |
| `build_donor_profile` | Creates an unsaved profile already linked to the user | `create` action |
| Singular resource | A route for "the one thing you have", with no `:id` in the URL | `resource :donor_profile` in routes |
| `Current.user` | The logged-in user | Every action |
| Strong params (`params.expect`) | The list of form fields allowed into the model | `donor_profile_params` |
| `form_with` + form helpers | Builds an HTML form tied to a model | `_form.html.erb` |
| Partial with locals | A reusable view piece that gets its data passed in | `_form` shared by `new` and `edit` |
| `redirect_to` vs `render` | Go to another URL vs. show a view again | `create` and `update` |
| `before_action` | A method that runs before some actions | Loading the profile for `edit` and `update` |

**Validations.** The model is the "records room" from the [MVC guide](../MVC_GUIDE.md#the-model): it refuses to file a bad form. When a validation fails, `save` returns `false` and `errors.full_messages` tells you why. The controller does not check fields itself; it just asks "did it save?". Because of this, the console and the browser behave the same way.

**`has_one` and `build_donor_profile`.** `has_one :donor_profile` on `User` gives every user a `user.donor_profile` method (returns the profile or `nil`) and a `user.build_donor_profile(attrs)` method. `build_` makes a new, unsaved `DonorProfile` with `user_id` already set to that user. You never put `user_id` in the form, so nobody can create a profile for someone else.

**Singular resource.** `resources :blood_requests` (plural) gives URLs like `/blood_requests/5`, because there are many. `resource :donor_profile` (singular) gives `/donor_profile/edit`, with no id, because each user has only one. The controller never reads `params[:id]`; it always uses `Current.user.donor_profile`. That alone makes it impossible to open someone else's profile.

**Strong params.** `params.expect(donor_profile: [ :blood_group, :city, :phone, :available ])` says "the form must have a `donor_profile` section, and only these four fields get through". A sneaky extra field like `user_id` is dropped. See [The Controller](../MVC_GUIDE.md#the-controller).

**Form helpers.** `form_with model:` fills in values and errors from the object. `f.select` makes a dropdown, so blood group and city are never typed freely. See [Forms](../MVC_GUIDE.md#forms).

## Data you work with

Table `donor_profiles` (created by the mentor at 0:00; you do not create a migration).

| Column | Type | Rule | Enforced by |
| --- | --- | --- | --- |
| `user_id` | integer | required; one profile per user | DB: `null: false`, foreign key, **unique index**. Model: `belongs_to :user` (required by default) and `validates :user_id, uniqueness: true` |
| `blood_group` | string | required; one of `BLOOD_GROUPS` | DB: `null: false`. Model: `presence` + `inclusion` |
| `city` | string | required; one of `CITIES` | DB: `null: false`. Model: `presence` + `inclusion` |
| `phone` | string | required; never shown on list pages | DB: `null: false`. Model: `presence` |
| `available` | boolean | defaults to `true` | DB: `null: false, default: true`. No validation needed |

Also `id`, `created_at`, `updated_at` (automatic).

Why both the DB and the model? The **model** gives friendly error messages on the form ("Phone can't be blank"). The **database** is the last safety net: even if model code is wrong, it refuses a row with no phone or a second profile for the same user (as an exception, not a nice message). The DB does **not** check that `"Z+"` is a real blood group; only your `inclusion` validation does.

You also read `users.name` indirectly (Module B shows it), but you never change the `users` table.

## URLs and routes

Mentors already wrote `resource :donor_profile, only: [ :new, :create, :edit, :update ]`. Run `bin/rails routes -g donor_profile` to see them.

| Verb | Path | Controller#action | Path helper | What it does |
| --- | --- | --- | --- | --- |
| GET | `/donor_profile/new` | `donor_profiles#new` | `new_donor_profile_path` | Shows the empty form (or redirects to edit if you have a profile) |
| POST | `/donor_profile` | `donor_profiles#create` | `donor_profile_path` | Saves a new profile for `Current.user` |
| GET | `/donor_profile/edit` | `donor_profiles#edit` | `edit_donor_profile_path` | Shows the filled form with the available checkbox (A3) |
| PATCH | `/donor_profile` | `donor_profiles#update` | `donor_profile_path` | Saves changes (A3) |
| GET | `/donors` | `donors#index` (Module B) | `donors_path` | Where you redirect after saving |

Note: the controller is plural (`DonorProfilesController`) even though the route is singular. That is a Rails convention.

## Files you own

| File | What goes in it |
| --- | --- |
| `app/models/donor_profile.rb` | `belongs_to :user` and validations (A1) |
| `app/controllers/donor_profiles_controller.rb` | `new`, `create`, `edit`, `update`, `donor_profile_params` (mentors left empty actions) |
| `app/views/donor_profiles/new.html.erb` | Heading + renders the form |
| `app/views/donor_profiles/edit.html.erb` | Heading + renders the form (A3) |
| `app/views/donor_profiles/_form.html.erb` | The form itself, shared by both |

**Do not touch:** `config/routes.rb`, `app/models/user.rb` (a mentor adds `has_one :donor_profile`), `config/initializers/constants.rb`, `app/views/layouts/`, `db/` (no migrations, never edit `schema.rb`), and any other module's controller or views.

## Build steps

### A1. Validations

**Goal:** the model refuses incomplete or invalid profiles and a second profile for the same user.

```ruby
# app/models/donor_profile.rb
class DonorProfile < ApplicationRecord
  belongs_to :user   # already written by the mentor's generator; keep it

  validates :blood_group, :city, :phone, presence: true
  validates :blood_group, inclusion: { in: BLOOD_GROUPS }
  validates :city, inclusion: { in: CITIES }
  validates :user_id, uniqueness: true
end
```

**What this does**

- `belongs_to :user` was already written by the mentor's `rails g model DonorProfile user:references`; keep it. It links each profile to a user and gives you `profile.user`. In Rails 8 it is also a rule: a profile without a user is invalid ("User must exist").
- `presence: true` means the value cannot be `nil` or an empty string.
- `inclusion: { in: BLOOD_GROUPS }` means the value must be exactly one item in the list. `"o+"` or `"O positive"` fails.
- `uniqueness: true` on `user_id` runs a quick query: "does another profile already have this user_id?" The unique index in the DB backs it up.

**Check it works**

```ruby
# bin/rails console
u = User.first
p = DonorProfile.new(user: u, blood_group: "Z+", city: "Paris", phone: "")
p.valid?                  # => false
p.errors.full_messages    # => ["Phone can't be blank", "Blood group is not included in the list", "City is not included in the list"]

p = DonorProfile.new(user: u, blood_group: "O+", city: "Pune", phone: "9800000001")
p.save                    # => true
DonorProfile.new(user: u, blood_group: "A+", city: "Pune", phone: "9800000002").valid?  # => false ("User has already been taken")
p.destroy                 # clean up
```

**AI prompt**

> In my Rails 8.1 app, edit only the model `app/models/donor_profile.rb`. The `donor_profiles` table has user_id, blood_group, city, phone, available. Keep the generated `belongs_to :user` and add validations: blood_group, city and phone required; blood_group must be in the global constant `BLOOD_GROUPS`; city must be in `CITIES`; one profile per user (user_id unique). Do not create a migration. Then explain each line.

### A2. New profile form

**Goal:** a logged-in user fills a form and a profile is saved for them.

```ruby
# app/controllers/donor_profiles_controller.rb
class DonorProfilesController < ApplicationController
  def new
    if Current.user.donor_profile
      redirect_to edit_donor_profile_path
    else
      @donor_profile = DonorProfile.new
    end
  end

  def create
    if Current.user.donor_profile
      redirect_to edit_donor_profile_path, alert: "You already have a donor profile."
      return
    end

    @donor_profile = Current.user.build_donor_profile(donor_profile_params)

    if @donor_profile.save
      redirect_to donors_path, notice: "Your donor profile is saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # edit and update: see A3

  private

  def donor_profile_params
    params.expect(donor_profile: [ :blood_group, :city, :phone, :available ])
  end
end
```

```erb
<%# app/views/donor_profiles/new.html.erb %>
<h1>Become a donor</h1>
<%= render "form", donor_profile: @donor_profile %>
```

```erb
<%# app/views/donor_profiles/_form.html.erb %>
<%= form_with model: donor_profile, url: donor_profile_path do |f| %>
  <% if donor_profile.errors.any? %>
    <ul class="errors">
      <% donor_profile.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
    </ul>
  <% end %>

  <div>
    <%= f.label :blood_group %>
    <%= f.select :blood_group, BLOOD_GROUPS, include_blank: "Choose your blood group" %>
  </div>

  <div>
    <%= f.label :city %>
    <%= f.select :city, CITIES, include_blank: "Choose your city" %>
  </div>

  <div>
    <%= f.label :phone %>
    <%= f.telephone_field :phone, placeholder: "Made-up number, e.g. 9800000001" %>
  </div>

  <% if donor_profile.persisted? %>
    <div>
      <%= f.check_box :available %>
      <%= f.label :available, "Available to donate" %>
    </div>
  <% end %>

  <%= f.submit "Save" %>
<% end %>
```

**What this does**

- `new`: if you already have a profile, there is nothing to create, so go to edit. Otherwise give the form an empty `DonorProfile`. (If A3 is cut, change `edit_donor_profile_path` to `donors_path` in both `new` and `create`.)
- `create`, the guard: checks again for an existing profile. This matters: on a `has_one`, `build_donor_profile` **replaces** the old profile, and with `dependent: :destroy` the old one is deleted. The guard stops that.
- `Current.user.build_donor_profile(...)`: makes an unsaved profile with `user_id` set to the logged-in user and fills in the allowed form fields.
- `if @donor_profile.save`: runs your A1 validations. Success: **redirect** (so refreshing does not resubmit). Failure: **render** `new` again with status 422; `@donor_profile` still holds the typed values and the errors.
- `donor_profile_params`: strong params. Only these four fields reach the model.
- `new.html.erb` passes the profile into the partial as a **local** (`donor_profile:`), so `_form` does not depend on an `@` variable.
- `form_with model: donor_profile, url: donor_profile_path`: the `url:` is required because the route is singular. Without it Rails guesses a plural URL (`/donor_profiles`) that does not exist. On the edit page Rails would guess `/donor_profile.5`, which is also wrong, so `url:` is needed on both pages. Rails still picks the verb: POST for a new record, PATCH for a saved one.
- `f.select ..., include_blank:` adds an empty first option, so the user must choose and a blank choice triggers your validation.
- `f.telephone_field` is a text input with `type="tel"`, so phones show a number keypad.
- The checkbox only shows when the profile is already saved (`persisted?`), which means only on the edit page.

**Check it works**

1. Sign up as a new user, then go to `/donor_profile/new`. You see two dropdowns and a phone field.
2. Leave the phone empty and click Save. You see "Phone can't be blank" and your dropdown choices are still selected.
3. Fill in the phone and click Save. You land on `/donors` with "Your donor profile is saved." (until Module B merges, see [Working with other modules](#working-with-other-modules)).
4. In the console: `User.last.donor_profile` shows your row with `available: true`.
5. Visit `/donor_profile/new` again. You are sent to `/donor_profile/edit`.

**AI prompt**

> Rails 8.1 app with the Rails 8 authentication generator (`Current.user` is the logged-in user). Routes already exist: `resource :donor_profile, only: [:new, :create, :edit, :update]` (singular). User `has_one :donor_profile`. In `app/controllers/donor_profiles_controller.rb` fill in `new` and `create`: `new` redirects to `edit_donor_profile_path` if the user already has a profile; `create` also refuses if one exists, then uses `Current.user.build_donor_profile(donor_profile_params)`, redirects to `donors_path` with notice "Your donor profile is saved." on success and does `render :new, status: :unprocessable_entity` on failure. Use `params.expect(donor_profile: [:blood_group, :city, :phone, :available])`. Then write `new.html.erb` and a `_form.html.erb` partial that receives `donor_profile` as a local, uses `form_with model: donor_profile, url: donor_profile_path`, `f.select` with `BLOOD_GROUPS` and `CITIES` and `include_blank`, `f.telephone_field :phone`, and lists error messages. No new gems. Explain each block.

### A3. Edit profile with the available toggle (cut first if behind)

**Goal:** a donor can change their details and mark themselves unavailable.

```ruby
# app/controllers/donor_profiles_controller.rb (add to the class)
before_action :set_donor_profile, only: [ :edit, :update ]

def edit
end

def update
  if @donor_profile.update(donor_profile_params)
    redirect_to edit_donor_profile_path, notice: "Your donor profile is updated."
  else
    render :edit, status: :unprocessable_entity
  end
end

private

def set_donor_profile
  @donor_profile = Current.user.donor_profile
  redirect_to new_donor_profile_path, alert: "Create your donor profile first." unless @donor_profile
end
```

```erb
<%# app/views/donor_profiles/edit.html.erb %>
<h1>Your donor profile</h1>
<%= render "form", donor_profile: @donor_profile %>
```

Put `before_action` near the top of the class and `set_donor_profile` under `private`, next to `donor_profile_params`.

**What this does**

- `before_action :set_donor_profile, only: [ :edit, :update ]` runs `set_donor_profile` before those two actions, so you load the profile in one place.
- `set_donor_profile` always loads **your own** profile through `Current.user`, never by id. If you have none, it redirects to the new form; a redirect inside a `before_action` stops the action from running.
- `edit` is empty on purpose: `@donor_profile` is already set, and Rails renders `edit.html.erb` by itself.
- `update` works like `create`: `update` runs validations and saves; success redirects back to the edit page with a notice (not the donors list, because an unavailable donor disappears from that list, which is confusing), failure re-renders `edit` with errors.
- The checkbox: `f.check_box :available` sends `"1"` when ticked and a hidden `"0"` when unticked, and Rails turns those into `true`/`false`. That is why `:available` is in the strong params.

**Check it works**

1. As a user with a profile, open `/donor_profile/edit`. The form is filled in and "Available to donate" is ticked.
2. Untick it and click Save. You stay on `/donor_profile/edit` with "Your donor profile is updated." In the console, `User.last.donor_profile.available` is `false`.
3. Clear the phone and Save. The error shows and nothing changes in the database.
4. As a user with no profile, open `/donor_profile/edit`. You are sent to `/donor_profile/new`.

**AI prompt**

> In the same `DonorProfilesController` (Rails 8.1, singular `resource :donor_profile`), add `edit` and `update`. Use a `before_action` that loads `Current.user.donor_profile` and redirects to `new_donor_profile_path` if it is nil. `update` redirects to `edit_donor_profile_path` with notice "Your donor profile is updated." on success and renders `:edit` with `status: :unprocessable_entity` on failure. Add `edit.html.erb` that renders the existing `_form` partial with the local `donor_profile: @donor_profile`. The form already shows an `available` checkbox when the profile is persisted. Explain how the checkbox becomes true/false.

## Privacy and edge cases

| Situation | What happens | Why |
| --- | --- | --- |
| Not logged in | Sent to the login page | `Authentication` concern in `ApplicationController` (mentors); you add nothing |
| Already has a profile, opens `/donor_profile/new` | Redirected to edit | Guard in `new` |
| Already has a profile, posts the form anyway (old tab, double click) | Redirected to edit with an alert; old profile is kept | Guard in `create`; without it `build_donor_profile` would replace the old profile |
| Two saves race at the same moment | Second one fails at the database | Unique index on `user_id` |
| Missing blood group, city or phone | Form comes back with error messages | Presence validations, `render :new` |
| Blood group or city edited in the browser's dev tools to a fake value | Rejected | `inclusion` validations; the DB alone would accept it |
| Someone adds `user_id=1` to the form | Ignored | Not in `params.expect`; `user_id` comes from `build_donor_profile` |
| Someone tries to edit another user's profile | Not possible | No id in the URL; you always load `Current.user.donor_profile` |
| No profile, opens `/donor_profile/edit` | Redirected to new | `set_donor_profile` |
| Phone number | Saved, but never shown on any list page | Module B shows name, blood group and city only. Use made-up numbers. |

## Testing checklist

Manual click-through (do this after A2, and again after the merge with seed data):

- [ ] Logged out, open `/donor_profile/new` → login page.
- [ ] Sign up a new user, open `/donor_profile/new` → empty form with two dropdowns and a phone field.
- [ ] Submit with nothing chosen → errors for blood group, city and phone.
- [ ] Submit with phone empty only → "Phone can't be blank", dropdown choices kept.
- [ ] Submit a complete form → redirected to `/donors` with "Your donor profile is saved."; you appear in the list without a phone number.
- [ ] Open `/donor_profile/new` again → redirected to edit.
- [ ] (A3) Untick available, save → `available` is `false` in the console.
- [ ] (A3) Log in as a user with no profile, open `/donor_profile/edit` → redirected to new.

Optional model test (ask a mentor before adding; it is a new file outside your folders):

> Needs test setup by a mentor: this app was created without the test framework (`config/application.rb` has `rails/test_unit/railtie` commented out and there is no `test/` folder). Skip this if a mentor has not set it up.

```ruby
# test/models/donor_profile_test.rb
require "test_helper"

class DonorProfileTest < ActiveSupport::TestCase
  test "requires a phone and a real blood group" do
    profile = DonorProfile.new(user: users(:one), blood_group: "Z+", city: "Pune", phone: "")
    assert_not profile.valid?
    assert_includes profile.errors[:phone], "can't be blank"
    assert_includes profile.errors[:blood_group], "is not included in the list"
  end
end
```

Run it with `bin/rails test test/models/donor_profile_test.rb`. This test does not sign in; if you add a controller test that does, use `sign_in_as(user)` from the test helper made by the Rails 8.1 authentication generator.

If every test fails with "uninitialized constant Donor" or "Missing model class Donor", Module E's `class_name: "User"` is not merged yet; ask a mentor.

## Working with other modules

**You depend on (mentors, before the day or at 0:00):** login and `Current.user`, the routes, the empty `DonorProfilesController`, `BLOOD_GROUPS` and `CITIES`, the `donor_profiles` table, `has_one :donor_profile` in `user.rb`, and flash messages (`notice`/`alert`) shown in the layout. If any is missing, ask a mentor; do not add it yourself.

**Who depends on you:**

| Module | What they need from you |
| --- | --- |
| B. Donor directory | Profiles to list; `belongs_to :user` so `donor.user.name` works. Your redirect goes to their page. |
| D. Matching donors | `blood_group` and `city` values that exactly match `BLOOD_GROUPS` and `CITIES`, so their `where` finds them |
| D. Matching donors (D3) | A mentor and Attendee 4 add one class method, `self.matching`, to your model in a separate small commit after you merge. Leave it in place; you don't need to explain it at A4. |
| Seed data (mentor) | Your validations: seeds must pass them, so tell the mentor if you add a rule |

**Coordination points**

- Until Module B is merged, `/donors` has an empty action and no view, so redirecting there shows "missing template". Temporarily use `redirect_to root_path, notice: ...` and switch to `donors_path` after B is on main.
- Do not rename fields or the partial's local; Module B and D read the same columns.
- Merge order: **C first**, then **A**, B, D, E (see [README](README.md#shared-files-and-merge-order)). Pull main after every merge announcement.

## Common mistakes

| Symptom | Cause | Fix |
| --- | --- | --- |
| `undefined method 'donor_profiles_path'` on the form | Singular route, but `form_with` guessed a plural URL | Add `url: donor_profile_path` to `form_with` |
| `undefined method 'build_donor_profile'` | `has_one :donor_profile` missing in `User` | Ask a mentor to add it to `user.rb` |
| `uninitialized constant BLOOD_GROUPS` | Constants file not loaded or missing | Pull main, restart `bin/dev` (initializers load only at boot) |
| Form saves but phone or available is empty/unchanged | Field missing from `params.expect` | Add it to the list in `donor_profile_params` |
| `ActionController::ParameterMissing: donor_profile` | Form fields not named `donor_profile[...]` | Use `form_with model: donor_profile` and `f.` helpers, not plain `text_field_tag` |
| Errors never show; nothing happens (browser console: "Form responses must redirect to another location") | Missing `status: :unprocessable_entity` (Turbo ignores a 200 after a form post) | Add the status to `render :new` / `render :edit` |
| Two messages for an empty blood group ("can't be blank" and "is not included") | Both presence and inclusion fail on blank | Expected; fine for today |
| `undefined local variable 'donor_profile'` in `_form` | Rendered the partial without the local | `render "form", donor_profile: @donor_profile` |
| User's old profile disappeared after submitting the new form | `create` has no guard, so `build_donor_profile` replaced it | Add the "already has a profile" check at the top of `create` |
| `ActiveRecord::RecordNotUnique` | Saved without the uniqueness validation | Add `validates :user_id, uniqueness: true` |
| Checkbox appears on the new page | Missing `persisted?` check | Wrap it in `<% if donor_profile.persisted? %>` |

More general errors: [Common errors and what they mean](../MVC_GUIDE.md#common-errors-and-what-they-mean).

## Explain it (A4)

Questions a mentor will ask, and what a good answer covers:

| Question | Key points |
| --- | --- |
| Why is there no id in `/donor_profile/edit`? | Singular resource; each user has one profile; we load `Current.user.donor_profile`, so you cannot reach someone else's |
| Where is "phone is required" enforced? | In the model with `validates`; the DB also has `null: false` as a safety net |
| Why a dropdown for blood group and not a text field? | Exact values so filters (B, D) match; `inclusion` still checks in case someone fakes the value |
| How does the profile know whose it is? | `Current.user.build_donor_profile` sets `user_id`; `user_id` is not a form field and not in strong params |
| What happens when the form has an error? | `save` returns false, controller renders `new` with status 422, the view lists `errors.full_messages` |
| Why redirect after a successful save? | So refreshing does not submit again; it also lands on the donors list for the demo |
| What stops two profiles for one user? | Guard in `new`/`create`, `uniqueness` validation, unique DB index |
| (A3) How does the checkbox become `false`? | Hidden field sends `"0"` when unticked; Rails casts it to `false`; `:available` is permitted |

Your 5-line explanation (template from [MVC_GUIDE.md](../MVC_GUIDE.md#explaining-your-module-at-the-demo)):

1. "When you open **`/donor_profile/new`**, the router sends it to **`DonorProfilesController#new`**, which gives the form an empty profile, or sends you to edit if you already have one."
2. "Submitting goes to **`create`**, which builds the profile for the logged-in user with **`Current.user.build_donor_profile(donor_profile_params)`**."
3. "The model makes sure **blood group, city and phone are filled, blood group and city come from the fixed lists, and each user has only one profile**."
4. "The view **`_form.html.erb`** shows **dropdowns for blood group and city and a phone field**, and the donors list never shows **the phone number**."
5. "If something is wrong, like **a missing phone**, **`save` returns false and the form comes back with the error message; if it saves, you are redirected to the donors list**."

## Out of scope

Do not build these, even if your AI tool suggests them:

- A `show` page for the profile, or deleting a profile (no route exists)
- Adding name or email to this form (name lives on `users`, set at sign-up)
- Phone format validation, OTP or SMS checks
- Last donation date, eligibility rules, donation history
- Showing phone numbers anywhere else
- New migrations, columns or edits to `config/routes.rb`
- Gems such as Devise, Pundit, simple_form or phonelib
- Turbo Frames / Stimulus enhancements; a plain form is enough
