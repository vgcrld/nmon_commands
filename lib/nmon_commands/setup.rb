module NmonCommands
   SETUP      = File.dirname(__FILE__)
   LIB        = File.dirname(SETUP)
   HOME       = File.dirname(LIB)
   BIN        = File.join(HOME,'bin')
   TMP        = File.join(HOME,'tmp')
   VAR        = File.join(HOME,'var')

   FileUtils.mkdir_p(TMP)
   FileUtils.mkdir_p(VAR)
end
