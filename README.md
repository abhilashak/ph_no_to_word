# Phone number to word

  `ph_no_to_word` allows given 10 character phone number to convert into a word that is contained in a dictionary.
  The phone number should not contain 0 or 1. The matching words contain atleast 3 characters.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ph_no_to_word'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ph_no_to_word


## Usage
After installing the gem goto

```ruby
irb(main):001:0> require 'ph_no_to_word'
=> true
irb(main):002:0> PhNoToWord::convert "2282668687"
Results:
* act, amounts
* act, boo, tots
* act, boo, tour
* act, boot, mus
* act, boot, nus
* act, boot, our
* act, con, tots
* act, con, tour
* act, contour
.......
.......
* cat, con, tour
* cat, contour
* cat, coo, tots
* cat, coo, tour
* cat, coot, mus
* cat, coot, nus
* cat, coot, our
* catamounts
```

```ruby
irb(main):004:0> PhNoToWord::convert '6686787825'
* mot, opt, puck
* mot, opt, ruck
* mot, opt, suck
* mot, opts, taj
* mot, opus, taj
* mot, ort, puck
* mot, ort, ruck
* mot, ort, suck
.......
.......
```

## Contributing

Bug reports and pull requests are welcome on Github at https://github.com/abhilashak/ph_no_to_word. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PhNoToWord project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ph_no_to_word/blob/master/CODE_OF_CONDUCT.md).
