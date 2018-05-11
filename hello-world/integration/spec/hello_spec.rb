require 'rspec'
require 'mechanize'
require 'timeout'


base_url = ENV['BASE_URL']

puts "=" * 100
puts " base url = #{base_url}"
puts "=" * 100

describe "the service" do 

  it "says hello" do
    agent = ::Mechanize.new do |a|
      a.open_timeout = 2
      a.read_timeout = 10
    end

    Timeout::timeout(5) do
      response = agent.get(base_url)

      expect(response.body).to eq "Hello World!"
    end

  end
end
