# frozen_string_literal: true

#
#  Copyright (c) 2020-2022 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe GroupHealthController do
  let(:user) { people(:root) }
  let(:token) { ServiceToken.create(name: "Token", layer: groups(:bund)) }

  describe "authentication" do
    it "redirects to login" do
      get :people
      is_expected.to redirect_to "/users/sign_in"
    end
  end

  describe "unauthorized" do
    before { sign_in(people(:bulei)) }

    it "denies access" do
      expect { get :people }.to raise_error(CanCan::AccessDenied)
    end
  end

  describe "service-token" do
    context "with group_health" do
      before do
        token.update(group_health: true)
      end

      it "is authorized for non census evaluation endpoints" do
        request.headers["X-Token"] = token.token
        get :groups, format: :json
        expect(response).to have_http_status(200)
      end

      it "is unauthorized for census evaluation endpoint" do
        request.headers["X-Token"] = token.token
        get :census_evaluations, format: :json
        expect(response).to have_http_status(403)
      end
    end

    context "with census_evaluations" do
      before do
        token.update(census_evaluations: true)
      end

      it "is unauthorized for non census evaluation endpoints" do
        request.headers["X-Token"] = token.token
        get :groups, format: :json
        expect(response).to have_http_status(403)
      end

      it "is authorized for census evaluation endpoint" do
        request.headers["X-Token"] = token.token
        get :census_evaluations, format: :json
        expect(response).to have_http_status(200)
      end
    end

    context "with group_health and census_evaluations" do
      before do
        token.update(group_health: true, census_evaluations: true)
      end

      it "is authorized for non census evaluation endpoints" do
        request.headers["X-Token"] = token.token
        get :groups, format: :json
        expect(response).to have_http_status(200)
      end

      it "is authorized for census evaluation endpoint" do
        request.headers["X-Token"] = token.token
        get :census_evaluations, format: :json
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "authorized" do
    before { sign_in(user) }

    describe "GET show" do
      context "json" do
        it "is valid" do
          get :groups, format: :json
          json = JSON.parse(response.body)
          group = json["groups"].first
          expect(group["name"]).to eq(groups(:bund).name)
          expect(group["canton_id"]).to be_nil
        end
      end

      context "no opt-in" do
        it "does not export any people" do
          get :people, format: :json
          json = JSON.parse(response.body)
          expect(json["people"].size).to eq(0)
        end

        it "does not export any courses" do
          get :courses, format: :json
          json = JSON.parse(response.body)
          expect(json["courses"].size).to eq(0)
        end

        context "for abteilung" do
          it "exports census evaluations of current census year" do
            get :census_evaluations, format: :json
            abteilung_evaluations = evaluations_by_group_type(Group::Abteilung)
            expect(abteilung_evaluations.size).to eq(3)
            abteilung_evaluation = abteilung_evaluations.find { |a| a["abteilung_id"] == groups(:schekka).id }
            expect(abteilung_evaluation).to be_present
            expect(abteilung_evaluation["kantonalverband_id"]).to eq(groups(:be).id)
            expect(abteilung_evaluation["region_id"]).to eq(groups(:bern).id)
            expect(abteilung_evaluation["abteilung_id"]).to eq(groups(:schekka).id)

            expect(abteilung_evaluation.keys.size).to eq(10)
            expect(abteilung_evaluation["f"].size).to eq(7)
            expect(abteilung_evaluation["m"].size).to eq(7)
            expect(abteilung_evaluation["f"]["leiter"]).to eq(2)
            expect(abteilung_evaluation["m"]["leiter"]).to eq(3)
            expect(abteilung_evaluation["f"]["pfadis"]).to eq(4)
            expect(abteilung_evaluation["m"]["pfadis"]).to eq(3)
            expect(abteilung_evaluation["group_type"]).to eq(Group::Abteilung.sti_name)
            expect(abteilung_evaluation["group_id"]).to eq(groups(:schekka).id)
            expect(abteilung_evaluation["group_name"]).to eq(groups(:schekka).name)
            expect(abteilung_evaluation["parent_id"]).to eq(groups(:schekka).parent_id)

            expect(abteilung_evaluation["total"]["total"]).to eq(12)
            expect(abteilung_evaluation["total"]["f"]).to eq(6)
            expect(abteilung_evaluation["total"]["m"]).to eq(6)
          end

          it "exports census evaluations of given year" do
            get :census_evaluations, params: {year: "2013"}, format: :json
            abteilung_evaluations = evaluations_by_group_type(Group::Abteilung)
            expect(abteilung_evaluations).to be_empty
          end
        end

        context "for Kantonalverband" do
          it "exports census evaluations" do
            get :census_evaluations, format: :json
            kantonalverband_evaluations = evaluations_by_group_type(Group::Kantonalverband)
            expect(kantonalverband_evaluations.size).to eq(2)
            kantonalverband_evaluation = kantonalverband_evaluations.find { |a| a["kantonalverband_id"] == groups(:be).id }
            expect(kantonalverband_evaluation["kantonalverband_id"]).to eq(groups(:be).id)
            expect(kantonalverband_evaluation["region_id"]).to eq(groups(:bern).id)
            expect(kantonalverband_evaluation["abteilung_id"]).to eq(groups(:schekka).id)

            expect(kantonalverband_evaluation.keys.size).to eq(10)
            expect(kantonalverband_evaluation["f"].size).to eq(7)
            expect(kantonalverband_evaluation["m"].size).to eq(7)
            expect(kantonalverband_evaluation["f"]["leiter"]).to eq(3)
            expect(kantonalverband_evaluation["m"]["leiter"]).to eq(5)
            expect(kantonalverband_evaluation["f"]["pfadis"]).to eq(5)
            expect(kantonalverband_evaluation["m"]["pfadis"]).to eq(6)
            expect(kantonalverband_evaluation["group_type"]).to eq(Group::Kantonalverband.sti_name)
            expect(kantonalverband_evaluation["group_id"]).to eq(groups(:be).id)
            expect(kantonalverband_evaluation["group_name"]).to eq(groups(:be).name)
            expect(kantonalverband_evaluation["parent_id"]).to eq(groups(:be).parent_id)

            expect(kantonalverband_evaluation["total"]["total"]).to eq(19)
            expect(kantonalverband_evaluation["total"]["f"]).to eq(8)
            expect(kantonalverband_evaluation["total"]["m"]).to eq(11)
          end

          it "exports census evaluations of given year" do
            get :census_evaluations, params: {year: "2013"}, format: :json
            kantonalverband_evaluations = evaluations_by_group_type(Group::Kantonalverband)
            expect(kantonalverband_evaluations).to be_empty
          end
        end

        context "for region" do
          it "exports census evaluations" do
            get :census_evaluations, format: :json
            region_evaluations = evaluations_by_group_type(Group::Region)
            expect(region_evaluations.size).to eq(2)
            region_evaluation = region_evaluations.find { |a| a["region_id"] == groups(:bern).id }
            expect(region_evaluation["kantonalverband_id"]).to eq(groups(:be).id)
            expect(region_evaluation["region_id"]).to eq(groups(:bern).id)
            expect(region_evaluation["abteilung_id"]).to eq(groups(:schekka).id)

            expect(region_evaluation.keys.size).to eq(10)
            expect(region_evaluation["f"].size).to eq(7)
            expect(region_evaluation["m"].size).to eq(7)
            expect(region_evaluation["f"]["leiter"]).to eq(2)
            expect(region_evaluation["m"]["leiter"]).to eq(3)
            expect(region_evaluation["f"]["pfadis"]).to eq(4)
            expect(region_evaluation["m"]["pfadis"]).to eq(3)
            expect(region_evaluation["group_type"]).to eq(Group::Region.sti_name)
            expect(region_evaluation["group_id"]).to eq(groups(:bern).id)
            expect(region_evaluation["group_name"]).to eq(groups(:bern).name)
            expect(region_evaluation["parent_id"]).to eq(groups(:bern).parent_id)

            expect(region_evaluation["total"]["total"]).to eq(12)
            expect(region_evaluation["total"]["f"]).to eq(6)
            expect(region_evaluation["total"]["m"]).to eq(6)
          end

          it "exports census evaluations of given year" do
            get :census_evaluations, params: {year: "2013"}, format: :json
            region_evaluations = evaluations_by_group_type(Group::Region)
            expect(region_evaluations).to be_empty
          end
        end
      end

      context "opt-in" do
        context "for abteilung" do
          before do
            groups(:schekka).update(group_health: true)
          end

          it "does export the group having opted in" do
            get :groups, format: :json
            json = JSON.parse(response.body)
            groups = json["groups"].select { |g| g["name"] == groups(:schekka).name }
            expect(groups.size).to eq(1)
            group = groups.first
            expect(group.keys).to match_array(%w[id parent_id type name created_at deleted_at canton_id canton_name])
            expect(group["canton_id"]).to eq(groups(:be).id)
          end

          it "does not export internes Gremium" do
            intern_group = Group::InternesAbteilungsGremium.create!(name: "Internes Gremium",
              parent: groups(:schekka))

            get :groups, format: :json
            json = JSON.parse(response.body)
            groups = json["groups"].select { |g| g["name"] == intern_group.name }
            expect(groups).to be_empty
          end

          it "does only export people with roles in a group having opted in" do
            get :people, format: :json
            json = JSON.parse(response.body)
            people = json["people"]
            expect(people.size).to eq(2)
            person = people.first
            expect(person.keys).to match_array(%w[id pbs_number town zip_code country gender birthday entry_date leaving_date primary_group_id name address])
          end

          it "does only export camps with participants having roles in a group having opted in" do
            get :camps, format: :json
            json = JSON.parse(response.body)
            expect(json["camps"].size).to eq(1)
            expect(json["camps"][0]["name"]).to eq(events(:schekka_camp).name)
          end

          it "does paginate" do
            Role.create(group: groups(:schekka), person: people(:bulei),
              type: Group::Abteilung::Sekretariat.sti_name)
            get :participations, params: {size: 3}, format: :json
            json = JSON.parse(response.body)
            expect(json["participations"].size).to eq(3)
            get :participations, params: {page: 2, size: 3}, format: :json
            json = JSON.parse(response.body)
            expect(json["participations"].size).to eq(2)
          end

          it "exports census evaluations of current census year" do
            get :census_evaluations, format: :json
            abteilung_evaluations = evaluations_by_group_type(Group::Abteilung)
            expect(abteilung_evaluations.size).to eq(3)
            abteilung_evaluation = abteilung_evaluations.find { |a| a["abteilung_id"] == groups(:schekka).id }
            expect(abteilung_evaluation).to be_present
            expect(abteilung_evaluation["kantonalverband_id"]).to eq(groups(:be).id)
            expect(abteilung_evaluation["region_id"]).to eq(groups(:bern).id)
            expect(abteilung_evaluation["abteilung_id"]).to eq(groups(:schekka).id)

            expect(abteilung_evaluation.keys.size).to eq(10)
            expect(abteilung_evaluation["f"].size).to eq(7)
            expect(abteilung_evaluation["m"].size).to eq(7)
            expect(abteilung_evaluation["f"]["leiter"]).to eq(2)
            expect(abteilung_evaluation["m"]["leiter"]).to eq(3)
            expect(abteilung_evaluation["f"]["pfadis"]).to eq(4)
            expect(abteilung_evaluation["m"]["pfadis"]).to eq(3)
            expect(abteilung_evaluation["group_type"]).to eq(Group::Abteilung.sti_name)
            expect(abteilung_evaluation["group_id"]).to eq(groups(:schekka).id)
            expect(abteilung_evaluation["group_name"]).to eq(groups(:schekka).name)
            expect(abteilung_evaluation["parent_id"]).to eq(groups(:schekka).parent_id)

            expect(abteilung_evaluation["total"]["total"]).to eq(12)
            expect(abteilung_evaluation["total"]["f"]).to eq(6)
            expect(abteilung_evaluation["total"]["m"]).to eq(6)
          end

          it "exports census evaluations of given year" do
            get :census_evaluations, params: {year: "2013"}, format: :json
            abteilung_evaluations = evaluations_by_group_type(Group::Abteilung)
            expect(abteilung_evaluations).to be_empty
          end
        end

        context "for Kantonalverband" do
          before do
            groups(:be).update(group_health: true)
          end

          it "does export the group having opted in" do
            get :groups, format: :json
            json = JSON.parse(response.body)
            groups = json["groups"].select { |g| g["name"] == groups(:be).name }
            expect(groups.size).to eq(1)
            group = groups.first
            expect(group.keys).to match_array(%w[id parent_id type name created_at deleted_at canton_id canton_name])
            expect(group["canton_id"]).to eq(groups(:be).id)
          end

          it "does not export internes Gremium" do
            intern_group = Group::InternesAbteilungsGremium.create!(name: "Internes Gremium",
              parent: groups(:schekka))

            get :groups, format: :json
            json = JSON.parse(response.body)
            groups = json["groups"].select { |g| g["name"] == intern_group.name }
            expect(groups).to be_empty
          end

          it "does only export people with roles in a group having opted in" do
            get :people, format: :json
            json = JSON.parse(response.body)
            expect(json["people"].size).to eq(1)
          end

          it "does only export camps with participants having roles in a group having opted in" do
            get :camps, format: :json
            json = JSON.parse(response.body)
            expect(json["camps"].size).to eq(1)
            expect(json["camps"][0]["name"]).to eq(events(:be_camp).name)
          end

          it "does paginate" do
            Role.create(group: groups(:be), person: people(:bulei),
              type: Group::Kantonalverband::Sekretariat.sti_name)
            get :participations, params: {size: 3}, format: :json
            json = JSON.parse(response.body)
            expect(json["participations"].size).to eq(3)
            get :participations, params: {page: 2, size: 3}, format: :json
            json = JSON.parse(response.body)
            expect(json["participations"].size).to eq(1)
          end

          it "exports census evaluations" do
            get :census_evaluations, format: :json
            kantonalverband_evaluations = evaluations_by_group_type(Group::Kantonalverband)
            expect(kantonalverband_evaluations.size).to eq(2)
            kantonalverband_evaluation = kantonalverband_evaluations.find { |a| a["kantonalverband_id"] == groups(:be).id }
            expect(kantonalverband_evaluation["kantonalverband_id"]).to eq(groups(:be).id)
            expect(kantonalverband_evaluation["region_id"]).to eq(groups(:bern).id)
            expect(kantonalverband_evaluation["abteilung_id"]).to eq(groups(:schekka).id)

            expect(kantonalverband_evaluation.keys.size).to eq(10)
            expect(kantonalverband_evaluation["f"].size).to eq(7)
            expect(kantonalverband_evaluation["m"].size).to eq(7)
            expect(kantonalverband_evaluation["f"]["leiter"]).to eq(3)
            expect(kantonalverband_evaluation["m"]["leiter"]).to eq(5)
            expect(kantonalverband_evaluation["f"]["pfadis"]).to eq(5)
            expect(kantonalverband_evaluation["m"]["pfadis"]).to eq(6)
            expect(kantonalverband_evaluation["group_type"]).to eq(Group::Kantonalverband.sti_name)
            expect(kantonalverband_evaluation["group_id"]).to eq(groups(:be).id)
            expect(kantonalverband_evaluation["group_name"]).to eq(groups(:be).name)
            expect(kantonalverband_evaluation["parent_id"]).to eq(groups(:be).parent_id)

            expect(kantonalverband_evaluation["total"]["total"]).to eq(19)
            expect(kantonalverband_evaluation["total"]["f"]).to eq(8)
            expect(kantonalverband_evaluation["total"]["m"]).to eq(11)
          end

          it "exports census evaluations of given year" do
            get :census_evaluations, params: {year: "2013"}, format: :json
            kantonalverband_evaluations = evaluations_by_group_type(Group::Kantonalverband)
            expect(kantonalverband_evaluations).to be_empty
          end
        end

        context "for region" do
          before do
            groups(:bern).update(group_health: true)
          end

          it "does export the group having opted in" do
            get :groups, format: :json
            json = JSON.parse(response.body)
            groups = json["groups"].select { |g| g["name"] == groups(:bern).name }
            expect(groups.size).to eq(1)
            group = groups.first
            expect(group.keys).to match_array(%w[id parent_id type name created_at deleted_at canton_id canton_name])
            expect(group["canton_id"]).to eq(groups(:be).id)
          end

          it "does not export internes Gremium" do
            intern_group = Group::InternesAbteilungsGremium.create!(name: "Internes Gremium",
              parent: groups(:schekka))

            get :groups, format: :json
            json = JSON.parse(response.body)
            groups = json["groups"].select { |g| g["name"] == intern_group.name }
            expect(groups).to be_empty
          end

          it "does only export people with roles in a group having opted in" do
            get :people, format: :json
            json = JSON.parse(response.body)
            expect(json["people"].size).to eq(1)
          end

          it "does only export camps with participants having roles in a group having opted in" do
            get :camps, format: :json
            json = JSON.parse(response.body)
            expect(json["camps"].size).to eq(1)
            expect(json["camps"][0]["name"]).to eq(events(:bern_camp).name)
          end

          it "exports census evaluations" do
            get :census_evaluations, format: :json
            region_evaluations = evaluations_by_group_type(Group::Region)
            expect(region_evaluations.size).to eq(2)
            region_evaluation = region_evaluations.find { |a| a["region_id"] == groups(:bern).id }
            expect(region_evaluation["kantonalverband_id"]).to eq(groups(:be).id)
            expect(region_evaluation["region_id"]).to eq(groups(:bern).id)
            expect(region_evaluation["abteilung_id"]).to eq(groups(:schekka).id)

            expect(region_evaluation.keys.size).to eq(10)
            expect(region_evaluation["f"].size).to eq(7)
            expect(region_evaluation["m"].size).to eq(7)
            expect(region_evaluation["f"]["leiter"]).to eq(2)
            expect(region_evaluation["m"]["leiter"]).to eq(3)
            expect(region_evaluation["f"]["pfadis"]).to eq(4)
            expect(region_evaluation["m"]["pfadis"]).to eq(3)
            expect(region_evaluation["group_type"]).to eq(Group::Region.sti_name)
            expect(region_evaluation["group_id"]).to eq(groups(:bern).id)
            expect(region_evaluation["group_name"]).to eq(groups(:bern).name)
            expect(region_evaluation["parent_id"]).to eq(groups(:bern).parent_id)

            expect(region_evaluation["total"]["total"]).to eq(12)
            expect(region_evaluation["total"]["f"]).to eq(6)
            expect(region_evaluation["total"]["m"]).to eq(6)
          end

          it "exports census evaluations of given year" do
            get :census_evaluations, params: {year: "2013"}, format: :json
            region_evaluations = evaluations_by_group_type(Group::Region)
            expect(region_evaluations).to be_empty
          end
        end
      end
    end
  end

  def evaluations_by_group_type(type)
    json = JSON.parse(response.body)
    json["census_evaluations"]["groups"].select { |g| g["group_type"] == type.sti_name }
  end
end
