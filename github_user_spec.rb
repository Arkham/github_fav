require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end

require_relative 'github_user'

describe GithubUser do
  let(:name) { "Arkham" }
  let(:user) { described_class.new(name) }

  context "#favourite_language" do
    it "guesses Ruby as favourite language" do
      VCR.use_cassette('user_repos') do
        expect(user.favourite_language).to eq("Ruby")
      end
    end

    context "user not found" do
      let(:name) { "HappyDragonHippo" }

      it "raises an exception" do
        VCR.use_cassette('user_not_found') do
          expect { user.favourite_language }.to raise_error(GithubUser::UserNotFound)
        end
      end
    end
  end
end
