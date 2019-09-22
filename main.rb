require "watir"
require "./constant.rb"
require "json"
include Watir
#
# @script: chotot.com crawler
# @author: TuongNguyen
#
$SITE_URL = "chotot.com"
$PAGE_NAV_MAX = 5

begin
  puts "-" * 50
  puts "Opening browser ..."
  browser = Watir::Browser.new :chrome
  browser.goto($SITE_URL)

  # close the popup
  Wait.until { !browser.div(class: ["ab-in-app-message", "ab-show", "ab-modal-interactions", "graphic", "ab-modal", "ab-effect-modal"]).nil? }
  popup = browser.div(class: ["ab-in-app-message", "ab-show", "ab-modal-interactions", "graphic", "ab-modal", "ab-effect-modal"])
  popup.i(aria_label: "Close Message").click!

  puts "click 'Bất động sản' menu item ..."
  browser.a(href: "https://nha.chotot.com#regionselect?v=1.1").click!

  # array to save all href of item in the page
  hrefs = []

  # get element content
  element_ads_contents = browser.div(class: "ctStickyAdsListing")
  element_normal_contents = browser.div(class: "-AGAL8Zp7YDoV-PVebFY0")

  current_page = 1

  # get all href
  loop do
    puts 'Retrieving all href on page '+ current_page.to_s 
    if current_page < 3
      Wait.until { !browser.div(class: "pgjTolSNq4-L--tpQ7Xp5").nil? }
      element_ads_items = element_ads_contents.as(class: "ctAdListingItem")
      element_ads_items.each do |element_ads_item|
        href = element_ads_item.href
        hrefs << href unless href.nil?
      end
    end

    Wait.until { !browser.div(class: "pgjTolSNq4-L--tpQ7Xp5").nil? }
    element_normal_items = element_normal_contents.as(class: "_3JMKvS6hucA6KaM9tX3Qb1")
    element_normal_items.each do |element_normal_item|
      href = element_normal_item.href
      hrefs << href unless href.nil?
    end

    # set break flag
    break if current_page == $PAGE_NAV_MAX

    # go to next page
    current_page += 1
    page_nav = browser.div(class: ["sc-fBuWsC", "eNbGuL"])
    page_nav.a(text: current_page.to_s).click!
  end

  # get data
  datas = []
  hrefs.each do |href|
    puts "-" * 50
    puts "Go to: " + href
    browser.goto(href)

    # show phone number
    Wait.until { !browser.div(class: "iltDBORq0FT_OjmouT7Ui").nil? }
    puts 'click on \'Nhấn để hiện số: _______***\''
    browser.div(class: ["sc-cHGsZl", "etsTpm"]).span().click!

    # get infomations
    puts "getting data ..."
    type = browser.span(class: "_2XzRqDnzWwQayyJVHsXLo_").text
    title = browser.h1(itemprop: "name").text
    price = browser.span(itemprop: "price").text + browser.span(itemprop: "priceCurrency").text
    description = browser.p(itemprop: "description").text
    phonenumber = browser.div(class: ["sc-cHGsZl", "etsTpm"]).span.strong.text

    # get more info
    more_info = ""
    moreinfo_element = browser.div(class: ["row", "_1DTCXk4eb6dusdylsQxCos"])
    moreinfo_element_items = moreinfo_element.divs(class: "media")
    moreinfo_element_items.each do |element|
      info = element.span.text
      more_info << info + "; " unless info.nil?
    end

    # address
    address = browser.div(class: ["media", "margin-top-05"]).div(class: ["media-body", "media-middle"]).text

    # add json to datas
    datas << JSON.generate(
      type: type,
      title: title,
      price: price,
      description: description,
      phonenumber: phonenumber,
      more_info: more_info,
      address: address,
    )
    puts "Done"
  end

  puts "-" * 50
  puts datas

  sleep($LONG_TIME_DELAY)
  puts "-" * 50
  puts 'closing browser ...'
  browser.close
  puts "-" * 50
  puts "Succeed!"

  
rescue => exception
  puts "**ERROR: " + exception.message
end
