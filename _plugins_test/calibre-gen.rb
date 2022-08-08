# frozen_string_literal: true

require "json"
require "tmpdir"
require "securerandom"
require "time"
require "digest"

module Jekyll
  module Library
    class Generator < Jekyll::Generator
      safe true
      priority :low

      # Main plugin action, called by Jekyll-core
      def generate(site)
        @site = site
        @config = @site.config["library"] || {}
        @logger_prefix = "[jekyll-library]"

        if ! @config.key? "cover_folder"
          log("error", "No cover folder defined in configuration!")
          return;
        end

        pages = get_page_list(@config["pages"] || false, @config["collections"] || [])

        with_cache { |cache|
          pages.each do |page|
            isbn = page.data["isbn"]

            metadata = cache.fetch(isbn) { cache[isbn] = get_book_info(isbn) }

            page.data["image"] = File.join(@site.config["baseurl"], metadata["cover"]["url"])
            page.data["book"] = metadata
          end
        }
      end

      private

      def log(type, message)
        debug = !!@config.dig("debug")

        if debug || %w(error msg).include?(type)
          type = "info" if type == "msg"

          Jekyll.logger.method(type).call("#{@logger_prefix} #{message}")
        end
      end

      def with_cache(&block)
        cache = {}

        block.call(cache)
      end

      def get_page_list(include_pages, collections)
        pages = []

        pages += @site.pages if (include_pages)

        pages += @site
          .collections
          .values
          .find_all { |collection| collections.include? collection.label }
          .map { |collection| collection.docs }
          .flatten

        pages.select { |p| p.data.key? "isbn" }
      end

      def get_cover_path(id)
        cover_folder = @site.in_source_dir(@config["cover_folder"])
        Dir.mkdir(cover_folder) unless File.exist?(cover_folder)

        fname = id + ".jpg"

        return {
          "abs" => Jekyll.sanitized_path(cover_folder, fname),
          "url" => File.join(@config["cover_folder"], fname)
        }
      end

      def get_book_info(isbn)
        metadata = { "cover" => get_cover_path(isbn) }

        plugins = @config["plugins"]

        Dir.mktmpdir { |dir|
          output = File.join(dir, "output.json")
          cover = File.join(dir, "cover.jpg")

          args = [ "calibredb" ]
          args += [ "list" ]
          args += [ "-s", "isbn:#{ isbn }" ]
          args += [ "-f", "all" ]
          args += [ "--for-machine" ]

          system(*args, :err => File::NULL, :out => [output, "w"])

          meta = (File.open(output) { |f| JSON.load(f) }).first

          if (! meta.nil?)
            ids = meta["identifiers"]

            metadata["title"] = meta["title"]
            metadata["authors"] = meta["authors"]
            metadata["description"] = meta["comments"]
            metadata["publisher"] = meta["publisher"]
            metadata["date"] = meta["pubdate"]
            metadata["stars"] = meta["rating"] / 2 if (meta.key? "rating")
            metadata["series"] = meta["series"] if (meta.key? "series")
            metadata["series_index"] = meta["series_index"] if (meta.key? "series_index")
            metadata["uri"] = ids["uri"] if (ids.key? "uri")
            metadata["author_uri"] = ids["authoruri"] if (ids.key? "authoruri")
            metadata["series_uri"] = ids["seriesuri"] if (ids.key? "seriesuri")

            # Only get a copy of the cover if the Calibre version is different from
            # the one we have.

            md5_source = Digest::MD5.hexdigest(IO::read(meta["cover"]));

            if File.file?(metadata["cover"]["abs"])
              md5_target = Digest::MD5.hexdigest(IO::read(metadata["cover"]["abs"]));
            else
              md5_target = ""
            end

            IO::copy_stream(meta["cover"], metadata["cover"]["abs"]) if (md5_source != md5_target);
          end

          metadata
        }
      end
    end
  end
end