module Retail
  AMAZON_AFFILIATE_ID = 'driscollbrookpress-20'
  ITUNES_AFFILIATE_ID = '1l3vpYQ'
  SMASHWORDS_AFFILIATE_ID = 'dalehartleyemery'

  AMAZON_URL_TEMPLATE = "http://amazon.com/dp/%s?tag=#{AMAZON_AFFILIATE_ID}"
  BN_URL_TEMPLATE = 'http://www.barnsandnoble.com/s/%s'

  IDENTIFIED_BY_PAPERBACK_ISBN10 = lambda { |item| ISBN::CALCULATOR.isbn10(item.book['paperback']['isbn']) }
  IDENTIFIED_BY_PAPERBACK_ISBN13 = lambda { |item| ISBN::CALCULATOR.isbn13(item.book['paperback']['isbn']) }
  IDENTIFIED_BY_B2R = lambda { |item| item.book['ebook']['books2read'] }

  BOOKS_2_READ_URL_TEMPLATE = 'https://books2read.com/u/%s'

  class Marketplace
    def initialize
      @retailers = {
        amazon: Retailer.new('Amazon', AMAZON_URL_TEMPLATE, IDENTIFIED_BY_PAPERBACK_ISBN10),
        bn: Retailer.new('B&amp;N', BN_URL_TEMPLATE, IDENTIFIED_BY_PAPERBACK_ISBN13),

        ibooks: Books2ReadRetailer.new('iBooks', 'apple'),
        kindle: Books2ReadRetailer.new('Kindle', 'amazon'),
        kobo: Books2ReadRetailer.new('Kobo', 'kobo'),
        nook: Books2ReadRetailer.new('Nook', 'nook'),

        other: Retailer.new('More&nbsp;Ebook&nbsp;Stores', BOOKS_2_READ_URL_TEMPLATE, IDENTIFIED_BY_B2R)
      }
    end

    def retailer(offerer)
      @retailers[offerer.to_sym]
    end
  end

  class Retailer
    def initialize(name, url_template, identify_item)
      @name = name
      @url_template = url_template
      @identify_item = identify_item
    end

    def identify(item)
      @identify_item.call(item)
    end

    def link_to(item)
      "<a href='#{@url_template % identify(item)}'>#{@name}</a>"
    end
  end

  class Books2ReadRetailer < Retailer
    def initialize(name, tag)
      super(name, BOOKS_2_READ_URL_TEMPLATE + '?store=' + tag, IDENTIFIED_BY_B2R)
    end

    def identify(item)
      item.book['ebook']['books2read']
    end
  end

  MARKETPLACE = Marketplace.new

  def offer_link(offer, book)
    retailer_key, stock_number = offer
    item = OpenStruct.new book: book, stock_number: stock_number
    MARKETPLACE.retailer(retailer_key).link_to(item)
  end
end

Liquid::Template.register_filter(Retail)
