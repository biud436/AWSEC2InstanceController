require 'aws-sdk-ec2'
require "yaml"

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

    # 인바운드 규칙을 추가합니다.
    # @return [Void]
    def add_inbound_rule(rules)
        if not @client.is_a?(Aws::EC2::Client)
            puts "ec2_client is not a Aws::EC2::Client"
            return
        end

        rules.each do |rule|
            @client.authorize_security_group_ingress({
                group_id: @config['security_group_id'],
                ip_permissions: [
                    {
                        ip_protocol: 'ssh',
                        from_port: 22,
                        to_port: 22,
                        ip_ranges: [
                            {
                                cidr_ip: rule
                            }
                        ]
                    }
                ]
            })
        end

    end

    # 인바운드 규칙을 삭제합니다.
    # @return [Void]
    def remove_inbound_rule(prev_rules)
        if not @client.is_a?(Aws::EC2::Client)
            puts "ec2_client is not a Aws::EC2::Client"
            return
        end

        @client.revoke_security_group_ingress({
            group_id: @config['security_group_id'],
            ip_permissions: prev_rules.collect do |e|
                {
                    ip_protocol: 'ssh',
                    from_port: 22,
                    to_port: 22,
                    ip_ranges: [
                        {
                            cidr_ip: e
                        }
                    ]
                }
            end
        })       
    end

end