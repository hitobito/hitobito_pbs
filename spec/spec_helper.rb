# encoding: utf-8

#  Copyright (c) 2012-2013, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# Conditional Spork.prefork (this comment is needed to fool Spork's `bootstrapped?` check)
helper_kind =  /spork/i =~ $0  || (RSpec.respond_to?(:configuration) && RSpec.configuration.drb?) ? "spork" : "base"
require File.expand_path("../spec_helper_#{helper_kind}", __FILE__)
