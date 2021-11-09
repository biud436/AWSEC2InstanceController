#!/bin/ruby -w

require 'ipaddr'
require_relative "../lib/OS"
require_relative "../lib/EC2"
require_relative "../lib/Github"

module EntryPoint

    class App
        def initialize
            @meta = Github::Metadata.new
            @ec2 = EC2.new

            # CRC 체크
            @meta.check_crc(
                success:->(crc){
                    # 데이터가 변경되지 않았습니다.
                    puts "새로운 데이터를 가져올 필요가 없습니다."
                }, 
                failed:->() {
                    # 캐시된 메타 데이터 파일이 없어서 새로 생성하였습니다.
                    puts "CRC 데이터를 가져오는데 실패했습니다."
                },
                different:->(cached_data, new_data) {
                    # 새로운 데이터가 있습니다.

                    # 기존 규칙을 캐시된 메타 파일로부터 가져옵니다
                    if cached_data.nil? or cached_data.empty? or !cached_data.is_a?(Array)
                        raise "캐시 데이터가 손상되었습니다."
                    end
                    
                    # 기존 규칙을 삭제합니다.
                    p "기존 인바운드 규칙을 삭제하였습니다."
                    @ec2.remove_inbound_rule(cached_data)

                    # 새로운 규칙을 가져와 적용합니다.
                    p "새로운 인바운드 규칙을 적용하였습니다.-"
                    @ec2.add_inbound_rule(new_data)
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
