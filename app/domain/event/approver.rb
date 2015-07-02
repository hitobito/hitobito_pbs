# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# Approver contains all the business logic for the approval process.
class Event::Approver

  attr_reader :participation

  def initialize(participation)
    @participation = participation
  end

  def application_created
    # gemäss 4.101
    # return if no approval required
    # create Event::Approval for first layer from which approval is required
    # send email to all roles from affected layer(s) with permission :approve_applications
  end

  def approve(layer, comment, user)
    # gemäss 4.103, 4.108
    # find Event::Approval for given layer
    # update fields
    # if no next layer, set application#approved to true and return
    # create Event::Approval for next layer from which approval is required
    # send email to all roles from affected layer(s) with permission :approve_applications
  end

  def reject(layer, user)
    # gemäss 4.1010
    # find Event::Approval for given layer
    # update fields
    # set application#rejected to true
  end

end