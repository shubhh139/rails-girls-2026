# Blood Donor Connect

A Rails 8 app where people register as blood donors, post blood requests, and donors respond to matching requests. Built in one day at Rails Girls 2026 by 5 attendees and 2 mentors.

Demo project built at Rails Girls. Not a real emergency service. Use made-up names and phone numbers only.

## Getting started

You need Ruby 4.0.1 (see `.ruby-version`) and SQLite.

```bash
git clone git@github.com:shubhh139/rails-girls-2026.git
cd rails-girls-2026
bin/setup      # installs gems, creates the database, loads seed data, starts the server
```

After the first setup, start the app with:

```bash
bin/dev
```

Then open http://localhost:3000 and log in with one of the demo accounts below.

To start over with fresh demo data: `bin/rails db:reset` (drops, recreates and seeds the database).

## Demo logins

Every seeded account uses the password **`password`**.

| Email | Name | Who they are |
| --- | --- | --- |
| `donor1@example.com` | Asha Kulkarni | Donor, O+, Pune |
| `donor2@example.com` | Neha Shah | Donor, O+, Pune |
| `donor3@example.com` | Meera Joshi | Donor, A-, Nashik |
| `donor4@example.com` … `donor15@example.com` | | More donors across all blood groups and cities (donor5 and donor12 are not available) |
| `requester1@example.com` | Ravi Patil | Posted 2 requests (B+ Pune, O- Mumbai) |
| `requester2@example.com` | Sunita More | Posted 1 request (O+ Pune) |
| `requester3@example.com` | Arjun Mehta | Posted 2 requests (AB+ Mumbai, A- Nashik) |
| `requester4@example.com` | Farah Khan | Posted 1 request (A+ Nagpur) |

To try the full journey, log in as a donor in one browser and as a requester in another (or a private window). You can also create your own account at `/registration/new`.

These are made-up demo accounts for a local app. Never reuse this password anywhere real.

## Pages that work today

| Page | URL | Login needed |
| --- | --- | --- |
| Home | `/` | No |
| Style guide (every CSS class, with HTML to copy) | `/styleguide` | No |
| Log in | `/session/new` | No |
| Sign up | `/registration/new` | No |
| Module pages: donors, requests, request blood, request page, donor profile | `/donors`, `/blood_requests`, `/blood_requests/new`, `/blood_requests/:id`, `/donor_profile/new`, `/donor_profile/edit` | Yes. Each shows a placeholder until its module is built. |

## Docs

Read them in this order:

| Doc | What's in it |
| --- | --- |
| [MVC_GUIDE.md](MVC_GUIDE.md) | How a Rails app is organised (models, views, controllers, routes), using this app as the example. Read first. |
| [ATTENDEE_TASKS.md](ATTENDEE_TASKS.md) | The five modules, one per attendee, and the order of the day |
| [specs/](specs/README.md) | A tech spec for each module: concepts, code, checks, and how to explain it |
| [UI_DESIGN.md](UI_DESIGN.md) | What every screen looks like and the CSS classes to use |
| [DB_SCHEMA.md](DB_SCHEMA.md) | The tables and columns |
| [PRD.md](PRD.md) | Scope, goals and rules for the day |
| [TASKS.md](TASKS.md) | Every task, mentors included |

## Stack

Ruby 4, Rails 8.1, SQLite, Hotwire (Turbo and Stimulus), import maps, Propshaft, `bcrypt` for passwords. Plain CSS, no CSS framework. No test suite. No extra gems for the must-ship scope.

## What mentors have set up

Everything below is on `main`, so attendees start straight on their module.

### Login

A small login built on Rails features, without the authentication generator and without a sessions table.

| What | File | Notes |
| --- | --- | --- |
| Passwords | `app/models/user.rb` | `has_secure_password` (stores a `password_digest`), email normalised to lower case |
| Current user | `app/models/current.rb`, `app/controllers/application_controller.rb` | The signed-in user's id lives in the session cookie; `Current.user` is that user on every request |
| Login required | `app/controllers/application_controller.rb` | Every page needs login. Signed-out visitors go to the login page and come back afterwards. A controller opens pages with `allow_unauthenticated_access`. |
| Log in, log out | `app/controllers/sessions_controller.rb`, `app/views/sessions/new.html.erb` | `/session/new` login page; failed logins are rate-limited; "Log out" in the nav |
| Sign up | `app/controllers/registrations_controller.rb`, `app/views/registrations/new.html.erb` | Name, email, password; logs you in and opens the donor profile form |

In views, use `signed_in?` and `Current.user`.

### UI

The shared look is in place, so attendees build pages by adding class names, not by writing CSS.

| What | File | Notes |
| --- | --- | --- |
| Shared stylesheet | `app/assets/stylesheets/application.css` | Design tokens, base styles, focus outlines, and every component class from UI_DESIGN.md |
| Layout | `app/views/layouts/application.html.erb` | Nav, flash messages (`notice` and `alert`), `.container`, demo footer. Attendees do not edit it. |
| Nav | `app/views/layouts/_nav.html.erb` | Signed in: Requests, Donors, Request blood, My profile (edit if you have a profile, otherwise new), Log out. Signed out: Log in, Sign up. |
| Home page | `app/controllers/pages_controller.rb`, `app/views/pages/home.html.erb` | Screen 1 from UI_DESIGN.md |
| Style guide | `app/views/pages/styleguide.html.erb` | One of each component, at `/styleguide` |

Tailwind was removed (gem, `Procfile.dev` watcher and asset files), so `bin/dev` runs only the Rails server.

#### Component classes

| Class | Use for |
| --- | --- |
| `page-title` | The one `<h1>` on each page |
| `card`, `card-list` | One donor, request or response; a list of them |
| `badge` | A blood group (A+, O-) |
| `meta` | A secondary line of text |
| `btn`, `btn btn-primary` | A button or button-styled link; the one main action on a page |
| `form-field`, `form-errors` | A label with its input; the error box at the top of a form |
| `filter-bar` | The dropdowns and button above a list |
| `empty-state` | The message when a list has no rows |
| `flash flash-notice`, `flash flash-alert` | Success and error messages (the layout shows these) |

```erb
<h1 class="page-title">Donors</h1>

<div class="card-list">
  <div class="card">
    <span class="badge">O+</span> Asha Kulkarni
    <p class="meta">Pune</p>
  </div>
</div>
```

### Database and seed data

The four tables from [DB_SCHEMA.md](DB_SCHEMA.md): `users`, `donor_profiles`, `blood_requests` and `responses` (migrations in `db/migrate/`, current shape in `db/schema.rb`).

| What | File | Notes |
| --- | --- | --- |
| Models | `app/models/` | As generated (`belongs_to` only). Attendees add validations in A1, C1 and E1; `Response` still needs `class_name: "User"` on `belongs_to :donor` (E1). |
| User | `app/models/user.rb` | `has_one :donor_profile`, `has_many :blood_requests`, `has_many :responses` (by `donor_id`), name and email validations |
| Allowed values | `config/initializers/constants.rb` | `BLOOD_GROUPS` and `CITIES` |
| Seed data | `db/seeds.rb` | The demo logins above, 15 donor profiles (2 unavailable), 6 future requests, some with matching donors by blood group and city, no responses. Safe to run again. |

### Module scaffolding

| What | File | Notes |
| --- | --- | --- |
| Routes | `config/routes.rb` | Every module route from [specs/README.md](specs/README.md#routes). Nobody edits this file during the build. |
| Controllers | `donor_profiles`, `donors`, `blood_requests`, `responses` in `app/controllers/` | Empty actions, each marked with its module |
| Placeholder views | `app/views/donor_profiles/`, `donors/`, `blood_requests/` | A heading and "Module X builds this page". Attendees replace them. |

## Mentor checklist

- [x] Rails app, Tailwind removed, plain CSS
- [x] Login, log out and sign up (no generator, no sessions table)
- [x] Layout, nav, flash, footer, home page, style guide
- [x] Routes and empty controllers for every module, with placeholder pages
- [x] Tables, models, `User` associations, `BLOOD_GROUPS` and `CITIES`
- [x] Seed data with demo logins
- [ ] At 0:00: walk through the migrations and `db/schema.rb` on the projector, then everyone runs `bin/rails db:reset`
