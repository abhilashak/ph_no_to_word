class PhNoToWord
  # PhNoToWord::Error is raised when it's caused by wrong usage of PhNoToWord classes. Those
  # errors have their backtrace suppressed and are nicely shown to the user.
  #
  # Errors that are caused by the developer, like declaring a method which
  # overwrites a PhNoToWord keyword, SHOULD NOT raise a PhNoToWord::Error. This way, we
  # ensure that developer errors are shown with full backtrace.
  class Error < StandardError
  end

  # Raised when a command was not found.
  class UndefinedCommandError < Error
  end

  class UnknownArgumentError < Error
  end

  class RequiredArgumentMissingError < InvocationError
  end

  class MalformattedArgumentError < InvocationError
  end
end