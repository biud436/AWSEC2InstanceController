require 'uri'
require 'net/http'
require 'json'

# 이 클래스는 특정 URL에 GET 요청을 보내고 JSON(HASH)으로 반환 받습니다.
#
# ## 예제
#
#  url = "http://www.google.com"
#  data = WebRequest.get(url)
#
class WebRequest
    def self.get(url)
        uri = URI(url)
        response = Net::HTTP.get_response(uri)
        JSON.parse(response.body)
    end
end