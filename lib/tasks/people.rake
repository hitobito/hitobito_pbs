namespace :people do
  desc 'Print Information about Last years people data'
  task :yearly_report do
    # rubocop:disable all
    year = Date.today.year - 1
    year_start = Date.new(year)
    year_end = year_start.end_of_year

    persons = Person.where(locked_at: nil).count
    users = Person.where(locked_at: nil).where.not(encrypted_password: nil).where('sign_in_count > 0').count
    users_by_signin = Person.where(locked_at: nil).where.not(encrypted_password: nil).group(:sign_in_count).order(:sign_in_count).count
    camps = Event::Camp.where('created_at >= ? AND created_at <= ?', year_start, year_end).count
    courses = Event::Course.where('created_at >= ? AND created_at <= ?', year_start, year_end).count
    events = Event.where('type IS NULL AND created_at >= ? AND created_at <= ?', year_start, year_end).count
    mailinglists = MailingList.count
    layers = Group.all.select { |g| g.class.layer }.length
    require_add_requests = Group.where(require_person_add_requests: true).count

    puts "Anzahl erfasster Personen insgesamt: #{persons}\n" +
      "Anzahl Benutzer mit genutzten Logins: #{users}\n" +
      "Anzahl Logins: #{users_by_signin}\n" +
      "Anzahl erfasster Lager im #{year}: #{camps}\n" +
      "Anzahl erfasster Kurse im #{year}: #{courses}\n" +
      "Anzahl erfasster Anlässe im #{year}: #{events}\n" +
      "Anzahl erfasster Abos: #{mailinglists}\n" +
      "Wieviele Abteilungen haben Freigabeverfahren (zum Hinzufügen von Personen) aktiviert?: #{require_add_requests}/#{layers}\n"
    # rubocop:enable all
  end
end
