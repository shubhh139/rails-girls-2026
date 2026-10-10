# Blood Donor Connect — task list

Every task for the session, mentors included. Time blocks are hours:minutes from the start of build time.

See also: [PRD.md](PRD.md), [ATTENDEE_TASKS.md](ATTENDEE_TASKS.md) and [MVC_GUIDE.md](MVC_GUIDE.md).

- **Who:** Attendee = she builds it herself with AI help; Attendee + mentor = a mentor sits with her; Mentor = mentor builds it.
- **If behind:** Cut first = drop it at the 1:30 checkpoint if not started; Mentor takes over = mentor builds it while the attendee watches and explains it back; Keep = attendee finishes it.
- A task is done only after its owner has explained it to a mentor.


## Setup

| ID | Owner | Task | Who | Depends on | Time | Done when | If behind |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | Mentor 1 | Create Rails 8 app, push to GitHub, add all 7 collaborators | Mentor |  | Before the day | Everyone can clone and run bin/dev | Keep |
| P2 | Mentor 1 | Run authentication generator and add sign-up page | Mentor | P1 | Before the day | A new user can sign up, log in and log out | Keep |
| P3 | Mentor 2 | Add layout, nav bar, home page with demo disclaimer; add routes and a controller with empty actions for each module | Mentor | P1 | Before the day | Home page loads; nobody needs to edit config/routes.rb | Keep |
| P4 | Mentor 2 | Add BLOOD_GROUPS constant and CITIES list | Mentor | P1 | Before the day | Both lists usable in any model or form | Keep |
| W1 | Mentor 1 | Create all three tables (donor_profiles, blood_requests, responses) live on the projector, explaining each column; everyone pulls and migrates | Mentor | P2, P4 | 0:00 - 0:20 | Every attendee has all three tables locally and can name the columns her module uses | Keep |
| P5 | Mentor 2 | Write seed data: 15 donors, 6 requests | Mentor | W1 | 0:20 - 1:30 | bin/rails db:seed fills every screen | Keep |

## A. Donor profile

| ID | Owner | Task | Who | Depends on | Time | Done when | If behind |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A1 | Attendee 1 | Add validations: blood group in list, city and phone required, one profile per user | Attendee | W1 | 0:20 - 1:30 | Invalid profile is rejected in the console | Keep |
| A2 | Attendee 1 | Build the new-profile form with blood group and city dropdowns | Attendee | W1 | 0:20 - 1:30 | Form saves a profile for the logged-in user | Keep |
| A3 | Attendee 1 | Build edit profile page with the available yes/no toggle | Attendee | A2 | 0:20 - 1:30 | Toggling available changes the saved value | Cut first |
| A4 | Attendee 1 | Explain model, controller and view to a mentor | Attendee | A1, A2 | 2:10 - 2:30 | Mentor signs off | Keep |

## B. Donor directory

| ID | Owner | Task | Who | Depends on | Time | Done when | If behind |
| --- | --- | --- | --- | --- | --- | --- | --- |
| B1 | Attendee 2 | Create donors list page showing name, blood group and city | Attendee | W1 | 0:20 - 1:30 | Donors appear; no phone numbers shown | Keep |
| B2 | Attendee 2 | Add blood group filter dropdown | Attendee | B1 | 0:20 - 1:30 | Choosing O+ shows only O+ donors | Keep |
| B3 | Attendee 2 | Add city filter, combined with blood group | Attendee | B2 | 0:20 - 1:30 | Both filters work together | Cut first |
| B4 | Attendee 2 | Explain the query and view to a mentor | Attendee | B1, B2 | 2:10 - 2:30 | Mentor signs off | Keep |

## C. Blood requests

| ID | Owner | Task | Who | Depends on | Time | Done when | If behind |
| --- | --- | --- | --- | --- | --- | --- | --- |
| C1 | Attendee 3 | Add BloodRequest model rules: belongs to a user, required fields, units at least 1 | Attendee | W1 | 0:20 - 1:30 | Invalid request is rejected in the console | Keep |
| C2 | Attendee 3 | Build the Request blood form | Attendee | W1 | 0:20 - 1:30 | Form saves a request owned by the logged-in user | Keep |
| C3 | Attendee 3 | Build the request page showing all details | Attendee | C2 | 0:20 - 1:30 | Saving the form lands on the request page | Keep |
| C4 | Attendee 3 | Explain model, controller and view to a mentor | Attendee | C2, C3 | 2:10 - 2:30 | Mentor signs off | Keep |

## D. Requests list

| ID | Owner | Task | Who | Depends on | Time | Done when | If behind |
| --- | --- | --- | --- | --- | --- | --- | --- |
| D1 | Attendee 4 | Create open requests list page, newest first | Attendee | W1 | 0:20 - 1:30 | Requests appear and link to the request page | Keep |
| D2 | Attendee 4 | Add blood group filter dropdown | Attendee | D1 | 0:20 - 1:30 | Filter narrows the list correctly | Keep |
| D3 | Attendee 4 | Show matching donors (same blood group and city) on the request page | Attendee + mentor | W1, C3 | 0:20 - 1:30 | Request page lists the right donors from seed data | Cut first |
| D4 | Attendee 4 | Explain the query and view to a mentor | Attendee | D1, D2 | 2:10 - 2:30 | Mentor signs off | Keep |

## E. Responses

| ID | Owner | Task | Who | Depends on | Time | Done when | If behind |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E1 | Attendee 5 | Add Response model rules: belongs to a request and a donor, one response per donor per request | Attendee + mentor | W1 | 0:20 - 1:30 | A response can be created in the console; a duplicate is rejected | Keep |
| E2 | Attendee 5 | Add I can help button on the request page | Attendee | E1 | 0:20 - 1:30 | Button works as a partial; added to the request page once Module C merges | Keep |
| E3 | Attendee 5 | Show responses list with donor name and phone, visible only to the request's creator | Attendee + mentor | E2 | 0:20 - 1:30 | Creator sees responders; other users do not | Mentor takes over |
| E4 | Attendee 5 | Explain model and rules to a mentor | Attendee | E1, E2 | 2:10 - 2:30 | Mentor signs off | Keep |

## Wrap-up

| ID | Owner | Task | Who | Depends on | Time | Done when | If behind |
| --- | --- | --- | --- | --- | --- | --- | --- |
| X1 | Mentors | Review and merge pull requests, resolve conflicts | Mentor |  | Throughout | main always boots | Keep |
| X2 | Mentors | Integration pass: everything merged, seeds loaded, full journey clicked through | Mentor | All slices | 1:30 - 2:10 | Sign up, post request, respond, see responder works twice in a row | Keep |
| X3 | All attendees | Present own slice in the demo | Attendee | X2 | After 2:30 | Each attendee explains her slice in about 2 minutes | Keep |
