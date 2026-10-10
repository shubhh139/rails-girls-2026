# Blood Donor Connect — one-day PoC PRD

Oct 10, 2026 · Vishwajeetsingh Desurkar

A Rails 8 app where people register as blood donors, post blood requests, and donors respond to matching requests, built in one Rails Girls day by 5 attendees and 2 mentors using AI tools.

See also: [ATTENDEE_TASKS.md](ATTENDEE_TASKS.md) for the five modules, and [TASKS.md](TASKS.md) for the full task list.

## Goals

Understanding comes first, a working app second, feature count last. When they conflict, cut features.

1. **Each attendee understands what she built.** At the demo she can open her model, controller and view and explain what each does, without a mentor prompting.
2. **Each attendee owns something visible.** Every slice is a screen she can point to and say "I built this".
3. **The app is useful and minimal.** One complete journey works end to end: post a request, find a matching donor, respond.

How the plan serves this:

- The data model is built together. A mentor creates all three database tables on the projector with everyone following, so all five understand the data before working alone.
- Mentors take the complex steps (authentication, merges, contact-reveal rules, anything involving associations across slices). Attendees take the steps they can explain.
- A slice is done when its owner has explained it to a mentor, not when it works.
- If the team is behind at the 1:30 mark, the "cut first" tasks are dropped and the time goes to explaining and rehearsing the demo.

## Scope

Build time is 2 to 3 hours, so scope is three build tasks per attendee. The session succeeds if a requester can post a request and a donor can respond to it, end to end, in the demo.

| In scope (must ship) | Cut first if behind | Out of scope |
| --- | --- | --- |
| Sign up, log in, log out (built by a mentor before the day) | Edit profile with an available yes/no toggle | Editing, closing or deleting requests |
| Donor profile: blood group, city, phone | City filter on the donors list | Compatibility matching (O- to all, AB+ from all) |
| Donors list with a blood group filter | Matching donors shown on the request page | Notifications of any kind |
| Create and view a blood request |  | Pages for signed-out visitors, other than home |
| Open requests list with a blood group filter |  | Deploy to a public URL |
| Donor clicks "I can help" on a request |  | Maps, admin panel, hospital accounts |
| Requester sees who responded |  | Donation history and eligibility rules |

This is a learning PoC with seed data. It must not be presented or used as a real emergency service.

## Users and flows

There is one account type. Any signed-in user can be a donor, a requester, or both.

**Flow 1: Become a donor**

1. Sign up with name, email and password.
2. Fill in the donor profile: blood group, city, phone.
3. Appear in the donors list, which shows name, blood group and city.

**Flow 2: Request blood**

1. Sign in and click "Request blood".
2. Enter patient name, blood group, units needed, hospital, city, needed-by date and contact phone.
3. Land on the request page, which lists responses as they come in.

**Flow 3: Respond to a request**

1. A donor opens a request from the open requests list.
2. The donor clicks "I can help".
3. The requester sees the donor's name and phone under responses.

**Acceptance criteria**

- Every page except the home page requires login.
- Blood group is chosen from a fixed list of 8 values (A+, A-, B+, B-, AB+, AB-, O+, O-), never typed freely.
- A donor can respond to a request only once.
- Donor phone numbers appear only in a request's responses list, and only its creator sees that list.
- The blood group filter works on both the donors list and the requests list.

## Data model

Five tables: `users` and `sessions` come from the Rails 8 authentication generator, and the team adds `donor_profiles`, `blood_requests` and `responses`.

| Model | Fields | Rules |
| --- | --- | --- |
| User | name, email_address, password_digest | has one donor profile, has many blood requests, has many responses |
| DonorProfile | user_id, blood_group, city, phone, available (boolean, default true) | belongs to user; blood_group, city and phone required; one per user |
| BloodRequest | user_id, patient_name, blood_group, units_needed (integer), hospital, city, needed_by (date), contact_phone, note | belongs to user; units_needed at least 1 |
| Response | blood_request_id, donor_id (user), note | unique on blood_request_id + donor_id; donor cannot be the request's owner |

Shared pieces:

- `BLOOD_GROUPS` constant, defined once and used by both DonorProfile and BloodRequest validations and form dropdowns.
- City is a dropdown from a short fixed list (for example Pune, Mumbai, Nashik, Nagpur, Kolhapur) so filters match exactly.
- `db/seeds.rb` creates about 15 donors and 6 requests across groups and cities, so every screen has data during the demo.

Stack: Ruby 4, Rails 8, SQLite, Hotwire defaults, Tailwind or plain CSS, Minitest. No extra gems for the must-ship scope.

## Build plan

Mentors build everything that is not a learning moment before the day, so the 2.5 hours go to features. All five work in parallel in one repo, each on her own feature branch and slice.

**Before the day (mentors, about 1.5 hours)**

- [ ] `rails new` with Rails 8, push to GitHub, add all 7 people as collaborators
- [ ] Run the authentication generator and add a sign-up page (the generator only creates login)
- [ ] Add the layout, nav bar, home page with the demo disclaimer, `BLOOD_GROUPS` and the city list
- [ ] Add routes and a controller with empty actions for each slice, so nobody edits `config/routes.rb` during the build
- [ ] Confirm the app boots on every attendee laptop

**Slices (three build tasks each, plus explaining it to a mentor)**

| Slice | Owner | Builds | Mentor needed for |
| --- | --- | --- | --- |
| A. Donor profile | Attendee 1 | Validations, new-profile form, edit with available toggle | Nothing |
| B. Donor directory | Attendee 2 | Donors list, blood group filter, city filter | Nothing |
| C. Blood requests | Attendee 3 | BloodRequest model, request form, request page | Nothing |
| D. Requests list | Attendee 4 | Open requests list, blood group filter, matching donors | Matching donors query |
| E. Responses | Attendee 5 | Response model, "I can help" button, responses list | Uniqueness rule and owner-only visibility |

**Timeline (hours:minutes from the start of build time)**

| Time | Activity |
| --- | --- |
| 0:00 - 0:20 | Mentor creates all three tables on the projector (donor profiles, blood requests, responses), explaining each column; everyone pulls and migrates |
| 0:20 - 1:30 | All five slices in progress in parallel |
| 1:30 | Checkpoint: drop every "cut first" task that has not started |
| 1:30 - 2:10 | Merge to main, load seed data, click through the full journey, fix what breaks |
| 2:10 - 2:30 | Each attendee explains her slice to a mentor; rehearse the demo |
| After 2:30 | Demo: each attendee presents her own slice |

The plan uses 2.5 hours and leaves 30 minutes of slack inside a 3-hour session. All migrations are done in the first 20 minutes, so all five start together and nobody creates a migration afterwards. Slice E is still the hardest, so it goes to the strongest attendee.

## Working rules

The goal of the day is that each attendee can explain her slice, not that the AI produced the most code.

**AI tools**

- Prompt for one small step at a time (one model, one form, one filter), not "build the whole feature".
- Before accepting generated code, the attendee explains to a mentor or a peer what it does. If she cannot, she asks the AI to explain it line by line.
- Paste the relevant section of this PRD into the prompt so the AI uses the agreed field names.
- No new gems without a mentor's approval. AI tools often suggest Devise, Pundit or Ransack, and none are needed here.

**Git**

- One feature branch per slice, small pull requests, a mentor merges.
- All migrations are created in the first 20 minutes. After that, nobody creates a migration or edits `schema.rb` by hand.
- Pull from main after every merge announcement.

**Privacy and safety**

- Phone numbers are never shown on public or list pages. A donor's phone is shown only to the requester she responded to.
- Use seed data and made-up phone numbers only. No real patient or donor details are entered during the day.
- The home page carries a visible line: "Demo project built at Rails Girls. Not a real emergency service."
- If the app is deployed, it is deployed with seed data and taken down or locked after the demo.

## Open questions

Confirmed: one shared repo, attendees know Git, all have AI tools, login is in scope, attendees are college students new to Ruby, five work in parallel.

Still assumed:

- [ ] Do the 2 to 3 hours include the demo? The plan assumes the demo comes after.
- [ ] Which attendee takes slice E, the hardest one?
- [ ] Is localhost on a projector enough for the demo (assumed), with no deploy?
- [ ] Tailwind or plain CSS?
