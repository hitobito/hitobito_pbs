require 'spec_helper'

describe Event::KindsController do
  before { sign_in(people(:bulei)) }

  it 'POST create accepts documents_text' do
    post :create, event_kind: { label: 'Foo',
                                documents_text: '<b>bar</b>' }

    kind = assigns(:kind)
    expect(kind.reload.documents_text).to eq '<b>bar</b>'
  end

end
