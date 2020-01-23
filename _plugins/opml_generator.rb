# Jekyll plugin for generating an opml feed for blogs from planet.yml
#
# Author: Maciej Paruszewski <maciek.paruszewski@gmail.com>
# Site: http://github.com/pinoss
#
# Distributed under the MIT license
# Copyright Maciej Paruszewski 2014

module Jekyll
  class OPMLFeed < Page; end

  class OPMLGenerator < Generator
    priority :low
    safe true

    def generate(site)
      generate_for_all(site)
      generate_for_categories(site)
      generate_for_tags(site)
      generate_for_tags_in_categories(site)
    end

    # Generates an opml feed
    #
    # site - the site
    #
    # Returns nothing
    def generate_for_all(site)
      require 'nokogiri'

      config_file = File.join(site.source, site.config['opml']['source'])
      all_blogs = read_blogs_from_config(config_file)
      categories = all_blogs.group_by { |blog| blog['categories'] }

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.opml(version: '1.1') {
          xml.head {
            xml.title site.config['opml']['title']
          }
          xml.body {
            xml.outline(text: site.config['opml']['outline']['text'], title: site.config['opml']['outline']['title']) {
              categories.each do |name, blogs|
                xml.outline(text: name, title: name) {
                  blogs.each do |blog|
                    xml.outline(
                      htmlUrl: blog['url'],
                      text: "#{blog['author']} - #{blog['title']}",
                      title: "#{blog['author']} - #{blog['title']}",
                      type: 'rss',
                      version: 'RSS',
                      xmlUrl: blog['feed']
                    )
                  end
                }
              end
            }
          }
        }
      end

      opml_path = site.config['opml']['path'] || '/'
      opml_name = site.config['opml']['name'] || 'feed.opml'
      full_path = File.join(site.dest, opml_path)
      ensure_directory(full_path)
      File.open("#{full_path}#{opml_name}", 'w') { |f| f.write(builder.to_xml) }

      site.pages << Jekyll::OPMLFeed.new(site, site.dest, opml_path, opml_name)
    end

    # Generates an opml feed
    #
    # site - the site
    #
    # Returns nothing
    def generate_for_categories(site)
      require 'nokogiri'

      config_file = File.join(site.source, site.config['opml']['source'])
      all_blogs = read_blogs_from_config(config_file)
      categories = all_blogs.group_by { |blog| blog['categories'] }

      categories.each do |name, blogs|
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.opml(version: '1.1') {
            xml.head {
              xml.title "Category: #{name} - #{site.config['opml']['title']}"
            }
            xml.body {
              xml.outline(text: site.config['opml']['outline']['text'], title: site.config['opml']['outline']['title']) {
                  xml.outline(text: name, title: name) {
                    blogs.each do |blog|
                      xml.outline(
                        htmlUrl: blog['url'],
                        text: "#{blog['author']} - #{blog['title']}",
                        title: "#{blog['author']} - #{blog['title']}",
                        type: 'rss',
                        version: 'RSS',
                        xmlUrl: blog['feed']
                      )
                    end
                  }
              }
            }
          }
        end

        category_dir = site.config['categories_dir'] || 'categories'

        opml_path = "#{category_dir}/#{name.downcase}/"
        opml_name = site.config['opml']['name'] || 'feed.opml'
        full_path = File.join(site.dest, opml_path)
        ensure_directory(full_path)
        File.open("#{full_path}#{opml_name}", 'w') { |f| f.write(builder.to_xml) }

        site.pages << Jekyll::OPMLFeed.new(site, site.dest, opml_path, opml_name)
      end
    end

    # Generates an opml feed
    #
    # site - the site
    #
    # Returns nothing
    def generate_for_tags(site)
      require 'nokogiri'

      config_file = File.join(site.source, site.config['opml']['source'])
      all_blogs = read_blogs_from_config(config_file)

      tags = {}
      site.tags.keys.each { |tag| tags[tag] = [] }

      tags_grouped = all_blogs.group_by { |blog| blog['tags'] }
      tags_grouped.each do |tag_names, blogs|
        tag_names.split.each do |name|
          if tags.key? name
            tags[name] += blogs
          else
            tags[name] = blogs
          end
        end
      end

      tags.each do |name, blogs|
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.opml(version: '1.1') {
            xml.head {
              xml.title "Tag: #{name} - #{site.config['opml']['title']}"
            }
            xml.body {
              xml.outline(text: site.config['opml']['outline']['text'], title: site.config['opml']['outline']['title']) {
                  xml.outline(text: name, title: name) {
                    blogs.each do |blog|
                      xml.outline(
                        htmlUrl: blog['url'],
                        text: "#{blog['author']} - #{blog['title']}",
                        title: "#{blog['author']} - #{blog['title']}",
                        type: 'rss',
                        version: 'RSS',
                        xmlUrl: blog['feed']
                      )
                    end
                  }
              }
            }
          }
        end

        tag_dir = site.config['tag_dir'] || 'tags'

        opml_path = "#{tag_dir}/#{name.downcase}/"
        opml_name = site.config['opml']['name'] || 'feed.opml'
        full_path = File.join(site.dest, opml_path)
        ensure_directory(full_path)
        File.open("#{full_path}#{opml_name}", 'w') { |f| f.write(builder.to_xml) }

        site.pages << Jekyll::OPMLFeed.new(site, site.dest, opml_path, opml_name)
      end
    end

    # Generates an opml feed
    #
    # site - the site
    #
    # Returns nothing
    def generate_for_tags_in_categories(site)
      require 'nokogiri'

      config_file = File.join(site.source, site.config['opml']['source'])
      all_blogs = read_blogs_from_config(config_file)
      
      categories = all_blogs.group_by { |blog| blog['categories'] }

      categories.each do |category, category_blogs|

        tags = {}
        tags_grouped = category_blogs.group_by { |blog| blog['tags'] }
        tags_grouped.each do |tag_names, blogs|
          tag_names.split.each do |name|
            if tags.key? name
              tags[name] += blogs
            else
              tags[name] = blogs
            end
          end
        end

        tags.each do |name, blogs|
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.opml(version: '1.1') {
              xml.head {
                xml.title "Category: #{category} / Tag: #{name} - #{site.config['opml']['title']}"
              }
              xml.body {
                xml.outline(text: site.config['opml']['outline']['text'], title: site.config['opml']['outline']['title']) {
                    xml.outline(text: name, title: name) {
                      blogs.each do |blog|
                        xml.outline(
                          htmlUrl: blog['url'],
                          text: "#{blog['author']} - #{blog['title']}",
                          title: "#{blog['author']} - #{blog['title']}",
                          type: 'rss',
                          version: 'RSS',
                          xmlUrl: blog['feed']
                        )
                      end
                    }
                }
              }
            }
          end
          category_dir = site.config['categories_dir'] || 'categories'
          tag_dir = site.config['tag_dir'] || 'tags'

          opml_path = "#{category_dir}/#{category.downcase}/#{tag_dir}/#{name}/"
          opml_name = site.config['opml']['name'] || 'feed.opml'
          full_path = File.join(site.dest, opml_path)
          ensure_directory(full_path)
          File.open("#{full_path}#{opml_name}", 'w') { |f| f.write(builder.to_xml) }

          site.pages << Jekyll::OPMLFeed.new(site, site.dest, opml_path, opml_name)
        end
      end
    end

    private

    def ensure_directory(path)
      FileUtils.mkdir_p(path)
    end

    def read_blogs_from_config(config_file_path)
      config = YAML.load_file(config_file_path)
      config.fetch('blogs', [])
    end
  end
end
