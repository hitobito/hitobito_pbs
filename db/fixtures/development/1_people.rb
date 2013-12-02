# encoding: utf-8

@encrypted_password = BCrypt::Password.create("pbs42pbs", cost: 1)

puzzlers = ['Pascal Zumkehr',
            'Pierre Fritsch',
            'Andreas Maierhofer',
            'Andre Kunz',
            'Roland Studer']

devs = puzzlers.each_with_object({}) do |puz, memo|
  memo[puz] = "#{puz.split.last.downcase}@puzzle.ch"
end


root = Group.root
devs.each do |name, email|
  first, last = name.split
  attrs = { email: email,
            first_name: first,
            last_name: last,
            encrypted_password: @encrypted_password }
  Person.seed_once(:email, attrs)
  person = Person.find_by_email(attrs[:email])

  role_member_attrs = { person_id: person.id, group_id: root.id, type: Group::TopLayer::Leader.sti_name }
  Role.seed_once(*role_member_attrs.keys, role_member_attrs)
end
