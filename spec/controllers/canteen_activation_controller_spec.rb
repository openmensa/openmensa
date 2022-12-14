# frozen_string_literal: true

require File.dirname(__FILE__) + "/../spec_helper"

describe CanteenActivationController, type: :controller do
  describe "#create" do
    subject { response }

    let(:canteen) { create(:canteen, state: "archived") }

    before do
      post :create, params: {canteen_id: canteen.id}
    end

    context "as anonymous" do
      its(:status) { is_expected.to eq 401 }
    end
  end

  describe "#destroy" do
    subject { response }

    let(:canteen) { create(:canteen) }

    before do
      delete :destroy, params: {canteen_id: canteen.id}
    end

    context "as anonymous" do
      its(:status) { is_expected.to eq 401 }
    end
  end
end
