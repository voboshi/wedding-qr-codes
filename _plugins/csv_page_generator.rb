require 'csv'
require 'digest'
require 'base64'

module Jekyll
  class CsvPage < Page
    attr_reader :url_safe_hash
    
    def initialize(site, base, dir, guest_data)
      @site = site
      @base = base
      @dir = dir
      
      # Generate URL-safe hash from the name
      hash = Digest::SHA256.digest(guest_data['NAME'])
      @url_safe_hash = Base64.urlsafe_encode64(hash).tr('=', '')[0..15]  # Take first 16 chars for shorter URLs
      @name = "#{@url_safe_hash}.html"
      
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'guest.html')
      
      self.data['title'] = guest_data['NAME']
      self.data['guest'] = guest_data
      self.data['layout'] = 'guest'
    end
  end
  
  class CsvPageGenerator < Generator
    safe true

    def generate(site)
      csv_file = File.join(site.source, 'contents.csv')
      hash_csv_file = File.join(site.source, 'hash_names.csv')

      if File.exist?(csv_file)
        # First pass: build a lookup map of all guests
        guests_lookup = {}
        CSV.foreach(csv_file, headers: true) do |row|
          guest_data = row.to_h
          guests_lookup[guest_data['NAME'].strip] = guest_data
        end

        # Second pass: generate pages with enriched meeting data
        # Open hash_names.csv for writing
        CSV.open(hash_csv_file, 'w', headers: ['NAME', 'HASH', 'URL'], write_headers: true) do |hash_csv|
          CSV.foreach(csv_file, headers: true) do |row|
            guest_data = row.to_h

            # Enrich the MEET_OTHERS data
            if guest_data['MEET_OTHERS'] && !guest_data['MEET_OTHERS'].empty?
              # Parse comma-separated names
              names_to_meet = guest_data['MEET_OTHERS'].split(',').map(&:strip)

              # Build enriched data for each person they should meet
              enriched_meetings = names_to_meet.map do |name|
                other_guest = guests_lookup[name]
                if other_guest
                  {
                    'name' => name,
                    'connection' => other_guest['CONNECTION'],
                    'interests' => other_guest['INTERESTS']
                  }
                else
                  # If guest not found, just include the name
                  {
                    'name' => name,
                    'connection' => '',
                    'interests' => ''
                  }
                end
              end

              guest_data['enriched_meetings'] = enriched_meetings
            else
              guest_data['enriched_meetings'] = []
            end

            csv_page = CsvPage.new(site, site.source, '', guest_data)
            site.pages << csv_page

            # Write to hash_names.csv
            hash_csv << [
              guest_data['NAME'],
              csv_page.url_safe_hash,
              "https://qrs.bakers.house/#{csv_page.url_safe_hash}/"
            ]
          end
        end

        Jekyll.logger.info "Generated hash_names.csv with #{site.pages.length} entries"
      else
        Jekyll.logger.warn "CSV file not found at #{csv_file}"
      end
    end
  end
end