module PhNoToWord
  module Logger
    # Log a PhNoToWord-specific line.
    def log(message)
      logger.info("[ph_no_to_word] #{message}") if logging?
    end
  end
end