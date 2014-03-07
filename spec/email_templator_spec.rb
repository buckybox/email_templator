require "simplecov"
SimpleCov.start
SimpleCov.minimum_coverage 100

require "email_templator"

class EmailTemplatorTest < EmailTemplator
  KEYWORDS = {
    first_name: :name,
    email: :email,
  }
end

class EmailTemplatorTestWithCustomDelimiters < EmailTemplatorTest
  DELIMITERS = %w(# #)
end

describe EmailTemplatorTest do
  subject { EmailTemplatorTest }

  describe "#valid?" do
    it "validates presence of required attributes" do
      template = subject.new "", ""

      template.should_not be_valid
      template.errors.join.should include "Subject", "Body", "blank"
    end

    it "validates absence of unknown attributes" do
      template = subject.new "Hey", "{nope}"

      template.should_not be_valid
      expect(template.errors).to eq ["Unknown keywords found: nope"]
    end
  end

  describe "#unknown_keywords" do
    it "returns unknown keywords" do
      template = subject.new "Hey {you}", <<-BODY
        Hi {first_name},

        Your are {age} years old!
      BODY

      template.unknown_keywords.should eq %w(you age)
    end
  end

  describe "#personalize" do
    it "replaces keywords" do
      customer = double(:customer,
        name: "Joe",
        email: "joe@example.net",
      )

      template = subject.new "Hi {first_name}", <<-BODY
        Hey {first_name}!

        Here's your email: {email}
      BODY

      personalized_email = template.personalize(customer)
      personalized_email.subject.should eq "Hi Joe"
      personalized_email.body.should eq <<-BODY
        Hey Joe!

        Here's your email: joe@example.net
      BODY
    end
  end

  describe ".keywords_with_delimiters" do
    it "returns a list of keywords for use in views" do
      expect(subject.keywords_with_delimiters).to eq %w({email} {first_name})
    end
  end
end

describe EmailTemplatorTestWithCustomDelimiters do
  subject { EmailTemplatorTestWithCustomDelimiters }

  specify { expect(subject.keywords_with_delimiters).to eq %w(#email# #first_name#) }
end

