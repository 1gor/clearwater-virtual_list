# Clearwater::VirtualList

Render a virtual list of Clearwater components where list items outside of the visible area of the page are not rendered. They are inserted just in time while scrolling and removed when they are no longer visible.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clearwater-virtual_list'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clearwater-virtual_list

## Usage

Inside your Clearwater app:

```ruby
require 'clearwater/component'
require 'clearwater/virtual_list'

class MyList
  include Clearwater::Component
  
  def initialize(items: [], list_style:, item_style:)
    # VirtualList will give you the items to render within the viewport
    @items = items
    
    # Make sure you set your list container's style property to this value
    @list_style = list_style
    
    # Make sure the list items' styles are set with this
    @item_style = item_style
  end
  
  def render
    ul({ style: @list_style }, @items.map { |item|
      li({ style: @item_style }, [
        # ...
      ])
    })
  end
end

# Define the virtual list component in terms of your regular list component
MyVirtualList = Clearwater::VirtualList.create do |items:, list_style:, item_style:|
  MyList.new(
    items: items,
    list_style: list_style,
    item_style: item_style,
  )
end
```

Use the `items` and `item_height` keyword arguments to the component when using it:

```ruby
class Layout
  include Clearwater::Component

  def render
    div([
      h1('My list of things'),
      MyVirtualList.new(
        items: all_the_things, # The full list of items
        item_height: 100,      # The height of each item in pixels
      ),
    ])
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/clearwater-rb/clearwater-virtual_list. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Clearwater::VirtualList project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/clearwater-rb/clearwater-virtual_list/blob/master/CODE_OF_CONDUCT.md).
