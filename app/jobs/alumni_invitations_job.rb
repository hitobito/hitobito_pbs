class AlumniInvitationsJob < RecurringJob
  run_every 1.day

  def perform
    Person::AlumniInvitor.new.run
  end
end
