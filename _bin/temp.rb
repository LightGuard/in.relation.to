#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require_relative 'blog_entry'

require 'choice'
require 'anemone'
require 'pstore'

require 'nokogiri'
require 'date'
require 'fileutils'
require 'net/http'
require 'uri'
require 'cgi'

class Importer
  BASE_URL = "http://in.relation.to"

  def initialize(import_file, output_dir)
    @import_file = import_file
    @output_dir = output_dir
  end

  def import_posts
    posts = PStore.new(@import_file)
    posts.transaction(true) do  # begin read-only transaction, no changes allowed
      posts.roots.each do |post_url|
        puts "key: #{post_url}"
        puts "value: #{posts[post_url]}"
      end
    end
  end

  private

  def import_item(item_xml)
    type = item_xml.get_text( 'wp:post_type' )
    return if type == 'page'
    status = item_xml.get_text( 'wp:status' )
    return if status != 'publish'

    tags = Array.new
    item_xml.get_elements( 'category' ).each do |tag|
      value = tag.text
      if value != "Uncategorized"
        tags << value
      end
    end

    title = item_xml.get_text( 'title' ).to_s
    author = 'Emmanuel Bernard'
    link = item_xml.get_text( 'link' ).to_s

    if ( link =~ %r(/([^/]+)/$) )
      slug = $1
    end
    published = DateTime.parse( item_xml.get_text( 'pubDate' ).to_s )
    #content = REXML::Text.unnormalize( item_xml.get_text( 'content:encoded' ).to_s )
    content = item_xml.get_text( 'content:encoded' ).to_s
    in_pre = false
    p_content = ''
    content.each_line do |line|
      if ( line =~ /<pre>/ )
      in_pre = true
    end
    if ( line =~ /<\/pre>/ )
      in_pre = false
    end
    if ( in_pre || ( line =~ /^\s*</ ) )
      p_content << line
    elsif ( line.strip == '' )
      # nothing
    else
      p_content << "<p>#{line}</p>\n"
    end
  end
  content = p_content

  content = import_images( content )
  content = import_assets( content )

  output_path = File.join( @output_dir, published.strftime( "%Y-%m-%d-#{slug}.html.erb" ) )
  #if ( ! File.exist?( output_path ) )
  puts "writing post: #{output_path}"
  FileUtils.mkdir_p( File.dirname( output_path ) )
  File.open( output_path, 'w' ) do |f|
    #f.puts "date: #{published.year}-#{published.month}-#{published.day}"
    f.puts '---'
    f.puts "title: '#{title}'"
    f.puts "author: 'Emmanuel Bernard'"
    f.puts "layout: blog-post"
    f.puts "tags: [ #{tags.join(", ")} ]"
    f.puts '---'
    f.puts content
  end

  def import_images(content)
    #doc = REXML::Document.new( '<entry>' + CGI.escapeHTML( content ) + '</entry>' )
    doc = REXML::Document.new( '<entry>' + content + '</entry>' )
    REXML::XPath.each( doc, '//img' ) do |img|
      src = img.attributes['src']

      if ( src =~ /^\// )
        src = "http://blog.emmanuelbernard.com#{src}"
      else
        next
      end

      basename = File.basename( src )
      output_path = "posts/assets/#{basename}"

      url = URI.parse( src )

      res = Net::HTTP.start(url.host, url.port) {|http|
        http.get(url.path)
      }

      FileUtils.mkdir_p( File.dirname( output_path ) )
      puts "writing image: #{output_path}"
      File.open( output_path, 'wb' ) do |f|
        f.write res.body
      end

      img.attributes['src'] = "/#{output_path}"
    end
    content = ''
    doc.root.children.each do |c|
      content += c.to_s
    end
    content
  end


  def import_assets(content)
    doc = REXML::Document.new( '<entry>' + content + '</entry>' )
    REXML::XPath.each( doc, '//a' ) do |a|
      href = a.attributes['href']
      local = false
      if ( href =~ /^\// )
        href = "http://blog.emmanuelbernard.com#{href}"
        local = true
      end
      if ( local && href =~ /\.(pdf)$/ )
        basename = File.basename( href )
        output_path = "posts/assets/#{basename}"

        url = URI.parse( href )

        if ( ! File.exist?( output_path ) )
          puts "fetching: #{url}"
          FileUtils.mkdir_p( File.dirname( output_path ) )
          File.open( output_path, 'wb' ) do |f|
            Net::HTTP.start(url.host, url.port) do |http|
              http.get(url.path) do |str|
                f.write str
                $stderr.putc '.'
                $stderr.flush
              end
            end
          end
          puts "writing asset: #{output_path}"
        end

        a.attributes['href'] = "/#{output_path}"
      end

    end
    content = ''
    doc.root.children.each do |c|
      content += c.to_s
    end
    content

  end

