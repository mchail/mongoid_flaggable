mongoid_flaggable [![Gem Version](https://badge.fury.io/rb/mongoid_flaggable.png)](http://badge.fury.io/rb/mongoid_flaggable) [![Code Climate](https://codeclimate.com/github/mchail/mongoid_flaggable.png)](https://codeclimate.com/github/mchail/mongoid_flaggable) [![Build Status](https://travis-ci.org/mchail/mongoid_flaggable.png?branch=master)](https://travis-ci.org/mchail/mongoid_flaggable)
==============

mongoid_flaggable is a lightweight and powerful way to add flags/tags (boolean values) to your mongoid models.

# Installation

Install directly from rubygems:

```ruby
gem install mongoid_flaggable
```

Or if you are using a Gemfile, place this in your Gemfile:

```ruby
gem 'mongoid_flaggable'
```

# Use cases

This gem was created to give developers an easy way to flag mongoid models with boolean values. Flags are well-suited for temporary boolean values that do not merit the overhead of an additional field on the model and in the database. This includes gradual feature rollouts (whitelisting certain users for experimental features) and temporary metadata useful for analytics. Flags are *not* well-suited for data you intend to persist on your documents long-term.

# Configure a model to be flaggable

One line of code is needed to set up a model with mongoid_flaggable.

```ruby
class Book
    include Mongoid::Document
    include Mongoid::Flaggable         # it's this one
end
```

Be sure to run `rake db:mongoid:create_indexes` after adding mongoid_flaggable to a model. This will create an index on the `flag_array` field it makes use of.

# Basic usage

```ruby
book = Book.create
book.flags                             #=> []
book.add_flag!(:out_of_print)
book.flags                             #=> ["out_of_print"]
book.flag?(:out_of_print)              #=> true
book.flag?(:florinese_translation)     #=> false
book.remove_flag!(:out_of_print)
book.flags                             #=> []
```

# API

- All methods accept `"strings"` or `:symbols`. The arguments are cast to strings before being used.
- Methods that end in a `!` will immediately write to the database. Methods without the bang will make updates in memory (if the intention of the method is to update data), but will not persist the changes (i.e. after calling `book.add_flag(:out_of_print)`, you must call `book.save` to persist the new flag).

### Instance Methods

Add a flag to a specific model **without saving**

```ruby
book.add_flag(:out_of_print)
```

Add a flag to a specific model **and save immediately**

```ruby
book.add_flag!(:out_of_print)
```

Remove a flag from a specific model **without saving**

```ruby
book.remove_flag(:out_of_print)
```

Remove a flag from a specific model **and save immediately**

```ruby
book.remove_flag!(:out_of_print)
```

Clear all flags from a specific model **without saving**

```ruby
book.clear_flags
```

Clear all flags from a specific model **and save immediately**

```ruby
book.clear_flags!
```

Get array of flags from a model - guaranteed to return an array or zero or more strings

```ruby
book.flags   # => ["out_of_print"]
```

Test for the presence of a flag

```ruby
book.flag?(:out_of_print)
```

Test for the presence of **any** of multiple flags

```ruby
book.any_flags?(:out_of_print, :florinese_translation)
```

Test for the presence of **all** of multiple flags

```ruby
book.all_flags?(:out_of_print, :florinese_translation)
```

### Class Methods

- All finders return a `Mongoid::Criteria` that may be chained with additional clauses (e.g. `where`, `limit`, `skip`, `order_by`, etc.)

Retrieve documents with a given flag

```ruby
Book.by_flag(:out_of_print)
```

Retrieve documents with **any** of multiple flags

```ruby
Book.by_any_flags(:out_of_print, :florinese_translation)
```

Retrieve documents with **all** of multiple flags

```ruby
Book.by_all_flags(:out_of_print, :florinese_translation)
```

Get the number of documents with a given flag

```ruby
Book.flag_count(:out_of_print)
```

Get the number of documents with **all** of multiple flags

```ruby
Book.flag_count(:out_of_print, :florinese_translation)
```

Get an array of all the distinct flags in use on the collection

```ruby
Book.distinct_flags
```

Add a flag to multiple documents matching given criteria

```ruby
Book.bulk_add_flag!(:out_of_print, {:last_printed_at.lt => 20.years.ago})
```
	
Remove a flag from multiple documents matching given criteria

```ruby
Book.bulk_remove_flag!(:out_of_print, {author_name: "William Goldman"})
```

Remove a flag from all documents

```ruby
Book.bulk_remove_flag!(:out_of_print)
```

Get a sorted frequency hash of all flags used on a collection

```ruby
Book.flag_frequency           #=> {"out_of_print" => 20, "florinese_translation" => 5}
```

# Contributing

1. Fork it
2. Make your changes
3. Write/update tests. Run with `rake`.
4. Issue a Pull Request

# License

MIT. Go nuts.
