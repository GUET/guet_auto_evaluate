require 'net/http'
require 'nokogiri'
require 'open-uri'

acount = []

ARGV.each do|a|
  acount.push a
end

BASE_URL = 'bkjw.guet.edu.cn'

LOGIN_URL = '/student/public/login.asp'
LOGOUT_URL = '/student/public/logout.asp'

LOGIN_DATA = "username=#{acount[0]}&passwd=#{acount[1]}&login=%B5%C7%A1%A1%C2%BC"


VOTE_URL_LIST = {'/student/stjxpg.asp' => '/student/teachinpj.asp','/student/textevaluation.asp' => '/student/textpj.asp'}

http = Net::HTTP.new(BASE_URL, 80)
# GET request -> so the host can set his cookies
resp, data = http.post(LOGIN_URL, LOGIN_DATA)
cookie = resp.response['set-cookie'].split('; ')[0]

print "the cookie is :"+cookie+"\n"

headers = {
    'Cookie' => cookie,
    'Referer' => 'http://bkjw.guet.edu.cn',
    'Content-Type' => 'application/x-www-form-urlencoded'
}
puts "begin get vote list ..."

VOTE_URL_LIST.each do |vote_list_url,vote_post_url|
  puts 'start -------------------'
  vote_list=[]

  resp, data = http.get(vote_list_url,headers)

  if resp.message == "OK"
    resp.body.scan(/href=\'(.*?)\'/) do |x|
      x[0].gsub!('kcteachpj','teachinpj')
      x[0].gsub!(' ','')
      vote_list.push '/student/' + x[0]
    end
  end

  puts vote_list
  vote_list.each do |url|
    puts "start set up url : " + url
    tmp = []
    resp, data = http.get(url,headers)
    if resp.message == "OK"
      if /lwBtntijiao/.match resp.body
        html_doc = Nokogiri::HTML(resp.body)
        html_doc.search('form input').each do |link|
          tmp.push Array[link.get_attribute('name'),link.get_attribute('value')]
        end
      else
        puts url + ' was voted'
      end
    else
      puts resp.code
    end

    tmp_url = ''
    ax = nil
    tmp.each do |i|
      if ax == i[0]

      else
        tmp_url += i[0].to_s + '=' + i[1].to_s + '&'
      end
      ax = i[0]
    end
    puts vote_post_url + tmp_url

    puts "start vote..."
    resp, data = http.post(vote_post_url,tmp_url,headers)
    if resp.code == 200
      puts "vote complete"
    else
      puts  "error code is : " + resp.code
    end
  end
end

resp, data = http.get(LOGOUT_URL,headers)
print resp.code+" logout success"
