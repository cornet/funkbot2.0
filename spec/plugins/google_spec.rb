require "spec_helper"
require "./plugins/google.rb"

describe Google do
  describe "search" do
    it "should return a result that includes a URL" do
      Google.search("cows").should =~ /^.* : https?:\/\/.*$/
    end
  end
end
