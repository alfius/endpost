# Endpost

A wrapper library around Endicia's SOAP api.

## Instalation

```ruby
gem install endpost
```

## Usage

### Setup

```ruby
Endpost.test = true
Endpost.requester_id = 'lxxx'

# label server credentials
Endpost.account_id = '1234567'
Endpost.password = 'current_password'

# dial-a-zip credentials
Endpost.dial_a_zip_user = '123456'
Endpost.dial_a_zip_password = 'current_password'
```

### Change the pass phrase

```ruby
Endpost.change_pass_phrase('current_password', 'new_password')
```

### Generate a label

```ruby
response = Endpost.get_postage_label({
  :from => {
    :full_name => 'Alf Test',
    :address => '10B Glenlake Parkway, Suite 300',
    :city => 'Atlanta',
    :state => 'CA',
    :zip => '30328',
  },
  :to => {
    :full_name => 'Harry Whitehouse',
    :address => '247 High Street',
    :city => 'Palo Alto',
    :state => 'CA',
    :zip => '94301',
  },
  :weight => 16,
  :mail_class => 'Priority',
  :mailpiece_shape => 'Parcel',
  :sort_type => 'SinglePiece',
})

binary_pdf_label = Base64.decode64(response)
```

### Buy postage

```ruby
Endpost.buy_postage(10)
```

### Verify an address

```ruby
Endpost.verify_address({
  :full_name => 'Dymo Endicia',
  :address => '385 Sherman Avenue #1',
  :city => 'Palo Alto',
  :state => 'CA',
  :zip => '94306',
})
# => {
#  :full_name => 'DYMO ENDICIA',
#  :address => '385 SHERMAN AVE STE 1',
#  :city => 'PALO ALTO',
#  :state => 'CA',
#  :zip => '94306-1840',
# }
```

## Contributing

If you want to contribute to this project, just fork it and create a pull request. Also, feel free to report issues on the [issues section](issues).
Run tests with `rake test`. If you need to rebuild the cassettes use your own sandbox credentials and then change the credentials in the cassette manually.
