Tire.configure do
  # assign log4r's logger as rails' logger.
  log4r_config= YAML.load_file(File.join(File.dirname(__FILE__),"..","log4r.yml"))
  YamlConfigurator.decode_yaml( log4r_config['log4r_config'] )
  #logger STDERR
  #logger Log4r::Logger['tire']
  logger "log/tire.log"
end
