# This module checks whether the platform is on Windows or Linux
# 
# ## Example
#
#   OS.linux?
#   OS.windows?
#
module OS
    def self.linux?
        index = RUBY_PLATFORM =~ /(?:linux)/i
        index != nil and index >= 0
    end

    def self.windows?
        index = RUBY_PLATFORM =~ /(?:x32|x64)/i
        index != nil and index >= 0
    end
end