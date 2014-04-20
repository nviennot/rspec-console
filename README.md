RSpec Console
=============

RSpec Console allows you to run your RSpec tests in a Rails console.
Best served chilled with [irb-config](https://github.com/nviennot/irb-config).

### Watch the screencast

[![Watch the screencast!](https://s3.amazonaws.com/velvetpulse/screencasts/irb-config-screencast.jpg)](http://velvetpulse.com/2012/11/19/improve-your-ruby-workflow-by-integrating-vim-tmux-pry/)

Usage
------

Install it with:

```ruby
gem 'rspec-console'
```

Ensure you turned off Rails's `cache_classes` in the config/environment/test.rb file.

```ruby
Rails.application.configure do
  # turn off this!
  conig.cache_classes = false
end
```

If you have [Pry](https://github.com/pry/pry) installed, you will have access to the `rspec` command
in your console, which works exactly like the shell command line rspec one.


```
# Launch Rails console with test environment!
pafy@bisou ~/prj/sniper [master●] % rails c test
~/prj/crowdtap/sniper (test) > rspec spec/integration/closing_brand_action_spec.rb:33 --format=doc
Run options: include {:locations=>{"./spec/integration/closing_brand_action_spec.rb"=>[33]}}

Sniper
  when reaching the maximum number of participants
    no longer targets this brand action on members

Finished in 0.12654 seconds
1 example, 0 failures
~/prj/crowdtap/sniper (test) >
```

If you don't have pry, you can use:

```ruby
RSpecConsole.run 'spec/integration/closing_brand_action_spec.rb:33' '--format=doc'
```

TODO
----

* Testing

License
-------

MIT License
