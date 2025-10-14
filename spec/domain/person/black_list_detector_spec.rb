#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Person::BlackListDetector do
  let(:detector) { Person::BlackListDetector.new(person) }
  let(:person) {
    Person.create(first_name: "foo",
      last_name: "bar",
      email: "foo@bar.com")
  }

  subject { detector.occures? }

  it "does not occure if none matching attributes" do
    is_expected.to be false
  end

  it "occures if same first and last name" do
    Fabricate(:black_list, first_name: "foo", last_name: "bar")
    is_expected.to be true
  end

  it "does not occure if only same frist_name" do
    Fabricate(:black_list, first_name: "foo")
    is_expected.to be false
  end

  it "does not occure if only same last_name" do
    Fabricate(:black_list, last_name: "bar")
    is_expected.to be false
  end

  it "occures if same email" do
    Fabricate(:black_list, email: "foo@bar.com")
    is_expected.to be true
  end

  it "occures if same pbs_number" do
    person.update(pbs_number: "000-111-222")
    Fabricate(:black_list, pbs_number: "000-111-222")
    is_expected.to be true
  end

  it "occures if any phone_number matches" do
    number1 = Fabricate(:phone_number, number: "+41 44 345 67 89")
    number2 = Fabricate(:phone_number, number: "+41 77 123 45 67")
    person.update(phone_numbers: [number1, number2])

    Fabricate(:black_list, phone_number: "+41 44 345 67 89")

    is_expected.to be true
  end

  context "strip phone numbers" do
    it "removes all none digits and takes the last 9 chars" do
      numbers = detector.send(:strip_numbers,
        ["+a1b2b3 45 67 89+", "+32 98 765 43 21", "wrong-format"])
      expect(numbers).to include("123456789")
      expect(numbers).to include("987654321")
      expect(numbers).not_to include("wrong-format")
      expect(numbers.count).to eq(2)
    end

    it "does not match if less than 9 numbers" do
      numbers = detector.send(:strip_numbers, ["123 45 67 8"])
      expect(numbers).to be_blank
    end
  end
end
