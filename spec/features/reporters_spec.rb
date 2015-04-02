# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'Canteen', type: :feature do
  let(:canteen)  { FactoryGirl.create :canteen }
  let(:canteens) { [canteen] + (0..25).map { FactoryGirl.create :canteen } }

  it 'should be able to register a intereseted canteen' do
  end

  it 'shoulb be able to see list of interested canteens' do
  end

  it 'should be able to report an issues for a canteen' do
  end

  it 'shoulb be able to report correct canteen meta data' do
  end
end
