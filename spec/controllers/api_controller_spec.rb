# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe ApiController do
  controller(ApiController) do
    def index
      render nothing: true
    end
  end

  describe "#set_content_type" do
    context "on json format" do
      it "should set json content type" do
        get :index, format: 'json'
        response.content_type.should == 'application/json'
      end
    end

    context "on xml format" do
      it "should set xml content type" do
        get :index, format: 'xml'
        response.content_type.should == 'application/xml'
      end
    end

    context "on msgpack format" do
      it "should set msgpack content type" do
        get :index, format: 'msgpack'
        response.content_type.should == 'application/x-msgpack'
      end
    end

    context "on unsupported format" do
      it "should respond with http not acceptable" do
        get :index, format: 'bson'
        response.status.should == 406
      end
    end
  end
end
