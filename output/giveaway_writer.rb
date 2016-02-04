require 'nokogiri'

module Output
  class GiveawayWriter
    attr_accessor :wishlist, :normal, :bundled

    def build
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html {
          doc.body {
            fragment(doc, 'Wishlist', wishlist) unless wishlist.empty?
            fragment(doc, 'Non-Bundled Games', normal)
            fragment(doc, 'Bundled Games', bundled) unless bundled.empty?
          }
        }
      end
      builder.to_html
    end

    private
    def fragment(doc, title, items)
      doc.h1 title
      doc.ul {
        items.each { |giveaway|
          doc.li {
            doc.a(href: giveaway.uri) {
              doc.text giveaway.title
            }
          }
        }
      }
    end
  end
end
