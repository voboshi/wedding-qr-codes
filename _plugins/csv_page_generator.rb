require 'csv'
require 'digest'
require 'base64'

module Jekyll
  class CsvPage < Page
    def initialize(site, base, dir, guest_data)
      @site = site
      @base = base
      @dir = dir
      
      # Generate URL-safe hash from the name
      hash = Digest::SHA256.digest(guest_data['NAME'])
      url_safe_hash = Base64.urlsafe_encode64(hash).tr('=', '')[0..15]  # Take first 16 chars for shorter URLs
      @name = "#{url_safe_hash}.html"
      
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
      
      if File.exist?(csv_file)
        CSV.foreach(csv_file, headers: true) do |row|
          guest_data = row.to_h
          site.pages << CsvPage.new(site, site.source, '', guest_data)
        end
      else
        Jekyll.logger.warn "CSV file not found at #{csv_file}"
      end
    end
  end
end