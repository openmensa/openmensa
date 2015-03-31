# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe ApiController, type: :controller do
  controller(ApiController) do
    def index
      render text: 'NOTHING'
    end
  end

  describe '#set_content_type' do
    context 'on json format' do
      it 'should set json content type' do
        get :index, format: 'json'
        expect(response.content_type).to eq 'application/json'
      end
    end

    context 'on xml format' do
      it 'should set xml content type' do
        get :index, format: 'xml'
        expect(response.content_type).to eq 'application/xml'
      end
    end

    context 'on msgpack format' do
      it 'should set msgpack content type' do
        get :index, format: 'msgpack'
        expect(response.content_type).to eq 'application/x-msgpack'
      end
    end

    context 'on unsupported format' do
      it 'should respond with http not acceptable' do
        get :index, format: 'bson'
        expect(response.status).to eq 406
      end
    end
  end
end
