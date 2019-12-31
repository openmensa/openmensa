# frozen_string_literal: true

require File.dirname(__FILE__) + '/../spec_helper'

describe ApiController, type: :controller do
  controller(described_class) do
    def index
      render json: []
    end
  end

  describe '#set_content_type' do
    context 'on json format' do
      it 'sets json content type' do
        get :index, format: 'json'
        expect(response.content_type).to eq 'application/json'
      end
    end

    context 'on xml format' do
      it 'sets xml content type' do
        get :index, format: 'xml'
        expect(response.content_type).to eq 'application/xml'
      end
    end

    context 'on msgpack format' do
      it 'sets msgpack content type' do
        get :index, format: 'msgpack'
        expect(response.content_type).to eq 'application/x-msgpack'
      end
    end

    context 'on unsupported format' do
      it 'responds with http not acceptable' do
        get :index, format: 'bson'
        expect(response.status).to eq 406
      end
    end
  end
end
