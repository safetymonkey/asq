module AsqMailerHelper
# Return a URL for a asq based on the VIP name
  def vip_url
    "http://#{Settings.vip_name}/asqs/#{@asq.name}"
  end
end