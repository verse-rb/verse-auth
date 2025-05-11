# frozen_string_literal: true

require "spec_helper"

RSpec.describe Verse::Login::LoginStrategy::SimpleLogin do
  let(:auth_context) { double("auth_context") }
  let(:user_repository) { double("user_repository") }
  let(:password_strategy) { double("password_strategy") }
  let(:token_builder) { double("token_builder") }
  let(:user) { double("user") }
  let(:username) { "test_user" }
  let(:password) { "password123" }
  let(:encrypted_password) { "encrypted_password_hash" }
  let(:role) { "user_role" }
  let(:env) { { ip: "127.0.0.1" } }
  let(:auth_token_result) { double("auth_token_result") }

  subject { described_class.new(auth_context) }

  before do
    # Mock configuration
    allow(Verse::Login::Config).to receive(:user_column_username).and_return(:username)
    allow(Verse::Login::Config).to receive(:user_column_encrypted_password).and_return(:encrypted_password)
    allow(Verse::Login::Config).to receive(:password_strategy).and_return(password_strategy)
    allow(Verse::Login::Config).to receive(:wait_when_user_not_found).and_return(0.01)
    allow(Verse::Login::Config).to receive(:registerable).and_return(false)
    allow(Verse::Login::Config).to receive(:lockable).and_return(false)

    # Mock repository and user
    allow(subject).to receive(:user_repository).and_return(user_repository)
    allow(user).to receive(:send).with(:encrypted_password).and_return(encrypted_password)

    # Mock token builder
    allow(Verse::Login::TokenBuilder).to receive(:new).and_return(token_builder)
    allow(token_builder).to receive(:build).and_return(auth_token_result)
  end

  describe "#call" do
    context "with valid credentials" do
      before do
        allow(user_repository).to receive(:find_by!).and_return(user)
        allow(password_strategy).to receive(:check?).with(password, encrypted_password).and_return(true)
      end

      it "returns auth token when credentials are valid" do
        expect(subject.call(username, password, role: role, env: env)).to eq(auth_token_result)
      end

      it "passes the correct parameters to token builder" do
        expect(token_builder).to receive(:build).with(user, role, env: env, nonce: anything)
        subject.call(username, password, role: role, env: env)
      end
    end

    context "with invalid credentials" do
      before do
        allow(user_repository).to receive(:find_by!).and_return(user)
      end

      it "raises AuthenticationFailed when password is invalid" do
        allow(password_strategy).to receive(:check?).with(password, encrypted_password).and_return(false)
        expect { subject.call(username, password) }.to raise_error(Verse::Error::AuthenticationFailed)
      end
    end

    context "when user is not found" do
      before do
        allow(user_repository).to receive(:find_by!).and_raise(Verse::Error::RecordNotFound)
        allow(subject).to receive(:sleep)
      end

      it "waits and raises AuthenticationFailed" do
        expect(subject).to receive(:sleep).with(0.01)
        expect { subject.call(username, password) }.to raise_error(Verse::Error::AuthenticationFailed)
      end
    end
  end

  context "with registerable enabled" do
    before do
      allow(Verse::Login::Config).to receive(:registerable).and_return(true)
      allow(Verse::Login::Config).to receive(:verifiable_column).and_return(:verified_at)
      allow(user_repository).to receive(:find_by!).and_return(user)
      allow(password_strategy).to receive(:check?).with(password, encrypted_password).and_return(true)
    end

    it "checks if user is verified" do
      allow(user).to receive(:send).with(:verified_at).and_return(Time.now)
      expect(subject.call(username, password, role: role, env: env)).to eq(auth_token_result)
    end

    it "raises AccountNotVerified when user is not verified" do
      allow(user).to receive(:send).with(:verified_at).and_return(nil)
      expect { subject.call(username, password, role: role, env: env) }.to raise_error(Verse::Login::Error::AccountNotVerified)
    end
  end

  context "with lockable enabled" do
    before do
      allow(Verse::Login::Config).to receive(:lockable).and_return(true)
      allow(Verse::Login::Config).to receive(:lockable_column).and_return(:locked_at)
      allow(user_repository).to receive(:find_by!).and_return(user)
      allow(password_strategy).to receive(:check?).with(password, encrypted_password).and_return(true)
    end

    it "checks if user is not locked" do
      allow(user).to receive(:send).with(:locked_at).and_return(nil)
      expect(subject.call(username, password, role: role, env: env)).to eq(auth_token_result)
    end

    it "raises AccountLocked when user is locked" do
      allow(user).to receive(:send).with(:locked_at).and_return(Time.now)
      expect { subject.call(username, password, role: role, env: env) }.to raise_error(Verse::Login::Error::AccountLocked)
    end
  end

  context "with different configuration options" do
    it "uses custom username column" do
      custom_column = :email
      allow(Verse::Login::Config).to receive(:user_column_username).and_return(custom_column)
      allow(user_repository).to receive(:find_by!).with({ custom_column => username }).and_return(user)
      allow(password_strategy).to receive(:check?).with(password, encrypted_password).and_return(true)

      expect(subject.call(username, password, role: role, env: env)).to eq(auth_token_result)
    end

    it "uses custom encrypted password column" do
      custom_column = :hashed_password
      allow(Verse::Login::Config).to receive(:user_column_encrypted_password).and_return(custom_column)
      allow(user_repository).to receive(:find_by!).and_return(user)
      allow(user).to receive(:send).with(custom_column).and_return(encrypted_password)
      allow(password_strategy).to receive(:check?).with(password, encrypted_password).and_return(true)

      expect(subject.call(username, password, role: role, env: env)).to eq(auth_token_result)
    end

    it "uses custom password strategy" do
      custom_strategy = double("custom_strategy")
      allow(Verse::Login::Config).to receive(:password_strategy).and_return(custom_strategy)
      allow(user_repository).to receive(:find_by!).and_return(user)
      allow(custom_strategy).to receive(:check?).with(password, encrypted_password).and_return(true)

      expect(subject.call(username, password, role: role, env: env)).to eq(auth_token_result)
    end
  end
end
