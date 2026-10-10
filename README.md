# Blood Donor Connect

A Rails 8 app where people register as blood donors, post blood requests, and donors respond to matching requests. Built in one day at Rails Girls 2026 by 5 attendees and 2 mentors.

Demo project built at Rails Girls. Not a real emergency service. Use made-up names and phone numbers only.

## Getting started

You need Ruby 4.0.1 (see `.ruby-version`) and SQLite.

```bash
git clone git@github.com:shubhh139/rails-girls-2026.git
cd rails-girls-2026
bin/setup      # installs gems, prepares the database, starts the server
```

After the first setup, start the app with:

```bash
bin/dev
```

Then open http://localhost:3000.

| Page | URL | What it is |
| --- | --- | --- |
| Home | http://localhost:3000/ | The landing page (UI_DESIGN.md screen 1) |
| Style guide | http://localhost:3000/styleguide | Every CSS class you can use, with HTML to copy |

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

Ruby 4, Rails 8.1, SQLite, Hotwire (Turbo and Stimulus), import maps, Propshaft, Minitest. Plain CSS, no CSS framework. No extra gems for the must-ship scope.

## UI base setup

The shared look of the app is already in place, so attendees build pages by adding class names, not by writing CSS.

| What | File | Notes |
| --- | --- | --- |
| Shared stylesheet | `app/assets/stylesheets/application.css` | Design tokens, base styles, focus outlines, and every component class from UI_DESIGN.md |
| Layout | `app/views/layouts/application.html.erb` | Nav, flash messages (`notice` and `alert`), `.container`, demo footer. Attendees do not edit it. |
| Nav | `app/views/layouts/_nav.html.erb` | Red nav bar with Requests, Donors, Request blood, My profile, Log out |
| Home page | `app/controllers/pages_controller.rb`, `app/views/pages/home.html.erb` | Screen 1 from UI_DESIGN.md, at `/` |
| Style guide | `app/views/pages/styleguide.html.erb` | One of each component, at `/styleguide` |
| Routes | `config/routes.rb` | `root "pages#home"` and `get "styleguide"` |

Tailwind was removed (gem, `Procfile.dev` watcher and asset files), so `bin/dev` runs only the Rails server.

### Component classes

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

Example:

```erb
<h1 class="page-title">Donors</h1>

<div class="card-list">
  <div class="card">
    <span class="badge">O+</span> Asha Kulkarni
    <p class="meta">Pune</p>
  </div>
</div>
```

## Still to do before the day (mentors)

The full checklist is in [specs/README.md](specs/README.md#mentor-checklist-before-the-day) and [TASKS.md](TASKS.md).

- [ ] Run the authentication generator and add sign-up (`RegistrationsController`, `/registration/new`) that collects a name
- [ ] Nav: once login exists, follow the TODO in `app/views/layouts/_nav.html.erb` (route helpers, signed-out links, "My profile" target, `button_to` for Log out)
- [ ] Uncomment `allow_unauthenticated_access` in `PagesController` so signed-out visitors can see the home page
- [ ] Remove the generator's own flash messages from the session and password views; style sign-up and log-in (screen 2)
- [ ] Module routes and empty controller actions (see [specs/README.md](specs/README.md#routes))
- [ ] `BLOOD_GROUPS` and `CITIES` in `config/initializers/constants.rb`
- [ ] Seed data in `db/seeds.rb`
- [ ] Optional: enable Minitest before running the authentication generator

Until the module routes exist, the nav links to Requests, Donors and the profile pages show a routing error. That is expected.
