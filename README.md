Chef Dashboard: A Small HUD for Your Chef Resources and Nodes.
--------------------------------------------------------------------------------

This is a (very simple) heads-up-display for your nodes. You can see an example
in action [here](http://home.hollensbe.org).

It solves a few problems:

* Helps you keep tabs on what nodes are failing and why they're failing.
* Keeps you in the loop on how many nodes you have running, how many haven't
  reported in at a variety of increments.
* Reports resource groupings -- this can assist with identifying non-idempotent
  recipes and providers, e.g., a large batch of nodes is executing the same
  thing every time.

Installing
--------------------------------------------------------------------------------

You can do a couple of things here:

* [here](http://github.com/erikh/chef-chef-dashboard) is a cookbook that will do
  most of the work for you. Consider it beta at the time of this writing. :)
* Alternatively you can do is fork the project and do what's below:

Creating Capistrano configuration to deploy this application should be cake and
should follow a normal deployment pattern. This app should be cooperative with
any rack-capable server with `bundle exec` support, internal or external,
although it already has support to run under `unicorn`. Since configuration of
capistrano is out of scope for this project and tends to vary by environment, I
will leave it as an exercise for the reader.

You may need to run the `bin/create_database` script manually, which should
dump a `dashboard.db` in your project's root directory. Future support for
other databases is planned, but sqlite3 has served my purpose with excellent
performance on initial testing with around 10k reports and 100 nodes, which
should be more than enough for small to midsize environments.

You will want to extract the [chef dashboard handler](https://github.com/erikh/chef-chef-dashboard/blob/master/templates/default/chef_dashboard_handler.rb)
to make full effectiveness of the HUD (or write your own). This installs as
both an exception and reporting handler in your `/etc/chef/client.rb`. You can
use schisamo's wonderful [chef handler provider](https://github.com/opscode-cookbooks/chef_handler)
to drive this installation.

Payload Details
--------------------------------------------------------------------------------

Sending data to the `/report` handler is pretty simple. The payload is just
JSON data and should be relatively easy to populate from anything that uses
Chef as a framework.

If you look in [int/test.json](https://github.com/erikh/chef-dashboard/blob/master/int/test.json)
you will see what a payload looks like:

* node `fqdn`, `name`, and `ipaddress` as string.
* `success` boolean value.
* `resources` array of string.

These are sent in a `PUT` query as `application/json`. The appropriate response
is a `200 OK` and empty json object (e.g., `{}`).

The Future
--------------------------------------------------------------------------------

More plans will be expressed in a TODO file in the future. I want this project
to improve on its basic features, and gradually become a complete reporting
solution for Chef-enabled networks. No plans to make it
[cloudkick](http://www.cloudkick.com) or
[sensu](https://github.com/sonian/sensu). If you need those, use them.  KISS.

Contributing
--------------------------------------------------------------------------------

* Fork the project
* Make your edits
* Do not modify any LICENSE or CREDITS files, or similar data. If you have
  concerns about being credited for your work, say so in the pull request.
* Send a pull request.

Author
--------------------------------------------------------------------------------

Erik Hollensbe <erik+chef@hollensbe.org>
