# encoding: utf-8
require "watir-webdriver"
require "yaml"

class NimbusBrowser < Watir::Browser
  attr_accessor :config
  
  def initialize(browser = :chrome, *args)
    parse_config
    super(browser, *args)
  end
  
  def goto(partial_uri = "")
    super(self.base_url+partial_uri)
  end
  
  def base_url
    "http://#{self.nimbus_ip}/"
  end
    
  def parse_config
      self.config = open('config.yml') {|f| YAML.load(f)}
      for k,v in self.config:
        create_attr k
        self.send "#{k}=", v
      end
  end
  
  def nimbus_login
    self.goto "session/login"
    self.auto_fill :nimbus_login
    self.button(:value => 'Acessar').click
  end
  
  def auto_fill(data_set_name)
    data_set = self.send data_set_name
    for type,data in fields: 
      self.fill(type, data)
    end
  end
  
  def fill(type, data)
    type = find_setter(type)
    for name,value in data:
      self.send "#{type}(:name => '#{name}').#{setter}", value
    end
  end

  def find_setter(type)
    case type
      when 'text_field'
        'set'
      when 'select_list'
        'select'
    end
  end  
  
  def create_method( name, &block )
       self.class.send( :define_method, name, &block )
   end

   def create_attr( name )
       create_method( "#{name}=".to_sym ) { |val| 
           instance_variable_set( "@" + name, val)
       }

       create_method( name.to_sym ) { 
           instance_variable_get( "@" + name ) 
       }
   end  
end