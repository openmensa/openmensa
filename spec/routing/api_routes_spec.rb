require 'spec_helper'

describe 'API routing within' do
  context '/api/v1' do
    let(:base) { '/api/v1' }

    it 'should route /cafeterias to v1 cafeterias#index' do
      expect(:get => "#{base}/cafeterias").to route_to(
        :controller => 'api/v1/cafeterias',
        :action => 'index',
        :format => 'json'
      )
    end

    it 'should route /cafeterias/:id to v1 cafeterias#show' do
      expect(:get => "#{base}/cafeterias/5").to route_to(
        :controller => 'api/v1/cafeterias',
        :action => 'show',
        :format => 'json',
        :id => '5'
      )
    end

    it 'should route /cafeterias/:id/meals to v1 meals#index' do
      expect(:get => "#{base}/cafeterias/5/meals").to route_to(
        :controller => 'api/v1/meals',
        :action => 'index',
        :format => 'json',
        :cafeteria_id => '5'
      )
    end
  end

  context '/api/v2' do
    let(:base) { '/api/v2' }

    it 'should route /canteens to v2 canteen#index' do
      expect(:get => "#{base}/canteens").to route_to(
        :controller => 'api/v2/canteens',
        :action => 'index',
        :format => 'json'
      )
    end

    it 'should route /canteens/:id to v2 canteens#show' do
      expect(:get => "#{base}/canteens/1").to route_to(
        :controller => 'api/v2/canteens',
        :action => 'show',
        :format => 'json',
        :id => '1'
      )
    end

    it 'should route /canteens/:id/meals to v2 meals#index' do
      expect(:get => "#{base}/canteens/1/meals").to route_to(
        :controller => 'api/v2/meals',
        :action => 'index',
        :format => 'json',
        :canteen_id => '1'
      )
    end
  end
end
