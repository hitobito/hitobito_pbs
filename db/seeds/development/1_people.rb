# encoding: utf-8

require Rails.root.join('db', 'seeds', 'support', 'person_seeder')

class Seeder

  include PersonSeeder

  def initialize
    @encrypted_password = BCrypt::Password.create("hito42bito", cost: 1)
  end

  def amount(role_type)
    case role_type.name.demodulize
    when 'Passivmitglied', 'Biber', 'Wolf', 'Pfadi', 'Mitglied', 'Pio', 'Rover' then 5
    else 1
    end
  end

end

seeder = Seeder.new

seeder.seed_all_roles

puzzlers = ['Pascal Zumkehr',
            'Pierre Fritsch',
            'Andreas Maierhofer',
            'Andre Kunz',
            'Roland Studer']

devs = {'Somebody' => 'some@email.example.com'}
puzzlers.each do |puz|
  devs[puz] = "#{puz.split.last.downcase}@puzzle.ch"
end

root = Group.root
devs.each do |name, email|
  seeder.seed_developer(name, email, root, Group::Bund::MitarbeiterGs)
end
