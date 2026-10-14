# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CSRF protection" do
  let(:canteen) { create(:canteen) }
  let(:params) { {feedback: {message: "Dies ist ein sehr langes Nutzerfeedback!"}} }

  # Forgery protection is disabled in the test environment by default.
  around do |example|
    previous = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = previous
  end

  it "rejects form submissions without a valid authenticity token" do
    expect { post "/c/#{canteen.id}/feedbacks", params: }.not_to change(Feedback, :count)

    expect(response).to have_http_status(:unprocessable_content)
  end

  it "accepts form submissions with a valid authenticity token" do
    get "/c/#{canteen.id}/feedbacks/new"
    token = response.parsed_body.at_css("meta[name=csrf-token]")[:content]

    expect do
      post "/c/#{canteen.id}/feedbacks", params: params.merge(authenticity_token: token)
    end.to change(Feedback, :count).by(1)
  end
end
