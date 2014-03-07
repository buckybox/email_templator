# EmailTemplator

Sanitize and parse an user-generated email template for sending.

## Usage

```ruby
# 1. Define an email template class which can be personalized for a given resource (e.g. a customer)
class CustomerEmailTemplate < EmailTemplator

  # white-list mapping of keywords to be replaced
  KEYWORDS = {
    first_name:            :first_name,
    account_balance:       :account_balance_with_currency,
    email_address:         :email,
  }

end

# 2. Create the template
template = CustomerEmailTemplate.new "Hi {first_name}", <<-BODY
Hey {first_name}!

Here's your email: {email_address}
BODY

template.valid? #=> true

# 3. Create a personalized email from the template
customer = OpenStruct.new(first_name: "Joe", email: "joe@example.net") # typically a model
personalized_email = template.personalize(customer)
personalized_email.subject #=> "Hi Joe"
personalized_email.body #=> "Hey Joe!\n\nHere's your email: joe@example.net\n"

# 4. Send emails!
```

