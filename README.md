acts_as_aliased
===============

Extends `ActiveRecord::Base` with a mechanism to create aliases for resources.

Installation
------------

    gem 'acts_as_aliased'

After updating your bundle, run

    rails generate acts_as_aliased:install
    rake db:migrate

This will create a new table `aliases`.

Usage
-----

Let's say you have a model `Company` that requires aliasing because there are different versions of the company name. Enable
aliasing in your model by using `acts_as_aliased`:

    model Company < ActiveRecord::Base
      acts_as_aliased
    end

This assumes a column called `name` on your company model. You can specify a different column by passing a `column` argument:

   model Company < ActiveRecord::Base
     acts_as_aliased :column => 'title'
   end

An alias can be created manually like this:

    company = Company.create(name: "foo")
    ActsAsAliased.create(name: "bar", aliased: company)

But a more common use case is that you have two instances of a model and would like to convert one into an alias of the other. Say
you have these two companies:

    foo = Company.create(name: "Foo")
    foollc = Company.create(name: "Foo LLC")

Then you can convert one into an alias for the other like this:

    foo.to_alias!(foollc) # this will DESTROY foo and create a new alias for foollc in it's place

Now let's say you also have a model called `Project` and that a company has many projects:

    model Company < ActiveRecord::Base
      has_many :projects
    end

This implies a foreign key `company_id` in the `projects` table. When you convert a company into
an alias, you'll also want to update those foreign keys. You can accomplish this by passing the associations
to be updated to `acts_as_alias`:

    model Company < ActiveRecord::Base
      has_many :projects
      acts_as_aliased associations: [:projects]
    end

Finally, to find a model by it's alias, acts_as_aliased implements a `lookup` class method on your model:

    company = Company.create(name: "foo")
    ActsAsAliased.create(name: "bar", aliased: company)

    Company.lookup("foo")  # returns company
    Company.lookup("bar")  # also returns company


### Contributing to acts_as_aliased

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

### Copyright

Copyright (c) 2012 LegitScript. See LICENSE.txt for
further details.

