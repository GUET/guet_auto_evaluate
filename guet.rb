class Guet
  require 'net/http'
  require 'nokogiri'
  require 'open-uri'

  BASE_URL = 'bkjw.guet.edu.cn'

  LOGIN_URL = '/student/public/login.asp'
  LOGOUT_URL = '/student/public/logout.asp'
  USER_INFO_URL = '/student/Info.asp'

  LOGIN_DATA = 'username={user}&passwd={passwd}&login=%B5%C7%A1%A1%C2%BC'

  attr_accessor :http, :headers, :user, :passwd

  def initialize
    @http = Net::HTTP.new(BASE_URL, 80)

    resp, data = http.get(LOGIN_URL)

    cookie = resp.response['set-cookie'].split('; ')[0]

    @headers = {
        'Cookie' => cookie,
        'Referer' => 'http://bkjw.guet.edu.cn',
        'Content-Type' => 'application/x-www-form-urlencoded'
    }
  end

  def login(user , passwd)
    login_data = LOGIN_DATA.gsub(/\{user\}/, user)
    login_data = login_data.gsub(/\{passwd\}/, passwd)
    @user = user
    @passwd = passwd
    resp, data = @http.post(LOGIN_URL, login_data, @headers)

    if /red/.match resp.body
      false
    else
      true
    end
  end
  def get_user_info()
    resp, data = @http.get(USER_INFO_URL, @headers)
    info = []
    if resp.code == '200'
      doc =  Nokogiri::HTML(resp.body, nil, 'gbk')
      content = doc.xpath('//p')
      content.map { |e| info.push e.text }
    end
    return info
  end
  def logout()
    resp, data = @http.get(LOGOUT_URL, @headers)

    true if resp.code == '200'
  end
end
