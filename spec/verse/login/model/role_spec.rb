# frozen_string_literal: true

RSpec.describe Verse::Login::Role::Repository, type: :repository do
  before do
    Verse::Login::Role::Repository.data&.clear
  end

  context "correct data" do
    before do
      allow(Verse::Login::Config).to receive(:role_definition_path).and_return("spec/spec_data/roles/correct")
      allow(Verse::Login::Config).to receive(:role_definition_template_path).and_return("spec/spec_data/roles/correct/_templates")
    end

    it "load the roles" do
      Verse::Login::Role::Repository.load

      expect(Verse::Login::Role::Repository.data).not_to be_empty
    end
  end

end
