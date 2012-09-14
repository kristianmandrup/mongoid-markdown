# Mongoid Markdown

Add Markdown functionality to any Mongoid object.

```ruby

class Message
  include Mongoid::Document
  include Mongoid::Markdown

  field :body, :markdown => true
end

message = Message.new :body => "## Hello world"

message.marked_down? # => false

message.markdown!

message.marked_down? # => true

puts message.body # => "<h2>Hello world</h2>"

message.body = "## Goodbye cruel world..."

message.reload # not sure about this!

message.marked_down? # => true
```

Enjoy!

Extracted from: https://github.com/baphled/chat-engine/blob/master/lib/mongoid/markdown.rb

See specs for more usage examples

Should work on both Mongoid pre 2.4 and later, including 3.x. 

Please help fix any bugs or come with suggestions to improvements.

## Contributing to mongoid-markdown
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2012 Kristian Mandrup. See LICENSE.txt for
further details.

