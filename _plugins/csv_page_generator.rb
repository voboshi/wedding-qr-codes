require 'csv'

module Jekyll
  class CsvPage < Page
    def initialize(site, base, dir, guest_data)
      @site = site
      @base = base
      @dir = dir
      @name = "#{guest_data['NAME'].downcase.gsub(' ', '-')}.html"
      
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