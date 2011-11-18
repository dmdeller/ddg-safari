#!/usr/bin/ruby -w

class DDGSafariSetup

  COCOA_DIALOG = './CocoaDialog.app/Contents/MacOS/CocoaDialog'
  
  HOSTS_DDG_IP = '127.0.0.1'
  HOSTS_HOSTNAME = 'search.yahoo.com'
  HOSTS_TAG = 'Automatically added by DuckDuckGo Safari Setup app'
  
  HOSTS_LINE = "#{HOSTS_DDG_IP} #{HOSTS_HOSTNAME} # #{HOSTS_TAG}"
  HOSTS_LINE_SHORT = "#{HOSTS_DDG_IP} #{HOSTS_HOSTNAME}"
  
  HOSTS_FILE = '/etc/hosts'
  
  
  def initialize(command)
  
    if (command == 'install') then
    
      install
      
    elsif (command == 'uninstall') then
    
      uninstall
      
    else
    
      welcome
      
    end
  
  end
  
  
  def welcome
    
    header = 'DuckDuckGo Safari Setup: READ CAREFULLY'
    info = "This app will replace the Yahoo search in your Safari browser with DuckDuckGo. Your administrator password will be required.
    
You will no longer be able to access Yahoo search from any browser on this computer; you can still access other Yahoo sites. If you change your mind, simply run this app again to uninstall.

For wizards only: This is just going to add an entry to your
/etc/hosts file. You can do it yourself if you'd prefer:
#{HOSTS_LINE_SHORT}"
    
    button_clicked = `#{COCOA_DIALOG} msgbox --button1 Quit --button2 Install --button3 Uninstall --text "#{header}" --informative-text "#{info}"`.to_i
    
    if (button_clicked == 2) then
      
      execAsAdmin('install')
      
    elsif (button_clicked == 3) then
    
      execAsAdmin('uninstall')
    
    else
    
      exit
      
    end
    
  end
  
  
  def install
    
    begin
      
      file = File.new(HOSTS_FILE, 'a+')
      file << "\n"
      file << "#{HOSTS_LINE}\n"
      
      info = 'Installation successful.'
      detail = 'Please quit and reopen Safari for changes to take effect.'
      `#{COCOA_DIALOG} msgbox --button1 OK --text "#{info}" --informative-text "#{detail}"`
      
    rescue
    
      info = 'Installation failed.'
      detail = 'The file /etc/hosts could not be accessed.'
      `#{COCOA_DIALOG} msgbox --button1 OK --text "#{info}" --informative-text "#{detail}"`
    
    end
    
  end
  
  
  def uninstall
  
    begin
      
      new_lines = []
      matches = 0
      
      file = File.new(HOSTS_FILE, 'r')
      
      file.each do |line|
      
        if (line.match(/#{HOSTS_TAG}/)) then
        
          matches += 1
          
        else
        
          new_lines.push(line)
        
        end
      
      end
      
      if (matches > 0) then
        
        file = File.new(HOSTS_FILE, 'w')
        
        new_lines.each do |line|
        
          file << line
        
        end
        
        info = 'Uninstallation successful.'
        detail = 'Please quit and reopen Safari for changes to take effect.'
        `#{COCOA_DIALOG} msgbox --button1 OK --text "#{info}" --informative-text "#{detail}"`
      
      else
      
        info = 'There was nothing to uninstall.'
        `#{COCOA_DIALOG} msgbox --button1 OK --text "#{info}"`
      
      end
      
    rescue
    
      info = 'Uninstallation failed.'
      detail = 'The file /etc/hosts could not be accessed.'
      `#{COCOA_DIALOG} msgbox --button1 OK --text "#{info}" --informative-text "#{detail}"`
    
    end
  
  end
  
  
  def execAsAdmin(command)
    
    shell_script = "'" + $0 + "' " + command
    applescript = 'do shell script \"' + shell_script + '\" with administrator privileges'
  
    result = `osascript -e "#{applescript}"`
  
  end

end

app = DDGSafariSetup.new(ARGV[0])
