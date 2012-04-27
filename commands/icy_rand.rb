﻿#=========================================#
# // Random
#=========================================#
# // Created by IceDragon (IceDragon200)
#=========================================#
module IrcBot
  module IrcCommands::IcyCommands
    # klik - Is a one click stopwatch
    Scarlet.hear /klik/i, :registered do
      n = ::IrcBot::IrcCommands::IcyCommands.klik.round(2)
      reply format("KLIK! %0.2f %s", n, (n == 1 ? "sec" : "secs"))
    end
    def self.klik
      @klik ||= [Time.now,Time.now]
      @klik[0] = Time.now - @klik[1]
      @klik[1] = Time.now
      @klik[0]
    end
    # time - Prints the current owners time
    Scarlet.hear /time/i, :registered do
      reply Time.now
    end
    # hb <name> - Prints a happy birthday to <name>
    Scarlet.hear /hb (\S+)/i, :registered do
      reply format("Happy Birthday %s!", params[0])
    end
  end
end