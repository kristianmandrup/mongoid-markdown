require 'spec_helper'

class Message
  include Mongoid::Document
  include Mongoid::Markdown

  field :body, :markdown => true
end

describe "MongoidMarkdown" do
  subject { Message.new :body => markdown_text }

  let(:markdown_text) { '## Hello world '}  

  describe '.markdown!' do
    before :each do
      subject.markdown!
    end

    it "should markup text" do
      subject.marked_down?.should be_true
      subject.body.should_not == markdown_text
    end
  end
end
