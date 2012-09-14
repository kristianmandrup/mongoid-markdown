require 'rdiscount'

Mongoid::Fields.option :markdown do |model,field,options|
  options = {} unless options.kind_of?(Hash)

  attribute = field.name.to_sym

  model.class_eval do
    (self.markdown_attributes ||= []) << attribute

    define_method(attribute) do |*type|
      type = type.first
      value = read_attribute(attribute)

      if type.nil? && value
        marked_down[attribute] ||= RDiscount.new(value).to_html.html_safe
      elsif type.nil? && value.nil?
        nil
      elsif type_options.include?(type.to_s)
        send("#{attribute}_#{type}")
      else
        raise "I don't understand the `#{type}' option.  Try #{type_options.join(' or ')}."
      end
    end

    define_method("#{attribute}_plain",  proc { strip_markdown_html(__send__(attribute)) if __send__(attribute) } )
    define_method("#{attribute}_source", proc { read_attribute(attribute) } )
  end  
end

module Mongoid
  module Markdown
    extend ActiveSupport::Concern

    included do
      # attr_accessor :geo
      cattr_accessor :markdown_attributes
      @@markdown_attributes = []

      self.send :include, InstanceMethods
    end

    def marked_down
      marked_down? ? (@marked_down ||= {}) : @attributes.dup
    end

    def marked_down?
      @is_marked_down != false
    end

    def marked_down=(value)
      @is_marked_down = !!value
    end

    def markdown!
      self.class.markdown_attributes.each { |attr| __send__(attr) }
    end

    def reload
      marked_down.clear
      super
    end

    def write_attribute(attr_name, value)
      marked_down[attr_name.to_s] = nil
      super
    end

    module InstanceMethods
      private

      def strip_markdown_html(html)
        returning html.dup.gsub(html_regexp, '') do |h|
          markdown_glyphs.each do |(entity, char)|
            sub = [ :gsub!, entity, char ]
            @textiled_unicode ? h.chars.send(*sub) : h.send(*sub)
          end
        end
      end

      def markdown_glyphs
        [[ '&#8217;', "'" ], 
         [ '&#8216;', "'" ],
         [ '&lt;', '<' ], 
         [ '&gt;', '>' ], 
         [ '&#8221;', '"' ],
         [ '&#8220;', '"' ],            
         [ '&#8230;', '...' ],
         [ '\1&#8212;', '--' ], 
         [ ' &rarr; ', '->' ], 
         [ ' &#8211; ', '-' ], 
         [ '&#215;', 'x' ], 
         [ '&#8482;', '(TM)' ], 
         [ '&#174;', '(R)' ],
         [ '&#169;', '(C)' ]]
      end

      def html_regexp
        %r{<(?:[^>"']+|"(?:\\.|[^\\"]+)*"|'(?:\\.|[^\\']+)*')*>}xm
      end
    end    
    
    module ClassMethods
      def markdown(*attributes)        
        @markdown_unicode = String.new.respond_to? :chars

        type_options = %w( plain source )

        attributes.each do |attribute|
          define_method(attribute) do |*type|
            type = type.first
            value = read_attribute(attribute)

            if type.nil? && value
              marked_down[attribute.to_sym] ||= RDiscount.new(value).to_html.html_safe
            elsif type.nil? && value.nil?
              nil
            elsif type_options.include?(type.to_s)
              send("#{attribute}_#{type}")
            else
              raise "I don't understand the `#{type}' option.  Try #{type_options.join(' or ')}."
            end
          end

          define_method("#{attribute}_plain",  proc { strip_markdown_html(__send__(attribute)) if __send__(attribute) } )
          define_method("#{attribute}_source", proc { read_attribute(attribute) } )
        end

        include InstanceMethods
      end
    end
  end
end