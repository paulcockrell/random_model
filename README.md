# random_model

Based on the gem 'randumb', random_model is a ruby gem that selects a random record via ActiveRecord for a model with much
greater speed than that of 'randumb'. This is beter suited to working with records sets in the millions

Requires ActiveRecord 3.0.0 or greater

## Usage

``` ruby
MyModel.random # returns a randomly selected instance of MyModel if there are any, otherwise nil
```

## Install 

``` ruby
# Add the following to you Gemfile
gem 'random_model'
# Update your bundle
bundle install
```
