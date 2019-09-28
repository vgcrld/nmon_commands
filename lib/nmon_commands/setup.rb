module NmonCommands
   SETUP      = File.dirname(__FILE__)
   LIB        = File.dirname(SETUP)
   HOME       = File.dirname(LIB)
   BIN        = File.join(HOME,'bin')
   TMP        = File.join(HOME,'tmp')

   FileUtils.mkdir(TMP)
end
