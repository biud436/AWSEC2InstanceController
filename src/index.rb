#!/bin/ruby -w

require 'uri'
require 'net/http'
require 'json'
require 'ipaddr'
require 'aws-sdk-ec2'
require "yaml"
require 'zlib'

require_relative "../lib/OS"
require_relative "../lib/WebRequest"

# 이 클래스는 EC2 인스턴스의 인바운드 규칙을 조회하고, 새로운 인바운드 규칙을 추가합니다.
class EC2

    attr_accessor :client

    def initialize()
        load_config

        @access_id = @config['access_id']
        @secret_access_key = @config['secret_access_key']

        credential = Aws::Credentials.new(@access_id, @secret_access_key)
        ec2_client = Aws::EC2::Client.new(region:"ap-northeast-2", credentials:credential)

        @client = ec2_client
    end

    def load_config
        File.open(File.join(File.dirname(__FILE__), "..", 'config.yml'), 'r') do |f|
            @config = YAML.load(f)
        end
    end

    # @return [Array]
    def print_inbound_rules
        if not @client.is_a?(Aws::EC2::Client)
            puts "ec2_client is not a Aws::EC2::Client"
            return
        end

        addrs = @client.describe_security_groups.data.security_groups.collect do |e|        
            e.ip_permissions.collect do |i|
                cidr_ip = i.ip_ranges.first.cidr_ip
                desc = i.ip_ranges.first.description || ""
                port = i.from_port
                ret = {"ip" => cidr_ip, "desc" => desc, "port" => port}
                ret
            end
        end

        addrs
    end

    # @return [Void]
    def add_inbound_rule(ip_range)
        if not @client.is_a?(Aws::EC2::Client)
            puts "ec2_client is not a Aws::EC2::Client"
            return
        end

        @client.authorize_security_group_ingress({
            group_id: @config['security_group_id'],
            ip_permissions: [
                {
                    ip_protocol: 'ssh',
                    from_port: 22,
                    to_port: 22,
                    ip_ranges: [
                        {
                            cidr_ip: ip_range
                        }
                    ]
                }
            ]
        })

    end

end

module Github
    class Metadata
        attr_accessor :actions

        def initialize
            @meta = WebRequest.get('https://api.github.com/meta')
            @actions = @meta["actions"] || [""]
        end

        # crc를 만듭니다.
        def create_crc
            crc = Zlib::crc32(@actions.to_s)
            crc_raw = crc.to_s(16)

            # CRC 덤프
            data = {"crc" => crc_raw}
            yaml_dump_bin = YAML.dump(data)

            # CRC 덤프의 경로
            crc_file_path = File.join(File.dirname(__FILE__), "..", 'crc.bin')

            # CRC 덤프를 루프 경로에 저장
            f = File.open(crc_file_path, "w+")
            f.puts yaml_dump_bin
            f.close
        end

        def check_crc(&callback)
            crc_file_path = File.join(File.dirname(__FILE__), "..", 'crc.bin')
            is_existed = File.exist?(crc_file_path)

            # 파일이 존재한다면 CRC를 비교한다.
            if is_existed

                crc_raw = File.read(crc_file_path)

                # 이전 CRC 값
                prev_crc = YAML.load(crc_raw)[:crc] rescue ""

                # 새로운 CRC 값
                crc = Zlib::crc32(@actions.to_s)
                crc_raw_check = crc.to_s(16)

                if prev_crc == crc_raw_check
                    # 콜백 블럭을 호출한다.
                    callback.call
                else
                    puts "crc is different"
                end                
            else 
                # 콜백 블럭을 호출한다.
                callback.call
            end

        end
    end
end

module EntryPoint

    class App
        def initialize
            @meta = Github::Metadata.new
            @ec2 = EC2.new
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

