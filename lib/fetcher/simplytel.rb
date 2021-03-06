module Fetcher
  
  class Simplytel < Base
    
    START = 'https://www.simplytel.de/'
    
    def login
      page  = get(START)
      form  = page.forms.first
      form.credential_0 = @account.username
      form.credential_1 = @account.password
      
      # Einloggen
      page = @agent.submit(form)
      
      # Login fehlgeschlagen?
      raise LoginException unless page.uri.to_s.ends_with?('/index3.php')
    end
    
    def list
      # Link zur Rechnungsübersicht
      page = get('/rechnungonline.php?action=rechnung24&unteraction=uebersicht&sehen=Alle+Rechnungen+anzeigen')
      
      invoices = []
      
      for row in page.search("select[name=datum]/option")
        
        number = row["value"].to_s
        date   = Date.parse(row.text)
        
        invoices << build_invoice(
          :href   => "/phppdfdrillisch.php?dt=RECH&datum=#{number}&unterunteraction=ConvertDoc",
          :number => date.to_s.gsub('-',''),
          :date   => date
        )
      end
      
      invoices
    end
    
    def logout
      get('/frei/logout.pl')
    end
    
  end
  
end