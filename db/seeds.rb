# Demo data for Blood Donor Connect. Every name and phone number here is made up.
# Safe to run more than once: bin/rails db:seed
#
# - 15 donors across all blood groups and cities (2 of them not available right now)
# - 4 requesters who post 6 blood requests, all needed in the future
# - Several requests share a blood group and city with donors, so "matching donors" has results
# - No responses: those come from clicking "I can help" during the demo
#
# Log in as any of them with their email (donor1@example.com ... donor15@example.com,
# requester1@example.com ... requester4@example.com) and the password "password".

PASSWORD = "password"

donors = [
  # name,              blood group, city,       available
  [ "Asha Kulkarni",   "O+",  "Pune",     true ],
  [ "Neha Shah",       "O+",  "Pune",     true ],
  [ "Meera Joshi",     "A-",  "Nashik",   true ],
  [ "Priya Deshmukh",  "B+",  "Pune",     true ],
  [ "Sneha Patil",     "B+",  "Pune",     false ],
  [ "Kavya Iyer",      "AB+", "Mumbai",   true ],
  [ "Ananya Rao",      "O-",  "Mumbai",   true ],
  [ "Riya Sharma",     "A+",  "Nagpur",   true ],
  [ "Isha Gupta",      "A+",  "Nagpur",   true ],
  [ "Pooja Nair",      "AB-", "Kolhapur", true ],
  [ "Divya Menon",     "B-",  "Mumbai",   true ],
  [ "Tanvi Jadhav",    "O-",  "Pune",     false ],
  [ "Shruti Pawar",    "A-",  "Kolhapur", true ],
  [ "Aditi Kale",      "O+",  "Nashik",   true ],
  [ "Nikita Bhosale",  "AB+", "Mumbai",   true ]
]

donors.each_with_index do |(name, blood_group, city, available), i|
  user = User.find_or_create_by!(email_address: "donor#{i + 1}@example.com") do |u|
    u.name = name
    u.password = PASSWORD
  end

  profile = DonorProfile.find_or_initialize_by(user: user)
  profile.update!(
    blood_group: blood_group,
    city: city,
    phone: format("98000000%02d", i + 1),
    available: available
  )
end

requesters = [ "Ravi Patil", "Sunita More", "Arjun Mehta", "Farah Khan" ].map.with_index do |name, i|
  User.find_or_create_by!(email_address: "requester#{i + 1}@example.com") do |u|
    u.name = name
    u.password = PASSWORD
  end
end

requests = [
  # requester, patient,       group, units, hospital,               city,     days from now, note
  [ 0, "Ravi Patil",    "B+",  2, "Sahyadri Hospital",    "Pune",   2, "Surgery scheduled for Monday morning." ],
  [ 1, "Kamala More",   "O+",  1, "Ruby Hall Clinic",     "Pune",   4, nil ],
  [ 2, "Rohan Mehta",   "AB+", 3, "Lilavati Hospital",    "Mumbai", 3, "Accident case, any time of day." ],
  [ 3, "Zoya Khan",     "A+",  1, "Orange City Hospital", "Nagpur", 5, nil ],
  [ 0, "Vasant Patil",  "O-",  2, "Kokilaben Hospital",   "Mumbai", 6, nil ],
  [ 2, "Lata Mehta",    "A-",  1, "Wockhardt Hospital",   "Nashik", 7, "Planned operation." ]
]

requests.each_with_index do |(requester, patient, blood_group, units, hospital, city, days, note), i|
  request = BloodRequest.find_or_initialize_by(user: requesters[requester], patient_name: patient)
  request.update!(
    blood_group: blood_group,
    units_needed: units,
    hospital: hospital,
    city: city,
    needed_by: Date.current + days,
    contact_phone: format("97000000%02d", i + 1),
    note: note
  )
end

puts "Seeded #{User.count} users, #{DonorProfile.count} donor profiles, #{BloodRequest.count} blood requests."
