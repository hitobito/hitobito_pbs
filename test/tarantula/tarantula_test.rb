# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'test_helper'
require 'relevance/tarantula'
require 'tarantula/tarantula_config'

class TarantulaTest < ActionDispatch::IntegrationTest
  # Load enough test data to ensure that there's a link to every page in your
  # application. Doing so allows Tarantula to follow those links and crawl
  # every page.  For many applications, you can load a decent data set by
  # loading all fixtures.

  reset_fixture_path File.expand_path('../../../spec/fixtures', __FILE__)

  include TarantulaConfig

  def test_tarantula_as_bundesleitung
    crawl_as(people(:bulei))
  end

  def test_tarantula_as_abteilungsleiter
    crawl_as(people(:al_schekka))
  end

  def test_tarantula_as_child
    crawl_as(people(:child))
  end

  private

  def configure_urls_with_pbs(t, person)
    configure_urls_without_pbs(t, person)

    # The parent entry may already have been deleted, thus producing 404s.
    t.allow_404_for(/groups\/\d+\/member_counts$/)

    # delete not allowed - not completely clarified - investigate later
    t.allow_500_for(/groups\/\d+\/events\/\d+\/roles\/\d+$/)
    # roles with invalid created_at and deleted_at values may generate 500 :(
    t.allow_500_for(/groups\/\d+\/roles(\/\d+)?$/)
  end
  alias_method_chain :configure_urls, :pbs

end
