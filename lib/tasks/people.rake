# rubocop:disable all
namespace :people  do
  desc 'Print statistical Information about current or given year.'
  task :yearly_report, [:year] => [:environment] do |task, args|
    year = args[:year] ?  args[:year].to_i : Date.today.year
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
  end

  desc 'Returns a csv with people in certain roles at Kantonalverband that had that role in the past year'
  task :deleted_kanton_roles => [:environment] do
    person_attrs = %w(
      first_name last_name nickname email
      phone_numbers address zip_code town
      gender birthday kantonalverband_id
    )

    role_attrs = %w(Rolle deleted_at label)

    role_names = %w(
      Kantonsleitung Praesidium VizePraesidium Kassier Mediensprecher
      VerantwortungKrisenteam VerantwortungAusbildung VerantwortungBetreuung
      VerantwortungProgramm VerantwortungPr VerantwortungBiberstufe
      VerantwortungWolfstufe VerantwortungPfadistufe VerantwortungPiostufe
      VerantwortungRoverstufe VerantwortungPfadiTrotzAllem Webmaster Redaktor
    )
    types = role_names.collect { |type| Group::Kantonalverband.const_get(type).to_s }

    last_year = Time.zone.now.last_year
    last_year_range = last_year.beginning_of_year..last_year.end_of_year

    roles = Role.deleted.
      select('type, label, person_id, DATE(deleted_at) as deleted_at').
      distinct.
      where(end_on: last_year_range, type: types)

    def human_attrs(attrs, model_class)
      attrs.collect { |attr| model_class.human_attribute_name(attr) }
    end

    def values(attrs, model)
      attrs.collect do |attr|
        yield(model, attr).to_s.delete("\n").delete("\r").presence
      end
    end

    headers = human_attrs(person_attrs, Person) + human_attrs(role_attrs, Role)

    data = CSV.generate(headers: headers, write_headers: true, col_sep: ';') do |csv|
      roles.each do |role|

        person_values = values(person_attrs, role.person) do |model, attr|

          value = model.send(attr)
          case attr
          when 'birthday' then value ? value.strftime('%Y-%m-%d') : nil
          when 'phone_numbers' then value.where(public: true).join(' ')
          when 'gender' then model.gender_label
          when 'kantonalverband_id' then model.kantonalverband.name if model.kantonalverband
          else value.presence
          end
        end

        role_values = values(role_attrs, role) do |model, attr|
          case attr
          when 'deleted_at' then model.send(:end_on).strftime('%Y-%m-%d')
          when 'Rolle' then model.model_name.human
          else model.send(attr)
          end
        end

        csv << (person_values + role_values)
      end
    end
    File.write("expired_roles_#{last_year.year}.csv", data)
  end
end

# rubocop:enable all
