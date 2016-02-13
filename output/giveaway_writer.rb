require 'nokogiri'

module Output
  class GiveawayWriter
    attr_accessor :wishlist, :normal, :bundled, :exists_in_account, :other_links

    def build
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html {
          doc.body {
            fragment(doc, 'Wishlist', wishlist) unless wishlist.empty?
            fragment(doc, 'Non-Bundled Games', normal)
            fragment(doc, 'Bundled Games', bundled) unless bundled.empty?
            fragment(doc, 'Exists in Account / Missing Base Game', exists_in_account) unless exists_in_account.empty?

            unless other_links.empty?
              doc.h1 'Other Links'
              doc.h2 "(#{other_links.length})"
              doc.ul {
                other_links.each { |link|
                  doc.li {
                    doc.a(href: link) {
                      doc.text link
                    }
                  }
                }
              }
            end
          }
        }
      end
      builder.to_html
    end

    private
    def fragment(doc, title, items)
      doc.h1 title
      doc.h2 "(#{items.length})"
      doc.ul {
        items.each { |giveaway|
          doc.li {
            doc.a(href: giveaway.uri) {
              if giveaway.enterable or giveaway.exists_in_account
                doc.text giveaway.title
              else
                doc.s giveaway.title
              end
            }
          }
        }
      }
    end
  end
end
