# Generic version of Tagger
module Awestruct
  module Extensions
    class Splitter

      class SplitStat
        attr_accessor :pages
        attr_accessor :group
        attr_accessor :primary_page
        def initialize(split, pages)
          @split = split
          @pages = pages
        end

        def to_s
          @split
        end
      end

      module SplitLinker
        def split_links(delimiter = ', ', style_class = nil)
          class_attr = (style_class ? ' class="' + style_class + '"' : '')
          splits.map{|split| %Q{<a#{class_attr} href="#{split.primary_page.url}">#{split}</a>}}.join(delimiter)
        end
      end

      def initialize(split_items_property, split_property, input_path, output_path, opts={})
        @split_items_property = split_items_property
        @split_property = split_property
        @input_path  = input_path
        @output_path = output_path
        @sanitize = opts[:sanitize] || false
        @pagination_opts = opts
      end

      def execute(site)
        @splits ||= {}
        all = site.send( @split_items_property )
        return if ( all.nil? || all.empty? ) 

        all.each do |page|
          splits = page.send( @split_property )
          if ( splits && ! splits.empty? )
            splits = Array(splits)
            splits.each do |split|
              split = split.to_s
              @splits[split] ||= SplitStat.new( split, [] )
              @splits[split].pages << page
            end
          end
        end

        all.each do |page|
          page.send( "#{@split_property}=", ( Array( page.send( @split_property ) ) ).collect{|t| @splits[t]} )
          page.extend( SplitLinker )
        end

        ordered_splits = @splits.values
        ordered_splits.sort!{|l,r| -(l.pages.size <=> r.pages.size)}
        #ordered_splits = ordered_splits[0,100]
        ordered_splits.sort!{|l,r| l.to_s <=> r.to_s}

        min = 9999
        max = 0

        ordered_splits.each do |split|
          min = split.pages.size if ( split.pages.size < min )
          max = split.pages.size if ( split.pages.size > max )
        end

        span = max - min
        
        if span > 0
          slice = span / 6.0
          ordered_splits.each do |split|
            adjusted_size = split.pages.size - min
            scaled_size = adjusted_size / slice
            split.group = (( split.pages.size - min ) / slice).ceil
          end
        else
          ordered_splits.each do |split|
            split.group = 0
          end
        end

        @splits.values.each do |split|
          ## Optionally sanitize split URL
          output_prefix = File.join( @output_path, sanitize(split.to_s) )
          options = { :remove_input=>false, :output_prefix=>output_prefix, :collection=>split.pages }.merge( @pagination_opts )
          
          paginator = Awestruct::Extensions::Paginator.new( @split_items_property, @input_path, options )
          primary_page = paginator.execute( site )
          split.primary_page = primary_page
        end

        site.send( "#{@split_items_property}_#{@split_property}=", ordered_splits )
      end

      def sanitize(string)
        #replace accents with unaccented version, go lowercase and replace and space with dash
        if @sanitize
          string.to_s.urlize({:convert_spaces=>true})
        else
          string
        end
      end
    end
  end
end
