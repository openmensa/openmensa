# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController, :type => :controller do
  describe '#create' do
    before do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:twitter]
    end

    it 'should create user from omniauth hash w/o info node' do
      request.env['omniauth.auth'] = {
        'provider' => 'test',
        'uid' => '123456',
        'credentials' => {
          'token' => '123456',
          'secret' => 'geheim'
        },
        'info' => nil
      }

      expect { get :create, provider: 'test' }.to change { User.all.count }.from(0).to(1)

      expect(response).to redirect_to(root_path)
    end

    it 'should redirect to back url' do
      get :create, provider: 'twitter', ref: '/mypath'

      expect(response).to redirect_to('/mypath')
    end

    it 'should only redirect to own host' do
      get :create, provider: 'twitter', ref: 'http://twitter.com/path'

      expect(response).to redirect_to('/')
    end
  end
end
