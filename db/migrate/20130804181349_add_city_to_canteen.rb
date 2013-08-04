class AddCityToCanteen < ActiveRecord::Migration
  def up
    add_column :canteens, :city, :string

    puts 'Update cities...'

    rgx = /\d{5}\s+(?<city>\w+)/
    Canteen.where(city: nil).each do |canteen|
      if (result = rgx.match(canteen.address))
        canteen.update_attributes city: result[:city]
      end
    end

    puts "#{Canteen.where(city: nil).count} canteens without city left."
  end

  def down
    remove_column :canteens, :city
  end
end
