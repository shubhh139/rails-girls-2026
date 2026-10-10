# Blood Donor Connect — attendee tasks

Oct 10, 2026 · Vishwajeetsingh Desurkar

Five modules, one per attendee, each with three build tasks and one explain task, sized for 2.5 hours of build time.

See also: [PRD.md](PRD.md) for scope and data model, and [TASKS.md](TASKS.md) for the full task list including mentor tasks.

## Before you start

You start from a working app with login. Once the database tables are done in the first 20 minutes, all five modules run in parallel.

**Already built by mentors**

- Rails 8 app with sign up, log in and log out
- Layout, nav bar and home page
- `BLOOD_GROUPS` and `CITIES` lists, ready to use in dropdowns
- Routes and a controller with empty actions for each module, so nobody edits `config/routes.rb`

**Order of work**

| When | What happens |
| --- | --- |
| 0:00 - 0:20 | A mentor creates all three tables (donor profiles, blood requests, responses) on the projector and explains each column. Everyone pulls and runs `bin/rails db:migrate`. |
| 0:20 | All five modules start at the same time, each on her own branch. |
| 1:30 | Checkpoint, then merging. See Finish. |

**Rules for everyone**

- Work on your own branch, named after your module (`module-a-donor-profile`).
- Edit only the files listed under your module. If you need a change in someone else's file, ask her.
- Ask your AI tool for one small step at a time, and paste your task text into the prompt so it uses the right names.
- Before you accept generated code, ask the AI to explain it line by line until you could explain it yourself.
- No new gems. If the AI suggests Devise, Pundit or Ransack, say no.
- Use made-up names and phone numbers only.

Nobody creates a migration after 0:20. If you think you need a new column, ask a mentor, who adds it for everyone.

## Module A: Donor profile

You build the form where a signed-in user becomes a donor. Owner: Attendee 1. Start at 0:20.

- [ ] **A1. Validations.** In the DonorProfile model, require blood group, city and phone. Blood group must be one of `BLOOD_GROUPS`. A user can have only one profile.
- [ ] **A2. New profile form.** Build the page with dropdowns for blood group and city and a text field for phone. Saving creates a profile for the logged-in user.
- [ ] **A3. Edit profile (cut first if behind).** Add an edit page with an "available to donate" yes/no toggle.
- [ ] **A4. Explain it.** Walk a mentor through your model, controller and view.

**Files you own:** `app/models/donor_profile.rb`, `app/controllers/donor_profiles_controller.rb`, `app/views/donor_profiles/`

**Done when:** a new user can sign up, fill the form and see her profile saved, and a form with a missing phone shows an error.

## Module B: Donor directory

You build the page where anyone signed in can find donors by blood group. Owner: Attendee 2. Start at 0:20.

- [ ] **B1. Donors list.** Build a page listing every donor's name, blood group and city. Do not show phone numbers.
- [ ] **B2. Blood group filter.** Add a dropdown above the list. Choosing O+ shows only O+ donors; choosing nothing shows everyone.
- [ ] **B3. City filter (cut first if behind).** Add a second dropdown that works together with the blood group filter.
- [ ] **B4. Explain it.** Walk a mentor through your query and view.

**Files you own:** `app/controllers/donors_controller.rb`, `app/views/donors/`

**Done when:** the list shows donors, the filter narrows it correctly, and no phone number appears anywhere on the page.

Until seed data is merged, create two or three donors yourself in `bin/rails console` to test with.

## Module C: Blood requests

You build the form and page for posting a blood request. Owner: Attendee 3. Start at 0:20.

- [ ] **C1. BloodRequest model rules.** The table already exists. In the model, say that a request belongs to a user, require every field except note, and require units needed to be at least 1.
- [ ] **C2. Request form.** Build the "Request blood" page with dropdowns for blood group and city. Saving creates a request owned by the logged-in user.
- [ ] **C3. Request page.** Build the page that shows one request's details. After saving the form, the user lands here.
- [ ] **C4. Explain it.** Walk a mentor through your model, controller and view.

**Files you own:** `app/models/blood_request.rb`, the `new`, `create` and `show` actions in `app/controllers/blood_requests_controller.rb`, and `app/views/blood_requests/new.html.erb`, `_form.html.erb` and `show.html.erb`

**Done when:** a signed-in user can post a request and see it on its own page, and a form with units left blank shows an error.

Modules D and E each add one line to your request page near the end. Leave a clearly marked spot at the bottom for them.

## Module D: Requests list

You build the page donors open first: the list of blood requests. Owner: Attendee 4. Start at 0:20.

- [ ] **D1. Requests list.** Build a page listing all requests, newest first, showing blood group, units, hospital, city and needed-by date. Each row links to the request page.
- [ ] **D2. Blood group filter.** Add a dropdown above the list. Choosing B+ shows only B+ requests.
- [ ] **D3. Matching donors (with a mentor, cut first if behind).** On the request page, list donors with the same blood group and city as the request. Name and city only, no phone.
- [ ] **D4. Explain it.** Walk a mentor through your query and view.

**Files you own:** the `index` action in `app/controllers/blood_requests_controller.rb`, `app/views/blood_requests/index.html.erb` and `_matching_donors.html.erb`

**Done when:** the list shows requests newest first, the filter works, and clicking a row opens that request.

You share one controller file with Module C. The empty actions are already there: fill in only `index` and leave hers alone.

Until seed data is merged, create two or three requests yourself in `bin/rails console` to test with.

## Module E: Responses

You build the step that connects the two sides: a donor saying "I can help". This is the hardest module. Owner: Attendee 5. Start at 0:20.

- [ ] **E1. Response model rules (with a mentor).** The table already exists. In the model, say that a response belongs to a blood request and to a donor (a user), and that a donor can respond to the same request only once.
- [ ] **E2. "I can help" button.** Add a button to the request page. Clicking it creates a response for the logged-in user and shows a confirmation.
- [ ] **E3. Responses list (mentor takes over if behind).** On the request page, list each responder's name and phone. Only the person who created the request can see this list.
- [ ] **E4. Explain it.** Walk a mentor through your model and the "only the creator sees it" rule.

**Files you own:** `app/models/response.rb`, `app/controllers/responses_controller.rb`, `app/views/responses/`

**Done when:** a donor can click the button once, a second click is refused, and the request's creator sees the donor's name and phone while a different user does not.

Module C's request page will not be merged when you start. Build your button and list as partials, test the model in `bin/rails console`, and add them to her page once it is on main.

## Finish

The last hour is for joining the five modules into one working app and being able to explain your part.

| When | What you do |
| --- | --- |
| 1:30 | Checkpoint. If your "cut first" task has not started, skip it. |
| 1:30 - 2:10 | Open a pull request. A mentor reviews and merges. Pull main, run `bin/rails db:seed`, and click through the whole app. |
| 2:10 - 2:30 | Do your explain task with a mentor. Rehearse your two minutes. |
| After 2:30 | Demo. You present your own module. |

**The journey the demo must show**

1. Sign up and create a donor profile (Module A).
2. Find that donor in the donors list by blood group (Module B).
3. As a second user, post a blood request (Module C).
4. As the donor, find the request in the list (Module D).
5. Click "I can help", then switch back and see the donor's contact (Module E).
