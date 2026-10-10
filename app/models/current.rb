<<<<<<< HEAD
class Current < ActiveSupport::CurrentAttributes
  attribute :user
end
=======
# Per-request globals. Current.user is the signed-in user, set by ApplicationController.
class Current < ActiveSupport::CurrentAttributes
  attribute :user
end
>>>>>>> main
