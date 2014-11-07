# Neighborly::Balanced::Bankaccount

[![Build Status](https://travis-ci.org/neighborly/neighborly-balanced-bankaccount.png?branch=jl-setup-test-env)](https://travis-ci.org/neighborly/neighborly-balanced-bankaccount) [![Code Climate](https://codeclimate.com/github/neighborly/neighborly-balanced-bankaccount.png)](https://codeclimate.com/github/neighborly/neighborly-balanced-bankaccount)

## What

This is an integration between [Balanced](https://www.balancedpayments.com/) and [Neighbor.ly Donate](https://github.com/neighborly/neighborly-donate), a crowdfunding platform.

## How

Include this gem as dependency of your project, adding the following line in your `Gemfile`.

```ruby
# Gemfile
gem 'neighborly-balanced-bankaccount'
```

Neighborly::Balanced::Bankaccount is a Rails Engine, integrating with your (Neighbor.ly Donate) Rails application with very little of effort. To turn the engine on, mount it in an appropriate route:

```ruby
# config/routes.rb
mount Neighborly::Balanced::Bankaccount::Engine => '/', as: 'neighborly_balanced_bankaccount'
```

And load our JavaScript:

```coffeescript
//= require neighborly-balanced-bankaccount
```

And install the engine:

```console
$ bundle exec rake railties:install:migrations db:migrate
```

### Load/Update Routing Numbers in database

We have a rake task to update the Routing Numbers from [fededirectory.frb.org](http://www.fededirectory.frb.org/fpddir.txt) with the Bank Name.

From your main app, just run:

`$ rake neighborly_balanced_bankaccount:update_routing_numbers`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Running specs

We prize for our test suite and coverage, so it would be great if you could run the specs to ensure that your patch is not breaking the existing codebase.

`bundle exec rspec`

## License

Licensed under the [MIT license](LICENSE.txt).
