module Fetcher
  
  class Binlayer < Base
    
    START = 'http://binlayer.com/'
    
    def list
      page  = @agent.get(START)
      form  = page.forms.find{|f|f.action =~ /login/ }
      form.username = @account.username
      form.passwort = @account.password
      
      # Einloggen
      page = form.submit
      
      # Login fehlgeschlagen?
      raise LoginException if page.uri.path == '/login.html'
      
      # Rechnungsübersicht aufrufen
      page = @agent.get('/konto-auszahlungen.html')
      
      invoices = []
      
      for row in page.search("table/tr")
        
        cells = row.search("td")
        next if cells.empty?
        
        link = row.search("a").first
        next if !link || link['href'] !~ /pdf/
        
        invoices << build_invoice(
          :href   => link['href'],
          :number => cells[0].text,
          :date   => Date.parse(cells[1].text),
          :amount => extract_amount(cells[2].text)
        )
      end
      
      invoices
    end
    
  end
  
end