#!/bin/ruby -w

require 'ipaddr'
require_relative "../lib/OS"
require_relative "../lib/EC2"
require_relative "../lib/Github"

module EntryPoint

    class App
        def initialize
            @meta = Github::Metadata.new
            @meta.check_crc(
                success:->(crc){
                    puts "CRC 데이터는 #{crc} 입니다."
                }, 
                failed:->() {
                    puts "CRC 데이터를 가져오는데 실패했습니다."
                }
            )
        end
    end

    def refresh_github_workflow_inbound_rules
        actions = @meta.actions
        return false if actions.nil? or !actions.is_a?(Array)
        return if !@ec2.is_a?(EC2)

        actions.each do |e|
            addr = IPAddr.new(e)
            if addr.ipv4?
                # IP 취득
                addr = addr.to_s
                # 인바운드 규칙으로 추가
                @ec2.add_inbound_rule(addr)
            end
        end
    end
end

EntryPoint::App.new
