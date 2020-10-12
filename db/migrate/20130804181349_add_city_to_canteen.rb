# frozen_string_literal: true

class AddCityToCanteen < ActiveRecord::Migration[4.2]
  def up
    add_column :canteens, :city, :string

    say_with_time "Updating cities..." do
      rgx = /\d{5}\s+(?<city>\w+)/
      Canteen.where(city: nil).each do |canteen|
        if (result = rgx.match(canteen.address))
          canteen.update city: result[:city]
        end
      end

      say "#{Canteen.where(city: nil).count} canteens without city left.", :subitem
    end
  end

  def down
    remove_column :canteens, :city
  end
end
