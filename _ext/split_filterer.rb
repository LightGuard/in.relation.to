# Generic version of Tagger
module Awestruct
  module Extensions
    # Filter out a set of split values (like tags).
    # Values are outputted in system out as warning
    # and removed from the post.
    # This extension must be placed right after the Post extension in the
    # pipeline
    class SplitFilterer
      # split_items_property: property containing the posts
      # split_property: name of the property to split by
      # denied_splits: array of string values forbidden
      def initialize(split_items_property, split_property, denied_splits, opts={})
        @split_items_property = split_items_property
        @split_property = split_property
        @denied_splits = Array( denied_splits )
        @sanitize = opts[:sanitize] || false
        @pagination_opts = opts
      end

      def execute(site)
        @splits ||= {}
        all = site.send( @split_items_property )
        return if ( all.nil? || all.empty? ) 

        plural_split_property =  @split_property

        all.each do |page|
          splits = page.send( @split_property )
          if ( splits && ! splits.empty? )
            filtered_out_splits = splits.find_all { |split| @denied_splits.include? split.to_s }
            splits.each do |elt|
              if @denied_splits.include? elt.to_s
                puts ">>>> WARNING: tag '#{elt.to_s}' is illegal, remove it from: #{page.relative_source_path}"
              end
            end
            filtered_splits = splits.find_all { |split| not (@denied_splits.include? split.to_s) }
            page.send( "#{@split_property}=", filtered_splits )
          end
        end
      end
    end
  end
end
